include( "IconSupport" );
include( "InstanceManager" );
include("GameplayUtilities");
include("InfoTooltipInclude");

local g_InstanceManager = InstanceManager:new( "Leader Button", "Button", Controls.LeaderStack );
local g_iAIPlayer = -1;
local g_iAITeam = -1;
local g_CurrentTopic = -1;

local g_bCanGoBack = true;

local g_DiploUIState = -1;
local g_iDiploData = -1;

-- Discussion modes
local g_iModeDiscussionRoot = 0;
local g_iModeDiscussionWar = 1;
local g_iModeDiscussionShareOpinion = 2;
local g_iInvokedDiscussionMode = g_iModeDiscussionRoot;

local g_bDiscussionRequests = false;
for row in GameInfo.Sapiens_ModOptions{Name = "DISCUSSION_REQUESTS"} do
	g_bDiscussionRequests = (row.Value == 1);
end

local g_strDefaultDiscussionText = Locale.ConvertTextKey("TXT_KEY_DIPLOMACY_DISCUSS_WHAT");

local offsetOfString = 32;
local bonusPadding = 16;
local innerFrameWidth = 554;
local outerFrameWidth = 550;
local offsetsBetweenFrames = 4;

local oldCursor = 0;

----------------------------------------------------------------    
-- LEADER MESSAGE HANDLER
----------------------------------------------------------------    
function LeaderMessageHandler(iPlayer, iDiploUIState, szLeaderMessage, iAnimationAction, iData1)
    
    g_DiploUIState = iDiploUIState;
    g_iDiploData = iData1;
    
    g_iAIPlayer = iPlayer;
    g_iAITeam = Players[g_iAIPlayer]:GetTeam();
    
    local pAIPlayer = Players[g_iAIPlayer];
    local iActivePlayer = Game.GetActivePlayer();
    
    local pActiveTeam = Teams[Game.GetActiveTeam()];
    local pAITeam = Teams[g_iAITeam];
    
    local activePlayer = Players[iActivePlayer];
    
    local themCivType = pAIPlayer:GetCivilizationType();
    local themCivInfo = GameInfo.Civilizations[themCivType];
    CivIconHookup(g_iAIPlayer, 64, Controls.ThemSymbolShadow, Controls.CivIconBG, Controls.CivIconShadow, false, true);
    
    local player = Players[g_iAIPlayer];
    local strTitleText = GameplayUtilities.GetLocalizedLeaderTitle(player);
    Controls.TitleText:SetText(strTitleText);
    
    local otherLeader = GameInfo.Leaders[player:GetLeaderType()];

    local playerLeaderInfo = GameInfo.Leaders[player:GetLeaderType()];
    local leaderTextures = {
        ["LEADER_ALEXANDER"] = "alexander.dds",
        ["LEADER_ASKIA"] = "askia.dds",
		["LEADER_AUGUSTUS"] = "augustus.dds",
		["LEADER_BISMARCK"] = "bismark.dds",
		["LEADER_CATHERINE"] = "catherine.dds",
		["LEADER_DARIUS"] = "darius.dds",
		["LEADER_ELIZABETH"] = "elizabeth.dds",
		["LEADER_GANDHI"] = "ghandi.dds",
		["LEADER_HARUN_AL_RASHID"] = "alrashid.dds",
		["LEADER_HIAWATHA"] = "hiawatha.dds",
		["LEADER_MONTEZUMA"] = "montezuma.dds",
		["LEADER_NAPOLEON"] = "napoleon.dds",
		["LEADER_ODA_NOBUNAGA"] = "oda.dds",
		["LEADER_RAMESSES"] = "ramesses.dds",
		["LEADER_RAMKHAMHAENG"] = "ramkhamaeng.dds",
		["LEADER_SULEIMAN"] = "sulieman.dds",
		["LEADER_WASHINGTON"] = "washington.dds",
		["LEADER_WU_ZETIAN"] = "wu.dds",
		["LEADER_GENGHIS_KHAN"] = "genghis.dds",
		["LEADER_ISABELLA"] = "isabella.dds",
		["LEADER_PACHACUTI"] = "pachacuti.dds",
		["LEADER_KAMEHAMEHA"] = "kamehameha.dds",
		["LEADER_HARALD"] = "harald.dds",
		["LEADER_SEJONG"] = "sejong.dds",
		["LEADER_NEBUCHADNEZZAR"] = "nebuchadnezzar.dds",
		["LEADER_ATTILA"] = "attila.dds",
		["LEADER_BOUDICCA"] = "boudicca.dds",
		["LEADER_DIDO"] = "dido.dds",
		["LEADER_GUSTAVUS_ADOLPHUS"] = "gustavus adolphus.dds",
		["LEADER_MARIA"] = "mariatheresa.dds",
		["LEADER_PACAL"] = "pacal_the_great.dds",
		["LEADER_THEODORA"] = "theodora.dds",
		["LEADER_SELASSIE"] = "haile_selassie.dds",
		["LEADER_WILLIAM"] = "william_of_orange.dds",		
		["LEADER_SHAKA"] = "Shaka.dds",
		["LEADER_POCATELLO"] = "Pocatello.dds",
		["LEADER_PEDRO"] = "Pedro.dds",
		["LEADER_MARIA_I"] = "Maria_I.dds",
		["LEADER_GAJAH_MADA"] = "Gajah.dds",
		["LEADER_ENRICO_DANDOLO"] = "Dandolo.dds",
		["LEADER_CASIMIR"] = "Casimir.dds",
		["LEADER_ASHURBANIPAL"] = "Ashurbanipal.dds",
		["LEADER_AHMAD_ALMANSUR"] = "Almansur.dds",
	}
	
	if iPlayer > 21 then
        local backupTexture = "loadingbasegame_9.dds";
        if leaderTextures[playerLeaderInfo.Type] then
            backupTexture = leaderTextures[playerLeaderInfo.Type];
        end

        Controls.BackupTexture:SetTexture(backupTexture);
        local screenW, screenH = Controls.BackupTexture:GetSizeVal();
        Controls.BackupTexture:SetTextureAndResize(backupTexture);
        local textureW, textureH = Controls.BackupTexture:GetSizeVal();    

        local ratioW = screenW / textureW;
        local ratioH = screenH / textureH;

        local ratio = math.max(ratioW, ratioH);
        Controls.BackupTexture:SetSizeVal(math.floor(textureW * ratio), math.floor(textureH * ratio));
        Controls.BackupTexture:SetHide(false);
    else
        Controls.BackupTexture:UnloadTexture();
        Controls.BackupTexture:SetHide(true);
    end

    -- Mood
    local iApproach = activePlayer:GetApproachTowardsUsGuess(g_iAIPlayer);
    local strMoodText = Locale.ConvertTextKey("TXT_KEY_EMOTIONLESS");

    if (Players[g_iAIPlayer]:IsAlive()) then
        if (not activePlayer:IsAlive()) then
            strMoodText = Locale.ConvertTextKey("TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_NEUTRAL", otherLeader.Description);
        else
            if (pActiveTeam:IsAtWar(g_iAITeam)) then
                strMoodText = Locale.ConvertTextKey("TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_WAR");
            elseif (Players[g_iAIPlayer]:IsDenouncingPlayer(iActivePlayer)) then
                strMoodText = Locale.ConvertTextKey("TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_DENOUNCING");
            elseif (Players[g_iAIPlayer]:WasResurrectedThisTurnBy(iActivePlayer)) then
                strMoodText = Locale.ConvertTextKey("TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_LIBERATED");
            else
                if iApproach == MajorCivApproachTypes.MAJOR_CIV_APPROACH_WAR then
                    strMoodText = Locale.ConvertTextKey("TXT_KEY_WAR_CAPS");
                elseif iApproach == MajorCivApproachTypes.MAJOR_CIV_APPROACH_HOSTILE then
                    strMoodText = Locale.ConvertTextKey("TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_HOSTILE", otherLeader.Description);
                elseif iApproach == MajorCivApproachTypes.MAJOR_CIV_APPROACH_GUARDED then
                    strMoodText = Locale.ConvertTextKey("TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_GUARDED", otherLeader.Description);
                elseif iApproach == MajorCivApproachTypes.MAJOR_CIV_APPROACH_AFRAID then
                    strMoodText = Locale.ConvertTextKey("TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_AFRAID", otherLeader.Description);
                elseif iApproach == MajorCivApproachTypes.MAJOR_CIV_APPROACH_FRIENDLY then
                    strMoodText = Locale.ConvertTextKey("TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_FRIENDLY", otherLeader.Description);
                else
                    strMoodText = Locale.ConvertTextKey("TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_NEUTRAL", otherLeader.Description);
                end
            end
        end
    end

    Controls.MoodText:SetText(strMoodText);
    local strMoodInfo = GetMoodInfo(g_iAIPlayer);
    Controls.MoodText:SetToolTipString(strMoodInfo);

	local bMyMode = false;
	
	local strExtra = "";
	
	if (iDiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_HUMAN_INVOKED) then
		bMyMode = true;
	elseif (iDiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_BLANK_DISCUSSION_RETURN_TO_ROOT) then
		bMyMode = true;
	elseif (iDiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_BLANK_DISCUSSION) then
		bMyMode = true;
	elseif (iDiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_BLANK_DISCUSSION_MEAN_HUMAN) then
		bMyMode = true;
	elseif (iDiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_BLANK_DISCUSSION_MEAN_AI) then
		bMyMode = true;
	elseif (iDiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_AI_DECLARED_WAR) then
		strExtra = "[NEWLINE][NEWLINE](" .. Locale.ConvertTextKey("TXT_KEY_WAR_DECLARED") .. ")";
		bMyMode = true;
	elseif (iDiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_AGGRESSIVE_MILITARY_WARNING) then
		bMyMode = true;
	elseif (iDiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_I_ATTACKED_YOUR_MINOR_CIV) then
		bMyMode = true;
	elseif (iDiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_I_BULLIED_YOUR_MINOR_CIV) then
		bMyMode = true;
	elseif (iDiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_YOU_ATTACKED_MINOR_CIV) then
		bMyMode = true;
	elseif (iDiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_YOU_BULLIED_MINOR_CIV) then
		bMyMode = true;
	elseif (iDiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_PROTECT_MINOR_CIV) then
		bMyMode = true;
	elseif (iDiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_YOU_EXPANSION_WARNING) then
		bMyMode = true;
	elseif (iDiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_YOU_PLOT_BUYING_WARNING) then
		bMyMode = true;
	elseif (iDiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_WORK_WITH_US) then
		bMyMode = true;
	elseif (iDiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_WORK_AGAINST_SOMEONE) then
		bMyMode = true;
	elseif (iDiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_COOP_WAR) then
		bMyMode = true;
	elseif (iDiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_COOP_WAR_TIME) then
		bMyMode = true;
	elseif (iDiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_PLAN_RESEARCH_AGREEMENT) then
		bMyMode = true;
	elseif (iDiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_AI_REQUEST_DENOUNCE) then
		bMyMode = true;
	elseif (iDiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_CAUGHT_YOUR_SPY) then
		bMyMode = true;
	elseif (iDiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_KILLED_YOUR_SPY) then
		bMyMode = true;
	elseif (iDiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_KILLED_MY_SPY) then
		bMyMode = true;
	elseif (iDiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_CONFRONT_YOU_KILLED_MY_SPY) then
		bMyMode = true;
	elseif (iDiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_STOP_CONVERSIONS) then
		bMyMode = true;
	elseif (iDiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_STOP_DIGGING) then
		bMyMode = true;
	elseif (iDiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_AI_REVOKE_VASSALAGE) then
		bMyMode = true;
	elseif (iDiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_WAR_DECLARED_BY_HUMAN) then
		if (iData1 == 1) then
			bMyMode = true;
		end
	end
    
    if (bMyMode) then
    
        if( ContextPtr:IsHidden() ) then
    	    UIManager:QueuePopup( ContextPtr, PopupPriority.LeaderDiscuss );
	    end
		
		Controls.LeaderSpeech:SetText( szLeaderMessage .. strExtra );
		
		local contentSize = Controls.LeaderSpeech:GetSize().y + offsetOfString + bonusPadding;
		Controls.LeaderSpeechBorderFrame:SetSizeY( contentSize );
		Controls.LeaderSpeechFrame:SetSizeY( contentSize - offsetsBetweenFrames );
		
		local strButton1Text = -1;
		local strButton2Text = -1;
		local strButton3Text = -1;
		local strButton4Text = -1;
		local strButton5Text = -1;
		local strButton6Text = -1;
		local strButton7Text = -1;
		local strButton8Text = -1;
		local strButton9Text = -1;
		local strButton10Text = -1;
		local strButton11Text = -1;
		
		local strButton1Tooltip = "";
		local strButton2Tooltip = "";
		local strButton3Tooltip = "";
		local strButton4Tooltip = "";
		local strButton5Tooltip = "";
		local strButton6Tooltip = "";
		local strButton7Tooltip = "";
		local strButton8Tooltip = "";
		local strButton9Tooltip = "";
		local strButton10Tooltip = "";
		local strButton11Tooltip = "";
		
 		Controls.Button1:SetDisabled(false);
 		Controls.Button2:SetDisabled(false);
 		Controls.Button3:SetDisabled(false);
 		Controls.Button4:SetDisabled(false);
		Controls.Button5:SetDisabled(false);
		Controls.Button6:SetDisabled(false);
		Controls.Button7:SetDisabled(false);
		Controls.Button8:SetDisabled(false);
		Controls.Button9:SetDisabled(false);
		Controls.Button10:SetDisabled(false);
		Controls.Button11:SetDisabled(false);
		
		local bHideBackButton = false;
	    
		-- Human invoked discussion
		if (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_HUMAN_INVOKED) then

			-- Discussion Root Mode
			if (g_iInvokedDiscussionMode == g_iModeDiscussionRoot) then
				local strLeaderName;
				if(pAIPlayer:GetNickName() ~= "" and Game:IsNetworkMultiPlayer()) then
					strLeaderName = pAIPlayer:GetNickName();
				else
					strLeaderName = pAIPlayer:GetName();
				end

				--------------------
				-- SHARE INTRIGUE --
				--------------------

				if (activePlayer:HasRecentIntrigueAbout(iPlayer) and activePlayer:IsAlive() and (not Players[iPlayer]:IsHuman()) and (not pActiveTeam:IsAtWar(g_iAITeam))) then
					local strLeaderName;
					if(pAIPlayer:GetNickName() ~= "" and Game:IsNetworkMultiPlayer()) then
						strLeaderName = pAIPlayer:GetNickName();
					else
						strLeaderName = pAIPlayer:GetName()
					end

					strButton2Text = Locale.ConvertTextKey("TXT_KEY_DIPLO_DISCUSS_MESSAGE_SHARE_INTRIGUE", strLeaderName);
					strButton2Tooltip = Locale.ConvertTextKey("TXT_KEY_DIPLO_DISCUSS_MESSAGE_SHARE_INTRIGUE_TT", strLeaderName);
				end

				--------------------
				-- STOP SPYING  --
				--------------------

				local agents = pAIPlayer:GetEspionageSpies();
				local bHasAgents = #agents ~= 0;

				if (not pAIPlayer:IsStopSpyingMessageTooSoon(iActivePlayer) and bHasAgents and (g_iAITeam ~= Game.GetActiveTeam())) then
					strButton3Text = Locale.ConvertTextKey( "TXT_KEY_DIPLO_DISCUSS_MESSAGE_STOP_SPYING" );
				end

				---------------------
				--  STOP RELIGION  --
				---------------------

				if (activePlayer:GetNegativeReligiousConversionPoints(g_iAIPlayer) > 0 or activePlayer:HasCreatedReligion() or pAIPlayer:HasCreatedReligion()) then
					if (not pAIPlayer:IsAskedToStopConverting(iActivePlayer)) then
						strButton4Text = Locale.ConvertTextKey("TXT_KEY_DIPLO_DISCUSS_MESSAGE_STOP_SPREADING_RELIGION");
					end
				end

				---------------------
				-- DON'T SETTLE  --
				---------------------

				if (not pAIPlayer:IsDontSettleMessageTooSoon(iActivePlayer)) then
					strButton5Text = Locale.ConvertTextKey( "TXT_KEY_DIPLO_DISCUSS_MESSAGE_DONT_SETTLE" );
				end

				-----------------------
				--	STOP ARCHAEOLOGY --
				-----------------------

				if (activePlayer:GetNegativeArchaeologyPoints(g_iAIPlayer) > 0 and not pAIPlayer:IsAskedToStopDigging(iActivePlayer)) then
					strButton6Text = Locale.ConvertTextKey("TXT_KEY_DIPLO_DISCUSS_MESSAGE_STOP_DIGGING");
				end

				-----------------------
				--  DENOUNCE AND DOF --
				-----------------------
				if (pAIPlayer:GetTeam() ~= Players[iActivePlayer]:GetTeam()) then
					if (not pAIPlayer:IsDoFMessageTooSoon(iActivePlayer)) then
						strButton7Text = Locale.ConvertTextKey( "TXT_KEY_DIPLO_DISCUSS_MESSAGE_DEC_FRIENDSHIP" );
						strButton7Tooltip = Locale.ConvertTextKey( "TXT_KEY_DIPLO_DISCUSS_MESSAGE_DEC_FRIENDSHIP_TT" );
					end

					local strLeaderName;
					if(pAIPlayer:GetNickName() ~= "" and Game:IsNetworkMultiPlayer()) then
						strLeaderName = pAIPlayer:GetNickName();
					else
						strLeaderName = pAIPlayer:GetName();
					end

					if(not activePlayer:IsDenouncedPlayer(g_iAIPlayer)) then
						strButton8Text = Locale.ConvertTextKey( "TXT_KEY_DIPLO_DISCUSS_DENOUNCE", strLeaderName);
						strButton8Tooltip = Locale.ConvertTextKey( "TXT_KEY_DIPLO_DISCUSS_DENOUNCE_TT");
					end
				end

				-----------------
				-- MOVE TROOPS --
				-----------------
				if (g_bDiscussionRequests and pAIPlayer._MoveRequestTooSoon and not pAIPlayer:_MoveRequestTooSoon(iActivePlayer)) then
					if (activePlayer:_GetMilitaryAggressivePosture(g_iAIPlayer) >= AggressivePostureTypes.AGGRESSIVE_POSTURE_MEDIUM) then
						if (pAIPlayer._IsActHostileTowardsHuman and pAIPlayer:_IsActHostileTowardsHuman(iActivePlayer)) then
							strButton9Text = Locale.ConvertTextKey( "TXT_KEY_GAIA_DISCUSS_ASK_WITHDRAW_BORDER_TROOPS_HOSTILE" );
						else
							strButton9Text = Locale.ConvertTextKey( "TXT_KEY_GAIA_DISCUSS_ASK_WITHDRAW_BORDER_TROOPS" );
						end

						strButton9Tooltip = Locale.ConvertTextKey("TXT_KEY_GAIA_DISCUSS_ASK_WITHDRAW_BORDER_TROOPS_TT", strLeaderName);
					end
				end

				--------------------------------
				--  DECLARE WAR (THIRD PARTY) --
				--------------------------------
				strButton10Text = Locale.ConvertTextKey( "TXT_KEY_DIPLO_DISCUSS_MESSAGE_DECLARE_WAR" );
				Controls.Button10:SetDisabled(true);

				--------------------
				--  SHARE OPINION --
				--------------------
				if (g_bDiscussionRequests) then
					strButton11Text = Locale.ConvertTextKey( "TXT_KEY_DIPLO_DISCUSS_MESSAGE_SHARE_OPINION" );
					Controls.Button11:SetDisabled(true);
				end

				for iPlayerLoop = 0, GameDefines.MAX_MAJOR_CIVS-1, 1 do

					-- War button: Button 10
					if (pAIPlayer:IsDoF(iActivePlayer) or pAIPlayer:GetTeam() == Players[iActivePlayer]:GetTeam()) then
						if (IsWarAgainstThirdPartyPlayerValid(iPlayerLoop) and not pActiveTeam:IsAtWar(g_iAITeam)) then
							strButton10Tooltip = Locale.ConvertTextKey( "TXT_KEY_GAIA_JOINT_WAR_REQUEST_TT" );
							Controls.Button10:SetDisabled(false);
						end
					end

					-- Share Opinion button: Button 11
					if (g_bDiscussionRequests and IsShareOpinionOnThirdPartyPlayerValid(iPlayerLoop)) then
						Controls.Button11:SetDisabled(false);
					end
				end
			end

		-- Human did something mean, AI responded
		elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_BLANK_DISCUSSION_MEAN_HUMAN) then
			strButton1Text = Locale.ConvertTextKey( "TXT_KEY_DIPLO_DISCUSS_MESSAGE_SORRY" );
			strButton2Text = Locale.ConvertTextKey( "TXT_KEY_DIPLO_DISCUSS_MESSAGE_DEAL" );
			bHideBackButton = true;
			
		-- AI did something mean
		elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_BLANK_DISCUSSION_MEAN_AI) then
			strButton1Text = Locale.ConvertTextKey( "TXT_KEY_DIPLO_DISCUSS_MESSAGE_OKAY" );
			strButton2Text = Locale.ConvertTextKey( "TXT_KEY_DIPLO_DISCUSS_MESSAGE_YOULL_PAY" );
			bHideBackButton = true;
			
		elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_AI_DECLARED_WAR) then
			strButton1Text = Locale.ConvertTextKey( "TXT_KEY_DIPLO_DISCUSS_MESSAGE_OKAY" );
			strButton2Text = Locale.ConvertTextKey( "TXT_KEY_DIPLO_DISCUSS_MESSAGE_YOULL_PAY" );
			
			bHideBackButton = true;
			
		elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_AGGRESSIVE_MILITARY_WARNING) then
			strButton1Text = Locale.ConvertTextKey( "TXT_KEY_DIPLO_DISCUSS_WE_MEAN_NO_HARM" );
			strButton2Text = Locale.ConvertTextKey( "TXT_KEY_DIPLO_DISCUSS_TIME_TO_DIE" );
			bHideBackButton = true;
		elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_I_ATTACKED_YOUR_MINOR_CIV) then
			strButton1Text = Locale.ConvertTextKey( "TXT_KEY_DIPLO_DISCUSS_NO_DIVIDE" );
			strButton2Text = Locale.ConvertTextKey( "TXT_KEY_DIPLO_DISCUSS_YOU_WILL_PAY" );
			local pMinor = Players[iData1];
			if (pMinor ~= nil) then
				local iInfLoss = (GameDefines["MINOR_FRIENDSHIP_DROP_DISHONOR_PLEDGE_TO_PROTECT"] / 100) * -1;
				strButton1Tooltip = Locale.ConvertTextKey("TXT_KEY_DIPLO_DISCUSS_PROTECTED_MINOR_FORGIVE_TT", pAIPlayer:GetCivilizationShortDescriptionKey(), pMinor:GetCivilizationShortDescriptionKey(), iInfLoss);
				strButton2Tooltip = Locale.ConvertTextKey("TXT_KEY_DIPLO_DISCUSS_PROTECTED_MINOR_DISPUTE_TT", pAIPlayer:GetCivilizationShortDescriptionKey(), pMinor:GetCivilizationShortDescriptionKey());
			end
			bHideBackButton = true;
		elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_I_BULLIED_YOUR_MINOR_CIV) then
			strButton1Text = Locale.ConvertTextKey( "TXT_KEY_DIPLO_DISCUSS_NO_DIVIDE" );
			strButton2Text = Locale.ConvertTextKey( "TXT_KEY_DIPLO_DISCUSS_YOU_WILL_PAY" );
			local pMinor = Players[iData1];
			if (pMinor ~= nil) then
				local iInfLoss = (GameDefines["MINOR_FRIENDSHIP_DROP_DISHONOR_PLEDGE_TO_PROTECT"] / 100) * -1;
				strButton1Tooltip = Locale.ConvertTextKey("TXT_KEY_DIPLO_DISCUSS_PROTECTED_MINOR_FORGIVE_TT", pAIPlayer:GetCivilizationShortDescriptionKey(), pMinor:GetCivilizationShortDescriptionKey(), iInfLoss);
				strButton2Tooltip = Locale.ConvertTextKey("TXT_KEY_DIPLO_DISCUSS_PROTECTED_MINOR_DISPUTE_TT", pAIPlayer:GetCivilizationShortDescriptionKey(), pMinor:GetCivilizationShortDescriptionKey());
			end
			bHideBackButton = true;
		elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_YOU_ATTACKED_MINOR_CIV) then
			strButton1Text = Locale.ConvertTextKey( "TXT_KEY_DIPLO_DISCUSS_NOT_YOUR_BUSINESS" );
			strButton2Text = Locale.ConvertTextKey( "TXT_KEY_DIPLO_DISCUSS_WILL_WITHDRAW" );
			bHideBackButton = true;
		elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_YOU_BULLIED_MINOR_CIV) then
			strButton1Text = Locale.ConvertTextKey( "TXT_KEY_DIPLO_DISCUSS_NOT_YOUR_BUSINESS" );
			strButton2Text = Locale.ConvertTextKey( "TXT_KEY_DIPLO_DISCUSS_SORRY_FOR_BULLYING" );
			bHideBackButton = true;
		---- AI seriously warning human about his expansion
		elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_YOU_EXPANSION_WARNING) then
			strButton1Text = Locale.ConvertTextKey( "TXT_KEY_DIPLO_DISCUSS_SETTLE_WHAT_WE_PLEASE") ;
			strButton2Text = Locale.ConvertTextKey( "TXT_KEY_DIPLO_DISCUSS_SORRY_FOR_SETTLING") ;
			bHideBackButton = true;
		-- AI seriously warning human about his plot buying
		elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_YOU_PLOT_BUYING_WARNING) then
			strButton1Text = Locale.ConvertTextKey( "TXT_KEY_DIPLO_DISCUSS_NOT_YOUR_BUSINESS" );
			strButton2Text = Locale.ConvertTextKey( "TXT_KEY_DIPLO_DISCUSS_SORRY_FOR_CLAIMING" );
			bHideBackButton = true;
		-- AI asking player to work with him
		elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_WORK_WITH_US) then
			strButton1Text = Locale.ConvertTextKey( "TXT_KEY_DIPLO_DISCUSS_YES_WORK_TOGETHER" );
			strButton2Text = Locale.ConvertTextKey( "TXT_KEY_DIPLO_DISCUSS_NO_GO_IT_ALONE" );
			bHideBackButton = true;
		-- AI asking player to work against someone
		elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_WORK_AGAINST_SOMEONE) then
			strButton1Text = Locale.ConvertTextKey( "TXT_KEY_DIPLO_DISCUSS_SORRY_NO_INTEREST" );
			strButton2Text = Locale.ConvertTextKey( "TXT_KEY_DIPLO_DISCUSS_HOW_DARE_YOU" );
			strButton3Text = Locale.ConvertTextKey( "TXT_KEY_DIPLO_DISCUSS_DO_WHAT_WE_CAN" );
			bHideBackButton = true;
		-- AI asking player to declare war against someone
		elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_COOP_WAR) then
			strButton1Text = Locale.ConvertTextKey( "TXT_KEY_DIPLO_DISCUSS_SORRY_NO_INTEREST" );
			strButton2Text = Locale.ConvertTextKey( "TXT_KEY_DIPLO_DISCUSS_HOW_DARE_YOU" );
			strButton3Text = Locale.ConvertTextKey( "TXT_KEY_DIPLO_DISCUSS_COOP_WAR_SOON" );
			strButton4Text = Locale.ConvertTextKey( "TXT_KEY_DIPLO_DISCUSS_COOP_WAR_YES" );
			bHideBackButton = true;
		elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_COOP_WAR_TIME) then
			strButton1Text = Locale.ConvertTextKey( "TXT_KEY_DIPLO_DISCUSS_COOP_WAR_NOW" );
			strButton2Text = Locale.ConvertTextKey( "TXT_KEY_DIPLO_DISCUSS_CHANGED_MIND" );
			bHideBackButton = true;
		elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_PLAN_RESEARCH_AGREEMENT) then
			strButton1Text = Locale.ConvertTextKey( "TXT_KEY_DIPLO_DISCUSS_YES_LET_US_PREPARE" );
			strButton2Text = Locale.ConvertTextKey( "TXT_KEY_DIPLO_DISCUSS_SORRY_OTHER_PLANS" );
			bHideBackButton = true;
		-- AI asking player to denounce someone
		elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_AI_REQUEST_DENOUNCE) then
			strButton1Text = Locale.ConvertTextKey( "TXT_KEY_DIPLO_DISCUSS_DO_WHAT_WE_CAN" );
			strButton2Text = Locale.ConvertTextKey( "TXT_KEY_DIPLO_DISCUSS_SORRY_NO_INTEREST" );
			bHideBackButton = true;
		-- AI caught one of player's spies
		elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_CAUGHT_YOUR_SPY) then
			strButton1Text = Locale.ConvertTextKey( "TXT_KEY_DIPLO_DISCUSS_NOT_SORRY_FOR_SPY_CAUGHT" );
			strButton2Text = Locale.ConvertTextKey( "TXT_KEY_DIPLO_DISCUSS_SORRY_FOR_SPY_CAUGHT" );
			bHideBackButton = true;
		-- AI killed one of player's spies
		elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_KILLED_YOUR_SPY) then
			strButton1Text = Locale.ConvertTextKey( "TXT_KEY_DIPLO_DISCUSS_NOT_SORRY_FOR_SPY_KILLED" );
			strButton2Text = Locale.ConvertTextKey( "TXT_KEY_DIPLO_DISCUSS_SORRY_FOR_SPY_KILLED" );
			bHideBackButton = true;
		-- Player killed one of AI's spies
		elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_KILLED_MY_SPY) then
			strButton1Text = Locale.ConvertTextKey( "TXT_KEY_DIPLO_DISCUSS_DONT_FORGIVE_SPYING" );
			strButton2Text = Locale.ConvertTextKey( "TXT_KEY_DIPLO_DISCUSS_FORGIVE_SPYING" );
			bHideBackButton = true;
			
		elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_CONFRONT_YOU_KILLED_MY_SPY) then
			local strLeaderName;
			if(pAIPlayer:GetNickName() ~= "" and Game:IsNetworkMultiPlayer()) then
				strLeaderName = pAIPlayer:GetNickName();
			else
				strLeaderName = pAIPlayer:GetName();
			end

			strButton1Text = Locale.ConvertTextKey( "TXT_KEY_DIPLO_DISCUSS_CAUGHT_FORGIVE_SPYING" );
			
			if (not pAIPlayer:IsStopSpyingMessageTooSoon(iActivePlayer)) then
				strButton2Text = Locale.ConvertTextKey( "TXT_KEY_DIPLO_DISCUSS_CAUGHT_DEMAND_STOP_SPYING" );
			end
			
			if(not activePlayer:IsDenouncedPlayer(iPlayer)) then
				strButton3Text = Locale.ConvertTextKey( "TXT_KEY_DIPLO_DISCUSS_CAUGHT_DENOUNCE_FOR_SPYING", strLeaderName );
 			end
 			
			strButton4Text = Locale.ConvertTextKey( "TXT_KEY_DIPLO_DISCUSS_CAUGHT_DECLARE_WAR", strLeaderName );

			if (not pActiveTeam:CanDeclareWar(g_iAITeam)) then
				Controls.Button4:SetDisabled(true);

				if (pActiveTeam._IsVassalOfSomeone and pActiveTeam:_IsVassalOfSomeone()) then
					if (pActiveTeam._IsVassal and pActiveTeam:_IsVassal(g_iAITeam)) then
						strButton4Tooltip = Locale.ConvertTextKey( "TXT_KEY_GAIA_WAR_BLOCKED_ON_OWN_MASTER_TT" );
					else
						strButton4Tooltip = Locale.ConvertTextKey( "TXT_KEY_GAIA_WAR_BLOCKED_WHILE_VASSAL_TT" );
					end
				elseif (pActiveTeam:IsForcePeace(g_iAITeam)) then
					strButton4Tooltip = Locale.ConvertTextKey( "TXT_KEY_DIPLO_MAY_NOT_ATTACK" );
				elseif (Teams[g_iAITeam]._IsVassalOfSomeone and Teams[g_iAITeam]:_IsVassalOfSomeone() and Teams[g_iAITeam]:_GetMaster() ~= Game.GetActiveTeam()) then
					local pMaster = Teams[ Teams[g_iAITeam]:_GetMaster() ];
					strButton4Tooltip = Locale.ConvertTextKey( "TXT_KEY_DIPLO_MAY_NOT_ATTACK_VASSAL", pMaster:GetName() );
				elseif (pActiveTeam._IsWarBlockedBySameReligion and pActiveTeam:_IsWarBlockedBySameReligion(g_iAITeam)) then
					strButton4Tooltip = Locale.ConvertTextKey( "TXT_KEY_DIPLO_MAY_NOT_ATTACK_RELIGION" );
				else
					strButton4Tooltip = Locale.ConvertTextKey( "TXT_KEY_DIPLO_MAY_NOT_ATTACK_MOD" );
				end
			end
			
			bHideBackButton = true;
			
		-- Player converted cities in another empire
		elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_STOP_CONVERSIONS) then
			strButton1Text = Locale.ConvertTextKey( "TXT_KEY_DIPLO_DISCUSS_DONT_STOP_CONVERSIONS" );
			strButton2Text = Locale.ConvertTextKey( "TXT_KEY_DIPLO_DISCUSS_STOP_CONVERSIONS" );
			bHideBackButton = true;
	    
		-- Player dug for artifacts in another empire
		elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_STOP_DIGGING) then
			strButton1Text = Locale.ConvertTextKey( "TXT_KEY_DIPLO_DISCUSS_DONT_STOP_DIGGING" );
			strButton2Text = Locale.ConvertTextKey( "TXT_KEY_DIPLO_DISCUSS_STOP_DIGGING" );
			bHideBackButton = true;
		
		-- AI wants to revoke Vassalage
		elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_AI_REVOKE_VASSALAGE) then
			strButton1Text = Locale.ConvertTextKey( "TXT_KEY_GAIA_DISCUSS_REFUSE_VASSAL_INDEPENDENCE" );
			strButton2Text = Locale.ConvertTextKey( "TXT_KEY_GAIA_DISCUSS_GRANT_VASSAL_INDEPENDENCE" );
			bHideBackButton = true;
		end
	    
		-- Buttons: change text or hide
		if (strButton1Text == -1) then
	 		Controls.Button1:SetHide(true);
		else
	 		Controls.Button1Label:SetText(strButton1Text);		
	 		Controls.Button1:SetHide(false);
	 		Controls.Button1:SetToolTipString(strButton1Tooltip);
		end
	    
		if (strButton2Text == -1) then
	 		Controls.Button2:SetHide(true);
		else
	 		Controls.Button2Label:SetText(strButton2Text);		
	 		Controls.Button2:SetHide(false);
	 		Controls.Button2:SetToolTipString(strButton2Tooltip);
		end

		if (strButton3Text == -1) then
	 		Controls.Button3:SetHide(true);
		else
	 		Controls.Button3Label:SetText(strButton3Text);		
	 		Controls.Button3:SetHide(false);
	 		Controls.Button3:SetToolTipString(strButton3Tooltip);
		end

		if (strButton4Text == -1) then
	 		Controls.Button4:SetHide(true);
		else
	 		Controls.Button4Label:SetText(strButton4Text);		
	 		Controls.Button4:SetHide(false);
	 		Controls.Button4:SetToolTipString(strButton4Tooltip);
		end

		if (strButton5Text == -1) then
			Controls.Button5:SetHide(true);
		else
			Controls.Button5Label:SetText(strButton5Text);
			Controls.Button5:SetHide(false);
			Controls.Button5:SetToolTipString(strButton5Tooltip);
		end	

		if (strButton6Text == -1) then
			Controls.Button6:SetHide(true);
		else
			Controls.Button6Label:SetText(strButton6Text);
			Controls.Button6:SetHide(false);
			Controls.Button6:SetToolTipString(strButton6Tooltip);
		end

		if (strButton7Text == -1) then
			Controls.Button7:SetHide(true);
		else
			Controls.Button7Label:SetText(strButton7Text);
			Controls.Button7:SetHide(false);
			Controls.Button7:SetToolTipString(strButton7Tooltip);
		end

		if (strButton8Text == -1) then
			Controls.Button8:SetHide(true);
		else
			Controls.Button8Label:SetText(strButton8Text);
			Controls.Button8:SetHide(false);
			Controls.Button8:SetToolTipString(strButton8Tooltip);
		end
		
		if (strButton9Text == -1) then
			Controls.Button9:SetHide(true);
		else
			Controls.Button9Label:SetText(strButton9Text);
			Controls.Button9:SetHide(false);
			Controls.Button9:SetToolTipString(strButton9Tooltip);
		end
		
		if (strButton10Text == -1) then
			Controls.Button10:SetHide(true);
		else
			Controls.Button10Label:SetText(strButton10Text);
			Controls.Button10:SetHide(false);
			Controls.Button10:SetToolTipString(strButton10Tooltip);
		end
		
		if (strButton11Text == -1) then
			Controls.Button11:SetHide(true);
		else
			Controls.Button11Label:SetText(strButton11Text);
			Controls.Button11:SetHide(false);
			Controls.Button11:SetToolTipString(strButton11Tooltip);
		end
		
		if (bHideBackButton) then
	 		Controls.BackButton:SetHide(true);
	 		g_bCanGoBack = false;
		else
	 		Controls.BackButton:SetHide(false);
	 		g_bCanGoBack = true;
		end
		
	end
    
