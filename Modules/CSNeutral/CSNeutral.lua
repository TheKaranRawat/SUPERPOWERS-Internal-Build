-- CityStateNoAllyWar.lua (sim-side hook only, no UI events)

local iLastSweepTurn = -1

local function CheckMinor(iMinor)
    local pMinor = Players[iMinor]
    if pMinor == nil or not pMinor:IsAlive() or not pMinor:IsMinorCiv() then return end

    local iAlly = pMinor:GetAlly()
    if iAlly == nil or iAlly < 0 then return end

    local pAlly = Players[iAlly]
    if pAlly == nil or not pAlly:IsAlive() then return end

    local iMinorTeam = pMinor:GetTeam()
    local iAllyTeam  = pAlly:GetTeam()
    local pMinorTeam = Teams[iMinorTeam]
    local pAllyTeam  = Teams[iAllyTeam]

    -- Majors only: skips minors and barbarians
    for iTeam = 0, GameDefines.MAX_MAJOR_CIVS - 1 do
        if iTeam ~= iAllyTeam and Teams[iTeam]:IsAlive()
           and pMinorTeam:IsAtWar(iTeam) and pAllyTeam:IsAtWar(iTeam) then
            pMinorTeam:MakePeace(iTeam)
        end
    end
end

function OnPlayerDoTurn(iPlayer)
    -- Only react on major players' turn start, and only once per game turn
    if iPlayer >= GameDefines.MAX_MAJOR_CIVS then return end
    local iTurn = Game.GetGameTurn()
    if iTurn == iLastSweepTurn then return end
    iLastSweepTurn = iTurn

    for iMinor = GameDefines.MAX_MAJOR_CIVS, GameDefines.MAX_CIV_PLAYERS - 1 do
        CheckMinor(iMinor)
    end
end
GameEvents.PlayerDoTurn.Add(OnPlayerDoTurn)