--====================================================================================================================
-- Military Overview
--====================================================================================================================

include( "IconSupport" );
include( "InstanceManager" );
include( "GreatPeopleIcons" );

local GameInfo = GameInfo

--====================================================================================================================
-- Global Variables and Constants
--====================================================================================================================
local g_MilitaryUnitsManager = InstanceManager:new("UnitInstance", "Root", Controls.MilitaryStack)
local g_CivilianUnitsManager = InstanceManager:new("UnitInstance", "Root", Controls.CivilianStack)

local g_SortTable = {}
local eName, eStatus, eMovement, eMoves, eStrength, eRanged, eUnitXP = 0, 1, 2, 3, 4, 5, 6
local g_SortMode = eName
local g_bSortReverse = false
local g_PopupInfo = nil
local g_MaxDamage = GameDefines.MAX_HIT_POINTS or 100

--====================================================================================================================
-- On Popup
--====================================================================================================================
function OnPopup(popupInfo)
    if popupInfo.Type == ButtonPopupTypes.BUTTONPOPUP_MILITARY_OVERVIEW then
        g_PopupInfo = popupInfo

        if g_PopupInfo.Data1 == 1 then
            if not ContextPtr:IsHidden() then
                OnClose()
            else
                UIManager:QueuePopup(ContextPtr, PopupPriority.InGameUtmost)
            end
        else
            UIManager:QueuePopup(ContextPtr, PopupPriority.MilitaryOverview)
        end
    end
end
Events.SerialEventGameMessagePopup.Add(OnPopup)

--====================================================================================================================
-- Close Handler
--====================================================================================================================
function OnClose()
    UIManager:DequeuePopup(ContextPtr)
end
Controls.CloseButton:RegisterCallback(Mouse.eLClick, OnClose)

--====================================================================================================================
-- Input Handler
--====================================================================================================================
function InputHandler(uiMsg, wParam, lParam)
    if uiMsg == KeyEvents.KeyDown then
        if wParam == Keys.VK_ESCAPE or wParam == Keys.VK_RETURN then
            OnClose()
            return true
        end
    end
end
ContextPtr:SetInputHandler(InputHandler)

--====================================================================================================================
-- Unit Click Handler
--====================================================================================================================
function UnitClicked(unitID)
    local selectedUnit = UI:GetHeadSelectedUnit()
    if selectedUnit and selectedUnit:GetID() == unitID then
        UI.LookAtSelectionPlot(0)
    else
        Events.SerialEventUnitFlagSelected(Game:GetActivePlayer(), unitID)
        BuildUnitList(unitID)
    end
end
Events.SerialEventUnitFlagSelected.Add(function() UI.LookAtSelectionPlot(0) end)

--====================================================================================================================
-- Update Screen
--====================================================================================================================
function UpdateScreen()
    local player = Players[Game.GetActivePlayer()]

    -- Update Great General Progress
    Controls.GPMeter:SetPercent(player:GetCombatExperience() / player:GreatGeneralThreshold())
    Controls.GPBox:LocalizeAndSetToolTip("TXT_KEY_MO_GENERAL_TT", player:GetCombatExperience(), player:GreatGeneralThreshold())

    -- Update Great Admiral Progress
    Controls.GAMeter:SetPercent(player:GetNavalCombatExperience() / player:GreatAdmiralThreshold())
    Controls.GABox:LocalizeAndSetToolTip("TXT_KEY_MO_ADMIRAL_TT", player:GetNavalCombatExperience(), player:GreatAdmiralThreshold())

    -- Update Supply Information
    Controls.HandicapSupplyValue:SetText(player:GetNumUnitsSuppliedByHandicap())
    Controls.CitiesSupplyValue:SetText(player:GetNumUnitsSuppliedByCities())
    Controls.PopulationSupplyValue:SetText(player:GetNumUnitsSuppliedByPopulation())
    Controls.SupplyCapValue:SetText(player:GetNumUnitsSupplied())
	if player._NumUnitsTotal then
		Controls.SupplyUseValue:SetText(player:_NumUnitsTotal())
	else
		Controls.SupplyUseValue:SetText(player:GetNumUnits())
	end

    local supplyDeficit = player:GetNumUnitsOutOfSupply()
    local inDeficit = supplyDeficit ~= 0

    Controls.SupplyRemaining:SetHide(inDeficit)
    Controls.SupplyDeficit:SetHide(not inDeficit)
    Controls.DeficitPenalty:SetHide(not inDeficit)

    if inDeficit then
        Controls.SupplyDeficitValue:SetText(supplyDeficit)
        Controls.SupplyDeficitPenaltyValue:SetText(player:GetUnitProductionMaintenanceMod() .. "%")
    else
		if player._NumUnitsTotal then
			Controls.SupplyRemainingValue:SetText(player:GetNumUnitsSupplied() - player:_NumUnitsTotal())
		else
			Controls.SupplyRemainingValue:SetText(player:GetNumUnitsSupplied() - player:GetNumUnits())
		end
    end

    BuildUnitList(UI:GetHeadSelectedUnit() and UI:GetHeadSelectedUnit():GetID())
