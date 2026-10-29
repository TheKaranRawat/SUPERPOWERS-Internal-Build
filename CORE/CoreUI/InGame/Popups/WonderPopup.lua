-------------------------------------------------
-- Wonder Popup
-------------------------------------------------

include("IconSupport")
include("InfoTooltipInclude")

local m_fAnimSeconds      = 5
local m_fScaleFactor      = 0.5
local m_fPct              = 0
local m_fOriginalSizeX    = 0
local m_fOriginalSizeY    = 0
local m_PopupInfo         = nil
local lastBackgroundImage = "WonderConceptStonehedge.dds"

function OnPopup(popupInfo)
	if popupInfo.Type ~= ButtonPopupTypes.BUTTONPOPUP_WONDER_COMPLETED_ACTIVE_PLAYER then
		return
	end

	if Game == nil or Game.GetGameTurn() <= Game.GetStartTurn() then
		return
	end

	m_PopupInfo = popupInfo

	local wonderImage, wonderAnchor
	local wonderDescription, wonderQuote, wonderHelp
	local wonderIconAtlas, wonderIconIndex

	if popupInfo.Data1 ~= -1 then
		-- National Wonder
		local iBuildingID = popupInfo.Data1
		local thisBuilding = GameInfo.Buildings[iBuildingID]
		if not thisBuilding then return end

		print(string.format("WonderPopup for Building %s", thisBuilding.Type))
		wonderImage, wonderAnchor = GetWonderImage(thisBuilding.Type, thisBuilding.WonderSplashImage, (thisBuilding.WonderSplashAnchor or "R,T"))
		wonderDescription = thisBuilding.Description
		wonderQuote       = thisBuilding.Quote
		wonderHelp        = thisBuilding.Help
		wonderIconAtlas   = thisBuilding.IconAtlas
		wonderIconIndex   = thisBuilding.PortraitIndex

		if not wonderHelp then
			wonderHelp = GetHelpTextForBuilding(iBuildingID, true, true, false)
		end
	else
		-- National Project
		popupInfo.Data1 = 0
		local iProjectID = popupInfo.Data2
		local thisProject = GameInfo.Projects[iProjectID]
		if not thisProject then return end

		print(string.format("WonderPopup for Project %s", thisProject.Type))
		wonderImage, wonderAnchor = GetWonderImage(thisProject.Type, thisProject.MovieDefineTag, "R,T")
		wonderDescription = thisProject.Description
		wonderQuote       = Locale.ConvertTextKey(string.format("TXT_KEY_%s_QUOTE", thisProject.Type))
		if (wonderQuote:sub(1, string.len("TXT_KEY_")) == "TXT_KEY_") then wonderQuote = nil end
		wonderHelp        = thisProject.Help
		wonderIconAtlas   = thisProject.IconAtlas
		wonderIconIndex   = thisProject.PortraitIndex
	end

	-- Fallbacks
	wonderImage = wonderImage or lastBackgroundImage
	wonderAnchor = wonderAnchor or "R,T"

	if wonderImage then
		Controls.WonderSplash:SetAnchor(wonderAnchor)
		Controls.WonderSplash:ReprocessAnchoring()
		lastBackgroundImage = wonderImage
		Controls.WonderSplash:SetTextureAndResize(wonderImage)

		m_fOriginalSizeX, m_fOriginalSizeY = Controls.WonderSplash:GetSizeVal()
		Controls.WonderSplash:SetSizeVal(m_fOriginalSizeX * (1 + m_fScaleFactor), m_fOriginalSizeY * (1 + m_fScaleFactor))

		ContextPtr:SetUpdate(OnUpdate)
	end

	IconHookup(wonderIconIndex, 128, wonderIconAtlas, Controls.WonderIcon)

	if wonderDescription then
		Controls.Title:SetText(Locale.ConvertTextKey(wonderDescription))
		Controls.LowerTitle:SetText(Locale.ConvertTextKey(wonderDescription))
		Controls.Title:SetHide(false)
		Controls.LowerTitle:SetHide(false)
	else
		Controls.Title:SetHide(true)
		Controls.LowerTitle:SetHide(true)
	end

	if wonderQuote then
		Controls.Quote:SetText(Locale.ConvertTextKey(wonderQuote))
		Controls.Quote:SetHide(false)
	else
		Controls.Quote:SetHide(true)
	end

	if wonderHelp then
		Controls.Stats:SetText(Locale.ConvertTextKey(wonderHelp))
		Controls.Stats:SetHide(false)
	else
		Controls.Stats:SetHide(true)
	end

	UIManager:QueuePopup(ContextPtr, PopupPriority.WonderPopup)

	m_fPct = 0
	OnUpdate(0)
end
Events.SerialEventGameMessagePopup.Add(OnPopup)

function GetWonderImage(sWonderType, sDefaultImage, sDefaultAnchor)
	local response = {Image = sDefaultImage, Anchor = sDefaultAnchor}
	LuaEvents.GetWonderImage(sWonderType, sDefaultImage, sDefaultAnchor, response)
	return response.Image, response.Anchor
end

function OnUpdate(fDTime)
	m_fPct = m_fPct + (fDTime / m_fAnimSeconds)

	if m_fPct > 1 then
		ContextPtr:ClearUpdate()
		print("Setting to original size", m_fOriginalSizeX, m_fOriginalSizeY)
		Controls.WonderSplash:SetSizeVal(m_fOriginalSizeX, m_fOriginalSizeY)
	else
		local fScale = 1 + ((1 - m_fPct) * (1 - m_fPct) * m_fScaleFactor)
		Controls.WonderSplash:SetSizeVal(m_fOriginalSizeX * fScale, m_fOriginalSizeY * fScale)
	end
end

function OnClose()
	UIManager:DequeuePopup(ContextPtr)
end
Controls.CloseButton:RegisterCallback(Mouse.eLClick, OnClose)

function InputHandler(uiMsg, wParam, lParam)
	if uiMsg == KeyEvents.KeyDown then
		if wParam == Keys.VK_ESCAPE or wParam == Keys.VK_RETURN then
			OnClose()
			return true
		end
	end
end
ContextPtr:SetInputHandler(InputHandler)

function ShowHideHandler(bIsHide, bInitState)
	if not bInitState then
		Controls.WonderSplash:UnloadTexture()
		if not bIsHide then
			UI.incTurnTimerSemaphore()
			Events.SerialEventGameMessagePopupShown(m_PopupInfo)
			Controls.WonderSplash:SetTextureAndResize(lastBackgroundImage)
		else
			UI.decTurnTimerSemaphore()
			Events.SerialEventGameMessagePopupProcessed.CallImmediate(ButtonPopupTypes.BUTTONPOPUP_WONDER_COMPLETED_ACTIVE_PLAYER, 0)
			ContextPtr:ClearUpdate()
		end
	end
end
ContextPtr:SetShowHideHandler(ShowHideHandler)

Events.GameplaySetActivePlayer.Add(OnClose)
