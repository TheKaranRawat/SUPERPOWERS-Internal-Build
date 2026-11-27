--=============================================================================
-- REFUGEE SETTLERS  (Civ V: Brave New World / Gods & Kings)
--
-- 1. A city attacked by an enemy on 2 consecutive turns loses 2 population and
--    spawns a refugee unit ("<City> Refugees") on a nearby empty land tile.
--    The unit type is configurable (CFG.REFUGEE_UNIT), default UNIT_SETTLER.
-- 2. The unit is moved by this script to the nearest city every turn and is
--    locked (0 moves left after the script moves it) so neither human nor AI
--    can give it orders.
-- 3. Within 1 tile of the destination city the unit is removed and the city
--    gains 2 population.
-- 4. Works for humans and AI (major civs).
-- 5. Human owners get a notification when refugees leave and when they arrive.
-- 6. Human attackers get a notification when their siege forces refugees out.
--
-- MULTIPLAYER NOTES
--   * INSTALL AS A GAMEPLAY SCRIPT: in ModBuddy set the file's
--     "AddGameplayScripts" = True (and ImportIntoVFS = True). Do NOT register
--     it as an InGameUIAddin: the UI Lua state is not synchronised, so
--     InitUnit / SetMoves / ChangePopulation run from there can desync.
--   * Only synced APIs are used (Game.Rand, GameEvents). No pairs()/next()
--     iteration is used to make a gameplay decision; every list walk is an
--     array walk in a fixed order.
--   * All players must run the mod, with identical CFG values.
--
-- PERFORMANCE NOTES
--   * Combat hook does cheap early-outs before touching any state.
--   * PlayerDoTurn only walks the refugees of the player whose turn it is
--     (per-owner lists) and does nothing at all when none exist.
--   * Each refugee caches its destination city, so the "nearest city" scan
--     runs once per refugee (and again only if the destination is lost).
--   * Distances use the engine's Map.PlotDistance (wrap-aware, native).
--   * Stale attack-tracker entries are pruned every few turns.
--=============================================================================

----------------------------------------------------------------------------
-- CONFIG
----------------------------------------------------------------------------
local CFG = {
    -- Unit used for the refugees. Any LAND unit type from the database,
    -- e.g. "UNIT_SETTLER", "UNIT_WORKER", "UNIT_MY_REFUGEE" (from your own mod).
    -- If invalid / not a land unit, UNIT_SETTLER is used (with a log warning).
    REFUGEE_UNIT                = "UNIT_REFUGEE",

    ATTACK_STREAK_REQUIRED      = 2,     -- consecutive turns a city must be attacked
    POP_LOSS                    = 2,     -- population removed from attacked city
    POP_GAIN                    = 2,     -- population added to destination city
    SPAWN_MAX_RADIUS            = 3,     -- how far from the city the unit may appear
    ARRIVAL_DISTANCE            = 2,     -- "within one tile" of the destination city
    COUNT_BARBARIANS            = false, -- do barbarian attacks count?
    REQUIRE_SAME_ATTACKER       = false, -- must the same civ attack on both turns?
    ALLOW_ORIGIN_AS_DESTINATION = false, -- if no other city exists, may they return home?
    NOTIFY_ATTACKER             = true,  -- alert the besieging player when refugees flee
    SEND_NOTIFICATION           = false, -- entry in the notification panel (right side)
    SEND_ALERT                  = true,  -- on-screen banner message only
    DEBUG                       = false, -- print diagnostics to Lua.log
    NAME_SUFFIX                 = " Refugees",
    REQUIRE_SAME_LANDMASS            = true, -- destination city must be on the same landmass as the besieged city
    REQUIRE_SAME_LANDMASS_AS_CAPITAL = false, -- besieged city must be on the same landmass as its capital
    MAX_DESTINATION_DISTANCE         = 12,   -- max hex distance to the destination city (nil = no limit)
    TRACKER_PRUNE_INTERVAL           = 25,   -- turns between cleanups of stale attack records
}

local function Log(...)
    if CFG.DEBUG then print("RS:", ...) end
end

----------------------------------------------------------------------------
-- UNIT TYPE RESOLUTION
----------------------------------------------------------------------------
local function ResolveRefugeeUnit()
    local id = GameInfoTypes[CFG.REFUGEE_UNIT]
    if id then
        local info = GameInfo.Units[id]
        if info and info.Domain == "DOMAIN_LAND" then
            return id
        end
        print("RS: WARNING - " .. tostring(CFG.REFUGEE_UNIT) ..
              " is not a land unit, falling back to UNIT_SETTLER")
    else
        print("RS: WARNING - unknown unit type " .. tostring(CFG.REFUGEE_UNIT) ..
              ", falling back to UNIT_SETTLER")
    end
    return GameInfoTypes.UNIT_SETTLER
