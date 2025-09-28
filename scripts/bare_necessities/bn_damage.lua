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
    debuff_spell = DEBUFFS.RESURRECTION_SICKNESS
})


function DamageResourceRefresh(player)
    local current = select(1, DAMAGE_RESOURCE:fetch(player:GetName()))
    if current <= DAMAGE_RESOURCE.minimum then
        if not player:HasAura(DAMAGE_RESOURCE.debuff_spell) then
            player:AddAura(DAMAGE_RESOURCE.debuff_spell, player)
        end
    else
        if player:HasAura(DAMAGE_RESOURCE.debuff_spell) then
            player:RemoveAura(DAMAGE_RESOURCE.debuff_spell)
        end
    end
end

NecessityResources = NecessityResources or {}
NecessityResources.Damage = DAMAGE_RESOURCE

NecessityResourceOrder = NecessityResourceOrder or {}
local damage_present = false
for _, key in ipairs(NecessityResourceOrder) do
    if key == "Damage" then
        damage_present = true
        break
    end
end
if not damage_present then
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
    player:RemoveAura(DEBUFFS.RESURRECTION_SICKNESS)
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
                local health_percent

                if player.GetHealthPct then
                    health_percent = player:GetHealthPct()
                else
                    health_percent = (current / player:GetMaxHealth()) * 100
                end

                if health_percent < 40 then
                    if math.random() < 0.05 then
                        player:SendBroadcastMessage("You feel your wounds deepen.")
                        DAMAGE_RESOURCE:decrement(player)
                    end
                end
            end

            DAMAGE_HEALTH_TRACK[guid] = current
        end
    end
end

CreateLuaEvent(pollDamageHealth, DAMAGE_HEALTH_POLL_MS, 0)
