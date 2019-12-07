local _, core = ...;

core.currentlyRestocking = false
core.itemsRestocked = {}
core.restockedItems = false
core.coroutine = nil
core.framepool = {}
core.hiddenFrame = CreateFrame("Frame", nil, UIParent)
core.hiddenFrame:Hide()


function core:Print(...)
  DEFAULT_CHAT_FRAME:AddMessage(tostringall(...))
end

local events = CreateFrame("Frame");
events:RegisterEvent("ADDON_LOADED");
events:RegisterEvent("MERCHANT_SHOW");
events:RegisterEvent("MERCHANT_CLOSED");
events:RegisterEvent("BANKFRAME_OPENED");
events:RegisterEvent("BANKFRAME_CLOSED");
events:RegisterEvent("BAG_UPDATE");
events:SetScript("OnEvent", function(self, event, ...)
  return self[event] and self[event](self, ...)
end)



function events:ADDON_LOADED(name)
  if name ~= "Restocker" then return end

  if RestockerDB == nil then RestockerDB = {} end
  if RestockerDB["AutoBuy"] == nil then RestockerDB["AutoBuy"] = true end
  if RestockerDB["Items"] == nil then RestockerDB["Items"] = {} end
  if RestockerDB["Poisons"] == nil then RestockerDB["Poisons"] = {} end
  if RestockerDB["Poisons"]["minDifference"] == nil then RestockerDB["Poisons"]["minDifference"] = 0 end




  SLASH_FRAMESTK1 = "/fs"
  SlashCmdList.FRAMESTK = function()
    LoadAddOn('Blizzard_DebugTools')
    FrameStackTooltip_Toggle()
  end

  local f=InterfaceOptionsFrame;
  f:SetMovable(true);
  f:EnableMouse(true);
  f:SetUserPlaced(true);
  f:SetScript("OnMouseDown", f.StartMoving);
  f:SetScript("OnMouseUp", f.StopMovingOrSizing);


  SLASH_RESTOCKER1= "/restocker";
  SLASH_RESTOCKER2= "/rs";
  SlashCmdList.RESTOCKER = function(msg)
    core:SlashCommand(msg)
  end
  core:Print("|cffff2200Restocker|r by |cffFFF569Mayushi|r on |cffff0000Gehennas|r. /rs or /restocker to open addon frame.")
end



----------------------------
---- MERCHANT SHOWN
----------------------------

function events:MERCHANT_SHOW(event, ...)
  local menu = core.addon or core:CreateMenu();
  --menu:Show();
  core:Update()
  if RestockerDB.Items == nil then return end



  local boughtItems = 0

  local poisonReagentsNeeded = core:getPoisonReagents()

  if RestockerDB.AutoBuy == true then

    for i = 0, GetMerchantNumItems() do
      local itemName, _, _, quantity, numAvailable = GetMerchantItemInfo(i)
      local itemLink = GetMerchantItemLink(i)


      -- POISONS
      if poisonReagentsNeeded[itemName] ~= nil then
          local _, _, _, _, _, _, _, itemStackCount = GetItemInfo(itemLink)

          local buyAmount = poisonReagentsNeeded[itemName]-GetItemCount(itemName, false)

          for n = buyAmount, 1, -itemStackCount do
            if n > itemStackCount then
              BuyMerchantItem(i, itemStackCount)
              boughtItems = boughtItems +1
            else
              BuyMerchantItem(i, n)
              boughtItems = boughtItems +1
            end
          end

      end


      -- EVERYTHING ELSE
      if RestockerDB.Items[itemName] ~= nil then
        _, _, _, _, _, _, _, itemStackCount = GetItemInfo(RestockerDB.Items[itemName].itemLink)
        local restockNum = RestockerDB.Items[itemName].amount
        local inPossesion = GetItemCount(itemName, false)
        local difference = restockNum - inPossesion

        if restockNum > inPossesion then
          if restockNum > numAvailable and numAvailable > 0 then
            BuyMerchantItem(i, numAvailable)
            boughtItems = boughtItems +1
          else
            for n = difference, 1, -itemStackCount do
              if n > itemStackCount then
                BuyMerchantItem(i, itemStackCount)
                boughtItems = boughtItems +1
              else
                BuyMerchantItem(i, n)
                boughtItems = boughtItems +1
              end
            end -- forloop
          end
        end -- restockNum > inPossesion
      end -- if RestockerDB.Items[itemName] ~= nil
    end -- for loop GetMerchantNumItems()
  end
  --if boughtItems > 0 then core:Print("Restocker has finished restocking.") end
end


function events:MERCHANT_CLOSED(event, ...)
  core.addon:Hide();
end

function events:BANKFRAME_CLOSED(event, ...)
  core.currentlyRestocking = false
  core.addon:Hide();
end

function events:MERCHANT_CLOSED(event, ...)
  core.addon:Hide();
end



