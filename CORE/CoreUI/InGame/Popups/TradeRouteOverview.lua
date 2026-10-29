-------------------------------------------------
-- Trade Route Overview
-------------------------------------------------
include( "IconSupport" );
include( "InstanceManager" );
include( "TradeRouteHelpers" );

local g_PopupInfo = nil;

-------------------------------------------------
-- Global Variables
-------------------------------------------------
g_CurrentTab = nil;

-------------------------------------------------
-- Global Constants
-------------------------------------------------
g_Tabs = {
	["YourTR"] = {
		SelectHighlight = Controls.YourTRSelectHighlight,
	},
	
	["AvailableTR"] = {
		SelectHighlight = Controls.AvailableTRSelectHighlight,
	},
	
	["TRWithYou"] = {
		SelectHighlight = Controls.TRWithYouSelectHighlight,
	},
}

g_SortOptions = {
	{
		Button = Controls.Domain,
		Column = "Domain",
		DefaultDirection = "asc",
		CurrentDirection = nil,
		SortType = "numeric",
	},
	{
		Button = Controls.FromOwnerHeader,
		Column = "FromCiv",
		SecondaryColumn = "FromCityName",
		SecondaryDirection = "asc",
		DefaultDirection = "asc",
		CurrentDirection = nil,
	},
	{
		Button = Controls.FromCityHeader,
		Column = "FromCityName",
		DefaultDirection = "asc",
		CurrentDirection = "asc",
	},
	{
		Button = Controls.ToOwnerHeader,
		Column = "ToCiv",
		SecondaryColumn = "ToCityName",
		SecondaryDirection = "asc",
		DefaultDirection = "asc",
		CurrentDirection = nil,
	},
	{
		Button = Controls.ToCityHeader,
		Column = "ToCityName",
		DefaultDirection = "asc",
		CurrentDirection = nil,
	},
	{
		Button = Controls.FromGPT,
		Column = "FromGPT",
		DefaultDirection = "desc",
		CurrentDirection = nil,
		SortType = "numeric",
	},
	{
		Button = Controls.ToGPT,
		Column = "ToGPT",
		DefaultDirection = "desc",
		CurrentDirection = nil,
		SortType = "numeric",
	},
	{
		Button = Controls.ToFood,
		Column = "ToFood",
		DefaultDirection = "desc",
		CurrentDirection = nil,
		SortType = "numeric",
	},
	{
		Button = Controls.ToProduction,
		Column = "ToProduction",
		DefaultDirection = "desc",
		CurrentDirection = nil,
		SortType = "numeric",
	},
	{
		Button = Controls.FromReligion,
		Column = "FromReligion",
		DefaultDirection = "desc",
		CurrentDirection = nil,
		SortType = "numeric",
	},
	{
		Button = Controls.ToReligion,
		Column = "ToReligion",
		DefaultDirection = "desc",
		CurrentDirection = nil,
		SortType = "numeric",
	},
	{
		Button = Controls.FromScience,
		Column = "FromScience",
		DefaultDirection = "desc",
		CurrentDirection = nil,
		SortType = "numeric",
	},
	{
		Button = Controls.ToScience,
		Column = "ToScience",
		DefaultDirection = "desc",
		CurrentDirection = nil,
		SortType = "numeric",
	},
	{
		Button = Controls.TurnsLeft,
		Column = "TurnsLeft",
		DefaultDirection = "asc",
		CurrentDirection = nil,
		SortType = "numeric",
	},
};

g_SortFunction = nil;

-------------------------------------------------------------------------------
-- Sorting Support
-------------------------------------------------------------------------------
function AlphabeticalSortFunction(field, direction, secondarySort)
	if(direction == "asc") then
		return function(a,b)
			local va = (a ~= nil and a[field] ~= nil) and a[field] or "";
			local vb = (b ~= nil and b[field] ~= nil) and b[field] or "";
			
			if(secondarySort ~= nil and va == vb) then
				return secondarySort(a,b);
			else
				return Locale.Compare(va, vb) == -1;
			end
		end
	elseif(direction == "desc") then
		return function(a,b)
			local va = (a ~= nil and a[field] ~= nil) and a[field] or "";
			local vb = (b ~= nil and b[field] ~= nil) and b[field] or "";
			
			if(secondarySort ~= nil and va == vb) then
				return secondarySort(a,b);
			else
				return Locale.Compare(va, vb) == 1;
			end
		end
	end
end

