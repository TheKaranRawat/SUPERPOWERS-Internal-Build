include( "IconSupport" );
include( "GameplayUtilities" );
include( "InfoTooltipInclude" );

local g_iAIPlayer = -1;
local g_iAITeam = -1;

local g_DiploUIState = -1;

local g_iRootMode = 0;
local g_iTradeMode = 1;
local g_iDiscussionMode = 2;

local g_strLeaveScreenText = Locale.ConvertTextKey("TXT_KEY_DIPLOMACY_ANYTHING_ELSE");

local offsetOfString = 32;
local bonusPadding = 16
local innerFrameWidth = 654;
local outerFrameWidth = 650;
local offsetsBetweenFrames = 4;

----------------------------------------------------------------        
-- LEADER MESSAGE HANDLER
----------------------------------------------------------------        
function LeaderMessageHandler( iPlayer, iDiploUIState, szLeaderMessage, iAnimationAction, iData1 )
	
	g_DiploUIState = iDiploUIState;
	
	g_iAIPlayer = iPlayer;
	g_iAITeam = Players[g_iAIPlayer]:GetTeam();
	
	local pActivePlayer = Players[Game.GetActivePlayer()];
	local pActiveTeam = Teams[pActivePlayer:GetTeam()];
	
	CivIconHookup( iPlayer, 64, Controls.ThemSymbolShadow, Controls.CivIconBG, Controls.CivIconShadow, false, true );
		
	local player = Players[iPlayer];
	local strTitleText = GameplayUtilities.GetLocalizedLeaderTitle(player);
	Controls.TitleText:SetText(strTitleText);
	
	playerLeaderInfo = GameInfo.Leaders[player:GetLeaderType()];
	
	-- Mood
	local iApproach = pActivePlayer:GetApproachTowardsUsGuess(g_iAIPlayer);
	local strMoodText = Locale.ConvertTextKey("TXT_KEY_EMOTIONLESS");

	if (Players[g_iAIPlayer]:IsAlive()) then
		if (not pActivePlayer:IsAlive()) then
			strMoodText = Locale.ConvertTextKey( "TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_NEUTRAL", playerLeaderInfo.Description );
		else
			if (pActiveTeam:IsAtWar(g_iAITeam) and pActivePlayer._GetWarScore ~= nil) then
				strMoodText = Locale.ConvertTextKey( "TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_WAR" );
			elseif (Players[g_iAIPlayer]:IsDenouncingPlayer(Game.GetActivePlayer())) then
				strMoodText = Locale.ConvertTextKey( "TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_DENOUNCING" );	
			elseif (Players[g_iAIPlayer]:WasResurrectedThisTurnBy(Game.GetActivePlayer())) then
				strMoodText = Locale.ConvertTextKey( "TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_LIBERATED" );		
			else
				if( iApproach == MajorCivApproachTypes.MAJOR_CIV_APPROACH_WAR ) then
					strMoodText = Locale.ConvertTextKey( "TXT_KEY_WAR_CAPS" );
				elseif( iApproach == MajorCivApproachTypes.MAJOR_CIV_APPROACH_HOSTILE ) then
					strMoodText = Locale.ConvertTextKey( "TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_HOSTILE", playerLeaderInfo.Description  );
				elseif( iApproach == MajorCivApproachTypes.MAJOR_CIV_APPROACH_GUARDED ) then
					strMoodText = Locale.ConvertTextKey( "TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_GUARDED", playerLeaderInfo.Description  );
				elseif( iApproach == MajorCivApproachTypes.MAJOR_CIV_APPROACH_AFRAID ) then
					strMoodText = Locale.ConvertTextKey( "TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_AFRAID", playerLeaderInfo.Description  );
				elseif( iApproach == MajorCivApproachTypes.MAJOR_CIV_APPROACH_FRIENDLY ) then
					strMoodText = Locale.ConvertTextKey( "TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_FRIENDLY", playerLeaderInfo.Description  );
				else
					strMoodText = Locale.ConvertTextKey( "TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_NEUTRAL", playerLeaderInfo.Description );
				end
			end
		end
	end
	
	Controls.MoodText:SetText(strMoodText);
	
	local strMoodInfo = GetMoodInfo(g_iAIPlayer);
	Controls.MoodText:SetToolTipString(strMoodInfo);
	
	-- War score
	if (pActiveTeam:IsAtWar(g_iAITeam) and pActivePlayer._GetWarScore ~= nil) then
		Controls.WarScore:SetHide(false);
		local iWarScore = pActivePlayer:_GetWarScore(g_iAIPlayer);
		local strWarScore = Locale.ConvertTextKey("TXT_KEY_GAIA_WAR_PANEL_PROJECTION_VALUE", iWarScore);

		Controls.WarScore:SetText(strWarScore);
	
		local strWarInfo = Locale.ConvertTextKey("TXT_KEY_GAIA_WAR_PANEL_PROJECTION_TT");

		if(Players[g_iAIPlayer]:_IsWantsPeaceWithPlayer(Game.GetActivePlayer())) then
			local iPeaceValue = Players[g_iAIPlayer]:_GetTreatyWillingToOffer(Game.GetActivePlayer());
			if(iPeaceValue >  PeaceTreatyTypes.PEACE_TREATY_WHITE_PEACE) then
				if( iPeaceValue == PeaceTreatyTypes.PEACE_TREATY_ARMISTICE ) then
					strWarInfo = strWarInfo .. '[NEWLINE]' .. Locale.ConvertTextKey( "TXT_KEY_GAIA_WAR_PANEL_PEACE_TIER_ARMISTICE" );
				elseif( iPeaceValue == PeaceTreatyTypes.PEACE_TREATY_SETTLEMENT ) then
					strWarInfo = strWarInfo .. '[NEWLINE]' .. Locale.ConvertTextKey( "TXT_KEY_GAIA_WAR_PANEL_PEACE_TIER_SETTLEMENT" );
				elseif( iPeaceValue == PeaceTreatyTypes.PEACE_TREATY_BACKDOWN ) then
					strWarInfo = strWarInfo .. '[NEWLINE]' .. Locale.ConvertTextKey( "TXT_KEY_GAIA_WAR_PANEL_PEACE_TIER_BACKDOWN" );
				elseif( iPeaceValue == PeaceTreatyTypes.PEACE_TREATY_SUBMISSION ) then
					strWarInfo = strWarInfo .. '[NEWLINE]' .. Locale.ConvertTextKey( "TXT_KEY_GAIA_WAR_PANEL_PEACE_TIER_SUBMISSION" );
				elseif( iPeaceValue == PeaceTreatyTypes.PEACE_TREATY_SURRENDER ) then
					strWarInfo = strWarInfo .. '[NEWLINE]' .. Locale.ConvertTextKey( "TXT_KEY_GAIA_WAR_PANEL_PEACE_TIER_SURRENDER" );
				elseif( iPeaceValue == PeaceTreatyTypes.PEACE_TREATY_CESSION ) then
					strWarInfo = strWarInfo .. '[NEWLINE]' .. Locale.ConvertTextKey( "TXT_KEY_GAIA_WAR_PANEL_PEACE_TIER_CESSION" );
				elseif( iPeaceValue == PeaceTreatyTypes.PEACE_TREATY_CAPITULATION ) then
					strWarInfo = strWarInfo .. '[NEWLINE]' .. Locale.ConvertTextKey( "TXT_KEY_GAIA_WAR_PANEL_PEACE_TIER_CAPITULATION" );
				elseif( iPeaceValue == PeaceTreatyTypes.PEACE_TREATY_UNCONDITIONAL_SURRENDER ) then
					strWarInfo = strWarInfo .. '[NEWLINE]' .. Locale.ConvertTextKey( "TXT_KEY_GAIA_WAR_PANEL_PEACE_TIER_UNCONDITIONAL" );
				end
			end
		else
			strWarInfo = strWarInfo .. '[NEWLINE]' .. Locale.ConvertTextKey( "TXT_KEY_GAIA_WAR_PANEL_PEACE_TIER_NONE" );
		end

		local iStrengthAverage = pActivePlayer:_GetMilitaryStrengthComparedToUs(g_iAIPlayer);
		if( iStrengthAverage == StrengthTypes.STRENGTH_PATHETIC ) then
			strWarInfo = strWarInfo .. '[NEWLINE]' .. Locale.ConvertTextKey( "TXT_KEY_GAIA_WAR_PANEL_MILITARY_PATHETIC" );
		elseif( iStrengthAverage == StrengthTypes.STRENGTH_WEAK ) then
			strWarInfo = strWarInfo .. '[NEWLINE]' .. Locale.ConvertTextKey( "TXT_KEY_GAIA_WAR_PANEL_MILITARY_WEAK" );
		elseif( iStrengthAverage == StrengthTypes.STRENGTH_POOR ) then
			strWarInfo = strWarInfo .. '[NEWLINE]' .. Locale.ConvertTextKey( "TXT_KEY_GAIA_WAR_PANEL_MILITARY_POOR" );
		elseif( iStrengthAverage == StrengthTypes.STRENGTH_AVERAGE ) then
			strWarInfo = strWarInfo .. '[NEWLINE]' .. Locale.ConvertTextKey( "TXT_KEY_GAIA_WAR_PANEL_MILITARY_AVERAGE" );
		elseif( iStrengthAverage == StrengthTypes.STRENGTH_STRONG ) then
			strWarInfo = strWarInfo .. '[NEWLINE]' .. Locale.ConvertTextKey( "TXT_KEY_GAIA_WAR_PANEL_MILITARY_STRONG" );
		elseif( iStrengthAverage == StrengthTypes.STRENGTH_POWERFUL ) then
			strWarInfo = strWarInfo .. '[NEWLINE]' .. Locale.ConvertTextKey( "TXT_KEY_GAIA_WAR_PANEL_MILITARY_POWERFUL" );
		elseif( iStrengthAverage == StrengthTypes.STRENGTH_IMMENSE ) then
			strWarInfo = strWarInfo .. '[NEWLINE]' .. Locale.ConvertTextKey( "TXT_KEY_GAIA_WAR_PANEL_MILITARY_IMMENSE" );
		end

		local iEconomicAverage = pActivePlayer:_GetEconomicStrengthComparedToUs(g_iAIPlayer);
		if( iEconomicAverage == StrengthTypes.STRENGTH_PATHETIC ) then
			strWarInfo = strWarInfo .. '[NEWLINE]' .. Locale.ConvertTextKey( "TXT_KEY_GAIA_WAR_PANEL_ECONOMY_PATHETIC" );
		elseif( iEconomicAverage == StrengthTypes.STRENGTH_WEAK ) then
			strWarInfo = strWarInfo .. '[NEWLINE]' .. Locale.ConvertTextKey( "TXT_KEY_GAIA_WAR_PANEL_ECONOMY_WEAK" );
		elseif( iEconomicAverage == StrengthTypes.STRENGTH_POOR ) then
			strWarInfo = strWarInfo .. '[NEWLINE]' .. Locale.ConvertTextKey( "TXT_KEY_GAIA_WAR_PANEL_ECONOMY_POOR" );
		elseif( iEconomicAverage == StrengthTypes.STRENGTH_AVERAGE ) then
			strWarInfo = strWarInfo .. '[NEWLINE]' .. Locale.ConvertTextKey( "TXT_KEY_GAIA_WAR_PANEL_ECONOMY_AVERAGE" );
		elseif( iEconomicAverage == StrengthTypes.STRENGTH_STRONG ) then
			strWarInfo = strWarInfo .. '[NEWLINE]' .. Locale.ConvertTextKey( "TXT_KEY_GAIA_WAR_PANEL_ECONOMY_STRONG" );
		elseif( iEconomicAverage == StrengthTypes.STRENGTH_POWERFUL ) then
			strWarInfo = strWarInfo .. '[NEWLINE]' .. Locale.ConvertTextKey( "TXT_KEY_GAIA_WAR_PANEL_ECONOMY_POWERFUL" );
		elseif( iEconomicAverage == StrengthTypes.STRENGTH_IMMENSE ) then
			strWarInfo = strWarInfo .. '[NEWLINE]' .. Locale.ConvertTextKey( "TXT_KEY_GAIA_WAR_PANEL_ECONOMY_IMMENSE" );
		end

		local iOurWarDamage = pActivePlayer:_GetWarDamageValue(g_iAIPlayer);
		local iTheirWarDamage = Players[g_iAIPlayer]:_GetWarDamageValue(Game.GetActivePlayer());
		local iTotal = iTheirWarDamage - iOurWarDamage;

		if (iTotal > 0) then
			if (iTotal >= GameDefines.WAR_DAMAGE_LEVEL_THRESHOLD_CRIPPLED) then
				strWarInfo = strWarInfo .. '[NEWLINE]' .. Locale.ConvertTextKey( "TXT_KEY_GAIA_WAR_PANEL_LOSSES_THEM_CRIPPLED" );
			elseif (iTotal >= GameDefines.WAR_DAMAGE_LEVEL_THRESHOLD_SERIOUS) then
				strWarInfo = strWarInfo .. '[NEWLINE]' .. Locale.ConvertTextKey( "TXT_KEY_GAIA_WAR_PANEL_LOSSES_THEM_SERIOUS" );
			elseif (iTotal >= GameDefines.WAR_DAMAGE_LEVEL_THRESHOLD_MAJOR) then
				strWarInfo = strWarInfo .. '[NEWLINE]' .. Locale.ConvertTextKey( "TXT_KEY_GAIA_WAR_PANEL_LOSSES_THEM_MAJOR" );
			elseif (iTotal >= GameDefines.WAR_DAMAGE_LEVEL_THRESHOLD_MINOR) then
				strWarInfo = strWarInfo .. '[NEWLINE]' .. Locale.ConvertTextKey( "TXT_KEY_GAIA_WAR_PANEL_LOSSES_THEM_MINOR" );
			end
		elseif (iTotal < 0) then
			if (iTotal <= -GameDefines.WAR_DAMAGE_LEVEL_THRESHOLD_CRIPPLED) then
				strWarInfo = strWarInfo .. '[NEWLINE]' .. Locale.ConvertTextKey( "TXT_KEY_GAIA_WAR_PANEL_LOSSES_US_CRIPPLED" );
			elseif (iTotal <= -GameDefines.WAR_DAMAGE_LEVEL_THRESHOLD_SERIOUS) then
				strWarInfo = strWarInfo .. '[NEWLINE]' .. Locale.ConvertTextKey( "TXT_KEY_GAIA_WAR_PANEL_LOSSES_US_SERIOUS" );
			elseif (iTotal <= -GameDefines.WAR_DAMAGE_LEVEL_THRESHOLD_MAJOR) then
				strWarInfo = strWarInfo .. '[NEWLINE]' .. Locale.ConvertTextKey( "TXT_KEY_GAIA_WAR_PANEL_LOSSES_US_MAJOR" );
			elseif (iTotal <= -GameDefines.WAR_DAMAGE_LEVEL_THRESHOLD_MINOR) then
				strWarInfo = strWarInfo .. '[NEWLINE]' .. Locale.ConvertTextKey( "TXT_KEY_GAIA_WAR_PANEL_LOSSES_US_MINOR" );
			end
		end

		Controls.WarScore:SetToolTipString(strWarInfo);
	else
		Controls.WarScore:SetHide(true);
	end

	local bMyMode = false;
	
	if (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DEFAULT_ROOT) then
		bMyMode = true;
	elseif (iDiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_WAR_DECLARED_BY_HUMAN) then
		bMyMode = true;
	elseif (iDiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_PEACE_MADE_BY_HUMAN) then
		bMyMode = true;
	end
	
	if (bMyMode) then					
		UI.SetLeaderHeadRootUp( true );
		Controls.LeaderSpeech:SetText( szLeaderMessage );		
		local contentSize = Controls.LeaderSpeech:GetSize().y + offsetOfString + bonusPadding;
		Controls.LeaderSpeechBorderFrame:SetSizeY( contentSize );
		Controls.LeaderSpeechFrame:SetSizeY( contentSize - offsetsBetweenFrames );
		
	else
		Controls.LeaderSpeech:SetText( g_strLeaveScreenText );
		
	end
	
	UIManager:QueuePopup( ContextPtr, PopupPriority.LeaderHead );
    