function events:BAG_UPDATE(event, ...)
  if core.currentlyRestocking == true then
    if type(core.coroutine) == nil then
      if coroutine.status(core.coroutine) ~= "running" then
        core.coroutine = coroutine.create(function()
          core:PickupItem()
        end)
        coroutine.resume(core.coroutine)
      end
    else
      core.coroutine = coroutine.create(function()
        core:PickupItem()
      end)
      coroutine.resume(core.coroutine)
    end

  end
end

----------------------------
---- BANK SHOWN
----------------------------

function events:BANKFRAME_OPENED(event, ...)
  local menu = core.addon or core:CreateMenu();
  core:Update()
  if RestockerDB.Items == nil then return end
  core.currentlyRestocking = true
  core:PickupItem()

end


function core:PickupItem()
  local bankBags = {-1,5,6,7,8,9,10}

  for itemName, v in pairs(RestockerDB.Items) do
    local numItemsInBags = GetItemCount(itemName, false)
    local numItemsInBank = GetItemCount(itemName, true) - numItemsInBags
    local restockNum = v.amount
    local difference = restockNum-numItemsInBags
    local itemLink = v.itemLink

    if difference > 0 and numItemsInBank > 0 then
      for k, bbag in ipairs(bankBags) do
        for bslot = 1, GetContainerNumSlots(bbag) do
          local _, bstackSize, _, _, _, _, bitemLink, _, _, bitemID = GetContainerItemInfo(bbag, bslot)
          if bitemLink ~= nil then
            local bitemName, bitemLink, _, _, _, _, _, bmaxStack = GetItemInfo(bitemID)

            if itemName == bitemName then
              if difference < bstackSize then
                SplitContainerItem(bbag, bslot, difference)

                for ibag = 0, NUM_BAG_SLOTS do
                  for islot = 1, GetContainerNumSlots(ibag) do
                    local _, istackSize, _, _, _, _, iitemLink, _, _, iitemID = GetContainerItemInfo(ibag, islot)
                    if iitemLink ~= nil then
                      local iitemName, iitemLink, _, _, _, _, _, imaxStack = GetItemInfo(iitemID)
                      local curstackplusdif = istackSize + difference
                      if iitemName == itemName and (curstackplusdif == imaxStack) then
                        return PickupContainerItem(ibag, islot)
                      end

                    end
                  end -- for invslots
                end -- for invbags

                -- If we get here then there were nowhere to put the picked up item to match a full stack size, so push it to the first available slot
                for ibag = 0, NUM_BAG_SLOTS do
                  if GetContainerNumFreeSlots(ibag) > 0 then
                    if ibag == 0 then
                      return PutItemInBackpack()
                    else
                      return PutItemInBag(19+ibag)
                    end

                  end
                end

              else -- difference >= bstackSize
                return UseContainerItem(bbag, bslot)
              end

            end -- itemname == bitemname

          end -- itemname ~= nil
        end -- for bankslots
      end -- for bankbags
      return
    end -- if difference > 0
  end -- for each RestockerDB.Item


  core.currentlyRestocking = false
end


------------------------
----- Slash commands
----–––––---------------

function core:SlashCommand(args)
  local farg = select(1, args);
  if farg == "reset" then
    RestockerDB = {}
    RestockerDB["AutoBuy"] = true
    RestockerDB["Items"] = {}
    return
  elseif farg == "show" then
    local menu = core.addon or core:CreateMenu();
    menu:SetShown(true);
  else
    local menu = core.addon or core:CreateMenu();
    menu:SetShown(not menu:IsShown());
  end
  core:Update()
end


