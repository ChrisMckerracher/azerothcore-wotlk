-- PLAYER_EVENT_ON_LOGIN (Hooks.h:166) for level 1 starter kit

local CAMPFIRE_SPELL_ID = 818
local FIRST_AID_SKILL_ID = 129
local FIRST_AID_MAX_SKILL = 75
local CLASS_HUNTER = 3 -- SharedDefines.h:143

local FOOD_ITEM = { id = 117, name = "Tough Jerky", count = 20 }
local DRINK_ITEM = { id = 159, name = "Refreshing Spring Water", count = 20 }
local CAMPFIRE_REAGENTS = {
    { id = 4470, name = "Simple Wood", count = 3 },
    { id = 4471, name = "Flint and Tinder", count = 3 }
}
local BANDAGE_ITEM = { id = 1251, name = "Linen Bandage", count = 20 }
local QUIVER_ITEM = { id = 5439, name = "Small Quiver" }
local ARROW_ITEM = { id = 2512, name = "Rough Arrow", count = 200 }

local function ensureFirstAid(player)
    player:SetSkill(FIRST_AID_SKILL_ID, 0, 1, FIRST_AID_MAX_SKILL)
end

local function grantCampfire(player)
    player:LearnSpell(CAMPFIRE_SPELL_ID)
end

local function ensureItem(player, item)
    if not item then
        return "unknown item"
    end

    local desired = item.count or 1
    local current = player:GetItemCount(item.id)
    local missing = desired - current
    if missing > 0 then
        player:AddItem(item.id, missing)
    end

    return string.format("%s x%d", item.name or "item", desired)
end

local function setupLoadout(player)
    for _, reagent in ipairs(CAMPFIRE_REAGENTS) do
        ensureItem(player, reagent)
    end

    ensureItem(player, FOOD_ITEM)
    ensureItem(player, DRINK_ITEM)
    ensureItem(player, BANDAGE_ITEM)

    if player:GetClass() ~= CLASS_HUNTER then
        ensureItem(player, ARROW_ITEM)
        ensureItem(player, QUIVER_ITEM)
        if player:GetItemCount(ARROW_ITEM.id) > 0 then
            player:SetAmmo(ARROW_ITEM.id)
        end
    end
end

local STARTER_LEVEL = 1

local function OnLogin(event, player)
    if player:GetLevel() ~= STARTER_LEVEL then
        return
    end

    ensureFirstAid(player)
    grantCampfire(player)
    setupLoadout(player)
end

RegisterPlayerEvent(3, OnLogin)
