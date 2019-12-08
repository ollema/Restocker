local _, core = ...;

function core:PickupItem()
  local bankBags = {-1,5,6,7,8,9,10}
  local bankBagsReversed = {10,9,8,7,6,5,-1}

  for _, item in ipairs(Restocker.Items) do
    local numItemsInBags = GetItemCount(item.itemID, false)
    local numItemsInBank = GetItemCount(item.itemID, true) - numItemsInBags
    local restockNum = item.amount
    local difference = restockNum-numItemsInBags

    if difference > 0 and numItemsInBank > 0 then
      for _, bbag in ipairs(bankBagsReversed) do
        for bslot = GetContainerNumSlots(bbag), 1, -1 do
          local _, bstackSize, _, _, _, _, bitemLink, _, _, bitemID = GetContainerItemInfo(bbag, bslot)
          if bitemLink ~= nil then
            local bitemName = GetItemInfo(bitemID)

            if item.itemName == bitemName then
              if difference < bstackSize then
                SplitContainerItem(bbag, bslot, tonumber(difference))

                for ibag = 0, NUM_BAG_SLOTS do
                  for islot = 1, GetContainerNumSlots(ibag) do
                    local _, istackSize, _, _, _, _, iitemLink, _, _, iitemID = GetContainerItemInfo(ibag, islot)
                    if iitemLink ~= nil then
                      local iitemName, _, _, _, _, _, _, imaxStack = GetItemInfo(iitemID)
                      local curstackplusdif = istackSize + difference
                      if iitemName == item.itemName and (curstackplusdif == imaxStack) then
                        if ibag == 0 then
                          return PutItemInBackpack()
                        else
                          return PutItemInBag(19+ibag)
                        end
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
    elseif difference < 0 then
      local posdifference = difference*-1 -- turn negative number to positive
      for ibag = NUM_BAG_SLOTS, 0, -1 do -- loop backwards through bags
        for islot = GetContainerNumSlots(ibag), 1, -1 do -- loop backward through bagslots
          local _, istackSize, _, _, _, _, iitemLink, _, _, iitemID = GetContainerItemInfo(ibag, islot)
          if iitemLink ~= nil then -- slot contains an item
            local iitemName = GetItemInfo(iitemID)
            if iitemName == item.itemName then
              return UseContainerItem(ibag, islot)
            end
          end -- invitemlink ~= nil
        end -- for numslots
      end -- for numbags
    end
  end -- for each Restocker.Item


  core.currentlyRestocking = false
end