end
Events.AILeaderMessage.Add( LeaderMessageHandler );


----------------------------------------------------------------
-- BACK
----------------------------------------------------------------
function OnBack(bForce)
    
    if (g_bCanGoBack or bForce) then
		
	    UIManager:DequeuePopup( ContextPtr );
		Controls.LeaderPanel:SetHide( true );
	    
    	UI.RequestLeaveLeader();
	end

end
Controls.BackButton:RegisterCallback( Mouse.eLClick, OnBack );


----------------------------------------------------------------    
-- SHOW/HIDE
----------------------------------------------------------------    
local bEverShown = false;
function OnShowHide( bHide, bIsInit )
	
	if( not bIsInit ) then
    	-- Showing Screen
    	if (not bHide) then
    		oldCursor = UIManager:SetUICursor(0);
    		
    		bEverShown = true;
    	    
    		local pPlayer = Players[Game.GetActivePlayer()];
    		local pTeam = Teams[pPlayer:GetTeam()];
    		
    		local pThirdPartyPlayer;
    		local iThirdPartyTeam;
    		
    		--------------------------------------------------------------------------
    		-- THE CODE AFTER THIS LINE SHOULD BE REWRITTEN - IT IS OBSOLETE
    		--------------------------------------------------------------------------
    		
    		local iNumPlayers = 0;
    		
    		for iPlayerLoop = 0, GameDefines.MAX_MAJOR_CIVS-1, 1 do
    			
    			pThirdPartyPlayer = Players[iPlayerLoop];
    			iThirdPartyTeam = pThirdPartyPlayer:GetTeam();
    			
    			if (pPlayer:GetTeam() ~= iThirdPartyTeam and pThirdPartyPlayer:IsAlive()) then
    				
    					if (pTeam:IsHasMet(iThirdPartyTeam)) then
    						iNumPlayers = iNumPlayers + 1;
    					end
    			end
    		end
    		
    	-- Hiding Screen
    	else
    		UIManager:SetUICursor(oldCursor);
    		
    		g_bCanGoBack	= true;		
    		g_DiploUIState = -1;
    		g_iDiploData = -1;
    		
    		g_iInvokedDiscussionMode = g_iModeDiscussionRoot;
    	end
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
			
			if(Controls.DenounceConfirm:IsHidden() and Controls.WarConfirm:IsHidden()) then
				-- Talk-about-a-leader mode
				if (g_iInvokedDiscussionMode ~= g_iModeDiscussionRoot) then
					OnCloseLeaderPanelButton();
					
				-- In base discussion mode
				else
					OnBack();
				end
			elseif (not Controls.DenounceConfirm:IsHidden()) then
				OnDenounceConfirmNo();
			elseif (not Controls.WarConfirm:IsHidden()) then
				OnWarConfirmNo();
			end
        end
    end
    return true;
