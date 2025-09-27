-- Bare Necessities: shared periodic tick for player needs

local TICK_INTERVAL_SECONDS = 6000
local TICK_INTERVAL_MS = TICK_INTERVAL_SECONDS * 1000

local RESOURCES = {
    Hunger = Necessity:new({ column = "Hunger", label = "hunger", decrement_step = 1, increment_step = 1, default = 5, minimum = 0, maximum = 5, debuff_spell = 1604 }),
    Thirst = Necessity:new({ column = "Thirst", label = "thirst", decrement_step = 1, increment_step = 1, default = 5, minimum = 0, maximum = 5, debuff_spell = 1604 }),
    Rest = Necessity:new({ column = "Rest", label = "fatigue", decrement_step = 1, increment_step = 0.1, default = 5, minimum = 0, maximum = 5, debuff_spell = 1604 })
}

local RESOURCE_ORDER = { "Hunger", "Thirst", "Rest" }

NecessityResources = RESOURCES
NecessityResourceOrder = RESOURCE_ORDER

local function runTick()
    local players = GetPlayersInWorld()
    if not players then
        return
    end

    for _, key in ipairs(RESOURCE_ORDER) do
        local resource = RESOURCES[key]
        resource:tick(players)
    end
end

CreateLuaEvent(runTick, TICK_INTERVAL_MS, 0)
