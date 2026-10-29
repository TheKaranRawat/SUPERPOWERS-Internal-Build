-------------------------------------------------
-- Vassalage
-------------------------------------------------
include( "IconSupport" );
include( "InstanceManager" );
include( "TechHelpInclude" );

local m_PopupInfo = nil;

local isVassalageEnabled = Game.IsOption("GAMEOPTION_GAIA_VASSALAGE")

local g_VassalButtonIM = InstanceManager:new( "VassalButtonInstance", "VassalButton", Controls.VassalStack );

local g_iPlayer = Game.GetActivePlayer();
local g_pPlayer = Players[ g_iPlayer ];
local g_iTeam = g_pPlayer:GetTeam();
local g_pTeam = Teams[ g_iTeam ];

local g_IdeologyBackgrounds = {
	["POLICY_BRANCH_AUTOCRACY"] = "loading_13.dds",
	["POLICY_BRANCH_FREEDOM"]   = "loadingbasegame_19.dds",
	["POLICY_BRANCH_ORDER"]     = "loadingbasegame_7.dds",
	["default"]                 = "loading_20.dds"
}

local g_SelectedVassal = nil;
local g_SelectedMaster = nil;

-----------------------------------------------------------------
-- Add Vassal Overview to Dropdown
-----------------------------------------------------------------
LuaEvents.AdditionalInformationDropdownGatherEntries.Add( function(entries)
	if isVassalageEnabled then
		table.insert(entries, {
			text = Locale.Lookup("TXT_KEY_GAIA_VASSALAGE_OVERVIEW_TITLE"),
			call = function()
				Events.SerialEventGameMessagePopup {
					Type = ButtonPopupTypes.BUTTONPOPUP_GAIA_VASSALAGE_OVERVIEW,
				};
			end,
		});
		
	end
end);

function ClearVassalDetails()
	Controls.VassalDescBox:SetHide(true);
	Controls.MasterDescBox:SetHide(true);
end

function Update()
	g_iPlayer = Game.GetActivePlayer();
	g_pPlayer = Players[ g_iPlayer ];
	g_iTeam = g_pPlayer:GetTeam();
	g_pTeam = Teams[ g_iTeam ];

	function HasVassalageStarted()
		return (g_pTeam:GetCurrentEra() >= Game._GetVassalageEnabledEra()) or g_pTeam:_IsVassalOfSomeone();
	end

	local bVassalStarted = HasVassalageStarted();

	Controls.LabelNoVassals:SetHide( g_pTeam:_GetNumVassals() ~= 0 or g_pTeam:_IsVassalOfSomeone() );
	Controls.LabelVassalNotStartedYet:SetHide(bVassalStarted);
	Controls.OverviewPanel:SetHide(not bVassalStarted);
	Controls.NumVassals:SetHide(not bVassalStarted);
	Controls.NumVassalsWorld:SetHide(not bVassalStarted);

	SetBackground();

	if(bVassalStarted) then
		local iTotalVassals = 0;

		for iTeamLoop = 0, GameDefines.MAX_CIV_TEAMS - 1 do
			local pTeam = Teams[iTeamLoop];
			if pTeam:_GetMaster() ~= -1 then
				iTotalVassals = iTotalVassals + 1;
			end
		end

		Controls.NumVassals:LocalizeAndSetText( "TXT_KEY_GAIA_VASSALAGE_FOOTER_YOUR_VASSAL_COUNT", g_pTeam:_GetNumVassals() );
		Controls.NumVassalsWorld:LocalizeAndSetText( "TXT_KEY_GAIA_VASSALAGE_FOOTER_WORLD_VASSAL_COUNT", iTotalVassals );

		-- Show Master Information
		if( g_pTeam:_IsVassalOfSomeone() ) then
			PopulateMasterList();
			g_SelectedMaster = nil;
		-- Show Vassal Information
		else
			PopulateVassalList();
			g_SelectedVassal = nil;
		end
	end
end

function SetBackground()
	local iIdeology = g_pPlayer:GetLateGamePolicyTree();
	local strBackgroundImage = g_IdeologyBackgrounds["default"];

	if iIdeology ~= -1 then
		local ideology = GameInfo.PolicyBranchTypes[iIdeology];
		if ideology and g_IdeologyBackgrounds[ideology.Type] then
			strBackgroundImage = g_IdeologyBackgrounds[ideology.Type];
		end
	end

	Controls.VassalBackgroundImage:SetTextureAndResize(strBackgroundImage);
	Controls.VassalBackgroundImage:SetSizeX(926);
	Controls.VassalBackgroundImage:SetSizeY(500);
end

function PopulateMasterList()
	if (ContextPtr:IsHidden()) then
		return;
	end
	
	if (IsGameCoreBusy()) then
		return;
	end

	Controls.LabelVassalList:SetText( Locale.ConvertTextKey( "TXT_KEY_GAIA_VASSALAGE_LIST_MASTERS_HEADER" ) );
	Controls.LabelVassalDetails:SetText( Locale.ConvertTextKey( "TXT_KEY_GAIA_VASSALAGE_PROFILE_MASTER_HEADER" ) );

	g_VassalButtonIM:ResetInstances();

	for iPlayerLoop = 0, GameDefines.MAX_MAJOR_CIVS-1, 1 do
	
		local pOtherPlayer = Players[iPlayerLoop];
		if pOtherPlayer:IsEverAlive() then
			local iOtherTeam = pOtherPlayer:GetTeam();
			local pOtherTeam = Teams[ iOtherTeam ];

			if (iPlayerLoop ~= g_iPlayer and pOtherPlayer:IsAlive()) then
				if (g_pTeam:_IsVassal(iOtherTeam)) then
					local controlTable = g_VassalButtonIM:GetInstance();

					if(pOtherPlayer:GetNickName() ~= "" and Game.IsGameMultiPlayer() and pOtherPlayer:IsHuman()) then
						controlTable.LeaderName:SetText( pOtherPlayer:GetNickName() ); 
					else
						controlTable.LeaderName:SetText( pOtherPlayer:GetName() );
					end

					local civType = pOtherPlayer:GetCivilizationType();
					local civInfo = GameInfo.Civilizations[civType];
					local strCiv = Locale.ConvertTextKey(civInfo.ShortDescription);

					local otherLeaderType = pOtherPlayer:GetLeaderType();
					local otherLeaderInfo = GameInfo.Leaders[otherLeaderType];

					controlTable.CivName:SetText(strCiv);
					IconHookup( otherLeaderInfo.PortraitIndex, 64, otherLeaderInfo.IconAtlas, controlTable.LeaderPortrait );

            		if( pOtherTeam:GetNumMembers() > 1 ) then
            			controlTable.TeamID:LocalizeAndSetText( "TXT_KEY_MULTIPLAYER_DEFAULT_TEAM_NAME", pOtherTeam:GetID() + 1 );
            			controlTable.TeamID:SetHide( false );
					else
            			controlTable.TeamID:SetHide( true );
            		end

					controlTable.VassalButton:SetVoid1( iPlayerLoop );
					controlTable.VassalButton:RegisterCallback( Mouse.eLClick, OnMasterPicked );
				end
			end
		end
	end
	Controls.VassalStack:CalculateSize();

	Controls.ScrollPanel:CalculateInternalSize();
	Controls.ScrollPanel:ReprocessAnchoring();
