-------------------------------------------------
-- Great Work Popup
-------------------------------------------------

include "InfoTooltipInclude"
include "CommonBehaviors"

include "IconSupport"

local function GaiaSetGreatWorkIcon(greatWorkClassType, control)
	local IconHookup = IconHookup
	local GREAT_WORK_ATLAS = "GREAT_WORKS_ATLAS" 
	local GREAT_WORK_ICON_SIZE = 128

	local iconIndices = {
		GREAT_WORK_ART = 2,
		GREAT_WORK_MUSIC = 0,
		GREAT_WORK_LITERATURE = 3
	}

	local gaiaIcons = {
		GREAT_WORK_GAIA_HOLY_ARTIFACT    = "GAIA_GW_Religion_128.dds",
		GREAT_WORK_GAIA_CORPORATION = "GAIA_GW_Corporation_128.dds",
		GREAT_WORK_GAIA_CINEMA      = "GAIA_GW_Cinema_128.dds",
		GREAT_WORK_GAIA_VIDEOGAME   = "GAIA_GW_Videogame_128.dds"
	}

	local gaiaTexture = gaiaIcons[greatWorkClassType]
	if gaiaTexture then
		control:SetTexture(gaiaTexture)
		control:SetTextureOffsetVal(0,0)
		control:SetHide(false)
	elseif greatWorkClassType == "GREAT_WORK_ARTIFACT" then
		control:SetTexture("GreatWorksAtlas128_Exp2.dds")
		control:SetTextureOffsetVal(0,0)
		control:SetHide(false)
	else
		local index = iconIndices[greatWorkClassType]
		if index then
			IconHookup(index, GREAT_WORK_ICON_SIZE, GREAT_WORK_ATLAS, control)
			control:SetHide(false)
		else
			control:SetHide(true)
			print("Warning: Unknown GreatWorkClassType", greatWorkClassType)
		end
	end
end

local g_PopupInfo = nil

local gwsWidth, gwsHeight = Controls.GreatWorkSplash:GetSizeVal()
local windowWidth, windowHeight = Controls.Window:GetSizeVal()


local deltaWidth = windowWidth - gwsWidth
local deltaHeight = windowHeight - gwsHeight

-------------------------------------------------
-- On Popup
-------------------------------------------------
function OnPopup(popupInfo)

	if popupInfo.Type ~= ButtonPopupTypes.BUTTONPOPUP_GREAT_WORK_COMPLETED_ACTIVE_PLAYER then
		return
	end
	
	g_PopupInfo = popupInfo
		  
	local iPriority = popupInfo.Priority
	if iPriority == PopupPriority.Default then 
		iPriority = PopupPriority.GreatWorkPopup
	end
	
	UIManager:QueuePopup(ContextPtr, iPriority)
end
Events.SerialEventGameMessagePopup.Add(OnPopup)

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
		if not bIsHide then
			UI.incTurnTimerSemaphore()
			Events.SerialEventGameMessagePopupShown(g_PopupInfo)

			local iGWIndex = g_PopupInfo.Data1
			local eGWType = (iGWIndex ~= -1) and Game.GetGreatWorkType(iGWIndex) or g_PopupInfo.Data2
			local greatWork = GameInfo.GreatWorks[eGWType]
			local greatWorkImage = greatWork.Image or "GW_Starry_Night.dds"

			Controls.GreatWorkSplash:SetTextureAndResize(greatWorkImage)
			m_fOriginalSizeX, m_fOriginalSizeY = Controls.GreatWorkSplash:GetSizeVal()

			GaiaSetGreatWorkIcon(greatWork.GreatWorkClassType, Controls.TopIcon)

			-- Window sizing
			Controls.Window:SetSizeVal(m_fOriginalSizeX + deltaWidth, m_fOriginalSizeY + deltaHeight)
			Controls.GreatWorkSplashClip:SetSizeVal(m_fOriginalSizeX, m_fOriginalSizeY)
			Controls.GreatWorkSplashContainer:SetSizeVal(m_fOriginalSizeX, m_fOriginalSizeY)
			Controls.GreatWorkSplashClip:ReprocessAnchoring()
			Controls.GreatWorkSplashContainer:ReprocessAnchoring()

			-- Animation
			g_AnimUpdate = ZoomOutEffect{
				SplashControl = Controls.GreatWorkSplash,
				ScaleFactor = 0.5,
				AnimSeconds = 5
			}
			ContextPtr:SetUpdate(function(dTime)
				if not g_AnimUpdate or g_AnimUpdate(dTime) == true then
					ContextPtr:ClearUpdate()
				end
			end)

			-- Caption and quote
			local lcMaxWidth = m_fOriginalSizeX + deltaWidth - 34
			Controls.LowerCaption:SetWrapWidth(lcMaxWidth)

			if not greatWork.ArchaeologyOnly then
				Controls.Title:LocalizeAndSetText(Game.GetGreatWorkArtist(iGWIndex))
			else
				Controls.Title:LocalizeAndSetText("TXT_KEY_GREAT_WORK_POPUP_WRITTEN_ARTIFACT")
			end
			Controls.LowerCaption:LocalizeAndSetText(greatWork.Description)

			local lcWidth, lcHeight = Controls.LowerCaption:GetSizeVal()
			local lcNewWidth = math.min(lcWidth + 100, lcMaxWidth)
			local lcNewHeight = lcHeight + 20
			Controls.LowerCaptionFrame:SetSizeVal(lcNewWidth, lcNewHeight)
			Controls.LowerCaptionFrame:SetDisabled(true)
			Controls.LowerCaptionFrame:ReprocessAnchoring()

			if greatWork.Quote ~= nil then
				Controls.Quote:LocalizeAndSetText(greatWork.Quote)
				Controls.Quote:SetHide(false)
			else
				Controls.Quote:SetHide(true)
			end
		else
			UI.decTurnTimerSemaphore()
			if g_PopupInfo then
				Events.SerialEventGameMessagePopupProcessed.CallImmediate(g_PopupInfo.Type, 0)
			end
			ContextPtr:ClearUpdate()
			Controls.GreatWorkSplash:UnloadTexture()
		end
	end
end
ContextPtr:SetShowHideHandler(ShowHideHandler)

Events.GameplaySetActivePlayer.Add(OnClose)
