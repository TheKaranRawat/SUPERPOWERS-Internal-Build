-------------------------------------------------------------------------------
-- COLD WAR (InGameUIAddin)
--
-- A top-right button that unlocks once the first Manhattan Project is built.
-- It opens a popup ranking every major civ by military power / nukes, with the
-- top two highlighted as superpowers. If the top two go to war the popup flips
-- from "Cold War" to "Hot War".
--
-- MULTIPLAYER SAFETY
--   * Read-only UI. No GameEvents, no network messages, no database changes,
--     no game state is modified, so it cannot cause a desync.
--   * In multiplayer / hotseat only civs you have met are listed (config).
--   * The cached list is rebuilt whenever the active player changes, so
--     hotseat players never see each other's view.
--
-- PERFORMANCE
--   * Unit scanning (the only expensive part) runs once every
--     CONFIG.SCAN_INTERVAL_TURNS turns (plus once when the button unlocks or a
--     save loads). Opening the popup never triggers a scan.
--   * War declarations only rebuild the list from the cached scan (no unit
--     loop), and bursts of war events are coalesced into ONE refresh on the
--     next frame. The per-frame update hook is only attached while a refresh
--     is pending, so the idle cost is zero.
--   * Popup rows are pooled by InstanceManager (no leak on repeated opens).
-------------------------------------------------------------------------------
include("IconSupport")
include("InstanceManager")

-------------------------------------------------------------------------------
-- CONFIG
-------------------------------------------------------------------------------
local CONFIG = {
	-- Button icon. Priority: ICON_ATLAS/ICON_INDEX  >  ICON_TEXTURE  >  ICON_TECH
	ICON_TECH    = "TECH_GLOBALIZATION", -- any row of the Technologies table
	ICON_ATLAS   = nil,                  -- e.g. "COLDWAR_ICON_ATLAS" (your own IconTextureAtlases entry, 45px)
	ICON_INDEX   = 0,
	ICON_TEXTURE = nil,                  -- e.g. "ColdWarIcon45.dds" (a 45x45 DDS shipped with the mod)

	-- Button position (pixels in from the right / down from the top).
	-- Raise BUTTON_OFFSET_Y if it overlaps your notification stack.
	BUTTON_OFFSET_X = 12,
	BUTTON_OFFSET_Y = 44,

	-- Unlock condition
	REQUIRE_MANHATTAN = true,            -- false = button always visible (handy for testing)
	MANHATTAN_PROJECT = "PROJECT_MANHATTAN_PROJECT",

	-- Which unit types count as nukes
	NUKE_UNITS = { "UNIT_ATOMIC_BOMB", "UNIT_NUCLEAR_MISSILE" },

	-- How often the expensive unit scan runs. Opening the popup never scans;
	-- it shows the last snapshot (the footer says which turn it is from).
	SCAN_INTERVAL_TURNS = 3,

	-- Ranking score = Military Might + (nukes * NUKE_WEIGHT)
	NUKE_WEIGHT = 50,

	-- Only list yourself and civs your team has met.
	--   "auto" = on in multiplayer/hotseat (no fog-of-war leaks), off in single player
	--   true / false = force it
	ONLY_MET_CIVS = "auto",

	-- true = a war against a city-state also shows the [ICON_WAR] marker
	WAR_INCLUDES_CITY_STATES = false,
}