end
ContextPtr:SetInputHandler( InputHandler );


----------------------------------------------------------------
-- BUTTON 1
----------------------------------------------------------------
function OnButton1()
    g_InstanceManager:ResetInstances();
    	
	local pPlayer = Players[Game.GetActivePlayer()];
	local pTeam = Teams[pPlayer:GetTeam()];
	
	local iButtonID = 1;
        
    -- Fluff discussion mode
	if (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_BLANK_DISCUSSION_MEAN_HUMAN) then
		OnBack(true);
    -- Fluff discussion mode 2
	elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_BLANK_DISCUSSION_MEAN_AI) then
		OnBack(true);
    -- AI declared war on us
	elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_AI_DECLARED_WAR) then
		OnBack(true);
    
    -- AI seriously warning us about expansion
	elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_AGGRESSIVE_MILITARY_WARNING) then
	    Game.DoFromUIDiploEvent( FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_AGGRESSIVE_MILITARY_WARNING_RESPONSE, g_iAIPlayer, iButtonID, 0 );
    
	elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_I_ATTACKED_YOUR_MINOR_CIV) then
		local iMinor = g_iDiploData;
	    Game.DoFromUIDiploEvent( FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_I_ATTACKED_YOUR_MINOR_CIV_RESPONSE, g_iAIPlayer, iButtonID, iMinor );

	elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_I_BULLIED_YOUR_MINOR_CIV) then
		local iMinor = g_iDiploData;
	    Game.DoFromUIDiploEvent( FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_I_BULLIED_YOUR_MINOR_CIV_RESPONSE, g_iAIPlayer, iButtonID, iMinor );

	elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_YOU_ATTACKED_MINOR_CIV) then
	    Game.DoFromUIDiploEvent( FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_ATTACKED_MINOR_RESPONSE, g_iAIPlayer, iButtonID, 0 );
    
	elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_YOU_BULLIED_MINOR_CIV) then
	    Game.DoFromUIDiploEvent( FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_BULLIED_MINOR_RESPONSE, g_iAIPlayer, iButtonID, 0 );

    -- AI warning us about expansion
	elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_YOU_EXPANSION_WARNING) then
	    Game.DoFromUIDiploEvent( FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_EXPANSION_WARNING_RESPONSE, g_iAIPlayer, iButtonID, 0 );
    
    -- AI warning us about plot buying
	elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_YOU_PLOT_BUYING_WARNING) then
	    Game.DoFromUIDiploEvent( FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_PLOT_BUYING_WARNING_RESPONSE, g_iAIPlayer, iButtonID, 0 );
    
    -- AI asking to work together
	elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_WORK_WITH_US) then
	    Game.DoFromUIDiploEvent( FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_WORK_WITH_US_RESPONSE, g_iAIPlayer, iButtonID, 0 );
 
    -- AI asking to work against someone
	elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_WORK_AGAINST_SOMEONE) then
		local iAgainstPlayer = g_iDiploData;
	    Game.DoFromUIDiploEvent( FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_WORK_AGAINST_SOMEONE_RESPONSE, g_iAIPlayer, iButtonID, iAgainstPlayer );
        
    -- AI asking to declare war against someone
	elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_COOP_WAR) then
		local iAgainstPlayer = g_iDiploData;
	    Game.DoFromUIDiploEvent( FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_COOP_WAR_RESPONSE, g_iAIPlayer, iButtonID, iAgainstPlayer );
	    
    -- AI asking to declare war against someone NOW
	elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_COOP_WAR_TIME) then
		local iAgainstPlayer = g_iDiploData;
	    Game.DoFromUIDiploEvent( FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_COOP_WAR_NOW_RESPONSE, g_iAIPlayer, iButtonID, iAgainstPlayer );
    
	elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_PLAN_RESEARCH_AGREEMENT) then
	    Game.DoFromUIDiploEvent( FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_PLAN_RA_RESPONSE, g_iAIPlayer, iButtonID, 0 );
    
    -- AI asking to denounce another player
	elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_AI_REQUEST_DENOUNCE) then
		local iAgainstPlayer = g_iDiploData;
	    Game.DoFromUIDiploEvent( FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_AI_REQUEST_DENOUNCE_RESPONSE, g_iAIPlayer, iButtonID, iAgainstPlayer );
		
	-- AI asking to stop spying
	elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_CAUGHT_YOUR_SPY) then
		Game.DoFromUIDiploEvent( FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_CAUGHT_YOUR_SPY_RESPONSE, g_iAIPlayer, iButtonID, iAgainstPlayer);

	-- AI asking to stop spying after death
	elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_KILLED_YOUR_SPY) then
		Game.DoFromUIDiploEvent( FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_CAUGHT_YOUR_SPY_RESPONSE, g_iAIPlayer, iButtonID, iAgainstPlayer);
	
	-- AI asking to forgive for spying
	elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_KILLED_MY_SPY) then
		Game.DoFromUIDiploEvent( FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_KILLED_MY_SPY_RESPONSE, g_iAIPlayer, iButtonID, iAgainstPlayer);
	
	elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_CONFRONT_YOU_KILLED_MY_SPY) then
		Game.DoFromUIDiploEvent( FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_KILLED_MY_SPY_RESPONSE, g_iAIPlayer, 2, iAgainstPlayer);
		
	elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_STOP_CONVERSIONS) then
	   Game.DoFromUIDiploEvent( FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_STOP_CONVERSIONS, g_iAIPlayer, iButtonID, iAgainstPlayer);
	   
	elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_STOP_DIGGING) then
	   Game.DoFromUIDiploEvent( FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_STOP_DIGGING, g_iAIPlayer, iButtonID, iAgainstPlayer);
	  
	elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_AI_REVOKE_VASSALAGE) then
		Game.DoFromUIDiploEvent( FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_HUMAN_ENDS_VASSALAGE, g_iAIPlayer, iButtonID, 0 );
	
    -- Default mode - TBR
    elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DEFAULT_ROOT) then
		
		local pThirdPartyPlayer;
		local iThirdPartyTeam;
		
		local iNumPlayers = 0;
		
		for iPlayerLoop = 0, GameDefines.MAX_MAJOR_CIVS-1, 1 do
			
			pThirdPartyPlayer = Players[iPlayerLoop];
			iThirdPartyTeam = pThirdPartyPlayer:GetTeam();
			
			if (pPlayer:GetTeam() ~= iThirdPartyTeam and pThirdPartyPlayer:IsAlive()) then
				
				if (g_iAITeam ~= iThirdPartyTeam) then
					
					if (pTeam:IsHasMet(iThirdPartyTeam)) then
						iNumPlayers = iNumPlayers + 1;
						AddLeaderButton( iPlayerLoop, pThirdPartyPlayer:GetName() );
					end
				end
			end
		end

		if (iNumPlayers > 0) then
			Controls.LeaderPanel:SetHide( false );
		end
	end
	
