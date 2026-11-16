--==========================================================================
-- AutoImprovements.lua
-- Worker-less terrain improvement for Civilization V (BNW / Gods & Kings).
--
-- Every BUILD_INTERVAL turns (staggered per city) each city places
--   N = BASE_PER_TURN + number of researched BONUS_TECHS
-- improvements on tiles inside its borders. Pillaged improvements are
-- repaired by a separate, slower pass (REPAIR_*), optionally clearing fallout.
--
-- MULTIPLAYER STABILITY
--   * Runs only from GameEvents.PlayerDoTurn, which fires identically on
--     every machine, and only reads/writes synchronized game state.
--   * Fully deterministic: no math.random, no clocks in game logic, no
--     pairs() over hash tables after load, no Game.GetActivePlayer(), no UI.
--   * Stateless: schedules come from (game turn + city ID), so a reload or
--     a late join can never put one client out of step with another.
--   * Cities are processed in the engine's own (synchronized) ID order and
--     ties are broken by plot coordinates, never by chance.
--   * The whole handler is wrapped in pcall so one bad tile or a modded
--     ruleset quirk cannot break the turn for other scripts.
--   * Re-loading the script replaces its old handler (no double builds).
--
-- PERFORMANCE
--   * All database lookups are cached once at load.
--   * Idle turns cost one loop over the player's cities and a modulo check.
--   * Per tile: cheap ownership/improvement checks first, a database-driven
--     prefilter before the expensive CanBuild call, yield "before" values
--     computed once per tile, worked-tile lookup only when needed.
--   * Top-N selection is done inline with a tiny insertion list: no
--     per-candidate tables for losing tiles and no sorting.
--==========================================================================

--------------------------------------------------------------------------
-- CONFIG
--------------------------------------------------------------------------
local CONFIG = {
	-- Improvements each city places on its build turn.
	BASE_PER_TURN = 1,
	-- Each tech the team owns adds +1 per build turn (unknown techs ignored).
	BONUS_TECHS = {
		"TECH_INDUSTRIALIZATION",   -- 2 per build turn
		-- "TECH_ELECTRICITY",      -- uncomment for 3
		-- "TECH_ROBOTICS",         -- uncomment for 4
	},
	HARD_CAP_PER_TURN = 6,

	-- A city builds only every BUILD_INTERVAL turns (1 = every turn).
	-- Cities are offset by city ID so they do not all build on the same turn.
	BUILD_INTERVAL = 3,

	APPLY_TO_HUMANS      = true,
	APPLY_TO_AI          = true,
	APPLY_TO_CITY_STATES = true,

	-- Slow repair of pillaged improvements, independent of the build count.
	REPAIR_PILLAGED  = true,
	REPAIR_INTERVAL  = 4,       -- each city repairs every 4 turns (staggered)
	REPAIRS_PER_CITY = 1,
	REMOVE_FALLOUT   = true,    -- clear fallout from tiles being repaired

	-- Do not build on tiles holding an at-war unit (repairs always skip them).
	SKIP_OCCUPIED_BY_ENEMY = true,

	-- How far from a city (in tiles) it may build and repair on tiles that
	-- the player owns. 3 = the normal city work area; 5 reaches purchased /
	-- culture-expanded border tiles. Larger values scan more tiles per city.
	BUILD_RANGE = 5,
	-- A city can only WORK tiles up to this distance (3 in the base game).
	-- It only affects the worked-tile score bonus.
	WORK_RADIUS = 5,

	-- Never auto-built (unit-consuming builds are excluded automatically).
	EXCLUDED_IMPROVEMENTS = {
		"IMPROVEMENT_FORT",
		"IMPROVEMENT_CITADEL",
	},

	-- Tile scoring
	YIELD_WEIGHTS = {
		YIELD_FOOD       = 12,
		YIELD_PRODUCTION = 10,
		YIELD_GOLD       = 6,
		YIELD_SCIENCE    = 8,
		YIELD_CULTURE    = 8,
		YIELD_FAITH      = 6,
	},
	RESOURCE_CONNECT_BONUS = 100,   -- connecting any resource
	STRATEGIC_BONUS        = 400,   -- extra for strategic resources
	LUXURY_BONUS           = 400,   -- extra for luxury resources
	WORKED_TILE_BONUS      = 20,
	UPGRADE_BONUS          = 300,   -- replace a stand-in with the proper improvement

	-- Skip the expensive CanBuild call for improvements that cannot be valid
	-- on a tile's terrain/feature/resource (built from the game database and
	-- deliberately conservative). Set false if a custom rule in your mod
	-- makes some improvement valid in a way the database does not describe.
	USE_BUILD_PREFILTER = true,

	-- Logs per-player timing and actions to Lua.log.
	DEBUG = false,
}

