local _, core = ...

core.currentlyRestocking = false
core.itemsRestocked = {}
core.restockedItems = false
core.coroutine = nil
core.framepool = {}
core.hiddenFrame = CreateFrame("Frame", nil, UIParent):Hide()
core.currentProfile


function core:Print(...)
  DEFAULT_CHAT_FRAME:AddMessage(tostringall(...))
end


--[[
  SLASH COMMANDS
]]
function core:SlashCommand(args)
  local farg = select(1, args)
  if farg == "reset" then
    Restocker = {}
    Restocker["AutoBuy"] = true
    Restocker["Items"] = {}
    return
  elseif farg == "show" then
    local menu = core.addon or core:CreateMenu()
    menu:Show()
  else
    local menu = core.addon or core:CreateMenu()
    menu:SetShown(not menu:IsShown())
  end
  core:Update()
end


--[[
  UPDATE
]] 
function core:Update()


  for _, f in ipairs(core.framepool) do
    f.isInUse = false
    f:SetParent(core.hiddenFrame)
  end

  for _, item in ipairs(Restocker.Items) do
    local f = core:GetFirstEmpty()
    f:SetParent(core.addon.scrollChild)
    f.isInUse = true
    f.editBox:SetText(item.amount)
    f.text:SetText(item.itemName)
  end

  local height = 0
  for _, f in ipairs(core.framepool) do
    if f.isInUse then height = height+15 end
  end
  core.addon.scrollChild:SetHeight(height)
end



function core:GetFirstEmpty()
  for i, frame in ipairs(core.framepool) do
    if not frame.isInUse then
      return frame
    end
  end
  return core:addListFrame()
end


--[[
  RENAME PROFILE
]] 
function core:RenameCurrentProfile(newName)
  local currentProfile = core.currentProfile
  Restocker.profiles[newName] = Restocker.profiles[currentProfile]
  Restocker.profiles[currentProfile] = nil
  core.currentProfile = newName
end