-------------------------------------------------------------------------------
-- TEXT (kept in Lua on purpose: the mod makes NO database changes)
-------------------------------------------------------------------------------
local TEXT = {
	TITLE_COLD   = "[COLOR_CYAN]COLD WAR[ENDCOLOR]",
	TITLE_HOT    = "[COLOR_NEGATIVE_TEXT]HOT WAR[ENDCOLOR]",
	TOOLTIP_HINT = "Click to view the global power rankings.",

	-- %s = top power, %s = second power, %d = their combined warheads (HOT only)
	DESC_HOT        = "[COLOR_NEGATIVE_TEXT]The Cold War has turned hot![ENDCOLOR] %s and %s are at war, and together they hold %d nuclear warheads. Nuclear war is imminent.",
	DESC_HOT_NONUKE = "[COLOR_NEGATIVE_TEXT]The Cold War has turned hot![ENDCOLOR] %s and %s are at war, each racing to build the bomb. Nuclear war is imminent.",
	DESC_PROXY      = "%s and %s eye each other across a nuclear divide, and their rivalry is bleeding into proxy wars around the globe. One miscalculation could end it all.",
	DESC_MAD        = "A tense standoff grips the world. %s and %s each wield enough firepower to destroy the other, and only the fear of mutual destruction keeps the peace.",
	DESC_MONOPOLY   = "%s alone holds the bomb, and %s will stop at nothing to close the gap. The balance of terror is dangerously uneven.",
	DESC_RACE       = "The Manhattan Project is complete and the arms race has begun. %s and %s lead the world in military power, each racing to build the arsenal that will decide the age.",
	DESC_ALONE      = "Only one superpower remains. The world waits to see what it does with its strength.",

	SUPERPOWER = "[COLOR_YELLOW]SUPERPOWER[ENDCOLOR]",
	OTHERS     = "OTHER NATIONS",
	COL_NUKES  = "Nukes",
	COL_ARMY   = "Army",
	COL_NAVY   = "Navy",
	COL_MIGHT  = "Might",
	FOOTER     = "Score = Might + %d per nuke. Unit counts as of turn %d.",
}

-------------------------------------------------------------------------------
-- STATE
-------------------------------------------------------------------------------
local g_Unlocked    = false
local g_NukeTypes   = {}
local g_Scan        = {}     -- viewer-independent snapshot (expensive to build)
local g_NeedScan    = true   -- first scan happens as soon as the button unlocks
local g_ScanTurn    = -1000  -- game turn of the last scan
local g_List        = nil    -- viewer-specific sorted list (cheap to build)
local g_Hot         = false
local g_Title       = ""
local g_Desc        = ""
local g_Queued      = false
local g_ErrorLogged = false

local g_SuperMgr   = InstanceManager:new("SuperInstance",   "Root", Controls.Stack)
local g_RowMgr     = InstanceManager:new("RowInstance",     "Root", Controls.Stack)
local g_DividerMgr = InstanceManager:new("DividerInstance", "Root", Controls.Stack)

-------------------------------------------------------------------------------
-- HELPERS
-------------------------------------------------------------------------------
local function SafeRun(fn, ...)
	local ok, err = pcall(fn, ...)
	if not ok and not g_ErrorLogged then
		g_ErrorLogged = true -- log once, never spam
		print("ColdWar UI error: " .. tostring(err))
	end
	return ok
end

local function BuildNukeSet()
	g_NukeTypes = {}
	for _, name in ipairs(CONFIG.NUKE_UNITS) do
		local id = GameInfoTypes[name]
		if id then
			g_NukeTypes[id] = true
		end
	end
end

local function OnlyMetActive()
	if CONFIG.ONLY_MET_CIVS == "auto" then
		return (Game.IsNetworkMultiPlayer() or Game.IsHotSeat()) and true or false
	end
	return CONFIG.ONLY_MET_CIVS and true or false
end

-- Has anyone completed the Manhattan Project? Latches once true. Very cheap.
local function CheckUnlocked()
	if g_Unlocked then
		return true
	end
	if not CONFIG.REQUIRE_MANHATTAN then
		g_Unlocked = true
		return true
	end

	local projectID = GameInfoTypes[CONFIG.MANHATTAN_PROJECT]
	if not projectID then
		return false
	end

	for teamID = 0, GameDefines.MAX_MAJOR_CIVS - 1 do
		local team = Teams[teamID]
		if team and team:GetProjectCount(projectID) > 0 then
			g_Unlocked = true
			return true
		end
	end
	return false
end

-- EXPENSIVE: loops over every unit a player owns.
local function CountMilitary(player)
	local nukes, army, navy = 0, 0, 0
	local DOMAIN_SEA = DomainTypes.DOMAIN_SEA
	for unit in player:Units() do
		if g_NukeTypes[unit:GetUnitType()] then
			nukes = nukes + 1
		elseif unit:IsCombatUnit() then
			if unit:GetDomainType() == DOMAIN_SEA then
				navy = navy + 1
			else
				army = army + 1 -- land + air
			end
		end
	end
	return nukes, army, navy
