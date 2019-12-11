local _, core = ...;

poisons = {
  -- INSTANT POISONS
  ["Instant Poison VI"] = {
    ["Dust of Deterioration"] = 4,
    ["Crystal Vial"] = 1
  },
  ["Instant Poison V"] = {
    ["Dust of Deterioration"] = 3,
    ["Crystal Vial"] = 1
  },
  ["Instant Poison IV"] = {
    ["Dust of Deterioration"] = 2,
    ["Crystal Vial"] = 1
  },
  ["Instant Poison III"] = {
    ["Dust of Deterioration"] = 1,
    ["Leaded Vial"] = 1
  },
  ["Instant Poison II"] = {
    ["Dust of Decay"] = 3,
    ["Leaded Vial"] = 1
  },
  ["Instant Poison"] = {
    ["Dust of Decay"] = 1,
    ["Empty Vial"] = 1
  },
  -- CRIPPLING POISONS
  ["Crippling Poison II"] = {
    ["Essence of Agony"] = 3,
    ["Crystal Vial"] = 1
  },
  ["Crippling Poison"] = {
    ["Essence of Pain"] = 1,
    ["Empty Vial"] = 1
  },
  -- DEADLY POISONS
  ["Deadly Poison V"] = {
    ["Deathweed"] = 7,
    ["Crystal Vial"] = 1
  },
  ["Deadly Poison IV"] = {
    ["Deathweed"] = 5,
    ["Crystal Vial"] = 1
  },
  ["Deadly Poison III"] = {
    ["Deathweed"] = 3,
    ["Crystal Vial"] = 1
  },
  ["Deadly Poison II"] = {
    ["Deathweed"] = 2,
    ["Leaded Vial"] = 1
  },
  ["Deadly Poison"] = {
    ["Deathweed"] = 1,
    ["Leaded Vial"] = 1
  },
  -- MIND-NUMBING POISONS
  ["Mind-numbing Poison III"] = {
    ["Dust of Deterioration"] = 2,
    ["Essence of Agony"] = 2,
    ["Crystal Vial"] = 1
  },
  ["Mind-numbing Poison II"] = {
    ["Dust of Decay"] = 4,
    ["Essence of Pain"] = 4,
    ["Leaded Vial"] = 1
  },
  ["Mind-numbing Poison"] = {
    ["Dust of Decay"] = 1,
    ["Essence of Pain"] = 1,
    ["Empty Vial"] = 1
  },
  -- WOUND POISONS
  ["Wound Poison IV"] = {
    ["Essence of Agony"] = 2,
    ["Deathweed"] = 2,
    ["Crystal Vial"] = 1
  },
  ["Wound Poison III"] = {
    ["Essence of Agony"] = 1,
    ["Deathweed"] = 2,
    ["Crystal Vial"] = 1
  },
  ["Wound Poison II"] = {
    ["Essence of Pain"] = 1,
    ["Deathweed"] = 2,
    ["Leaded Vial"] = 1
  },
  ["Wound Poison"] = {
    ["Essence of Pain"] = 1,
    ["Deathweed"] = 1,
    ["Leaded Vial"] = 1
  }
}

core.poisons = poisons;


function core:getPoisonReagents()
  local neededReagents = {}
  for _, item in ipairs(Restocker.profiles[Restocker.currentProfile]) do
    if string.find(item.itemName:lower(), "poison") ~= nil then
      local restockNum = item.amount
      local inPossesion = GetItemCount(item.itemID, true)
      local poisonsNeeded = restockNum - inPossesion
      local minDifference = restockNum/2

      if poisonsNeeded >= minDifference and poisonsNeeded > 0 then
          for reagent, amount in pairs(core.poisons[item.itemName]) do
            if neededReagents[reagent] ~= nil then neededReagents[reagent] = neededReagents[reagent]+(amount*poisonsNeeded) end
            if neededReagents[reagent] == nil then neededReagents[reagent] = (amount*poisonsNeeded) end
          end
      end

    end
  end

  return neededReagents
end


--return core
