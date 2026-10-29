--====================================================================================================================
-- Victory Progress
--====================================================================================================================


include "SupportFunctions"
include "InstanceManager"
include "IconSupport"

-- Vassalage feature gate
local g_bVassalageModOption = Game.IsOption("GAMEOPTION_GAIA_VASSALAGE")

-- Domination Variables
local g_DominationRowsIM = InstanceManager:new( "DominationRow", "RowStack", Controls.DominationStack )
local g_DominationRowList = {}
local g_DominationItemIMList = {}
local g_DominationItemList = {}

MAX_DOMINATION_ICONS_PER_ROW = 8

-- Tech Details Variables
local g_TechIM = InstanceManager:new( "TechCiv", "Civ", Controls.TechStack )
local g_TechList = {}

-- Diplo Details Variables
local g_DiploIM = InstanceManager:new( "DiploCiv", "Civ", Controls.DiploStack )
local g_DiploList = {}

-- Cultural Details Variables
local g_CultureRowsIM = InstanceManager:new( "CultureRow", "RowStack", Controls.CultureStack )
local g_CultureRowList = {}
local g_CultureItemIMList = {}
local g_CultureItemList = {}

MAX_CULTURE_ICONS_PER_ROW = 8

-- Religious Details Variables
local g_ReligiousRowsIM = InstanceManager:new( "ReligiousRow", "RowStack", Controls.ReligiousStack )
local g_ReligiousRowList = {}
local g_ReligiousItemIMList = {}
local g_ReligiousItemList = {}

MAX_RELIGIOUS_ICONS_PER_ROW = 8

-- Economic Details Variables
local g_EconomicRowsIM = InstanceManager:new( "EconomicRow", "RowStack", Controls.EconomicStack )
local g_EconomicRowList = {}
local g_EconomicItemIMList = {}
local g_EconomicItemList = {}
local g_EconomicIM = InstanceManager:new( "EconomicCiv", "Civ", Controls.EconomicCompareStack )
local g_EconomicList = {}

MAX_ECONOMIC_ICONS_PER_ROW = 12

-- Score Details Variables
local g_ScoreIM = InstanceManager:new( "ScoreCiv", "Civ", Controls.ScoreStack )
local g_ScoreList = {}

function OnBack()
	Controls.RightHandScreen:SetHide(false);
	Controls.ScoreScreen:SetHide(true);
	Controls.SpaceRaceScreen:SetHide(true);
	Controls.DiploScreen:SetHide(true);
	Controls.EconomicScreen:SetHide(true);
	
	-- Delete instanced screens
	DeleteSpaceRaceScreen();
	DeleteDiploScreen();
	DeleteScoreScreen();
	
	UIManager:DequeuePopup( ContextPtr );
end
Controls.BackButton:RegisterCallback( Mouse.eLClick, OnBack );

function OnSpaceRaceDetails()
	Controls.RightHandScreen:SetHide(true);
	Controls.SpaceRaceScreen:SetHide(false);
	Controls.BackButton:SetHide(true);
	Controls.SpaceRaceClose:SetHide(false);
	
	-- Populate Detail Screens
	PopulateSpaceRaceScreen();
end
Controls.SpaceRaceDetails:RegisterCallback( Mouse.eLClick, OnSpaceRaceDetails );

function OnScoreDetails()
	Controls.RightHandScreen:SetHide(true);
	Controls.ScoreScreen:SetHide(true);
	Controls.SpaceRaceScreen:SetHide(true);
	Controls.DiploScreen:SetHide(true);
	Controls.ScoreScreen:SetHide(false);
	Controls.BackButton:SetHide(true);
	
	Controls.ScoreClose:SetHide(false);
	Controls.DiploClose:SetHide(true);
	Controls.SpaceRaceClose:SetHide(true);
	
	-- Populate Detail Screens
	PopulateScoreScreen();
end
Controls.ScoreDetails:RegisterCallback( Mouse.eLClick, OnScoreDetails );

function OnEconomicDetails()
	Controls.RightHandScreen:SetHide(true);
	Controls.EconomicScreen:SetHide(false);
	Controls.BackButton:SetHide(true);
	Controls.EconomicClose:SetHide(false);
	
	-- Populate Detail Screens
	PopulateEconomicScreen();
end
Controls.EconomicVictoryDetails:RegisterCallback( Mouse.eLClick, OnEconomicDetails );

function OnSpaceRaceClose()
	Controls.RightHandScreen:SetHide(false);
	Controls.SpaceRaceScreen:SetHide(true);
	Controls.BackButton:SetHide(false);
	Controls.SpaceRaceClose:SetHide(true);
	
	-- Delete instanced parts of culture screen
	DeleteSpaceRaceScreen();
end
Controls.SpaceRaceClose:RegisterCallback( Mouse.eLClick, OnSpaceRaceClose );

function OnDiploClose()
	Controls.RightHandScreen:SetHide(false);
	Controls.DiploScreen:SetHide(true);
	Controls.BackButton:SetHide(false);
	Controls.DiploClose:SetHide(true);
	
	-- Delete instanced parts of culture screen
	DeleteDiploScreen();
end
Controls.DiploClose:RegisterCallback( Mouse.eLClick, OnDiploClose );

function OnScoreClose()
	Controls.RightHandScreen:SetHide(false);
	Controls.ScoreScreen:SetHide(true);
	Controls.BackButton:SetHide(false);
	Controls.ScoreClose:SetHide(true);
	
	-- Delete instanced parts of culture screen
	DeleteScoreScreen();
end
Controls.ScoreClose:RegisterCallback( Mouse.eLClick, OnScoreClose );

function OnEconomicClose()
	Controls.RightHandScreen:SetHide(false);
	Controls.EconomicScreen:SetHide(true);
	Controls.BackButton:SetHide(false);
	Controls.EconomicClose:SetHide(true);
	
	-- Delete instanced parts of culture screen
	DeleteEconomicScreen();
end
Controls.EconomicClose:RegisterCallback( Mouse.eLClick, OnEconomicClose );

function PopulateScoreBreakdown()
	local pPlayer = Players[Game.GetActivePlayer()];
	local bScenario = PreGame.GetLoadWBScenario();
	
	if(PreGame.IsVictory(GameInfo.Victories["VICTORY_TIME"].ID))then
		Controls.Cities:SetText(pPlayer:GetScoreFromCities());
		Controls.Population:SetText(pPlayer:GetScoreFromPopulation());
		Controls.Land:SetText(pPlayer:GetScoreFromLand());
		Controls.Wonders:SetText(pPlayer:GetScoreFromWonders());
		if (not Game.IsOption(GameOptionTypes.GAMEOPTION_NO_SCIENCE)) then
			Controls.Tech:SetText(pPlayer:GetScoreFromTechs());
			Controls.FutureTech:SetText(pPlayer:GetScoreFromFutureTech());
			Controls.TechLabel:SetHide(false);
			Controls.FutureTechLabel:SetHide(false);
			Controls.TechDetailsBox:SetHide(false);
			Controls.FutureTechBox:SetHide(false);
			Controls.Tech:SetHide(false);
			Controls.FutureTech:SetHide(false);
		else
			Controls.TechLabel:SetHide(true);
			Controls.FutureTechLabel:SetHide(true);
			Controls.TechDetailsBox:SetHide(true);
			Controls.FutureTechBox:SetHide(true);
			Controls.Tech:SetHide(true);
			Controls.FutureTech:SetHide(true);
		end
		if (not Game.IsOption(GameOptionTypes.GAMEOPTION_NO_POLICIES)) then
			Controls.Policies:SetText(pPlayer:GetScoreFromPolicies());
			Controls.PolicyLabel:SetHide(false);
			Controls.PolicyBox:SetHide(false);
			Controls.Policies:SetHide(false);
		else
			Controls.PolicyLabel:SetHide(true);
			Controls.PolicyBox:SetHide(true);
			Controls.Policies:SetHide(true);
		end
		Controls.GreatWorks:SetText(pPlayer:GetScoreFromGreatWorks());
		if (not Game.IsOption(GameOptionTypes.GAMEOPTION_NO_RELIGION)) then
			Controls.Religion:SetText(pPlayer:GetScoreFromReligion());
			Controls.ReligionLabel:SetHide(false);
			Controls.ReligionBox:SetHide(false);
			Controls.Religion:SetHide(false);
		else
			Controls.ReligionLabel:SetHide(true);
			Controls.ReligionBox:SetHide(true);
			Controls.Religion:SetHide(true);
		end
		if (g_bVassalageModOption and pPlayer._GetScoreFromVassals ~= nil) then
			Controls.Vassal:SetText(pPlayer:_GetScoreFromVassals());
			Controls.VassalLabel:SetHide(false);
			Controls.VassalBox:SetHide(false);
			Controls.Vassal:SetHide(false);
		else
			Controls.VassalLabel:SetHide(true);
			Controls.VassalBox:SetHide(true);
			Controls.Vassal:SetHide(true);
		end
		if (bScenario == true) then
			Controls.Scenario1:SetText(pPlayer:GetScoreFromScenario1());
			Controls.Scenario2:SetText(pPlayer:GetScoreFromScenario2());
			Controls.Scenario3:SetText(pPlayer:GetScoreFromScenario3());
			Controls.Scenario4:SetText(pPlayer:GetScoreFromScenario4());
			Controls.Scenario1:SetHide(false);
			Controls.Scenario2:SetHide(false);
			Controls.Scenario3:SetHide(false);
			Controls.Scenario4:SetHide(false);		
			Controls.ScenarioBox1:SetHide(false);
			Controls.ScenarioBox2:SetHide(false);
			Controls.ScenarioBox3:SetHide(false);
			Controls.ScenarioBox4:SetHide(false);		
			Controls.VPLabel1:SetHide(false);		
			Controls.VPLabel2:SetHide(false);		
			Controls.VPLabel3:SetHide(false);		
			Controls.VPLabel4:SetHide(false);		
		else
			Controls.Scenario1:SetHide(true);
			Controls.Scenario2:SetHide(true);
			Controls.Scenario3:SetHide(true);
			Controls.Scenario4:SetHide(true);
			Controls.ScenarioBox1:SetHide(true);
			Controls.ScenarioBox2:SetHide(true);
			Controls.ScenarioBox3:SetHide(true);
			Controls.ScenarioBox4:SetHide(true);		
			Controls.VPLabel1:SetHide(true);		
			Controls.VPLabel2:SetHide(true);		
			Controls.VPLabel3:SetHide(true);		
			Controls.VPLabel4:SetHide(true);		
		end
		Controls.Score:SetText(pPlayer:GetScore());
		Controls.ScoreDetailsStack:CalculateSize();
		Controls.ScoreDetailsStack:ReprocessAnchoring();
		Controls.ScoreLabelStack:CalculateSize();
		Controls.ScoreLabelStack:ReprocessAnchoring();
		
		Controls.TimeVictoryDisabledBox:SetHide(true);
		
	else
		Controls.ScoreDetails:SetHide(true);
		Controls.TimeStack:SetHide(true);
		
		Controls.TimeVictoryDisabledBox:SetHide(false);
	end
