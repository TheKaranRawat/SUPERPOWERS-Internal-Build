-------------------------------------------------
-- Religion Overview
-------------------------------------------------
include( "IconSupport" );
include( "InstanceManager" );

-------------------------------------------------
-- Tabs
-------------------------------------------------
g_Tabs = {
	["YourReligion"] = {
		Panel = Controls.YourReligionPanel,
		SelectHighlight = Controls.YourReligionSelectHighlight,
	},
	["WorldReligion"] = {
		Panel = Controls.WorldReligionPanel,
		SelectHighlight = Controls.WorldReligionsSelectHighlight,
	},
	["Beliefs"] = {
		Panel = Controls.BeliefsPanel,
		SelectHighlight = Controls.BeliefsSelectHighlight,
	},
	["Map"] = {
		Panel = Controls.MapPanel,
		SelectHighlight = Controls.MapSelectHighlight,
	},
}

g_BeliefSortOptions = {
	{
		Button = Controls.BPSortbyName,
		ImageControl = Controls.BPSortbyNameImage,
		Column = "Name",
		DefaultDirection = "asc",
		CurrentDirection = "asc",
	},
	{
		Button = Controls.BPSortbyType,
		ImageControl = Controls.BPSortbyTypeImage,
		Column = "Type",
		DefaultDirection = "desc",
		CurrentDirection = nil,
	},
	{
		Button = Controls.BPSortbyBonus,
		ImageControl = Controls.BPSortbyBonusImage,
		Column = "Description",
		DefaultDirection = "desc",
		CurrentDirection = nil,
	},
	{
		Button = Controls.BPSortbyReligion,
		ImageControl = Controls.BPSortbyReligionImage,
		Column = "Religion",
		DefaultDirection = "desc",
		CurrentDirection = nil,
	},
};

g_WorldReligionSortOptions = {
	{
		Button = Controls.WRSortByReligion,
		ImageControl = Controls.WRSortByReligionImage,
		Column = "Name",
		DefaultDirection = "asc",
		CurrentDirection = "asc",
	},
	{
		Button = Controls.WRSortByHolyCity,
		ImageControl = Controls.WRSortByHolyCityImage,
		Column = "HolyCity",
		DefaultDirection = "desc",
		CurrentDirection = nil,
	},
	{
		Button = Controls.WRSortByFounder,
		ImageControl = Controls.WRSortByFounderImage,
		Column = "Founder",
		DefaultDirection = "desc",
		CurrentDirection = nil,
	},
	{
		Button = Controls.WRSortByNumYear,
		ImageControl = Controls.WRSortByNumYearImage,
		Column = "NumYears",
		DefaultDirection = "desc",
		SortType = "numeric",
		CurrentDirection = nil,
	},
	{
		Button = Controls.WRSortByNumCities,
		ImageControl = Controls.WRSortByNumCitiesImage,
		Column = "NumCities",
		DefaultDirection = "desc",
		SortType = "numeric",
		CurrentDirection = nil,
	},
	{
		Button = Controls.WRSortByNumFollowers,
		ImageControl = Controls.WRSortByNumFollowersImage,
		Column = "NumFollowers",
		DefaultDirection = "desc",
		SortType = "numeric",
		CurrentDirection = nil,
	},
};

local g_ReligiousBeliefsManager = InstanceManager:new("YourReligiousBeliefInstance", "Base", Controls.YourReligiousBeliefsStack)
local g_FaithModifierManager = InstanceManager:new("FaithModifierInstance", "FaithModifier", Controls.FaithModifierStack)
local g_WorldReligionsManager = InstanceManager:new( "WorldReligionInstance", "Base", Controls.WorldReligionsStack)
local g_BeliefsManager = InstanceManager:new( "BeliefInstance", "Base", Controls.BeliefsStack)
local g_BeliefSortFunction, g_WorldReligionSortFunction, g_CurrentTab, g_PopupInfo

-------------------------------------------------
-- Religion-map palette and setup
-------------------------------------------------
local tColours = {
	UNKNOWN		= {r=190, g=190, b=190, a=1.0},
	NONE		= {r=0,   g=0,   b=0,   a=0.0},
	WATER		= {r=0,   g=0,   b=0,   a=0.0},
	ICE			= {r=189, g=242, b=255, a=0.7},
	CITY		= {r=0,   g=0,   b=0,   a=1.0},
	HOLY_CITY	= {r=255, g=255, b=0,   a=1.0}
}

local iFeatureIce = GameInfoTypes.FEATURE_ICE
local iTerrainDesert = GameInfoTypes.TERRAIN_DESERT

local mapWidth, mapHeight = Map.GetGridSize()
Controls.ReligionMap:SetMapSize(mapWidth, mapHeight, 0, -1)

g_CurrentTab = nil;

