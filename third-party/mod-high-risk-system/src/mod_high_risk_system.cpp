/*
*   Copyright (C) AstoriaCore 2021 | This piece of Code was customly coded by frytiks
*   for the AstoriaCore Team and is fully ported over from TrinityCore to AzerothCore.
*   It has multiple Bugfixes, Performance and Efficiency Updates! ~ Lushen
*/

#include "Bag.h"
#include "Chat.h"
#include "GameObject.h"
#include "Item.h"
#include "Log.h"
#include "LootMgr.h"
#include "ObjectGuid.h"
#include "Player.h"
#include "ScriptMgr.h"
#include "WorldSession.h"

#include <cstdint>
#include <vector>

namespace
{
constexpr uint32 CHEST_ENTRY = 184930; // generic loot chest visual without pre-defined rewards
constexpr uint32 CHEST_LIFETIME = 300; // seconds
constexpr uint8 MAX_LOOT_STACK = 255;

struct ItemLocation
{
    uint8 bagSlot = 0;
    uint8 slot = 0;
};

bool IsEligibleItem(Item const* item)
{
    if (!item)
        return false;

    return true;
}

void AppendIfEligible(Player& player, std::vector<ItemLocation>& items, uint8 bagSlot, uint8 slot)
{
    if (Item* item = player.GetItemByPos(bagSlot, slot))
        if (IsEligibleItem(item))
            items.push_back({ bagSlot, slot });
}

void CollectEquippedItems(Player& player, std::vector<ItemLocation>& items)
{
    for (uint8 slot = EQUIPMENT_SLOT_START; slot < EQUIPMENT_SLOT_END; ++slot)
        AppendIfEligible(player, items, INVENTORY_SLOT_BAG_0, slot);
}

void CollectBackpackItems(Player& player, std::vector<ItemLocation>& items)
{
    for (uint8 slot = INVENTORY_SLOT_ITEM_START; slot < INVENTORY_SLOT_ITEM_END; ++slot)
        AppendIfEligible(player, items, INVENTORY_SLOT_BAG_0, slot);
}

void CollectBagContents(Player& player, std::vector<ItemLocation>& items)
{
    for (uint8 bagSlot = INVENTORY_SLOT_BAG_START; bagSlot < INVENTORY_SLOT_BAG_END; ++bagSlot)
    {
        if (Bag* bag = player.GetBagByPos(bagSlot))
            for (uint8 slot = 0; slot < bag->GetBagSize(); ++slot)
                if (Item* item = bag->GetItemByPos(slot))
                    if (IsEligibleItem(item))
                        items.push_back({ bagSlot, slot });

        AppendIfEligible(player, items, INVENTORY_SLOT_BAG_0, bagSlot);
    }
}

void CollectSpecialtyItems(Player& player, std::vector<ItemLocation>& items)
{
    for (uint8 slot = KEYRING_SLOT_START; slot < KEYRING_SLOT_END; ++slot)
        AppendIfEligible(player, items, INVENTORY_SLOT_BAG_0, slot);

    for (uint8 slot = CURRENCYTOKEN_SLOT_START; slot < CURRENCYTOKEN_SLOT_END; ++slot)
        AppendIfEligible(player, items, INVENTORY_SLOT_BAG_0, slot);
}

std::vector<ItemLocation> CollectPlayerItems(Player& player)
{
    std::vector<ItemLocation> items;
    items.reserve(INVENTORY_SLOT_ITEM_END + 64); // account for bags and specialty storage

    CollectEquippedItems(player, items);
    CollectBackpackItems(player, items);
    CollectBagContents(player, items);
    CollectSpecialtyItems(player, items);

    return items;
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

        uint32 remainingCount = item->GetCount() > 0 ? item->GetCount() : 1;

        do
        {
            uint8 const chunk = remainingCount > MAX_LOOT_STACK ? MAX_LOOT_STACK : static_cast<uint8>(remainingCount);
            LootStoreItem lootItem(item->GetEntry(), 0, 100.0f, 0, LOOT_MODE_DEFAULT, 0, chunk, chunk);
            chest.loot.AddItem(lootItem);

            if (!chest.loot.items.empty())
            {
                LootItem& lootEntry = chest.loot.items.back();
                lootEntry.count = chunk;
                lootEntry.randomPropertyId = item->GetItemRandomPropertyId();
                lootEntry.randomSuffix = item->GetItemSuffixFactor();
                lootEntry.freeforall = true;
            }

            if (remainingCount <= chunk)
                break;

            remainingCount -= chunk;
        } while (true);

        player.DestroyItem(location.bagSlot, location.slot, true);
        return true;
    }

    return false;
}

uint32 DropAllCarriedItems(Player& player, GameObject& chest)
{
    std::vector<ItemLocation> locations = CollectPlayerItems(player);
    uint32 dropped = 0;

    for (ItemLocation const& location : locations)
        if (MoveItemToChest(player, chest, location))
            ++dropped;

    return dropped;
}

GameObject* SummonChest(Player& player)
{
    GameObject* chest = player.SummonGameObject(CHEST_ENTRY, player.GetPositionX(), player.GetPositionY(), player.GetPositionZ(), player.GetOrientation(), 0.0f, 0.0f, 0.0f, 0.0f, CHEST_LIFETIME);

    if (!chest)
        return nullptr;

    // Detach ownership so instant resurrections can't despawn it and purge any template loot.
    player.RemoveGameObject(chest, false);
    chest->SetOwnerGUID(ObjectGuid::Empty);
    chest->loot.clear();
    chest->loot.lootOwnerGUID = player.GetGUID();
    chest->loot.loot_type = LOOT_CORPSE;
    chest->SetLootState(GO_READY);
    return chest;
}
}

class HighRiskSystem final : public PlayerScript
{
public:
    HighRiskSystem() : PlayerScript("HighRiskSystem") { }

    void OnPlayerJustDied(Player* player) override
    {
        if (!player)
            return;

        Map const* map = player->GetMap();
        if (!map)
            return;

        // Skip instanced content: dungeons include raids, battlegrounds cover arenas too.
        if (map->IsDungeon() || map->IsBattlegroundOrArena())
            return;

        LOG_INFO("module", "HighRiskSystem death hook triggered for {}", player->GetName());

        // Always spawn the chest at the death location before siphoning items.
        GameObject* chest = SummonChest(*player);
        if (!chest)
            return;

        uint32 const dropped = DropAllCarriedItems(*player, *chest);

        chest->loot.lootOwnerGUID = ObjectGuid::Empty;

        if (dropped == 0)
            chest->DespawnOrUnsummon();
    }
};

void AddSC_high_risk_system()
{
    new HighRiskSystem();
}
