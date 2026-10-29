function HasPromotion(pUnit, iPromotion)
  return (pUnit and pUnit:IsHasPromotion(iPromotion))
end

function CanAcquirePromotion(pUnit, iPromotion)
  if (pUnit and pUnit:CanAcquirePromotion(iPromotion)) then
    local iAction = GetActionForPromotion(iPromotion)
	return (iAction and Game.CanHandleAction(iAction))
  end

  return false
end


function GetActionForPromotion(iPromotion)
  local promotion = GameInfo.UnitPromotions[iPromotion]

  for iAction, action in pairs(GameInfoActions) do
    if (action.SubType == ActionSubTypes.ACTIONSUBTYPE_PROMOTION and action.Type == promotion.Type) then
	  return iAction
    end
  end

  return nil
end


local sMatchRank = "_[0-9IV]+$"

function IsRankedPromotion(sPromotion)
	if (sPromotion == "PROMOTION_MEDIC" or sPromotion == "PROMOTION_CHARGE" or sPromotion == "PROMOTION_ANTI_AIR") then
		return true
	end
  return (sPromotion:match(sMatchRank) ~= nil)
end

function GetPromotionBase(sPromotion)
  local sRank = sPromotion:match(sMatchRank) or ""
  return sPromotion:sub(1, sPromotion:len()-sRank:len())
end

function GetNextPromotion(sPromotion, sCombatClass)
  if (not IsRankedPromotion(sPromotion)) then
    return nil
  end

  local sBase = GetPromotionBase(sPromotion)

  local promotions = {}
  local sPrereqs = "p1.Type = p2.PromotionPrereqOr1 OR p1.Type = p2.PromotionPrereqOr2 OR p1.Type = p2.PromotionPrereqOr3 OR p1.Type = p2.PromotionPrereqOr4 OR p1.Type = p2.PromotionPrereqOr5 OR p1.Type = p2.PromotionPrereqOr6 OR p1.Type = p2.PromotionPrereqOr7 OR p1.Type = p2.PromotionPrereqOr8 OR p1.Type = p2.PromotionPrereqOr9"
  local sQuery = "SELECT p2.Type FROM UnitPromotions p1, UnitPromotions p2, UnitPromotions_UnitCombats c WHERE p1.Type = ? AND (" .. sPrereqs .. ") AND p2.Type = c.PromotionType AND c.UnitCombatType = ? AND p2.Type LIKE ?"
  for row in DB.Query(sQuery, sPromotion, sCombatClass, sBase .. "%") do
    table.insert(promotions, row.Type)
  end
  
  return promotions[1]
end

function GetPromotionChain(sPromotion, sCombatClass)
  local promotions = {}

  repeat
	table.insert(promotions, sPromotion)

	sPromotion = GetNextPromotion(sPromotion, sCombatClass)
  until (sPromotion == nil)

  return promotions
end

function GetBasicPromotions(sCombatClass)
  local promotions = {}

  local sQuery = "SELECT p.Type FROM UnitPromotions p, UnitPromotions_UnitCombats c WHERE c.UnitCombatType = ? AND c.PromotionType = p.Type AND p.PromotionPrereqOr1 IS NULL AND NOT p.CannotBeChosen"
  for row in DB.Query(sQuery, sCombatClass) do
    if (IsRankedPromotion(row.Type)) then
      table.insert(promotions, row.Type)
	end
  end

  return promotions
end

