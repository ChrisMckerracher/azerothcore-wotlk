-- Bare Necessities: debug utilities for rapid testing

local COOKING_SKILL_ID = 185
local CAMPFIRE_SPELL_ID = 818
local FIRST_AID_SKILL_ID = 129
local FIRST_AID_MAX_SKILL = 300

local FOOD_ITEM = { id = 117, name = "Tough Jerky", count = 20 }
local DRINK_ITEM = { id = 159, name = "Refreshing Spring Water", count = 20 }
local CAMPFIRE_REAGENTS = {
    { id = 4470, name = "Simple Wood", count = 1 },
    { id = 4471, name = "Flint and Tinder", count = 1 }
}
local BANDAGE_ITEM = { id = 1251, name = "Linen Bandage", count = 20 }
local QUIVER_ITEM = { id = 5439, name = "Small Quiver" }
local EXTRA_BAG_ITEM = { id = 5571, name = "Small Black Pouch" }
local ARROW_ITEM = { id = 2512, name = "Rough Arrow", count = 200 }

local BAG_SLOTS = { 19, 20, 21, 22 }
local BACKPACK_SLOT_START = 23
local BACKPACK_SLOT_END = 38

local function seedRandom()
    if NecessityDebugSeeded then
        return
    end

    local seed = os.time() + math.random(1000)
    math.randomseed(seed)
    NecessityDebugSeeded = true
end

local function ensureCookingSkill(player)
    player:SetSkill(COOKING_SKILL_ID, 0, 75, 75)
    player:LearnSpell(CAMPFIRE_SPELL_ID)
end

local function ensureFirstAid(player)
    player:SetSkill(FIRST_AID_SKILL_ID, 0, FIRST_AID_MAX_SKILL, FIRST_AID_MAX_SKILL)
end

local function destroyItem(player, item)
    if not item then
        return
    end

    local count = item:GetCount()
    if count and count > 0 then
        player:RemoveItem(item, count)
    end
end

local function clearBagContents(player, bagSlot)
    local bag = player:GetInventoryItem(bagSlot)
    if not bag then
        return
    end

    local size = bag:GetBagSize() or 0
    for slot = 0, size - 1 do
        local item = player:GetItemByPos(bagSlot, slot)
        destroyItem(player, item)
    end

    player:RemoveItem(bag, 1)
end

local function clearBackpack(player)
    for slot = BACKPACK_SLOT_START, BACKPACK_SLOT_END do
        destroyItem(player, player:GetInventoryItem(slot))
    end
end

local function clearNonBackpackItems(player)
    for _, slot in ipairs(BAG_SLOTS) do
        clearBagContents(player, slot)
    end

    clearBackpack(player)
end

local function grantItem(player, item)
    if not item then
        return "unknown item"
    end

    player:AddItem(item.id, item.count or 1)
    return string.format("%s x%d", item.name or "item", item.count or 1)
end

local function setupLoadout(player)
    local reagents = {}
    for _, reagent in ipairs(CAMPFIRE_REAGENTS) do
        table.insert(reagents, grantItem(player, reagent))
    end

    grantItem(player, FOOD_ITEM)
    grantItem(player, DRINK_ITEM)
    grantItem(player, BANDAGE_ITEM)
    grantItem(player, QUIVER_ITEM)
    grantItem(player, ARROW_ITEM)
    grantItem(player, EXTRA_BAG_ITEM)
    grantItem(player, EXTRA_BAG_ITEM)

    player:SendBroadcastMessage(string.format(
        "Debug loadout applied: reagents(%s), food(%s), drink(%s), bandages(%s), quiver(%s), arrows(%s), extra bags x2",
        table.concat(reagents, ", "),
        FOOD_ITEM.name,
        DRINK_ITEM.name,
        BANDAGE_ITEM.name,
        QUIVER_ITEM.name,
        ARROW_ITEM.name
    ))
end

local function levelPlayer(player)
    player:SetLevel(15)
end

local function OnDebugLogin(event, player)
    seedRandom()
    levelPlayer(player)
    ensureCookingSkill(player)
    ensureFirstAid(player)
    clearNonBackpackItems(player)
    setupLoadout(player)
end

RegisterPlayerEvent(3, OnDebugLogin)
