--====================================================================================================================
-- USER INTERFACE OPTIONS
--====================================================================================================================

ContextPtr:SetHide(true)

local m_bDialogOpen = false

local g_UserData = Modding.OpenUserData("GAIA_UIOptions", 1)
if not g_UserData then
	MapModData.GAIA_UIOptions = MapModData.GAIA_UIOptions or {}
	local t = MapModData.GAIA_UIOptions
	g_UserData = { GetValue = function(k) return t[k] end, SetValue = function(k, v) t[k] = v end }
end

--====================================================================================================================
-- SMALL RESOURCE ICONS
--====================================================================================================================

local function IsSmallIconsEnabled()
	return g_UserData.GetValue("SmallResourceIcons") == 1
end

Controls.SmallIconsCheck:SetCheck(IsSmallIconsEnabled())

Events.LoadScreenClose.Add(function()
	LuaEvents.RIM_SetSize(IsSmallIconsEnabled())
end)

-- Toggle
Controls.SmallIconsCheck:RegisterCheckHandler(function(bIsChecked)
	g_UserData.SetValue("SmallResourceIcons", bIsChecked and 1 or 0)
	LuaEvents.RIM_SetSize(bIsChecked)
end)

--====================================================================================================================
-- PROMOTION FLAGS
--====================================================================================================================

local function IsPromotionFlagsEnabled()
	return g_UserData.GetValue("PromotionFlags") == 1
end

Controls.PromotionFlagsCheck:SetCheck(IsPromotionFlagsEnabled())

-- Toggle
Controls.PromotionFlagsCheck:RegisterCheckHandler(function(bIsChecked)
	g_UserData.SetValue("PromotionFlags", bIsChecked and 1 or 0)
	LuaEvents.PromotionFlags(bIsChecked)
end)

--====================================================================================================================
-- AUTO END TURN BUTTON
--====================================================================================================================

local function IsAutoEndTurnButtonEnabled()
	return g_UserData.GetValue("AutoEndTurnButton") ~= 0
end

Controls.AutoEndTurnButtonCheck:SetCheck(IsAutoEndTurnButtonEnabled())

-- Toggle
Controls.AutoEndTurnButtonCheck:RegisterCheckHandler(function(bIsChecked)
	g_UserData.SetValue("AutoEndTurnButton", bIsChecked and 1 or 0)
	LuaEvents.GaiaAutoEndTurnButtonChanged()
end)

--====================================================================================================================
-- PRODUCTION MENU
--====================================================================================================================

local function IsGaiaUIModActive()
	for _, mod in ipairs(Modding.GetActivatedMods()) do
		if mod.ID == "cab8584b-84a2-4c19-a4d8-bb163f129faa" then
			return true
		end
	end
	return Locale.ConvertTextKey("TXT_KEY_TP_NO_GREAT_PERSON") ~= "TXT_KEY_TP_NO_GREAT_PERSON"
end

if IsGaiaUIModActive() then
	Controls.ProductionSortCheck:SetCheck(g_UserData.GetValue("ProductionSort") == 1)

	-- Toggle
	Controls.ProductionSortCheck:RegisterCheckHandler(function(bIsChecked)
		g_UserData.SetValue("ProductionSort", bIsChecked and 1 or 0)
	end)

	Controls.ProductionHideCheck:SetCheck(g_UserData.GetValue("ProductionHide") ~= 0)
	Controls.ProductionHideCheck:RegisterCheckHandler(function(bIsChecked)
		g_UserData.SetValue("ProductionHide", bIsChecked and 1 or 0)
	end)
else
	Controls.ProductionSortCheck:SetHide(true)
	Controls.ProductionHideCheck:SetHide(true)
end

--====================================================================================================================
-- MAP OVERLAYS
--====================================================================================================================

local g_OverlayChildren = {
	{ control = Controls.OverlayCityLimitsCheck,   key = "MapOverlays_CityLimits"   },
	{ control = Controls.OverlayCommanderCheck,    key = "MapOverlays_Commander"    },
	{ control = Controls.OverlayDigSitesCheck,     key = "MapOverlays_DigSites"     },
	{ control = Controls.OverlayMovementPathCheck, key = "MapOverlays_MovementPath" },
}

local function IsMapOverlaysEnabled()
	return g_UserData.GetValue("MapOverlays") == 1
end

local function IsOverlayChildOn(sKey)
	return g_UserData.GetValue(sKey) ~= 0
end

local function UpdateOverlayChildState()
	local bEnabled = IsMapOverlaysEnabled()
	for _, child in ipairs(g_OverlayChildren) do
		child.control:SetDisabled(not bEnabled)
	end
end

Controls.OverlayMasterCheck:SetCheck(IsMapOverlaysEnabled())
for _, child in ipairs(g_OverlayChildren) do
	child.control:SetCheck(IsOverlayChildOn(child.key))