function GetBasicPromotionsSpecialCases(typeOfUnit)
	local promotions = {}
	local sQuery = ""

	if (typeOfUnit == 0) then
		sQuery = "SELECT p.Type FROM UnitPromotions p, UnitPromotions_UnitCombats c WHERE c.UnitCombatType = \"UNITCOMBAT_HELICOPTER\" AND c.PromotionType = p.Type AND p.PromotionPrereqOr1 IS NULL AND NOT p.CannotBeChosen"
	elseif (typeOfUnit == 1) then
		sQuery = "SELECT p.Type FROM UnitPromotions p, UnitPromotions_UnitCombats c WHERE c.UnitCombatType = \"UNITCOMBAT_MOUNTED_ARCHER\" AND c.PromotionType = p.Type AND p.PromotionPrereqOr1 IS NULL AND NOT p.CannotBeChosen"
	elseif (typeOfUnit == 2) then
		sQuery = "SELECT p.Type FROM UnitPromotions p, UnitPromotions_UnitCombats c WHERE c.UnitCombatType = \"UNITCOMBAT_ARCHER\" AND c.PromotionType = p.Type AND p.PromotionPrereqOr1 IS NULL AND NOT p.CannotBeChosen"  
	elseif (typeOfUnit == 3) then
		sQuery = "SELECT p.Type FROM UnitPromotions p, UnitPromotions_UnitCombats c WHERE c.UnitCombatType = \"UNITCOMBAT_SIEGE\" AND c.PromotionType = p.Type AND p.PromotionPrereqOr1 IS NULL AND NOT p.CannotBeChosen"
	elseif (typeOfUnit == 5) then
		sQuery = "SELECT p.Type FROM UnitPromotions p, UnitPromotions_UnitCombats c WHERE c.UnitCombatType = \"UNITCOMBAT_ARMOR\" AND c.PromotionType = p.Type AND p.PromotionPrereqOr1 IS NULL AND NOT p.CannotBeChosen"
	elseif (typeOfUnit == 6) then
		sQuery = "SELECT p.Type FROM UnitPromotions p, UnitPromotions_UnitCombats c WHERE c.UnitCombatType = \"UNITCOMBAT_NAVALMELEE\" AND c.PromotionType = p.Type AND p.PromotionPrereqOr1 IS NULL AND NOT p.CannotBeChosen"
	end

	for row in DB.Query(sQuery) do
		if (IsRankedPromotion(row.Type)) then
			table.insert(promotions, row.Type)
		end
	end
  
	if (typeOfUnit == 3) then
		table.insert(promotions, "PROMOTION_COVER_1")
	elseif (typeOfUnit == 6) then  
		table.insert(promotions, "PROMOTION_CAN_SEE_INVISIBLE_SUBMARINE")
  end
  
  return promotions
end

function GetBasePromotions(sCombatClass)
	local promotions = {}
 
	if (sCombatClass == "UNITCOMBAT_HELICOPTER") then
		for _, sPromotion in ipairs(GetBasicPromotionsSpecialCases(0)) do
			table.insert(promotions, GetPromotionChain(sPromotion, sCombatClass))
		end
	elseif (sCombatClass == "UNITCOMBAT_MOUNTED_ARCHER") then
		for _, sPromotion in ipairs(GetBasicPromotionsSpecialCases(1)) do
			table.insert(promotions, GetPromotionChain(sPromotion, sCombatClass))
		end
	elseif (sCombatClass == "UNITCOMBAT_ARCHER") then
		for _, sPromotion in ipairs(GetBasicPromotionsSpecialCases(2)) do
			table.insert(promotions, GetPromotionChain(sPromotion, sCombatClass))
		end
	elseif (sCombatClass == "UNITCOMBAT_SIEGE") then
		for _, sPromotion in ipairs(GetBasicPromotionsSpecialCases(3)) do
			table.insert(promotions, GetPromotionChain(sPromotion, sCombatClass))
		end
	elseif (sCombatClass == "UNITCOMBAT_ARMOR") then
		for _, sPromotion in ipairs(GetBasicPromotionsSpecialCases(5)) do
			table.insert(promotions, GetPromotionChain(sPromotion, sCombatClass))
		end
	elseif (sCombatClass == "UNITCOMBAT_NAVALMELEE") then
		for _, sPromotion in ipairs(GetBasicPromotionsSpecialCases(6)) do
			table.insert(promotions, GetPromotionChain(sPromotion, sCombatClass))
		end
	else
		for _, sPromotion in ipairs(GetBasicPromotions(sCombatClass)) do
			table.insert(promotions, GetPromotionChain(sPromotion, sCombatClass))
		end
	end
	
	return promotions
end

function GetDependentPromotions(sCombatClass, sPromotion)
  local promotions = {}

  if (IsRankedPromotion(sPromotion)) then
    local sBase = GetPromotionBase(sPromotion)
    
	local sPrereqs = "p1.Type = p2.PromotionPrereqOr1 OR p1.Type = p2.PromotionPrereqOr2 OR p1.Type = p2.PromotionPrereqOr3 OR p1.Type = p2.PromotionPrereqOr4 OR p1.Type = p2.PromotionPrereqOr5 OR p1.Type = p2.PromotionPrereqOr6 OR p1.Type = p2.PromotionPrereqOr7 OR p1.Type = p2.PromotionPrereqOr8 OR p1.Type = p2.PromotionPrereqOr9"
	local sQuery = "SELECT p2.Type FROM UnitPromotions p1, UnitPromotions p2, UnitPromotions_UnitCombats c WHERE p1.Type = ? AND (" .. sPrereqs .. ") AND p2.Type = c.PromotionType AND c.UnitCombatType = ? AND p2.Type NOT LIKE ?"
    for row in DB.Query(sQuery, sPromotion, sCombatClass, sBase .. "%") do
		table.insert(promotions, GetPromotionChain(row.Type, sCombatClass))
	end
  end

  return promotions
end