-------------------------------------------------
-- Shared helpers
-------------------------------------------------
function GetReligiousStatus()

	local text = nil;
	local player = Players[Game.GetActivePlayer()];
	if(player:HasCreatedReligion()) then
		local eReligion = player:GetReligionCreatedByPlayer();
		text = Locale.Lookup("TXT_KEY_RO_STATUS_FOUNDER", Game.GetReligionName(eReligion));
	elseif(player:HasCreatedPantheon()) then
		text = Locale.Lookup("TXT_KEY_RO_STATUS_CREATED_PANTHEON");
	elseif(player:CanCreatePantheon(true)) then
		text = Locale.Lookup("TXT_KEY_RO_STATUS_CAN_CREATE_PANTHEON");
	elseif(player:CanCreatePantheon(false)) then
		local minRequiredFaith = Game.GetMinimumFaithNextPantheon();
		local currentFaith = player:GetFaith();
		local faithNeeded = minRequiredFaith - currentFaith;
		text = Locale.Lookup("TXT_KEY_RO_STATUS_NEED_FAITH" , faithNeeded);
	else
		text = Locale.Lookup("TXT_KEY_RO_STATUS_TOO_LATE");
	end

	return text;
end

function GetBeliefType(belief)
	if(belief.Pantheon) then
		return Locale.Lookup("TXT_KEY_RO_BELIEF_TYPE_PANTHEON");
	elseif(belief.Founder) then
		return Locale.Lookup("TXT_KEY_RO_BELIEF_TYPE_FOUNDER");
	elseif(belief.Follower) then
		return Locale.Lookup("TXT_KEY_RO_BELIEF_TYPE_FOLLOWER");
	elseif(belief.Enhancer) then
		return Locale.Lookup("TXT_KEY_RO_BELIEF_TYPE_ENHANCER");
	elseif(belief.Reformation) then
		return Locale.Lookup("TXT_KEY_RO_BELIEF_TYPE_REFORMATION");
	end
end

-------------------------------------------------
-- Popup show / hide / input
-------------------------------------------------
function OnPopupMessage(popupInfo)

	local popupType = popupInfo.Type;
	if popupType ~= ButtonPopupTypes.BUTTONPOPUP_RELIGION_OVERVIEW then
		return;
	end

	if(not Game.IsOption(GameOptionTypes.GAMEOPTION_NO_RELIGION)) then
		g_PopupInfo = popupInfo;

		if( g_PopupInfo.Data1 == 1 ) then
			if( ContextPtr:IsHidden() == false ) then
				OnClose();
			else
				UIManager:QueuePopup( ContextPtr, PopupPriority.InGameUtmost );
			end
		else
			UIManager:QueuePopup( ContextPtr, PopupPriority.SocialPolicy );
		end
	end
end
Events.SerialEventGameMessagePopup.Add( OnPopupMessage );

function InputHandler( uiMsg, wParam, lParam )
	if(uiMsg == KeyEvents.KeyDown) then
		if (wParam == Keys.VK_ESCAPE) then
			OnClose();
			return true;
		end
		if(wParam == Keys.VK_RETURN) then
			return true;
		end
	end
end
ContextPtr:SetInputHandler( InputHandler );

function OnClose()
	UIManager:DequeuePopup(ContextPtr);
end
Controls.CloseButton:RegisterCallback(Mouse.eLClick, OnClose);

-------------------------------------------------
-- Tab switching
-------------------------------------------------
function TabSelect(tab)
	for i,v in pairs(g_Tabs) do
		local bHide = i ~= tab;
		v.Panel:SetHide(bHide);
		v.SelectHighlight:SetHide(bHide);
	end
	g_CurrentTab = tab;
	g_Tabs[tab].RefreshContent();
end
Controls.TabButtonYourReligion:RegisterCallback( Mouse.eLClick, function() TabSelect("YourReligion"); end);
Controls.TabButtonWorldReligions:RegisterCallback( Mouse.eLClick, function() TabSelect("WorldReligion"); end );
Controls.TabButtonBeliefs:RegisterCallback( Mouse.eLClick, function() TabSelect("Beliefs"); end );
Controls.TabButtonMap:RegisterCallback( Mouse.eLClick, function() TabSelect("Map"); end );

