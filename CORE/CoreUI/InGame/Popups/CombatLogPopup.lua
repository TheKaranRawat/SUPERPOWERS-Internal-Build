include "IconSupport"
local CivIconHookup = CivIconHookup

include "InstanceManager"
local InstanceManager = InstanceManager
local g_LogInstanceManager = InstanceManager:new( "LogEntry", "Button", Controls.LogEntryStack )

function RefreshList()
  CivIconHookup(Game.GetActivePlayer(), 64, Controls.CivIcon, Controls.CivIconBG, Controls.CivIconShadow, false, true)
  
  g_LogInstanceManager:ResetInstances()

  local pPlayer = Players[Game.GetActivePlayer()]
  
  local playerLog = pPlayer:_GetCombatLog()
  for i = #playerLog, 1, -1 do
    local e = playerLog[i]
    AddMessage(e.Turn, e.Message, e.Plot, e.OtherPlayer)
  end
  
  Controls.LogEntryStack:CalculateSize()
  Controls.LogEntryStack:ReprocessAnchoring()
  Controls.LogScrollPanel:CalculateInternalSize()
end

function AddMessage(iTurn, sMsg, pPlot, iOtherPlayer)  
  local controlTable = g_LogInstanceManager:GetInstance()

  CivIconHookup(iOtherPlayer, 32, controlTable.OtherIcon, controlTable.OtherIconBG, controlTable.OtherIconShadow, false, true)
  
  controlTable.LogText:SetText(sMsg)
  controlTable.LogTurn:SetText(Locale.ConvertTextKey("TXT_KEY_TP_TURN_COUNTER", iTurn))
    
  controlTable.TextStack:CalculateSize()
  controlTable.TextStack:ReprocessAnchoring()
    
  local sizeY = controlTable.TextStack:GetSizeY()
  controlTable.Button:SetSizeY(sizeY)
  controlTable.TextAnim:SetSizeY(sizeY)
  controlTable.TextHL:SetSizeY(sizeY)
    
  controlTable.Button:SetVoids(pPlot:GetX(), pPlot:GetY())
  controlTable.Button:RegisterCallback(Mouse.eLClick, MessageSelected)
end

function MessageSelected(iX, iY)
  UI.LookAt(Map.GetPlot(iX, iY), 0)
end

function OnClose ()
  ContextPtr:SetHide(true)
end
Controls.CloseButton:RegisterCallback(Mouse.eLClick, OnClose)

function InputHandler(uiMsg, wParam, lParam)
  if (uiMsg == KeyEvents.KeyDown) then
    if (wParam == Keys.VK_ESCAPE or wParam == Keys.VK_RETURN) then
      OnClose()
      return true
    end
  end
end
ContextPtr:SetInputHandler(InputHandler)

function ShowHideHandler(bIsHide, bInitState)
  if (not bInitState and not bIsHide) then
    RefreshList()
  end
end
ContextPtr:SetShowHideHandler(ShowHideHandler)

ContextPtr:SetHide(true)


function OnDiploCornerPopup()
  ContextPtr:SetHide(false)
end

function OnAdditionalInformationDropdownGatherEntries(additionalEntries)
  table.insert(additionalEntries, {text=Locale.ConvertTextKey("TXT_KEY_POP_COMBAT_LOG"), call=OnDiploCornerPopup})
end
LuaEvents.AdditionalInformationDropdownGatherEntries.Add(OnAdditionalInformationDropdownGatherEntries)
LuaEvents.RequestRefreshAdditionalInformationDropdownEntries()

Events.GameplaySetActivePlayer.Add(OnClose)
