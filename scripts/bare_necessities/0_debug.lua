-- Bare Necessities: debug utilities for rapid testing

local COOKING_SKILL_ID = 185
local CAMPFIRE_SPELL_ID = 818

local FOOD_ITEMS = {
    {id = 117, name = "Tough Jerky"},
    {id = 2287, name = "Haunch of Meat"},
    {id = 4599, name = "Cured Ham Steak"}
}

local DRINK_ITEMS = {
    {id = 159, name = "Refreshing Spring Water"},
    {id = 1179, name = "Ice Cold Milk"},
    {id = 1645, name = "Moonberry Juice"}
}

local CAMPFIRE_REAGENTS = {
    {id = 4470, name = "Simple Wood", count = 5},
    {id = 4471, name = "Flint and Tinder", count = 5}
}

local function seedRandom()
    if NecessityDebugSeeded then
        return
    end

    local seed = os.time() + math.random(1000)
    math.randomseed(seed)
    NecessityDebugSeeded = true
end

local function pickRandomItem(pool)
    return pool[math.random(1, #pool)]
end

local function grantItem(player, item)
    local amount = item.count or 5
    player:AddItem(item.id, amount)
    return string.format("%s x%d", item.name, amount)
end

local function ensureCampfireReagents(player)
    local granted = {}
    for _, reagent in ipairs(CAMPFIRE_REAGENTS) do
        table.insert(granted, grantItem(player, reagent))
    end
    return granted
end

local function ensureCookingSkill(player)
    player:SetSkill(COOKING_SKILL_ID, 0, 75, 75)
    player:LearnSpell(CAMPFIRE_SPELL_ID)
end

local function levelPlayer(player)
    if player:GetLevel() < 60 then
        player:SetLevel(60)
    end
end

local function OnDebugLogin(event, player)
    seedRandom()
    levelPlayer(player)
    ensureCookingSkill(player)

    local food = grantItem(player, pickRandomItem(FOOD_ITEMS))
    local drink = grantItem(player, pickRandomItem(DRINK_ITEMS))
    local reagents = ensureCampfireReagents(player)

    local message = string.format(
        "Debug loadout: food(%s), drink(%s), reagents(%s)",
        food,
        drink,
        table.concat(reagents, ", ")
    )
    player:SendBroadcastMessage(message)
end

RegisterPlayerEvent(3, OnDebugLogin)