end

function PopulateDomination()
		
	if(PreGame.IsVictory(GameInfo.Victories["VICTORY_DOMINATION"].ID))then		
		for i, v in pairs(g_DominationRowList) do
			v.RowStack:DestroyAllChildren();
		end
		g_DominationRowsIM:ResetInstances();
		
		g_DominationRowList = {};
		g_DominationItemList = {};
		g_DominationItemIMList = {};
		
		local curRow = nil;
		local numRows = 0;
		local curItemIM = nil;
		local numItemIM = 0;
		local curCol = 0;
		local numItems = 0;
		local numCapitals = 0;
		
		local iLeadingNumCapitals = 0;
		local iLeadingTeam = -1;
		local iLeadingPlayer = -1;
		local iLeadingNumPlayersOnTeam = 0;
		local bAnyoneLostControlOfCapital = false;
		
		local aiCapitalOwner = {};
		
		local function GetDominationOwner(pCity)
			if (pCity._GetOwnerForDominationVictory ~= nil) then
				return pCity:_GetOwnerForDominationVictory();
			end
			return pCity:GetOwner();
		end
		
		local aiTeamCapitalCount = {};
		for iPlayerLoop = 0, GameDefines.MAX_CIV_PLAYERS-1, 1 do
			local pPlayer = Players[iPlayerLoop];
			if (pPlayer:IsEverAlive()) then
				for pCity in pPlayer:Cities() do
					if (pCity:IsOriginalMajorCapital()) then
						local iEffectiveOwner = GetDominationOwner(pCity);
						if (iEffectiveOwner >= 0) then
							aiCapitalOwner[pCity:GetOriginalOwner()] = iEffectiveOwner;
							local pEffective = Players[iEffectiveOwner];
							if (not pEffective:IsMinorCiv()) then
								local iTeam = pEffective:GetTeam();
								aiTeamCapitalCount[iTeam] = (aiTeamCapitalCount[iTeam] or 0) + 1;
							end
						end
					end
				end
			end
		end

		for iTeamLoop = 0, GameDefines.MAX_CIV_TEAMS-1, 1 do
			local iNumCapitals = aiTeamCapitalCount[iTeamLoop] or 0;
			local iNumPlayersOnTeam = 0;
			local iPlayerOnTeam = -1;
			
			for iPlayerLoop = 0, GameDefines.MAX_MAJOR_CIVS-1, 1 do
				local pPlayer = Players[iPlayerLoop];
				if (not pPlayer:IsMinorCiv() and pPlayer:IsEverAlive() and pPlayer:GetTeam() == iTeamLoop) then
					if (pPlayer:IsHasLostCapital()) then
						bAnyoneLostControlOfCapital = true;
					end
				
					iPlayerOnTeam = iPlayerLoop;
					iNumPlayersOnTeam = iNumPlayersOnTeam + 1;
				end
			end
			
			if (iNumCapitals - iNumPlayersOnTeam > iLeadingNumCapitals - iLeadingNumPlayersOnTeam) then
				iLeadingTeam = iTeamLoop;
				iLeadingNumCapitals = iNumCapitals;
				iLeadingNumPlayersOnTeam = iNumPlayersOnTeam;
				iLeadingPlayer = iPlayerOnTeam;
			end
		end
		
		for iPlayerLoop = 0, GameDefines.MAX_CIV_PLAYERS-1, 1 do

			local pPlayer = Players[iPlayerLoop];
			
			if(not pPlayer:IsMinorCiv() and pPlayer:IsEverAlive()) then
				if(curRow == nil) then
					numRows = numRows + 1;
					curRow = g_DominationRowsIM:GetInstance();
					g_DominationRowList[numRows] = curRow;
					
					numItemIM = numItemIM + 1;
					curItemIM = InstanceManager:new( "DominationItem", "IconFrame", curRow.RowStack );
					g_DominationItemIMList[numItemIM] = curItemIM;
					
				end
				
				local dominatingPlayer = Players[aiCapitalOwner[iPlayerLoop]];
				local newNumItems = AddDominationCiv(pPlayer, dominatingPlayer, numItems, curItemIM);
				
				if(newNumItems ~= numItems) then
					numItems = newNumItems;				
					curCol = curCol + 1;
					if(curCol >= MAX_DOMINATION_ICONS_PER_ROW) then
						curRow = nil;
						curCol = 0;
					end
				end
			end
		end
		
		local pActivePlayer = Players[Game.GetActivePlayer()];
		local pActiveTeam = Teams[pActivePlayer:GetTeam()];
		
		if (iLeadingTeam == -1) then
			if (bAnyoneLostControlOfCapital) then
				Controls.DominationLabel:SetHide(true);
			else
				Controls.DominationLabel:SetText(Locale.ConvertTextKey("TXT_KEY_VP_DIPLO_NEW_CAPITALS_REMAINING"));	
				Controls.DominationLabel:SetHide(false);
			end
		elseif (iLeadingNumPlayersOnTeam > 1) then
			Controls.DominationLabel:SetText(Locale.ConvertTextKey("TXT_KEY_VP_DIPLO_CAPITALS_TEAM_LEADING", iLeadingTeam + 1, iLeadingNumCapitals));	
			Controls.DominationLabel:SetHide(false);		
		else
			if (iLeadingPlayer == Game.GetActivePlayer()) then
				Controls.DominationLabel:SetText(Locale.ConvertTextKey("TXT_KEY_VP_DIPLO_CAPITALS_ACTIVE_PLAYER_LEADING", iLeadingNumCapitals));
			else
				local pOtherPlayer = Players[iLeadingPlayer];			
				if (pOtherPlayer:GetNickName() ~= "" and pOtherPlayer:IsHuman()) then
					Controls.DominationLabel:SetText(Locale.ConvertTextKey("TXT_KEY_VP_DIPLO_CAPITALS_PLAYER_LEADING", pOtherPlayer:GetNickName(), iLeadingNumCapitals));
				elseif (not pActiveTeam:IsHasMet(iLeadingTeam)) then
					Controls.DominationLabel:SetText(Locale.ConvertTextKey("TXT_KEY_VP_DIPLO_CAPITALS_UNMET_PLAYER_LEADING", iLeadingNumCapitals));
				else
					Controls.DominationLabel:SetText(Locale.ConvertTextKey("TXT_KEY_VP_DIPLO_CAPITALS_PLAYER_LEADING", pOtherPlayer:GetName(), iLeadingNumCapitals));
    			end
			end
			Controls.DominationLabel:SetHide(false);	
		end
		
		Controls.DominationStack:CalculateSize();
		Controls.DominationStack:ReprocessAnchoring();
		Controls.DominationScrollPanel:CalculateInternalSize();
		
		Controls.DominationVictoryProgress:SetHide(false);
		Controls.DominationDisabledLabel:SetHide(true);
	else
		Controls.DominationVictoryProgress:SetHide(true);
		Controls.DominationDisabledLabel:SetHide(false);
	end