end

--====================================================================================================================
-- Unit Status Text
--====================================================================================================================
function GetUnitStatus(unit)
    if unit._IsSealiftPending and unit:_IsSealiftPending() then
        return Locale.ConvertTextKey("TXT_KEY_GAIA_SEALIFT_IN_TRANSIT") .. " (" .. tostring(unit:_GetSealiftTurnsLeft()) .. ")"
    end
    if unit:IsEmbarked() then
        return Locale.ConvertTextKey("TXT_KEY_UNIT_STATUS_EMBARKED")
    elseif unit:IsGarrisoned() then
        return Locale.ConvertTextKey("TXT_KEY_MISSION_GARRISON")
    elseif unit:IsAutomated() then
        if unit:IsWork() then
            return Locale.ConvertTextKey("TXT_KEY_ACTION_AUTOMATE_BUILD")
        else
            return Locale.ConvertTextKey("TXT_KEY_ACTION_AUTOMATE_EXPLORE")
        end
    end

    local activityType = unit:GetActivityType()

    if activityType == ActivityTypes.ACTIVITY_HEAL then
        return Locale.ConvertTextKey("TXT_KEY_MISSION_HEAL")
    elseif activityType == ActivityTypes.ACTIVITY_SENTRY then
        return Locale.ConvertTextKey("TXT_KEY_MISSION_ALERT")
    elseif unit:GetFortifyTurns() > 0 then
        return Locale.ConvertTextKey("TXT_KEY_UNIT_STATUS_FORTIFIED")
    elseif activityType == ActivityTypes.ACTIVITY_SLEEP then
        return Locale.ConvertTextKey("TXT_KEY_MISSION_SLEEP")
    end

    -- Actively building something
    local buildType = unit:GetBuildType()
    if buildType ~= -1 then
        local build = GameInfo.Builds[buildType]
        local statusText = build and Locale.ConvertTextKey(build.Description) or ""
        local turnsLeft = unit:GetPlot():GetBuildTurnsLeft(buildType, Game.GetActivePlayer(), 0, 0)
        if turnsLeft > 0 and turnsLeft < 4000 then
            statusText = statusText .. " (" .. tostring(turnsLeft) .. ")"
        end
        return statusText
    end

    return nil
end

function GetSealiftToolTip(unit)
    if not (unit._IsSealiftPending and unit:_IsSealiftPending()) then
        return nil
    end
    local city = unit._GetSealiftCity and unit:_GetSealiftCity()
    local landingTurn = Game.GetGameTurn() + unit:_GetSealiftTurnsLeft()
    if city then
        return Locale.ConvertTextKey("TXT_KEY_GAIA_SEALIFT_IN_TRANSIT_TT", city:GetNameKey(), landingTurn)
    end
    return Locale.ConvertTextKey("TXT_KEY_GAIA_SEALIFT_IN_TRANSIT")
end

