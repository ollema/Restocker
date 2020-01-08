local _, core = ...;




local function putIntoEmptySlot()
  local bankBags = {-1,5,6,7,8,9,10}
  for _, bag in ipairs(bankBags) do
    for slot = 1, GetContainerNumSlots(bag) do
      local _, stackSize, locked, _, _, _, itemLink, _, _, itemID = GetContainerItemInfo(bag, slot)
      if itemLink == nil then -- slot is empty
        PickupContainerItem(bag, slot)
      end
    end
  end
end


local function findPreciseStack(restockItemLink, amount)
  local bankBagsReversed = {10,9,8,7,6,5,-1}
  for _, bag in ipairs(bankBagsReversed) do
    for slot = 1, GetContainerNumSlots(bag) do
      local _, stackSize, locked, _, _, _, itemLink, _, _, itemID = GetContainerItemInfo(bag, slot)
      if itemLink == restockItemLink and stackSize == amount and locked then -- slot is not empty
        UseContainerItem(bag, slot)
      end
    end
  end
end




function core:PickupItem()
  local bankBags = {-1,5,6,7,8,9,10}
  local bankBagsReversed = {10,9,8,7,6,5,-1}
  local currentProfile = Restocker.profiles[Restocker.currentProfile]


  for _, item in ipairs(currentProfile) do
    local numItemsInBags = GetItemCount(item.itemID, false)
    local numItemsInBank = GetItemCount(item.itemID, true) - numItemsInBags
    local restockNum = item.amount
    local difference = restockNum-numItemsInBags

    findPreciseStack(item.itemLink, difference)

    if difference > 0 and numItemsInBank > 0 then
      for _, bbag in ipairs(bankBagsReversed) do -- traverse bank bags backwards (helps keeping bank more tidy)
        for bslot = GetContainerNumSlots(bbag), 1, -1 do -- traverse bank bag slots backwards
          local _, bstackSize, blocked, _, _, _, bitemLink, _, _, bitemID = GetContainerItemInfo(bbag, bslot)
          if bitemLink ~= nil then -- slot contains an item
            local bitemName = GetItemInfo(bitemID) -- get item name

            if item.itemName == bitemName then -- if item in slot == restock item
              if difference < bstackSize then -- if the restock number is less than the stack size
                SplitContainerItem(bbag, bslot, difference) -- split the item
                putIntoEmptySlot()
                return

              else -- difference >= bstackSize
                UseContainerItem(bbag, bslot) -- if the restock num is higher than the stack size then just return rightclick that stack
                return
              end

            end -- itemname == bitemname

          end -- itemname ~= nil
        end -- for bankslots
      end -- for bankbags
      return
    elseif difference < 0 then -- more of restock item in bags than needed, put excess in bank
      local posdifference = difference*-1 -- turn negative number to positive
      for ibag = NUM_BAG_SLOTS, 0, -1 do -- loop backwards through bags (helps with maintaining order)
        for islot = GetContainerNumSlots(ibag), 1, -1 do -- loop backward through bagslots
          local _, istackSize, _, _, _, _, iitemLink, _, _, iitemID = GetContainerItemInfo(ibag, islot)
          if iitemLink ~= nil then -- slot contains an item
            local iitemName = GetItemInfo(iitemID)
            if iitemName == item.itemName then -- item in slot is same as restock item
              return UseContainerItem(ibag, islot) -- push item from inventory to bank
              -- do this even if this results in less than the restock amount in bags as it will trigger the
              -- above code and will grab a partial stack to complete the numbers in inventory
              -- basically lazy coding which makes the implementation of profiles later easier
              -- (if you switch profile and want to put all of a certain item to bank)
            end
          end -- invitemlink ~= nil
        end -- for numslots
      end -- for numbags
    end
  end -- for each Restocker.Item

  core.currentlyRestocking = false
end
