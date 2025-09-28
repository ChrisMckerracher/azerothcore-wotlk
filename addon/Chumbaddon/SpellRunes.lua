SpellRunes = {}
SpellRunes.__index = SpellRunes

function SpellRunes:new()
  local o = setmetatable({}, self)
  o.active = true
  o.spell_rune_name = "Spell Rune"
  o.spell_bag_name = "Spell Rune Bag"
  o.spell_rune_icon = "Interface\\Icons\\INV_Misc_Rune_11"
  o.spell_bag_icon = "Interface\\Icons\\INV_Enchant_EssenceArcaneLarge"
  o.keywords = {
    rune_item = { ids = { 2512 }, icon = o.spell_rune_icon, name = o.spell_rune_name },
    quiver = { keyword = "uiver", icon = o.spell_bag_icon, name = o.spell_bag_name },
  }
  o.equipment_slots = {
    "AmmoSlot",
    "HeadSlot",
    "NeckSlot",
    "ShoulderSlot",
    "BackSlot",
    "ChestSlot",
    "ShirtSlot",
    "TabardSlot",
    "WristSlot",
    "HandsSlot",
    "WaistSlot",
    "LegsSlot",
    "FeetSlot",
    "Finger0Slot",
    "Finger1Slot",
    "Trinket0Slot",
    "Trinket1Slot",
    "MainHandSlot",
    "SecondaryHandSlot",
    "RangedSlot",
  }
  return o
end

function SpellRunes:register()
  if self.frame then
    return
  end

  self.frame = CreateFrame("Frame")
  local frame = self.frame
  frame:RegisterEvent("PLAYER_LOGIN")
  frame:RegisterEvent("PLAYER_ENTERING_WORLD")
  frame:RegisterEvent("PLAYER_LEVEL_UP")
  frame:RegisterEvent("BAG_UPDATE")
  frame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
  frame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
  frame:SetScript("OnEvent", function(_, event, ...)
    self:OnEvent(event, ...)
  end)

  if ContainerFrame_Update then
    hooksecurefunc("ContainerFrame_Update", function(container)
      self:ApplyToContainerFrame(container)
    end)
  end

  if BagSlotButton_Update then
    hooksecurefunc("BagSlotButton_Update", function(button)
      self:ApplyToBagButton(button)
    end)
  end

  if PaperDollItemSlotButton_Update then
    hooksecurefunc("PaperDollItemSlotButton_Update", function(button)
      self:ApplyToEquipmentSlot(button)
    end)
  end

  GameTooltip:HookScript("OnTooltipSetItem", function(tooltip)
    self:OnTooltipSetItem(tooltip)
  end)

  ItemRefTooltip:HookScript("OnTooltipSetItem", function(tooltip)
    self:OnTooltipSetItem(tooltip)
  end)

  self:RefreshAllContainers()
  self:RefreshBagBar()
  self:RefreshEquipment()
end

function SpellRunes:OnEvent(event, ...)
  if event == "PLAYER_LOGIN" or event == "PLAYER_ENTERING_WORLD" then
    self:RefreshAllContainers()
    self:RefreshBagBar()
    self:RefreshEquipment()
  elseif event == "PLAYER_LEVEL_UP" then
    self:RefreshAllContainers()
    self:RefreshBagBar()
    self:RefreshEquipment()
  elseif event == "BAG_UPDATE" then
    self:RefreshContainer(...)
  elseif event == "PLAYER_EQUIPMENT_CHANGED" then
    self:RefreshBagBar()
    self:RefreshEquipment()
  elseif event == "GET_ITEM_INFO_RECEIVED" then
    self:RefreshAllContainers()
    self:RefreshBagBar()
    self:RefreshEquipment()
  end
end

function SpellRunes:RefreshContainer(bag_id)
  if bag_id == nil then
    return
  end

  for frame_index = 1, NUM_CONTAINER_FRAMES or 13 do
    local frame = _G["ContainerFrame" .. frame_index]
    if frame and frame:GetID() == bag_id then
      self:ApplyToContainerFrame(frame)
      break
    end
  end
end

function SpellRunes:RefreshAllContainers()
  for frame_index = 1, NUM_CONTAINER_FRAMES or 13 do
    local frame = _G["ContainerFrame" .. frame_index]
    if frame and frame:GetID() ~= nil then
      self:ApplyToContainerFrame(frame)
    end
  end
end