function NumericSortFunction(field, direction, secondarySort)
	if(direction == "asc") then
		return function(a,b)
			local va = (a ~= nil and a[field] ~= nil) and a[field] or -1;
			local vb = (b ~= nil and b[field] ~= nil) and b[field] or -1;
			
			if(secondarySort ~= nil and tonumber(va) == tonumber(vb)) then
				return secondarySort(a,b);
			else
				return tonumber(va) < tonumber(vb);
			end
		end
	elseif(direction == "desc") then
		return function(a,b)
			local va = (a ~= nil and a[field] ~= nil) and a[field] or -1;
			local vb = (b ~= nil and b[field] ~= nil) and b[field] or -1;

			if(secondarySort ~= nil and tonumber(va) == tonumber(vb)) then
				return secondarySort(a,b);
			else
				return tonumber(vb) < tonumber(va);
			end
		end
	end
end

function RegisterSortOptions()
	
	for i,v in ipairs(g_SortOptions) do
		if(v.Button ~= nil) then
			v.Button:RegisterCallback(Mouse.eLClick, function() SortOptionSelected(v); end);
		end
	end
	
	g_SortFunction = GetSortFunction(g_SortOptions);
end

function GetSortFunction(sortOptions)
	local orderBy = nil;
	for i,v in ipairs(sortOptions) do
		if(v.CurrentDirection ~= nil) then
			local secondarySort = nil;
			if(v.SecondaryColumn ~= nil) then
				if(v.SecondarySortType == "numeric") then
					secondarySort = NumericSortFunction(v.SecondaryColumn, v.SecondaryDirection)
				else
					secondarySort = AlphabeticalSortFunction(v.SecondaryColumn, v.SecondaryDirection);
				end
			end
		
			if(v.SortType == "numeric") then
				return NumericSortFunction(v.Column, v.CurrentDirection, secondarySort);
			else
				return AlphabeticalSortFunction(v.Column, v.CurrentDirection, secondarySort);
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

function SortOptionSelected(option)
	local sortOptions = g_SortOptions;
	UpdateSortOptionState(sortOptions, option);
	g_SortFunction = GetSortFunction(sortOptions);
	
	SortData();
	DisplayData();
end

function OnPopupMessage(popupInfo)

	local popupType = popupInfo.Type;
	if popupType ~= ButtonPopupTypes.BUTTONPOPUP_TRADE_ROUTE_OVERVIEW then
		return;
	end
	
	g_PopupInfo = popupInfo;
	
	if (g_PopupInfo.Data2 == 1) then
		g_CurrentTab = "YourTR";
	elseif (g_PopupInfo.Data2 == 2) then
		g_CurrentTab = "AvailableTR";
	elseif (g_PopupInfo.Data2 == 3) then
		g_CurrentTab = "TRWithYou";
	end
	
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
Events.SerialEventGameMessagePopup.Add( OnPopupMessage );

function InputHandler( uiMsg, wParam, lParam )
    ----------------------------------------------------------------        
    -- Key Down Processing
    ----------------------------------------------------------------        
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


function TabSelect(tab)
	for i,v in pairs(g_Tabs) do
		local bHide = i ~= tab;
		v.SelectHighlight:SetHide(bHide);
	end
	g_CurrentTab = tab;
	g_Tabs[tab].RefreshContent();	
end
Controls.TabButtonYourTR:RegisterCallback( Mouse.eLClick, function() TabSelect("YourTR"); end);
Controls.TabButtonAvailableTR:RegisterCallback( Mouse.eLClick, function() TabSelect("AvailableTR"); end );
Controls.TabButtonTRWithYou:RegisterCallback( Mouse.eLClick, function() TabSelect("TRWithYou"); end );

function RefreshYourTR()
	local pPlayer = Players[ Game.GetActivePlayer() ];
    
	SetData(pPlayer:GetTradeRoutes());
	SortData();
	DisplayData();
	
end
g_Tabs["YourTR"].RefreshContent = RefreshYourTR;

function RefreshAvailableTR()
	local pPlayer = Players[ Game.GetActivePlayer() ];

    SetData(pPlayer:GetTradeRoutesAvailable());
	SortData();
	DisplayData();
end
g_Tabs["AvailableTR"].RefreshContent = RefreshAvailableTR;

function RefreshTRWithYou()
	local pPlayer = Players[ Game.GetActivePlayer() ];
    
    SetData(pPlayer:GetTradeRoutesToYou());
    SortData();
    DisplayData();
    
