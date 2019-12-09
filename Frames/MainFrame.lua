local _, core = ...;


core.hiddenFrame = CreateFrame("Frame", nil, UIParent)
core.hiddenFrame:Hide()

function core:CreateMenu()
  -- Frame
  local addon = CreateFrame("Frame", "RestockerMainFrame", UIParent, "BasicFrameTemplate");
  addon.width = 250
  addon.height = 350
  addon:SetSize(addon.width, addon.height);
  addon:SetPoint("RIGHT", UIParent, "RIGHT", -5, 0);
  addon:SetFrameStrata("HIGH");
  addon:SetMovable(true)
  addon:EnableMouse(true)
  addon:RegisterForDrag("LeftButton")
  addon:SetScript("OnDragStart", addon.StartMoving)
  addon:SetScript("OnDragStop", addon.StopMovingOrSizing)

  local listInset = CreateFrame("Frame", nil, addon, "InsetFrameTemplate3");
  listInset.width = addon.width - 6
  listInset.height = addon.height - 56
  listInset:SetSize(listInset.width, listInset.height);
  listInset:SetPoint("TOPLEFT", addon, "TOPLEFT", 2, -22);
  addon.listInset = listInset


  local scrollFrame = CreateFrame("ScrollFrame", nil, addon, "UIPanelScrollFrameTemplate")
  scrollFrame.width = addon.listInset.width - 4
  scrollFrame.height = addon.listInset.height - 32
  scrollFrame:SetSize(scrollFrame.width-30, scrollFrame.height);
  scrollFrame:SetPoint("TOPLEFT", listInset, "TOPLEFT", 8, -6);
  addon.scrollFrame = scrollFrame

  local scrollChild = CreateFrame("Frame",nil,ScrollFrame)
  scrollChild.width = scrollFrame:GetWidth()
  scrollChild.height = scrollFrame:GetHeight()
  scrollChild:SetWidth(scrollChild.width)
  scrollChild:SetHeight(scrollChild.height-10)
  addon.scrollChild = scrollChild

  scrollFrame:SetScrollChild(scrollChild)






  -- Title
  local title = addon:CreateFontString(nil, "OVERLAY");
  title:SetFontObject("GameFontHighlightLarge");
  title:SetPoint("CENTER", addon.TitleBg, "CENTER", 0, 0);
  title:SetText("Restocker");
  addon.title = title


  -- Text field and button group
  local addGrp = CreateFrame("Frame", nil, addon);
  addGrp:SetPoint("BOTTOM", addon.listInset, "BOTTOM", 0, 2);
  addGrp:SetSize(listInset.width-5, 25);
  addon.addGrp = addGrp




    -- Add button
    local addBtn = CreateFrame("Button", nil, addon.addGrp, "GameMenuButtonTemplate");
    addBtn:SetPoint("BOTTOMRIGHT", addon.addGrp, "BOTTOMRIGHT");
    addBtn:SetSize(60, 25);
    addBtn:SetText("Add");
    addBtn:SetNormalFontObject("GameFontNormal");
    addBtn:SetHighlightFontObject("GameFontHighlight");
    addBtn:SetScript("OnClick", function(self, button, down)
      local editBox = self:GetParent():GetParent().editBox
      local text = editBox:GetText()

      core:addItem(text);

      editBox:SetText("")
      editBox:ClearFocus()
    end);


    -- Text field
    local editBox = CreateFrame("EditBox", nil, addon.addGrp, "InputBoxTemplate");
    editBox:SetPoint("RIGHT", addBtn, "LEFT", 3);
    editBox:SetAutoFocus(false);
    editBox:SetSize(addon.addGrp:GetWidth()-addBtn:GetWidth()-5, 25);
    editBox:SetScript("OnEnterPressed", function(self)
      local text = self:GetText()

      core:addItem(text);

      self:SetText("")
      self:ClearFocus()

    end);

    addon.editBox = editBox
    addon.addBtn = addBtn

  -- END OF GROUP

  -- AUTOBUY
  -- Checkbox for autobuy
    local checkbox = CreateFrame("CheckButton", nil, addon, "UICheckButtonTemplate");
    checkbox:SetPoint("BOTTOMLEFT", addon, "BOTTOMLEFT", 5, 5)
    checkbox:SetSize(25, 25)
    checkbox:SetChecked(Restocker["AutoBuy"]);
    checkbox:SetScript("OnClick", function(self, button, down)
      Restocker["AutoBuy"] = checkbox:GetChecked()
    end);
    addon.checkbox = checkbox

    -- Auto buy text
    local checkboxText = addon:CreateFontString(nil, "OVERLAY");
    checkboxText:SetFontObject("GameFontHighlight");
    checkboxText:SetPoint("LEFT", checkbox, "RIGHT", 1, 1);
    checkboxText:SetText("Auto buy items");
    addon.checkbox = checkboxText
  -- // AUTOBUY


  tinsert(UISpecialFrames, "RestockerMainFrame")
  addon:Hide()

  core.addon = addon
  return core.addon
end




function core:addItem(text)
  local currentProfile = Restocker.profiles[Restocker.currentProfile]
  
  local itemName, itemLink = GetItemInfo(text)
  local itemID
  if itemLink == nil then
    core.itemWaitTable[text] = true
    return
  elseif itemLink ~= nil then
    itemID = string.match(itemLink, "item:(%d+)")
    for _, item in ipairs(currentProfile) do
      if item.itemName:lower() == itemName:lower() then return end
    end
  end

  local T = {}

  T.itemName = itemName
  T.itemLink = itemLink
  T.itemID = itemID
  T.amount = 1
  tinsert(Restocker.profiles[Restocker.currentProfile], T)

  core:Update()
end