end

-- EXPENSIVE: snapshot of every living major civ. Viewer-independent so it can
-- be cached and shared between players in hotseat.
local function ScanAll()
	g_Scan = {}
	for id = 0, GameDefines.MAX_MAJOR_CIVS - 1 do
		local p = Players[id]
		if p and p:IsAlive() then
			local nukes, army, navy = CountMilitary(p)
			g_Scan[#g_Scan + 1] = {
				id      = id,
				team    = p:GetTeam(),
				civName = p:GetCivilizationShortDescription(),
				leader  = p:GetName(),
				nukes   = nukes,
				army    = army,
				navy    = navy,
				might   = p:GetMilitaryMight(),
			}
		end
	end
	g_NeedScan = false
	g_ScanTurn = Game.GetGameTurn()
end

-- CHEAP: O(civs) team lookups.
local function IsAtWarWithAnyone(player)
	local myID   = player:GetID()
	local myTeam = player:GetTeam()
	local team   = Teams[myTeam]
	local last   = GameDefines.MAX_MAJOR_CIVS - 1
	if CONFIG.WAR_INCLUDES_CITY_STATES then
		last = GameDefines.MAX_CIV_PLAYERS - 1
	end

	for id = 0, last do
		if id ~= myID then
			local other = Players[id]
			if other and other:IsAlive() then
				local otherTeam = other:GetTeam()
				if otherTeam ~= myTeam and team:IsAtWar(otherTeam) then
					return true
				end
			end
		end
	end
	return false
end

-- CHEAP: builds the viewer-specific, sorted list from the cached scan.
local function BuildList()
	local list       = {}
	local activeID   = Game.GetActivePlayer()
	local activeTeam = Teams[Game.GetActiveTeam()]
	local filter     = OnlyMetActive() and activeTeam ~= nil

	for _, s in ipairs(g_Scan) do
		local p = Players[s.id]
		if p and p:IsAlive() then
			if (not filter) or s.id == activeID or activeTeam:IsHasMet(s.team) then
				list[#list + 1] = {
					id      = s.id,
					team    = s.team,
					civName = s.civName,
					leader  = s.leader,
					nukes   = s.nukes,
					army    = s.army,
					navy    = s.navy,
					might   = s.might,
					score   = s.might + s.nukes * CONFIG.NUKE_WEIGHT,
					atWar   = IsAtWarWithAnyone(p),
				}
			end
		end
	end

	-- deterministic on every client (tie-break on player id)
	table.sort(list, function(a, b)
		if a.score ~= b.score then
			return a.score > b.score
		end
		return a.id < b.id
	end)
	return list
end

-- Returns isHot, titleText, descriptionText for the current top two.
local function BuildStatus(list)
	local a, b = list[1], list[2]

	if not (a and b) then
		return false, TEXT.TITLE_COLD, TEXT.DESC_ALONE
	end

	local totalNukes = a.nukes + b.nukes

	if a.team ~= b.team and Teams[a.team]:IsAtWar(b.team) then
		if totalNukes > 0 then
			return true, TEXT.TITLE_HOT, string.format(TEXT.DESC_HOT, a.civName, b.civName, totalNukes)
		end
		return true, TEXT.TITLE_HOT, string.format(TEXT.DESC_HOT_NONUKE, a.civName, b.civName)
	end

	if a.nukes > 0 and b.nukes > 0 then
		if a.atWar or b.atWar then
			return false, TEXT.TITLE_COLD, string.format(TEXT.DESC_PROXY, a.civName, b.civName)
		end
		return false, TEXT.TITLE_COLD, string.format(TEXT.DESC_MAD, a.civName, b.civName)
	elseif a.nukes > 0 or b.nukes > 0 then
		local holder, other = a, b
		if a.nukes == 0 then
			holder, other = b, a
		end
		return false, TEXT.TITLE_COLD, string.format(TEXT.DESC_MONOPOLY, holder.civName, other.civName)
	end

	return false, TEXT.TITLE_COLD, string.format(TEXT.DESC_RACE, a.civName, b.civName)