end
Controls.Button1:RegisterCallback( Mouse.eLClick, OnButton1 );


----------------------------------------------------------------
-- BUTTON 2
----------------------------------------------------------------
function OnButton2()
    g_InstanceManager:ResetInstances();
    	
	local pPlayer = Players[Game.GetActivePlayer()];
	local pTeam = Teams[pPlayer:GetTeam()];
	
	local pAIPlayer = Players[g_iAIPlayer];
	
	local iActivePlayer = Game.GetActivePlayer();
	
	local iButtonID = 2;
        
    -- Human-invoked discussion
    if (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_HUMAN_INVOKED) then
		if (g_iInvokedDiscussionMode == g_iModeDiscussionRoot) then
			-- Share intrigue with AI player
			local iIntriguePlotter;
			local iIntrigueType;
			iIntriguePlotter, iIntrigueType = pPlayer:GetRecentIntrigueInfo(g_iAIPlayer);			
			Game.DoFromUIDiploEvent( FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_HUMAN_DISCUSSION_SHARE_INTRIGUE, g_iAIPlayer, iIntriguePlotter, iIntrigueType);
		end
		
	-- Fluff discussion mode
	elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_BLANK_DISCUSSION_MEAN_HUMAN) then
	    OnBack(true);
    -- Fluff discussion mode 2
	elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_BLANK_DISCUSSION_MEAN_AI) then
	    OnBack(true);
	elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_AI_DECLARED_WAR) then
	    OnBack(true);	
		
	elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_AGGRESSIVE_MILITARY_WARNING) then
	    Game.DoFromUIDiploEvent( FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_AGGRESSIVE_MILITARY_WARNING_RESPONSE, g_iAIPlayer, iButtonID, 0 );

	elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_I_ATTACKED_YOUR_MINOR_CIV) then
		local iMinor = g_iDiploData;
	    Game.DoFromUIDiploEvent( FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_I_ATTACKED_YOUR_MINOR_CIV_RESPONSE, g_iAIPlayer, iButtonID, iMinor );

	elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_I_BULLIED_YOUR_MINOR_CIV) then
		local iMinor = g_iDiploData;
	    Game.DoFromUIDiploEvent( FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_I_BULLIED_YOUR_MINOR_CIV_RESPONSE, g_iAIPlayer, iButtonID, iMinor );
    
	elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_YOU_ATTACKED_MINOR_CIV) then
	    Game.DoFromUIDiploEvent( FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_ATTACKED_MINOR_RESPONSE, g_iAIPlayer, iButtonID, 0 );
    
	elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_YOU_BULLIED_MINOR_CIV) then
	    Game.DoFromUIDiploEvent( FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_BULLIED_MINOR_RESPONSE, g_iAIPlayer, iButtonID, 0 );

    -- AI warning us about expansion
	elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_YOU_EXPANSION_WARNING) then
	    Game.DoFromUIDiploEvent( FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_EXPANSION_WARNING_RESPONSE, g_iAIPlayer, iButtonID, 0 );
    
    -- AI warning us about plot buying
	elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_YOU_PLOT_BUYING_WARNING) then
	    Game.DoFromUIDiploEvent( FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_PLOT_BUYING_WARNING_RESPONSE, g_iAIPlayer, iButtonID, 0 );
    
    -- AI asking to work with us
	elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_WORK_WITH_US) then
	    Game.DoFromUIDiploEvent( FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_WORK_WITH_US_RESPONSE, g_iAIPlayer, iButtonID, 0 );
		
    -- AI asking to work against someone
	elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_WORK_AGAINST_SOMEONE) then
		local iAgainstPlayer = g_iDiploData;
	    Game.DoFromUIDiploEvent( FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_WORK_AGAINST_SOMEONE_RESPONSE, g_iAIPlayer, iButtonID, iAgainstPlayer );
        
    -- AI asking to declare war against someone
	elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_COOP_WAR) then
		local iAgainstPlayer = g_iDiploData;
	    Game.DoFromUIDiploEvent( FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_COOP_WAR_RESPONSE, g_iAIPlayer, iButtonID, iAgainstPlayer );
    
    -- AI asking to declare war against someone NOW
	elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_COOP_WAR_TIME) then
		local iAgainstPlayer = g_iDiploData;
	    Game.DoFromUIDiploEvent( FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_COOP_WAR_NOW_RESPONSE, g_iAIPlayer, iButtonID, iAgainstPlayer );
    
	elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_PLAN_RESEARCH_AGREEMENT) then
	    Game.DoFromUIDiploEvent( FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_PLAN_RA_RESPONSE, g_iAIPlayer, iButtonID, 0 );
    
    -- AI asking to denounce another player
	elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_AI_REQUEST_DENOUNCE) then
		local iAgainstPlayer = g_iDiploData;
	    Game.DoFromUIDiploEvent( FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_AI_REQUEST_DENOUNCE_RESPONSE, g_iAIPlayer, iButtonID, iAgainstPlayer );
		
	-- AI asking to stop spying
	elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_CAUGHT_YOUR_SPY) then
		Game.DoFromUIDiploEvent( FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_CAUGHT_YOUR_SPY_RESPONSE, g_iAIPlayer, iButtonID, iAgainstPlayer);
		
	-- AI asking to stop spying after death
	elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_KILLED_YOUR_SPY) then
		Game.DoFromUIDiploEvent( FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_CAUGHT_YOUR_SPY_RESPONSE, g_iAIPlayer, iButtonID, iAgainstPlayer);

	-- AI asking to forgive for spying
	elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_KILLED_MY_SPY) then
		Game.DoFromUIDiploEvent( FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_KILLED_MY_SPY_RESPONSE, g_iAIPlayer, iButtonID, iAgainstPlayer);

	elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_CONFRONT_YOU_KILLED_MY_SPY) then
		if (g_iInvokedDiscussionMode == g_iModeDiscussionRoot) then
			Game.DoFromUIDiploEvent( FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_HUMAN_DISCUSSION_STOP_SPYING, g_iAIPlayer, 1, 0 );
		end
				
	elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_STOP_CONVERSIONS) then
	   Game.DoFromUIDiploEvent( FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_STOP_CONVERSIONS, g_iAIPlayer, iButtonID, iAgainstPlayer);

	elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_STOP_DIGGING) then
	   Game.DoFromUIDiploEvent( FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_STOP_DIGGING, g_iAIPlayer, iButtonID, iAgainstPlayer);

	elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_AI_REVOKE_VASSALAGE) then
		Game.DoFromUIDiploEvent( FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_HUMAN_ENDS_VASSALAGE, g_iAIPlayer, iButtonID, 0 );

    -- Default mode
    elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DEFAULT_ROOT) then
		
	end
	
