local _, core = ...

core.currentlyRestocking = false
core.itemsRestocked = {}
core.restockedItems = false
core.framepool = {}
core.hiddenFrame = CreateFrame("Frame", nil, UIParent):Hide()

core.defaults = {
  prefix = "|cffff2200Restocker|r ",
  color = "ff2200",
  slash = "|cffff2200/rs|r "
}


function core:Print(...)
  DEFAULT_CHAT_FRAME:AddMessage(tostringall(...))
end



core.commands = {
  show = core.defaults.slash .. "show - Show the addon",
  profile = {
    add = core.defaults.slash .. "profile add [name] - Adds a profile with [name]",
    delete = core.defaults.slash .. "profile delete [name] - Deletes profile with [name]",
    rename = core.defaults.slash .. "profile rename [name] - Renames current profile to [name]",
    copy = core.defaults.slash .. "profile copy [name] - Copies profile [name] into current profile.",
  }
}

--[[
  SLASH COMMANDS
]]
function core:SlashCommand(args)
  local command, rest = strsplit(" ", args, 2)
  command = command:lower()

  if command == "show" then
    local menu = core.addon or core:CreateMenu()
    menu:Show()

  elseif command == "profile" then
    if rest == "" or rest == nil then
      for _,v in pairs(core.commands.profile) do
        core:Print(v)
      end
      return
    end

    local subcommand, name = strsplit(" ", rest, 2)


    if subcommand == "add" then
      core:AddProfile(name)

    elseif subcommand == "delete" then
      core:DeleteProfile(name)

    elseif subcommand == "rename" then
      core:RenameCurrentProfile(name)

    elseif subcommand == "copy" then
      core:CopyProfile(name)
    end

  elseif command == "help" then

    for _, v in pairs(core.commands) do
      if type(v) == "table" then
        for _, vv in pairs(v) do
          core:Print(vv)
        end
      else
        core:Print(v)
      end
    end
    return

  elseif command == "config" then
    InterfaceOptionsFrame_OpenToCategory(core.optionsPanel)
    InterfaceOptionsFrame_OpenToCategory(core.optionsPanel)
    return

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
  local currentProfile = Restocker.profiles[Restocker.currentProfile]

  for _, f in ipairs(core.framepool) do
    f.isInUse = false
    f:SetParent(core.hiddenFrame)
    f:Hide()
  end

  for _, item in ipairs(currentProfile) do
    local f = core:GetFirstEmpty()
    f:SetParent(core.addon.scrollChild)
    f.isInUse = true
    f.editBox:SetText(item.amount)
    f.text:SetText(item.itemName)
    f:Show()
  end

  local height = 0
  for _, f in ipairs(core.framepool) do
    if f.isInUse then height = height+15 end
  end
  core.addon.scrollChild:SetHeight(height)
end


--[[
  GET FIRST UNUSED SCROLLCHILD FRAME
]]
function core:GetFirstEmpty()
  for i, frame in ipairs(core.framepool) do
    if not frame.isInUse then
      return frame
    end
  end
  return core:addListFrame()
end



--[[
  ADD PROFILE
]]
function core:AddProfile(newProfile)
  Restocker.currentProfile = newProfile
  Restocker.profiles[newProfile] = {}

  local menu = core.addon or core:CreateMenu()
  menu:Show()
  core:Update()

  UIDropDownMenu_SetText(core.addon.profileDropDownMenu, Restocker.currentProfile)


end


--[[
  DELETE PROFILE
]]
function core:DeleteProfile(profile)
  local currentProfile = Restocker.currentProfile

  if currentProfile == profile then
    if #Restocker.profiles > 1 then
      Restocker.profiles[currentProfile] = nil
      Restocker.currentProfile = Restocker.profiles[1]
    else
      Restocker.profiles[currentProfile] = nil
      Restocker.currentProfile = "default"
      Restocker.profiles.default = {}
    end

  else
    Restocker.profiles[profile] = nil
  end


  UIDropDownMenu_SetText(core.optionsPanel.deleteProfileMenu, "")
  local menu = core.addon or core:CreateMenu()
  Restocker.profileSelectedForDeletion = ""
  UIDropDownMenu_SetText(core.addon.profileDropDownMenu, Restocker.currentProfile)

end

--[[
  RENAME PROFILE
]]
function core:RenameCurrentProfile(newName)
  local currentProfile = Restocker.currentProfile

  Restocker.profiles[newName] = Restocker.profiles[currentProfile]
  Restocker.profiles[currentProfile] = nil

  Restocker.currentProfile = newName


  UIDropDownMenu_SetText(core.addon.profileDropDownMenu, Restocker.currentProfile)
end


--[[
  CHANGE PROFILE
]]
function core:ChangeProfile(newProfile)
  Restocker.currentProfile = newProfile

  UIDropDownMenu_SetText(core.addon.profileDropDownMenu, Restocker.currentProfile)
  print(core.defaults.prefix .. "current profile: ".. Restocker.currentProfile)
  core:Update()
  core:triggerBankOpen()
end


--[[
  COPY PROFILE
]]
function core:CopyProfile(profileToCopy)
  local copyProfile = CopyTable(Restocker.profiles[profileToCopy])
  Restocker.profiles[Restocker.currentProfile] = copyProfile
  core:Update()
end
