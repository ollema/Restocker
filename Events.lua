local _, core = ...;

core.itemWaitTable = {}

local events = CreateFrame("Frame");
events:RegisterEvent("ADDON_LOADED");
events:RegisterEvent("MERCHANT_SHOW");
events:RegisterEvent("MERCHANT_CLOSED");
events:RegisterEvent("BANKFRAME_OPENED");
events:RegisterEvent("BANKFRAME_CLOSED");
events:RegisterEvent("GET_ITEM_INFO_RECEIVED");
events:RegisterEvent("BAG_UPDATE");
events:SetScript("OnEvent", function(self, event, ...)
  return self[event] and self[event](self, ...)
end)

function events:ADDON_LOADED(name)
  if name ~= "Restocker" then return end

  if Restocker == nil then Restocker = {} end
  if Restocker["AutoBuy"] == nil then Restocker["AutoBuy"] = true end
  if Restocker["Items"] == nil and Restocker["profiles"] == nil then Restocker["Items"] = {} end
  if Restocker.profiles == nil then Restocker["profiles"] = {} end
  if Restocker.profiles == nil and #Restocker.Items > 0 then
    Restocker.profiles.default = Restocker.Items
  end
  if Restocker.currentProfile == nil then Restocker.currentProfile = "default" end
  Restocker.Items = nil
 
  

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


function events:MERCHANT_SHOW()
  --local menu = core.addon or core:CreateMenu();
  if Restocker.profiles[Restocker.currentProfile] == nil then return end

  local poisonReagentsNeeded = core:getPoisonReagents()
  local buyTable = {}
  

  if Restocker.AutoBuy == true then
    local currentProfile = Restocker.profiles[Restocker.currentProfile]

    for _, item in ipairs(currentProfile) do
      local numInBags = GetItemCount(item.itemName, false)
      local numNeeded = item.amount - numInBags
      if numNeeded > 0 then
        buyTable[item.itemName] = {}
        buyTable[item.itemName]["numNeeded"] = numNeeded
        buyTable[item.itemName]["itemName"] = item.itemName
        buyTable[item.itemName]["itemID"] = item.itemID
        buyTable[item.itemName]["itemLink"] = item.itemLink
      end
    end

    for i = 0, GetMerchantNumItems() do
      local itemName, _, _, _, numAvailable = GetMerchantItemInfo(i)
      local itemLink = GetMerchantItemLink(i)


      -- POISONS
      if poisonReagentsNeeded[itemName] ~= nil then
          local _, _, _, _, _, _, _, itemStackCount = GetItemInfo(itemLink)

          local buyAmount = poisonReagentsNeeded[itemName]-GetItemCount(itemName, false)

          for n = buyAmount, 1, -itemStackCount do
            if n > itemStackCount then
              BuyMerchantItem(i, itemStackCount)
            else
              BuyMerchantItem(i, n)
            end
          end

      end


      -- EVERYTHING ELSE
      if buyTable[itemName] ~= nil then
        local item = buyTable[itemName]
        local _, _, _, _, _, _, _, itemStackCount = GetItemInfo(item.itemLink)


        if item.numNeeded > numAvailable and numAvailable > 0 then
          BuyMerchantItem(i, numAvailable)
        else
          for n = item.numNeeded, 1, -itemStackCount do
            if n > itemStackCount then
              BuyMerchantItem(i, itemStackCount)
            else
              BuyMerchantItem(i, n)
            end
          end -- forloop
        end
      end -- if Restocker.Items[itemName] ~= nil
    end -- for loop GetMerchantNumItems()
  end
end


function events:MERCHANT_CLOSED(event, ...)
  local menu = core.addon or core:CreateMenu();
  menu:Hide();
end







function events:BANKFRAME_OPENED(event, ...)
  if Restocker.Items == nil then return end
  core.currentlyRestocking = true
  core:PickupItem()
end


function events:BANKFRAME_CLOSED(event, ...)
  core.currentlyRestocking = false
end


function events:BAG_UPDATE(event, ...)
  if core.currentlyRestocking == true then
    if GetCursorInfo() == "item" then return end
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


function events:GET_ITEM_INFO_RECEIVED(itemID, success)
  if success == nil then return end
  if core.itemWaitTable[itemID] then
    core.itemWaitTable[itemID] = nil
    core:addItem(itemID)
  end
end