end
Controls.Button2:RegisterCallback( Mouse.eLClick, OnButton2 );


----------------------------------------------------------------
-- BUTTON 3
----------------------------------------------------------------
function OnButton3()
    g_InstanceManager:ResetInstances();
    
	local pPlayer = Players[Game.GetActivePlayer()];
	local pTeam = Teams[pPlayer:GetTeam()];
	
	local pAIPlayer = Players[g_iAIPlayer];
	
	local iButtonID = 3;
	
	if (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_HUMAN_INVOKED) then
		if (g_iInvokedDiscussionMode == g_iModeDiscussionRoot) then
			Game.DoFromUIDiploEvent( FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_HUMAN_DISCUSSION_STOP_SPYING, g_iAIPlayer, 0, 0 );
		end
		
    -- AI asking to work against someone
	elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_WORK_AGAINST_SOMEONE) then
		local iAgainstPlayer = g_iDiploData;
	    Game.DoFromUIDiploEvent( FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_WORK_AGAINST_SOMEONE_RESPONSE, g_iAIPlayer, iButtonID, iAgainstPlayer );
    
    -- AI asking to declare war against someone
	elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_COOP_WAR) then
		local iAgainstPlayer = g_iDiploData;
	    Game.DoFromUIDiploEvent( FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_COOP_WAR_RESPONSE, g_iAIPlayer, iButtonID, iAgainstPlayer );
	    
	elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_CONFRONT_YOU_KILLED_MY_SPY) then
		-- Discussion Root Mode
		if (g_iInvokedDiscussionMode == g_iModeDiscussionRoot) then
			local name;
			if(pAIPlayer:GetNickName() ~= "" and pAIPlayer:IsHuman()) then
				name = pAIPlayer:GetNickName();
			else
				name = pAIPlayer:GetName();		    
			end
			
			Controls.DenounceLabel:LocalizeAndSetText("TXT_KEY_CONFIRM_DENOUNCE", name);
			
			Controls.DenounceConfirm:SetHide(false);
		end

    -- Default mode
    elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DEFAULT_ROOT) then
		
	end
	