end
UpdateOverlayChildState()

-- Master toggle
Controls.OverlayMasterCheck:RegisterCheckHandler(function(bIsChecked)
	g_UserData.SetValue("MapOverlays", bIsChecked and 1 or 0)
	UpdateOverlayChildState()
	LuaEvents.GaiaMapOverlaysChanged()
end)

-- Per-overlay toggles
for _, child in ipairs(g_OverlayChildren) do
	child.control:RegisterCheckHandler(function(bIsChecked)
		g_UserData.SetValue(child.key, bIsChecked and 1 or 0)
		LuaEvents.GaiaMapOverlaysChanged()
	end)
end

--====================================================================================================================
-- QUICK ANIMATIONS
--====================================================================================================================

local g_QuickAnimChildren = {
	{ control = Controls.QuickAnimPlayerWarCheck,   key = "QuickAnimations_NoPlayerWar"   },
	{ control = Controls.QuickAnimAIWarCheck,       key = "QuickAnimations_NoAIWar"       },
	{ control = Controls.QuickAnimPlayerPeaceCheck, key = "QuickAnimations_NoPlayerPeace" },
	{ control = Controls.QuickAnimBarbariansCheck,  key = "QuickAnimations_NoBarbarian"   },
}

local function QuickAnim()
	return MapModData.FuriousTurns
end

local function IsQuickAnimEnabled()
	local qa = QuickAnim()
	return qa ~= nil and qa.GetOptionValue("QuickAnimations") == 1
end

local function IsQuickAnimAvailable()
	return not Game.IsNetworkMultiPlayer()
end

local function UpdateQuickAnimChildState()
	local bEnabled = IsQuickAnimEnabled() and IsQuickAnimAvailable()
	for _, child in ipairs(g_QuickAnimChildren) do
		child.control:SetDisabled(not bEnabled)
	end
end

local function SyncQuickAnimCheckboxes()
	local qa = QuickAnim()
	if not qa then return end
	Controls.QuickAnimMasterCheck:SetCheck(qa.GetOptionValue("QuickAnimations") == 1)
	Controls.QuickAnimMasterCheck:SetDisabled(not IsQuickAnimAvailable())
	for _, child in ipairs(g_QuickAnimChildren) do
		child.control:SetCheck(qa.GetOptionValue(child.key) == 1)
	end
	UpdateQuickAnimChildState()
end

-- Master toggle
Controls.QuickAnimMasterCheck:RegisterCheckHandler(function(bIsChecked)
	local qa = QuickAnim()
	if qa then qa.SetOptionValue("QuickAnimations", bIsChecked and 1 or 0) end
	UpdateQuickAnimChildState()
end)

-- Per-animation toggles
for _, child in ipairs(g_QuickAnimChildren) do
	child.control:RegisterCheckHandler(function(bIsChecked)
		local qa = QuickAnim()
		if qa then qa.SetOptionValue(child.key, bIsChecked and 1 or 0) end
	end)
end

local function ApplyQuickAnimOnClose()
	local qa = QuickAnim()
	if not qa or not qa.IsPlayerTurn or qa.GetOptionValue("QuickAnimations") ~= 1 then return end
	local tPlayer = Teams[Game.GetActiveTeam()]
	local sKey = "QuickAnimations_NoPlayerPeace"
	for iTarget = 0, GameDefines.MAX_PLAYERS - 1 do
		local pTarget = Players[iTarget]
		if pTarget:IsAlive() and not pTarget:IsMinorCiv() and not pTarget:IsBarbarian() and tPlayer:IsAtWar(pTarget:GetTeam()) then
			sKey = "QuickAnimations_NoPlayerWar"
			break
		end
	end
	qa.SetAnimations(qa.GetOptionValue(sKey) == 1)
end

--====================================================================================================================
-- DIALOG CONTROL
--====================================================================================================================

local function OpenDialog()
	SyncQuickAnimCheckboxes()
	ContextPtr:SetHide(false)
	m_bDialogOpen = true
end

local function CloseDialog()
	ApplyQuickAnimOnClose()
	ContextPtr:SetHide(true)
	m_bDialogOpen = false
end

Controls.CloseButton:RegisterCallback(Mouse.eLClick, CloseDialog)

ContextPtr:SetInputHandler(function(uiMsg, wParam)
	if not m_bDialogOpen then return false end
	if uiMsg == KeyEvents.KeyDown and wParam == Keys.VK_ESCAPE then CloseDialog() end
	return true
end)

--====================================================================================================================
-- DROPDOWN INTEGRATION
--====================================================================================================================

LuaEvents.AdditionalInformationDropdownGatherEntries.Add(function(entries)
	table.insert(entries, { text = Locale.ConvertTextKey("TXT_KEY_GAIA_UI_OPTIONS"), call = OpenDialog })
end)

LuaEvents.RequestRefreshAdditionalInformationDropdownEntries()
