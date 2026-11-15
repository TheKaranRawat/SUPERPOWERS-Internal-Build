-- GroupMove.lua : Ctrl+drag or Alt+drag box-select, right-click group dispatch,
-- hex highlight, alert-on-arrival and optional control groups.
--
-- MULTIPLAYER SAFETY
--  * UI side only. The script never sets unit positions or any game state.
--  * Every order (move, alert) goes through the engine's networked order
--    calls, one unit at a time, exactly like a manual order, so every client
--    receives the same commands.
--  * Orders are only issued while it is the player's turn, and only for the
--    active player's own units.
--  * Reads of other players' information are limited to what the player can
--    already see (destination tiles are only chosen from visible tiles).
--  * State is kept per player, so hotseat turn changes can't mix up units.
--
-- PERFORMANCE
--  * No polling. Everything runs from input, selection or unit events.
--  * The per-frame callback is only installed while there is deferred work
--    (a highlight redraw or an arrival check) and removes itself afterward.
--  * Refreshes are coalesced to at most one per frame, and the highlight is
--    only redrawn when the set of occupied tiles actually changed.
--  * Mouse moves cost one comparison unless a box is being dragged.
--
-- The script keeps its own "logical" group (state.selected). The engine may
-- only be able to highlight one unit at a time, so the group is NOT read back
-- from the engine's selection; it is set by box select / recall and cleared
-- when YOU pick something else (engine-driven selection changes are ignored).

-- Speculative: some builds define Vector2 in this helper. If it isn't there,
-- the call fails harmlessly and the script uses fallbacks.
pcall(include, "MathHelpers")

----------------------------------------------------------------
-- Config
----------------------------------------------------------------
local MAX_GROUPS       = 9
local KEY_1            = 49    -- virtual-key code for '1'
local DRAG_THRESHOLD   = 6     -- pixels before a press becomes a drag
local MILITARY_ONLY    = true  -- box-select skips workers, settlers, etc.
local REQUIRE_BOTH     = false -- false: Ctrl OR Alt alone starts a box select
                               -- true: both must be held together
local CLICK_CANCELS    = true  -- a plain left click deselects a multi-unit group
local ALERT_AFTER_MOVE = true  -- put units on alert when the group finishes moving
local SPREAD_UNITS     = true  -- units from different tiles get different destinations
local SPREAD_RADIUS    = 4     -- how far from the clicked hex to look for free tiles
local MAX_TRACK_TURNS  = 5     -- stop watching a dispatched group after this many turns
local HIGHLIGHT        = true  -- light up the hex under every unit in the group
local HL_COLOR         = { 1.0, 0.9, 0.5, 1.0 }   -- r, g, b, a (0 to 1)
local HL_STYLE         = nil   -- optional highlight style name passed to the game
local DEBUG            = true  -- writes key events to Lua.log
local DEBUG_VERBOSE    = false -- also logs routine events (can be noisy)

local function Log(msg)
    if DEBUG then print("GroupMove: " .. msg) end
end

----------------------------------------------------------------
-- Cached message ids
----------------------------------------------------------------
local MSG_LDOWN = MouseEvents.LButtonDown
local MSG_LUP   = MouseEvents.LButtonUp
local MSG_RDOWN = MouseEvents.RButtonDown
local MSG_RUP   = MouseEvents.RButtonUp
local MSG_MOVE  = MouseEvents.MouseMove
local MSG_KEY   = KeyEvents.KeyDown

