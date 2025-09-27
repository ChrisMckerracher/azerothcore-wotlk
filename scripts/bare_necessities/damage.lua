-- Bare Necessities: damage necessity tracking

local DAMAGE_AURA_NAME = "First Aid"

local FIRST_AID_SKILL_ID = 129
local FIRST_AID_MAX_SKILL = 300
local BANDAGE_LOADOUT = {
    { id = 1251, count = 20 }, -- Linen Bandage
    { id = 3530, count = 20 }  -- Wool Bandage
}

local DAMAGE_HEALTH_TRACK = {}
local DAMAGE_HEALTH_POLL_MS = 1000
local DAMAGE_RESOURCE = Necessity:new({
    column = "Damage",
    label = "damage",
    decrement_step = 1,
    increment_step = 1,
    default = 5,
    minimum = 0,
    maximum = 5,
    debuff_spell = 15007 -- Resurrection Sickness
})

if NecessityResources and not NecessityResources.Damage then
    NecessityResources.Damage = DAMAGE_RESOURCE
    table.insert(NecessityResourceOrder, "Damage")
end

local function ensureFirstAidLoadout(player)
    player:SetSkill(FIRST_AID_SKILL_ID, 0, FIRST_AID_MAX_SKILL, FIRST_AID_MAX_SKILL)

    for _, item in ipairs(BANDAGE_LOADOUT) do
        player:AddItem(item.id, item.count)
    end
end

local function OnDamageLogin(event, player)
    ensureFirstAidLoadout(player)
    DAMAGE_HEALTH_TRACK[player:GetGUIDLow()] = player:GetHealth()
    local current = select(1, DAMAGE_RESOURCE:fetch(player:GetName()))
    player:SendBroadcastMessage(string.format("Damage status: %d.", current))
end

RegisterPlayerEvent(3, OnDamageLogin)

local function OnDamageLogout(event, player)
    DAMAGE_HEALTH_TRACK[player:GetGUIDLow()] = nil
end

RegisterPlayerEvent(4, OnDamageLogout)

local function OnDamageAura(event, player, aura)
    if type(GetSpellInfo) ~= "function" then
        return
    end

    local info = GetSpellInfo(aura:GetAuraId())
    if not info or not info.GetName then
        return
    end

    if info:GetName() ~= DAMAGE_AURA_NAME then
        return
    end

    player:SendBroadcastMessage("Bandaging reduces your damage level.")
    DAMAGE_RESOURCE:increment(player)
    player:RemoveAura(15007)
end

RegisterPlayerEvent(64, OnDamageAura)

local function pollDamageHealth()
    local players = GetPlayersInWorld()
    if not players then
        return
    end

    for _, player in pairs(players) do
        if player and player:IsInWorld() then
            local guid = player:GetGUIDLow()
            local current = player:GetHealth()
            local previous = DAMAGE_HEALTH_TRACK[guid]

            if previous and current < previous then
                player:SendBroadcastMessage("You feel your wounds deepen.")
                if math.random() < 0.5 then
                    DAMAGE_RESOURCE:decrement(player)
                end
            end

            DAMAGE_HEALTH_TRACK[guid] = current
        end
    end
end

CreateLuaEvent(pollDamageHealth, DAMAGE_HEALTH_POLL_MS, 0)