-------------------------------------------------
-- Tab: Your Religion
-------------------------------------------------
function RefreshYourReligion()
	local player = Players[Game.GetActivePlayer()];
	local capital = player:GetCapitalCity();

	local minFaithForProphet = tostring(player:GetMinimumFaithNextGreatProphet());
	Controls.CurrentFaith:LocalizeAndSetText("TXT_KEY_RO_FAITH", player:GetFaith(), minFaithForProphet);
	Controls.CurrentFaith:LocalizeAndSetToolTip("TXT_KEY_RO_FAITH_TOOLTIP", minFaithForProphet);

	-- Faith-per-turn breakdown
	g_FaithModifierManager:ResetInstances();
	local faithSources = {
		{ "TXT_KEY_TP_FAITH_FROM_CITIES",   player:GetFaithPerTurnFromCities() },
		{ "TXT_KEY_TP_FAITH_FROM_MINORS",   player:GetFaithPerTurnFromMinorCivs() },
		{ "TXT_KEY_TP_FAITH_FROM_RELIGION", player:GetFaithPerTurnFromReligion() },
	};
	for _, source in ipairs(faithSources) do
		local amount = source[2];
		if amount ~= 0 then
			g_FaithModifierManager:GetInstance().FaithModifier:LocalizeAndSetText(source[1], amount);
		end
	end

	-- Great People currently unlocked for faith purchase
	local unlockedGreatPeople = {}
	if(capital ~= nil) then
		for info in GameInfo.Units{Special = "SPECIALUNIT_PEOPLE"} do
			local infoID = info.ID;
			local faithCost = capital:GetUnitFaithPurchaseCost(infoID, true);
			if(faithCost > 0 and player:IsCanPurchaseAnyCity(false, true, infoID, -1, YieldTypes.YIELD_FAITH)) then
				if (player:DoesUnitPassFaithPurchaseCheck(infoID)) then
					table.insert(unlockedGreatPeople, Locale.Lookup(info.Description));
				end
			end
		end
	end

	table.sort(unlockedGreatPeople, function(a,b) return Locale.Compare(a,b) == -1 end);

	for i = 1,9,1 do
		Controls["GreatPersonName" .. i]:SetHide(true);
	end

	for i,v in ipairs(unlockedGreatPeople) do
		local c = Controls["GreatPersonName" .. i];
		if(c ~= nil) then
			c:SetText("[ICON_BULLET] " .. v);
			c:SetHide(false);
		end
	end

	if(#unlockedGreatPeople == 0) then
		local c = Controls["GreatPersonName" .. 1];
		c:LocalizeAndSetText("TXT_KEY_RO_YR_NO_GREAT_PEOPLE");
		c:SetHide(false);
	end

	Controls.GreatPersonList:CalculateSize();

	-- Founder icon: religion, else pantheon, else hidden
	if(player:HasCreatedReligion()) then
		local religion = GameInfo.Religions[player:GetReligionCreatedByPlayer()];
		IconHookup(religion.PortraitIndex, 80, religion.IconAtlas, Controls.FounderReligionIcon);
		Controls.FounderReligionIcon:SetHide(false);
	elseif(player:HasCreatedPantheon()) then
		local pantheon = GameInfo.Religions["RELIGION_PANTHEON"];
		IconHookup(pantheon.PortraitIndex, 80, pantheon.IconAtlas, Controls.FounderReligionIcon);
		Controls.FounderReligionIcon:SetHide(false);
	else
		Controls.FounderReligionIcon:SetHide(true);
	end

	CivIconHookup(player:GetID(), 80, Controls.FounderIcon, Controls.FounderIconBG, Controls.FounderIconShadow, true, true );

	Controls.ReligiousStatus:SetText(GetReligiousStatus());

	g_ReligiousBeliefsManager:ResetInstances();
	Controls.YourReligionNoBeliefs:SetHide(true);
	Controls.YourReligiousBeliefsStack:SetHide(false);

	local function AddBeliefRow(belief)
		local entry = g_ReligiousBeliefsManager:GetInstance();
		entry.BeliefType:SetText(GetBeliefType(belief));
		entry.BeliefName:LocalizeAndSetText(belief.ShortDescription);
		entry.BeliefDescription:LocalizeAndSetText(belief.Description);
		entry.BeliefDescription:LocalizeAndSetToolTip(belief.Description);
		local bw,bh = entry.Base:GetSizeVal();
		local bdw,bdh = entry.BeliefDescription:GetSizeVal();
		entry.Base:SetSizeVal(bw, bdh + 18);
	end

	if (player:HasCreatedReligion()) then
		local eReligion = player:GetReligionCreatedByPlayer();
		for i,v in ipairs(Game.GetBeliefsInReligion(eReligion)) do
			local belief = GameInfo.Beliefs[v];
			if (belief ~= nil) then
				AddBeliefRow(belief);
			end
		end
	elseif (player:HasCreatedPantheon()) then
		local belief = GameInfo.Beliefs[player:GetBeliefInPantheon()];
		if(belief ~= nil) then
			AddBeliefRow(belief);
		end
	else
		Controls.YourReligionNoBeliefs:SetHide(false);
		Controls.YourReligiousBeliefsStack:SetHide(true);
	end

	Controls.YourReligiousBeliefsStack:CalculateSize();
	Controls.YourReligiousBeliefsStack:ReprocessAnchoring();
	Controls.YourReligiousBeliefsScrollPanel:CalculateInternalSize();

	-- Automatic faith-purchase pulldown
	local automaticPurchasePullDown = Controls.AutomaticPurchasePD;

	local function AddToPullDown(text, tooltip, v1, v2)
		local controlTable = {};
		automaticPurchasePullDown:BuildEntry( "InstanceOne", controlTable );
		controlTable.Button:SetVoids(v1, v2);
		controlTable.Button:SetText(text);
		controlTable.Button:SetToolTipString(tooltip);
	end

	local function SetCurrentSelection(v1, v2)
		if (v1 == FaithPurchaseTypes.NO_AUTOMATIC_FAITH_PURCHASE) then
			automaticPurchasePullDown:GetButton():LocalizeAndSetText("TXT_KEY_RO_AUTO_FAITH_PROMPT");
		elseif (v1 == FaithPurchaseTypes.FAITH_PURCHASE_SAVE_PROPHET) then
			automaticPurchasePullDown:GetButton():LocalizeAndSetText("TXT_KEY_RO_AUTO_FAITH_PROPHET");
		elseif (v1 == FaithPurchaseTypes.FAITH_PURCHASE_UNIT) then
			local faithCost = capital:GetUnitFaithPurchaseCost(v2, true);
			if (faithCost == 0 and player:DoesUnitPassFaithPurchaseCheck(v2)) then
				for pCity in player:Cities() do
					faithCost = pCity:GetUnitFaithPurchaseCost(v2, true)
					if (faithCost > 0) then
						break;
					end
				end
			end
			local gpString = string.format("%s (%i [ICON_PEACE])", Locale.Lookup(GameInfo.Units[v2].Description), faithCost);
			automaticPurchasePullDown:GetButton():LocalizeAndSetText("TXT_KEY_RO_AUTO_FAITH_PURCHASE_GREAT_PERSON", gpString);
		else
			local faithCost = capital:GetBuildingFaithPurchaseCost(v2, true);
			if (faithCost == 0) then
				for pCity in player:Cities() do
					local faithCost = pCity:GetBuildingFaithPurchaseCost(v2, true);
					if (faithCost > 0) then
						break;
					end
				end
			end
			local gpString = string.format("%s (%i [ICON_PEACE])", Locale.Lookup(GameInfo.Buildings[v2].Description), faithCost);
			automaticPurchasePullDown:GetButton():LocalizeAndSetText("TXT_KEY_RO_AUTO_FAITH_PURCHASE_GREAT_PERSON", gpString);
		end
		automaticPurchasePullDown:GetButton():SetToolTipString("");
	end

	automaticPurchasePullDown:ClearEntries();

	AddToPullDown(Locale.Lookup("TXT_KEY_RO_AUTO_FAITH_PROMPT"), "", FaithPurchaseTypes.NO_AUTOMATIC_FAITH_PURCHASE, 0);

	if (player:GetReligionCreatedByPlayer() > ReligionTypes.RELIGION_PANTHEON or Game.GetNumReligionsStillToFound() > 0) then
		if (player:GetCurrentEra() < GameInfo.Eras["ERA_INDUSTRIAL"].ID) then
			AddToPullDown(Locale.Lookup("TXT_KEY_RO_AUTO_FAITH_PROPHET"), "", FaithPurchaseTypes.FAITH_PURCHASE_SAVE_PROPHET, 0);
		end
	end

	if(capital ~= nil) then
		for unit in GameInfo.Units() do
			local faithCost = capital:GetUnitFaithPurchaseCost(unit.ID, true);
			local canBuyAnywhere = player:IsCanPurchaseAnyCity(false, true, unit.ID, -1, YieldTypes.YIELD_FAITH);
			if(faithCost > 0 and canBuyAnywhere) then
				if (player:DoesUnitPassFaithPurchaseCheck(unit.ID)) then
					local gpString = string.format("%s (%i [ICON_PEACE])", Locale.Lookup(unit.Description), faithCost);
					AddToPullDown(Locale.Lookup("TXT_KEY_RO_AUTO_FAITH_PURCHASE_GREAT_PERSON", gpString), "", FaithPurchaseTypes.FAITH_PURCHASE_UNIT, unit.ID);
				end
			elseif (canBuyAnywhere) then
				for pCity in player:Cities() do
					if (pCity:GetUnitFaithPurchaseCost(unit.ID, true) > 0) then
						local faithCost = pCity:GetUnitFaithPurchaseCost(unit.ID, true);
						if (player:DoesUnitPassFaithPurchaseCheck(unit.ID)) then
							local gpString = string.format("%s (%i [ICON_PEACE])", Locale.Lookup(unit.Description), faithCost);
							AddToPullDown(Locale.Lookup("TXT_KEY_RO_AUTO_FAITH_PURCHASE_GREAT_PERSON", gpString), "", FaithPurchaseTypes.FAITH_PURCHASE_UNIT, unit.ID);
							break;
						end
					end
				end
			end
		end

		for building in GameInfo.Buildings() do
			local faithCost = capital:GetBuildingFaithPurchaseCost(building.ID, true);
			local canBuyAnywhere = player:IsCanPurchaseAnyCity(false, true, -1, building.ID, YieldTypes.YIELD_FAITH);
			if(faithCost > 0 and canBuyAnywhere) then
				local gpString = string.format("%s (%i [ICON_PEACE])", Locale.Lookup(building.Description), faithCost);
				AddToPullDown(Locale.Lookup("TXT_KEY_RO_AUTO_FAITH_PURCHASE_GREAT_PERSON", gpString), "", FaithPurchaseTypes.FAITH_PURCHASE_BUILDING, building.ID);
			elseif (canBuyAnywhere) then
				for pCity in player:Cities() do
					if (pCity:GetBuildingFaithPurchaseCost(building.ID, true) > 0) then
						local faithCost = pCity:GetBuildingFaithPurchaseCost(building.ID, true);
						local gpString = string.format("%s (%i [ICON_PEACE])", Locale.Lookup(building.Description), faithCost);
						AddToPullDown(Locale.Lookup("TXT_KEY_RO_AUTO_FAITH_PURCHASE_GREAT_PERSON", gpString), "", FaithPurchaseTypes.FAITH_PURCHASE_BUILDING, building.ID);
						break;
					end
				end
			end
		end
	end

	SetCurrentSelection(player:GetFaithPurchaseType(), player:GetFaithPurchaseIndex());

	automaticPurchasePullDown:CalculateInternals();
	automaticPurchasePullDown:RegisterSelectionCallback(function(v1, v2)
		local player = Players[Game.GetActivePlayer()];
		Network.SendFaithPurchase(Game.GetActivePlayer(), v1, v2);
		SetCurrentSelection(v1, v2);
	end);

end
g_Tabs["YourReligion"].RefreshContent = RefreshYourReligion;

-------------------------------------------------
-- Tab: World Religions
-------------------------------------------------
function RefreshWorldReligions()
	g_WorldReligionsManager:ResetInstances()

	local religions = {}
	local activePlayer = Players[Game.GetActivePlayer()]
	local activeTeam = Teams[activePlayer:GetTeam()]

	AssignReligionColours()

	for religion in GameInfo.Religions() do
		local eReligion = religion.ID
		local holyCity = Game.GetHolyCityForReligion(eReligion, -1)
		if holyCity then
			local pPlayer = Players[holyCity:GetOwner()]
			local holyCityName = holyCity:GetName()
			local civName = pPlayer:GetCivilizationDescription()
			local founderID = pPlayer:GetID()

			local tColour = tColours[eReligion]
			if not tColour then
				tColour = { r = 190, g = 190, b = 190, a = 1.0 }
			end

			local bMet = true
			if not activeTeam:IsHasMet(pPlayer:GetTeam()) then
				founderID = -1
				holyCityName = "TXT_KEY_RO_WR_UNKNOWN_HOLY_CITY"
				civName = "TXT_KEY_RO_WR_UNKNOWN_CIV"
				bMet = false
			end

			-- Founding year
			local iFoundYear = Game._GetFoundYear and Game._GetFoundYear(eReligion)
			if iFoundYear == nil or iFoundYear < 0 then
				iFoundYear = 0
			end

			table.insert(religions, {
				Name = Locale.Lookup(Game.GetReligionName(eReligion)),
				ReligionIconIndex = religion.PortraitIndex,
				ReligionIconAtlas = religion.IconAtlas,
				FounderID = founderID,
				HolyCity = Locale.Lookup(holyCityName),
				Founder = Locale.Lookup(civName),
				NumCities = Game.GetNumCitiesFollowing(eReligion),
				NumYears = iFoundYear,
				ReligionID = eReligion,
				Colour = { x = tColour.r / 255, y = tColour.g / 255, z = tColour.b / 255, w = tColour.a },
				NumFollowers = Game.GetNumFollowers(eReligion),
				FounderAlive = pPlayer:IsAlive(),
				Met = bMet
			})
		end
	end

	if #religions > 0 then
		Controls.WorldReligionsScrollPanel:SetHide(false)
		Controls.NoWorldReligions:SetHide(true)

		table.sort(religions, g_WorldReligionSortFunction)

		for i, v in ipairs(religions) do
			local entry = g_WorldReligionsManager:GetInstance()
			entry.ReligionName:SetText(v.Name)
			if v.Met then
				entry.ReligionName:SetColor(v.Colour, 0)
			end
			entry.HolyCityName:SetText(v.HolyCity)
			entry.Founder:SetText(v.Founder)

			-- Year founded
			if Game.GetTurnYear(v.NumYears) ~= nil and Game._GetDateString then
				entry.YearFounded:SetText(Game._GetDateString(v.NumYears))
			else
				entry.YearFounded:SetText("?")
			end

			entry.NumberOfCities:SetText(v.NumCities)
			entry.NumberOfFollowers:SetText(v.NumFollowers)

			IconHookup(v.ReligionIconIndex, 48, v.ReligionIconAtlas, entry.WorldReligionIcon)
			CivIconHookup(v.FounderID, 45, entry.FounderIcon, entry.FounderIconBG, entry.FounderIconShadow, true, true)
		end

		Controls.WorldReligionsStack:CalculateSize()
		Controls.WorldReligionsStack:ReprocessAnchoring()
		Controls.WorldReligionsScrollPanel:CalculateInternalSize()
	else
		Controls.WorldReligionsScrollPanel:SetHide(true)
		Controls.NoWorldReligions:SetHide(false)
	end

	local iReligionsLeft = Game.GetNumReligionsStillToFound()
	if iReligionsLeft < 0 then
		iReligionsLeft = 0
	end
	Controls.NumberOfReligionsCanBeFounded:LocalizeAndSetText("TXT_KEY_TP_FAITH_RELIGIONS_LEFT", iReligionsLeft)

	Controls.TooLateToStartPantheon:SetText(GetReligiousStatus())
end
g_Tabs["WorldReligion"].RefreshContent = RefreshWorldReligions;

-------------------------------------------------
-- Tab: Beliefs
-------------------------------------------------
function RefreshBeliefs()

	g_BeliefsManager:ResetInstances()

	local beliefs = {}

	local activePlayer = Players[Game.GetActivePlayer()]
	local activeTeam = Teams[activePlayer:GetTeam()]

	-- Beliefs of every founded religion
	for religion in GameInfo.Religions() do
		local eReligion = religion.ID
		local holyCity = Game.GetHolyCityForReligion(eReligion, -1)
		if holyCity then
			for i,v in ipairs(Game.GetBeliefsInReligion(eReligion)) do
				local belief = GameInfo.Beliefs[v]

				local beliefName = belief and Locale.Lookup(belief.ShortDescription or "TXT_KEY_GAIA_RELIGION_OVERVIEW_BELIEF_FALLBACK")
				local beliefDescription = belief and Locale.Lookup(belief.Description or "TXT_KEY_GAIA_RELIGION_OVERVIEW_BELIEF_FALLBACK")

				local religionName = Locale.Lookup(Game.GetReligionName(eReligion))

				table.insert(beliefs, {
					Name = beliefName,
					Description = beliefDescription,
					Type = GetBeliefType(belief),
					Tooltip = beliefDescription,
					Religion = religionName,
					ReligionIconIndex = religion.PortraitIndex,
					ReligionIconAtlas = religion.IconAtlas
				})
			end
		end
	end

	for iPlayer = 0, GameDefines.MAX_CIV_PLAYERS - 1 do
		local pPlayer = Players[iPlayer]
		if pPlayer:IsEverAlive() then
			if pPlayer:HasCreatedPantheon() then
				local iBelief = pPlayer:GetBeliefInPantheon()
				local belief = GameInfo.Beliefs[iBelief]

				if belief then
					local religionDisplay
					if not activeTeam:IsHasMet(pPlayer:GetTeam()) then
						religionDisplay = Locale.Lookup("TXT_KEY_RO_BELIEF_UNKNOWN_PANTHEON")
					else
						local civAdj = pPlayer:GetCivilizationAdjectiveKey()
						religionDisplay = Locale.Lookup("TXT_KEY_RO_BELIEF_PANTHEON", civAdj)
					end

					local pantheon = GameInfo.Religions["RELIGION_PANTHEON"]

					table.insert(beliefs, {
						Name = Locale.Lookup(belief.ShortDescription),
						Description = Locale.Lookup(belief.Description),
						Type = GetBeliefType(belief),
						Religion = religionDisplay,
						ReligionIconIndex = pantheon.PortraitIndex,
						ReligionIconAtlas = pantheon.IconAtlas
					})
				end
			end
		end
	end

	if #beliefs > 0 then
		Controls.BeliefsScrollPanel:SetHide(false)
		Controls.NoBeliefs:SetHide(true)

		table.sort(beliefs, g_BeliefSortFunction)

		for i,v in ipairs(beliefs) do
			local beliefEntry = g_BeliefsManager:GetInstance()
			beliefEntry.BeliefName:SetText(v.Name)
			beliefEntry.BeliefType:SetText(v.Type)
			beliefEntry.BeliefDescription:SetText(v.Description)
			beliefEntry.BeliefDescription:SetToolTipString(v.Tooltip)
			beliefEntry.BeliefReligion:SetText(v.Religion)
			IconHookup(v.ReligionIconIndex, 48, v.ReligionIconAtlas, beliefEntry.BeliefReligionIcon)
		end

		Controls.BeliefsStack:CalculateSize()
		Controls.BeliefsStack:ReprocessAnchoring()
		Controls.BeliefsScrollPanel:CalculateInternalSize()

	else
		Controls.BeliefsScrollPanel:SetHide(true)
		Controls.NoBeliefs:SetHide(false)
	end

end
g_Tabs["Beliefs"].RefreshContent = RefreshBeliefs;

-------------------------------------------------
-- Tab: Map (religion spread)
-------------------------------------------------

function AssignReligionColours()
	tColours = {
		UNKNOWN    = {r=190, g=190, b=190, a=1.0},
		NONE       = {r=0,   g=0,   b=0,   a=0.0},
		WATER      = {r=0,   g=0,   b=0,   a=0.0},
		ICE        = {r=189, g=242, b=255, a=0.7},
		CITY       = {r=0,   g=0,   b=0,   a=1.0},
		HOLY_CITY  = {r=255, g=255, b=0,   a=1.0},
	}

	for religion in GameInfo.Religions() do
		local eReligion = religion.ID
		local tColour = {}

		if religion.Type == "RELIGION_PANTHEON" then
			tColour = GameInfo.Colors["COLOR_PLAYER_GRAY"]

		elseif (Game._AnyoneHasReligion and Game._AnyoneHasReligion(eReligion))
			or Game.GetNumCitiesFollowing(eReligion) > 0
			or Game.GetNumFollowers(eReligion) > 0 then

			local pHolyCity = Game.GetHolyCityForReligion(eReligion, -1)
			if pHolyCity then
				local iOwner = pHolyCity:GetOwner()
				local pPlayer = Players[iOwner]

				if not pPlayer:IsAlive() then
					iOwner = pHolyCity:GetOriginalOwner()
					pPlayer = Players[iOwner]
				end

				if not pPlayer:IsAlive() then
					tColour = GameInfo.Colors["COLOR_PLAYER_PEACH"]
				else
					local playerColorInfo = GameInfo.PlayerColors[pPlayer:GetPlayerColor()]
					local primaryColor = GameInfo.Colors[playerColorInfo.PrimaryColor]
					local secondaryColor = GameInfo.Colors[playerColorInfo.SecondaryColor]

					if (primaryColor.Red + primaryColor.Green + primaryColor.Blue) >
					   (secondaryColor.Red + secondaryColor.Green + secondaryColor.Blue) then
						tColour = primaryColor
					else
						tColour = secondaryColor
					end
				end
			else
				tColour = GameInfo.Colors["COLOR_PLAYER_PEACH"]
			end

		else
			-- Unfounded or no followers
			tColour = GameInfo.Colors["COLOR_PLAYER_PEACH"]
		end

		tColours[eReligion] = {
			r = tColour.Red * 255,
			g = tColour.Green * 255,
			b = tColour.Blue * 255,
			a = 1.0
		}
	end
end

function ShadeCities(iTeam)
	for iPlayer=0, GameDefines.MAX_CIV_PLAYERS-1 do
		local pPlayer = Players[iPlayer]

		if (pPlayer:IsAlive()) then
			for pCity in pPlayer:Cities() do
				local iReligion = pCity:GetReligiousMajority()

				if (iReligion > 0) then
					if (tColours[iReligion] == nil) then
						AssignReligionColours()
					end

					ShadeCity(iTeam, pCity, tColours[iReligion])
				end
			end
		end
	end
end

function ShadeCity(iTeam, pCity, colour)
	for i = 1, pCity:GetNumCityPlots()-1, 1 do
		local pPlot = pCity:GetCityIndexPlot(i)

		if (pPlot ~= nil and pPlot:IsRevealed(iTeam)) then
			if (pPlot:GetOwner() == pCity:GetOwner()) then
				if (pPlot:IsLake() or not pPlot:IsWater()) then
					if (pPlot:IsMountain() or pPlot:GetTerrainType() == iTerrainDesert or pCity:IsWorkingPlot(pPlot) or pCity:CanWork(pPlot)) then
						Controls.ReligionMap:SetPlot(pPlot:GetX(), pPlot:GetY(), pPlot:GetTerrainType(), colour.r/255, colour.g/255, colour.b/255, colour.a)
					end
				end
			end
		end
	end
end

function RefreshMap()
	AssignReligionColours()

	local iPlayer = Game.GetActivePlayer()
	local pPlayer = Players[iPlayer]
	local iTeam = pPlayer:GetTeam()

	for y = 0, mapHeight - 1, 1 do
		for x = 0, mapWidth - 1, 1 do
			local pPlot = Map.GetPlot(x, y)
			local colour = tColours.UNKNOWN

			if (pPlot:IsRevealed(iTeam)) then
				if (pPlot:IsCity()) then
					local pCity = pPlot:GetPlotCity()
					local iReligion = pCity:GetReligiousMajority()

					if (iReligion >= 0 and pCity:IsHolyCityForReligion(iReligion)) then
						colour = tColours.HOLY_CITY
					else
						colour = tColours.CITY
					end
				else
					if (pPlot:GetFeatureType() == iFeatureIce) then
						colour = tColours.ICE
					elseif (pPlot:IsWater()) then
						colour = tColours.WATER
					else
						colour = tColours.NONE
					end
				end
			end

			Controls.ReligionMap:SetPlot(x, y, pPlot:GetTerrainType(), colour.r/255, colour.g/255, colour.b/255, colour.a)
		end
	end

	ShadeCities(iTeam)
end
g_Tabs["Map"].RefreshContent = RefreshMap;

-------------------------------------------------
-- Sorting
-------------------------------------------------
function AlphabeticalSortFunction(field, direction)
	if(direction == "asc") then
		return function(a,b)
			return Locale.Compare(a[field], b[field]) == -1;
		end
	elseif(direction == "desc") then
		return function(a,b)
			return Locale.Compare(a[field], b[field]) == 1;
		end
	end
end

function NumericSortFunction(field, direction)
	if(direction == "asc") then
		return function(a,b)
			return a[field] < b[field];
		end
	elseif(direction == "desc") then
		return function(a,b)
			return a[field] > b[field];
		end
	end
end

function RegisterSortOptions()

	for i,v in ipairs(g_BeliefSortOptions) do
		if(v.Button ~= nil) then
			v.Button:RegisterCallback(Mouse.eLClick, function() BeliefSortOptionSelected(v); end);
		end
	end

	for i,v in ipairs(g_WorldReligionSortOptions) do
		if(v.Button ~= nil) then
			v.Button:RegisterCallback(Mouse.eLClick, function() WorldReligionSortOptionSelected(v); end);
		end
	end

	UpdateSortOptionsDisplay(g_BeliefSortOptions);
	UpdateSortOptionsDisplay(g_WorldReligionSortOptions);

	g_BeliefSortFunction = GetSortFunction(g_BeliefSortOptions);
	g_WorldReligionSortFunction = GetSortFunction(g_WorldReligionSortOptions);
end

function GetSortFunction(sortOptions)
	for i,v in ipairs(sortOptions) do
		if(v.CurrentDirection ~= nil) then
			if(v.SortType == "numeric") then
				return NumericSortFunction(v.Column, v.CurrentDirection);
			else
				return AlphabeticalSortFunction(v.Column, v.CurrentDirection);
			end
		end
	end

	return nil;
end

function UpdateSortOptionState(sortOptions, selectedOption)
	for i,v in ipairs(sortOptions) do
		if(v == selectedOption) then
			if(v.CurrentDirection == nil) then
				v.CurrentDirection = v.DefaultDirection;
			else
				if(v.CurrentDirection == "asc") then
					v.CurrentDirection = "desc";
				else
					v.CurrentDirection = "asc";
				end
			end
		else
			v.CurrentDirection = nil;
		end
	end
end

function UpdateSortOptionsDisplay(sortOptions)
	for i,v in ipairs(sortOptions) do
		local imageControl = v.ImageControl;
		if(imageControl ~= nil) then
			if(v.CurrentDirection == nil) then
				imageControl:SetHide(true);
			else
				local imageToUse = "SelectedUp.dds";
				if(v.CurrentDirection == "desc") then
					imageToUse = "SelectedDown.dds";
				end
				imageControl:SetTexture(imageToUse);
				imageControl:SetHide(false);
			end
		end
	end
end

function BeliefSortOptionSelected(option)
	local sortOptions = g_BeliefSortOptions;
	UpdateSortOptionState(sortOptions, option);
	UpdateSortOptionsDisplay(sortOptions);
	g_BeliefSortFunction = GetSortFunction(sortOptions);

	RefreshBeliefs();
end

function WorldReligionSortOptionSelected(option)
	local sortOptions = g_WorldReligionSortOptions;
	UpdateSortOptionState(sortOptions, option);
	UpdateSortOptionsDisplay(sortOptions);
	g_WorldReligionSortFunction = GetSortFunction(sortOptions);

	RefreshWorldReligions();
end

-------------------------------------------------
-- Lifecycle
-------------------------------------------------
function ShowHideHandler( bIsHide, bInitState )
	if( not bInitState ) then
		if( not bIsHide ) then
			UI.incTurnTimerSemaphore();
			Events.SerialEventGameMessagePopupShown(g_PopupInfo);

			TabSelect(g_CurrentTab);
			local pPlayer = Players[Game.GetActivePlayer()]
			Controls.FoundButton:SetHide(pPlayer:HasCreatedPantheon() == true or pPlayer:CanCreatePantheon(true) == false)
		else
			if(g_PopupInfo ~= nil) then
				Events.SerialEventGameMessagePopupProcessed.CallImmediate(g_PopupInfo.Type, 0);
			end
			UI.decTurnTimerSemaphore();
		end
	end
end
ContextPtr:SetShowHideHandler( ShowHideHandler );

function OnActivePlayerChanged()
end
Events.GameplaySetActivePlayer.Add(OnActivePlayerChanged);

if(not Game.IsOption(GameOptionTypes.GAMEOPTION_NO_RELIGION)) then
	LuaEvents.AdditionalInformationDropdownGatherEntries.Add(function(entries)
		table.insert(entries, {
			text=Locale.Lookup("TXT_KEY_RELIGION_OVERVIEW"),
			call=function()
				Events.SerialEventGameMessagePopup{
					Type = ButtonPopupTypes.BUTTONPOPUP_RELIGION_OVERVIEW,
				};
			end,
		});
	end);

	LuaEvents.RequestRefreshAdditionalInformationDropdownEntries();
end

function OnFound()
	OnClose()
	Events.SerialEventGameMessagePopup({Type=ButtonPopupTypes.BUTTONPOPUP_FOUND_PANTHEON, Data2=1})
end
Controls.FoundButton:RegisterCallback(Mouse.eLClick, OnFound)

AssignReligionColours()
RegisterSortOptions();
TabSelect("YourReligion");