end

function PopulateVassalList()
	if (ContextPtr:IsHidden()) then
		return;
	end
	
	if (IsGameCoreBusy()) then
		return;
	end

	Controls.LabelVassalList:SetText( Locale.ConvertTextKey( "TXT_KEY_GAIA_VASSALAGE_LIST_VASSALS_HEADER" ) );
	Controls.LabelVassalDetails:SetText( Locale.ConvertTextKey( "TXT_KEY_GAIA_VASSALAGE_PROFILE_VASSAL_HEADER" ) );

	g_VassalButtonIM:ResetInstances();

	for iPlayerLoop = 0, GameDefines.MAX_MAJOR_CIVS-1, 1 do
	
		local pOtherPlayer = Players[iPlayerLoop];
		if pOtherPlayer:IsEverAlive() then
			local iOtherTeam = pOtherPlayer:GetTeam();
			local pOtherTeam = Teams[ iOtherTeam ];

			if (iPlayerLoop ~= g_iPlayer and pOtherPlayer:IsAlive()) then
				if (pOtherTeam:_IsVassal(g_iTeam)) then
					local controlTable = g_VassalButtonIM:GetInstance();

					if(pOtherPlayer:GetNickName() ~= "" and Game.IsGameMultiPlayer() and pOtherPlayer:IsHuman()) then
						controlTable.LeaderName:SetText( pOtherPlayer:GetNickName() );
					else
						controlTable.LeaderName:SetText( pOtherPlayer:GetName() );
					end

					local civType = pOtherPlayer:GetCivilizationType();
					local civInfo = GameInfo.Civilizations[civType];
					local strCiv = Locale.ConvertTextKey(civInfo.ShortDescription);

					local otherLeaderType = pOtherPlayer:GetLeaderType();
					local otherLeaderInfo = GameInfo.Leaders[otherLeaderType];

					controlTable.CivName:SetText(strCiv);
					IconHookup( otherLeaderInfo.PortraitIndex, 64, otherLeaderInfo.IconAtlas, controlTable.LeaderPortrait );

            		if( pOtherTeam:GetNumMembers() > 1 ) then
            			controlTable.TeamID:LocalizeAndSetText( "TXT_KEY_MULTIPLAYER_DEFAULT_TEAM_NAME", pOtherTeam:GetID() + 1 );
            			controlTable.TeamID:SetHide( false );
					else
            			controlTable.TeamID:SetHide( true );
            		end

					controlTable.VassalButton:SetVoid1( iPlayerLoop );
					controlTable.VassalButton:RegisterCallback( Mouse.eLClick, OnVassalPicked );
				end
			end
		end
	end
	Controls.VassalStack:CalculateSize();

	Controls.ScrollPanel:CalculateInternalSize();
	Controls.ScrollPanel:ReprocessAnchoring();
end

-------------------------------------------------
-- On Leader Selected
-------------------------------------------------
function OnMasterPicked( ePlayer )
	if not Players[Game.GetActivePlayer()]:IsTurnActive() or Game.IsProcessingMessages() then
		return;
	end

	if( Controls.MasterDescBox:IsHidden() ) then
		Controls.MasterDescBox:SetHide(false);
	end

	local pMasterPlayer = Players[ePlayer];
	local iMasterTeam = pMasterPlayer:GetTeam();
	local pMasterTeam = Teams[iMasterTeam];

	g_SelectedMaster = iMasterTeam;
	
	local civType = pMasterPlayer:GetCivilizationType();
	local civInfo = GameInfo.Civilizations[civType];
	local strCiv = Locale.ConvertTextKey(civInfo.ShortDescription);
	
	if(pMasterPlayer:GetNickName() ~= "" and Game.IsGameMultiPlayer() and pMasterPlayer:IsHuman()) then
		Controls.MasterInfoLeaderName:SetText( pMasterPlayer:GetNickName() );
	else
		Controls.MasterInfoLeaderName:SetText( pMasterPlayer:GetName() );
	end
	
	Controls.MasterInfoCivName:SetText( strCiv );

	-- Leader Portrait
	local pLeader = GameInfo.Leaders[pMasterPlayer:GetLeaderType()];
	IconHookup( pLeader.PortraitIndex, 128, pLeader.IconAtlas, Controls.MasterIcon );
	CivIconHookup( ePlayer, 45, Controls.MasterSubIcon, Controls.MasterSubIconBG, Controls.MasterSubIconShadow, true, true, Controls.MasterSubIconHighlight );

	Controls.MasterTurnsYouAreVassal:LocalizeAndSetText( "TXT_KEY_GAIA_VASSALAGE_TURNS_AS_VASSAL", g_pTeam:_GetNumTurnsIsVassal(), Game.GetGameTurn() - g_pTeam:_GetNumTurnsIsVassal() );
	
	local strIndependencePossible = "";
	if( g_pTeam:_CanEndVassal(iMasterTeam) ) then
		strIndependencePossible = "[COLOR_POSITIVE_TEXT]" .. Locale.ConvertTextKey("TXT_KEY_DECLARE_WAR_YES") .. "[ENDCOLOR]";
	else 
		strIndependencePossible = "[COLOR_NEGATIVE_TEXT]" .. Locale.ConvertTextKey("TXT_KEY_DECLARE_WAR_NO") .. "[ENDCOLOR]";
	end
	
	Controls.MasterDeclareIndependence:LocalizeAndSetText( "TXT_KEY_GAIA_VASSALAGE_INDEPENDENCE_ALLOWED_WITH_VALUE", strIndependencePossible );
	Controls.MasterDeclareIndependence:LocalizeAndSetToolTip( g_pPlayer:_GetVassalIndependenceTooltipAsVassal(ePlayer) );

	-- Request Independence button
	local bCanRequestIndependence = g_pTeam:_CanEndVassal( iMasterTeam );

	local strTooltip = "";
	strTooltip = strTooltip .. Locale.ConvertTextKey( "TXT_KEY_GAIA_VASSALAGE_SEEK_INDEPENDENCE_TT", pMasterTeam:GetName() );
	-- Can't request? Set up tooltip
	if( not bCanRequestIndependence ) then
		local iMinimumTurns = 0;
		if ( g_pTeam:_IsVoluntaryVassal(iMasterTeam) ) then
			iMinimumTurns = Game._GetMinimumVoluntaryVassalTurns();
		else 
			iMinimumTurns = Game._GetMinimumVassalTurns();
		end

		local iNumTurnsIsVassal = g_pTeam:_GetNumTurnsIsVassal();

		if(iNumTurnsIsVassal < iMinimumTurns) then
			strTooltip = strTooltip .. "[NEWLINE][NEWLINE]" .. Locale.ConvertTextKey( "TXT_KEY_GAIA_VASSALAGE_SEEK_INDEPENDENCE_TOO_SOON_TT", iMinimumTurns, iMinimumTurns - iNumTurnsIsVassal);
		else
			strTooltip = strTooltip .. "[NEWLINE][NEWLINE]" .. Locale.ConvertTextKey( "TXT_KEY_GAIA_VASSALAGE_SEEK_INDEPENDENCE_CONDITIONS_UNMET_TT" );
		end
	end

	Controls.RequestIndependence:SetDisabled( not bCanRequestIndependence );
	Controls.RequestIndependence:SetToolTipString( strTooltip );
	Controls.RequestIndependence:SetVoid1( pMasterTeam:GetLeaderID() );
	Controls.RequestIndependence:RegisterCallback( Mouse.eLClick, OnRequestIndependence );

	RefreshMasterStats( ePlayer );
	RefreshMasterTaxes( ePlayer );

	local strType, strTypeTooltip;
	if( g_pTeam:_IsVoluntaryVassal( iMasterTeam ) ) then
		strType = Locale.ConvertTextKey( "TXT_KEY_GAIA_VASSALAGE_TYPE_VOLUNTARY_LABEL" );
		strTypeTooltip = Locale.ConvertTextKey( "TXT_KEY_GAIA_VASSALAGE_TYPE_VOLUNTARY_SEEN_BY_VASSAL_TT", pMasterTeam:GetName() );
	else
		strType = Locale.ConvertTextKey( "TXT_KEY_GAIA_VASSALAGE_TYPE_CAPITULATED_LABEL" );
		strTypeTooltip = Locale.ConvertTextKey( "TXT_KEY_GAIA_VASSALAGE_TYPE_CAPITULATED_SEEN_BY_VASSAL_TT", pMasterTeam:GetName() );
	end

	Controls.MasterVassalType:SetText(strType);
	Controls.MasterVassalType:SetToolTipString(strTypeTooltip);
