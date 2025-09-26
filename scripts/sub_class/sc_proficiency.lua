Proficiency = {}
Proficiency.__index = Proficiency

function Proficiency:new(skill, spells, ignore_classes)
    local instance = {}
    setmetatable(instance, Proficiency)
    instance.skill = skill
    instance.spells = spells
    instance.ignore_classes = ignore_classes
    return instance
end

function Proficiency:Register(player)
    if item_exists(self.ignore_classes, player:GetClassAsString()) then
        return
    end

    player:SetSkill(self.skill, 0, 1, 1)
    player:LearnSpell(spell.spell_id)
end

function Proficiency:Register(player)
    if item_exists(self.ignore_classes, player:GetClassAsString()) then
        return
    end

    -- Weapon skills must be relearned
    if self.skill ~= nil then
        player:SetSkill(self.skill, 0, 1, 1)
    end
    player:LearnSpell(self.spell.spell_id)
end

function Proficiency:Deregister(player)
    if item_exists(self.ignore_classes, player:GetClassAsString()) then
        return
    end
    player:RemoveSpell(self.spell.spell_id)
end

-- leather
leather_proficiency = Proficiency:new(414, leather, {
    CLASS_WARRIOR,
    CLASS_ROGUE,
    CLASS_DRUID,
    CLASS_HUNTER,
    CLASS_PALADIN,
    CLASS_SHAMAN
})
-- mail: ToDo: for now you'll have to lose mail as shaman and hunter when you change subclass between those 2
mail_proficiency = Proficiency:new(413, mail, {
    CLASS_WARRIOR,
    CLASS_PALADIN,
})
-- plate
plate_proficiency = Proficiency:new(293, plate, {
    CLASS_WARRIOR,
    CLASS_PALADIN,
})

--shield ToDo: does not support block atm, as we need custom rules around this
shield_proficiency = Proficiency:new(433, shield, {
    CLASS_SHAMAN,
    CLASS_WARRIOR,
    CLASS_PALADIN
})
block_proficiency = Proficiency:new(433, block, {
    CLASS_SHAMAN,
    CLASS_WARRIOR,
    CLASS_PALADIN
})

fist_proficiency = Proficiency:new(473, fist_weapons, {
    CLASS_ROGUE,
    CLASS_SHAMAN,
    CLASS_WARRIOR,
    CLASS_DRUID
})

dagger_proficiency = Proficiency:new(173, daggers, {
    CLASS_ROGUE,
    CLASS_MAGE,
    CLASS_PRIEST,
    CLASS_WARLOCK,
    CLASS_SHAMAN,
    CLASS_WARRIOR,
    CLASS_DRUID
})

one_hand_sword_proficiency = Proficiency:new(43, one_handed_swords, {
    CLASS_ROGUE,
    CLASS_MAGE,
    CLASS_PRIEST,
    CLASS_WARLOCK,
    CLASS_PALADIN,
    CLASS_WARRIOR,
    CLASS_HUNTER
})

two_handed_sword_proficiency = Proficiency:new(55, two_handed_swords, {
    CLASS_WARRIOR,
    CLASS_PALADIN,
    CLASS_HUNTER
})

one_handed_axe_proficiency = Proficiency:new(44, one_handed_axes, {
    CLASS_ROGUE,
    CLASS_SHAMAN,
    CLASS_WARRIOR,
    CLASS_HUNTER
})

two_hand_axe_proficiency = Proficiency:new(172, two_handed_axes, {
    CLASS_WARRIOR,
    CLASS_SHAMAN
})

one_hand_mace_proficiency = Proficiency:new(54, one_handed_maces, {
    CLASS_ROGUE,
    CLASS_PRIEST,
    CLASS_PALADIN,
    CLASS_SHAMAN,
    CLASS_WARRIOR,
    CLASS_DRUID
})

two_handed_mace_proficiency = Proficiency:new(160, two_handed_maces, {
    CLASS_PALADIN,
    CLASS_SHAMAN,
    CLASS_WARRIOR,
    CLASS_DRUID,
    CLASS_DEATHKNIGHT
})

polearm_proficiency = Proficiency:new(229, polearms, {
    CLASS_PALADIN,
    CLASS_WARRIOR,
    CLASS_HUNTER,
    CLASS_DRUID
})

staff_proficiency = Proficiency:new(136, staves, {
    CLASS_MAGE,
    CLASS_PRIEST,
    CLASS_WARLOCK,
    CLASS_SHAMAN,
    CLASS_WARRIOR,
    CLASS_DRUID,
    CLASS_HUNTER
})

bow_proficiency = Proficiency:new(45, bows, {
    CLASS_WARRIOR,
    CLASS_HUNTER,
    CLASS_ROGUE
})

crossbow_proficiency = Proficiency:new(226, crossbows, {
    CLASS_WARRIOR,
    CLASS_HUNTER,
    CLASS_ROGUE
})

gun_proficiency = Proficiency:new(46, guns, {
    CLASS_WARRIOR,
    CLASS_HUNTER,
    CLASS_ROGUE
})

thrown_proficiency = Proficiency:new(176, thrown, {
    CLASS_ROGUE,
    CLASS_WARRIOR
})

wand_proficiency = Proficiency:new(228, wands, {
    CLASS_MAGE,
    CLASS_PRIEST,
    CLASS_WARLOCK
})