end

-------------------------------------------------------------------------------
-- POPUP
-------------------------------------------------------------------------------
local function FillEntry(inst, e, rank, iconSize, isSuper, activeID)
	CivIconHookup(e.id, iconSize, inst.CivIcon, inst.CivIconBG, inst.CivIconShadow, false, true)

	if isSuper then
		inst.Rank:SetText("[COLOR_YELLOW]" .. rank .. "[ENDCOLOR]")
		inst.Tag:SetText(TEXT.SUPERPOWER)
		inst.Leader:SetText(e.leader)
	else
		inst.Rank:SetText(tostring(rank))
	end
	inst.Name:SetText(e.civName)

	if e.nukes > 0 then
		inst.Nukes:SetText("[COLOR_NEGATIVE_TEXT]" .. e.nukes .. "[ENDCOLOR]")
	else
		inst.Nukes:SetText("0")
	end
	inst.Army:SetText(tostring(e.army))
	inst.Navy:SetText(tostring(e.navy))
	inst.Might:SetText(tostring(math.floor(e.might)))

	inst.WarIcon:SetHide(not e.atWar)
	inst.Self:SetHide(e.id ~= activeID)
end

local function PopulatePopup()
	if not g_List then
		return
	end

	g_SuperMgr:ResetInstances()
	g_RowMgr:ResetInstances()
	g_DividerMgr:ResetInstances()

	Controls.Title:SetText(g_Title)
	Controls.Description:SetText(g_Desc)
	Controls.PanelHot:SetHide(not g_Hot)
	Controls.Footer:SetText(string.format(TEXT.FOOTER, CONFIG.NUKE_WEIGHT, math.max(g_ScanTurn, 0)))

	local activeID = Game.GetActivePlayer()
	for i, e in ipairs(g_List) do
		if i <= 2 then
			FillEntry(g_SuperMgr:GetInstance(), e, i, 64, true, activeID)
		else
			if i == 3 then
				g_DividerMgr:GetInstance().Text:SetText(TEXT.OTHERS)
			end
			FillEntry(g_RowMgr:GetInstance(), e, i, 45, false, activeID)
		end
	end

	Controls.Stack:CalculateSize()
	Controls.Stack:ReprocessAnchoring()
	Controls.Scroll:CalculateInternalSize()
end

local function HidePopup()
	Controls.Popup:SetHide(true)
end

-------------------------------------------------------------------------------
-- REFRESH
-------------------------------------------------------------------------------
local function DoRefresh()
	if not CheckUnlocked() then
		Controls.ColdWarButton:SetHide(true)
		HidePopup()
		return
	end

	if g_NeedScan then
		ScanAll()
	end
	g_List = BuildList()
	g_Hot, g_Title, g_Desc = BuildStatus(g_List)

	Controls.ColdWarButton:SetHide(false)
	Controls.HotGlow:SetHide(not g_Hot)
	Controls.ColdWarButton:SetToolTipString(g_Title .. "[NEWLINE]" .. TEXT.TOOLTIP_HINT)

	if not Controls.Popup:IsHidden() then
		PopulatePopup()
	end
end

-- Immediate refresh (used when the player clicks the button). Only scans if
-- no snapshot exists yet.
local function RefreshNow(rescan)
	if rescan then
		g_NeedScan = true
	end
	return SafeRun(DoRefresh)
end

-- Deferred, coalesced refresh (used by game events). Any number of calls in
-- the same frame result in a single refresh; the per-frame hook is removed as
-- soon as it has run, so there is no idle cost.
local function OnUpdate()
	ContextPtr:ClearUpdate()
	g_Queued = false
	RefreshNow(false)
end

local function QueueRefresh(rescan)
	if rescan then
		g_NeedScan = true
	end
	if not g_Queued then
		g_Queued = true
		ContextPtr:SetUpdate(OnUpdate)
	end
end

