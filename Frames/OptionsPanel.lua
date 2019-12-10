local _, core = ...



-- INTERFACE OPTIONS PANEL
function core:CreateOptionsMenu()
  local optionsPanel = CreateFrame("Frame", "RestockerOptions", UIParent)
  optionsPanel.name = "Restocker"


  local text = optionsPanel:CreateFontString(nil, "OVERLAY")
  text:SetFontObject("GameFontNormalLarge")
  text:SetText("Restocker Options")
  text:SetPoint("TOPLEFT", optionsPanel, "TOPLEFT", 20, -30)



  local vendorAutoOpen = CreateFrame("CheckButton", nil, optionsPanel, "UICheckButtonTemplate")
  vendorAutoOpen:SetSize(25,25)
  vendorAutoOpen:SetPoint("TOPLEFT", text, "BOTTOMLEFT", 10, -25)
  vendorAutoOpen:SetScript("OnClick", function(self, button)
    Restocker.vendorAutoOpen = self:GetChecked()
  end)
  vendorAutoOpen:SetChecked(Restocker.vendorAutoOpen)
  optionsPanel.vendorAutoOpen = vendorAutoOpen

  local vendorAutoOpenText = vendorAutoOpen:CreateFontString(nil, "OVERLAY")
  vendorAutoOpenText:SetFontObject("GameFontNormal")
  vendorAutoOpenText:SetPoint("LEFT", vendorAutoOpen, "RIGHT", 3, 0)
  vendorAutoOpenText:SetText("Open Restocker when visiting a vendor")
  optionsPanel.vendorAutoOpenText = vendorAutoOpenText



  local bankAutoOpen = CreateFrame("CheckButton", nil, optionsPanel, "UICheckButtonTemplate")
  bankAutoOpen:SetSize(25,25)
  bankAutoOpen:SetPoint("TOPLEFT", vendorAutoOpen, "BOTTOMLEFT", 0, 0)
  bankAutoOpen:SetScript("OnClick", function(self, button)
    Restocker.bankAutoOpen = self:GetChecked()
  end)
  bankAutoOpen:SetChecked(Restocker.bankAutoOpen)
  optionsPanel.bankAutoOpen = bankAutoOpen

  local bankAutoOpenText = bankAutoOpen:CreateFontString(nil, "OVERLAY")
  bankAutoOpenText:SetFontObject("GameFontNormal")
  bankAutoOpenText:SetPoint("LEFT", bankAutoOpen, "RIGHT", 3, 0)
  bankAutoOpenText:SetText("Open Restocker when visiting the bank")
  optionsPanel.bankAutoOpenText = bankAutoOpenText


  local profilesHeader = optionsPanel:CreateFontString(nil, "OVERLAY")
  profilesHeader:SetPoint("TOPLEFT", bankAutoOpen, "BOTTOMLEFT", -10, -20)
  profilesHeader:SetFontObject("GameFontNormalLarge")
  profilesHeader:SetText("Profiles")

  local addProfileEditBox = CreateFrame("EditBox", nil, optionsPanel, "InputBoxTemplate")
  addProfileEditBox:SetSize(123, 20)
  addProfileEditBox:SetPoint("TOPLEFT", profilesHeader, "BOTTOMLEFT", 5, -10)
  addProfileEditBox:SetAutoFocus(false)
  optionsPanel.addProfileEditBox = addProfileEditBox

  local addProfileButton = CreateFrame("Button", nil, optionsPanel, "GameMenuButtonTemplate")
  addProfileButton:SetPoint("LEFT", addProfileEditBox, "RIGHT")
  addProfileButton:SetSize(75, 25);
  addProfileButton:SetText("Add profile");
  addProfileButton:SetNormalFontObject("GameFontNormal");
  addProfileButton:SetHighlightFontObject("GameFontHighlight");
  addProfileButton:SetScript("OnClick", function(self, button, down)
    local editBox = self:GetParent().addProfileEditBox
    local text = editBox:GetText()

    core:AddProfile(text);

    editBox:SetText("")
    editBox:ClearFocus()
  end);
  optionsPanel.addProfileButton = addProfileButton






  local deleteProfileMenu = CreateFrame("Frame", "RestockerDeleteProfileMenu", optionsPanel, "UIDropDownMenuTemplate")
  deleteProfileMenu:SetPoint("TOPLEFT", addProfileEditBox, "BOTTOMLEFT", -24, -5)
  deleteProfileMenu.displayMode = "MENU"
  deleteProfileMenu.info = {}
  deleteProfileMenu.initialize = function(self, level)
    if not level then return end

    for profileName, _ in pairs(Restocker.profiles) do
      local info = UIDropDownMenu_CreateInfo()

      info.text = profileName
      info.arg1 = profileName
      info.func = core.selectProfileForDeletion
      info.checked = false

      UIDropDownMenu_AddButton(info, 1)
    end
  end

  optionsPanel.deleteProfileMenu = deleteProfileMenu

  core.optionsPanel = optionsPanel
  InterfaceOptions_AddCategory(optionsPanel)
end


function core.selectProfileForDeletion(self, arg1, arg2, checked)
  Restocker.profileSelectedForDeletion = arg1
  UIDropDownMenu_SetText(core.optionsPanel.deleteProfileMenu, Restocker.profileSelectedForDeletion)
end