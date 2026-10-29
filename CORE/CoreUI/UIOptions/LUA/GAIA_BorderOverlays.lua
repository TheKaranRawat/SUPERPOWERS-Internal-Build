--====================================================================================================================
-- BORDER OVERLAYS
--====================================================================================================================
include "FLuaVector"

OverlayColours = {
    Overlap   = Vector4(1.00, 0.60, 0.10, 0.45),
    DigSite   = Vector4(0.85, 0.25, 0.85, 0.50),
    DigTarget = Vector4(0.25, 0.85, 0.20, 0.50),
    Path      = Vector4(0.20, 0.80, 0.85, 0.45),
}

include "GAIA_DigSiteOverlay"

--====================================================================================================================
-- CONSTANTS AND STATE
--====================================================================================================================

local BORDER_CITY  = "MovementRangeBorder"
local BORDER_REACH = "GroupBorder"
local BORDER_PATH  = "MovementRangeBorder"

local RING_COLOUR = Vector4(1.0, 1.0, 1.0, 1.0)

local iGeneralClass = GameInfoTypes.UNITCLASS_GREAT_GENERAL
local iAdmiralClass = GameInfoTypes.UNITCLASS_GREAT_ADMIRAL
local iCommanderRange = GameDefines.GREAT_GENERAL_RANGE or 2
local DEFAULT_WORK_RANGE = 5
local NEIGHBOUR_SCAN_RANGE = 13

local iMapW = Map.GetGridSize()

local inCityScreen = false
local bFillsShown = false
local cityPlots = {}

--====================================================================================================================
-- USER PREFERENCES
--====================================================================================================================

local g_UserData = Modding.OpenUserData("GAIA_UIOptions", 1)
if not g_UserData then
    MapModData.GAIA_UIOptions = MapModData.GAIA_UIOptions or {}
    local t = MapModData.GAIA_UIOptions
    g_UserData = { GetValue = function(k) return t[k] end, SetValue = function(k, v) t[k] = v end }
end

local function OverlaysEnabled()
    return g_UserData.GetValue("MapOverlays") == 1
end

local function OverlayOn(sKey)
    return g_UserData.GetValue(sKey) ~= 0
end

--====================================================================================================================
-- CLEARING
--====================================================================================================================

local function ClearAllOverlays()
    Events.ClearHexHighlightStyle(BORDER_CITY)
    Events.ClearHexHighlightStyle(BORDER_REACH)
    if bFillsShown then
        Events.ClearHexHighlights()
        bFillsShown = false
    end
    cityPlots = {}
end

--====================================================================================================================
-- CITY LIMITS
--====================================================================================================================

local function GetCityWorkRange(pCity)
    return pCity._CityWorkRange and pCity:_CityWorkRange() or DEFAULT_WORK_RANGE
end

local function GetProspectiveWorkRange(pPlayer)
    local iRange = pPlayer._PlayerCityWorkRange and pPlayer:_PlayerCityWorkRange() or DEFAULT_WORK_RANGE
    if pPlayer:GetNumCities() == 0 then
        iRange = iRange + 1
    end
    return iRange
end

local function EachPlotInRange(iX, iY, iRange, fn)
    for iDX = -iRange, iRange do
        for iDY = -iRange, iRange do
            local pPlot = Map.GetPlotXY(iX, iY, iDX, iDY)
            if pPlot and Map.PlotDistance(iX, iY, pPlot:GetX(), pPlot:GetY()) <= iRange then
                fn(pPlot)
            end
        end
    end
end

local function RecordNeighbourCityPlots(pCenterPlot, pIgnoreCity)
    local iCenterX, iCenterY = pCenterPlot:GetX(), pCenterPlot:GetY()
    for _, pPlayer in pairs(Players) do
        if pPlayer:IsEverAlive() then
            for pCity in pPlayer:Cities() do
                if pCity ~= pIgnoreCity
                and Map.PlotDistance(iCenterX, iCenterY, pCity:GetX(), pCity:GetY()) <= NEIGHBOUR_SCAN_RANGE then
                    EachPlotInRange(pCity:GetX(), pCity:GetY(), GetCityWorkRange(pCity), function(pPlot)
                        cityPlots[pPlot:GetY() * iMapW + pPlot:GetX()] = true
                    end)
                end
            end
        end
    end
end

local function DrawWorkRange(iX, iY, iRange, sStyle)
    EachPlotInRange(iX, iY, iRange, function(pPlot)
        local hexID = ToHexFromGrid(Vector2(pPlot:GetX(), pPlot:GetY()))
        Events.SerialEventHexHighlight(hexID, true, RING_COLOUR, sStyle)
        if cityPlots[pPlot:GetY() * iMapW + pPlot:GetX()] then
            Events.SerialEventHexHighlight(hexID, true, OverlayColours.Overlap)
            bFillsShown = true
        end
    end)
end

local function ShowSettlerOverlay(pUnit)
    local pPlot = pUnit:GetPlot()
    RecordNeighbourCityPlots(pPlot, nil)
    DrawWorkRange(pPlot:GetX(), pPlot:GetY(), GetProspectiveWorkRange(Players[pUnit:GetOwner()]), BORDER_REACH)
end

local function ShowCityOverlay(pCity)
    RecordNeighbourCityPlots(pCity:Plot(), pCity)
    DrawWorkRange(pCity:GetX(), pCity:GetY(), GetCityWorkRange(pCity), BORDER_CITY)
end

local function IsCityFounder(pUnit)
    if pUnit:IsFound() then
        return true
    end
    local kUnitRow = GameInfo.Units{ ID = pUnit:GetUnitType() }()
    return kUnitRow and kUnitRow.FoundAbroad
