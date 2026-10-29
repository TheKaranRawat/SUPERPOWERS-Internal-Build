--====================================================================================================================
-- Technology Award Popup
--====================================================================================================================

include "TechButtonInclude"
include "ShortTechHelp"

local maxSmallButtons = 5

local playerID = Game.GetActivePlayer()
local player = Players[playerID]
local civType = GameInfo.Civilizations[player:GetCivilizationType()].Type
local activeTeamID = Game.GetActiveTeam()
local activeTeam = Teams[activeTeamID]

local storedPopupInfo = {}
local m_PopupInfo = nil

GatherInfoAboutUniqueStuff(civType)

function OnPopup(popupInfo)
	if popupInfo.Type ~= ButtonPopupTypes.BUTTONPOPUP_TECH_AWARD then return end
	if popupInfo.Data3 == -1 then return end

	m_PopupInfo = popupInfo
	storedPopupInfo = popupInfo

	local pTechInfo = GameInfo.Technologies[popupInfo.Data3]
	if not pTechInfo then return end

	RefreshDisplay(pTechInfo)
	UIManager:QueuePopup(ContextPtr, PopupPriority.TechAward)
end
Events.SerialEventGameMessagePopup.Add(OnPopup)

function RefreshDisplay(pTechInfo)
	if not pTechInfo then return end

	local playerID = Game.GetActivePlayer()
	local player = Players[playerID]

	-- Tech Name
	Controls.TechName:SetText(Locale.ConvertTextKey(pTechInfo.Description))

	-- Tech Quote
	Controls.TechQuote:SetText(Locale.ConvertTextKey(pTechInfo.Quote))

	-- Tech Icon
	if IconHookup(pTechInfo.PortraitIndex, 128, pTechInfo.IconAtlas, Controls.TechIcon) then
		Controls.TechIcon:SetHide(false)
	else
		Controls.TechIcon:SetHide(true)
	end

	-- Small Buttons
	techPediaSearchStrings = {}

	local numButtons = AddSmallButtonsToTechButton(Controls, pTechInfo, maxSmallButtons, 64)

	Controls.BonusStack:CalculateSize()
	Controls.BonusStack:ReprocessAnchoring()

	-- Short Tech Help
	Controls.TechHelp:SetText(GetShortTechHelp(pTechInfo.ID, playerID))

	Controls.OuterGrid:DoAutoSize()
end

function OnContinueButtonClicked()
	OnClose()
end
Controls.ContinueButton:RegisterCallback(Mouse.eLClick, OnContinueButtonClicked)

function OnClose()
	UIManager:DequeuePopup(ContextPtr)
end
Controls.CloseButton:RegisterCallback(Mouse.eLClick, OnClose)

function InputHandler(uiMsg, wParam)
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
			Events.SerialEventGameMessagePopupShown(m_PopupInfo)
		else
			UI.decTurnTimerSemaphore()
			Events.SerialEventGameMessagePopupProcessed.CallImmediate(ButtonPopupTypes.BUTTONPOPUP_TECH_AWARD, 0)
		end
	end
end
ContextPtr:SetShowHideHandler(ShowHideHandler)

function OnTechAwardActivePlayerChanged(iActivePlayer)
	playerID = Game.GetActivePlayer()
	player = Players[playerID]
	civType = GameInfo.Civilizations[player:GetCivilizationType()].Type
	activeTeamID = Game.GetActiveTeam()
	activeTeam = Teams[activeTeamID]

	GatherInfoAboutUniqueStuff(civType)

	OnClose()
end
Events.GameplaySetActivePlayer.Add(OnTechAwardActivePlayerChanged)