end

function OnVassalPicked( ePlayer )

	if not Players[Game.GetActivePlayer()]:IsTurnActive() or Game.IsProcessingMessages() then
		return;
	end

	if( Controls.VassalDescBox:IsHidden() ) then
		Controls.VassalDescBox:SetHide(false);
	end

	local pVassalPlayer = Players[ePlayer];
	local iVassalTeam = pVassalPlayer:GetTeam();
	local pVassalTeam = Teams[iVassalTeam];

	g_SelectedVassal = iVassalTeam;
	
	local civType = pVassalPlayer:GetCivilizationType();
	local civInfo = GameInfo.Civilizations[civType];
	local strCiv = Locale.ConvertTextKey(civInfo.ShortDescription);
	
	if(pVassalPlayer:GetNickName() ~= "" and Game.IsGameMultiPlayer() and pVassalPlayer:IsHuman()) then
		Controls.VassalInfoLeaderName:SetText( pVassalPlayer:GetNickName() );
	else
		Controls.VassalInfoLeaderName:SetText( pVassalPlayer:GetName() );
	end

	Controls.VassalInfoCivName:SetText( strCiv );
	Controls.VassalInfoStarted:LocalizeAndSetText("TXT_KEY_GAIA_VASSALAGE_TURNS_AS_VASSAL", pVassalTeam:_GetNumTurnsIsVassal(), Game.GetGameTurn() - pVassalTeam:_GetNumTurnsIsVassal() );

	-- Leader Portrait
	local pLeader = GameInfo.Leaders[pVassalPlayer:GetLeaderType()];
	IconHookup( pLeader.PortraitIndex, 128, pLeader.IconAtlas, Controls.VassalIcon );
	CivIconHookup( ePlayer, 45, Controls.VassalSubIcon, Controls.VassalSubIconBG, Controls.VassalSubIconShadow, true, true, Controls.VassalSubIconHighlight );

	local iCityPercent = 0;
	local iPopPercent = 0;
	
	if( pVassalTeam:_GetNumCitiesWhenVassalMade() ~= 0 ) then
		iCityPercent = math.floor(pVassalTeam:GetNumCities() * 100 / pVassalTeam:_GetNumCitiesWhenVassalMade());
	else
		if( pVassalTeam:GetNumCities() == 0) then
			iCityPercent = 0;
		else
			iCityPercent = 100;
		end
	end
	if( pVassalTeam:_GetTotalPopulationWhenVassalMade() ~= 0 ) then
		iPopPercent = math.floor(pVassalTeam:GetTotalPopulation() * 100 / pVassalTeam:_GetTotalPopulationWhenVassalMade());
	else
		if( pVassalTeam:GetTotalPopulation() == 0) then
			iPopPercent = 0;
		else
			iPopPercent = 100;
		end
	end

	local iMasterCityPercent = 0;
	local iMasterPopPercent = 0;

	if( g_pTeam:GetNumCities() ~= 0) then
		iMasterCityPercent = math.floor(pVassalTeam:GetNumCities() * 100 / g_pTeam:GetNumCities());
	end
	if( g_pTeam:GetTotalPopulation() ~= 0) then
		iMasterPopPercent = math.floor(pVassalTeam:GetTotalPopulation() * 100 / g_pTeam:GetTotalPopulation());
	end

	local iMinimumTurns = 0;
	if( pVassalTeam:_IsVoluntaryVassal(g_iTeam) ) then
		iMinimumTurns = Game._GetMinimumVoluntaryVassalTurns();
	else
		iMinimumTurns = Game._GetMinimumVassalTurns();
	end

	local strIndependenceTooltip = g_pPlayer:_GetVassalIndependenceTooltipAsMaster(ePlayer);

	local strIndependencePossible = "";
	if( pVassalTeam:_CanEndVassal(g_iPlayer) ) then
		strIndependencePossible = "[COLOR_NEGATIVE_TEXT]" .. Locale.ConvertTextKey("TXT_KEY_DECLARE_WAR_YES") .. "[ENDCOLOR]";
	else 
		strIndependencePossible = "[COLOR_POSITIVE_TEXT]" .. Locale.ConvertTextKey("TXT_KEY_DECLARE_WAR_NO") .. "[ENDCOLOR]";
	end


	Controls.VassalInfoIndependence:LocalizeAndSetText( strIndependencePossible );
	Controls.VassalInfoIndependence:SetToolTipString(strIndependenceTooltip);

	Controls.VassalPercentMasterCities:LocalizeAndSetText( iMasterCityPercent .. "%" );
	Controls.VassalPercentMasterCities:LocalizeAndSetToolTip( "TXT_KEY_GAIA_VASSALAGE_INDEPENDENCE_CITIES_VS_YOUR_TEAM_TT", pVassalTeam:GetNumCities(), g_pTeam:GetNumCities(), pVassalPlayer:GetNumCities() );
	Controls.VassalPercentMasterPop:LocalizeAndSetText( iMasterPopPercent .. "%" );
	Controls.VassalPercentMasterPop:LocalizeAndSetToolTip( "TXT_KEY_GAIA_VASSALAGE_INDEPENDENCE_POPULATION_VS_YOUR_TEAM_TT", pVassalTeam:GetTotalPopulation(), g_pTeam:GetTotalPopulation(), pVassalPlayer:GetTotalPopulation() );

	Controls.VassalInfoCityPercent:LocalizeAndSetText( iCityPercent  .. "%");
	Controls.VassalInfoCityPercent:LocalizeAndSetToolTip("TXT_KEY_GAIA_VASSALAGE_INDEPENDENCE_CITIES_VS_START_TT", pVassalTeam:GetNumCities(), pVassalTeam:_GetNumCitiesWhenVassalMade(), pVassalPlayer:GetNumCities());
	Controls.VassalInfoPopPercent:LocalizeAndSetText( iPopPercent  .. "%");
	Controls.VassalInfoPopPercent:LocalizeAndSetToolTip("TXT_KEY_GAIA_VASSALAGE_INDEPENDENCE_POPULATION_VS_START_TT", pVassalTeam:GetTotalPopulation(), pVassalTeam:_GetTotalPopulationWhenVassalMade(), pVassalPlayer:GetTotalPopulation());

	local strType, strTypeTooltip;
	if( pVassalTeam:_IsVoluntaryVassal( g_iTeam ) ) then
		strType = Locale.ConvertTextKey( "TXT_KEY_GAIA_VASSALAGE_TYPE_VOLUNTARY_LABEL" );
		strTypeTooltip = Locale.ConvertTextKey( "TXT_KEY_GAIA_VASSALAGE_TYPE_VOLUNTARY_SEEN_BY_MASTER_TT" );
	else
		strType = Locale.ConvertTextKey( "TXT_KEY_GAIA_VASSALAGE_TYPE_CAPITULATED_LABEL" );
		strTypeTooltip = Locale.ConvertTextKey( "TXT_KEY_GAIA_VASSALAGE_TYPE_CAPITULATED_SEEN_BY_MASTER_TT" );
	end

	Controls.VassalInfoType:LocalizeAndSetText(strType);
	Controls.VassalInfoType:LocalizeAndSetToolTip(strTypeTooltip);

	Controls.TaxSlider:SetValue( SliderToTaxPercent( g_pTeam:_GetVassalTax( ePlayer ) ) );
	
	local iNumTurnsForTax = Game._GetMinimumVassalTaxTurns();
	local iNumTurnsSinceSet = g_pTeam:_GetNumTurnsSinceVassalTaxSet( ePlayer );
	local iNumTurnsLeft = iNumTurnsForTax - iNumTurnsSinceSet;

	if( not g_pTeam:_CanSetVassalTax( ePlayer ) ) then
		Controls.TaxSlider:SetDisabled( true );
		Controls.TaxSliderValueToolTip:LocalizeAndSetToolTip( "TXT_KEY_GAIA_VASSALAGE_TAX_CHANGE_COOLDOWN_TT", iNumTurnsForTax, iNumTurnsLeft );
	else
		Controls.TaxSlider:SetDisabled( false );
		Controls.TaxSliderValueToolTip:SetToolTipString( "" );
	end
	
	local iTurnTaxesSet = Game.GetGameTurn() - iNumTurnsSinceSet;
	local iTurnTaxesAvailable = Game.GetGameTurn() + iNumTurnsLeft;
	local availableStr = "";
	local taxesSetTurnStr = "";
	if ( iNumTurnsLeft <= 0 or iNumTurnsSinceSet == -1 ) then
		availableStr = Locale.ConvertTextKey("TXT_KEY_GAIA_VASSALAGE_TAX_ADJUSTABLE_NOW_SEEN_BY_MASTER");
	else
		availableStr = Locale.ConvertTextKey("TXT_KEY_GAIA_VASSALAGE_TAX_NEXT_CHANGE_TURN", iTurnTaxesAvailable);
	end

	if ( g_pTeam:_GetNumTurnsSinceVassalTaxSet( ePlayer ) == -1 ) then	
		taxesSetTurnStr = Locale.ConvertTextKey("TXT_KEY_GAIA_VASSALAGE_TAX_NEVER_SET_SEEN_BY_MASTER");
	else
		taxesSetTurnStr = Locale.ConvertTextKey("TXT_KEY_GAIA_VASSALAGE_TAX_LAST_CHANGE_TURN", iTurnTaxesSet);
	end

	Controls.TaxesCurrentGPT:LocalizeAndSetText("TXT_KEY_GAIA_VASSALAGE_TAX_INCOME_SEEN_BY_MASTER", g_pPlayer:_GetVassalTaxContribution(ePlayer));
	Controls.TaxesCurrentGPT:LocalizeAndSetToolTip("TXT_KEY_GAIA_VASSALAGE_TAX_INCOME_SEEN_BY_MASTER_TT", g_pPlayer:_GetVassalTaxContribution(ePlayer), g_pTeam:_GetVassalTax( ePlayer), pVassalPlayer:CalculateGrossGold());

	Controls.TaxesTurnSet:SetText(taxesSetTurnStr);
	Controls.TaxesAvailableTurn:SetText(availableStr);
	Controls.TaxSliderValue:LocalizeAndSetText("TXT_KEY_GAIA_VASSALAGE_TAX_RATE_LABEL", g_pTeam:_GetVassalTax( ePlayer ) );

	RefreshVassalStats( ePlayer );
	RefreshTreatment( ePlayer );

	Controls.ApplyChanges:SetDisabled( true );
	Controls.ApplyChanges:SetVoid1( ePlayer );
	Controls.ApplyChanges:RegisterCallback( Mouse.eLClick, OnApplyTaxChanges );
	Controls.ApplyChanges:LocalizeAndSetToolTip( "TXT_KEY_GAIA_VASSAL_OVERVIEW_CONFIRM_TAX_BUTTON_TT" );

	-- Liberate Vassal button
	local tooltipStr = Locale.ConvertTextKey("TXT_KEY_GAIA_VASSALAGE_GRANT_INDEPENDENCE_TT", pVassalTeam:GetName());
	if( not g_pTeam:_CanLiberateVassal( iVassalTeam ) ) then
		Controls.LiberateCiv:SetDisabled( true );
		tooltipStr = tooltipStr .. "[NEWLINE][NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_GAIA_VASSALAGE_GRANT_INDEPENDENCE_TOO_SOON_TT", Game._GetMinimumVassalLiberateTurns(), Game._GetMinimumVassalLiberateTurns() - pVassalTeam:_GetNumTurnsIsVassal( g_iTeam ));
	else
		Controls.LiberateCiv:SetDisabled( false );
	end

	Controls.LiberateCiv:SetToolTipString( tooltipStr );
	Controls.LiberateCiv:SetVoid1( iVassalTeam );
	Controls.LiberateCiv:RegisterCallback( Mouse.eLClick, OnLiberateVassal );

	Controls.StatsScrollPanel:CalculateInternalSize();
	Controls.StatsScrollPanel:ReprocessAnchoring();

	Controls.ManagementScrollPanel:CalculateInternalSize();
	Controls.ManagementScrollPanel:ReprocessAnchoring();