end
Events.AILeaderMessage.Add( LeaderMessageHandler );


----------------------------------------------------------------        
-- BACK
----------------------------------------------------------------        
function OnReturn()
    UIManager:DequeuePopup( ContextPtr );
	UI.SetLeaderHeadRootUp( false );
	UI.RequestLeaveLeader();
end
Controls.BackButton:RegisterCallback( Mouse.eLClick, OnReturn );


function OnLeavingLeader()
	UI.SetLeaderHeadRootUp( false );
		
    UIManager:DequeuePopup( ContextPtr );
end
Events.LeavingLeaderViewMode.Add( OnLeavingLeader );


local oldCursor = 0;

----------------------------------------------------------------        
-- SHOW/HIDE
----------------------------------------------------------------        
function OnShowHide( bHide )
	
	-- Showing Screen
	if (not bHide) then

		LuaEvents.EUILeaderHeadRoot();
	
		Controls.RootOptions:SetHide( not UI.GetLeaderHeadRootUp() );

		local pActivePlayer = Players[Game.GetActivePlayer()];
		local pActiveTeam = Teams[Game.GetActiveTeam()];
		
		if (Game.GetActiveTeam() == g_iAITeam) then
			Controls.WarButton:SetHide(true);
			Controls.DemandButton:SetHide(true);
		elseif (not pActivePlayer:IsAlive()) then
			Controls.WarButton:SetHide(true);
			Controls.DemandButton:SetHide(true);
		else
			Controls.WarButton:SetHide(false);
			Controls.DemandButton:SetHide(false);
		end

		Controls.DiscussButton:SetDisabled(false);

		oldCursor = UIManager:SetUICursor(0);
		
		if (g_iAITeam ~= -1 and g_iAIPlayer ~= -1) then
			if (pActiveTeam:IsAtWar(g_iAITeam)) then
				Controls.WarButton:SetText( Locale.ConvertTextKey( "TXT_KEY_DIPLO_NEGOTIATE_PEACE" ));
				Controls.WarButton:SetToolTipString( Locale.ConvertTextKey( "TXT_KEY_DIPLO_NEGOTIATE_PEACE_TT" ));
				Controls.TradeButton:SetDisabled(true);
				Controls.DemandButton:SetDisabled(true);
				Controls.DemandButton:SetText( Locale.ConvertTextKey( "TXT_KEY_DIPLO_DEMAND_BUTTON" ));
				Controls.DemandButton:SetToolTipString(nil);

				if (pActiveTeam:CanChangeWarPeace(g_iAITeam) and not (Teams[g_iAITeam]._IsVassalLockedIntoWar and Teams[g_iAITeam]:_IsVassalLockedIntoWar(Game.GetActiveTeam()))) then
					Controls.WarButton:SetDisabled(false);
				else
					Controls.WarButton:SetDisabled(true);

					if (pActiveTeam._IsVassalLockedIntoWar and pActiveTeam:_IsVassalLockedIntoWar(g_iAITeam)) then
						Controls.WarButton:SetToolTipString( Locale.ConvertTextKey( "TXT_KEY_GAIA_PEACE_BLOCKED_WHILE_VASSAL_TT" ));
					elseif (Teams[g_iAITeam]._IsVassalLockedIntoWar and Teams[g_iAITeam]:_IsVassalLockedIntoWar(Game.GetActiveTeam())) then
						local iMaster = Teams[g_iAITeam]:_GetMaster();
						if (iMaster ~= -1) then
							local pMaster = Teams[iMaster];
							Controls.WarButton:SetToolTipString( Locale.ConvertTextKey( "TXT_KEY_GAIA_PEACE_BLOCKED_TARGET_IS_VASSAL_TT", pMaster:GetName() ));
						end
					else
						local iLockedTurnsUs = pActiveTeam:GetNumTurnsLockedIntoWar(g_iAITeam);
						local iLockedTurnsThem = Teams[g_iAITeam]:GetNumTurnsLockedIntoWar(Game.GetActiveTeam());

						if (iLockedTurnsUs ~= 0) then
							Controls.WarButton:SetToolTipString( Locale.ConvertTextKey( "TXT_KEY_DIPLO_NEGOTIATE_PEACE_BLOCKED_TT", iLockedTurnsUs ));
						elseif (iLockedTurnsThem ~= 0) then
							Controls.WarButton:SetToolTipString( Locale.ConvertTextKey( "TXT_KEY_GAIA_PEACE_BLOCKED_THEY_ARE_LOCKED_TT", iLockedTurnsThem ));
						else
							Controls.WarButton:SetToolTipString( Locale.ConvertTextKey( "TXT_KEY_GAIA_PEACE_BLOCKED_BY_RULES_TT" ));
						end
					end
				end
			else
				Controls.WarButton:SetText( Locale.ConvertTextKey( "TXT_KEY_DIPLO_DECLARE_WAR" ));
				Controls.WarButton:SetToolTipString( Locale.ConvertTextKey( "TXT_KEY_DIPLO_DECLARES_WAR_TT" ));
				Controls.TradeButton:SetDisabled(false);
				Controls.DemandButton:SetDisabled(false);

				if (Game.IsOption("GAMEOPTION_GAIA_VASSALAGE") and pActivePlayer:IsDoF(g_iAIPlayer)) then
					Controls.DemandButton:SetText( Locale.ConvertTextKey( "TXT_KEY_GAIA_ASK_FRIEND_FOR_HELP_BUTTON" ));
					Controls.DemandButton:SetToolTipString( Locale.ConvertTextKey( "TXT_KEY_GAIA_ASK_FRIEND_FOR_HELP_BUTTON_TT" ));
				else
					Controls.DemandButton:SetText( Locale.ConvertTextKey( "TXT_KEY_DIPLO_DEMAND_BUTTON" ));
					Controls.DemandButton:SetToolTipString( Locale.ConvertTextKey( "TXT_KEY_GAIA_LEADER_DEMAND_TRIBUTE_TT" ));
				end

				if (pActiveTeam:CanDeclareWar(g_iAITeam)) then
					Controls.WarButton:SetDisabled(false);
				else
					Controls.WarButton:SetDisabled(true);

					if (pActiveTeam._IsVassalOfSomeone and pActiveTeam:_IsVassalOfSomeone()) then
						if (pActiveTeam._IsVassal and pActiveTeam:_IsVassal(g_iAITeam)) then
							Controls.WarButton:SetToolTipString( Locale.ConvertTextKey( "TXT_KEY_GAIA_WAR_BLOCKED_ON_OWN_MASTER_TT" ));
						else
							Controls.WarButton:SetToolTipString( Locale.ConvertTextKey( "TXT_KEY_GAIA_WAR_BLOCKED_WHILE_VASSAL_TT" ));
						end
					elseif (pActiveTeam:IsForcePeace(g_iAITeam)) then
						Controls.WarButton:SetToolTipString( Locale.ConvertTextKey( "TXT_KEY_DIPLO_MAY_NOT_ATTACK" ));
					elseif (Teams[g_iAITeam]._IsVassalOfSomeone and Teams[g_iAITeam]:_IsVassalOfSomeone() and Teams[g_iAITeam]:_GetMaster() ~= Game.GetActiveTeam()) then
						local pMaster = Teams[ Teams[g_iAITeam]:_GetMaster() ];
						Controls.WarButton:SetToolTipString( Locale.ConvertTextKey( "TXT_KEY_DIPLO_MAY_NOT_ATTACK_VASSAL", pMaster:GetName() ));
					elseif (pActiveTeam._IsWarBlockedBySameReligion and pActiveTeam:_IsWarBlockedBySameReligion(g_iAITeam)) then
						Controls.WarButton:SetToolTipString( Locale.ConvertTextKey( "TXT_KEY_DIPLO_MAY_NOT_ATTACK_RELIGION" ));
					else
						Controls.WarButton:SetToolTipString( Locale.ConvertTextKey( "TXT_KEY_DIPLO_MAY_NOT_ATTACK_MOD" ));
					end
				end

			end
		end
		
	-- Hiding Screen
	else
		UIManager:SetUICursor(oldCursor);
	
	end