end

function AddDominationCiv(pPlayer, pDominatingPlayer, numItems, civMgr)
	
	if(pPlayer:IsEverAlive()) then
		local item = civMgr:GetInstance();
		g_DominationItemList[numItems] = item;
		numItems = numItems + 1;
		
		local iPlayer = pPlayer:GetID();
		-- Set Civ Icon
		SetConquestCivIcon(pPlayer, 64, item.Icon, item.IconFrame,
				   item.ConqueredCivSmallFrame, item.ConqueredCivIconBG, item.ConqueredCivIconShadow, item.ConqueredCivIcon, item.IconOut, pDominatingPlayer,
				   item.CivIconBG, item.CivIconShadow); 

        local pTeam = Teams[ pPlayer:GetTeam() ];
        if( pTeam:GetNumMembers() > 1 ) then
    	    item.TeamID:LocalizeAndSetText( "TXT_KEY_MULTIPLAYER_DEFAULT_TEAM_NAME", pTeam:GetID() + 1 );
    	    item.TeamID:SetHide( false );
	    else
    	    item.TeamID:SetHide( true );
	    end
	end
	return numItems;
end 

local eApolloTech = GameInfoTypes[ GameInfo.Projects{ Type = "PROJECT_APOLLO_PROGRAM" }().TechPrereq ];
function PopulateSpaceRace()
	if(PreGame.IsVictory(GameInfo.Victories["VICTORY_SPACE_RACE"].ID))then
		local apolloProj = GameInfoTypes["PROJECT_APOLLO_PROGRAM"];
		local strPlayer = Locale.ConvertTextKey("TXT_KEY_CITY_STATE_NOBODY");
		if(apolloProj ~= -1) then
			local white = {x = 1, y = 1, z = 1, w = 1};
			local iTeam = Game.GetActiveTeam();
			if(Teams[iTeam]:GetProjectCount(apolloProj) == 1) then
				Controls.TechProgress:SetHide(true);
				Controls.ApolloProject:SetHide(false);
				Controls.BubblesAnim:SetHide(true);
				Controls.ApolloIcon:SetColor(white);
				
				SetProjectValue("PROJECT_SS_BOOSTER", iTeam, Controls, "Booster");
				SetProjectValue("PROJECT_SS_COCKPIT", iTeam, Controls, "Cockpit");
				SetProjectValue("PROJECT_SS_STASIS_CHAMBER", iTeam, Controls, "Chamber");
				SetProjectValue("PROJECT_SS_ENGINE", iTeam, Controls, "Engine");
			else
				local techsToComplete = Players[ Game.GetActivePlayer() ]:FindPathLength(eApolloTech, false)
				techsToComplete = math.min(10, techsToComplete)
				Controls.TechProgress:SetHide(false)
				if techsToComplete > 0 then
					Controls.TechProgress:SetPercent((10-techsToComplete)/10)
					Controls.BubblesAnim:SetHide(false)
				else
					Controls.TechProgress:SetPercent(1)
					Controls.TechIconAnim:SetHide(false)
					Controls.BubblesAnim:SetHide(true)
				end
			end
			
			local numApollo = 0;
			for i, v in pairs(Teams) do
				if(v:GetProjectCount(apolloProj) == 1) then
					numApollo = numApollo + 1;
				end
			end
			Controls.SpaceInfo:LocalizeAndSetText("TXT_KEY_VP_DIPLO_PROJECT_PLAYERS_COMPLETE", numApollo, "TXT_KEY_PROJECT_APOLLO_PROGRAM");
		end
		
		Controls.ScienceVictoryProgress:SetHide(false);
		Controls.ScienceVictoryDisabled:SetHide(true);
	else
		Controls.ScienceVictoryProgress:SetHide(true);
		Controls.ScienceVictoryDisabled:SetHide(false);
	end
end


function SetProjectValue( sProject, iTeam, controlTable, controlTag )

	local white = {x = 1, y = 1, z = 1, w = 1};
	local proj = GameInfoTypes[sProject];
	local vProj = GameInfo.Project_VictoryThresholds( "ProjectType = '" .. sProject .. "'" )();
	
	if( proj ~= -1 and vProj ~= -1 ) then
		local numBuilt = Teams[ iTeam ]:GetProjectCount( proj );
		local count = math.min( vProj.Threshold, numBuilt );
		
		if( count > 0 ) then
			for i = 1, count do
				local control = controlTag .. tostring( i );
				controlTable[ control ]:SetColor( white );
			end
		end
	end
end 


function PopulateDiplomatic()
	Controls.UNIcon:SetHide(true);
	Controls.TurnsUntilSessionLabel:SetHide(true);
	Controls.TurnsUntilSession:SetHide(true);
	Controls.DiploVictoryProgress:SetHide(true);
	Controls.DiploVictoryDisabled:SetHide(false);
	Controls.VotesNeededLabel:SetHide(true);
	Controls.VotesHaveLabel:SetHide(true);
	 
	local victoryId;
	local victoryInfo = GameInfo.Victories["VICTORY_DIPLOMATIC"];
	if(victoryInfo ~= nil) then
		victoryId = victoryInfo.ID;
	end
	 
	if (victoryId ~= nil and PreGame.IsVictory(victoryId))then
	
		if(Game.GetVictory() == victoryId) then
		
			local team = Teams[Game.GetWinner()];
			local leader = Players[team:GetLeaderID()];
			
			local playerName;
			if(Game:IsNetworkMultiPlayer() and leader:GetNickName() ~= "" and leader:IsHuman() ) then
				playerName = leader:GetNickName();
			else
				playerName = leader:GetNameKey();
			end
      			
			Controls.UNInfo:LocalizeAndSetText("TXT_KEY_VP_DIPLO_SOMEONE_WON", playerName);
			Controls.VotesNeeded:SetHide(true);
			Controls.VotesHave:SetHide(true);	
		else
			local iVotesControlled = 0;
			local sUNInfo = Locale.Lookup("TXT_KEY_VP_DIPLO_UN_INACTIVE");
			if (Game.GetNumActiveLeagues() > 0) then
				local pLeague = Game.GetActiveLeague();
				
				if (pLeague ~= nil and Game.IsUnitedNationsActive()) then
					Controls.UNIcon:SetHide(false);
					sUNInfo = Locale.Lookup("TXT_KEY_VP_DIPLO_UN_ACTIVE");
					Controls.TurnsUntilSessionLabel:SetHide(false);
					Controls.TurnsUntilSession:SetHide(false);
					Controls.TurnsUntilSession:SetText(pLeague:GetTurnsUntilVictorySession());
				end
				
				if (pLeague ~= nil) then
					iVotesControlled = pLeague:CalculateStartingVotesForMember(Game.GetActivePlayer());
				end
			end
			
			Controls.UNInfo:SetText(sUNInfo);
			Controls.VotesNeeded:SetText(Game.GetVotesNeededForDiploVictory());
			Controls.VotesHave:SetText(iVotesControlled);
			Controls.VotesNeededLabel:SetHide(false);
			Controls.VotesHaveLabel:SetHide(false);
	
			Controls.VotesNeeded:SetHide(false);
			Controls.VotesHave:SetHide(false);
		end
	
		Controls.DiploVictoryProgress:SetHide(false);
		Controls.DiploVictoryDisabled:SetHide(true);		
	end
end

