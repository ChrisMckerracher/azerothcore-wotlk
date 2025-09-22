SubClassLevelRange = {}
SubClassLevelRange.__index = SubClassLevelRange
function SubClassLevelRange:new(level, spells)
    local instance = {}
    setmetatable(instance, SubClassLevelRange)
    instance.name = level
    instance.spells = spells
    return instance
end

SubClass = {}
SubClass.__index = SubClass

function SubClass:new(name, spell_level_ranges, mandatory_items)
    local instance = {}
    setmetatable(instance, SubClass)
    instance.name = name
    instance.class = spell_level_ranges
    instance.spell_id = mandatory_items
    return instance
end

-- Because Player is a builtin concept in Eluna, I'm not sure I can extend it. Instead Subclass Registers the Player. Like a shitty listener pattern
function SubClass:Register(player)
    if player:GetClassAsString() ~= self.name then
        spells_to_register = self:GetSpells(player:GetLevel())
        for _, v in ipairs(spells_to_register) do
            player:LearnSpell(v.spell_id)
        end
    end
end

-- Because Player is a builtin concept in Eluna, instead Subclass Deregisters the Player. Like a shitty listener pattern
function SubClass:Deregister(player)
    local player_class = player:Get()
    spells_to_register = self:GetSpells(player:GetLevel())
    for _, v in ipairs(spells_to_register) do
        -- Some subclasses may be amalgamations of other classes, we don't want to remove an overlapped spell with the actual players mainclass spell
        if v.class ~= player_class then
            player:RemoveSpell(v.spell_id)
        end
    end
end

function SubClass:GetSpells(max_level)
    spells = {}
    for k, v in ipairs(self.spell_level_ranges) do
        if k <= max_level then
            spells = append(spells, v)
        end
    end
end

SUBCLASS_MAGE = SubClass:new(CLASS_MAGE, {
    [1] = SubClassLevelRange:new(1, {
        fireball_r1,
        arcane_missiles_r1,
        polymorph_r1
    })
})
