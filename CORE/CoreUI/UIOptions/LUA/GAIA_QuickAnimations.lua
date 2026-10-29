-------------------------------------------------
-- Quick Animations -- engine (Gaia's Core Mod)
-------------------------------------------------

--====================================================================================================================
-- MOD DATA
--====================================================================================================================
local FuriousTurns = {}
MapModData.FuriousTurns = FuriousTurns

FuriousTurns.IsPlayerTurn = false
FuriousTurns.DialogOpen = false
FuriousTurns.Synced = false

FuriousTurns.UserData = Modding.OpenUserData("GAIA_UIOptions", 1)
if not FuriousTurns.UserData then
    MapModData.GAIA_UIOptions = MapModData.GAIA_UIOptions or {}
    local t = MapModData.GAIA_UIOptions
    FuriousTurns.UserData = { GetValue = function(k) return t[k] end, SetValue = function(k, v) t[k] = v end }
end
FuriousTurns.Cache = {}

--====================================================================================================================
-- SETTINGS FUNCTIONS
--====================================================================================================================
function FuriousTurns.GetOptionValue(name)
    local cache = FuriousTurns.Cache
    if cache[name] == nil then
        cache[name] = FuriousTurns.UserData.GetValue(name)
    end
    return cache[name]
end

function FuriousTurns.SetOptionValue(name, value)
    local normalized = (value == 1) and 1 or 0
    if FuriousTurns.GetOptionValue(name) ~= normalized then
        FuriousTurns.UserData.SetValue(name, normalized)
        FuriousTurns.Cache[name] = normalized
    end
end

local function SetDefaultOption(name, value)
    if FuriousTurns.UserData.GetValue(name) == nil then
        FuriousTurns.UserData.SetValue(name, value)
    end
end

-- Default settings
SetDefaultOption("QuickAnimations", 0)
SetDefaultOption("QuickAnimations_NoPlayerWar", 0)
SetDefaultOption("QuickAnimations_NoPlayerPeace", 1)
SetDefaultOption("QuickAnimations_NoAIWar", 0)
SetDefaultOption("QuickAnimations_NoBarbarian", 1)

--====================================================================================================================
-- DEBUG
--====================================================================================================================
local DebugEnabled = false
local DebugPrint = DebugEnabled and function(text)
    print("[FuriousTurns] " .. tostring(text))
end or function() end

--====================================================================================================================
-- UTILITY
--====================================================================================================================
function FuriousTurns.SetAnimations(disabled)
    if Game.IsNetworkMultiPlayer() then
        return
    end
    DebugPrint("SetAnimations: " .. tostring(disabled))
    Network.SendGameOptions({
        { "GAMEOPTION_QUICK_MOVEMENT", disabled },
        { "GAMEOPTION_QUICK_COMBAT", disabled }
    })
end

--====================================================================================================================
-- MAIN LOGIC (ONLY ACTIVE WHEN ENABLED)
--====================================================================================================================
local function OnAIProcessingStartedForPlayer(iPlayer)
    if FuriousTurns.GetOptionValue("QuickAnimations") ~= 1 then
        return
    end

    DebugPrint("AIProcessingStartedForPlayer: " .. tostring(iPlayer))
    FuriousTurns.IsPlayerTurn = false

    local activePlayerID = Game.GetActivePlayer()
    local activeTeamID = Game.GetActiveTeam()

    if iPlayer == activePlayerID then
        return
    end

    local pComputer = Players[iPlayer]
    local tComputer = Teams[pComputer:GetTeam()]

    if pComputer:IsBarbarian() then
        DebugPrint("Target is Barbarian")
        FuriousTurns.SetAnimations(FuriousTurns.GetOptionValue("QuickAnimations_NoBarbarian") == 1)
    elseif tComputer:IsAtWar(activeTeamID) then
        DebugPrint("Target is at war with Player")
        FuriousTurns.SetAnimations(FuriousTurns.GetOptionValue("QuickAnimations_NoAIWar") == 1)
    else
        FuriousTurns.SetAnimations(true)
    end
end
Events.AIProcessingStartedForPlayer.Add(OnAIProcessingStartedForPlayer)

local function OnActivePlayerTurnStart()
    if FuriousTurns.GetOptionValue("QuickAnimations") ~= 1 then
        return
    end

    DebugPrint("ActivePlayerTurnStart")
    FuriousTurns.IsPlayerTurn = true

    local activeTeamID = Game.GetActiveTeam()
    local tPlayer = Teams[activeTeamID]

    for iPlayer = 0, GameDefines.MAX_PLAYERS - 1 do
        local pTarget = Players[iPlayer]
        if pTarget:IsAlive() and not pTarget:IsMinorCiv() and not pTarget:IsBarbarian() then
            if tPlayer:IsAtWar(pTarget:GetTeam()) then
                DebugPrint("At war with Player " .. tostring(iPlayer))
                FuriousTurns.SetAnimations(FuriousTurns.GetOptionValue("QuickAnimations_NoPlayerWar") == 1)
                return
            end
        end
    end

    FuriousTurns.SetAnimations(FuriousTurns.GetOptionValue("QuickAnimations_NoPlayerPeace") == 1)
end
Events.ActivePlayerTurnStart.Add(OnActivePlayerTurnStart)
Events.LoadScreenClose.Add(OnActivePlayerTurnStart)

local function OnWarStateChanged(iTeam1, iTeam2, bIsWar)
    if FuriousTurns.GetOptionValue("QuickAnimations") ~= 1 then
        return
    end

    DebugPrint("WarStateChanged: Teams " .. tostring(iTeam1) .. " vs " .. tostring(iTeam2) .. " | War = " .. tostring(bIsWar))

    local activeTeamID = Game.GetActiveTeam()
    if iTeam1 == activeTeamID or iTeam2 == activeTeamID then
        FuriousTurns.SetAnimations(
            (bIsWar and FuriousTurns.GetOptionValue("QuickAnimations_NoAIWar") == 1) or
            (not bIsWar)
        )
    end
end
Events.WarStateChanged.Add(OnWarStateChanged)

--====================================================================================================================
-- LISTEN FOR MANUAL OPTION CHANGES (DISABLE IF NEEDED)
--====================================================================================================================
Events.GameOptionsChanged.Add(function()
    if FuriousTurns.GetOptionValue("QuickAnimations") ~= 1 or Game.IsNetworkMultiPlayer() then
        FuriousTurns.Synced = false
        return
    end
    if PreGame.GetQuickMovement() == PreGame.GetQuickCombat() then
        FuriousTurns.Synced = true
    elseif FuriousTurns.Synced then
        FuriousTurns.SetOptionValue("QuickAnimations", 0)
        FuriousTurns.Synced = false
        DebugPrint("Furious Turns disabled due to manual Quick option change")
    end
end)