function PopulateCultural()
	
	local cultureVictory = GameInfo.Victories["VICTORY_CULTURAL"];
	if(cultureVictory ~= nil and PreGame.IsVictory(cultureVictory.ID))then
		for i, v in pairs(g_CultureRowList) do
			v.RowStack:DestroyAllChildren();
		end
		g_CultureRowsIM:ResetInstances();
		
		g_CultureRowList = {};
		g_CultureItemList = {};
		g_CultureItemIMList = {};
		
		local curRow = nil;
		local numRows = 0;
		local curItemIM = nil;
		local numItemIM = 0;
		local curCol = 0;
		local numItems = 0;	
		
		local iActivePlayer = Game.GetActivePlayer();
		local pActivePlayer = Players[iActivePlayer];
			
		for iPlayerLoop = 0, GameDefines.MAX_CIV_PLAYERS-1, 1 do

			local pPlayer = Players[iPlayerLoop];
			
			if(iPlayerLoop ~= iActivePlayer and not pPlayer:IsMinorCiv() and pPlayer:IsEverAlive()) then
				if(curRow == nil) then
					numRows = numRows + 1;
					curRow = g_CultureRowsIM:GetInstance();
					g_CultureRowList[numRows] = curRow;
					
					numItemIM = numItemIM + 1;
					curItemIM = InstanceManager:new( "CultureItem", "IconFrame", curRow.RowStack );
					g_CultureItemIMList[numItemIM] = curItemIM;
					
				end
							
				local item = curItemIM:GetInstance();
				g_CultureItemList[numItems] = item;
				numItems = numItems + 1;
				
				local iPlayer = pPlayer:GetID();
			
				local influencePercent = 0;
						
				local iInfluence = pActivePlayer:GetInfluenceOn(iPlayer);
				local iCulture = pPlayer:GetJONSCultureEverGenerated();
				if (iCulture > 0) then
					influencePercent = iInfluence / iCulture;
				end
				
				local activeTeam = Teams[pActivePlayer:GetTeam()];
				
				local bHasMet = activeTeam:IsHasMet(pPlayer:GetTeam());
				
				local iPlayerIcon = bHasMet and iPlayer or -1;
				local influenceKey = bHasMet and "TXT_KEY_VP_CULTURE_INFLUENCE" or "TXT_KEY_VP_CULTURE_INFLUENCE_UNMET";
					
				-- Set Civ Icon
				CivIconHookup(iPlayerIcon, 64, item.Icon, item.IconBG, item.IconShadow, true, true);
				
				local width, height = 64,64;	
				
				local newHeight = 42 * (1 - influencePercent) + 12;
				
				item.IconDark:SetSizeVal(width, newHeight);
				item.IconDark:SetTextureSizeVal(width, newHeight);
				item.IconDark:NormalizeTexture();
			
				item.IconFrameGlow:SetHide(influencePercent ~= 1);
				local txt = Locale.Lookup(influenceKey, influencePercent * 100, pPlayer:GetCivilizationShortDescriptionKey());
				item.IconFrame:SetToolTipString(txt);
			
				curCol = curCol + 1;
				if(curCol >= MAX_CULTURE_ICONS_PER_ROW) then
					curRow = nil;
					curCol = 0;
				end
			end
		end
		
		Controls.CultureStack:CalculateSize();
		Controls.CultureStack:ReprocessAnchoring();
		Controls.CultureScrollPanel:CalculateInternalSize();
	
		Controls.CultureVictoryProgress:SetHide(false);
		Controls.CultureVictoryDisabled:SetHide(true);
	else
		Controls.CultureVictoryProgress:SetHide(true);
		Controls.CultureVictoryDisabled:SetHide(false);
	end

end

local function GetEconomicVictoryMapLuxuries()
	local luxuryList = {}
	for _, resource in pairs(Game._GetActiveMapLuxuryTypes()) do
		table.insert(luxuryList, resource)
	end
	return luxuryList
end

function PopulateEconomic()
	local economicVictory = GameInfo.Victories["VICTORY_GAIA_ECONOMIC"];
	if not Game._GetActiveMapLuxuryTypes or economicVictory == nil or not PreGame.IsVictory(economicVictory.ID) then
		Controls.EconomicVictoryProgress:SetHide(true);
		Controls.EconomicVictoryDisabled:SetHide(false);
		return;
	end

	local iActivePlayer = Game.GetActivePlayer();
	local pActivePlayer = Players[iActivePlayer];

	-- Accumulated Gold
	local iPlayerGold = pActivePlayer:GetGold();
	local iRequiredGold = GameDefines.GD_ECONOMIC_VICTORY_GOLD_TARGET;
	local bDone = (iPlayerGold >= iRequiredGold);

	local goldStatusKey = bDone and "TXT_KEY_VP_ECONOMIC_GOLD_DONE" or "TXT_KEY_VP_ECONOMIC_GOLD";
	Controls.EconomicVictoryGold:SetText(Locale.Lookup(goldStatusKey, iPlayerGold, iRequiredGold));

	-- National Rail project
	local railProj = GameInfoTypes["PROJECT_GAIA_NATIONALRAIL"];
	if(railProj ~= nil and railProj ~= -1) then
		local railStatusKey = (Teams[pActivePlayer:GetTeam()]:GetProjectCount(railProj) > 0) and "TXT_KEY_VP_ECONOMIC_RAIL_DONE" or "TXT_KEY_VP_ECONOMIC_RAIL";
		Controls.EconomicVictoryRail:SetText(Locale.Lookup(railStatusKey, "TXT_KEY_PROJECT_GAIA_NATIONALRAIL"));
	else
		Controls.EconomicVictoryRail:SetText("");
	end

	-- Luxury list
	local iRequiredLuxPercent = GameDefines.GD_ECONOMIC_VICTORY_LUX_PERCENTAGE;
	local luxuryList = GetEconomicVictoryMapLuxuries();
	local iTotalLuxuries = #luxuryList;
	local iRequiredLuxuries = math.floor((iTotalLuxuries * iRequiredLuxPercent) / 100);

	Controls.EconomicVictoryLuxuries:SetText(Locale.Lookup("TXT_KEY_VP_ECONOMIC_LUXURIES", iRequiredLuxuries, iTotalLuxuries));

	for i, v in pairs(g_EconomicRowList) do
		v.RowStack:DestroyAllChildren();
	end
	g_EconomicRowsIM:ResetInstances();

	g_EconomicRowList = {};
	g_EconomicItemList = {};
	g_EconomicItemIMList = {};

	local curRow = nil;
	local numRows = 0;
	local curItemIM = nil;
	local numItemIM = 0;
	local curCol = 0;
	local numItems = 0;

	for _, iResource in ipairs(luxuryList) do
		local resource = GameInfo.Resources[iResource];

		if curRow == nil then
			numRows = numRows + 1;
			curRow = g_EconomicRowsIM:GetInstance();
			g_EconomicRowList[numRows] = curRow;

			numItemIM = numItemIM + 1;
			curItemIM = InstanceManager:new("EconomicItem", "IconFrame", curRow.RowStack);
			g_EconomicItemIMList[numItemIM] = curItemIM;
		end

		local item = curItemIM:GetInstance();
		g_EconomicItemList[numItems] = item;
		numItems = numItems + 1;

		IconHookup(resource.PortraitIndex, 45, resource.IconAtlas, item.Icon);

		local bHasResource = (pActivePlayer:GetNumResourceTotal(iResource, true) > 0);
		item.IconDark:SetHide(bHasResource);

		local statusKey = bHasResource and "TXT_KEY_VP_ECONOMIC_LUXURY_TOOLTIP_AQUIRED" or "TXT_KEY_VP_ECONOMIC_LUXURY_TOOLTIP";
		local txt = Locale.Lookup(statusKey, resource.Description);
		item.IconFrame:SetToolTipString(txt);

		curCol = curCol + 1;
		if curCol >= MAX_ECONOMIC_ICONS_PER_ROW then
			curRow = nil;
			curCol = 0;
		end
	end

	Controls.EconomicVictoryProgress:SetHide(false);
	Controls.EconomicVictoryDisabled:SetHide(true);
end
local function GetReligiousVictoryTotalCities()
	local iTotalCities = 0;
	for iPlayer = 0, GameDefines.MAX_PLAYERS - 1 do
		local pLoopPlayer = Players[iPlayer];
		if pLoopPlayer:IsEverAlive() then
			iTotalCities = iTotalCities + pLoopPlayer:GetNumCities();
		end
	end
	return iTotalCities;
end

