-- Bare Necessities: aura-based resource recovery

local RESOURCE_RECOVERY_AURAS = {
    Rest = { "Cozy Fire" },
    Hunger = { "Food" },
    Thirst = { "Drink" }
}

local RECOVERY_MESSAGES = {
    Rest = "resting at a campfire",
    Hunger = "eating food",
    Thirst = "drinking"
}

local RECOVERY_DEBUFFS = {
    Rest = 1604,
    Hunger = 1604,
    Thirst = 1604
}

local AURA_RESOURCE_MAP = {}
for key, names in pairs(RESOURCE_RECOVERY_AURAS) do
    for _, name in ipairs(names) do
        AURA_RESOURCE_MAP[name] = key
    end
end

local function OnAuraApply(event, player, aura)
    local auraId = aura:GetAuraId()
    local auraName = "unknown"
    if type(GetSpellInfo) == "function" then
        local info = GetSpellInfo(auraId)
        if info and info.GetName then
            auraName = info:GetName()
        end
    end

    local resourceKey = AURA_RESOURCE_MAP[auraName]
    if not resourceKey then
        return
    end

    local resource = NecessityResources[resourceKey]
    if not resource then
        return
    end

    resource:increment(player)

    local debuff = RECOVERY_DEBUFFS[resourceKey]
    if debuff == DEBUFFS.RESURRECTION_SICKNESS then
        player:RemoveAura(debuff)
    end
end

RegisterPlayerEvent(64, OnAuraApply)