-----------------------
---- MAIN FRAME
-----------------------

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

  --[[

    local listframe = CreateFrame("Frame", nil, addon)
    listframe.width = addon.listInset.width - 4
    listframe.height = addon.listInset.height - 32
    listframe:SetSize(listframe.width, listframe.height);
    listframe:SetPoint("TOP", listInset, "TOP", 2, -6);
    addon.listframe = listframe
  ]]

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



    -- Text field
    local editBox = CreateFrame("EditBox", nil, addon.addGrp, "InputBoxTemplate");
    editBox:SetPoint("RIGHT", addBtn, "LEFT", 3);
    editBox:SetAutoFocus(false);
    editBox:SetSize(addon.addGrp:GetWidth()-addBtn:GetWidth()-5, 25);

    addBtn:SetScript("OnClick", function(self, button, down)
      local text = editBox:GetText()

      local itemName, itemLink = GetItemInfo(text)
      if itemName ~= nil then
        core:addItem(itemName);

        editBox:SetText("")
        editBox:ClearFocus()
      else
      end
    end);

    editBox:SetScript("OnEnterPressed", function(self)
      local text = self:GetText()

      local itemName, itemLink = GetItemInfo(text)
      if itemLink ~= nil then

        core:addItem(itemName);

        self:SetText("")
        self:ClearFocus()
      else
      end

    end);

    addon.editBox = editBox
    addon.addBtn = addBtn

  -- END OF GROUP

  -- AUTOBUY
  -- Checkbox for autobuy
    local checkbox = CreateFrame("CheckButton", nil, addon, "UICheckButtonTemplate");
    checkbox:SetPoint("BOTTOMLEFT", addon, "BOTTOMLEFT", 5, 5)
    checkbox:SetSize(25, 25)
    checkbox:SetChecked(RestockerDB["AutoBuy"]);
    checkbox:SetScript("OnClick", function(self, button, down)
      RestockerDB["AutoBuy"] = checkbox:GetChecked()
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


-----------------------
---- UPDATE
-----------------------
function core:Update()
  local children  = { core.addon.scrollChild:GetChildren() }
  local numChildren = #children;
  local itemlist = RestockerDB.Items


  for k,v in pairs(itemlist) do
    if v.number ~= nil then
      local amount = tonumber(v.number)
      RestockerDB.Items[k].amount = amount
      v.number = nil
    end
    if v.itemName == nil then
      local amount = tonumber(v.number)
      RestockerDB.Items[k].itemName = k
      v.number = nil
    end
  end



  if numChildren == 0 then
    core:addListFrames()
    return
  end


  
  for i, frame in ipairs(core.framepool) do
    frame.isInUse = false
    frame:SetParent(core.hiddenFrame)
    frame:Hide()
  end


  for itemName, v in pairs(RestockerDB.Items) do

    local frame = core:GetFirstEmpty()

    if frame ~= false then 
      frame:SetParent(core.addon.scrollChild)
      frame:Show()
      frame.isInUse = true
      frame.editBox:SetText(v.amount)
      frame.text:SetText(itemName)
    else
      core:addListFrame(v.itemName, v)
    end
    
  end

end



function core:GetFirstEmpty() 
  for i, frame in ipairs(core.framepool) do
    if not frame.isInUse then 
      return frame 
    end
  end
  return core:addListFrame()
end
-----------------------
---- ADD ITEM
-----------------------
function core:addItem(itemName)
  if RestockerDB.Items[itemName] ~= nil then return end

  RestockerDB.Items[itemName] = {};
  local itemName, itemLink = GetItemInfo(itemName)

  if itemName ~= nil then
    RestockerDB.Items[itemName].itemLink = itemLink
    RestockerDB.Items[itemName].amount = 1
    RestockerDB.Items[itemName].itemName = itemName
  end
  core:addListFrame(itemName, RestockerDB.Items[itemName])
  core:Update()
end


-----------------------
---- ADD LIST FRAME
-----------------------
function core:addListFrame()
  local listframe = core.addon.scrollChild
  local children = { listframe:GetChildren() };
  local lastChild = children[#children];

  local frame = CreateFrame("Frame", nil, listframe)
  frame:SetSize(listframe.width, 20);
  if #children == 0 then
    frame:SetPoint("TOP", listframe, "TOP")
  else
    frame:SetPoint("TOP", lastChild, "BOTTOM")
  end
  listframe:SetHeight(#children*20)

  -- ITEM TEXT
  local text = frame:CreateFontString(nil, "OVERLAY");
  text:SetFontObject("GameFontHighlight");
  text:SetPoint("LEFT", frame, "LEFT");
  frame.text = text

  -- BUTTON
  local delBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton");
  delBtn:SetPoint("RIGHT", frame, "RIGHT", 8, 0);
  delBtn:SetSize(30, 30);
  delBtn:SetScript("OnClick", function(self, mousebutton, down)
    local parent = self:GetParent();
    local item = parent.text:GetText();

    RestockerDB.Items[item] = nil
    --parent:SetSize(1,1)
    --local point, relativeTo, relativePoint, xOfs, yOfs = parent:GetPoint()
    --parent:SetPoint("TOP", -1, -1)
    --parent:Hide();
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
    local item = parent.text:GetText();

    RestockerDB.Items[item].amount = tonumber(amount)
    editBox:ClearFocus()

  end);
  editBox:SetScript("OnKeyUp", function(self, key)
    local amount;
    local parent = self:GetParent();
    local item = parent.text:GetText();

    if self:GetText() == "" then
      amount = 0;
      self:SetText(0)
      RestockerDB.Items[item].amount = tonumber(amount)
      return
    end
    local amount = tonumber(self:GetText())

    self:SetText(amount);
    RestockerDB.Items[item].amount = tonumber(amount)
  end)
  frame.editBox = editBox
  frame.isInUse = true
  frame:Show()
  tinsert(core.framepool, frame)
  return frame
end



-----------------------
---- ADD LIST FRAMES
-----------------------
function core:addListFrames()
  local listframe = core.addon.listframe
  for k,v in pairs(RestockerDB.Items) do
    local frame = core:addListFrame()
    frame.text:SetText(k)
    frame.editBox:SetText(v.amount)
  end
end



-- REPOPULATE
function core:repopulate()
  local children = { core.addon.scrollChild:GetChildren() }
  for i, v in ipairs(children) do
    local c = children[i]
    c.isInUse = false
    c:Hide()
  end

  for itemName, v in ipairs(RestockerDB.Items) do
    local c = children[i]
    c:Show()
    c.isInUse = true
    c.editbox:SetText(v.amount)
    c.text:SetText(itemName)
  end
end