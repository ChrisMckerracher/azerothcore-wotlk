function createRage(player)
    if player:GetClassAsString() == CLASS_WARRIOR then
        return
    end
    player:SetPowerType(RESOURCE_RAGE)
    player:SetMaxPower(RESOURCE_RAGE, 500)
    player:SetPower(0, RESOURCE_RAGE)
end

local function handleUpdate(player, sc_spell)
    local player_class = player:GetClassAsString()
    -- Let rogue and warrior spells are handled by default
    if sc_spell.class == CLASS_ROGUE or sc_spell.class == CLASS_WARRIOR then
        return
    end

    if player_class == CLASS_ROGUE then
        -- rogue magic spells default to consuming 25 rage
        local rage_offset = sc_spell.rage
        rage_offset = rage_offset or 250
        local rage = player:GetPower(1)
        rage = rage - rage_offset
        rage = (rage >= 0) and rage or 0
        player:SetPower(rage, 1)
    end

    if player_class == CLASS_WARRIOR then
        -- warrior magic spells default to consuming 100 energy
        local energy_offset = sc_spell.rage
        energy_offset = energy_offset or 100
        local energy = player:GetPower(3)
        energy = energy - energy_offset
        energy = (energy >= 0) and energy or 0
        player:SetPower(energy, 3)
    end
end

local function OnSpellCast(event, player, spell, skipCheck)
    local subclass = SUBCLASSES[GetSubclass(player:GetName())]
    if subclass ~= nil then
        local sc_spells = subclass:GetSpells(player:GetLevel())
        for i = 1, #sc_spells do
            local sc_spell = sc_spells[i]
            if sc_spell.spell_id == spell:GetEntry() then
                handleUpdate(player, sc_spell)
            end
        end
    end
end

local function shouldCancel(player, sc_spell)
    local player_class = player:GetClassAsString()
    -- Let rogue and warrior spells are handled by default
    if sc_spell.class == CLASS_ROGUE or sc_spell.class == CLASS_WARRIOR then
        return
    end
    if player_class == CLASS_ROGUE then
        -- rogue magic spells default to consuming 25 rage
        local rage_offset = sc_spell.rage
        rage_offset = rage_offset or 250
        local rage = player:GetPower(1)
        return (rage - rage_offset) < 0
    end

    if player_class == CLASS_WARRIOR then
        -- warrior magic spells default to consuming 100 energy
        local energy_offset = sc_spell.rage
        energy_offset = energy_offset or 100
        local energy = player:GetPower(3)
        return (energy - energy_offset) < 0
    end

    return false
end

-- This gets called in Register, alternatively as a ToDo, is loop through every single spell in the subclass list and register it
function OnPrepare(event, player, spell)
    local subclass = SUBCLASSES[GetSubclass(player:GetName())]
    if subclass ~= nil then
        local sc_spells = subclass:GetSpells(player:GetLevel())
        for i = 1, #sc_spells do
            local sc_spell = sc_spells[i]
            if sc_spell.spell_id == spell:GetEntry() and shouldCancel(player, sc_spell) then
                spell:Cancel()
            end
        end
    end
end

RegisterPlayerEvent(5, OnSpellCast)


