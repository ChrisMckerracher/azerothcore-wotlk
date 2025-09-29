/*
*   Copyright (C) AstoriaCore 2021 | This piece of Code was customly coded by frytiks
*   for the AstoriaCore Team and is fully ported over from TrinityCore to AzerothCore.
*   It has multiple Bugfixes, Performance and Efficiency Updates! ~ Lushen
*/

#include "Bag.h"
#include "Chat.h"
#include "Creature.h"
#include "DBCStores.h"
#include "GameObject.h"
#include "Item.h"
#include "LootMgr.h"
#include "ObjectGuid.h"
#include "Player.h"
#include "Random.h"
#include "ScriptMgr.h"
#include "WorldSession.h"

#include <algorithm>
#include <cstdint>
#include <unordered_set>
#include <vector>

namespace
{
constexpr uint32 SPELL_SICKNESS = 15007;
constexpr uint32 CHEST_ENTRY = 179697;
constexpr uint32 CHEST_LIFETIME = 300; // seconds
constexpr uint8 MAX_ITEMS_TO_DROP = 2;
constexpr uint8 SECOND_DROP_CHANCE = 70;

struct ItemLocation
{
    Item* item = nullptr;
    uint8 bagSlot = 0;
    uint8 slot = 0;
};

bool IsPlayerInSanctuary(Player const& player)
{
    if (AreaTableEntry const* area = sAreaTableStore.LookupEntry(player.GetAreaId()))
        return area->IsSanctuary();

    return false;
}

bool IsEligiblePvPKill(Player* killer, Player* killed)
{
    if (!killer || killer == killed)
        return false;

    if (killer->GetLevel() >= killed->GetLevel() + 5)
        return false;

    if (IsPlayerInSanctuary(*killer) || IsPlayerInSanctuary(*killed))
        return false;

    if (WorldSession* killerSession = killer->GetSession())
        if (WorldSession* killedSession = killed->GetSession())
            if (killerSession->GetRemoteAddress() == killedSession->GetRemoteAddress())
                return false;

    return true;
}

bool IsEligibleItem(Item const* item, bool requireEquipped)
{
    if (!item)
        return false;

    if (requireEquipped && !item->IsEquipped())
        return false;

    if (ItemTemplate const* proto = item->GetTemplate())
        return proto->Quality >= ITEM_QUALITY_UNCOMMON;

    return false;
}

std::vector<ItemLocation> CollectEquippedItems(Player& player)
{
    std::vector<ItemLocation> items;
    items.reserve(EQUIPMENT_SLOT_END);

    for (uint8 slot = EQUIPMENT_SLOT_START; slot < EQUIPMENT_SLOT_END; ++slot)
        if (Item* item = player.GetItemByPos(INVENTORY_SLOT_BAG_0, slot))
            if (IsEligibleItem(item, true))
                items.push_back({ item, INVENTORY_SLOT_BAG_0, slot });

    return items;
}

std::vector<ItemLocation> CollectBackpackItems(Player& player)
{
    std::vector<ItemLocation> items;

    for (uint8 slot = INVENTORY_SLOT_ITEM_START; slot < INVENTORY_SLOT_ITEM_END; ++slot)
        if (Item* item = player.GetItemByPos(INVENTORY_SLOT_BAG_0, slot))
            if (IsEligibleItem(item, false))
                items.push_back({ item, INVENTORY_SLOT_BAG_0, slot });

    for (uint8 bagSlot = INVENTORY_SLOT_BAG_START; bagSlot < INVENTORY_SLOT_BAG_END; ++bagSlot)
        if (Bag* bag = player.GetBagByPos(bagSlot))
            for (uint32 slot = 0; slot < bag->GetBagSize(); ++slot)
                if (Item* item = bag->GetItemByPos(slot))
                    if (IsEligibleItem(item, false))
                        items.push_back({ item, bagSlot, static_cast<uint8>(slot) });

    return items;
}

ItemLocation SelectAndEraseRandom(std::vector<ItemLocation>& items)
{
    if (items.empty())
        return {};

    uint32 const index = urand(0, items.size() - 1);
    ItemLocation const location = items[index];
    items[index] = items.back();
    items.pop_back();
    return location;
}

void AnnounceLostItem(Player& player, Item const& item)
{
    if (WorldSession* session = player.GetSession())
        if (ItemTemplate const* proto = item.GetTemplate())
            ChatHandler(session).PSendSysMessage("|cffDA70D6You have lost your |cffffffff|Hitem:%u:0:0:0:0:0:0:0:0|h[%s]|h|r", item.GetEntry(), proto->Name1.c_str());
}

bool MoveItemToChest(Player& player, GameObject& chest, ItemLocation const& location)
{
    if (Item* item = player.GetItemByPos(location.bagSlot, location.slot))
    {
        ItemTemplate const* proto = item->GetTemplate();
        if (!proto)
            return false;

        AnnounceLostItem(player, *item);

        uint8 const stackCount = item->GetCount() > 0 ? (item->GetCount() > 255 ? 255 : item->GetCount()) : 1;
        LootStoreItem lootItem(item->GetEntry(), 0, 100.0f, 0, LOOT_MODE_DEFAULT, 0, stackCount, stackCount);
        chest.loot.AddItem(lootItem);

        player.DestroyItem(location.bagSlot, location.slot, true);
        return true;
    }

    return false;
}

bool DropRandomItem(Player& player, GameObject& chest, bool preferEquipped)
{
    if (preferEquipped)
    {
        std::vector<ItemLocation> equipped = CollectEquippedItems(player);
        if (!equipped.empty())
            return MoveItemToChest(player, chest, SelectAndEraseRandom(equipped));
    }

    std::vector<ItemLocation> allCandidates = CollectEquippedItems(player);
    std::vector<ItemLocation> backpack = CollectBackpackItems(player);
    allCandidates.insert(allCandidates.end(), backpack.begin(), backpack.end());

    if (allCandidates.empty())
        return false;

    return MoveItemToChest(player, chest, SelectAndEraseRandom(allCandidates));
}

GameObject* SummonChest(Player& killed, Player* summoner)
{
    Player* owner = summoner ? summoner : &killed;
    GameObject* chest = owner->SummonGameObject(CHEST_ENTRY, killed.GetPositionX(), killed.GetPositionY(), killed.GetPositionZ(), killed.GetOrientation(), 0.0f, 0.0f, 0.0f, 0.0f, CHEST_LIFETIME);

    if (!chest)
        return nullptr;

    owner->AddGameObject(chest);
    chest->SetOwnerGUID(ObjectGuid::Empty);
    return chest;
}
}

