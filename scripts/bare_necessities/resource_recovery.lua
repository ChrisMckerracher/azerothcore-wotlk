-- Bare Necessities: aura-based resource recovery

-- Spell IDs here are examples; adjust to match the buffs your server uses.
local RESOURCE_RECOVERY_AURAS = {
    Rest = {
        43024, -- Refreshment (campfire) placeholder
        67423  -- Cozy Fire placeholder
    },
    Hunger = {
        433,   -- Food
        45618  -- Eating (generic) placeholder
    },
    Thirst = {
        430,   -- Drink
        1137   -- Drink (generic) placeholder
    }
}

local AURA_TO_RESOURCE = {}
for resourceKey, auraList in pairs(RESOURCE_RECOVERY_AURAS) do
    for _, spellId in ipairs(auraList) do
        AURA_TO_RESOURCE[spellId] = resourceKey
    end
end

local function OnAuraApply(event, player, aura)
    local resources = BareNecessitiesResources
    if not resources then
        return
    end

    local spellId = aura:GetSpellId()
    local resourceKey = AURA_TO_RESOURCE[spellId]
    if not resourceKey then
        return
    end

    local resource = resources[resourceKey]
    if not resource then
        return
    end

    resource:increment(player)
end

RegisterPlayerEvent(64, OnAuraApply)
