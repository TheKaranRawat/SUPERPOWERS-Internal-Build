--==========================================================
-- AI Nuclear Retaliation
-- When an AI loses a city to a human (or another AI), it warns
-- the players, then tries to nuke the captor's cities on the
-- following turn.
--
-- Add to your mod as an InGameUIAddin file.
--==========================================================

------------------------- CONFIG -------------------------
local MAX_NUKES_PER_STRIKE = 4    -- 1 city lost = 1 nuke ... 4+ cities = 4 nukes
local RETRY_DELAY          = 5    -- turns to wait after an abandoned strike
local MAX_RETRIES          = 10   -- stop retrying after this many (set high for "forever")
local MAX_PREP_ATTEMPTS    = 3    -- max rebase turns before giving up for now
local REBASE_RANGE_MULT    = 2    -- air rebase range = unit range * this (game default is 200%)
local ANNOUNCE_LAUNCH      = true -- also notify humans when a nuke is launched
local AI_VS_AI             = true -- AI also retaliates against AI captors
local AI_ALERT_ONLY_IF_MET = true -- for AI-vs-AI strikes, only alert humans who have met
                                  -- the attacker or the victim (avoids leaking info)
-----------------------------------------------------------

local PHASE_ALERT = 1   -- waiting to send (or re-send) the alert
local PHASE_ACT   = 2   -- alert sent; launch / rebase on this turn

local captures = {}     -- [aiID] = cities lost (capped)
local plans    = {}     -- [aiID] = { phase, turn, target, remaining, preps, retries }

-- Cache which unit types are nukes (done once at load)
local nukeTypes = {}
for row in GameInfo.Units() do
    if (row.NukeDamageLevel and row.NukeDamageLevel > 0)
       or row.Type == "UNIT_ATOMIC_BOMB"
       or row.Type == "UNIT_NUCLEAR_MISSILE" then
        nukeTypes[row.ID] = true
    end
end

----------------------------------------------------------
-- Helpers
----------------------------------------------------------
local function CivName(pPlayer)
    return Locale.ConvertTextKey(pPlayer:GetCivilizationShortDescription())
end

local function NotifyHumans(text, summary, iAI, iTarget)
    local pAI, pTarget = Players[iAI], Players[iTarget]
    local filter = AI_ALERT_ONLY_IF_MET and iTarget and not pTarget:IsHuman()
    for i = 0, GameDefines.MAX_MAJOR_CIVS - 1 do
        local p = Players[i]
        if p and p:IsAlive() and p:IsHuman() then
            local show = true
            if filter then
                local team = Teams[p:GetTeam()]
                show = team:IsHasMet(pAI:GetTeam()) or team:IsHasMet(pTarget:GetTeam())
            end
            if show then
                p:AddNotification(NotificationTypes.NOTIFICATION_GENERIC, text, summary, -1, -1)
            end
        end
    end
end

local function SendAlert(iAI, iTarget)
    local text = CivName(Players[iAI]) .. " is preparing a nuclear strike against "
                 .. CivName(Players[iTarget]) .. "!"
    NotifyHumans(text, "Nuclear strike being prepared", iAI, iTarget)
end

