-- Bare Necessities: inventory cleanup rules

local BAG_FAMILY_AMMO = 0x3 -- arrows (0x1) | bullets (0x2)
local ITEM_CLASS_CONTAINER = 1
local ITEM_SUBCLASS_QUIVER = 2
local ITEM_SUBCLASS_AMMO_POUCH = 3

local function has_ammo_family(family)
    if not family then
        return false
    end

    if bit and bit.band then
        return bit.band(family, BAG_FAMILY_AMMO) ~= 0
    end

    if family % 2 == 1 then
        return true
    end

    if math.floor(family / 2) % 2 == 1 then
        return true
    end

    return false
end

local INVTYPE_BAG_START = 19
local INVTYPE_BAG_END = 22

local function is_bag_slot(slot)
    return slot >= INVTYPE_BAG_START and slot <= INVTYPE_BAG_END
end

local function get_item_template(item)
    if not item then
        return nil
    end

    local entry = item:GetEntry()
    if not entry then
        return nil
    end

    return GetItemTemplate(entry)
end

local function template_value(template, method_name, field_name)
    if not template then
        return nil
    end

    local method = template[method_name]
    if type(method) == "function" then
        return method(template)
    end

    return template[field_name]
end

local function getBagFamily(item)
    local template = get_item_template(item)
    if not template then
        return 0
    end

    local bagFamily = template_value(template, "GetBagFamily", "BagFamily")
    return bagFamily or 0
end

local function isProtectedBag(item)
    if not item then
        return false
    end

    local name = item:GetName()
    if type(name) == "string" then
        local lower_name = string.lower(name)
        if string.find(lower_name, "quiver", 1, true) or string.find(lower_name, "ammo pouch", 1, true) then
            return true
        end
    end

    local family = getBagFamily(item)
    local family_has_ammo = has_ammo_family(family)
    if family_has_ammo then
        return true
    end

    local item_class = item:GetClass()
    local item_subclass = item:GetSubClass()
    local is_quiver_type = item_class == ITEM_CLASS_CONTAINER and (
        item_subclass == ITEM_SUBCLASS_QUIVER or
        item_subclass == ITEM_SUBCLASS_AMMO_POUCH
    )

    return is_quiver_type
end

local function returnBag(player, item)
    if not item then
        return
    end

    local item_entry = item:GetEntry()
    local item_name = item:GetName() or "bag"

    player:RemoveItem(item, 1)

    local restored = false
    if item_entry then
        local stored_item = player:AddItem(item_entry, 1)
        if stored_item then
            restored = true
        end
    end

    if restored then
        player:SendBroadcastMessage(string.format("Returned %s to your inventory.", item_name))
    else
        player:SendBroadcastMessage(string.format("No space for %s. It has been removed.", item_name))
    end
end

local function enforceBags(player)
    for slot = INVTYPE_BAG_START, INVTYPE_BAG_END do
        local item = player:GetInventoryItem(slot)
        if item and not isProtectedBag(item) then
            returnBag(player, item)
        end
    end
end

local function OnBagEquip(event, player, item, bag, slot, spellCast)
    if not is_bag_slot(slot) then
        return
    end

    if isProtectedBag(item) then
        return
    end

    returnBag(player, item)
end

local function OnLogin(event, player)
    enforceBags(player)
end

RegisterPlayerEvent(3, OnLogin)
RegisterPlayerEvent(29, OnBagEquip)
