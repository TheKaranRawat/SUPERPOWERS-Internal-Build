print("RangeDisplay: file start")

if not Vector2 then
    Vector2 = function(x, y) return { x = x, y = y } end
end
if not Vector4 then
    Vector4 = function(x, y, z, w) return { x = x, y = y, z = z, w = w } end
end

local STYLE = "FireRangeBorder"
local COLOR = Vector4(1, 0.3, 0.3, 1)
local HIGHLIGHT_OWN_TILE = true   -- extra highlight on the unit's own tile
local DEBUG = false

local RANGE_MODE = InterfaceModeTypes.INTERFACEMODE_RANGE_ATTACK
local SELECT_MODE = InterfaceModeTypes.INTERFACEMODE_SELECTION

local g_weSetMode = false   -- true only if this script entered the mode
local g_ownTileShown = false

------------------------------------------------------------
-- Helpers
------------------------------------------------------------
local function GetUnitRange(unit)
    if unit.Range then return unit:Range() end
    if unit.GetRange then return unit:GetRange() end
    return 0
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

-- Mirrors when the ranged attack button is usable
local function CanShowFor(unit)
    if unit.IsEmbarked and unit:IsEmbarked() then return false end
    if unit.IsOutOfAttacks and unit:IsOutOfAttacks() then return false end
    if unit.CanMove and not unit:CanMove() then return false end
    return true
end

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
-- Main
------------------------------------------------------------
local function EnterRangeMode(unit)
    local ok, err = pcall(UI.SetInterfaceMode, RANGE_MODE)
    if not ok then
        print("RangeDisplay: SetInterfaceMode failed: " .. tostring(err))
        return
    end
    g_weSetMode = true
    ShowOwnTile(unit)   -- after the mode, so the game's highlights don't wipe it
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

Events.UnitSelectionChanged.Add(function(playerID, unitID, i, j, k, isSelected)
    LeaveRangeMode()
    if not isSelected then return end
    if playerID ~= Game.GetActivePlayer() then return end
    if not Players[playerID]:IsTurnActive() then return end

    local unit = Players[playerID]:GetUnitByID(unitID)
    if unit and IsRangedUnit(unit) and CanShowFor(unit) then
        EnterRangeMode(unit)
    end
end)

-- If the player cancels or changes mode (right-click, attack, etc.), clean up
-- and do NOT re-enter until the unit is selected again
Events.InterfaceModeChanged.Add(function(oldMode, newMode)
    if newMode ~= RANGE_MODE then
        ClearOwnTile()
        g_weSetMode = false
    end
end)

print("RangeDisplay: file loaded")