end

-------------------------------------------------
-- Liberate Civ button clicked
-------------------------------------------------
function OnLiberateVassal( iVassalTeam )
	print( "Clicked on Liberate Civ: " .. iVassalTeam );

	Controls.ConfirmLabel:LocalizeAndSetText( "TXT_KEY_GAIA_VASSALAGE_GRANT_INDEPENDENCE_CONFIRM", Teams[ iVassalTeam ]:GetName() );
	Controls.Confirm:SetHide( false );
	Controls.BGBlock:SetHide( true );
	
	Controls.Yes:SetVoid1( 0 );
	Controls.Yes:SetVoid2( iVassalTeam );
	Controls.Yes:RegisterCallback( Mouse.eLClick, OnYes );
end

function OnApplyTaxChanges( iVassalPlayer )
	local iTaxValue = TaxPercentToSlider( Controls.TaxSlider:GetValue() );

	Controls.ConfirmLabel:LocalizeAndSetText( "TXT_KEY_GAIA_VASSALAGE_TAX_CHANGE_CONFIRM", iTaxValue, Teams[ Players[iVassalPlayer]:GetTeam() ]:GetName(), Game._GetMinimumVassalTaxTurns() );
	Controls.Confirm:SetHide( false );
	Controls.BGBlock:SetHide( true );
	
	Controls.Yes:SetVoid1( 1 );
	Controls.Yes:SetVoid2( iVassalPlayer );
	Controls.Yes:RegisterCallback( Mouse.eLClick, OnYes );
