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
mail = Spell:new("Wear Mail", CLASS_MISC, 8737)
plate = Spell:new("Wear Plate", CLASS_MISC, 750)

shield = Spell:new("Use Shield", CLASS_MISC, 9116)
block = Spell:new("Block", CLASS_MISC, 107) -- ToDo this is wrong, as it belongs to multiple classes

fist_weapons      = Spell:new("Fist Weapons", CLASS_MISC, 15590)
daggers           = Spell:new("Daggers", CLASS_MISC, 1180)
one_handed_swords = Spell:new("One-Handed Swords", CLASS_MISC, 201)
two_handed_swords = Spell:new("Two-Handed Swords", CLASS_MISC, 202)
one_handed_axes   = Spell:new("One-Handed Axes", CLASS_MISC, 196)
two_handed_axes   = Spell:new("Two-Handed Axes", CLASS_MISC, 197)
one_handed_maces  = Spell:new("One-Handed Maces", CLASS_MISC, 198)
two_handed_maces  = Spell:new("Two-Handed Maces", CLASS_MISC, 199)
polearms          = Spell:new("Polearms", CLASS_MISC, 200)
staves            = Spell:new("Staves", CLASS_MISC, 227)
bows              = Spell:new("Bows", CLASS_MISC, 264)
crossbows         = Spell:new("Crossbows", CLASS_MISC, 5011)
guns              = Spell:new("Guns", CLASS_MISC, 266)
thrown            = Spell:new("Thrown", CLASS_MISC, 2567)
wands             = Spell:new("Wands", CLASS_MISC, 5009)

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