end
Controls.Button3:RegisterCallback( Mouse.eLClick, OnButton3 );


----------------------------------------------------------------
-- BUTTON 4
----------------------------------------------------------------
function OnButton4()
    g_InstanceManager:ResetInstances();
    	
	local pPlayer = Players[Game.GetActivePlayer()];
	local pTeam = Teams[pPlayer:GetTeam()];
	local pAIPlayer = Players[g_iAIPlayer];
	
	local iButtonID = 4;
	
	if (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_HUMAN_INVOKED) then
		if (g_iInvokedDiscussionMode == g_iModeDiscussionRoot) then
			Game.DoFromUIDiploEvent( FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_HUMAN_DISCUSSION_STOP_SPREADING_RELIGION, g_iAIPlayer, 0, 0 );
		end
        
    -- AI asking to declare war against someone
	elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_COOP_WAR) then
		local iAgainstPlayer = g_iDiploData;
	    Game.DoFromUIDiploEvent( FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_COOP_WAR_RESPONSE, g_iAIPlayer, iButtonID, iAgainstPlayer );
	
	elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_CONFRONT_YOU_KILLED_MY_SPY) then
		-- Discussion Root Mode
		if (g_iInvokedDiscussionMode == g_iModeDiscussionRoot) then
			Controls.WarConfirm:SetHide(false);
		end
	
    -- Default mode
    elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DEFAULT_ROOT) then
		
	end
	