end

function OnRequestIndependence( iVassalPlayer )
	Controls.ConfirmLabel:LocalizeAndSetText( "TXT_KEY_GAIA_VASSALAGE_SEEK_INDEPENDENCE_CONFIRM", Teams[ Players[iVassalPlayer]:GetTeam() ]:GetName() );
	Controls.Confirm:SetHide( false );
	Controls.BGBlock:SetHide( true );
	
	Controls.Yes:SetVoid1( 2 );
	Controls.Yes:SetVoid2( iVassalPlayer );
	Controls.Yes:RegisterCallback( Mouse.eLClick, OnYes );
end

function RefreshTreatment( ePlayer )
	local pPlayer = Players[ ePlayer ];

	local vassalTreatmentLookup = {
		[0] = "TXT_KEY_GAIA_VASSALAGE_TREATMENT_LEVEL_SATISFIED",
		[1] = "TXT_KEY_GAIA_VASSALAGE_TREATMENT_LEVEL_UNEASY",
		[2] = "TXT_KEY_GAIA_VASSALAGE_TREATMENT_LEVEL_AGGRIEVED",
		[3] = "TXT_KEY_GAIA_VASSALAGE_TREATMENT_LEVEL_RESENTFUL",
		[4] = "TXT_KEY_GAIA_VASSALAGE_TREATMENT_LEVEL_OPPRESSED",
	};

	-- Vassal Treatment
    		
	Controls.VassalTreatment:LocalizeAndSetText( "TXT_KEY_GAIA_VASSALAGE_TREATMENT_OPINION_LABEL", vassalTreatmentLookup[pPlayer:_GetVassalTreatmentLevel( g_iPlayer )] );
	Controls.VassalTreatment:SetToolTipString( pPlayer:_GetVassalTreatmentToolTip( g_iPlayer ) );
end

function RefreshVassalStats( ePlayer )
	local pPlayer = Players[ ePlayer ];
	
	-- Population
	Controls.VassalStatsPopulation:SetText( pPlayer:GetTotalPopulation() );
	local iHappiness = pPlayer:GetExcessHappiness();
	local szHappinessLabel = "";
	if(iHappiness < 0) then
		szHappinessLabel = "[ICON_HAPPINESS_3] " .. Locale.ConvertTextKey("TXT_KEY_GAIA_VASSALAGE_STAT_HAPPINESS_LEVEL_LABEL");
	else
		szHappinessLabel = "[ICON_HAPPINESS_1] " .. Locale.ConvertTextKey("TXT_KEY_GAIA_VASSALAGE_STAT_HAPPINESS_LEVEL_LABEL");
	end
	Controls.VassalStatsHappyLabel:SetText( szHappinessLabel );
	Controls.VassalStatsHappy:SetText( iHappiness );
	
	-- Economic
	Controls.VassalStatsGross:SetText( pPlayer:CalculateGrossGold() );
	Controls.VassalStatsGold:SetText( pPlayer:CalculateGoldRate() );
	Controls.VassalStatsTradeRoutes:LocalizeAndSetText( "TXT_KEY_GAIA_VASSALAGE_STAT_TRADE_ROUTES_USED_OF_TOTAL", pPlayer:GetNumInternationalTradeRoutesUsed(), pPlayer:GetNumInternationalTradeRoutesAvailable() );

	-- Culture
	local ideologyStr = Locale.ConvertTextKey("TXT_KEY_GAIA_VASSALAGE_STAT_NO_IDEOLOGY");
	local eIdeology = pPlayer:GetLateGamePolicyTree();
	if( eIdeology ~= -1 ) then
		local pIdeology = GameInfo.PolicyBranchTypes[ eIdeology ];
		if( pIdeology ) then
			if( eIdeology == POLICY_BRANCH_ORDER ) then
				ideologyStr = "[ICON_IDEOLOGY_ORDER] ";
			elseif ( eIdeology == POLICY_BRANCH_FREEDOM ) then
				ideologyStr = "[ICON_IDEOLOGY_FREEDOM] ";
			else
				ideologyStr = "[ICON_IDEOLOGY_AUTOCRACY] ";
			end
			ideologyStr = Locale.ConvertTextKey( "TXT_KEY_GAIA_VASSALAGE_STAT_CURRENT_IDEOLOGY", pIdeology.Description );
		end
	end
	Controls.VassalStatsIdeology:LocalizeAndSetText( "TXT_KEY_GAIA_VASSALAGE_STAT_IDEOLOGY_PASSTHROUGH", ideologyStr );
	Controls.VassalStatsCulture:SetText( pPlayer:GetTotalJONSCulturePerTurn() );
	Controls.VassalStatsTourism:SetText( pPlayer:GetTourism() / 100);
	
	-- Religion
	local eMajorityReligion = pPlayer:_GetMajorityReligion();
	local szMajorityReligion = Locale.ConvertTextKey( "TXT_KEY_GAIA_VASSALAGE_STAT_NO_PREVAILING_RELIGION" );
	if(eMajorityReligion ~= -1) then
		local pReligionInfo = GameInfo.Religions[eMajorityReligion];
		szMajorityReligion = Locale.ConvertTextKey( "TXT_KEY_GAIA_VASSALAGE_STAT_PREVAILING_RELIGION", pReligionInfo.Description );
	end
	Controls.VassalStatsReligion:SetText( szMajorityReligion );
	Controls.VassalStatsFaith:LocalizeAndSetText( pPlayer:GetTotalFaithPerTurn() );

	-- Science
	Controls.VassalStatsScience:SetText( pPlayer:GetScience() );
	RefreshVassalTechs( ePlayer );
