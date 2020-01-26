local _, core = ...



-- INTERFACE OPTIONS PANEL
function core:CreateOptionsMenu()
  local optionsPanel = CreateFrame("Frame", "RestockerOptions", UIParent)
  optionsPanel.name = "Restocker"


  local text = optionsPanel:CreateFontString(nil, "OVERLAY")
  text:SetFontObject("GameFontNormalLarge")
  text:SetText("Restocker Options")
  text:SetPoint("TOPLEFT", optionsPanel, "TOPLEFT", 20, -30)



  local autoOpenAtMerchant = CreateFrame("CheckButton", nil, optionsPanel, "UICheckButtonTemplate")
  autoOpenAtMerchant:SetSize(25,25)
  autoOpenAtMerchant:SetPoint("TOPLEFT", text, "BOTTOMLEFT", 10, -25)
  autoOpenAtMerchant:SetScript("OnClick", function(self, button)
    Restocker.autoOpenAtMerchant = self:GetChecked()
  end)
  autoOpenAtMerchant:SetChecked(Restocker.autoOpenAtMerchant)
  optionsPanel.autoOpenAtMerchant = autoOpenAtMerchant

  local autoOpenAtMerchantText = autoOpenAtMerchant:CreateFontString(nil, "OVERLAY")
  autoOpenAtMerchantText:SetFontObject("GameFontNormal")
  autoOpenAtMerchantText:SetPoint("LEFT", autoOpenAtMerchant, "RIGHT", 3, 0)
  autoOpenAtMerchantText:SetText("Open window at vendor")
  optionsPanel.autoOpenAtMerchantText = autoOpenAtMerchantText



  local autoOpenAtBank = CreateFrame("CheckButton", nil, optionsPanel, "UICheckButtonTemplate")
  autoOpenAtBank:SetSize(25,25)
  autoOpenAtBank:SetPoint("TOPLEFT", autoOpenAtMerchant, "BOTTOMLEFT", 0, 0)
  autoOpenAtBank:SetScript("OnClick", function(self, button)
    Restocker.autoOpenAtBank = self:GetChecked()
  end)
  autoOpenAtBank:SetChecked(Restocker.autoOpenAtBank)
  optionsPanel.autoOpenAtBank = autoOpenAtBank

  local autoOpenAtBankText = autoOpenAtBank:CreateFontString(nil, "OVERLAY")
  autoOpenAtBankText:SetFontObject("GameFontNormal")
  autoOpenAtBankText:SetPoint("LEFT", autoOpenAtBank, "RIGHT", 3, 0)
  autoOpenAtBankText:SetText("Open window at bank")
  optionsPanel.autoOpenAtBankText = autoOpenAtBankText



  -- Profiles
  local profilesHeader = optionsPanel:CreateFontString(nil, "OVERLAY")
  profilesHeader:SetPoint("TOPLEFT", autoOpenAtBank, "BOTTOMLEFT", -10, -20)
  profilesHeader:SetFontObject("GameFontNormalLarge")
  profilesHeader:SetText("Profiles")

  local addProfileEditBox = CreateFrame("EditBox", nil, optionsPanel, "InputBoxTemplate")
  addProfileEditBox:SetSize(124, 20)
  addProfileEditBox:SetPoint("TOPLEFT", profilesHeader, "BOTTOMLEFT", 15, -10)
  addProfileEditBox:SetAutoFocus(false)
  optionsPanel.addProfileEditBox = addProfileEditBox

  local addProfileButton = CreateFrame("Button", nil, optionsPanel, "GameMenuButtonTemplate")
  addProfileButton:SetPoint("LEFT", addProfileEditBox, "RIGHT")
  addProfileButton:SetSize(95, 28);
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



  local deleteProfileButton = CreateFrame("Button", nil, optionsPanel, "GameMenuButtonTemplate")
  deleteProfileButton:SetPoint("LEFT", deleteProfileMenu, "RIGHT", 108, 3)
  deleteProfileButton:SetSize(95, 28);
  deleteProfileButton:SetText("Delete profile");
  deleteProfileButton:SetNormalFontObject("GameFontNormal");
  deleteProfileButton:SetHighlightFontObject("GameFontHighlight");
  deleteProfileButton:SetScript("OnClick", function(self, button, down)
    core:DeleteProfile(Restocker.profileSelectedForDeletion)
  end);
  optionsPanel.deleteProfileButton = deleteProfileButton



  core.optionsPanel = optionsPanel
  InterfaceOptions_AddCategory(optionsPanel)
end


function core.selectProfileForDeletion(self, arg1, arg2, checked)
  Restocker.profileSelectedForDeletion = arg1
  UIDropDownMenu_SetText(core.optionsPanel.deleteProfileMenu, Restocker.profileSelectedForDeletion)
end