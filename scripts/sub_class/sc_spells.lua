Spell = {}
Spell.__index = Spell

-- ToDo: Implement a Rage and Energy override cost. Alternatively, spells will cost 100 Energy and 25
function Spell:new(name, class, spell_id, energy_cost, rage_cost)
    local instance = {}
    setmetatable(instance, Spell)
    instance.name = name
    instance.class = class
    instance.spell_id = spell_id
    instance.energy_cost = energy_cost
    instance.rage_cost = rage_cost
    return instance
end

-- Proficiency
leather = Spell:new("Wear Leather", CLASS_MISC, 9077)

-- Mage

fireball_r1 = Spell:new("Fireball, Rank 1", CLASS_MAGE, 133)
arcane_missiles_r1 = Spell:new("Arcane Missiles, Rank 1", CLASS_MAGE, 5143)
polymorph_r1 = Spell:new("Polymorph, Rank 1", CLASS_MAGE, 118)

-- Warlock
shadowbolt_r1 = Spell:new("Shadowbolt, Rank 1", CLASS_WARLOCK, 686)

-- Priest
lesser_heal_r1 = Spell:new("Lesser Heal, Rank 1", CLASS_PRIEST, 2050)

-- Rogue
sinister_strike_r1 = Spell:new("Sinister Strike, Rank 1", CLASS_ROGUE, 1752)

-- Warrior
heroic_strike_r1 = Spell:new("Heroic Strike, Rank 1", CLASS_WARRIOR, 78)