end

-------------------------------------------------
-- Vassal Tech Button
-------------------------------------------------
function RefreshVassalTechs( iVassalPlayer )
	local pPlayer = Players[ iVassalPlayer ];
	local pTeam = Teams[pPlayer:GetTeam()];
	local pTeamTechs = pTeam:GetTeamTechs();
	
	eCurrentTech = pPlayer:GetCurrentResearch();
	eRecentTech = pTeamTechs:GetLastTechAcquired();
	
	local fResearchProgressPercent = 0;
	local fResearchProgressPlusThisTurnPercent = 0;
	
	local researchStatus = "";
	local szText = "";
	
	if (eCurrentTech ~= -1) then
		
		local iResearchTurnsLeft = pPlayer:GetResearchTurnsLeft(eCurrentTech, true);
		local iCurrentResearchProgress = pPlayer:GetResearchProgress(eCurrentTech);
		local iResearchNeeded = pPlayer:GetResearchCost(eCurrentTech);
		local iResearchPerTurn = pPlayer:GetScience();
		local iCurrentResearchPlusThisTurn = iCurrentResearchProgress + iResearchPerTurn;
		
		fResearchProgressPercent = iCurrentResearchProgress / iResearchNeeded;
		fResearchProgressPlusThisTurnPercent = iCurrentResearchPlusThisTurn / iResearchNeeded;
		
		if (fResearchProgressPlusThisTurnPercent > 1) then
			fResearchProgressPlusThisTurnPercent = 1
		end
				
		local pTechInfo = GameInfo.Technologies[eCurrentTech];
		if pTechInfo then
			szText = Locale.ConvertTextKey( pTechInfo.Description );
			if iResearchPerTurn > 0 then
				szText = szText .. " (" .. tostring(iResearchTurnsLeft) .. ")";
			end		
			local customHelpString = GetHelpTextForTech(eCurrentTech);
			Controls.TechBox:SetToolTipString( customHelpString );
			Controls.TechLabel:SetText( szText );

			if IconHookup( pTechInfo.PortraitIndex, 64, pTechInfo.IconAtlas, Controls.TechIcon ) then
				Controls.TechIcon:SetHide( false );
			else
				Controls.TechIcon:SetHide( true );
			end			
		end
	elseif (eRecentTech ~= -1) then
		local pTechInfo = GameInfo.Technologies[eRecentTech];
		if pTechInfo then
			szText = Locale.ConvertTextKey( pTechInfo.Description );
			Controls.TechLabel:SetText( szText );

			if IconHookup( pTechInfo.PortraitIndex, 64, pTechInfo.IconAtlas, Controls.TechIcon ) then
				Controls.TechIcon:SetHide( false );
			else
				Controls.TechIcon:SetHide( true );
			end			
		end
		researchStatus = Locale.ConvertTextKey("TXT_KEY_RESEARCH_FINISHED");
		Controls.TechBox:SetToolTipString( helpTT );
	else
		researchStatus = Locale.ConvertTextKey("TXT_KEY_NOTIFICATION_SUMMARY_NEW_RESEARCH");
		Controls.TechBox:SetToolTipString( helpTT );
	end
	
	-- Research Meter
  	local research = pPlayer:GetCurrentResearch();
  	if( research ~= -1 ) then
    	Controls.ResearchMeter:SetPercents( fResearchProgressPercent, fResearchProgressPlusThisTurnPercent );
	else
    	Controls.ResearchMeter:SetPercents( 1, 0 );
	end
end

-------------------------------------------------
-- Tax Slider
-------------------------------------------------
function OnTaxSliderMoved( fValue )

	local iTaxValue = TaxPercentToSlider( fValue );
	Controls.TaxSliderValue:SetText( Locale.ConvertTextKey("TXT_KEY_GAIA_VASSALAGE_TAX_RATE_LABEL", iTaxValue) );

	RefreshApplyButton();
end
Controls.TaxSlider:RegisterSliderCallback( OnTaxSliderMoved );

function RefreshApplyButton()
	Controls.ApplyChanges:SetDisabled( TaxPercentToSlider( Controls.TaxSlider:GetValue() ) == g_pTeam:_GetVassalTax(g_SelectedVassal) );
end

function TaxPercentToSlider( fPercent )
	local iMin = Game._GetMinimumVassalTax();
	local iMax = Game._GetMaximumVassalTax();

	local iStepIncrease = 5;
	local iStepsNeeded = (iMax / iStepIncrease);
	
	fPercent = math.floor( fPercent * iStepsNeeded ) * (1 / iStepsNeeded);
	return fPercent * (iMax - iMin);
end

function SliderToTaxPercent( iTaxValue )
	local iMin = Game._GetMinimumVassalTax();
	local iMax = Game._GetMaximumVassalTax();
	return math.min(math.max((iTaxValue) / (iMax - iMin), 0), 1);
end