--------------------------------------------------------------------------
-- LOAD-TIME CACHES (built from the same database on every client)
--------------------------------------------------------------------------
local NO_IMPROVEMENT = -1   -- Civ 5 defines no NO_* globals for these
local NO_RESOURCE    = -1
local NO_FEATURE     = -1

local function dprint(...)
	if CONFIG.DEBUG then print("[AutoImprovements]", ...) end
end

-- Sanitised, localised config values (fast upvalue access in hot loops)
local BUILD_INTERVAL = math.max(1, math.floor(CONFIG.BUILD_INTERVAL))
local REPAIR_INTERVAL = math.max(1, math.floor(CONFIG.REPAIR_INTERVAL))
local REPAIRS_PER_CITY = math.max(1, math.floor(CONFIG.REPAIRS_PER_CITY))
local REPAIR_ENABLED = CONFIG.REPAIR_PILLAGED
local REMOVE_FALLOUT = CONFIG.REMOVE_FALLOUT
local SKIP_ENEMY = CONFIG.SKIP_OCCUPIED_BY_ENEMY
local USE_PREFILTER = CONFIG.USE_BUILD_PREFILTER
local CONNECT_BONUS = CONFIG.RESOURCE_CONNECT_BONUS
local WORKED_BONUS = CONFIG.WORKED_TILE_BONUS
local UPGRADE_BONUS = CONFIG.UPGRADE_BONUS
local BUILD_RANGE = math.max(1, math.floor(CONFIG.BUILD_RANGE))
local WORK_RADIUS = math.max(0, math.floor(CONFIG.WORK_RADIUS))

local FALLOUT_ID = GameInfoTypes["FEATURE_FALLOUT"]

-- Excluded improvement IDs
local excludedImprovement = {}
for _, typeName in ipairs(CONFIG.EXCLUDED_IMPROVEMENTS) do
	local id = GameInfoTypes[typeName]
	if id then excludedImprovement[id] = true end
end

