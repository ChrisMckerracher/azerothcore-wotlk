-- Bare Necessities: shared periodic tick for player needs

local TICK_INTERVAL_SECONDS = 10
local TICK_INTERVAL_MS = TICK_INTERVAL_SECONDS * 1000

local RESOURCES = {
    Hunger = Necessity:new({ column = "Hunger", label = "hunger", decrement = 1, default = 5, minimum = 0, maximum = 5 }),
    Thirst = Necessity:new({ column = "Thirst", label = "thirst", decrement = 1, default = 5, minimum = 0, maximum = 5 }),
    Rest = Necessity:new({ column = "Rest", label = "fatigue", decrement = 1, default = 5, minimum = 0, maximum = 5 })
}

local RESOURCE_ORDER = { "Hunger", "Thirst", "Rest" }

BareNecessitiesResources = RESOURCES
BareNecessitiesResourceOrder = RESOURCE_ORDER

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