end

--====================================================================================================================
-- COMMANDER INFLUENCE
--====================================================================================================================

local function ShowCommanderOverlay(pUnit, bWaterAura)
    EachPlotInRange(pUnit:GetX(), pUnit:GetY(), iCommanderRange, function(pPlot)
        if pPlot:IsCity() or pPlot:IsWater() == bWaterAura then
            Events.SerialEventHexHighlight(ToHexFromGrid(Vector2(pPlot:GetX(), pPlot:GetY())), true, RING_COLOUR, BORDER_REACH)
        end
    end)
end

--====================================================================================================================
-- MOVEMENT PATH
--====================================================================================================================

local function ShowMovementPath(pUnit)
    local pMissionPlot = pUnit:LastMissionPlot()
    if not pMissionPlot or (pUnit:GetX() == pMissionPlot:GetX() and pUnit:GetY() == pMissionPlot:GetY()) then
        return
    end

    if pUnit._GetActivePath then
        local path = pUnit:_GetActivePath()
        for i = 2, #path do
            local node = path[i]
            Events.SerialEventHexHighlight(ToHexFromGrid(Vector2(node.X, node.Y)), true, OverlayColours.Path)
            bFillsShown = true
        end
        if #path >= 2 then
            local dest = path[#path]
            Events.SerialEventHexHighlight(ToHexFromGrid(Vector2(dest.X, dest.Y)), true, RING_COLOUR, BORDER_PATH)
        end
    else
        local hexID = ToHexFromGrid(Vector2(pMissionPlot:GetX(), pMissionPlot:GetY()))
        Events.SerialEventHexHighlight(hexID, true, RING_COLOUR, BORDER_PATH)
        Events.GameplayFX(hexID.x, hexID.y, -1)
    end
end

--====================================================================================================================
-- DISPATCH AND EVENT HANDLERS
--====================================================================================================================

local function RefreshOverlays(pUnit)
    ClearAllOverlays()
    if not pUnit or not OverlaysEnabled() then
        return
    end

    if IsCityFounder(pUnit) then
        if OverlayOn("MapOverlays_CityLimits") then
            ShowSettlerOverlay(pUnit)
        end
        return
    end

    local iClass = pUnit:GetUnitClassType()
    if iClass == iGeneralClass then
        if OverlayOn("MapOverlays_Commander") then
            ShowCommanderOverlay(pUnit, false)
        end
    elseif iClass == iAdmiralClass then
        if OverlayOn("MapOverlays_Commander") then
            ShowCommanderOverlay(pUnit, true)
        end
    else
        local bDrewDig = false
        if OverlayOn("MapOverlays_DigSites") then
            local iDigSites = ShowDigSitesForUnit(Players[pUnit:GetOwner()], pUnit)
            if iDigSites then
                bFillsShown = bFillsShown or iDigSites > 0
                bDrewDig = true
            end
        end
        if not bDrewDig and OverlayOn("MapOverlays_MovementPath") then
            ShowMovementPath(pUnit)
        end
    end
end

-- City-View work-range ring
local function DrawCityLimitsForScreen()
    local pCity = UI.GetHeadSelectedCity()
    if pCity and OverlaysEnabled() and OverlayOn("MapOverlays_CityLimits") then
        ShowCityOverlay(pCity)
    end
end

local function RefreshCurrent()
    if inCityScreen then
        ClearAllOverlays()
        DrawCityLimitsForScreen()
    else
        RefreshOverlays(UI.GetHeadSelectedUnit())
    end
end
LuaEvents.GaiaMapOverlaysChanged.Add(RefreshCurrent)

local function OnUnitSelectionChanged(iPlayer, iUnit, _, _, _, bSelected)
    if inCityScreen then
        return
    end
    local pPlayer = Players[iPlayer]
    RefreshOverlays(bSelected and pPlayer and pPlayer:GetUnitByID(iUnit) or nil)
end
Events.UnitSelectionChanged.Add(OnUnitSelectionChanged)

local function OnUnitSelectionCleared()
    if inCityScreen then
        return
    end
    ClearAllOverlays()
end
Events.UnitSelectionCleared.Add(OnUnitSelectionCleared)

local function RefreshIfSelected(iPlayer, iUnit)
    if inCityScreen then
        return
    end
    local pSelected = UI.GetHeadSelectedUnit()
    if pSelected and pSelected:GetOwner() == iPlayer and pSelected:GetID() == iUnit then
        RefreshOverlays(pSelected)
    end
end

Events.SerialEventUnitMoveToHexes.Add(function(iPlayer, iUnit)
    RefreshIfSelected(iPlayer, iUnit)
end)

Events.SerialEventUnitTeleportedToHex.Add(function(_, _, iPlayer, iUnit)
    RefreshIfSelected(iPlayer, iUnit)
end)

local function OnUnitDestroyed(iPlayer, iUnit)
    if inCityScreen then
        return
    end
    local pSelected = UI.GetHeadSelectedUnit()
    if not pSelected or (pSelected:GetOwner() == iPlayer and pSelected:GetID() == iUnit) then
        ClearAllOverlays()
    end
end
Events.SerialEventUnitDestroyed.Add(OnUnitDestroyed)

local function OnEnterCityScreen()
    inCityScreen = true
    ClearAllOverlays()
    DrawCityLimitsForScreen()
end
Events.SerialEventEnterCityScreen.Add(OnEnterCityScreen)

local function OnExitCityScreen()
    inCityScreen = false
    ClearAllOverlays()
end
Events.SerialEventExitCityScreen.Add(OnExitCityScreen)
