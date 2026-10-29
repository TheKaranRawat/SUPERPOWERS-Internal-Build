local bWarned = false

local function OnClose()
	UIManager:DequeuePopup(ContextPtr)
end
Controls.CloseButton:RegisterCallback(Mouse.eLClick, OnClose)

ContextPtr:SetInputHandler(function(uiMsg, wParam, lParam)
	if uiMsg == KeyEvents.KeyDown and (wParam == Keys.VK_ESCAPE or wParam == Keys.VK_RETURN) then
		OnClose()
		return true
	end
end)

Events.LoadScreenClose.Add(function()
	if bWarned or Game._LogSapiensSession then
		return
	end
	bWarned = true
	Controls.DescriptionLabel:LocalizeAndSetText("TXT_KEY_GAIA_DLL_NOT_LOADED_TEXT")
	Controls.Grid:DoAutoSize()
	UIManager:QueuePopup(ContextPtr, PopupPriority.TextPopup)
end)

ContextPtr:SetHide(true)
