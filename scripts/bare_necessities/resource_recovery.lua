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

    player:SendBroadcastMessage(string.format(
        "Debug: aura apply event=%d auraId=%d name=%s type=%s",
        event,
        auraId,
        auraName,
        type(aura)
    ))

    local resourceKey = AURA_RESOURCE_MAP[auraName]
    if not resourceKey then
        return
    end

    local resource = NecessityResources[resourceKey]
    if not resource then
        return
    end

    local action = RECOVERY_MESSAGES[resourceKey] or "recovering"
    player:SendBroadcastMessage(string.format("Aura detected: %s (%d)", auraName, auraId))
    player:SendBroadcastMessage(string.format("Aura detected: %s. %s will improve.", action, resource.label))

    resource:increment(player)

    local debuff = RECOVERY_DEBUFFS[resourceKey]
    if debuff then
        player:RemoveAura(debuff)
    end
end

RegisterPlayerEvent(64, OnAuraApply)