function SpellRunes:ApplyToContainerFrame(frame)
  if not frame.size or frame.size == 0 then
    return
  end

  local bag_id = frame:GetID()

  for button_index = 1, frame.size do
    local button = _G[frame:GetName() .. "Item" .. button_index]
    if button then
      local slot = button:GetID()
      local texture, _, _, _, _, _, item_link = GetContainerItemInfo(bag_id, slot)
      local icon = _G[button:GetName() .. "IconTexture"]
      if item_link and icon then
        local override_name, override_icon = self:GetOverrideData(item_link)
        if override_icon then
          icon:SetTexture(override_icon)
        elseif texture then
          icon:SetTexture(texture)
        end
        button.spellRunesOverrideName = override_name
      else
        if icon and texture then
          icon:SetTexture(texture)
        end
        button.spellRunesOverrideName = nil
      end
    end
  end
end

function SpellRunes:RefreshBagBar()
  for bag = 0, NUM_BAG_SLOTS do
    local button = _G["CharacterBag" .. bag .. "Slot"]
    if button then
      self:ApplyToBagButton(button)
    end
  end
end

function SpellRunes:ApplyToBagButton(button)
  local inventory_slot = button:GetID()
  if not inventory_slot then
    return
  end

  local item_link = GetInventoryItemLink("player", inventory_slot)
  local item_texture = GetInventoryItemTexture("player", inventory_slot)
  local icon = _G[button:GetName() .. "IconTexture"]
  if not icon then
    return
  end

  if item_link then
    local override_name, override_icon = self:GetOverrideData(item_link)
    if override_icon then
      icon:SetTexture(override_icon)
    elseif item_texture then
      icon:SetTexture(item_texture)
    end
    button.spellRunesOverrideName = override_name
  else
    if item_texture then
      icon:SetTexture(item_texture)
    end
    button.spellRunesOverrideName = nil
  end
end

function SpellRunes:ApplyToEquipmentSlot(button, slot_id)
  if not button then
    return
  end

  local slot = slot_id or (button.GetID and button:GetID())
  if not slot then
    return
  end

  local icon = button.icon or _G[button:GetName() .. "IconTexture"]
  if not icon then
    return
  end

  local item_link = GetInventoryItemLink("player", slot)
  local item_texture = GetInventoryItemTexture("player", slot)

  if item_link then
    local override_name, override_icon = self:GetOverrideData(item_link)
    if override_icon then
      icon:SetTexture(override_icon)
    elseif item_texture then
      icon:SetTexture(item_texture)
    end
    button.spellRunesOverrideName = override_name
  else
    if item_texture then
      icon:SetTexture(item_texture)
    end
    button.spellRunesOverrideName = nil
  end
end

function SpellRunes:RefreshEquipment()
  if not self.equipment_slots then
    return
  end

  for _, slot_name in ipairs(self.equipment_slots) do
    local slot_id = GetInventorySlotInfo(slot_name)
    if slot_id then
      local button = _G["Character" .. slot_name]
      if button then
        self:ApplyToEquipmentSlot(button, slot_id)
      end
    end
  end
end

function SpellRunes:GetOverrideData(item_link)
  if not self.active then
    return nil, nil
  end

  local item_id = self:GetItemIdFromLink(item_link)
  if not item_id then
    return nil, nil
  end

  if self:IsRuneItem(item_id) then
    return self.keywords.rune_item.name, self.keywords.rune_item.icon
  end

  local name = GetItemInfo(item_link)
  if name and self:HasQuiverKeyword(name) then
    return self.keywords.quiver.name, self.keywords.quiver.icon
  end

  return nil, nil
end

function SpellRunes:OnTooltipSetItem(tooltip)
  if not self.active then
    return
  end

  local name, item_link = tooltip:GetItem()
  if not item_link then
    return
  end

  local override_name = nil
  local item_id = self:GetItemIdFromLink(item_link)
  if item_id and self:IsRuneItem(item_id) then
    override_name = self.keywords.rune_item.name
  else
    local name = GetItemInfo(item_link)
    if name and self:HasQuiverKeyword(name) then
      override_name = self.keywords.quiver.name
    end
  end

  if not override_name then
    return
  end

  local text = _G[tooltip:GetName() .. "TextLeft1"]
  if text then
    text:SetText(override_name)
    tooltip:Show()
  end
end

function SpellRunes:GetItemIdFromLink(item_link)
  if not item_link then
    return nil
  end
  local item_id = string.match(item_link, "item:(%d+)")
  if item_id then
    return tonumber(item_id)
  end
  return nil
end

function SpellRunes:HasQuiverKeyword(name)
  if not name then
    return false
  end
  return string.find(string.lower(name), "uiver", 1, true) ~= nil
end

function SpellRunes:IsRuneItem(item_id)
  if not item_id then
    return false
  end
  for _, id in ipairs(self.keywords.rune_item.ids) do
    if id == item_id then
      return true
    end
  end
  return false
end