local function GetNukes(pPlayer)
    local list = {}
    for unit in pPlayer:Units() do
        if nukeTypes[unit:GetUnitType()] then
            list[#list + 1] = unit
        end
    end
    return list
end

local function GetCityList(pPlayer)
    local list = {}
    for city in pPlayer:Cities() do
        list[#list + 1] = { x = city:GetX(), y = city:GetY(),
                            pop = city:GetPopulation(), nameKey = city:GetNameKey() }
    end
    return list
end

----------------------------------------------------------
-- Strike execution
----------------------------------------------------------
local function ScheduleRetry(iAI, plan, turn)
    plan.retries = plan.retries + 1
    if plan.retries > MAX_RETRIES then
        plans[iAI] = nil
        return
    end
    plan.phase = PHASE_ALERT
    plan.turn  = turn + RETRY_DELAY
    plan.preps = 0
end

local function ExecutePlan(iAI, plan, turn)
    local pAI     = Players[iAI]
    local pTarget = Players[plan.target]

    -- Validity checks: abandon silently if the strike no longer makes sense
    if not pAI:IsAlive() or pAI:GetNumCities() == 0
       or not pTarget:IsAlive()
       or not Teams[pAI:GetTeam()]:IsAtWar(pTarget:GetTeam()) then
        plans[iAI] = nil
        return
    end

    local nukes = GetNukes(pAI)
    if #nukes == 0 then
        plans[iAI] = nil
        return
    end

    local targets = GetCityList(pTarget)
    if #targets == 0 then
        plans[iAI] = nil
        return
    end

    local remaining = plan.remaining
    local launched  = 0
    local used      = {}
    local assigned  = {}

    -- Pass 1: launch every nuke that already has a target in range
    for n = 1, #nukes do
        if launched >= remaining then break end
        local unit  = nukes[n]
        local range = unit:Range()
        local ux, uy = unit:GetX(), unit:GetY()

        -- Prefer cities with fewer nukes assigned, then higher population
        local best, bestCount, bestPop
        for t = 1, #targets do
            local tc = targets[t]
            if Map.PlotDistance(ux, uy, tc.x, tc.y) <= range then
                local c = assigned[t] or 0
                if not best or c < bestCount or (c == bestCount and tc.pop > bestPop) then
                    best, bestCount, bestPop = t, c, tc.pop
                end
            end
        end

        if best then
            used[n] = true
            local tc = targets[best]
            local ok = pcall(unit.PushMission, unit, MissionTypes.MISSION_NUKE, tc.x, tc.y, 0, 0, 1)
            if ok then
                launched = launched + 1
                assigned[best] = (assigned[best] or 0) + 1
                if ANNOUNCE_LAUNCH then
                    NotifyHumans(CivName(pAI) .. " has launched a nuclear weapon at "
                                 .. Locale.ConvertTextKey(tc.nameKey) .. "!",
                                 "Nuclear launch detected", iAI, plan.target)
                end
            end
        end
    end

    -- Pass 2: rebase out-of-range nukes to an AI city that can reach a target
    local need  = remaining - launched
    local moved = 0
    if need > 0 then
        local myCities = GetCityList(pAI)
        for n = 1, #nukes do
            if moved >= need then break end
            if not used[n] then
                local unit  = nukes[n]
                local range = unit:Range()
                local rebaseRange = range * REBASE_RANGE_MULT
                local ux, uy = unit:GetX(), unit:GetY()

                local bestBase, bestDist
                for m = 1, #myCities do
                    local mc = myCities[m]
                    if (mc.x ~= ux or mc.y ~= uy)
                       and Map.PlotDistance(ux, uy, mc.x, mc.y) <= rebaseRange then
                        for t = 1, #targets do
                            local d = Map.PlotDistance(mc.x, mc.y, targets[t].x, targets[t].y)
                            if d <= range and (not bestDist or d < bestDist) then
                                bestBase, bestDist = mc, d
                            end
                        end
                    end
                end

                if bestBase then
                    local ok = pcall(unit.PushMission, unit, MissionTypes.MISSION_REBASE,
                                     bestBase.x, bestBase.y)
                    if ok then moved = moved + 1 end
                end
            end
        end
    end

    -- Decide what happens next
    plan.remaining = remaining - launched
    if plan.remaining <= 0 then
        plans[iAI] = nil                       -- strike complete
    elseif moved > 0 and plan.preps < MAX_PREP_ATTEMPTS then
        plan.preps = plan.preps + 1            -- launch the rebased nukes next turn
        plan.phase = PHASE_ACT
        plan.turn  = turn + 1
    else
        ScheduleRetry(iAI, plan, turn)         -- nothing in range: abandon, retry in 5 turns
    end
end

----------------------------------------------------------
-- Event handlers
----------------------------------------------------------
local function OnCityCaptured(iOldOwner, bIsCapital, iX, iY, iNewOwner, iPop, bConquest)
    if bConquest == false then return end
    if iOldOwner == iNewOwner then return end

    local pOld = Players[iOldOwner]
    local pNew = Players[iNewOwner]
    if not pOld or not pNew then return end

    -- Victim must be a major AI; captor must be a major civ (no barbarians or city-states)
    if pOld:IsHuman() or pOld:IsMinorCiv() or pOld:IsBarbarian() then return end
    if pNew:IsMinorCiv() or pNew:IsBarbarian() then return end
    if not pNew:IsHuman() and not AI_VS_AI then return end

    local count = math.min((captures[iOldOwner] or 0) + 1, MAX_NUKES_PER_STRIKE)
    captures[iOldOwner] = count

    local plan = plans[iOldOwner]
    if plan then
        -- A strike is already pending: scale it up and retarget the latest captor
        plan.remaining = count
        plan.target    = iNewOwner
    else
        plans[iOldOwner] = {
            phase = PHASE_ACT, turn = Game.GetGameTurn() + 1,
            target = iNewOwner, remaining = count, preps = 0, retries = 0,
        }
        SendAlert(iOldOwner, iNewOwner)
    end
end

local function OnPlayerDoTurn(iPlayer)
    local plan = plans[iPlayer]
    if not plan then return end                -- fast exit for almost every call

    local turn = Game.GetGameTurn()
    if turn < plan.turn then return end

    if plan.phase == PHASE_ALERT then
        SendAlert(iPlayer, plan.target)        -- retry: warn again, act next turn
        plan.phase = PHASE_ACT
        plan.turn  = turn + 1
    else
        ExecutePlan(iPlayer, plan, turn)
    end
end

GameEvents.CityCaptureComplete.Add(OnCityCaptured)
GameEvents.PlayerDoTurn.Add(OnPlayerDoTurn)