local _, core = ...;

function core:addListFrame()

  local frame = CreateFrame("Frame", nil, core.hiddenFrame)
  frame:SetSize(core.addon.scrollChild:GetWidth(), 20);
  if #core.framepool == 0 then
    frame:SetPoint("TOP", core.addon.scrollChild, "TOP")
  else
    frame:SetPoint("TOP", core.framepool[#core.framepool], "BOTTOM")
  end
  core.addon.scrollChild:SetHeight(#core.framepool*20)

  -- ITEM TEXT
  local text = frame:CreateFontString(nil, "OVERLAY");
  text:SetFontObject("GameFontHighlight");
  text:SetPoint("LEFT", frame, "LEFT");
  frame.text = text

  -- BUTTON
  local delBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton");
  delBtn:SetPoint("RIGHT", frame, "RIGHT", 8, 0);
  delBtn:SetSize(30, 30);
  delBtn:SetScript("OnClick", function(self)
    local parent = self:GetParent();
    local text = parent.text:GetText();

    for i, item in ipairs(Restocker.Items) do
      if item.itemName == text then
        Restocker.Items[i] = nil
      end
    end
    core:Update();
  end);

  -- EDITBOX
  local editBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate");
  editBox:SetSize(40,20)
  editBox:SetPoint("RIGHT", delBtn, "LEFT", 3, 0);
  editBox:SetAutoFocus(false);
  editBox:SetScript("OnEnterPressed", function(self)
    local amount = tonumber(self:GetText())
    local parent = self:GetParent();
    local text = parent.text:GetText();

    for _, item in ipairs(Restocker.Items) do
      if item.itemName == text then
        item.amount = tonumber(amount)
      end
    end
    editBox:ClearFocus()

  end);
  editBox:SetScript("OnKeyUp", function(self)
    local amount = self:GetText();
    local parent = self:GetParent();
    local item = parent.text:GetText();

    if amount == "" then
      amount = 0;
    end

    self:SetText(amount);

    for _, item in ipairs(Restocker.Items) do
      if item.itemName == text then
        item.amount = tonumber(amount)
      end
    end
  end)
  frame.editBox = editBox
  frame.isInUse = true
  frame:Show()

  tinsert(core.framepool, frame)
  return frame
end


function core:addListFrames()
  for _, item in ipairs(Restocker.Items) do
    local frame = core:addListFrame()
    frame.text:SetText(item.itemName)
    frame.editBox:SetText(item.amount)
  end
end