end

----------------------------------------------------------------------------
-- STATE (runtime only; rebuilt from unit names after a save/load)
----------------------------------------------------------------------------
local REFUGEE_UNIT_ID  = ResolveRefugeeUnit()
local MAX_MAJOR        = GameDefines.MAX_MAJOR_CIVS
local NUM_DIRECTIONS   = DirectionTypes.NUM_DIRECTION_TYPES - 1
local SUFFIX_LEN       = #CFG.NAME_SUFFIX

-- Per-owner ARRAYS of {unitID, originCityID, destID} (arrays = deterministic order)
local refugeesByOwner  = {}
local refugeeCount     = 0
-- [cityKey] = {lastTurn, streak, attacker}. Lookup only; the one pairs() walk
-- (pruning) only deletes stale records, so its order cannot affect gameplay.
local attackTracker    = {}
local registryBuilt    = false
local lastPruneTurn    = 0

for pid = 0, MAX_MAJOR - 1 do refugeesByOwner[pid] = {} end

----------------------------------------------------------------------------
-- MAP / HEX HELPERS
----------------------------------------------------------------------------
local gridW, gridH, wrapX, wrapY

local function CacheMapInfo()
    if not gridW then
        gridW, gridH = Map.GetGridSize()
        wrapX, wrapY = Map.IsWrapX(), Map.IsWrapY()
    end
end

-- Civ V uses "odd-r" offset hexes (odd rows shifted right).
local function CubeDistance(x1, y1, x2, y2)
    local q1 = x1 - (y1 - (y1 % 2)) / 2
    local q2 = x2 - (y2 - (y2 % 2)) / 2
    local dq = q1 - q2
    local dr = y1 - y2
    return (math.abs(dq) + math.abs(dr) + math.abs(dq + dr)) / 2
end

-- Fallback wrap-aware distance (only used if Map.PlotDistance is missing).
local function FallbackHexDistance(x1, y1, x2, y2)
    CacheMapInfo()
    local best = CubeDistance(x1, y1, x2, y2)
    local ixMin, ixMax, iyMin, iyMax = 0, 0, 0, 0
    if wrapX then ixMin, ixMax = -1, 1 end
    if wrapY then iyMin, iyMax = -1, 1 end
    for ix = ixMin, ixMax do
        for iy = iyMin, iyMax do
            local d = CubeDistance(x1, y1, x2 + ix * gridW, y2 + iy * gridH)
            if d < best then best = d end
        end
    end
    return best
end

-- Native engine distance is faster and always matches the game's own rules.
local HexDistance = Map.PlotDistance or FallbackHexDistance

local function GetWrappedPlot(x, y)
    CacheMapInfo()
    if wrapX then x = x % gridW end
    if wrapY then y = y % gridH end
    if x < 0 or x >= gridW or y < 0 or y >= gridH then return nil end
    return Map.GetPlot(x, y)
end

----------------------------------------------------------------------------
-- NOTIFICATIONS (humans only)
----------------------------------------------------------------------------
local function Notify(player, text, summary, x, y)
    if not player or not player:IsHuman() then return end

    if CFG.SEND_NOTIFICATION then
        local ok, err = pcall(function()
            player:AddNotification(NotificationTypes.NOTIFICATION_GENERIC, text, summary, x or -1, y or -1)
        end)
        if not ok then Log("AddNotification failed", player:GetID(), tostring(err)) end
    end

    -- On-screen banner. Display only (changes no game state), and
    -- pcall'd because Events/active-player may not exist in the gameplay state.
    if CFG.SEND_ALERT then
        pcall(function()
            if Events.GameplayAlertMessage and Game.GetActivePlayer() == player:GetID() then
                Events.GameplayAlertMessage(text)
            end
        end)
    end
end

----------------------------------------------------------------------------
-- SPAWN TILE SELECTION
----------------------------------------------------------------------------
local function IsPlotUsable(plot, ownerID)
    if not plot then return false end
    if plot:IsWater() or plot:IsImpassable() or plot:IsMountain() or plot:IsCity() then return false end
    if plot:GetNumUnits() > 0 then return false end
    local plotOwner = plot:GetOwner()
    if plotOwner ~= -1 and plotOwner ~= ownerID then return false end
    return true
end