end
Controls.Button4:RegisterCallback( Mouse.eLClick, OnButton4 );

----------------------------------------------------------------
-- BUTTON 5
----------------------------------------------------------------
function OnButton5()
    g_InstanceManager:ResetInstances();
    	
	local pPlayer = Players[Game.GetActivePlayer()];
	local pTeam = Teams[pPlayer:GetTeam()];
	local pAIPlayer = Players[g_iAIPlayer];
	
	local iButtonID = 5;
	
	if (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_HUMAN_INVOKED) then
		if (g_iInvokedDiscussionMode == g_iModeDiscussionRoot) then
			Game.DoFromUIDiploEvent( FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_HUMAN_DISCUSSION_DONT_SETTLE, g_iAIPlayer, 0, 0 );
		end
        
    -- AI asking to work against someone
	elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_WORK_AGAINST_SOMEONE) then
		local iAgainstPlayer = g_iDiploData;
	    Game.DoFromUIDiploEvent( FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_WORK_AGAINST_SOMEONE_RESPONSE, g_iAIPlayer, iButtonID, iAgainstPlayer );
    
    -- AI asking to declare war against someone
	elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_COOP_WAR) then
		local iAgainstPlayer = g_iDiploData;
	    Game.DoFromUIDiploEvent( FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_COOP_WAR_RESPONSE, g_iAIPlayer, iButtonID, iAgainstPlayer );
	    
    -- Default mode
    elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DEFAULT_ROOT) then
		
	end
	
end
Controls.Button5:RegisterCallback( Mouse.eLClick, OnButton5 );

----------------------------------------------------------------
-- BUTTON 6
----------------------------------------------------------------
function OnButton6()
    g_InstanceManager:ResetInstances();
    	
	local pPlayer = Players[Game.GetActivePlayer()];
	local pTeam = Teams[pPlayer:GetTeam()];
	local pAIPlayer = Players[g_iAIPlayer];

	local iButtonID = 6;

	if (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_HUMAN_INVOKED) then
		
		-- Discussion Root Mode
		if (g_iInvokedDiscussionMode == g_iModeDiscussionRoot) then
			if (g_iInvokedDiscussionMode == g_iModeDiscussionRoot) then
				Game.DoFromUIDiploEvent( FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_HUMAN_DISCUSSION_STOP_DIGGING, g_iAIPlayer, 0, 0 );
			end
		end
    -- Default mode
    elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DEFAULT_ROOT) then
	
	end	
end
Controls.Button6:RegisterCallback( Mouse.eLClick, OnButton6 );

----------------------------------------------------------------
-- BUTTON 7
----------------------------------------------------------------
function OnButton7()
	g_InstanceManager:ResetInstances();

	local pPlayer = Players[Game.GetActivePlayer()];
	local pAIPlayer = Players[g_iAIPlayer];
	local pTeam = Teams[pPlayer:GetTeam()];
	local iActivePlayer = Game.GetActivePlayer();
	
	local iButtonID = 7;
	if (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_HUMAN_INVOKED) then
		-- Discussion Root Mode
		if (g_iInvokedDiscussionMode == g_iModeDiscussionRoot) then
			if (not pAIPlayer:IsDoF(iActivePlayer)) then
				Game.DoFromUIDiploEvent( FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_HUMAN_DISCUSSION_WORK_WITH_US, g_iAIPlayer, 0, 0 );
			end
		end
	elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DEFAULT_ROOT) then
	end
end
Controls.Button7:RegisterCallback( Mouse.eLClick, OnButton7 );

----------------------------------------------------------------
-- BUTTON 8
----------------------------------------------------------------
function OnButton8()
	g_InstanceManager:ResetInstances();

	local pPlayer = Players[Game.GetActivePlayer()];
	local pTeam = Teams[pPlayer:GetTeam()];
	
	local iButtonID = 8;
	if (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_HUMAN_INVOKED) then
		-- Discussion Root Mode
		if (g_iInvokedDiscussionMode == g_iModeDiscussionRoot) then
			local pAIPlayer = Players[g_iAIPlayer];
			local name;
			if(pAIPlayer:GetNickName() ~= "" and pAIPlayer:IsHuman()) then
				name = pAIPlayer:GetNickName();
			else
				name = pAIPlayer:GetName();		    
			end
			
			Controls.DenounceLabel:LocalizeAndSetText("TXT_KEY_CONFIRM_DENOUNCE", name);
			
			Controls.DenounceConfirm:SetHide(false);
		end
	elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DEFAULT_ROOT) then
	end
end
Controls.Button8:RegisterCallback( Mouse.eLClick, OnButton8 );

----------------------------------------------------------------
-- BUTTON 9
----------------------------------------------------------------
function OnButton9()
	g_InstanceManager:ResetInstances();

	local pPlayer = Players[Game.GetActivePlayer()];
	local pTeam = Teams[pPlayer:GetTeam()];
	
	local iButtonID = 9;
	if (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_HUMAN_INVOKED) then
		-- Discussion Root Mode
		if (g_iInvokedDiscussionMode == g_iModeDiscussionRoot) then
			Game.DoFromUIDiploEvent( FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_HUMAN_MOVE_TROOPS_RESPONSE, g_iAIPlayer, 0, 0 );
		end
	elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DEFAULT_ROOT) then
	end
end
Controls.Button9:RegisterCallback( Mouse.eLClick, OnButton9);
----------------------------------------------------------------
-- BUTTON 10
----------------------------------------------------------------
function OnButton10()
	g_InstanceManager:ResetInstances();

	local pPlayer = Players[Game.GetActivePlayer()];
	local pTeam = Teams[pPlayer:GetTeam()];
	
	local iButtonID = 10;
	if (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_HUMAN_INVOKED) then
		-- Discussion Root Mode
		if (g_iInvokedDiscussionMode == g_iModeDiscussionRoot) then
			g_iInvokedDiscussionMode = g_iModeDiscussionWar
			OpenLeadersPanel()
		end
	elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DEFAULT_ROOT) then
	end
