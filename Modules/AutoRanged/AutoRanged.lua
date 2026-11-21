print("RangeDisplay: file start")

if not Vector2 then
    Vector2 = function(x, y) return { x = x, y = y } end
end
if not Vector4 then
    Vector4 = function(x, y, z, w) return { x = x, y = y, z = z, w = w } end
end

local STYLE = "FireRangeBorder"
local COLOR = Vector4(1, 0.3, 0.3, 1)
local HIGHLIGHT_OWN_TILE = true    -- extra highlight on the unit's own tile (land/sea ranged)
local INCLUDE_NONCOMBAT = true     -- count workers/settlers etc. as targets
local DEBUG = false

-- Aircraft circle
local AIR_STYLE = "FireRangeBorder"
local AIR_COLOR = Vector4(1, 0, 0, 1)
local AIR_RING_ONLY = false        -- true = highlight only the outer ring of hexes

local RANGE_MODE = InterfaceModeTypes.INTERFACEMODE_RANGE_ATTACK
local SELECT_MODE = InterfaceModeTypes.INTERFACEMODE_SELECTION

local g_weSetMode = false
local g_ownTileShown = false
local g_gameCheckBroken = false
local g_airShown = false
local g_airUnitID, g_airX, g_airY = nil, nil, nil

------------------------------------------------------------
-- Helpers
------------------------------------------------------------
local function GetUnitRange(unit)
    if unit.Range then return unit:Range() end
    if unit.GetRange then return unit:GetRange() end
    return 0
end

local function IsAirUnit(unit)
    return unit ~= nil and unit.GetDomainType ~= nil
        and unit:GetDomainType() == DomainTypes.DOMAIN_AIR
end

local function IsRangedUnit(unit)
    if not unit then return false end
    local ranged
    if unit.IsRanged then
        ranged = unit:IsRanged()
    elseif unit.GetBaseRangedCombatStrength then
        ranged = unit:GetBaseRangedCombatStrength() > 0
    else
        ranged = false
    end
    return ranged and GetUnitRange(unit) > 0
end

local function CanShowFor(unit)
    if unit.IsEmbarked and unit:IsEmbarked() then return false end
    if unit.IsOutOfAttacks and unit:IsOutOfAttacks() then return false end
    if unit.CanMove and not unit:CanMove() then return false end
    return true
end

------------------------------------------------------------
-- Aircraft range circle
------------------------------------------------------------
local function ClearAirRange()
    if g_airShown then
        g_airShown = false
        g_airUnitID, g_airX, g_airY = nil, nil, nil
        if Events.ClearHexHighlightStyle then
            Events.ClearHexHighlightStyle(AIR_STYLE)
        end
    end
end

local function ShowAirRange(unit)
    local x, y, range = unit:GetX(), unit:GetY(), GetUnitRange(unit)
    if range <= 0 then return end
    if g_airShown and g_airUnitID == unit:GetID() and g_airX == x and g_airY == y then return end
    ClearAirRange()
    g_airUnitID, g_airX, g_airY = unit:GetID(), x, y

    for dx = -range, range do
        for dy = -range, range do
            local plot = Map.PlotXYWithRangeCheck(x, y, dx, dy, range)
            if plot then
                local px, py = plot:GetX(), plot:GetY()
                local draw = true
                if AIR_RING_ONLY then
                    draw = Map.PlotDistance(x, y, px, py) == range
                end
                if draw then
                    local hex = ToHexFromGrid(Vector2(px, py))
                    local ok, err = pcall(Events.SerialEventHexHighlight, hex, true, AIR_COLOR, AIR_STYLE)
                    if not ok then
                        print("RangeDisplay: air highlight failed: " .. tostring(err))
                        return
                    end
                    g_airShown = true
                end
            end
        end
    end
end