function PopulateReligious()
	local religiousVictory = GameInfo.Victories["VICTORY_GAIA_RELIGIOUS"];
	if not Game._ReligiousVictoryTargetFollowers or religiousVictory == nil or not PreGame.IsVictory(religiousVictory.ID) then
		Controls.ReligiousVictoryProgress:SetHide(true);
		Controls.ReligiousVictoryDisabled:SetHide(false);
		Controls.NoReligionsFounded:SetHide(true);
		return;
	end

	for i, v in pairs(g_ReligiousRowList) do
		v.RowStack:DestroyAllChildren();
	end
	g_ReligiousRowsIM:ResetInstances();

	g_ReligiousRowList = {};
	g_ReligiousItemList = {};
	g_ReligiousItemIMList = {};

	local curRow = nil;
	local numRows = 0;
	local curItemIM = nil;
	local numItemIM = 0;
	local curCol = 0;
	local numItems = 0;

	local iActivePlayer = Game.GetActivePlayer();
	local pActivePlayer = Players[iActivePlayer];

	local iRequiredCitiesPercent = Game._ReligiousVictoryTargetCitiesPercent();
	local iMaxFollowers = Game._ReligiousVictoryTargetFollowers();

	for iPlayerLoop = 0, GameDefines.MAX_MAJOR_CIVS - 1 do
		local pPlayer = Players[iPlayerLoop];
		if pPlayer:IsEverAlive() and not pPlayer:IsMinorCiv() and pPlayer:HasCreatedReligion() then
			if curRow == nil then
				numRows = numRows + 1;
				curRow = g_ReligiousRowsIM:GetInstance();
				g_ReligiousRowList[numRows] = curRow;

				numItemIM = numItemIM + 1;
				curItemIM = InstanceManager:new("ReligiousItem", "IconFrame", curRow.RowStack);
				g_ReligiousItemIMList[numItemIM] = curItemIM;
			end

			local item = curItemIM:GetInstance();
			g_ReligiousItemList[numItems] = item;
			numItems = numItems + 1;

			local eReligion = pPlayer:GetReligionCreatedByPlayer();
			local religion = GameInfo.Religions[eReligion];

			local iCitiesFollowing = Game.GetNumCitiesFollowing(eReligion);
			local iTotalCities = GetReligiousVictoryTotalCities();

			local iSpreadPercent = (iTotalCities > 0) and math.floor(100 * iCitiesFollowing / iTotalCities) or 0;
			local iFollowers = Game.GetNumFollowers(eReligion);

			-- Clamp for progress bar calculation
			local spread = math.min(iSpreadPercent, iRequiredCitiesPercent);
			local followers = math.min(iFollowers, iMaxFollowers);

			local victoryPercent = (spread / iRequiredCitiesPercent) * 0.67 + (followers / iMaxFollowers) * 0.33;

			-- Religion icon
			IconHookup(religion.PortraitIndex, 48, religion.IconAtlas, item.Icon);

			local width, height = 64, 64;
			local newHeight = 42 * (1 - victoryPercent) + 12;

			item.IconDark:SetSizeVal(width, newHeight);
			item.IconDark:SetTextureSizeVal(width, newHeight);
			item.IconDark:NormalizeTexture();

			item.IconFrameGlow:SetHide(victoryPercent ~= 1);

			-- Tooltip
			local activeTeam = Teams[pActivePlayer:GetTeam()];
			local bHasMet = true;
			local statusKey = "";

			if iPlayerLoop ~= iActivePlayer then
				bHasMet = activeTeam:IsHasMet(pPlayer:GetTeam());
				statusKey = bHasMet and "TXT_KEY_VP_RELIGIOUS_STATUS" or "TXT_KEY_VP_RELIGIOUS_STATUS_UNMET";
			else
				statusKey = "TXT_KEY_VP_RELIGIOUS_STATUS_PLAYER";
			end

			local txt = Locale.Lookup(statusKey, religion.IconString, religion.Description, iSpreadPercent, iFollowers, iMaxFollowers, pPlayer:GetNameKey());
			item.IconFrame:SetToolTipString(txt);

			curCol = curCol + 1;
			if curCol >= MAX_RELIGIOUS_ICONS_PER_ROW then
				curRow = nil;
				curCol = 0;
			end
		end
	end

	Controls.ReligiousStack:CalculateSize();
	Controls.ReligiousStack:ReprocessAnchoring();
	Controls.ReligiousScrollPanel:CalculateInternalSize();

	if numRows == 0 then
		Controls.NoReligionsFounded:SetHide(false);
	else
		Controls.NoReligionsFounded:SetHide(true);
	end

	Controls.ReligiousVictoryProgress:SetHide(false);
	Controls.ReligiousVictoryDisabled:SetHide(true);
end

function SetupScreen()	
	-- Title Icon
	SimpleCivIconHookup( Game.GetActivePlayer(), 64, Controls.Icon ); 
	
	-- Set Remaining Turns
	local remainingTurns = Game.GetMaxTurns() - Game.GetElapsedGameTurns();
	if remainingTurns < 0 then
		remainingTurns = 0;
	end
	Controls.RemainingTurns:SetText(remainingTurns);
	
	-- Set Player Score
	PopulateScoreBreakdown();
	
	-- Populate Victories
	PopulateDomination();
	PopulateSpaceRace();
	PopulateDiplomatic();
	PopulateCultural();
	
	PopulateEconomic();
	PopulateReligious();
	
		
end

function PopulateScoreScreen()
	g_ScoreIM:ResetInstances();
	g_ScoreList = {};
	
	local sortedPlayerList = {};
	for iPlayerLoop = 0, GameDefines.MAX_CIV_PLAYERS-1, 1 do
		local pPlayer = Players[iPlayerLoop];
		if(not pPlayer:IsMinorCiv() and pPlayer:IsEverAlive()) then
			table.insert(sortedPlayerList, iPlayerLoop);			
		end
	end
	
	table.sort(sortedPlayerList, function(a, b) return Players[b]:GetScore() < Players[a]:GetScore() end);
	
	for i, v in ipairs(sortedPlayerList) do	
		local pPlayer = Players[v];
		
		-- Create Instance
		local controlTable = g_ScoreIM:GetInstance();
		g_ScoreList[i] = controlTable;
		
		-- Set Leader Icon
		SetCivLeader(pPlayer, 64, controlTable.Portrait);
	
		-- Set Civ Name
		SetCivName(pPlayer, i, controlTable.Score, PreGame.IsMultiplayerGame(), 730);
		controlTable.Name:SetText(controlTable.Score:GetText());
		
		-- Set Civ Icon
		SetCivIcon(pPlayer, 64, controlTable.Icon, nil, controlTable.IconOut, not pPlayer:IsAlive(), 
				   controlTable.CivIconBG, controlTable.CivIconShadow);
		
		-- Set Civ Score
		controlTable.Score:SetText(pPlayer:GetScore());
	end	
	
	Controls.ScoreStack:CalculateSize();
	Controls.ScoreStack:ReprocessAnchoring();
	Controls.ScoreScrollPanel:CalculateInternalSize();
end

function PopulateSpaceRaceScreen()
	g_TechIM:ResetInstances();
	g_TechList = {};
	
	local numTechs = 0;
	local white = {x = 1, y = 1, z = 1, w = 1};
	
	local apolloProj = GameInfoTypes["PROJECT_APOLLO_PROGRAM"];
	if(apolloProj ~= -1) then
		local sortedPlayerList = {};
		for iPlayerLoop = 0, GameDefines.MAX_CIV_PLAYERS-1, 1 do
			local pPlayer = Players[iPlayerLoop];
			if(not pPlayer:IsMinorCiv() and pPlayer:IsEverAlive()) then
				table.insert(sortedPlayerList, iPlayerLoop);			
			end
		end
		
		table.sort(sortedPlayerList, CompareSpaceRace);
	
		for i, v in ipairs(sortedPlayerList) do	
			local pPlayer = Players[v];
			local pTeam = pPlayer:GetTeam();
			
			-- Create Instance
			local controlTable = g_TechIM:GetInstance();
			g_TechList[i] = controlTable;
	
			-- Set Civ Name
			SetCivName(pPlayer, i, controlTable.Name, true, controlTable.Civ:GetSizeX() - controlTable.CivIconBG:GetSizeX());
			
			-- Set Civ Icon
			SetCivIcon(pPlayer, 45, controlTable.Icon, nil, controlTable.IconOut, not pPlayer:IsAlive(),
					   controlTable.CivIconBG, controlTable.CivIconShadow);
			
			-- Fill in Apollo Project
			if(Teams[pTeam]:GetProjectCount(apolloProj) == 1) then
				controlTable.ApolloIcon:SetColor(white);
				
				SetProjectValue("PROJECT_SS_BOOSTER", pTeam, controlTable, "Booster");
				SetProjectValue("PROJECT_SS_COCKPIT", pTeam, controlTable, "Cockpit");
				SetProjectValue("PROJECT_SS_STASIS_CHAMBER", pTeam, controlTable, "Chamber");
				SetProjectValue("PROJECT_SS_ENGINE", pTeam, controlTable, "Engine");
			end
		end	
	end
	
	Controls.ScrollPanel:CalculateInternalSize();
end

function CompareSpaceRace(a, b)
	local apolloProj = GameInfoTypes["PROJECT_APOLLO_PROGRAM"];
	local playerA = Players[a];
	local playerB = Players[b];
	local pTeamA = Teams[ playerA:GetTeam() ];
	local pTeamB = Teams[ playerB:GetTeam() ];
	local apolloA = pTeamA:GetProjectCount(apolloProj) == 1;
	local apolloB = pTeamB:GetProjectCount(apolloProj) == 1;
	
	if(apolloA) then
		if(apolloB)then
			local partsA = 0;
			local partsB = 0;
			local proj = GameInfoTypes["PROJECT_SS_BOOSTER"];
			if(proj ~= -1) then
				partsA = partsA + pTeamA:GetProjectCount(proj);
				partsB = partsB + pTeamB:GetProjectCount(proj);
			end
			
			proj = GameInfoTypes["PROJECT_SS_COCKPIT"];
			if(proj ~= -1) then
				partsA = partsA + pTeamA:GetProjectCount(proj);
				partsB = partsB + pTeamB:GetProjectCount(proj);
			end
			
			proj = GameInfoTypes["PROJECT_SS_STASIS_CHAMBER"];
			if(proj ~= -1) then
				partsA = partsA + pTeamA:GetProjectCount(proj);
				partsB = partsB + pTeamB:GetProjectCount(proj);
			end
			
			proj = GameInfoTypes["PROJECT_SS_ENGINE"];
			if(proj ~= -1) then
				partsA = partsA + pTeamA:GetProjectCount(proj);
				partsB = partsB + pTeamB:GetProjectCount(proj);
			end
			
			return partsB < partsA;
		else
			return true;
		end
	elseif(apolloB)then
		return false;
	else
		return false;
	end
