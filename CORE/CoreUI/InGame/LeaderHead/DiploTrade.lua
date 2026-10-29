include "TradeLogic"

local ContextPtr = ContextPtr
local Controls = Controls
local Mouse = Mouse
local UIManager = UIManager

Events.AILeaderMessage.Add( LeaderMessageHandler );

Controls.WhatWillMakeThisWorkButton:RegisterCallback( Mouse.eLClick, OnEqualizeDeal );
Controls.WhatWillEndThisWarButton:RegisterCallback( Mouse.eLClick, OnEqualizeDeal );
Controls.WhatConcessionsButton:RegisterCallback( Mouse.eLClick, OnEqualizeDeal );
Controls.WhatDoYouWantButton:RegisterCallback( Mouse.eLClick, OnWhatDoesAIWant );
Controls.WhatWillYouGiveMeButton:RegisterCallback( Mouse.eLClick, OnWhatWillAIGive );

ContextPtr:SetInputHandler( InputHandler );


function OnLeavingLeader()
    UIManager:DequeuePopup( ContextPtr );
end
Events.LeavingLeaderViewMode.Add( OnLeavingLeader );


ContextPtr:SetShowHideHandler( function( isHide, isInit )
	OnShowHide( isHide, isInit );
	if not isInit and not isHide then
		LuaEvents.OpenAILeaderDiploTrade();
	end
end);

function OnOpenSimpleDiploTrade()
	if not ContextPtr:IsHidden() then
		UIManager:DequeuePopup( ContextPtr );
	end
end
LuaEvents.OpenSimpleDiploTrade.Add(OnOpenSimpleDiploTrade);
