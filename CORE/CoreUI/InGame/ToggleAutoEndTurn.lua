-------------------------------------------------
-- Toggle Auto End Turn
-------------------------------------------------

local g_UserData = Modding.OpenUserData("GAIA_UIOptions", 1)
if not g_UserData then
	MapModData.GAIA_UIOptions = MapModData.GAIA_UIOptions or {}
	local t = MapModData.GAIA_UIOptions
	g_UserData = { GetValue = function(k) return t[k] end, SetValue = function(k, v) t[k] = v end }
end

local function IsButtonEnabled()
	return g_UserData.GetValue("AutoEndTurnButton") ~= 0
end

local function GetAutoEndTurnEnabled()
	if OptionsManager.GetSinglePlayerAutoEndTurnEnabled ~= nil then
		return OptionsManager.GetSinglePlayerAutoEndTurnEnabled();
	end
	OptionsManager.SyncGameOptionsCache();
	return OptionsManager.GetSinglePlayerAutoEndTurnEnabled_Cached();
end

local function UpdateDisplay()
	local bEnabled = GetAutoEndTurnEnabled();

	Controls.TurnIcon:SetAlpha( bEnabled and 0.35 or 1.0 );

	Controls.ToggleAETButton:SetToolTipString(
		"[COLOR_YELLOW]" .. Locale.ConvertTextKey( "TXT_KEY_OPSCREEN_SPLAYER_AUTO_END_TURN" ) .. "[ENDCOLOR]"
		.. "[NEWLINE]" .. Locale.ConvertTextKey( bEnabled and "TXT_KEY_GAIA_TAET_STATE_ON" or "TXT_KEY_GAIA_TAET_STATE_OFF" )
		.. "[NEWLINE][NEWLINE]" .. Locale.ConvertTextKey( "TXT_KEY_OPSCREEN_SPLAYER_AUTO_END_TURN_TT" )
		.. "[NEWLINE][NEWLINE]" .. Locale.ConvertTextKey( "TXT_KEY_GAIA_TAET_HIDE_HINT" ) );
end

local function OnToggleClicked()
	OptionsManager.SyncGameOptionsCache();
	OptionsManager.SetSinglePlayerAutoEndTurnEnabled_Cached( not GetAutoEndTurnEnabled() );
	OptionsManager.CommitGameOptions();
	UpdateDisplay();
end
Controls.ToggleAETButton:RegisterCallback( Mouse.eLClick, OnToggleClicked );

Events.GameOptionsChanged.Add( UpdateDisplay );

local pActionInfoPanel = ContextPtr:LookUpControl( "/InGame/WorldView/ActionInfoPanel" );
if pActionInfoPanel ~= nil then
	Controls.ToggleAETButton:ChangeParent( pActionInfoPanel );
else
	Events.SerialEventEnterCityScreen.Add( function() ContextPtr:SetHide( true ); end );
	Events.SerialEventExitCityScreen.Add( function() ContextPtr:SetHide( false ); end );
end

local g_bBulkHidden = false;

local function UpdateButtonVisibility()
	Controls.ToggleAETButton:SetHide( g_bBulkHidden or not IsButtonEnabled() );
end
LuaEvents.GaiaAutoEndTurnButtonChanged.Add( UpdateButtonVisibility );

Events.SystemUpdateUI.Add( function( eType )
	if eType == SystemUpdateUIType.BulkHideUI then
		g_bBulkHidden = true;
	elseif eType == SystemUpdateUIType.BulkShowUI then
		g_bBulkHidden = false;
	else
		return;
	end
	UpdateButtonVisibility();
end );

Controls.TurnIcon:SetText( "[ICON_TURNS_REMAINING]" );
UpdateDisplay();
UpdateButtonVisibility();