------------------------------------------------------------
-- Target detection (land/sea ranged units)
------------------------------------------------------------
local function TileHasTarget(unit, plot)
    local px, py = plot:GetX(), plot:GetY()

    if unit.CanRangeStrikeAt and not g_gameCheckBroken then
        local ok, res = pcall(unit.CanRangeStrikeAt, unit, px, py, true, INCLUDE_NONCOMBAT)
        if ok then
            return res and true or false
        end
        g_gameCheckBroken = true
        print("RangeDisplay: CanRangeStrikeAt failed, using fallback: " .. tostring(res))
    end

    if plot.IsVisibleEnemyUnit and plot:IsVisibleEnemyUnit(unit:GetOwner()) then
        return true
    end
    if plot.IsEnemyCity and plot:IsEnemyCity(unit) then
        return true
    end
    return false
end

local function HasTargetInRange(unit)
    local x, y, range = unit:GetX(), unit:GetY(), GetUnitRange(unit)
    local team = Game.GetActiveTeam()

    for dx = -range, range do
        for dy = -range, range do
            local plot = Map.PlotXYWithRangeCheck(x, y, dx, dy, range)
            if plot and not (plot:GetX() == x and plot:GetY() == y) then
                if plot:IsVisible(team, false) and TileHasTarget(unit, plot) then
                    return true
                end
            end
        end
    end
    return false
end

------------------------------------------------------------
-- Own tile highlight
------------------------------------------------------------
local function ClearOwnTile()
    if g_ownTileShown then
        g_ownTileShown = false
        if Events.ClearHexHighlightStyle then
            Events.ClearHexHighlightStyle(STYLE)
        end
    end
end

local function ShowOwnTile(unit)
    if not HIGHLIGHT_OWN_TILE then return end
    local hex = ToHexFromGrid(Vector2(unit:GetX(), unit:GetY()))
    local ok, err = pcall(Events.SerialEventHexHighlight, hex, true, COLOR, STYLE)
    if ok then
        g_ownTileShown = true
    else
        print("RangeDisplay: own tile highlight failed: " .. tostring(err))
    end
end

------------------------------------------------------------
-- Ranged attack mode
------------------------------------------------------------
local function EnterRangeMode(unit)
    local ok, err = pcall(UI.SetInterfaceMode, RANGE_MODE)
    if not ok then
        print("RangeDisplay: SetInterfaceMode failed: " .. tostring(err))
        return
    end
    g_weSetMode = true
    ShowOwnTile(unit)
    if DEBUG then print("RangeDisplay: entered range mode") end
end

local function LeaveRangeMode()
    ClearOwnTile()
    if g_weSetMode then
        g_weSetMode = false
        if UI.GetInterfaceMode() == RANGE_MODE then
            UI.SetInterfaceMode(SELECT_MODE)
        end
    end
end

------------------------------------------------------------
-- Events
------------------------------------------------------------
Events.UnitSelectionChanged.Add(function(playerID, unitID, i, j, k, isSelected)
    ClearAirRange()
    LeaveRangeMode()
    if not isSelected then return end
    if playerID ~= Game.GetActivePlayer() then return end

    local unit = Players[playerID]:GetUnitByID(unitID)
    if not unit then return end

    -- Aircraft: red circle only, never ranged attack mode
    if IsAirUnit(unit) then
        ShowAirRange(unit)
        return
    end

    if not Players[playerID]:IsTurnActive() then return end
    if not IsRangedUnit(unit) or not CanShowFor(unit) then return end

    if HasTargetInRange(unit) then
        EnterRangeMode(unit)
    elseif DEBUG then
        print("RangeDisplay: no target in range, staying in normal mode")
    end
end)

-- Redraw the aircraft circle after rebasing, clear it if the selection is gone
Events.SerialEventUnitInfoDirty.Add(function()
    if not g_airShown then return end
    local unit = UI.GetHeadSelectedUnit()
    if IsAirUnit(unit) then
        ShowAirRange(unit)
    else
        ClearAirRange()
    end
end)

Events.InterfaceModeChanged.Add(function(oldMode, newMode)
    if newMode ~= RANGE_MODE then
        ClearOwnTile()
        g_weSetMode = false
    end
end)

print("RangeDisplay: file loaded")