-- Bonus tech IDs (ordered list)
local bonusTechIDs = {}
for _, typeName in ipairs(CONFIG.BONUS_TECHS) do
	local id = GameInfoTypes[typeName]
	if id then bonusTechIDs[#bonusTechIDs + 1] = id end
end

-- Which improvements connect which resource
local improvementConnects = {}      -- [improvementID][resourceID] = true
local resourceHasImprovement = {}   -- [resourceID] = true
for row in GameInfo.Improvement_ResourceTypes() do
	local impID = GameInfoTypes[row.ImprovementType]
	local resID = GameInfoTypes[row.ResourceType]
	if impID and resID then
		improvementConnects[impID] = improvementConnects[impID] or {}
		improvementConnects[impID][resID] = true
		resourceHasImprovement[resID] = true
	end
end

-- Terrain / feature validity (used only by the conservative prefilter)
local validTerrain = {}   -- [improvementID][terrainID] = true
local validFeature = {}   -- [improvementID][featureID] = true
for row in GameInfo.Improvement_ValidTerrains() do
	local impID, terID = GameInfoTypes[row.ImprovementType], GameInfoTypes[row.TerrainType]
	if impID and terID then
		validTerrain[impID] = validTerrain[impID] or {}
		validTerrain[impID][terID] = true
	end
end
for row in GameInfo.Improvement_ValidFeatures() do
	local impID, feaID = GameInfoTypes[row.ImprovementType], GameInfoTypes[row.FeatureType]
	if impID and feaID then
		validFeature[impID] = validFeature[impID] or {}
		validFeature[impID][feaID] = true
	end
end

-- Unique improvements: [improvementID] = owning civilizationID
-- Improvements with special validity flags: never prefiltered
local improvementCiv = {}
local alwaysPass = {}
for row in GameInfo.Improvements() do
	local id = row.ID
	if row.CivilizationType then
		local civID = GameInfoTypes[row.CivilizationType]
		if civID then improvementCiv[id] = civID end
	end
	if row.HillsMakesValid or row.FreshWaterMakesValid or row.RiverSideMakesValid
		or row.Water or (not validTerrain[id] and not validFeature[id]) then
		alwaysPass[id] = true
	end
end

-- Candidate improvement builds (ordered by build ID -> deterministic)
local improvementBuilds = {}
for row in GameInfo.Builds() do
	local impID = row.ImprovementType and GameInfoTypes[row.ImprovementType]
	if impID and not row.Kill and not excludedImprovement[impID] then
		improvementBuilds[#improvementBuilds + 1] = {
			build       = row.ID,
			improvement = impID,
			tech        = row.PrereqTech and GameInfoTypes[row.PrereqTech] or nil,
		}
	end
end
table.sort(improvementBuilds, function(a, b) return a.build < b.build end)

-- Improvements this script could have placed (only these may be replaced)
local buildableImprovement = {}
for i = 1, #improvementBuilds do
	buildableImprovement[improvementBuilds[i].improvement] = true
end

-- Resource priority: [resourceID] = extra score for strategic / luxury
local resourcePriority = {}
for row in GameInfo.Resources() do
	local class = row.ResourceClassType
	local usage = row.ResourceUsage
	if usage == 1 or class == "RESOURCECLASS_RUSH" or class == "RESOURCECLASS_MODERN" then
		resourcePriority[row.ID] = CONFIG.STRATEGIC_BONUS
	elseif usage == 2 or class == "RESOURCECLASS_LUXURY" then
		resourcePriority[row.ID] = CONFIG.LUXURY_BONUS
	end
end

-- Yield list for scoring (fixed order)
local yieldList = {}
for typeName, weight in pairs(CONFIG.YIELD_WEIGHTS) do
	local id = GameInfoTypes[typeName]
	if id then yieldList[#yieldList + 1] = { id = id, weight = weight } end
end
table.sort(yieldList, function(a, b) return a.id < b.id end)
local nYields = #yieldList

-- Engine query support check (older/modded DLLs may lack it)
local HAS_YIELD_QUERY = false
do
	local testPlot = Map.GetPlotByIndex(0)
	HAS_YIELD_QUERY = testPlot ~= nil
		and testPlot.GetYieldWithBuild ~= nil
		and testPlot.CalculateYield ~= nil
end

-- Reusable scratch arrays (avoid per-tile allocations)
local scratchLegal  = {}
local scratchBefore = {}
local scratchPlots  = {}   -- owned tiles within BUILD_RANGE of the current city
local scratchInWork = {}   -- true when that tile is inside the city's work radius

-- Range lookup: the engine helper handles map wrapping. The fallback does
-- not wrap around the map seam (only used if the helper is missing).
local PlotXYWithRangeCheck = Map.PlotXYWithRangeCheck
if not PlotXYWithRangeCheck then
	PlotXYWithRangeCheck = function(x, y, dx, dy, range)
		local p = Map.GetPlot(x + dx, y + dy)
		if p and Map.PlotDistance(x, y, p:GetX(), p:GetY()) <= range then return p end
		return nil
	end
end

--------------------------------------------------------------------------
-- HELPERS
--------------------------------------------------------------------------
local function GetActionsPerTurn(iTeam)
	local team = Teams[iTeam]
	local count = CONFIG.BASE_PER_TURN
	for i = 1, #bonusTechIDs do
		if team:IsHasTech(bonusTechIDs[i]) then count = count + 1 end
	end
	if count > CONFIG.HARD_CAP_PER_TURN then count = CONFIG.HARD_CAP_PER_TURN end
	return count
end

local function PlayerQualifies(pPlayer)
	if not pPlayer or not pPlayer:IsAlive() then return false end
	if pPlayer:IsBarbarian() then return false end
	if pPlayer:IsMinorCiv() then return CONFIG.APPLY_TO_CITY_STATES end
	if pPlayer:IsHuman() then return CONFIG.APPLY_TO_HUMANS end
	return CONFIG.APPLY_TO_AI
end

-- Builds the player can use right now (once per player per turn)
local function GetAvailableBuilds(iTeam, iCiv)
	local team = Teams[iTeam]
	local list, n = {}, 0
	for i = 1, #improvementBuilds do
		local b = improvementBuilds[i]
		local owner = improvementCiv[b.improvement]
		-- Unique improvements are only available to the civ that owns them
		if (owner == nil or owner == iCiv)
			and (b.tech == nil or team:IsHasTech(b.tech)) then
			n = n + 1
			list[n] = b
		end
	end
	return list, n
end

local function BlockedByEnemy(pPlot, iTeam)
	local numUnits = pPlot:GetNumUnits()
	if numUnits == 0 then return false end
	local team = Teams[iTeam]
	for i = 0, numUnits - 1 do
		local pUnit = pPlot:GetUnit(i)
		if pUnit and team:IsAtWar(pUnit:GetTeam()) then return true end
	end
	return false
end

-- Fills scratchPlots / scratchInWork with the player's owned, non-city tiles
-- within BUILD_RANGE of the city (fixed dx/dy order -> deterministic) and
-- returns how many were found. Done once per city per turn.
local function CollectCityPlots(pCity, iPlayer)
	local cx, cy = pCity:GetX(), pCity:GetY()
	local n = 0
	for dx = -BUILD_RANGE, BUILD_RANGE do
		for dy = -BUILD_RANGE, BUILD_RANGE do
			local pPlot = PlotXYWithRangeCheck(cx, cy, dx, dy, BUILD_RANGE)
			if pPlot and pPlot:GetOwner() == iPlayer and not pPlot:IsCity() then
				n = n + 1
				scratchPlots[n] = pPlot
				scratchInWork[n] = Map.PlotDistance(cx, cy, pPlot:GetX(), pPlot:GetY()) <= WORK_RADIUS
			end
		end
	end
	return n
end

-- Conservative: false only if the database proves the improvement cannot
-- be valid here. CanBuild still makes the final decision.
local function MayApply(imp, terrain, feature, resID)
	if alwaysPass[imp] then return true end
	local vt = validTerrain[imp]
	if vt and vt[terrain] then return true end
	if feature >= 0 then
		local vf = validFeature[imp]
		if vf and vf[feature] then return true end
	end
	if resID >= 0 then
		local ic = improvementConnects[imp]
		if ic and ic[resID] then return true end
	end
	return false
end

local function FillBefore(pPlot)
	for j = 1, nYields do
		scratchBefore[j] = pPlot:CalculateYield(yieldList[j].id, true)
	end
end

local function ScoreBuild(pPlot, b, iPlayer, connects, bWorked, resID)
	local score = 0
	if connects then
		score = score + CONNECT_BONUS
		local extra = resourcePriority[resID]   -- strategic / luxury first
		if extra then score = score + extra end
	end
	if HAS_YIELD_QUERY then
		local buildID = b.build
		for j = 1, nYields do
			local y = yieldList[j]
			score = score + y.weight * (pPlot:GetYieldWithBuild(buildID, y.id, true, iPlayer) - scratchBefore[j])
		end
	end
	if bWorked then score = score + WORKED_BONUS end
	return score
end

-- pCity is passed as nil when the tile is outside the city's work radius.
-- Unimproved tile: best build and its score (nil if nothing suitable).
-- Resource tiles whose proper improvement is not unlocked yet receive a
-- stand-in; EvaluateUpgrade replaces it later.
local function EvaluateEmptyPlot(pCity, pPlot, iPlayer, iTeam, builds, nBuilds)
	local terrain = pPlot:GetTerrainType()
	local feature = pPlot:GetFeatureType()
	local resID   = pPlot:GetResourceType(iTeam)
	if resID == nil then resID = NO_RESOURCE end
	local hasResource = resID >= 0

	local nLegal = 0
	local anyConnects = false
	for i = 1, nBuilds do
		local b = builds[i]
		local imp = b.improvement
		if (not USE_PREFILTER or MayApply(imp, terrain, feature, resID))
			and pPlot:CanBuild(b.build, iPlayer) then
			nLegal = nLegal + 1
			scratchLegal[nLegal] = b
			if hasResource then
				local ic = improvementConnects[imp]
				if ic and ic[resID] then anyConnects = true end
			end
		end
	end
	if nLegal == 0 then return nil end

	local bWorked = (pCity ~= nil) and pCity:IsWorkingPlot(pPlot) or false
	if HAS_YIELD_QUERY then FillBefore(pPlot) end

	local bestBuild, bestScore
	for i = 1, nLegal do
		local b = scratchLegal[i]
		local connects = false
		if hasResource then
			local ic = improvementConnects[b.improvement]
			connects = (ic ~= nil and ic[resID] == true)
		end
		-- If the proper improvement is available, only consider those.
		if (not anyConnects) or connects then
			local score = ScoreBuild(pPlot, b, iPlayer, connects, bWorked, resID)
			if bestScore == nil or score > bestScore then
				bestBuild, bestScore = b, score
			end
		end
	end
	return bestBuild, bestScore
end

-- Improved tile: if it holds a non-connecting improvement we could have
-- placed, and a connecting improvement is now unlocked, return that build.
local function EvaluateUpgrade(pCity, pPlot, iPlayer, iTeam, builds, nBuilds, imp)
	if not buildableImprovement[imp] or excludedImprovement[imp] then return nil end

	local resID = pPlot:GetResourceType(iTeam)
	if resID == nil or resID < 0 or not resourceHasImprovement[resID] then return nil end
	local current = improvementConnects[imp]
	if current and current[resID] then return nil end   -- already proper

	local bestBuild, bestScore
	local prepared, bWorked = false, false
	for i = 1, nBuilds do
		local b = builds[i]
		local ic = improvementConnects[b.improvement]
		if ic and ic[resID] and pPlot:CanBuild(b.build, iPlayer) then
			if not prepared then
				prepared = true
				bWorked = (pCity ~= nil) and pCity:IsWorkingPlot(pPlot) or false
				if HAS_YIELD_QUERY then FillBefore(pPlot) end
			end
			local score = ScoreBuild(pPlot, b, iPlayer, true, bWorked, resID) + UPGRADE_BONUS
			if bestScore == nil or score > bestScore then
				bestBuild, bestScore = b, score
			end
		end
	end
	return bestBuild, bestScore
end

-- Candidate ordering: higher score first, then lower y, then lower x
local function Better(score, x, y, other)
	if other == nil then return true end
	if score ~= other.score then return score > other.score end
	if y ~= other.y then return y < other.y end
	return x < other.x
end

-- Keep the best k candidates, best first (tiny insertion list)
local function InsertTop(top, k, pPlot, b, score)
	local n = #top
	local x, y = pPlot:GetX(), pPlot:GetY()
	if n >= k and not Better(score, x, y, top[n]) then return end
	local c = { plot = pPlot, build = b, score = score, x = x, y = y }
	local i = (n >= k) and n or (n + 1)
	top[i] = c
	while i > 1 and Better(score, x, y, top[i - 1]) do
		top[i] = top[i - 1]
		top[i - 1] = c
		i = i - 1
	end
end

local function ApplyOne(c, iPlayer)
	c.plot:SetImprovementType(c.build.improvement, iPlayer)
	c.plot:SetImprovementPillaged(false)
	dprint("Player", iPlayer, "built", c.x, c.y)
end

--------------------------------------------------------------------------
-- BUILD PASS (one city) - works on the tiles gathered by CollectCityPlots
--------------------------------------------------------------------------
local function BuildForCity(pCity, iPlayer, iTeam, builds, nBuilds, perTurn, nPlots)
	local top = {}
	for i = 1, nPlots do
		local pPlot = scratchPlots[i]
		local workCity = scratchInWork[i] and pCity or nil
		local imp = pPlot:GetImprovementType()
		local b, score
		if imp == NO_IMPROVEMENT then
			if not (SKIP_ENEMY and BlockedByEnemy(pPlot, iTeam)) then
				b, score = EvaluateEmptyPlot(workCity, pPlot, iPlayer, iTeam, builds, nBuilds)
			end
		else
			b, score = EvaluateUpgrade(workCity, pPlot, iPlayer, iTeam, builds, nBuilds, imp)
			if b and SKIP_ENEMY and BlockedByEnemy(pPlot, iTeam) then b = nil end
		end
		if b then InsertTop(top, perTurn, pPlot, b, score) end
	end
	for i = 1, #top do ApplyOne(top[i], iPlayer) end
	if CONFIG.DEBUG then
		dprint("Player", iPlayer, "city", pCity:GetID(), "tiles", nPlots, "built", #top)
	end
end

--------------------------------------------------------------------------
-- REPAIR PASS (one city)
-- Worked tiles first, then lowest y, then lowest x (deterministic).
--------------------------------------------------------------------------
local function RepairCity(pCity, iPlayer, iTeam, nPlots)
	for _ = 1, REPAIRS_PER_CITY do
		local best, bestWorked, bestX, bestY
		for i = 1, nPlots do
			local pPlot = scratchPlots[i]
			if pPlot:GetImprovementType() ~= NO_IMPROVEMENT
				and pPlot:IsImprovementPillaged()
				and not BlockedByEnemy(pPlot, iTeam) then
				local x, y = pPlot:GetX(), pPlot:GetY()
				local worked = scratchInWork[i] and pCity:IsWorkingPlot(pPlot) or false
				local better
				if best == nil then
					better = true
				elseif worked ~= bestWorked then
					better = worked
				elseif y ~= bestY then
					better = y < bestY
				else
					better = x < bestX
				end
				if better then
					best, bestWorked, bestX, bestY = pPlot, worked, x, y
				end
			end
		end

		if not best then return end
		if REMOVE_FALLOUT and FALLOUT_ID and best:GetFeatureType() == FALLOUT_ID then
			best:SetFeatureType(NO_FEATURE)
			dprint("Player", iPlayer, "cleared fallout", bestX, bestY)
		end
		best:SetImprovementPillaged(false)
		dprint("Player", iPlayer, "repaired", bestX, bestY)
	end
end

--------------------------------------------------------------------------
-- MAIN
-- Schedules are stateless: a city acts when (turn + cityID) % interval == 0.
--------------------------------------------------------------------------
local function DoTurn(iPlayer)
	local pPlayer = Players[iPlayer]
	if not PlayerQualifies(pPlayer) then return end
	if pPlayer:GetNumCities() == 0 then return end

	local iTeam = pPlayer:GetTeam()
	local turn = Game.GetGameTurn()
	local builds, nBuilds, perTurn

	for pCity in pPlayer:Cities() do
		local key = turn + pCity:GetID()
		local doRepair = REPAIR_ENABLED and key % REPAIR_INTERVAL == 0
		local doBuild  = key % BUILD_INTERVAL == 0

		if doRepair or doBuild then
			local nPlots = CollectCityPlots(pCity, iPlayer)   -- once per city

			if doRepair then
				RepairCity(pCity, iPlayer, iTeam, nPlots)
			end

			if doBuild then
				if builds == nil then   -- computed once per player, only if needed
					perTurn = GetActionsPerTurn(iTeam)
					builds, nBuilds = GetAvailableBuilds(iTeam, pPlayer:GetCivilizationType())
				end
				if nBuilds > 0 then
					BuildForCity(pCity, iPlayer, iTeam, builds, nBuilds, perTurn, nPlots)
				end
			end
		end
	end
end

-- Error-isolating entry point (timing is debug output only, never logic)
local function SafeDoTurn(iPlayer)
	local t0 = nil
	if CONFIG.DEBUG and os and os.clock then t0 = os.clock() end

	local ok, err = pcall(DoTurn, iPlayer)
	if not ok then
		print("[AutoImprovements] ERROR for player " .. tostring(iPlayer) .. ": " .. tostring(err))
	end

	if t0 then
		print(string.format("[AutoImprovements] player %d took %.2f ms", iPlayer, (os.clock() - t0) * 1000))
	end
end

-- Replace any previously registered copy of this handler (no double builds)
if AutoImprovements_Handler then
	pcall(GameEvents.PlayerDoTurn.Remove, AutoImprovements_Handler)
end
AutoImprovements_Handler = SafeDoTurn
GameEvents.PlayerDoTurn.Add(SafeDoTurn)

print("AutoImprovements loaded. Yield query: " .. tostring(HAS_YIELD_QUERY)
	.. ", prefilter: " .. tostring(USE_PREFILTER))