end

function PopulateEconomicScreen()
	if GameInfo.Victories["VICTORY_GAIA_ECONOMIC"] == nil or not GameDefines.GD_ECONOMIC_VICTORY_GOLD_TARGET then return end
	g_EconomicIM:ResetInstances();
	g_EconomicList = {};

	local luxuryList = GetEconomicVictoryMapLuxuries();
	local iRequiredLuxPercent = GameDefines.GD_ECONOMIC_VICTORY_LUX_PERCENTAGE;
	local iRequiredLuxuries = math.floor(#luxuryList * iRequiredLuxPercent / 100);
	local iRequiredGold = GameDefines.GD_ECONOMIC_VICTORY_GOLD_TARGET;
	local railProj = GameInfoTypes["PROJECT_GAIA_NATIONALRAIL"];

	for iPlayer = 0, GameDefines.MAX_MAJOR_CIVS - 1 do
		local pPlayer = Players[iPlayer];

		if pPlayer:IsEverAlive() and not pPlayer:IsMinorCiv() then
			-- Create Instance
			local controlTable = g_EconomicIM:GetInstance();
			local i = iPlayer + 1;
			g_EconomicList[i] = controlTable;

			-- Set Civ Name
			SetCivName(pPlayer, i, controlTable.Name, true, controlTable.Civ:GetSizeX() - controlTable.CivIconBG:GetSizeX());

			-- Set Civ Icon
			SetCivIcon(pPlayer, 45, controlTable.Icon, nil, controlTable.IconOut, not pPlayer:IsAlive(),
					   controlTable.CivIconBG, controlTable.CivIconShadow);

			-- Accumulated Gold
			local iPlayerGold = pPlayer:GetGold();
			controlTable.EconomicVictoryGold:SetText(Locale.Lookup("TXT_KEY_VP_ECONOMIC_GOLD", iPlayerGold, iRequiredGold));

			-- National Rail project
			if(railProj ~= nil and railProj ~= -1) then
				local railStatusKey = (Teams[pPlayer:GetTeam()]:GetProjectCount(railProj) > 0) and "TXT_KEY_VP_ECONOMIC_RAIL_DONE" or "TXT_KEY_VP_ECONOMIC_RAIL";
				controlTable.EconomicVictoryRail:SetText(Locale.Lookup(railStatusKey, "TXT_KEY_PROJECT_GAIA_NATIONALRAIL"));
			else
				controlTable.EconomicVictoryRail:SetText("");
			end

			-- Luxury list
			controlTable.EconomicVictoryLuxuries:SetText(Locale.Lookup("TXT_KEY_VP_ECONOMIC_LUXURIES", iRequiredLuxuries, #luxuryList));
			controlTable.LuxuryStack:DestroyAllChildren();

			local LuxuryRowsIM = InstanceManager:new("EconomicRow", "RowStack", controlTable.LuxuryStack);
			local curRow = nil;
			local curCol = 0;

			for _, iResource in ipairs(luxuryList) do
				local resource = GameInfo.Resources[iResource];

				if curRow == nil then
					curRow = LuxuryRowsIM:GetInstance();
				end

				local itemIM = InstanceManager:new("EconomicItem", "IconFrame", curRow.RowStack);
				local item = itemIM:GetInstance();

				IconHookup(resource.PortraitIndex, 45, resource.IconAtlas, item.Icon);

				local bHasResource = (pPlayer:GetNumResourceTotal(iResource, true) > 0);
				item.IconDark:SetHide(bHasResource);

				local statusKey = bHasResource and "TXT_KEY_VP_ECONOMIC_LUXURY_TOOLTIP_AQUIRED" or "TXT_KEY_VP_ECONOMIC_LUXURY_TOOLTIP";
				local txt = Locale.Lookup(statusKey, resource.Description);
				item.IconFrame:SetToolTipString(txt);

				curCol = curCol + 1;
				if curCol >= MAX_ECONOMIC_ICONS_PER_ROW then
					curRow = nil;
					curCol = 0;
				end
			end
		end
	end

	Controls.EconomicCompareStack:CalculateSize();
	Controls.EconomicCompareStack:ReprocessAnchoring();
	Controls.EconomicScrollPanel:CalculateInternalSize();
end

function SetCivLeader(pPlayer, iconSize, controlTable)
	local pTeam = Teams[pPlayer:GetTeam()];
	if (pTeam:IsHasMet(Game.GetActiveTeam()) or Game:IsNetworkMultiPlayer()) then
		local leader = GameInfo.Leaders[pPlayer:GetLeaderType()];
		local leaderDescription = leader.Description;

		IconHookup( leader.PortraitIndex, iconSize, leader.IconAtlas, controlTable );
	else
		IconHookup( 22, iconSize, "LEADER_ATLAS", controlTable );
	end
end
function SetCivName(pPlayer, number, controlTable, truncate, controlSize)
	if(truncate == nil)then
		truncate = false;
	end
	
	-- Set Text
	local strPlayer = "";
	local strCiv = "";
	local myCivType = pPlayer:GetCivilizationType(); 
	local myCivInfo = GameInfo.Civilizations[myCivType];

	if(pPlayer:GetNickName() ~= "" and Game:IsNetworkMultiPlayer()) then
		strPlayer = pPlayer:GetNickName();
		strCiv = myCivInfo.ShortDescription;
	elseif(pPlayer:GetID() == Game.GetActivePlayer()) then
		if(PreGame.GetCivilizationShortDescription(pPlayer:GetID()) ~= "") then
			strPlayer = "TXT_KEY_POP_VOTE_RESULTS_YOU";
			strCiv = PreGame.GetCivilizationShortDescription(pPlayer:GetID());
		else
			strPlayer = "TXT_KEY_POP_VOTE_RESULTS_YOU";
			strCiv = myCivInfo.ShortDescription;
		end
	else
		strPlayer = pPlayer:GetNameKey();
		strCiv = myCivInfo.ShortDescription;
	end
	
	local pTeam = Teams[pPlayer:GetTeam()];
	if (pTeam:IsHasMet(Game.GetActiveTeam()) or Game:IsNetworkMultiPlayer()) then
		if(truncate)then
			local displayText = Locale.ConvertTextKey("TXT_KEY_NUMBERING_FORMAT", number) .. " " .. Locale.ConvertTextKey( "TXT_KEY_RANDOM_LEADER_CIV", strPlayer, strCiv );
			TruncateString(controlTable, controlSize, displayText);
		else
			controlTable:SetText( Locale.ConvertTextKey("TXT_KEY_NUMBERING_FORMAT", number) .. " " .. Locale.ConvertTextKey( "TXT_KEY_RANDOM_LEADER_CIV", strPlayer, strCiv ) );
		end
	else
		if(truncate)then
			local displayText = Locale.ConvertTextKey("TXT_KEY_NUMBERING_FORMAT", number) .. " " .. Locale.ConvertTextKey( "TXT_KEY_MISC_UNKNOWN");
			TruncateString(controlTable, controlSize, displayText);
		else
			controlTable:SetText( Locale.ConvertTextKey("TXT_KEY_NUMBERING_FORMAT", number) .. " " .. Locale.ConvertTextKey( "TXT_KEY_MISC_UNKNOWN"));
		end
	end
end

function SetCivIcon(pPlayer, iconSize, controlTable, controlTableTT, controlLost, lostCondition, controlBG, controlShadow)
	local iPlayer = pPlayer:GetID();
	-- Set Civ Icon
	local pTeam = Teams[pPlayer:GetTeam()];
	if (pTeam:IsHasMet(Game.GetActiveTeam()) or Game:IsNetworkMultiPlayer()) then
		CivIconHookup( iPlayer, iconSize, controlTable, controlBG, controlShadow, false, true );
		if(controlTableTT ~= nil) then
			if(Game:IsNetworkMultiPlayer() and pPlayer:GetNickName() ~= "") then
				controlTableTT:SetToolTipString(pPlayer:GetNickName());
			elseif(iPlayer == Game.GetActivePlayer()) then
				controlTableTT:SetToolTipString(Locale.ConvertTextKey( "TXT_KEY_POP_VOTE_RESULTS_YOU" ));
			else
				local myCivType = pPlayer:GetCivilizationType();
				local myCivInfo = GameInfo.Civilizations[myCivType];
				controlTableTT:SetToolTipString(Locale.ConvertTextKey(myCivInfo.ShortDescription));
			end
		end
	else
		CivIconHookup(-1, iconSize, controlTable, controlBG, controlShadow, false, true );
		if(controlTableTT ~= nil) then
			controlTableTT:SetToolTipString(Locale.ConvertTextKey( "TXT_KEY_MISC_UNKNOWN"));
		end
	end
	
	if(lostCondition and controlLost ~= nil) then
		local darken = {x = 1, y = 1, z = 1, w = 0.25};
		controlLost:SetHide(false);
		controlTable:SetColor(darken);
	end
end

function SetConquestCivIcon(pPlayer, iconSize, controlTable, controlTableTT, controlDominatingPlayer, controlConqueredCivIconBG, controlConqueredCivIconShadow, controlConqueredCivIcon, controlIconOut, pDominatingPlayer, controlBG, controlShadow)
	local iPlayer = pPlayer:GetID();
	
	-- Set Civ Icon
	local pTeam = Teams[pPlayer:GetTeam()];
	local bHasMetOrMultiplayer = pTeam:IsHasMet(Game.GetActiveTeam()) or Game:IsNetworkMultiPlayer();
	
	if (bHasMetOrMultiplayer == true) then
		CivIconHookup(iPlayer, iconSize, controlTable, controlBG, controlShadow, false, true );
	else
		CivIconHookup(-1, iconSize, controlTable, controlBG, controlShadow, false, true );
	end	
	
	if(pDominatingPlayer == nil) then
		if(iPlayer == Game.GetActivePlayer()) then
			controlTableTT:SetToolTipString(Locale.Lookup("TXT_KEY_VP_DIPLO_TT_YOU_NO_CAPITAL"));
	
		elseif(bHasMetOrMultiplayer) then	
			local playerName;
			if (pPlayer:GetNickName() ~= "" and Game:IsNetworkMultiPlayer()) then
				playerName = pPlayer:GetNickName();
			else
				playerName = pPlayer:GetName();
			end
		
			controlTableTT:SetToolTipString(Locale.Lookup("TXT_KEY_VP_DIPLO_TT_KNOWN_NO_CAPITAL", playerName));
		else
			controlTableTT:SetToolTipString(Locale.Lookup("TXT_KEY_VP_DIPLO_TT_UNKNOWN_NO_CAPITAL"));
		end
	
		return;
	end
	
	local iDominatingPlayer = pDominatingPlayer:GetID();	
	local pDominatingTeam = Teams[pDominatingPlayer:GetTeam()];
	
	if (iPlayer == iDominatingPlayer) then
		controlDominatingPlayer:SetHide(true);
	else
		controlDominatingPlayer:SetHide(false);
		if (pDominatingTeam:IsHasMet(Game.GetActiveTeam())) then
			CivIconHookup(iDominatingPlayer, 45, controlConqueredCivIcon, controlConqueredCivIconBG, controlConqueredCivIconShadow, false, true);
		else
			CivIconHookup(-1, 45, controlConqueredCivIcon, controlConqueredCivIconBG, controlConqueredCivIconShadow, false, true);
		end
	end
	
	if (controlTableTT ~= nil) then
		if (iPlayer == iDominatingPlayer) then
			if (pTeam:IsHasMet(Game.GetActiveTeam())) then
				local pOriginalCapital = nil;
				for pCity in pPlayer:Cities() do
					if (pCity:IsOriginalMajorCapital() and pCity:GetOriginalOwner() == iPlayer) then
						pOriginalCapital = pCity;
					end
				end
	
				if (iPlayer == Game.GetActivePlayer()) then
					controlTableTT:SetToolTipString(Locale.ConvertTextKey("TXT_KEY_VP_DIPLO_TT_YOU_CONTROL_YOUR_CAPITAL", pOriginalCapital:GetNameKey()));
				else
					if (pPlayer:GetNickName() ~= "" and Game:IsNetworkMultiPlayer()) then
						controlTableTT:SetToolTipString(Locale.ConvertTextKey("TXT_KEY_VP_DIPLO_TT_SOMEONE_CONTROLS_THEIR_CAPITAL", pPlayer:GetNickName(), pOriginalCapital:GetNameKey()));
					else
						controlTableTT:SetToolTipString(Locale.ConvertTextKey("TXT_KEY_VP_DIPLO_TT_SOMEONE_CONTROLS_THEIR_CAPITAL", pPlayer:GetName(), pOriginalCapital:GetNameKey()));
					end
				end
			else
				controlTableTT:SetToolTipString(Locale.ConvertTextKey("TXT_KEY_VP_DIPLO_TT_UNMET_CONTROLS_THEIR_CAPITAL"));			
			end
		else
			local tooltipDomination = "";
			if (pTeam:IsHasMet(Game.GetActiveTeam())) then
				local pOriginalCapital = nil;
				pOriginalCapital = pPlayer:_GetOriginalCapitalPlot():GetWorkingCity();
				if (pOriginalCapital == nil) then return end
				if (pDominatingPlayer ~= Players[pPlayer:_GetOriginalCapitalPlot():GetWorkingCity():GetOwner()] or pDominatingPlayer:IsMinorCiv()) then
					local pOwnerOfCapital = Players[pPlayer:_GetOriginalCapitalPlot():GetWorkingCity():GetOwner()];
					if Teams[pOwnerOfCapital:GetTeam()]._IsVassalOfSomeone and Teams[pOwnerOfCapital:GetTeam()]:_IsVassalOfSomeone() then
						local PlayerNameKey = Locale.ConvertTextKey("TXT_KEY_UNMET_PLAYER");
						local CityNameKey = "?"
						if Teams[pOwnerOfCapital:GetTeam()]:IsHasMet(Game.GetActiveTeam()) then PlayerNameKey = pOwnerOfCapital:GetName(); end
						if Teams[Players[pOriginalCapital:GetOriginalOwner()]:GetTeam()]:IsHasMet(Game.GetActiveTeam()) then CityNameKey = pOriginalCapital:GetNameKey(); end
						tooltipDomination = Locale.ConvertTextKey("TXT_KEY_GAIA_DOMINATION_TT_VASSAL_HOLDS_CAPITAL_FOR_MASTER", PlayerNameKey, CityNameKey) .. tooltipDomination
					end
					if (pOwnerOfCapital:IsMinorCiv()) then
						local PlayerNameKey = Locale.ConvertTextKey("TXT_KEY_UNMET_PLAYER");
						local CityNameKey = "?"
						if Teams[pOwnerOfCapital:GetTeam()]:IsHasMet(Game.GetActiveTeam()) then PlayerNameKey = pOwnerOfCapital:GetName(); end
						if Teams[Players[pOriginalCapital:GetOriginalOwner()]:GetTeam()]:IsHasMet(Game.GetActiveTeam()) then CityNameKey = pOriginalCapital:GetNameKey(); end 
						if (pOwnerOfCapital:GetAlly() == pDominatingPlayer:GetID()) then
							tooltipDomination = Locale.ConvertTextKey("TXT_KEY_GAIA_DOMINATION_TT_CITY_STATE_HOLDS_CAPITAL_FOR_ALLY", PlayerNameKey, CityNameKey) .. tooltipDomination
						elseif pOwnerOfCapital:GetAlly() ~= -1 then
							if (Teams[Players[pOwnerOfCapital:GetAlly()]:GetTeam()]._IsVassalOfSomeone and Teams[Players[pOwnerOfCapital:GetAlly()]:GetTeam()]:_IsVassalOfSomeone()) then
								tooltipDomination = Locale.ConvertTextKey("TXT_KEY_GAIA_DOMINATION_TT_CITY_STATE_HOLDS_CAPITAL_FOR_ALLYS_MASTER", PlayerNameKey, CityNameKey) .. tooltipDomination
							end
						else
							tooltipDomination = Locale.ConvertTextKey("TXT_KEY_GAIA_DOMINATION_TT_CITY_STATE_HOLDS_CAPITAL_NO_ALLY", PlayerNameKey, CityNameKey) .. tooltipDomination
						end
					end

				end
			
				if (pDominatingTeam:IsHasMet(Game.GetActiveTeam())) then
					if (iPlayer == Game.GetActivePlayer()) then
						if (pDominatingPlayer:GetNickName() ~= "" and Game:IsNetworkMultiPlayer()) then
							tooltipDomination = tooltipDomination .. Locale.ConvertTextKey("TXT_KEY_VP_DIPLO_TT_OTHER_PLAYER_CONTROLS_YOUR_CAPITAL", pDominatingPlayer:GetNickName(), pOriginalCapital:GetNameKey());
							if (pDominatingTeam._IsVassal and pDominatingTeam:_IsVassal(Game.GetActiveTeam())) then
								tooltipDomination = tooltipDomination .. Locale.ConvertTextKey("TXT_KEY_GAIA_DOMINATION_TT_YOU_ARE_VASSAL_OF_PLAYER", Players[Teams[Teams[pPlayer:GetTeam()]:_GetMaster()]:GetLeaderID()]:GetNickName());
							end
						else
							tooltipDomination = tooltipDomination .. Locale.ConvertTextKey("TXT_KEY_VP_DIPLO_TT_OTHER_PLAYER_CONTROLS_YOUR_CAPITAL", pDominatingPlayer:GetName(), pOriginalCapital:GetNameKey());
							if (pDominatingTeam._IsVassal and pDominatingTeam:_IsVassal(Game.GetActiveTeam())) then
								tooltipDomination = tooltipDomination .. Locale.ConvertTextKey("TXT_KEY_GAIA_DOMINATION_TT_YOU_ARE_VASSAL_OF_PLAYER", Players[Teams[Teams[pPlayer:GetTeam()]:_GetMaster()]:GetLeaderID()]:GetName());
							end
						end
					else
						if (iDominatingPlayer == Game.GetActivePlayer()) then
							tooltipDomination = tooltipDomination .. Locale.ConvertTextKey("TXT_KEY_VP_DIPLO_TT_YOU_CONTROL_OTHER_PLAYER_CAPITAL", pOriginalCapital:GetNameKey(), pPlayer:GetCivilizationShortDescriptionKey());
							if (iDominatingPlayer == Game.GetActivePlayer() and Teams[pPlayer:GetTeam()]._IsVassal and Teams[pPlayer:GetTeam()]:_IsVassal(Game.GetActiveTeam())) then
								tooltipDomination = tooltipDomination .. Locale.ConvertTextKey("TXT_KEY_GAIA_DOMINATION_TT_CIV_IS_YOUR_VASSAL", pPlayer:GetCivilizationShortDescriptionKey());
							elseif (Teams[pPlayer:GetTeam()]._IsVassalOfSomeone and Teams[pPlayer:GetTeam()]:_IsVassalOfSomeone()) then
								tooltipDomination = tooltipDomination .. Locale.ConvertTextKey("TXT_KEY_GAIA_DOMINATION_TT_CIV_IS_VASSAL_OF_PLAYER", Players[Teams[Teams[pPlayer:GetTeam()]:_GetMaster()]:GetLeaderID()]:GetName(), pPlayer:GetCivilizationShortDescriptionKey());
							end
						else
							if (pDominatingPlayer:GetNickName() ~= "" and Game:IsNetworkMultiPlayer()) then
								tooltipDomination = tooltipDomination .. Locale.ConvertTextKey("TXT_KEY_VP_DIPLO_TT_OTHER_PLAYER_CONTROLS_OTHER_PLAYER_CAPITAL", pDominatingPlayer:GetNickName(), pOriginalCapital:GetNameKey(), pPlayer:GetCivilizationShortDescriptionKey())
								if (Teams[pPlayer:GetTeam()]._IsVassalOfSomeone and Teams[pPlayer:GetTeam()]:_IsVassalOfSomeone()) then
									tooltipDomination = tooltipDomination .. Locale.ConvertTextKey("TXT_KEY_GAIA_DOMINATION_TT_CIV_IS_VASSAL_OF_PLAYER", Players[Teams[Teams[pPlayer:GetTeam()]:_GetMaster()]:GetLeaderID()]:GetNickName(), pPlayer:GetCivilizationShortDescriptionKey())
								elseif (iDominatingPlayer == Game.GetActivePlayer() and Teams[pPlayer:GetTeam()]._IsVassal and Teams[pPlayer:GetTeam()]:_IsVassal(Game.GetActiveTeam())) then
									tooltipDomination = tooltipDomination .. Locale.ConvertTextKey("TXT_KEY_GAIA_DOMINATION_TT_CIV_IS_YOUR_VASSAL", pPlayer:GetCivilizationShortDescriptionKey());
								end
							else
								tooltipDomination = tooltipDomination .. Locale.ConvertTextKey("TXT_KEY_VP_DIPLO_TT_OTHER_PLAYER_CONTROLS_OTHER_PLAYER_CAPITAL", pDominatingPlayer:GetName(), pOriginalCapital:GetNameKey(), pPlayer:GetCivilizationShortDescriptionKey())
								if (Teams[pPlayer:GetTeam()]._IsVassalOfSomeone and Teams[pPlayer:GetTeam()]:_IsVassalOfSomeone()) then
									tooltipDomination = tooltipDomination .. Locale.ConvertTextKey("TXT_KEY_GAIA_DOMINATION_TT_CIV_IS_VASSAL_OF_PLAYER", Players[Teams[Teams[pPlayer:GetTeam()]:_GetMaster()]:GetLeaderID()]:GetName(), pPlayer:GetCivilizationShortDescriptionKey());
								end
							end
						end
					end
				else
					tooltipDomination = tooltipDomination .. Locale.ConvertTextKey("TXT_KEY_VP_DIPLO_TT_UNMET_PLAYER_CONTROLS_OTHER_PLAYER_CAPITAL", pOriginalCapital:GetNameKey(), pPlayer:GetCivilizationShortDescriptionKey());
				end
			else
				if (pDominatingTeam:IsHasMet(Game.GetActiveTeam())) then
					if (pDominatingPlayer:GetNickName() ~= "" and Game:IsNetworkMultiPlayer()) then
						tooltipDomination = tooltipDomination .. Locale.ConvertTextKey("TXT_KEY_VP_DIPLO_TT_OTHER_PLAYER_CONTROLS_UNMET_PLAYER_CAPITAL", pDominatingPlayer:GetNickName())
					else
						tooltipDomination = tooltipDomination .. Locale.ConvertTextKey("TXT_KEY_VP_DIPLO_TT_OTHER_PLAYER_CONTROLS_UNMET_PLAYER_CAPITAL", pDominatingPlayer:GetName())
					end
				else
					if (Teams[pPlayer:GetTeam()]._IsVassal and Teams[pPlayer:GetTeam()]:_IsVassal(pDominatingPlayer:GetTeam())) then
						tooltipDomination = tooltipDomination .. Locale.ConvertTextKey("TXT_KEY_GAIA_DOMINATION_TT_UNMET_VASSAL_OF_UNMET_PLAYER");
					else
						tooltipDomination = tooltipDomination .. Locale.ConvertTextKey("TXT_KEY_VP_DIPLO_TT_UNMET_PLAYER_CONTROLS_UNMET_PLAYER_CAPITAL");
					end
				end
			end
			controlTableTT:SetToolTipString(tooltipDomination);
		end
	
	end
end


function DeleteScoreScreen()
	g_ScoreIM:ResetInstances();
	g_ScoreList = {};
end

function DeleteSpaceRaceScreen()
	g_TechIM:ResetInstances();
	g_TechList = {};
end

function DeleteDiploScreen()
	g_DiploIM:ResetInstances();
	g_DiploList = {};
end

function DeleteEconomicScreen()
	g_EconomicIM:ResetInstances();
	g_EconomicList = {};
end

-------------------------------------------------
-- On Popup
-------------------------------------------------
function OnPopup( popupInfo )

	if( popupInfo.Type == ButtonPopupTypes.BUTTONPOPUP_VICTORY_INFO ) then
		m_PopupInfo = popupInfo;
		if( m_PopupInfo.Data1 == 1 ) then
		
        	if( ContextPtr:IsHidden() == false ) then
        	    OnBack();
            else
            	UIManager:QueuePopup( ContextPtr, PopupPriority.InGameUtmost );
        	end
    	else
        	UIManager:QueuePopup( ContextPtr, PopupPriority.VictoryProgress );
    	end
	end
end
Events.SerialEventGameMessagePopup.Add( OnPopup );

----------------------------------------------------------------
-- Key Down Processing
----------------------------------------------------------------
function InputHandler( uiMsg, wParam, lParam )
    if( uiMsg == KeyEvents.KeyDown )
    then
        if( wParam == Keys.VK_RETURN or wParam == Keys.VK_ESCAPE ) then
			OnBack();
            return true;
        end
    end
end
ContextPtr:SetInputHandler( InputHandler );


function ShowHideHandler( bIsHide, bIsInit )
    
    if( not bIsInit ) then
        if( not bIsHide ) then
			SetupScreen();
            UI.incTurnTimerSemaphore();
            Events.SerialEventGameMessagePopupShown(m_PopupInfo);
        else
			Events.SerialEventGameMessagePopupProcessed.CallImmediate(ButtonPopupTypes.BUTTONPOPUP_VICTORY_INFO, 0);
            UI.decTurnTimerSemaphore();
        end
    end

end
ContextPtr:SetShowHideHandler( ShowHideHandler );

Events.GameplaySetActivePlayer.Add(OnBack);