end
ContextPtr:SetShowHideHandler( OnShowHide );


----------------------------------------------------------------        
-- Key Down Processing
----------------------------------------------------------------        
function InputHandler( uiMsg, wParam, lParam )
    if( uiMsg == KeyEvents.KeyDown )
    then
        if( wParam == Keys.VK_ESCAPE or wParam == Keys.VK_RETURN ) then
			OnReturn();
        end
    end
    return true;
end
ContextPtr:SetInputHandler( InputHandler );



function OnDiscuss()
	Controls.LeaderSpeech:SetText( g_strLeaveScreenText );
		
	Game.DoFromUIDiploEvent( FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_HUMAN_WANTS_DISCUSSION, g_iAIPlayer, 0, 0 );
end
Controls.DiscussButton:RegisterCallback( Mouse.eLClick, OnDiscuss );


function OnTrade()
	Players[g_iAIPlayer]:DoTradeScreenOpened();
	
	Controls.LeaderSpeech:SetText( g_strLeaveScreenText );
	
    UI.OnHumanOpenedTradeScreen(g_iAIPlayer);
end
Controls.TradeButton:RegisterCallback( Mouse.eLClick, OnTrade );


function OnDemand()
	
	Controls.LeaderSpeech:SetText( g_strLeaveScreenText );
	
    UI.OnHumanDemand(g_iAIPlayer);
