local _, core = ...;
core.loaded = false
core.itemWaitTable = {}


local events = CreateFrame("Frame");
events:RegisterEvent("ADDON_LOADED");
events:RegisterEvent("MERCHANT_SHOW");
events:RegisterEvent("MERCHANT_CLOSED");
events:RegisterEvent("BANKFRAME_OPENED");
events:RegisterEvent("BANKFRAME_CLOSED");
events:RegisterEvent("GET_ITEM_INFO_RECEIVED");
events:RegisterEvent("PLAYER_LOGOUT");
events:RegisterEvent("PLAYER_ENTERING_WORLD");
events:SetScript("OnEvent", function(self, event, ...)
  return self[event] and self[event](self, ...)
end)

function events:ADDON_LOADED(name)
  if name ~= "Restocker" then return end

  if Restocker == nil then Restocker = {} end

  -- OLD RESTOCKER
  if Restocker.AutoBuy == nil and Restocker.autoBuy == nil then Restocker.AutoBuy = true end
  if Restocker.Items == nil and Restocker.profiles == nil then Restocker.Items = {} end

  -- NEW RESTOCKER
  if Restocker.autoBuy == nil then Restocker.autoBuy = true end
  if Restocker.profiles == nil then Restocker.profiles = {} end
  if #Restocker.profiles == 0 and Restocker.Items ~= nil then
    Restocker.profiles.default = Restocker.Items
  end
  if Restocker.currentProfile == nil then Restocker.currentProfile = "default" end
  Restocker.Items = nil
  if Restocker.framePos == nil then Restocker.framePos = {} end
  if Restocker.autoOpenAtMerchant == nil then Restocker.autoOpenAtMerchant = false end
  if Restocker.autoOpenAtBank == nil then Restocker.autoOpenAtBank = true end
  if Restocker.profileSelectedForDeletion == nil then Restocker.profileSelectedForDeletion = "" end


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

  core:CreateOptionsMenu()
  core:Show()
  core:Hide()
  core.loaded = true
end

function events:PLAYER_ENTERING_WORLD(login, reloadui)
  if not core.loaded then return end
  if login or reloadui then
    core:Print("|cffff2200Restocker|r loaded. /rs or /restocker to open addon.")
  end
end

function events:MERCHANT_SHOW()
  local didBuy = false
  if Restocker.autoOpenAtMerchant then
    core:Show()
  end

  if Restocker.profiles[Restocker.currentProfile] == nil then return end

  local poisonReagentsNeeded = core:getPoisonReagents()
  local buyTable = {}



  if Restocker.autoBuy == true then
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
              didBuy = true
            else
              BuyMerchantItem(i, n)
              didBuy = true
            end
          end

      end


      -- EVERYTHING ELSE
      if buyTable[itemName] ~= nil then
        local item = buyTable[itemName]
        local _, _, _, _, _, _, _, itemStackCount = GetItemInfo(item.itemLink)


        if item.numNeeded > numAvailable and numAvailable > 0 then
          BuyMerchantItem(i, numAvailable)
          didBuy = true
        else
          for n = item.numNeeded, 1, -itemStackCount do
            if n > itemStackCount then
              BuyMerchantItem(i, itemStackCount)
              didBuy = true
            else
              BuyMerchantItem(i, n)
              didBuy = true
            end
          end -- forloop
        end
      end -- if buyTable[itemName] ~= nil
    end -- for loop GetMerchantNumItems()
    if didBuy then core:Print(core.defaults.prefix .. "finished restocking from vendor.") end
  end
end


function events:MERCHANT_CLOSED(event, ...)
  core:Hide()
end







function events:BANKFRAME_OPENED(event, ...)
  if Restocker.profiles[Restocker.currentProfile] == nil then return end

  if Restocker.autoOpenAtBank then core:Show() end

  core.currentlyRestocking = true
end

function core:triggerBankOpen()
  events:BANKFRAME_OPENED()
end


function events:BANKFRAME_CLOSED(event, ...)
  core.currentlyRestocking = false
  core:Hide()
end




function events:GET_ITEM_INFO_RECEIVED(itemID, success)
  if success == nil then return end
  if core.itemWaitTable[itemID] then
    core.itemWaitTable[itemID] = nil
    core:addItem(itemID)
  end
end



function events:PLAYER_LOGOUT()
  if Restocker.framePos == nil then Restocker.framePos = {} end

  core:Show()
  core:Hde()

  local point, relativeTo, relativePoint, xOfs, yOfs = core.addon:GetPoint(core.addon:GetNumPoints())

  Restocker.framePos.point = point
  Restocker.framePos.relativePoint = relativePoint
  Restocker.framePos.xOfs = xOfs
  Restocker.framePos.yOfs = yOfs
end
