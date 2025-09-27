SubClassLevelRange = {}
SubClassLevelRange.__index = SubClassLevelRange
function SubClassLevelRange:new(level, spells, proficiencies)
    local instance = {}
    setmetatable(instance, SubClassLevelRange)
    instance.level = level
    instance.spells = spells
    instance.proficiencies = proficiencies
    return instance
end

SubClass = {}
SubClass.__index = SubClass

-- ToDo: Implement proficiencies, Registration and Deregistration, with careful attention to dereg
function SubClass:new(name, spell_level_ranges, mandatory_items)
    local instance = {}
    setmetatable(instance, SubClass)
    instance.name = name
    instance.spell_level_ranges = spell_level_ranges
    instance.mandatory_items = mandatory_items
    return instance
end

-- Because Player is a builtin concept in Eluna, I'm not sure I can extend it. Instead Subclass Registers the Player. Like a shitty listener pattern
function SubClass:Register(player)
    if player:GetClassAsString() ~= self.name then
        local spells_to_register = self:GetSpells(player:GetLevel())
        for _, v in ipairs(spells_to_register) do
            if v.class ~= player_class then
                RegisterSpellEvent(v.spell_id, 1, OnPrepare)
            end
            player:LearnSpell(v.spell_id)
        end

        local proficiencies = self:GetProficiencies(player:GetLevel())
        for _, v in ipairs(proficiencies) do
            v:Register(player)
        end
    end
end

-- Because Player is a builtin concept in Eluna, instead Subclass Deregisters the Player. Like a shitty listener pattern
function SubClass:Deregister(player)
    local player_class = player:GetClassAsString()
    local spells_to_register = self:GetSpells(player:GetLevel())
    for _, v in ipairs(spells_to_register) do
        -- Some subclasses may be amalgamations of other classes, we don't want to remove an overlapped spell with the actual players mainclass spell
        if v.class ~= player_class then
            player:RemoveSpell(v.spell_id)
        end
    end

    local proficiencies = self:GetProficiencies(player:GetLevel())
    for _, v in ipairs(proficiencies) do
        v:Deregister(player)
    end
end

function SubClass:GetSpells(max_level)
    local spells = {}
    for _, v in ipairs(self.spell_level_ranges) do
        if v.level <= max_level then
            spells = append(spells, v.spells)
        end
    end
    return spells
end

function SubClass:GetProficiencies(max_level)
    local proficiencies = {}
    for _, v in ipairs(self.spell_level_ranges) do
        if v.level <= max_level then
            proficiencies = append(proficiencies, v.proficiencies)
        end
    end
    return proficiencies
end

SUBCLASS_MAGE = SubClass:new(CLASS_MAGE, {
    SubClassLevelRange:new(1, {
        fireball_r1,
        arcane_missiles_r1,
        polymorph_r1
    }, {})
})

SUBCLASS_TEST = SubClass:new("Test", {
    SubClassLevelRange:new(1, {
        sinister_strike_r1,
        shadowbolt_r1,
        heroic_strike_r1,
    }, {}),
    SubClassLevelRange:new(2, {
        fireball_r1,
    }, {
        leather_proficiency,
        two_handed_sword_proficiency
    })
})

SUBCLASSES = {
    [CLASS_MAGE] = SUBCLASS_MAGE,
    ["Test"] = SUBCLASS_TEST
}