--====================================================================================================================
-- Build Unit List
--====================================================================================================================
function BuildUnitList(selectedUnitID)
    g_MilitaryUnitsManager:ResetInstances()
    g_CivilianUnitsManager:ResetInstances()
    g_SortTable = {}

    local player = Players[Game.GetActivePlayer()]
    local moveDenominator = GameDefines.MOVE_DENOMINATOR
    local foundMilitary, foundCivilian = false, false

    for unit in player:Units() do
        local isMilitary = unit:GetUnitCombatType() ~= -1 or unit:CanNuke()
        local instance = isMilitary and g_MilitaryUnitsManager:GetInstance() or g_CivilianUnitsManager:GetInstance()
        local unitID = unit:GetID()

        if isMilitary then
            foundMilitary = true
        else
            foundCivilian = true
        end

        -- Register Callbacks
        instance.Button:RegisterCallback(Mouse.eLClick, UnitClicked)
        instance.Button:SetVoid1(unitID)

        -- Set Unit Name and Tooltip
        local unitName = Locale.Lookup(unit:GetName())
        local unitType = Locale.Lookup(unit:GetNameKey())
        if unitName ~= unitType then
            unitName = unitName:sub(1, #unitName - #unitType - 3)
        end

        if unit:IsGreatPerson() then
            local unitTypeString = GameInfo.Units[unit:GetUnitType()].Type
            unitName = unitName .. " " .. (GreatPeopleIcons[unitTypeString] or "[?]")
        end

        instance.UnitName:SetText(unitName)
        instance.UnitName:SetToolTipString(unitType)

        -- Set Unit Health Bar
        local healthPercent = unit:GetCurrHitPoints() / unit:GetMaxHitPoints()
        instance.HealthBar:SetHide(healthPercent == 1)
        if healthPercent < 1 then
            local barSize = { x = math.floor(138 * healthPercent), y = 3 }
            instance.GreenBar:SetSize(barSize)
            instance.YellowBar:SetHide(healthPercent > 0.33)
            instance.RedBar:SetHide(healthPercent > 0.7)
        end

        -- Selection, Promotion and Dimming
        instance.SelectionFrame:SetHide(unitID ~= selectedUnitID)
        instance.PromotionIndicator:SetHide(not unit:CanPromote())
        instance.Button:SetAlpha(unit:MovesLeft() > 0 and 1.0 or 0.6)

        -- Set Status
        local statusText = GetUnitStatus(unit)
        instance.Status:SetHide(statusText == nil)
        instance.Status:SetText(statusText or "")
        instance.Status:SetToolTipString(GetSealiftToolTip(unit) or "")

        -- Set Experience
        local unitXP = unit:GetExperience()
        instance.UnitXP:SetText(unitXP)

        -- Set Movement Pip and Moves
        local movesLeft = math.floor(unit:MovesLeft() / moveDenominator)
        local maxMoves = math.floor(unit:MaxMoves() / moveDenominator)

        if movesLeft == maxMoves then
            instance.MovementPip:SetTextureOffsetVal(0, 0)
        elseif movesLeft == 0 then
            instance.MovementPip:SetTextureOffsetVal(0, 96)
        else
            instance.MovementPip:SetTextureOffsetVal(0, 32)
        end

        instance.Movement:SetText(movesLeft .. "/" .. maxMoves)

        -- Set Combat Strength
        local strength = unit:GetBaseCombatStrength()
        instance.Strength:SetText(strength > 0 and strength or "-")

        -- Set Ranged Combat Strength
        local ranged = unit:GetBaseRangedCombatStrength()
        instance.RangedAttack:SetText(ranged > 0 and ranged or "-")

        -- Add to Sort Table
        g_SortTable[tostring(instance.Root)] = {
            [eName] = unitName,
            [eStatus] = statusText or "",
            [eMovement] = movesLeft,
            [eMoves] = maxMoves,
            [eStrength] = strength,
            [eRanged] = ranged,
            [eUnitXP] = unitXP,
            Unit = unit
        }
    end

    Controls.CivilianSeperator:SetHide(not (foundMilitary and foundCivilian))

    Controls.MilitaryStack:CalculateSize()
    Controls.CivilianStack:CalculateSize()
    Controls.MainStack:CalculateSize()
    Controls.ScrollPanel:CalculateInternalSize()
end

--====================================================================================================================
-- Sorting and Sorting Callbacks
--====================================================================================================================
function OnSort(type)
    g_SortMode = type
    g_bSortReverse = not g_bSortReverse
    Controls.MilitaryStack:SortChildren(SortFunction)
    Controls.CivilianStack:SortChildren(SortFunction)
end

function SortFunction(a, b)
    local entryA, entryB = g_SortTable[tostring(a)], g_SortTable[tostring(b)]

    if entryA == nil or entryB == nil then
        if entryA and entryB == nil then
            return false
        elseif entryA == nil and entryB then
            return true
        elseif g_bSortReverse then
            return tostring(a) > tostring(b)
        else
            return tostring(a) < tostring(b)
        end
    end

    local valueA, valueB = entryA[g_SortMode], entryB[g_SortMode]

    if valueA == valueB then
        valueA = entryA.Unit:GetID()
        valueB = entryB.Unit:GetID()
    end

    if g_bSortReverse then
        return valueA > valueB
    else
        return valueA < valueB
    end
end

Controls.SortName:RegisterCallback(Mouse.eLClick, function() OnSort(eName) end)
Controls.SortStatus:RegisterCallback(Mouse.eLClick, function() OnSort(eStatus) end)
Controls.SortXP:RegisterCallback(Mouse.eLClick, function() OnSort(eUnitXP) end)
Controls.SortMovement:RegisterCallback(Mouse.eLClick, function() OnSort(eMovement) end)
Controls.SortMoves:RegisterCallback(Mouse.eLClick, function() OnSort(eMoves) end)
Controls.SortStrength:RegisterCallback(Mouse.eLClick, function() OnSort(eStrength) end)
Controls.SortRanged:RegisterCallback(Mouse.eLClick, function() OnSort(eRanged) end)

--====================================================================================================================
-- Show/Hide Handler
--====================================================================================================================
function ShowHideHandler(isHide, isInit)
    
	CivIconHookup( 0, 64, Controls.Icon, Controls.CivIconBG, Controls.CivIconShadow, false, true );

    if isInit then
        return
    end

    if not isHide then
        UI.incTurnTimerSemaphore()
        UpdateScreen()
        if g_PopupInfo then
            Events.SerialEventGameMessagePopupShown(g_PopupInfo)
        end
    else
        UI.decTurnTimerSemaphore()
        Events.SerialEventGameMessagePopupProcessed.CallImmediate(ButtonPopupTypes.BUTTONPOPUP_MILITARY_OVERVIEW, 0)
    end
end
ContextPtr:SetShowHideHandler(ShowHideHandler)