-- Statistics for human vassal
function RefreshMasterStats( ePlayer )
	local pMasterPlayer = Players[ePlayer];
	local iMasterTeam = pMasterPlayer:GetTeam();
	local pMasterTeam = Teams[iMasterTeam];

	-- Population
	local iYourPopulation = g_pPlayer:GetTotalPopulation();
	local iYourPopulationTeam = g_pTeam:GetTotalPopulation();
	local iTheirPopulation = pMasterPlayer:GetTotalPopulation();
	local iTheirPopulationTeam = pMasterTeam:GetTotalPopulation();
	
	Controls.MasterStatsYourPopulation:LocalizeAndSetText( "TXT_KEY_GAIA_VASSALAGE_COMPARE_MASTER_VALUE_LEADER_AND_TEAM", iYourPopulation, iYourPopulationTeam );
	Controls.MasterStatsYourPopulation:LocalizeAndSetToolTip( "TXT_KEY_GAIA_VASSALAGE_COMPARE_MASTER_YOUR_POPULATION_TT" );
	Controls.MasterStatsTheirPopulation:LocalizeAndSetText( "TXT_KEY_GAIA_VASSALAGE_COMPARE_MASTER_VALUE_LEADER_AND_TEAM", iTheirPopulation, iTheirPopulationTeam );
	Controls.MasterStatsTheirPopulation:LocalizeAndSetToolTip( "TXT_KEY_GAIA_VASSALAGE_COMPARE_MASTER_MASTER_POPULATION_TT" );
	
	local iPopPercent = 0;
	if( iTheirPopulation ~= 0 ) then
		iPopPercent = math.floor(iYourPopulation * 100 / iTheirPopulation);
	end

	local iPopTeamPercent = 0;
	if( iTheirPopulationTeam ~= 0 ) then
		iPopTeamPercent = math.floor(iYourPopulationTeam * 100 / iTheirPopulationTeam);
	end
	Controls.MasterStatsPopulationPercent:LocalizeAndSetText( "TXT_KEY_GAIA_VASSALAGE_COMPARE_MASTER_VALUE_LEADER_AND_TEAM_PERCENT", iPopPercent, iPopTeamPercent );
	Controls.MasterStatsPopulationPercent:LocalizeAndSetToolTip( "TXT_KEY_GAIA_VASSALAGE_COMPARE_MASTER_POPULATION_RATIO_TT", pMasterPlayer:GetName() );

	local iYourPopWhenVassalStarted = g_pTeam:_GetTotalPopulationWhenVassalMade();
	local iPopFromStartPercent = 0;
	if( iYourPopWhenVassalStarted ~= 0 ) then
		iPopFromStartPercent = math.floor( iYourPopulationTeam * 100 / iYourPopWhenVassalStarted );
	end
	Controls.MasterStatsPopStartedPercent:LocalizeAndSetText( "TXT_KEY_GAIA_VASSALAGE_COMPARE_MASTER_VALUE_TEAM_PERCENT", iPopFromStartPercent);
	Controls.MasterStatsPopStartedPercent:LocalizeAndSetToolTip( "TXT_KEY_GAIA_VASSALAGE_COMPARE_MASTER_POPULATION_SINCE_START_TT", pMasterTeam:GetName() );

	-- Cities
	local iYourCities = g_pPlayer:GetNumCities();
	local iYourCitiesTeam = g_pTeam:GetNumCities();
	local iTheirCities = pMasterPlayer:GetNumCities();
	local iTheirCitiesTeam = pMasterTeam:GetNumCities();
	
	Controls.MasterStatsYourCities:LocalizeAndSetText( "TXT_KEY_GAIA_VASSALAGE_COMPARE_MASTER_VALUE_LEADER_AND_TEAM", iYourCities, iYourCitiesTeam  );
	Controls.MasterStatsYourCities:LocalizeAndSetToolTip( "TXT_KEY_GAIA_VASSALAGE_COMPARE_MASTER_YOUR_CITIES_TT"  );
	Controls.MasterStatsTheirCities:LocalizeAndSetText( "TXT_KEY_GAIA_VASSALAGE_COMPARE_MASTER_VALUE_LEADER_AND_TEAM", iTheirCities, iTheirCitiesTeam );
	Controls.MasterStatsTheirCities:LocalizeAndSetToolTip( "TXT_KEY_GAIA_VASSALAGE_COMPARE_MASTER_MASTER_CITIES_TT" );
	
	local iCityPercent = 0;
	if( iTheirCities ~= 0 ) then
		iCityPercent = math.floor(iYourCities * 100 / iTheirCities);
	end

	local iCityTeamPercent = 0;
	if( iTheirCitiesTeam ~= 0 ) then
		iCityTeamPercent = math.floor(iYourCitiesTeam * 100 / iTheirCitiesTeam);
	end
	Controls.MasterStatsCitiesPercent:LocalizeAndSetText( "TXT_KEY_GAIA_VASSALAGE_COMPARE_MASTER_VALUE_LEADER_AND_TEAM_PERCENT", iCityPercent, iCityTeamPercent );
	Controls.MasterStatsCitiesPercent:LocalizeAndSetToolTip( "TXT_KEY_GAIA_VASSALAGE_COMPARE_MASTER_CITY_RATIO_TT", pMasterPlayer:GetName() );
	
	local iYourCitiesWhenVassalStarted = g_pTeam:_GetNumCitiesWhenVassalMade();
	local iCityFromStartPercent = 0;
	if( iYourCitiesWhenVassalStarted ~= 0 ) then
		iCityFromStartPercent = math.floor( iYourCitiesTeam * 100 / iYourCitiesWhenVassalStarted );
	end
	Controls.MasterStatsCitiesStartedPercent:LocalizeAndSetText( "TXT_KEY_GAIA_VASSALAGE_COMPARE_MASTER_VALUE_TEAM_PERCENT",  iCityFromStartPercent);
	Controls.MasterStatsCitiesStartedPercent:LocalizeAndSetToolTip( "TXT_KEY_GAIA_VASSALAGE_COMPARE_MASTER_CITIES_SINCE_START_TT", pMasterTeam:GetName());

end

function RefreshMasterTaxes( ePlayer )
	local pMasterPlayer = Players[ePlayer];
	local iMasterTeam = pMasterPlayer:GetTeam();
	local pMasterTeam = Teams[iMasterTeam];

	local iNumTurnsForTax = Game._GetMinimumVassalTaxTurns();
	local iNumTurnsSinceSet = pMasterTeam:_GetNumTurnsSinceVassalTaxSet( g_iPlayer );
	local iNumTurnsLeft = iNumTurnsForTax - iNumTurnsSinceSet;
	
	local iTurnTaxesSet = Game.GetGameTurn() - iNumTurnsSinceSet;
	local iTurnTaxesAvailable = Game.GetGameTurn() + iNumTurnsLeft;
	local availableStr = "";
	local taxesSetTurnStr = "";
	if ( iNumTurnsLeft <= 0 or iNumTurnsSinceSet == -1 ) then
		availableStr = Locale.ConvertTextKey("TXT_KEY_GAIA_VASSALAGE_TAX_ADJUSTABLE_NOW_SEEN_BY_VASSAL");
	else
		availableStr = Locale.ConvertTextKey("TXT_KEY_GAIA_VASSALAGE_TAX_NEXT_CHANGE_TURN", iTurnTaxesAvailable);
	end
	
	if ( iNumTurnsSinceSet == -1 ) then	
		taxesSetTurnStr = Locale.ConvertTextKey("TXT_KEY_GAIA_VASSALAGE_TAX_NEVER_SET_SEEN_BY_VASSAL");
	else
		taxesSetTurnStr = Locale.ConvertTextKey("TXT_KEY_GAIA_VASSALAGE_TAX_LAST_CHANGE_TURN", iTurnTaxesSet);
	end

	local iTaxRate = pMasterTeam:_GetVassalTax( g_iPlayer );
	
	Controls.LabelMasterTaxRate:LocalizeAndSetText("TXT_KEY_GAIA_VASSALAGE_TAX_RATE_LABEL", iTaxRate );
	Controls.LabelMasterTaxRate:LocalizeAndSetToolTip("TXT_KEY_GAIA_VASSALAGE_TAX_RATE_SEEN_BY_VASSAL_TT", iTaxRate, pMasterTeam:GetName() );
	
	Controls.MasterTaxSlider:SetDisabled(false);
	Controls.MasterTaxSlider:SetValue( SliderToTaxPercent( pMasterTeam:_GetVassalTax( g_iPlayer ) ) );
	Controls.MasterTaxSlider:SetDisabled(true);
	
	Controls.MasterTaxesTurnSet:LocalizeAndSetText( taxesSetTurnStr );
	Controls.MasterAvailableTurn:LocalizeAndSetText( availableStr );
	Controls.MasterTaxesCurrentGPT:LocalizeAndSetText( "TXT_KEY_GAIA_VASSALAGE_TAX_PAYMENT_SEEN_BY_VASSAL", g_pPlayer:_GetExpensePerTurnFromVassalTaxes());
	Controls.MasterTaxesCurrentGPT:LocalizeAndSetToolTip( "TXT_KEY_GAIA_VASSALAGE_TAX_PAYMENT_SEEN_BY_VASSAL_TT", g_pPlayer:_GetExpensePerTurnFromVassalTaxes(), iTaxRate, g_pPlayer:CalculateGrossGold() );