end
g_Tabs["TRWithYou"].RefreshContent = RefreshTRWithYou;


function SetData(data)
	local cityStateCiv = GameInfo.Civilizations["CIVILIZATION_MINOR"];
	local cityStateCivID = cityStateCiv and cityStateCiv.ID or -1;

	local function GetCivName(playerID)
		local civType = PreGame.GetCivilization(playerID);
		local civ = GameInfo.Civilizations[civType];
		if(civ.ID == cityStateCivID) then
			local minorCivPlayer = Players[playerID];
			local minorCivType = minorCivPlayer:GetMinorCivType();
			local minorCiv = GameInfo.MinorCivilizations[minorCivType];
		
			return Locale.Lookup(minorCiv.ShortDescription);
		else
			return Locale.Lookup(civ.Description);
		end
	end
	
	g_Data = {};
	for i,v in ipairs(data) do
		if (v.FromCity ~= nil and v.ToCity ~= nil) then
			v.FromCiv = GetCivName(v.FromID);
			v.ToCiv = GetCivName(v.ToID);
			table.insert(g_Data, v);
		end
	end
end

function SortData()
	table.sort(g_Data, g_SortFunction);
end

function round(num, idp)
  return tonumber(string.format("%." .. (idp or 0) .. "f", num))
end

function LookAtOrRecall(instance, v)
  if (v.UnitID == nil or v.FromID ~= Game.GetActivePlayer()) then return end
  local pPlayer = Players[v.FromID]
  if (pPlayer) then
    local pUnit = pPlayer:GetUnitByID(v.UnitID)
	if (pUnit) then
	  -- Recall mutates sim state locally (no net routing)
	  local bHasRecallApi = (pUnit._IsRecalledTrader and pUnit._EndTrader)
	  if (UIManager:GetControl() and bHasRecallApi and not Game.IsNetworkMultiPlayer()) then
	    if (pUnit:IsTrade() and not pUnit:_IsRecalledTrader()) then
		  pUnit:_EndTrader()
		  instance.TurnsLeft:LocalizeAndSetText("TXT_KEY_GAIA_ROUTE_OVERVIEW_RECALLED_MARK")
		end
	  end

	  UI.LookAt(pUnit:GetPlot())
  	  Events.SerialEventUnitFlagSelected(v.FromID, v.UnitID)
	end
  end
end