-- Checks the 6 neighbours (not a 3x3 box) for units of civs at war with us.
local function HasEnemyAdjacent(x, y, ownerID, myTeam)
    for dir = 0, NUM_DIRECTIONS do
        local p = Map.PlotDirection(x, y, dir)
        if p then
            for i = 0, p:GetNumUnits() - 1 do
                local u = p:GetUnit(i)
                if u then
                    local uOwnerID = u:GetOwner()
                    if uOwnerID ~= ownerID then
                        local uOwner = Players[uOwnerID]
                        if uOwner and Teams[uOwner:GetTeam()]:IsAtWar(myTeam) then
                            return true
                        end
                    end
                end
            end
        end
    end
    return false
end

-- Closest empty land tile; tiles next to enemy units are heavily penalised.
-- Candidates are collected in a fixed scan order and ties are broken with
-- Game.Rand (synced), so every machine picks the same tile.
local function FindSpawnPlot(city, ownerID)
    local cx, cy = city:GetX(), city:GetY()
    local myTeam = Players[ownerID]:GetTeam()
    local bestScore, candidates = nil, {}
    local R = CFG.SPAWN_MAX_RADIUS
    for dy = -R, R do
        for dx = -R, R do
            local dist = CubeDistance(cx, cy, cx + dx, cy + dy)
            if dist >= 1 and dist <= R and (not bestScore or dist <= bestScore) then
                local plot = GetWrappedPlot(cx + dx, cy + dy)
                if IsPlotUsable(plot, ownerID) then
                    local score = dist
                    if HasEnemyAdjacent(plot:GetX(), plot:GetY(), ownerID, myTeam) then score = score + 10 end
                    if not bestScore or score < bestScore then
                        bestScore = score
                        candidates = { plot }
                    elseif score == bestScore then
                        candidates[#candidates + 1] = plot
                    end
                end
            end
        end
    end
    if #candidates == 0 then return nil end
    return candidates[Game.Rand(#candidates, "Refugee spawn tile") + 1]
end

----------------------------------------------------------------------------
-- DESTINATION SELECTION
----------------------------------------------------------------------------
-- Nearest city of the player. player:Cities() has a fixed engine order and
-- ties keep the first city found, so the result is deterministic.
local function FindNearestCity(player, x, y, excludeCityID)
    local refPlot = Map.GetPlot(x, y)
    local refArea = refPlot and refPlot:GetArea() or nil
    local maxDist = CFG.MAX_DESTINATION_DISTANCE
    local sameLand = CFG.REQUIRE_SAME_LANDMASS
    local best, bestDist
    for city in player:Cities() do
        if city:GetID() ~= excludeCityID then
            local d = HexDistance(x, y, city:GetX(), city:GetY())
            if (not maxDist or d <= maxDist)
               and (not bestDist or d < bestDist)
               and (not sameLand or (refArea ~= nil and city:Plot():GetArea() == refArea)) then
                best, bestDist = city, d
            end
        end
    end
    return best
end

local function FindDestination(player, x, y, originCityID)
    local dest = FindNearestCity(player, x, y, originCityID)
    if not dest and CFG.ALLOW_ORIGIN_AS_DESTINATION then
        dest = FindNearestCity(player, x, y, nil)
    end
    return dest
end

----------------------------------------------------------------------------
-- REGISTRY (rebuilds itself from unit names after loading a save)
----------------------------------------------------------------------------
local function AddRecord(ownerID, unitID, originCityID, destID)
    local list = refugeesByOwner[ownerID]
    list[#list + 1] = { unitID = unitID, originCityID = originCityID, destID = destID }
    refugeeCount = refugeeCount + 1
end

local function IsRegistered(ownerID, unitID)
    local list = refugeesByOwner[ownerID]
    for i = 1, #list do
        if list[i].unitID == unitID then return true end
    end
    return false
end

local function EnsureRegistry()
    if registryBuilt then return end
    registryBuilt = true
    local suffix = CFG.NAME_SUFFIX
    for pid = 0, MAX_MAJOR - 1 do
        local p = Players[pid]
        if p and p:IsAlive() then
            for unit in p:Units() do
                if unit:GetUnitType() == REFUGEE_UNIT_ID then
                    local nm = unit:GetNameNoDesc()
                    if nm and #nm > SUFFIX_LEN and string.sub(nm, -SUFFIX_LEN) == suffix
                       and not IsRegistered(pid, unit:GetID()) then
                        local originName = string.sub(nm, 1, #nm - SUFFIX_LEN)
                        local originID = -1
                        for c in p:Cities() do
                            if c:GetName() == originName then originID = c:GetID() break end
                        end
                        AddRecord(pid, unit:GetID(), originID, nil)
                    end
                end
            end
        end
    end
end

----------------------------------------------------------------------------
-- SPAWNING REFUGEES
----------------------------------------------------------------------------
-- attackerID    : player who made the attack that triggered the spawn
-- firstAttacker : player who made the previous turn's attack (may be same / -1)
local function SpawnRefugees(city, player, attackerID, firstAttacker)
    if not REFUGEE_UNIT_ID then Log("spawn abort: no refugee unit type") return false end
    if city:GetPopulation() <= CFG.POP_LOSS then Log("spawn abort: population too low") return false end

    if CFG.REQUIRE_SAME_LANDMASS_AS_CAPITAL then
        local capital = player:GetCapitalCity()
        if capital and capital:Plot():GetArea() ~= city:Plot():GetArea() then
            Log("spawn abort: city is on a different landmass than the capital")
            return false
        end
    end

    local ownerID, cityID = player:GetID(), city:GetID()
    local cx, cy = city:GetX(), city:GetY()

    local dest = FindDestination(player, cx, cy, cityID)
    if not dest then Log("spawn abort: no destination city") return false end
    local plot = FindSpawnPlot(city, ownerID)
    if not plot then Log("spawn abort: no spawn plot") return false end

    local unit = player:InitUnit(REFUGEE_UNIT_ID, plot:GetX(), plot:GetY())
    if not unit then Log("spawn abort: InitUnit failed") return false end

    city:ChangePopulation(-CFG.POP_LOSS, true)

    local cityName = city:GetName()
    unit:SetName(cityName .. CFG.NAME_SUFFIX)
    unit:SetMoves(0) -- inert until the script moves it on the owner's turn

    AddRecord(ownerID, unit:GetID(), cityID, dest:GetID())
    Log("refugees spawned from", cityName, "attacker", attackerID, "first attacker", firstAttacker)

    Notify(player,
        cityName .. " has been under siege for two turns! " .. CFG.POP_LOSS ..
        " citizens have fled as refugees and are heading for the nearest safe city.",
        "Refugees leave " .. cityName,
        plot:GetX(), plot:GetY())

    -- Alert the besieging player(s). Points at the besieged city, not the
    -- refugee tile, so no fogged information is revealed.
    if CFG.NOTIFY_ATTACKER then
        local notified = {}
        local function AlertAttacker(id)
            if id and id >= 0 and id ~= ownerID and not notified[id] then
                notified[id] = true
                Notify(Players[id],
                    "Your siege of " .. cityName .. " has forced " .. CFG.POP_LOSS ..
                    " citizens to flee as refugees.",
                    "Siege of " .. cityName .. " forces refugees out",
                    cx, cy)
            end
        end
        AlertAttacker(attackerID)
        AlertAttacker(firstAttacker)
    end
    return true
end

----------------------------------------------------------------------------
-- COMBAT HOOK  (runs only when combat ends; cheap early-outs first)
----------------------------------------------------------------------------
local function OnCombatEnded(iAttackingPlayer, iAttackingUnit, attackerDamage, attackerFinalDamage, attackerMaxHP,
                             iDefendingPlayer, iDefendingUnit, defenderDamage, defenderFinalDamage, defenderMaxHP,
                             iInterceptingPlayer, iInterceptingUnit, interceptorDamage, plotX, plotY)
    if not plotX or not plotY then return end
    if not iAttackingPlayer or iAttackingPlayer < 0 then return end
    if not iDefendingPlayer or iDefendingPlayer < 0 or iDefendingPlayer >= MAX_MAJOR then return end
    if iAttackingPlayer == iDefendingPlayer then return end

    local plot = Map.GetPlot(plotX, plotY)
    if not plot or not plot:IsCity() then return end
    local city = plot:GetPlotCity()
    if not city or city:GetOwner() ~= iDefendingPlayer then return end -- also skips captured cities

    local turn = Game.GetGameTurn()
    local key  = iDefendingPlayer * 65536 + city:GetID()
    local rec  = attackTracker[key]
    if rec and rec.lastTurn == turn then return end -- already counted this turn (cheapest exit)

    local defender, attacker = Players[iDefendingPlayer], Players[iAttackingPlayer]
    if not defender or not attacker or not defender:IsAlive() then return end
    if attacker:IsBarbarian() then
        if not CFG.COUNT_BARBARIANS then return end
    elseif not Teams[attacker:GetTeam()]:IsAtWar(defender:GetTeam()) then
        return
    end

    EnsureRegistry()

    if not rec then
        rec = { lastTurn = -10, streak = 0, attacker = -1 }
        attackTracker[key] = rec
    end

    local firstAttacker = -1
    if rec.lastTurn == turn - 1
       and (not CFG.REQUIRE_SAME_ATTACKER or rec.attacker == iAttackingPlayer) then
        rec.streak = rec.streak + 1
        firstAttacker = rec.attacker
    else
        rec.streak = 1
    end
    rec.lastTurn, rec.attacker = turn, iAttackingPlayer
    Log("streak", rec.streak, "city", city:GetName(), "turn", turn, "attacker", iAttackingPlayer)

    if rec.streak >= CFG.ATTACK_STREAK_REQUIRED then
        if SpawnRefugees(city, defender, iAttackingPlayer, firstAttacker) then
            rec.streak = 0 -- needs a fresh run of attacks to trigger again
        end
    end
end

----------------------------------------------------------------------------
-- REFUGEE MOVEMENT / ARRIVAL  (once per owner's turn)
----------------------------------------------------------------------------
local function Arrive(player, unit, dest)
    local destName = dest:GetName()
    local unitName = unit:GetNameNoDesc()
    dest:ChangePopulation(CFG.POP_GAIN, true)
    Notify(player,
        unitName .. " have reached " .. destName .. ". Population +" .. CFG.POP_GAIN .. ".",
        "Refugees arrive in " .. destName,
        dest:GetX(), dest:GetY())
    unit:Kill(true, -1)
end

-- Uses the cached destination while that city is still ours; otherwise rescans.
local function GetDestination(rec, player, x, y)
    if rec.destID then
        local c = player:GetCityByID(rec.destID)
        if c then return c end
    end
    local c = FindDestination(player, x, y, rec.originCityID)
    rec.destID = c and c:GetID() or nil
    return c
end

-- returns true to keep the record, false to drop it
local function ProcessRefugee(rec, player)
    local unit = player:GetUnitByID(rec.unitID)
    if not unit or unit:IsDead() then return false end -- killed or captured

    local ux, uy = unit:GetX(), unit:GetY()
    local dest = GetDestination(rec, player, ux, uy)
    if not dest then
        unit:Kill(true, -1) -- no city left to go to
        return false
    end

    local dx, dy = dest:GetX(), dest:GetY()
    if HexDistance(ux, uy, dx, dy) <= CFG.ARRIVAL_DISTANCE then
        Arrive(player, unit, dest)
        return false
    end

    -- Move toward the city using the engine's pathfinder
    -- (this build wants numbers, not booleans, for the flag arguments)
    unit:PushMission(MissionTypes.MISSION_MOVE_TO, dx, dy, 0, 0, 0)

    unit = player:GetUnitByID(rec.unitID)
    if not unit or unit:IsDead() then return false end

    if HexDistance(unit:GetX(), unit:GetY(), dx, dy) <= CFG.ARRIVAL_DISTANCE then
        Arrive(player, unit, dest)
        return false
    end

    -- Lock the unit every turn it is processed, whether or not it moved
    unit:SetMoves(0)
    return true
end

local function PruneTracker(turn)
    -- Deleting stale records only; traversal order cannot change any outcome.
    for key, rec in pairs(attackTracker) do
        if rec.lastTurn < turn - 2 then attackTracker[key] = nil end
    end
end

local function OnPlayerDoTurn(iPlayer)
    -- Housekeeping once per game turn (player 0 is always first)
    if iPlayer == 0 then
        local turn = Game.GetGameTurn()
        if turn - lastPruneTurn >= CFG.TRACKER_PRUNE_INTERVAL then
            lastPruneTurn = turn
            PruneTracker(turn)
        end
    end

    EnsureRegistry()
    if refugeeCount == 0 then return end -- zero cost when nothing is active

    local list = refugeesByOwner[iPlayer]
    if not list or #list == 0 then return end

    local player = Players[iPlayer]
    if not player or not player:IsAlive() then return end

    for i = #list, 1, -1 do
        if not ProcessRefugee(list[i], player) then
            table.remove(list, i)
            refugeeCount = refugeeCount - 1
        end
    end
end

----------------------------------------------------------------------------
-- REGISTER
----------------------------------------------------------------------------
GameEvents.CombatEnded.Add(OnCombatEnded)
GameEvents.PlayerDoTurn.Add(OnPlayerDoTurn)

print("RefugeeSettlers loaded, refugee unit id: " .. tostring(REFUGEE_UNIT_ID))