local function ShowPopup()
	if not RefreshNow(false) or not g_List then
		return
	end
	Controls.Popup:SetHide(false)
	SafeRun(PopulatePopup)

	Controls.FadeAnim:SetToBeginning()
	Controls.FadeAnim:Play()
	Controls.SlideAnim:SetToBeginning()
	Controls.SlideAnim:Play()
end

-------------------------------------------------------------------------------
-- BUTTON ICON
-------------------------------------------------------------------------------
local function ApplyButtonIcon()
	local icon = Controls.ButtonIcon

	if CONFIG.ICON_ATLAS then
		if IconHookup(CONFIG.ICON_INDEX or 0, 45, CONFIG.ICON_ATLAS, icon) then
			return
		end
	end

	if CONFIG.ICON_TEXTURE then
		icon:SetTexture(CONFIG.ICON_TEXTURE)
		return
	end

	local tech = GameInfo.Technologies[CONFIG.ICON_TECH]
	if tech then
		IconHookup(tech.PortraitIndex, 45, tech.IconAtlas, icon)
	end
end

-------------------------------------------------------------------------------
-- INPUT
-------------------------------------------------------------------------------
local function OnButtonClicked()
	if Controls.Popup:IsHidden() then
		ShowPopup()
	else
		HidePopup()
	end
end

ContextPtr:SetInputHandler(function(uiMsg, wParam, lParam)
	if (not Controls.Popup:IsHidden()) and uiMsg == KeyEvents.KeyDown and wParam == Keys.VK_ESCAPE then
		HidePopup()
		return true
	end
	return false
end)

-------------------------------------------------------------------------------
-- EVENTS
-------------------------------------------------------------------------------
local function OnTurnStart()
	-- rescan units only every SCAN_INTERVAL_TURNS turns; otherwise just rebuild
	-- the list from the cached scan (cheap) so war / Hot War state stays current
	if Game.GetGameTurn() - g_ScanTurn >= CONFIG.SCAN_INTERVAL_TURNS then
		g_NeedScan = true
	end
	QueueRefresh(false)
end

local function OnWarStateChanged() QueueRefresh(false) end  -- cached scan is still valid
local function OnLoadScreenClose() QueueRefresh(false) end  -- g_NeedScan is already true on a fresh load

local function OnActivePlayerChanged()
	-- hotseat / observer switch: drop the old viewer's popup, rebuild for the new one
	HidePopup()
	ApplyButtonIcon()
	QueueRefresh(false)
end

ContextPtr:SetShutdown(function()
	Events.ActivePlayerTurnStart.Remove(OnTurnStart)
	Events.WarStateChanged.Remove(OnWarStateChanged)
	Events.GameplaySetActivePlayer.Remove(OnActivePlayerChanged)
	Events.LoadScreenClose.Remove(OnLoadScreenClose)
	ContextPtr:ClearUpdate()
end)

-------------------------------------------------------------------------------
-- INIT
-------------------------------------------------------------------------------
local function Initialize()
	BuildNukeSet()

	Controls.ColdWarButton:SetOffsetVal(CONFIG.BUTTON_OFFSET_X, CONFIG.BUTTON_OFFSET_Y)
	Controls.Popup:SetHide(true)
	ApplyButtonIcon()

	Controls.HdrNukes:SetText(TEXT.COL_NUKES)
	Controls.HdrArmy:SetText(TEXT.COL_ARMY)
	Controls.HdrNavy:SetText(TEXT.COL_NAVY)
	Controls.HdrMight:SetText(TEXT.COL_MIGHT)

	Controls.ColdWarButton:RegisterCallback(Mouse.eLClick, OnButtonClicked)
	Controls.CloseButton:RegisterCallback(Mouse.eLClick, HidePopup)
	Controls.Backdrop:RegisterCallback(Mouse.eLClick, HidePopup)

	-- cheap triggers only: your turn starting, a war starting / ending, load, player switch
	Events.ActivePlayerTurnStart.Add(OnTurnStart)
	Events.WarStateChanged.Add(OnWarStateChanged)
	Events.GameplaySetActivePlayer.Add(OnActivePlayerChanged)
	Events.LoadScreenClose.Add(OnLoadScreenClose)

	QueueRefresh(false)
end

Initialize()