end
Controls.DemandButton:RegisterCallback( Mouse.eLClick, OnDemand );


function OnWarOrPeace()
	
    local bAtWar = Teams[Game.GetActiveTeam()]:IsAtWar(g_iAITeam);
    
	-- Asking for Peace (currently at war)
    if (bAtWar) then
	    Game.DoFromUIDiploEvent( FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_HUMAN_NEGOTIATE_PEACE, g_iAIPlayer, 0, 0 );
		
    -- Declaring War (currently at peace)
	else
		UI.AddPopup{ Type = ButtonPopupTypes.BUTTONPOPUP_DECLAREWARMOVE, Data1 = g_iAITeam, Option1 = true, Text = ""};
    end
    
end
Controls.WarButton:RegisterCallback( Mouse.eLClick, OnWarOrPeace );


function WarStateChangedHandler( iTeam1, iTeam2, bWar )
	
	if (iTeam1 == Game.GetActiveTeam() and iTeam2 == g_iAITeam) then
		
		if (bWar) then
			Controls.WarButton:SetText( Locale.ConvertTextKey( "TXT_KEY_DIPLO_NEGOTIATE_PEACE" ));
			Controls.TradeButton:SetDisabled(true);
			Controls.DemandButton:SetDisabled(true);
			Controls.DemandButton:SetText( Locale.ConvertTextKey( "TXT_KEY_DIPLO_DEMAND_BUTTON" ));
			Controls.DemandButton:SetToolTipString( Locale.ConvertTextKey( "TXT_KEY_GAIA_LEADER_DEMAND_TRIBUTE_TT" ));
			Controls.DiscussButton:SetDisabled(false);
		else
			Controls.WarButton:SetText(Locale.ConvertTextKey( "TXT_KEY_DIPLO_DECLARE_WAR" ));
			Controls.TradeButton:SetDisabled(false);
			Controls.DemandButton:SetDisabled(false);
			Controls.DiscussButton:SetDisabled(false);
		end
		
	end
	
end
Events.WarStateChanged.Add( WarStateChangedHandler );

---------------------------------------------------------------------------------------
-- Support for Modded Add-in UI's
---------------------------------------------------------------------------------------
g_uiAddins = {};
for addin in Modding.GetActivatedModEntryPoints("DiplomacyUIAddin") do
	local addinFile = Modding.GetEvaluatedFilePath(addin.ModID, addin.Version, addin.File);
	local addinPath = addinFile.EvaluatedPath;
	
	local extension = Path.GetExtension(addinPath);
	local path = string.sub(addinPath, 1, #addinPath - #extension);
	
	table.insert(g_uiAddins, ContextPtr:LoadNewContext(path));
end
