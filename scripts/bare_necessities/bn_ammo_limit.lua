-- Bare Necessities: limit arrow carrying capacity

local MAX_ARROWS = 200
local ARROW_CLASS = 6
local ARROW_SUBCLASS = 2

local SPELL_ATTR0_USES_RANGED_SLOT = 0x00000002 -- SharedDefines.h:395
local SPELL_ATTR0_IS_TRADESKILL   = 0x00000020 -- SharedDefines.h:399

local CURRENT_GENERIC_SPELL = 1
local CURRENT_AUTOREPEAT_SPELL = 3

local ROOT_CONTAINER = 255
local ROOT_SLOT_RANGES = {
  { start_slot = 0, end_slot = 18 },   -- equipped gear + ammo slot
  { start_slot = 23, end_slot = 38 },  -- backpack inventory
}

local EQUIPPED_BAG_SLOTS = { 19, 20, 21, 22 }

local ARROW_EXEMPT_SPELLS = {
    [818] = true, -- Basic Campfire
}

local function scan_root_slot(player, slot)
  return player:GetItemByPos(ROOT_CONTAINER, slot)
end

local function scan_bag_slot(player, bag_slot, slot)
  return player:GetItemByPos(bag_slot, slot)
end

local function sync_ammo_pointer(player, stacks)
    local first = stacks[1]
    if first then
        player:SetAmmo(first.entry)
    else
        player:RemoveAmmo()
    end
end

local function isArrow(item)
    if not item or item:GetCount() == 0 then
        return false
    end

    local class = item:GetClass()
    local subclass = item:GetSubClass()

    return class == ARROW_CLASS and subclass == ARROW_SUBCLASS
end

local function collectArrowStacks(player)
    local stacks = {}
    local total = 0

    for _, range in ipairs(ROOT_SLOT_RANGES) do
        for slot = range.start_slot, range.end_slot do
            local item = scan_root_slot(player, slot)
            if isArrow(item) then
                local count = item:GetCount()
                table.insert(stacks, { entry = item:GetEntry(), count = count })
                total = total + count
            end
        end
    end

    for _, bagSlot in ipairs(EQUIPPED_BAG_SLOTS) do
        local bag = player:GetInventoryItem(bagSlot)
        if bag then
            local bagSize = bag:GetBagSize() or 0
            for slot = 0, bagSize - 1 do
                local item = scan_bag_slot(player, bagSlot, slot)
                if isArrow(item) then
                    local count = item:GetCount()
                    table.insert(stacks, { entry = item:GetEntry(), count = count })
                    total = total + count
                end
            end
        end
    end

    return stacks, total
end

local function clampArrows(player)
    local stacks, total = collectArrowStacks(player)
    if total <= MAX_ARROWS then
        sync_ammo_pointer(player, stacks)
        return
    end

    local excess = total - MAX_ARROWS
    for _, stack in ipairs(stacks) do
        if excess <= 0 then
            break
        end

        local removeCount = math.min(excess, stack.count)
        player:RemoveItem(stack.entry, removeCount)
        excess = excess - removeCount
    end

    local refreshed_stacks, refreshed_total = collectArrowStacks(player)
    sync_ammo_pointer(player, refreshed_stacks)
    player:SendBroadcastMessage(string.format("Arrow capacity limited to %d. Excess ammo removed.", MAX_ARROWS))
end

local function OnLogin(event, player)
    clampArrows(player)
end

local function OnStoreNewItem(event, player, item, count, itemEntry)
    clampArrows(player)
end

local function OnLootItem(event, player, item, count)
    clampArrows(player)
end

local function consumeArrow(player)
    local stacks, total = collectArrowStacks(player)
    if total <= 0 then
        player:RemoveAmmo()
        return false
    end

    for _, stack in ipairs(stacks) do
        if stack.count > 0 then
            player:RemoveItem(stack.entry, 1)
            local refreshed_stacks, refreshed_total = collectArrowStacks(player)
            if refreshed_total <= 0 then
                player:RemoveAmmo()
            else
                sync_ammo_pointer(player, refreshed_stacks)
            end
            return true
        end
    end

    player:RemoveAmmo()
    return false
end

local function get_casted_spell(player, spell)
    if spell then
        return spell
    end

    if player and player.GetCurrentSpell then
        local current = player:GetCurrentSpell(CURRENT_AUTOREPEAT_SPELL)
        if current then
            return current
        end

        current = player:GetCurrentSpell(CURRENT_GENERIC_SPELL)
        if current then
            return current
        end
    end

    return nil
end

local function should_consume_arrows(player, spell)
    if not player or not spell then
        return false
    end

    if spell.GetSpellInfo then
        local info = spell:GetSpellInfo()
        if info then
            if info.HasAttribute and info:HasAttribute(0, SPELL_ATTR0_IS_TRADESKILL) then
                return false
            end

            if info.HasAttribute and info:HasAttribute(0, SPELL_ATTR0_USES_RANGED_SLOT) then
                return true
            end
        end
    end

    if spell.GetCastTime then
        local cast_time = spell:GetCastTime()
        if cast_time and cast_time > 0 then
            return true
        end
    end

    return false
end

local function OnSpellCast(event, player, spell, skipCheck)
    local active_spell = get_casted_spell(player, spell)

    if not active_spell then
        return
    end

    local spellId = active_spell and active_spell:GetEntry()
    if spellId and ARROW_EXEMPT_SPELLS[spellId] then
        return
    end

    if spellId == 6477 then
        return
    end

    if not should_consume_arrows(player, active_spell) then
        return
    end

    if consumeArrow(player) then
        return
    end

    if active_spell then
        local name
        if active_spell.GetSpellInfo then
            local info = active_spell:GetSpellInfo()
            if info and info.GetName then
                name = info:GetName()
            end
        end
        active_spell:Cancel()
    end
    player:InterruptSpell(3, false)
    player:SendBroadcastMessage("You need arrows to cast!")
end

RegisterPlayerEvent(3, OnLogin)
RegisterPlayerEvent(53, OnStoreNewItem)
RegisterPlayerEvent(32, OnLootItem)
RegisterPlayerEvent(5, OnSpellCast)