end
Controls.Button10:RegisterCallback( Mouse.eLClick, OnButton10);
----------------------------------------------------------------
-- BUTTON 11
----------------------------------------------------------------
function OnButton11()
	g_InstanceManager:ResetInstances();
    	
	local pPlayer = Players[Game.GetActivePlayer()];
	local pTeam = Teams[pPlayer:GetTeam()];
	local pAIPlayer = Players[g_iAIPlayer];
	local pAITeam = Teams[pAIPlayer:GetTeam()];

	local iButtonID = 11;

	if (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DISCUSS_HUMAN_INVOKED) then
		-- Discussion Root Mode
		if (g_iInvokedDiscussionMode == g_iModeDiscussionRoot) then
			g_iInvokedDiscussionMode = g_iModeDiscussionShareOpinion
			OpenLeadersPanel()
		end
    -- Default mode
    elseif (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DEFAULT_ROOT) then
		
	end	 
end
Controls.Button11:RegisterCallback( Mouse.eLClick, OnButton11 );
function OpenLeadersPanel()
	
	local iNumPlayers = 0;
	
	for iPlayerLoop = 0, GameDefines.MAX_MAJOR_CIVS-1, 1 do

		-- War mode
		if (g_iInvokedDiscussionMode == g_iModeDiscussionWar and IsWarAgainstThirdPartyPlayerValid(iPlayerLoop)) then
			iNumPlayers = iNumPlayers + 1;
			AddLeaderButton( iPlayerLoop, Players[iPlayerLoop]:GetName() );
		end
		
		-- Share Opinion mode
		if (g_iInvokedDiscussionMode == g_iModeDiscussionShareOpinion and IsShareOpinionOnThirdPartyPlayerValid(iPlayerLoop)) then
			iNumPlayers = iNumPlayers + 1;
			AddLeaderButton( iPlayerLoop, Players[iPlayerLoop]:GetName() );
		end
	end

	if (iNumPlayers > 0) then
		Controls.LeaderStack:CalculateSize();
		Controls.LeaderStack:ReprocessAnchoring();
		Controls.LeaderScrollPanel:CalculateInternalSize();
		
		Controls.LeaderPanel:SetHide( false );

		-- Disable normal buttons
 		Controls.Button1:SetDisabled(true);
 		Controls.Button2:SetDisabled(true);
 		Controls.Button3:SetDisabled(true);
 		Controls.Button4:SetDisabled(true);
 		Controls.Button5:SetDisabled(true);
 		Controls.Button6:SetDisabled(true);
 		Controls.Button7:SetDisabled(true);
 		Controls.Button8:SetDisabled(true);
 		Controls.Button9:SetDisabled(true);
 		Controls.Button10:SetDisabled(true);
 		Controls.Button11:SetDisabled(true);
	end
end

function IsThirdPartyPlayerValid(iThirdPartyPlayer)

	local pActivePlayer = Players[Game.GetActivePlayer()];
	local pActiveTeam = Teams[pActivePlayer:GetTeam()];
	
	local pThirdPartyPlayer = Players[iThirdPartyPlayer];
	local iThirdPartyTeam = pThirdPartyPlayer:GetTeam();
	
	if (pActivePlayer:GetTeam() == iThirdPartyTeam) then
		return false;
	end
	
	if (not pThirdPartyPlayer:IsAlive()) then
		return false;
	end
	
	if (g_iAITeam == iThirdPartyTeam) then
		return false;
	end
	
	if (not pActiveTeam:IsHasMet(iThirdPartyTeam)) then
		return false;
	end
	
	if (not Teams[g_iAITeam]:IsHasMet(iThirdPartyTeam)) then
		return false;
	end
	
	return true;
	
end

function IsWarAgainstThirdPartyPlayerValid(iThirdPartyPlayer)
	
	if (not IsThirdPartyPlayerValid(iThirdPartyPlayer)) then
		return false;
	end
	
	local pActivePlayer = Players[Game.GetActivePlayer()];

	local iCoopState = Players[g_iAIPlayer]:GetCoopWarAcceptedState(pActivePlayer:GetID(), iThirdPartyPlayer);
	if (iCoopState == CoopWarStates.COOP_WAR_STATE_ACCEPTED or iCoopState == CoopWarStates.COOP_WAR_STATE_SOON) then
		return false;
	end

	local pAIPlayerTeam = Teams[Players[g_iAIPlayer]:GetTeam()];
	local iThirdPartyTeamID = Players[iThirdPartyPlayer]:GetTeam();
	if (not pAIPlayerTeam:CanDeclareWar(iThirdPartyTeamID)) then
		return false;
	end

	return true;
end

function IsShareOpinionOnThirdPartyPlayerValid(iThirdPartyPlayer)
	if (not IsThirdPartyPlayerValid(iThirdPartyPlayer)) then
		return false;
	end

	return true;
end

function AddLeaderButton( iLeaderId, sLeaderName )
    instanceControls = g_InstanceManager:GetInstance();
    instanceControls.Button:SetVoid1( iLeaderId );
    instanceControls.LeaderButtonLabel:SetText( sLeaderName );
    instanceControls.Button:RegisterCallback( Mouse.eLClick, OnLeaderSelect );
end

function OnCloseLeaderPanelButton()
	g_iInvokedDiscussionMode = g_iModeDiscussionRoot;
	
	-- Re-enable normal buttons
	Controls.Button1:SetDisabled(false);
	Controls.Button2:SetDisabled(false);
	Controls.Button3:SetDisabled(false);
	Controls.Button4:SetDisabled(false);
	Controls.Button5:SetDisabled(false);
	Controls.Button6:SetDisabled(false);
	Controls.Button7:SetDisabled(false);
	Controls.Button8:SetDisabled(false);
	Controls.Button9:SetDisabled(false);
	Controls.Button10:SetDisabled(true);
	Controls.Button11:SetDisabled(true);

	local pAIPlayer = Players[g_iAIPlayer];
	local iActivePlayer = Game.GetActivePlayer();
	local pActiveTeam = Teams[Game.GetActiveTeam()];

	for iPlayerLoop = 0, GameDefines.MAX_MAJOR_CIVS-1, 1 do

		if (pAIPlayer:IsDoF(iActivePlayer) or pAIPlayer:GetTeam() == Players[iActivePlayer]:GetTeam()) then
			if (IsWarAgainstThirdPartyPlayerValid(iPlayerLoop) and not pActiveTeam:IsAtWar(g_iAITeam)) then
				Controls.Button10:SetDisabled(false);
			end
		end

		-- Share Opinion button: Button 11
		if (g_bDiscussionRequests and IsShareOpinionOnThirdPartyPlayerValid(iPlayerLoop)) then
			Controls.Button11:SetDisabled(false);
		end
	end
	
    Controls.LeaderPanel:SetHide( true );
end
Controls.CloseLeaderPanelButton:RegisterCallback( Mouse.eLClick, OnCloseLeaderPanelButton );

function OnLeaderSelect( iLeaderId )
    g_CurrentTopic = iLeaderId;
    
    Controls.LeaderPanel:SetHide( true );
    
    -- War discussion mode
	if (g_iInvokedDiscussionMode == g_iModeDiscussionWar) then
	    Game.DoFromUIDiploEvent( FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_COOP_WAR_OFFER, g_iAIPlayer, iLeaderId, -1 );
	end

	-- Sharing opinion mode
	if (g_iInvokedDiscussionMode == g_iModeDiscussionShareOpinion and FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_HUMAN_DISCUSSION_SHARE_OPINION ~= nil) then
	    Game.DoFromUIDiploEvent( FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_HUMAN_DISCUSSION_SHARE_OPINION, g_iAIPlayer, iLeaderId, -1 );
	end
	
end


function OnLeavingLeader()
    UIManager:DequeuePopup( ContextPtr );
end
Events.LeavingLeaderViewMode.Add( OnLeavingLeader );

function OnDenonceConfirmYes( )
	Controls.DenounceConfirm:SetHide(true);

	Game.DoFromUIDiploEvent( FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_DENOUNCE, g_iAIPlayer, 0, 0 );				
end
Controls.DenounceConfirmYes:RegisterCallback( Mouse.eLClick, OnDenonceConfirmYes );

function OnDenounceConfirmNo( )
	Controls.DenounceConfirm:SetHide(true);
end
Controls.DenounceConfirmNo:RegisterCallback( Mouse.eLClick, OnDenounceConfirmNo );

function OnWarConfirmYes( )
	Controls.WarConfirm:SetHide(true);
	
	Game.DoFromUIDiploEvent( FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_HUMAN_DECLARES_WAR, g_iAIPlayer, 1, 0);
end
Controls.WarConfirmYes:RegisterCallback( Mouse.eLClick, OnWarConfirmYes );

function OnWarConfirmNo( )
	Controls.WarConfirm:SetHide(true);
end
Controls.WarConfirmNo:RegisterCallback( Mouse.eLClick, OnWarConfirmNo );