----------------------------------------------------------------
-- State (kept per player so hotseat turn changes can't mix up unit IDs)
----------------------------------------------------------------
local state = {}               -- state[playerID] = { groups, selected, moveTrack }

local function GetState(playerID)
    local s = state[playerID]
    if not s then
        s = { groups = {}, selected = {} }
        for n = 1, MAX_GROUPS do s.groups[n] = {} end
        state[playerID] = s
    end
    return s
end

local guard    = false         -- true while WE change the engine's selection
local boxing   = false         -- a modifier-held press is in progress
local dragging = false         -- passed the drag threshold
local startX, startY = 0, 0    -- screen position at mouse-down
local startHexX, startHexY     -- hex under cursor at mouse-down (fallback)

local clickTracking = false    -- plain left press that may become a cancel-click
local clickX, clickY = 0, 0    -- screen position of that press

local rDown = false            -- right button currently held
local rStartX, rStartY = 0, 0  -- screen position at right mouse-down

local userAction = false       -- true for one frame after a left click or key press

local function CountSet(set, limit)
    local count = 0
    for _ in pairs(set) do
        count = count + 1
        if limit and count >= limit then break end
    end
    return count
end

-- True when two or more units are in the logical group
local function HasGroupSelected()
    return CountSet(GetState(Game.GetActivePlayer()).selected, 2) >= 2
end

-- Orders can only be issued on the player's own turn
local function CanIssueOrders(player)
    if player.IsTurnActive and not player:IsTurnActive() then return false end
    return true
end

----------------------------------------------------------------
-- Hex highlight (visual only)
----------------------------------------------------------------
-- Draws the game's hex overlay under each grouped unit. If the game's Vector2,
-- Vector4 or ToHexFromGrid are missing, small built-in versions are used.
local hlAvailable = nil         -- nil = untested, true = works, false = off
local litHex = {}               -- litHex[key] = hex position currently lit
local litCount = 0
local hlColor = nil

local function MakeVec2(x, y)
    if Vector2 then return Vector2(x, y) end
    return { x = x, y = y }
end

local function MakeVec4(x, y, z, w)
    if Vector4 then return Vector4(x, y, z, w) end
    return { x = x, y = y, z = z, w = w }
end

-- Plot grid coordinates to the hex coordinates the highlight event expects
local function MakeHex(gx, gy)
    if ToHexFromGrid then return ToHexFromGrid(MakeVec2(gx, gy)) end
    return { x = gx - (gy - (gy % 2)) / 2, y = gy }
end

local function SetHexHighlight(hex, on, color)
    if HL_STYLE then
        Events.SerialEventHexHighlight(hex, on, color, HL_STYLE)
    else
        Events.SerialEventHexHighlight(hex, on, color)
    end
end

local function CheckHighlight()
    if hlAvailable == nil then
        if not HIGHLIGHT then
            hlAvailable = false
        elseif not (Events and Events.SerialEventHexHighlight) then
            hlAvailable = false
            Log("hex highlight unavailable: Events.SerialEventHexHighlight is missing")
        else
            hlAvailable = true
            hlColor = MakeVec4(HL_COLOR[1], HL_COLOR[2], HL_COLOR[3], HL_COLOR[4])
            local substituted = {}
            if not Vector2 then substituted[#substituted + 1] = "Vector2" end
            if not Vector4 then substituted[#substituted + 1] = "Vector4" end
            if not ToHexFromGrid then substituted[#substituted + 1] = "ToHexFromGrid" end
            if #substituted > 0 then
                Log("hex highlight available, using built-in versions of: " .. table.concat(substituted, ", "))
            else
                Log("hex highlight available")
            end
        end
    end
    return hlAvailable
end

-- Redraws the highlight. Unless forced, nothing happens when the set of
-- occupied tiles is unchanged. A forced refresh redraws everything, which
-- also repairs tiles the game may have cleared itself after a selection change.
local function RefreshHighlights(force)
    if not CheckHighlight() then return end

    local pid = Game.GetActivePlayer()
    local s = GetState(pid)

    local want, wantCount = {}, 0
    if CountSet(s.selected, 2) >= 2 then
        local player = Players[pid]
        for id in pairs(s.selected) do
            local unit = player:GetUnitByID(id)
            if unit and not unit:IsDelayedDeath() then
                local ux, uy = unit:GetX(), unit:GetY()
                local key = ux * 1024 + uy
                if not want[key] then
                    want[key] = { ux, uy }
                    wantCount = wantCount + 1
                end
            end
        end
    end

    if not force and wantCount == litCount then
        local same = true
        for key in pairs(want) do
            if not litHex[key] then same = false break end
        end
        if same then return end
    end

    for _, hex in pairs(litHex) do
        SetHexHighlight(hex, false, hlColor)
    end
    litHex, litCount = {}, 0

    for key, xy in pairs(want) do
        local hex = MakeHex(xy[1], xy[2])
        SetHexHighlight(hex, true, hlColor)
        litHex[key] = hex
        litCount = litCount + 1
    end
    if DEBUG_VERBOSE then Log("highlighted " .. litCount .. " tiles") end
end

----------------------------------------------------------------
-- Deferred work: highlight redraws, arrival checks, "was that the user?"
----------------------------------------------------------------
local hlDirty = false
local hlForce = false
local refreshing = false
local moveTrackActive = false   -- a dispatched group is being watched for arrival
local moveCheckDirty = false
local updateInstalled = false

local QueueRefresh              -- forward declarations, assigned below
local OnFrameUpdate

-- Sends the Alert (sentry) order to each unit. Like the move orders, it goes
-- through the engine's networked mission message, one unit at a time.
local function SetAlert(units)
    if not (MissionTypes and MissionTypes.MISSION_ALERT
            and GameMessageTypes and Game.SelectionListGameNetMessage) then
        error("alert mission or message API not available")
    end
    guard = true
    for _, unit in ipairs(units) do
        UI.ClearSelectionList()
        UI.SelectUnit(unit)
        Game.SelectionListGameNetMessage(GameMessageTypes.GAMEMESSAGE_PUSH_MISSION,
                                         MissionTypes.MISSION_ALERT, 0, 0, 0, false, false)
    end
    guard = false
end

-- After a dispatch, watches the group and drops it once movement is over.
-- A unit counts as "still going" while it has a mission running and hasn't
-- reached its destination. The group is dropped when none are still going
-- (after at least one was seen going, or when all have arrived). Watching
-- stops by itself after MAX_TRACK_TURNS turns.
local function CheckMovementComplete()
    local pid = Game.GetActivePlayer()
    local s = GetState(pid)
    local t = s.moveTrack
    if not t then
        moveTrackActive = false
        return
    end

    if Game.GetGameTurn() - t.turn > MAX_TRACK_TURNS then
        s.moveTrack = nil
        moveTrackActive = false
        Log("stopped watching the group (took too long), selection kept")
        return
    end

    local player = Players[pid]
    local tracked, arrived, going = 0, 0, 0
    for id, d in pairs(t.dest) do
        if s.selected[id] then
            local unit = player:GetUnitByID(id)
            if unit and not unit:IsDelayedDeath() then
                tracked = tracked + 1
                if unit:GetX() == d.x and unit:GetY() == d.y then
                    arrived = arrived + 1
                elseif ActivityTypes
                       and unit:GetActivityType() == ActivityTypes.ACTIVITY_MISSION then
                    going = going + 1
                end
            end
        end
    end

    if going > 0 then
        t.sawBusy = true
        return
    end
    if tracked > 0 and not t.sawBusy and arrived < tracked then
        return                          -- orders may not have registered yet
    end

    -- Movement is over: put the military units on alert where they stopped
    -- (only on our own turn, since orders are rejected otherwise)
    if ALERT_AFTER_MOVE and CanIssueOrders(player) then
        local alertUnits = {}
        for id in pairs(t.dest) do
            if s.selected[id] then
                local unit = player:GetUnitByID(id)
                if unit and not unit:IsDelayedDeath() and unit:IsCombatUnit() then
                    alertUnits[#alertUnits + 1] = unit
                end
            end
        end
        if #alertUnits > 0 then
            local aok, aerr = pcall(SetAlert, alertUnits)
            guard = false
            if aok then
                Log("set " .. #alertUnits .. " units to alert")
            else
                Log("alert failed: " .. tostring(aerr))
            end
        end
    end

    -- Then drop the group (and the engine's selection too, but
    -- only if it is still showing one of our units)
    local ok, head = pcall(UI.GetHeadSelectedUnit)
    if ok and head and s.selected[head:GetID()] then
        guard = true
        pcall(UI.ClearSelectionList)
        guard = false
    end
    s.selected = {}
    s.moveTrack = nil
    moveTrackActive = false
    Log("movement complete, group cleared")
    QueueRefresh(true)
end

local function ClearUpdateNow() ContextPtr:ClearUpdate() end
local function SetUpdateNow()   ContextPtr:SetUpdate(OnFrameUpdate) end

OnFrameUpdate = function()
    updateInstalled = false
    pcall(ClearUpdateNow)
    userAction = false

    if moveCheckDirty then
        moveCheckDirty = false
        local ok, err = pcall(CheckMovementComplete)
        if not ok then
            moveTrackActive = false
            Log("movement check error: " .. tostring(err))
        end
    end

    if hlDirty then
        local force = hlForce
        hlDirty, hlForce = false, false
        refreshing = true
        local ok, err = pcall(RefreshHighlights, force)
        refreshing = false
        if not ok then
            hlAvailable = false
            Log("hex highlight error, disabled: " .. tostring(err))
        end
    end
end

-- Installs the per-frame callback once; it removes itself when it has run
local function InstallUpdate()
    if updateInstalled then return end
    updateInstalled = true
    if not pcall(SetUpdateNow) then updateInstalled = false end
end

QueueRefresh = function(force)
    if hlAvailable == false then return end
    hlDirty = true
    if force then hlForce = true end
    InstallUpdate()
end

local function QueueMoveCheck()
    moveCheckDirty = true
    InstallUpdate()
end

-- Marks the next engine selection change as caused by the user
local function MarkUserAction()
    userAction = true
    InstallUpdate()
end

-- Keep the highlight and the arrival check up to date as units move. Both
-- hooks do nothing unless a highlight or a watched dispatch is active.
if Events.SerialEventUnitInfoDirty then
    Events.SerialEventUnitInfoDirty.Add(function()
        if refreshing then return end
        if litCount > 0 then QueueRefresh(false) end
        if moveTrackActive then QueueMoveCheck() end
    end)
end
if Events.ActivePlayerTurnStart then
    Events.ActivePlayerTurnStart.Add(function()
        -- Also covers hotseat: the new active player gets their own highlight
        if litCount > 0 then QueueRefresh(true) end
        if moveTrackActive then QueueMoveCheck() end
    end)
end

----------------------------------------------------------------
-- Selection tracking (event driven, no polling)
----------------------------------------------------------------
-- Events we cause ourselves are ignored (guard). Selection changes the game
-- makes on its own, such as auto-advancing to the next unit after an order,
-- are ignored too, so they can't silently drop the group. Only a change that
-- follows a left click or key press collapses the group to what the user
-- picked (Shift adds instead).
local function OnSelectionChanged(playerID, unitID, i, j, k, isSelected)
    if guard then return end
    if playerID ~= Game.GetActivePlayer() then return end
    if not userAction then
        if DEBUG_VERBOSE then
            Log("ignored engine-driven selection change for unit " .. tostring(unitID))
        end
        return
    end
    local s = GetState(playerID)
    if isSelected then
        if UIManager:GetShift() then
            s.selected[unitID] = true
        else
            s.selected = { [unitID] = true }
        end
    elseif s.selected[unitID] and CountSet(s.selected, 2) < 2 then
        s.selected[unitID] = nil
    end
    s.moveTrack = nil
    QueueRefresh(true)
end
if Events.UnitSelectionChanged then
    Events.UnitSelectionChanged.Add(OnSelectionChanged)
end

local function OnUnitDestroyed(playerID, unitID)
    if playerID ~= Game.GetActivePlayer() then return end
    local s = GetState(playerID)
    local wasSelected = s.selected[unitID]
    s.selected[unitID] = nil
    for n = 1, MAX_GROUPS do s.groups[n][unitID] = nil end
    if wasSelected then QueueRefresh(true) end
end
if Events.SerialEventUnitDestroyed then
    Events.SerialEventUnitDestroyed.Add(OnUnitDestroyed)
end

----------------------------------------------------------------
-- Control groups (optional)
----------------------------------------------------------------
local function AssignGroup(n)
    local s = GetState(Game.GetActivePlayer())
    if next(s.selected) == nil then return end
    local g = {}
    for id in pairs(s.selected) do
        g[id] = true
        for m = 1, MAX_GROUPS do            -- a unit belongs to one group only
            if m ~= n then s.groups[m][id] = nil end
        end
    end
    s.groups[n] = g
end

local function RecallGroup(n)
    local pid = Game.GetActivePlayer()
    local s = GetState(pid)
    local g = s.groups[n]
    if next(g) == nil then return false end
    local player = Players[pid]

    guard = true
    UI.ClearSelectionList()
    local recalled = {}
    for id in pairs(g) do
        local unit = player:GetUnitByID(id)
        if unit and not unit:IsDelayedDeath() then
            UI.SelectUnit(unit)
            recalled[id] = true
        else
            g[id] = nil                     -- lazy prune (safe during pairs)
        end
    end
    guard = false

    if next(recalled) == nil then return false end
    s.selected = recalled
    s.moveTrack = nil
    QueueRefresh(true)
    return true
end

----------------------------------------------------------------
-- Selection box visual
----------------------------------------------------------------
local function DrawBox(x1, y1, x2, y2)
    Controls.SelBox:SetOffsetVal(math.min(x1, x2), math.min(y1, y2))
    Controls.SelBox:SetSizeVal(math.abs(x2 - x1), math.abs(y2 - y1))
    Controls.SelBox:SetHide(false)
end

local function HideBox()
    Controls.SelBox:SetHide(true)
end

----------------------------------------------------------------
-- Box select (runs once, on mouse release)
----------------------------------------------------------------
local function Eligible(unit)
    if unit:IsDelayedDeath() then return false end
    if MILITARY_ONLY and not unit:IsCombatUnit() then return false end
    return true
end

-- Screen-space pass. These globals can differ between builds, so the whole
-- pass runs inside a single pcall (see BoxSelect) instead of one per unit.
local function CollectScreen(player, left, top, right, bottom)
    local picked = {}
    for unit in player:Units() do
        if Eligible(unit) then
            local world = HexToWorld(ToHexFromGrid(Vector2(unit:GetX(), unit:GetY())))
            local sx, sy = WorldPositionToScreenXY(world)
            if sx >= left and sx <= right and sy >= top and sy <= bottom then
                picked[#picked + 1] = unit
            end
        end
    end
    return picked
end

-- Fallback: bounding box in hex coordinates (less accurate near the edges)
local function CollectHex(player)
    local picked = {}
    local endHexX, endHexY = UI.GetMouseOverHex()
    if not (startHexX and endHexX) then return picked end
    local xMin, xMax = math.min(startHexX, endHexX), math.max(startHexX, endHexX)
    local yMin, yMax = math.min(startHexY, endHexY), math.max(startHexY, endHexY)
    for unit in player:Units() do
        if Eligible(unit) then
            local ux, uy = unit:GetX(), unit:GetY()
            if ux >= xMin and ux <= xMax and uy >= yMin and uy <= yMax then
                picked[#picked + 1] = unit
            end
        end
    end
    return picked
end

local screenOK = nil           -- nil = untested, true = works, false = use hex box

local function BoxSelect(x1, y1, x2, y2, addToSelection)
    local left,  right  = math.min(x1, x2), math.max(x1, x2)
    local top,   bottom = math.min(y1, y2), math.max(y1, y2)
    local pid = Game.GetActivePlayer()
    local player = Players[pid]

    local picked
    if screenOK ~= false then
        local ok, result = pcall(CollectScreen, player, left, top, right, bottom)
        if ok then
            screenOK = true
            picked = result
        else
            screenOK = false
            Log("screen projection unavailable (" .. tostring(result) .. "), using hex box from now on")
        end
    end
    if not picked then picked = CollectHex(player) end
    Log("box picked " .. #picked .. " units")

    if #picked == 0 then return false end

    local s = GetState(pid)
    guard = true
    if not addToSelection then
        UI.ClearSelectionList()
        s.selected = {}
        s.moveTrack = nil
    end
    for _, unit in ipairs(picked) do
        UI.SelectUnit(unit)
        s.selected[unit:GetID()] = true
    end
    guard = false
    QueueRefresh(true)
    return true
end

----------------------------------------------------------------
-- Group dispatch (runs once per right-click, only with 2+ units selected)
----------------------------------------------------------------

-- True if the tile has a unit the player can see on it
local function TileHasVisibleUnit(plot, team)
    for i = 0, plot:GetNumUnits() - 1 do
        local u = plot:GetUnit(i)
        if u then
            local hidden = u.IsInvisible and u:IsInvisible(team, false)
            if not hidden then return true end
        end
    end
    return false
end

-- A free tile that any unit could plausibly stand on. Only tiles the player
-- can currently see are considered, so nothing hidden influences the choice.
local function GenericTileOk(plot, team)
    if plot:IsImpassable() or plot:IsMountain() then return false end
    if not plot:IsVisible(team, false) then return false end
    if plot:IsCity() then return false end
    if TileHasVisibleUnit(plot, team) then return false end
    return true
end

local function DomainOk(plot, unit)
    local d = unit:GetDomainType()
    if d == DomainTypes.DOMAIN_SEA then return plot:IsWater() end
    if d == DomainTypes.DOMAIN_LAND then return not plot:IsWater() end
    return false                            -- air etc.: no spreading
end

-- Groups units by the tile they start on. Units sharing a tile get the SAME
-- destination (so they travel together); units on different tiles get
-- DIFFERENT destinations. The nearest group takes the clicked hex itself and
-- the others take free tiles around it.
local function AssignDestinations(units, plot)
    local clusters, byKey = {}, {}
    for _, e in ipairs(units) do
        local ux, uy = e.unit:GetX(), e.unit:GetY()
        local key = ux * 1024 + uy
        local c = byKey[key]
        if not c then
            c = { x = ux, y = uy, dist = e.dist, units = {}, dest = plot }
            byKey[key] = c
            clusters[#clusters + 1] = c
        end
        c.units[#c.units + 1] = e
    end
    table.sort(clusters, function(a, b) return a.dist < b.dist end)

    local need = #clusters - 1
    if need <= 0 or not SPREAD_UNITS then return clusters end

    -- Free tiles around the target, nearest rings first
    local team = Game.GetActiveTeam()
    local px, py = plot:GetX(), plot:GetY()
    local pool = {}
    local want = need * 2 + 4
    for r = 1, SPREAD_RADIUS do
        for x = px - r, px + r do
            for y = py - r, py + r do
                if Map.PlotDistance(px, py, x, y) == r then
                    local p = Map.GetPlot(x, y)
                    if p and GenericTileOk(p, team) then
                        pool[#pool + 1] = { p = p, x = x, y = y, ring = r }
                    end
                end
            end
        end
        if #pool >= want then break end
    end

    -- Each group (nearest first) takes the free tile that is close to both
    -- itself and the target, so the formation stays compact
    local taken = {}
    for ci = 2, #clusters do
        local c = clusters[ci]
        local lead = c.units[1].unit
        local best, bestScore, bestIdx
        for pi = 1, #pool do
            if not taken[pi] then
                local e = pool[pi]
                if DomainOk(e.p, lead) then
                    local score = Map.PlotDistance(c.x, c.y, e.x, e.y) + e.ring
                    if not bestScore or score < bestScore then
                        best, bestScore, bestIdx = e.p, score, pi
                    end
                end
            end
        end
        if best then
            c.dest = best
            taken[bestIdx] = true
        else
            Log("no free tile for the group starting at " .. c.x .. "," .. c.y .. ", sending it to the target")
        end
    end
    return clusters
end

local function DispatchMove(plot, alt, shift, ctrl)
    local pid = Game.GetActivePlayer()
    local player = Players[pid]
    local s = GetState(pid)

    if not CanIssueOrders(player) then
        Log("dispatch skipped, it is not your turn")
        return false
    end

    local px, py = plot:GetX(), plot:GetY()
    local units = {}
    for id in pairs(s.selected) do
        local unit = player:GetUnitByID(id)
        if unit and not unit:IsDelayedDeath() then
            units[#units + 1] = {
                unit = unit,
                id   = id,
                dist = Map.PlotDistance(unit:GetX(), unit:GetY(), px, py),
            }
        end
    end
    if #units < 2 then
        Log("dispatch skipped, only " .. #units .. " live units in group")
        return false                        -- let the engine handle single units
    end

    -- Nearest units are ordered first so they claim the front tiles
    table.sort(units, function(a, b) return a.dist < b.dist end)

    local ok, clusters = pcall(AssignDestinations, units, plot)
    if not ok then
        Log("destination spread failed (" .. tostring(clusters) .. "), sending everyone to the target")
        clusters = { { dest = plot, units = units } }
    end

    Log("dispatching " .. #units .. " units in " .. #clusters .. " tile group(s) toward " .. px .. "," .. py)

    -- The order loop runs in a pcall so the guard flag can never stay set
    local sent, err = pcall(function()
        guard = true
        for _, c in ipairs(clusters) do
            for _, e in ipairs(c.units) do
                UI.ClearSelectionList()
                UI.SelectUnit(e.unit)
                Game.SelectionListMove(c.dest, alt, shift, ctrl)
            end
        end

        -- Restore the group as the visible selection (best effort)
        UI.ClearSelectionList()
        for _, e in ipairs(units) do
            UI.SelectUnit(e.unit)
        end
    end)
    guard = false
    if not sent then
        Log("ERROR while sending orders: " .. tostring(err))
        return true                         -- orders may be partly sent; don't double-send
    end

    local keep = {}
    for _, e in ipairs(units) do keep[e.id] = true end
    s.selected = keep

    -- Watch the group so it can be dropped once everyone has arrived
    local dest = {}
    for _, c in ipairs(clusters) do
        local dx, dy = c.dest:GetX(), c.dest:GetY()
        for _, e in ipairs(c.units) do dest[e.id] = { x = dx, y = dy } end
    end
    s.moveTrack = { dest = dest, sawBusy = false, turn = Game.GetGameTurn() }
    moveTrackActive = true
    QueueMoveCheck()
    QueueRefresh(true)
    return true
end

----------------------------------------------------------------
-- Input
----------------------------------------------------------------
-- True if the unit the game currently has selected belongs to our group.
-- If the player picked a different unit some way we couldn't see (a unit
-- banner, the unit panel), the group is stale and must not hijack right-click.
local function GroupMatchesEngineSelection()
    local ok, head = pcall(UI.GetHeadSelectedUnit)
    if not ok then return true end          -- can't tell, assume it matches
    if not head then return false end
    return GetState(Game.GetActivePlayer()).selected[head:GetID()] ~= nil
end

local function BoxModifierHeld()
    local ctrl, alt = UIManager:GetControl(), UIManager:GetAlt()
    if REQUIRE_BOTH then return ctrl and alt end
    return ctrl or alt
end

local function InputHandlerImpl(uiMsg, wParam)

    -- Mouse. Without the modifier(s) nothing here is swallowed, so normal
    -- clicks and left-drag map panning behave exactly as before.
    if uiMsg == MSG_LDOWN then
        if BoxModifierHeld() then
            boxing, dragging = true, false
            startX, startY = UIManager:GetMousePos()
            startHexX, startHexY = UI.GetMouseOverHex()
            return true            -- swallow so the map doesn't pan
        end
        boxing = false
        MarkUserAction()
        clickTracking = CLICK_CANCELS and not UIManager:GetShift() and HasGroupSelected()
        if clickTracking then clickX, clickY = UIManager:GetMousePos() end
        return false

    elseif uiMsg == MSG_MOVE then
        if boxing then
            local x, y = UIManager:GetMousePos()
            if not dragging
               and (math.abs(x - startX) > DRAG_THRESHOLD
                    or math.abs(y - startY) > DRAG_THRESHOLD) then
                dragging = true
            end
            if dragging then DrawBox(startX, startY, x, y) end
            return true
        end
        return false

    elseif uiMsg == MSG_LUP then
        if boxing then
            local wasDragging = dragging
            boxing, dragging = false, false
            HideBox()
            if wasDragging then
                local x, y = UIManager:GetMousePos()
                BoxSelect(startX, startY, x, y, UIManager:GetShift())
            end
            return true
        end

        MarkUserAction()

        -- Plain click (not a drag) while a group is selected: cancel it.
        -- The click still passes through; we only clear if the group is still
        -- the logical selection, so clicking a unit keeps that new selection.
        if clickTracking then
            clickTracking = false
            local x, y = UIManager:GetMousePos()
            if math.abs(x - clickX) <= DRAG_THRESHOLD
               and math.abs(y - clickY) <= DRAG_THRESHOLD
               and HasGroupSelected() then
                guard = true
                UI.ClearSelectionList()
                guard = false
                local s = GetState(Game.GetActivePlayer())
                s.selected = {}
                s.moveTrack = nil
                QueueRefresh(true)
            end
        end
        return false

    -- Right-click: with 2+ units in the group, send them all to the clicked
    -- hex. Right-drags (map panning) and single-unit orders pass through.
    elseif uiMsg == MSG_RDOWN then
        rDown = true
        rStartX, rStartY = UIManager:GetMousePos()
        return false

    elseif uiMsg == MSG_RUP then
        if not rDown then return false end
        rDown = false
        local x, y = UIManager:GetMousePos()
        if math.abs(x - rStartX) > DRAG_THRESHOLD
           or math.abs(y - rStartY) > DRAG_THRESHOLD then
            return false
        end
        if not HasGroupSelected() then
            if DEBUG_VERBOSE then Log("right-click passed to engine, no group selected") end
            return false
        end
        if not GroupMatchesEngineSelection() then
            Log("group dropped: the selected unit is not part of it")
            local s = GetState(Game.GetActivePlayer())
            s.selected = {}
            s.moveTrack = nil
            QueueRefresh(true)
            return false                -- let the engine move the selected unit
        end
        local hx, hy = UI.GetMouseOverHex()
        local plot = hx and Map.GetPlot(hx, hy)
        if not plot then
            Log("right-click ignored, no plot under cursor")
            return false
        end
        return DispatchMove(plot, UIManager:GetAlt(), UIManager:GetShift(), UIManager:GetControl())

    -- Keyboard: Ctrl+1..9 assigns, 1..9 recalls
    elseif uiMsg == MSG_KEY then
        MarkUserAction()
        local n = wParam - KEY_1 + 1
        if n < 1 or n > MAX_GROUPS then return false end
        if UIManager:GetControl() then
            AssignGroup(n)
            return true
        end
        if not UIManager:GetShift() and not UIManager:GetAlt() then
            return RecallGroup(n)
        end
    end

    return false
end

-- Any error is logged and every transient flag is reset, so one failure can
-- never leave the script stuck in a half-finished state.
local function InputHandler(uiMsg, wParam, lParam)
    -- Fast path: mouse moves are by far the most frequent message
    if uiMsg == MSG_MOVE and not boxing then return false end

    local ok, result = pcall(InputHandlerImpl, uiMsg, wParam)
    if ok then return result end
    Log("ERROR in input handler: " .. tostring(result))
    guard, boxing, dragging, clickTracking, rDown = false, false, false, false, false
    pcall(HideBox)
    return false
end
ContextPtr:SetInputHandler(InputHandler)