function DisplayData()
	Controls.MainStack:DestroyAllChildren(); 
    for i,v in ipairs(g_Data) do
        local instance = {};
		ContextPtr:BuildInstanceForControl( "TRInstance", instance, Controls.MainStack );

		instance.DomainButton:RegisterCallback(Mouse.eLClick, function() LookAtOrRecall(instance, v); end);
	
		instance.Domain_Land:SetHide(true);
		instance.Domain_Sea:SetHide(true);
		
		local strTT = BuildTradeRouteToolTipString(Players[v.FromID], v.FromCity, v.ToCity, v.Domain) or "";
		
		if (v.Domain == DomainTypes.DOMAIN_LAND) then
			instance.Domain_Land:SetHide(false);
		elseif (v.Domain == DomainTypes.DOMAIN_SEA) then
			instance.Domain_Sea:SetHide(false);
		end
		
		CivIconHookup(v.FromID, 32, instance.FromCivIcon, instance.FromCivIconBG, instance.FromCivIconShadow, false, true, instance.FromCivIconHighlight);
		
		instance.FromCivIcon:SetToolTipString(v.FromCiv);
		instance.FromCivIconBG:SetToolTipString(v.FromCiv);
		instance.FromCivIconShadow:SetToolTipString(v.FromCiv);
		instance.FromCivIconHighlight:SetToolTipString(v.FromCiv);
		instance.FromCity:SetText(v.FromCityName);
		instance.FromCity:SetToolTipString(strTT);
		
		CivIconHookup(v.ToID, 32, instance.ToCivIcon, instance.ToCivIconBG, instance.ToCivIconShadow, false, true, instance.ToCivIconHighlight);
		instance.ToCivIcon:SetToolTipString(v.ToCiv);
		instance.ToCivIconBG:SetToolTipString(v.ToCiv);
		instance.ToCivIconShadow:SetToolTipString(v.ToCiv);
		instance.ToCivIconHighlight:SetToolTipString(v.ToCiv);
		instance.ToCity:SetText(v.ToCityName);
		instance.ToCity:SetToolTipString(strTT);
		
		local strToGPT = "";
		if (v.ToGPT ~= 0) then
			strToGPT = Locale.ConvertTextKey("TXT_KEY_TRO_GPT_ENTRY",  v.ToGPT / 100);
			instance.ToGPT:SetToolTipString(strTT);	
		end
		instance.ToGPT:SetText(strToGPT);

		local strFromGPT = "";		
		if (v.FromGPT ~= 0) then
			strFromGPT = Locale.ConvertTextKey("TXT_KEY_TRO_GPT_ENTRY",  v.FromGPT / 100);
			instance.FromGPT:SetToolTipString(strTT);	
		end
		instance.FromGPT:SetText(strFromGPT);
		
		local strToFood = "";
		if (v.ToFood ~= 0) then
			strToFood = round(v.ToFood / 100, 1);
			instance.ToFood:SetToolTipString(strTT);	
		end
		instance.ToFood:SetText(strToFood);
		
		local strToProduction = "";
		if (v.ToProduction ~= 0) then
			strToProduction = round(v.ToProduction / 100, 1);
			instance.ToProduction:SetToolTipString(strTT);	
		end
		instance.ToProduction:SetText(strToProduction);
		
		local strToPressure = "";
		if (v.ToReligion > 0 and v.ToPressure ~= 0) then
			local religion = GameInfo.Religions[v.ToReligion];
			local strIcon = religion.IconString;
			strToPressure = Locale.ConvertTextKey("TXT_KEY_TRO_RELIGIOUS_PRESSURE_ENTRY", strIcon, v.ToPressure);
			instance.ToReligion:SetToolTipString(strTT);	
		end
		instance.ToReligion:SetText(strToPressure);
		
		local strFromPressure = "";
		if (v.FromReligion > 0 and v.FromPressure ~= 0) then
			local religion = GameInfo.Religions[v.FromReligion];
			local strIcon = religion.IconString;
			strFromPressure = Locale.ConvertTextKey("TXT_KEY_TRO_RELIGIOUS_PRESSURE_ENTRY", strIcon, v.FromPressure);
			instance.FromReligion:SetToolTipString(strTT);	
		end
		instance.FromReligion:SetText(strFromPressure);
		
		local fromScience = "";
		local toScience = "";
		
		if (v.FromID ~= v.ToID) then
		
			if(v.FromScience ~= 0) then
				fromScience = v.FromScience / 100;
				instance.FromScience:SetToolTipString(strTT);	
			end
			
			if(v.ToScience ~= 0) then
				toScience = v.ToScience / 100;
				instance.ToScience:SetToolTipString(strTT);	
			end
		end
		instance.FromScience:SetText(fromScience);
		instance.ToScience:SetText(toScience);
		
		local strTurnsRemaining = "";
		if (v.IsRecalled) then
		  strTurnsRemaining = Locale.Lookup("TXT_KEY_GAIA_ROUTE_OVERVIEW_RECALLED_MARK")
		elseif (v.IsIndefinite) then
		  strTurnsRemaining = Locale.Lookup("TXT_KEY_TRO_INDEFINITE")
		else
		  if (v.TurnsLeft ~= nil and v.TurnsLeft >= 0) then
		    strTurnsRemaining = v.TurnsLeft;
		  end
		end
		instance.TurnsLeft:SetText(strTurnsRemaining);
        instance.TurnsButton:RegisterCallback(Mouse.eLClick, function() LookAtOrRecall(instance, v); end);
    end
    
    Controls.MainStack:CalculateSize();
    Controls.MainStack:ReprocessAnchoring();
    Controls.MainScroll:CalculateInternalSize();

end

function ShowHideHandler( bIsHide, bInitState )

	-- Set Civ Icon
	CivIconHookup( Game.GetActivePlayer(), 64, Controls.CivIcon, Controls.CivIconBG, Controls.CivIconShadow, false, true );

    if( not bInitState ) then
        if( not bIsHide ) then
        	UI.incTurnTimerSemaphore();  
        	Events.SerialEventGameMessagePopupShown(g_PopupInfo);
        	
        	TabSelect(g_CurrentTab);
        else
			if(g_PopupInfo ~= nil) then
				Events.SerialEventGameMessagePopupProcessed.CallImmediate(g_PopupInfo.Type, 0);
            end
            UI.decTurnTimerSemaphore();
        end
    end
end
ContextPtr:SetShowHideHandler( ShowHideHandler );

RegisterSortOptions();
TabSelect("YourTR");