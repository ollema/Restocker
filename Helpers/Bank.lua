local _, core = ...;

core.didBankStuff = false
local containerFreeSlots = {}
core.justSplit = false
core.splitLoc = {}



local function count(T)
  local i = 0
  for _,_ in pairs(T) do
    i = i+1
  end
  return i
end


local onUpdateFrame = CreateFrame("Frame")
local ONUPDATE_INTERVAL = 0.2
local timer = 0

onUpdateFrame:SetScript("OnUpdate", function(self, elapsed)
  timer = timer+elapsed
  if core.currentlyRestocking then
    if timer >= ONUPDATE_INTERVAL then
      timer = 0

      core:pickupItem()
    end
  end
end)



local function putIntoEmptyBankSlot()
  local bankBags = {-1,5,6,7,8,9,10}
  for _, bag in ipairs(bankBags) do
    wipe(containerFreeSlots)
    GetContainerFreeSlots(bag, containerFreeSlots)

    if count(containerFreeSlots) > 0 then
      PickupContainerItem(bag, containerFreeSlots[1])
      core.splitLoc.bag = bag
      core.splitLoc.slot = containerFreeSlots[1]
      core.justSplit = true
      return
    end

  end
end

local function pickupSpecificSlot(bag, slot)
  UseContainerItem(bag, slot)
  wipe(core.splitLoc)
  core.justSplit = false
end


local function anythingLocked()
  local bankBags = {-1,5,6,7,8,9,10}
  local anythingLocked = false

  for _, B in pairs(bankBags) do
    for S = 1, GetContainerNumSlots(B) do
      local _, _, locked = GetContainerItemInfo(B, S)
      if locked then return true end
    end
  end

  for B = 0, NUM_BAG_SLOTS do
    for S = 1, GetContainerNumSlots(B) do
      local _, _, locked = GetContainerItemInfo(B, S)
      if locked then return true end
    end
  end

  return false
end



function core:pickupItem()
  if anythingLocked() then return end
  local bankBags = {-1,5,6,7,8,9,10}
  local bankBagsReversed = {10,9,8,7,6,5,-1}
  local currentProfile = Restocker.profiles[Restocker.currentProfile]

  if core.justSplit then
    return pickupSpecificSlot(core.splitLoc.bag, core.splitLoc.slot)
  end

  for _, item in ipairs(currentProfile) do
    local numItemsInBags = GetItemCount(item.itemName, false)
    local numItemsInBank = GetItemCount(item.itemName, true) - numItemsInBags
    local restockNum = item.amount
    local difference = restockNum-numItemsInBags

    if difference > 0 and numItemsInBank > 0 then
      for _, bag in ipairs(bankBagsReversed) do -- traverse bank bags backwards (helps keeping bank more tidy)
        for slot = GetContainerNumSlots(bag), 1, -1 do -- traverse bank bag slots backwards
          local _, stackSize, locked, _, _, _, itemLink, _, _, itemID = GetContainerItemInfo(bag, slot)
          if itemLink ~= nil then -- slot contains an item
            local bitemName = GetItemInfo(itemLink) -- get item name

            if item.itemName == bitemName then -- if item in slot == restock item
              if difference < stackSize then -- if the restock number is less than the stack size
                SplitContainerItem(bag, slot, difference) -- split the item
                putIntoEmptyBankSlot()
                core.didBankStuff = true
                return

              else -- difference >= stackSize
                UseContainerItem(bag, slot) -- if the restock num is higher than the stack size then just return rightclick that stack
                core.didBankStuff = true
                return
              end

            end -- itemname == bitemname

          end -- itemname ~= nil
        end -- for bankslots
      end -- for bankbags
      return
    elseif difference < 0 then -- more of restock item in bags than needed, put excess in bank
      local posdifference = difference*-1 -- turn negative number to positive
      for bag = NUM_BAG_SLOTS, 0, -1 do -- loop backwards through bags (helps with maintaining order)
        for slot = GetContainerNumSlots(bag), 1, -1 do -- loop backward through bagslots
          local _, stackSize, locked, _, _, _, itemLink, _, _, itemID = GetContainerItemInfo(bag, slot)
          if itemLink ~= nil then -- slot contains an item
            local itemName = GetItemInfo(itemLink)
            if itemName == item.itemName then -- item in slot is same as restock item
              core.didBankStuff = true
              return UseContainerItem(bag, slot) -- push item from inventory to bank
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
  if core.didBankStuff then
    core:Print(core.defaults.prefix .. "finished restocking from bank.")
  end
  core.didBankStuff = false
end
