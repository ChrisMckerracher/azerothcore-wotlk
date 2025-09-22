Spell = {}
Spell.__index = Spell

function Spell:new(name, class, spell_id)
    local instance = {}
    setmetatable(instance, Spell)
    instance.name = name
    instance.class = class
    instance.spell_id = spell_id
    return instance
end

-- Mage

fireball_r1 = Spell:new("Fireball, Rank 1", CLASS_MAGE, 133)
arcane_missiles_r1 = Spell:new("Arcane Missiles, Rank 1", CLASS_MAGE, 5143)
polymorph_r1 = Spell:new("Polymorph, Rank 1", CLASS_MAGE, 118)

-- Warlock
shadowbolt_r1 = Spell:new("Shadowbolt, Rank 1", CLASS_WARLOCK, 686)

-- Priest
lesser_heal_r1 = Spell:new("Lesser Heal, Rank 1", CLASS_PRIEST, 2050)
