local _, core = ...



-- INTERFACE OPTIONS PANEL
function core:CreateOptionsMenu()
  local optionsPanel = CreateFrame("Frame", "RestockerOptions", UIParent)
  optionsPanel.name = "Restocker"


  local text = optionsPanel:CreateFontString(nil, "OVERLAY")
  text:SetFontObject("GameFontNormal")
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



  core.optionsPanel = optionsPanel
  InterfaceOptions_AddCategory(optionsPanel)
end