end

-------------------------------------------------
-- On Popup
-------------------------------------------------
function OnPopup( popupInfo )
	if( popupInfo.Type == ButtonPopupTypes.BUTTONPOPUP_GAIA_VASSALAGE_OVERVIEW ) then
    	m_PopupInfo = popupInfo;
    	
		if isVassalageEnabled then

			if( m_PopupInfo.Data1 == 1 ) then
        		if( ContextPtr:IsHidden() == false ) then
        			OnClose();
				else
            		UIManager:QueuePopup( ContextPtr, PopupPriority.InGameUtmost );
        		end
    		else
        		UIManager:QueuePopup( ContextPtr, PopupPriority.LoadGameScreen );
    		end

		end
	end
end
Events.SerialEventGameMessagePopup.Add( OnPopup );

function OnClose()
    UIManager:DequeuePopup( ContextPtr );
end
Controls.CloseButton:RegisterCallback( Mouse.eLClick, OnClose);

function OnYes( type, iValue )
	Controls.Confirm:SetHide(true);
	Controls.BGBlock:SetHide(false);
	
	-- Liberation
	if( type == 0 ) then
		Game.DoFromUIDiploEvent( FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_HUMAN_LIBERATES_VASSAL, Teams[iValue]:GetLeaderID(), iValue, 0 );
		OnClose();
	-- Apply Tax Change
	elseif ( type == 1 ) then
		local iTaxRate = TaxPercentToSlider( Controls.TaxSlider:GetValue() );
		Game.DoFromUIDiploEvent( FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_HUMAN_APPLIES_VASSAL_TAX, iValue, iTaxRate, 0 );
		OnVassalPicked( iValue );
		RefreshApplyButton();
	-- Request Independence
	elseif ( type == 2 ) then
		Game.DoFromUIDiploEvent( FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_HUMAN_ENDS_VASSALAGE, iValue, 2, 0 );
		OnClose();
	end
end

function OnNo( )
	Controls.Confirm:SetHide(true);
	Controls.BGBlock:SetHide(false);
end
Controls.No:RegisterCallback( Mouse.eLClick, OnNo );

function InputHandler( uiMsg, wParam, lParam )
    if uiMsg == KeyEvents.KeyDown then
        if wParam == Keys.VK_ESCAPE or wParam == Keys.VK_RETURN then
			if(Controls.Confirm:IsHidden()) then
				OnClose();
			else
				Controls.Confirm:SetHide(true);
				Controls.BGBlock:SetHide(false);
			end
            return true;
        end
    end
end
ContextPtr:SetInputHandler( InputHandler );

function ShowHideHandler( bIsHide, bInitState )

	CivIconHookup( Game.GetActivePlayer(), 64, Controls.Icon, Controls.CivIconBG, Controls.CivIconShadow, false, true );
   
    if( not bInitState ) then
        if( not bIsHide ) then
        	UI.incTurnTimerSemaphore();
        	Events.SerialEventGameMessagePopupShown(m_PopupInfo);
			Update();
        else
            UI.decTurnTimerSemaphore();
            Events.SerialEventGameMessagePopupProcessed.CallImmediate(ButtonPopupTypes.BUTTONPOPUP_GAIA_VASSALAGE_OVERVIEW, 0);
			ClearVassalDetails();
        end
    end
end
ContextPtr:SetShowHideHandler( ShowHideHandler );

local strBenefits = "";
strBenefits = strBenefits .. "[NEWLINE]" .. Locale.ConvertTextKey( "TXT_KEY_GAIA_VASSALAGE_MASTER_BENEFIT_OPEN_BORDERS_INTO_VASSALS" );
strBenefits = strBenefits .. "[NEWLINE]" .. Locale.ConvertTextKey( "TXT_KEY_GAIA_VASSALAGE_MASTER_BENEFIT_SHARE_OF_VASSAL_YIELDS" );
strBenefits = strBenefits .. "[NEWLINE]" .. Locale.ConvertTextKey( "TXT_KEY_GAIA_VASSALAGE_MASTER_BENEFIT_DOUBLE_RELIGIOUS_PRESSURE" );
strBenefits = strBenefits .. "[NEWLINE]" .. Locale.ConvertTextKey( "TXT_KEY_GAIA_VASSALAGE_MASTER_BENEFIT_TOURISM_BONUS" );
strBenefits = strBenefits .. "[NEWLINE]" .. Locale.ConvertTextKey( "TXT_KEY_GAIA_VASSALAGE_MASTER_BENEFIT_DIPLOMAT_IN_VASSAL_CAPITAL" );
strBenefits = strBenefits .. "[NEWLINE]" .. Locale.ConvertTextKey( "TXT_KEY_GAIA_VASSALAGE_MASTER_BENEFIT_BUY_VASSAL_UNIQUE_UNITS" );
strBenefits = strBenefits .. "[NEWLINE]" .. Locale.ConvertTextKey( "TXT_KEY_GAIA_VASSALAGE_MASTER_BENEFIT_AI_VASSALS_ADOPT_IDEOLOGY" );
Controls.VassalBenefits:SetText(strBenefits);

LuaEvents.RequestRefreshAdditionalInformationDropdownEntries();

ContextPtr:SetHide(true);