class HighRiskSystem final : public PlayerScript
{
public:
    HighRiskSystem() : PlayerScript("HighRiskSystem") { }

    void OnPlayerPVPKill(Player* killer, Player* killed) override
    {
        if (!killer || !killed)
            return;

        MarkHandled(*killed);
        TryHandleDeath(*killed, killer);
    }

    void OnPlayerKilledByCreature(Creature* /*creature*/, Player* killed) override
    {
        if (!killed)
            return;

        MarkHandled(*killed);
        TryHandleDeath(*killed, nullptr);
    }

    void OnPlayerJustDied(Player* player) override
    {
        if (!player)
            return;

        ObjectGuid::LowType const guidLow = player->GetGUID().GetCounter();
        if (_handledDeaths.erase(guidLow) > 0)
            return;

        TryHandleDeath(*player, nullptr);
    }

private:
    void MarkHandled(Player& player)
    {
        _handledDeaths.insert(player.GetGUID().GetCounter());
    }

    void TryHandleDeath(Player& killed, Player* killer)
    {
        if (killed.HasAura(SPELL_SICKNESS))
            return;

        if (killer && !IsEligiblePvPKill(killer, &killed))
            return;

        if (!killer && IsPlayerInSanctuary(killed))
            return;

        if (!roll_chance_i(70))
            return;

        GameObject* chest = SummonChest(killed, killer);
        if (!chest)
            return;

        uint8 dropped = 0;

        if (DropRandomItem(killed, *chest, true))
            ++dropped;

        if (dropped < MAX_ITEMS_TO_DROP && roll_chance_i(SECOND_DROP_CHANCE) && DropRandomItem(killed, *chest, false))
            ++dropped;

        if (dropped == 0)
            chest->DespawnOrUnsummon();
    }

    std::unordered_set<ObjectGuid::LowType> _handledDeaths;
};

void AddSC_high_risk_system()
{
    new HighRiskSystem();
}
