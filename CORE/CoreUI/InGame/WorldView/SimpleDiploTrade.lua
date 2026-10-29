include "TradeLogic"
Events.OpenPlayerDealScreenEvent.Add( OnOpenPlayerDealScreen );
Controls.ModifyButton:RegisterCallback( Mouse.eLClick, OnModify );



ContextPtr:SetInputHandler( InputHandler );

Controls.CloseButton:RegisterCallback( Mouse.eLClick, OnBack );

function OnDiploActivePlayerChanged()
	if not ContextPtr:IsHidden() then
		OnBack();
	end
end
Events.GameplaySetActivePlayer.Add(OnDiploActivePlayerChanged);


ContextPtr:SetShowHideHandler( function( isHide, isInit )
	OnShowHide( isHide, isInit );
	if not isInit and not isHide then
		LuaEvents.OpenSimpleDiploTrade();
	end
end);


function OnOpenAILeaderDiploTrade()
	if not ContextPtr:IsHidden() then
		OnBack();
	end
end
LuaEvents.OpenAILeaderDiploTrade.Add(OnOpenAILeaderDiploTrade);
