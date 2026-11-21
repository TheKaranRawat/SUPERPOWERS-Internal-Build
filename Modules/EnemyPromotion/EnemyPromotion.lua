-- Grants PROMOTION_ENEMY_WAR_FURY to combat units of non-human players that are
-- at war with a human player. Removes it again on peace.
--
-- Multiplayer: runs as a gameplay script, so every client executes the same logic
--   against the same game state. No UI calls, no Game.GetActivePlayer(), no
--   randomness, no state that affects outcomes beyond what the game itself stores.
-- Performance: units are only scanned when a player's war state changes, plus a
--   staggered safety pass every RECONCILE_INTERVAL turns.

local PROMO_ID = GameInfoTypes.PROMOTION_ENEMY_WAR_FURY
if PROMO_ID == nil then return end   -- DB entry failed to load; do nothing

local BUFF_BARBARIANS      = true
local BUFF_CITY_STATES     = true
local RECONCILE_INTERVAL   = 10      -- turns between safety scans per player
local MAX_MAJOR            = GameDefines.MAX_MAJOR_CIVS

-- Last state we applied per player. Not saved: after a load it is empty, which
-- just triggers one idempotent re-sync, so clients can never disagree on outcome.
local appliedState = {}

-- Team IDs of living human majors, rebuilt at most once per turn.
local humanTeamIDs   = {}
local humanCacheTurn = -1

local function RefreshHumans()
    local turn = Game.GetGameTurn()
    if turn == humanCacheTurn then return end
    humanCacheTurn = turn
    humanTeamIDs = {}
    for i = 0, MAX_MAJOR - 1 do
        local p = Players[i]
        if p:IsAlive() and p:IsHuman() then
            humanTeamIDs[#humanTeamIDs + 1] = p:GetTeam()
        end
    end
end

local function IsEnemy(player)
    if player:IsHuman() then return false end
    if player:IsBarbarian() then return BUFF_BARBARIANS end
    if player:IsMinorCiv() and not BUFF_CITY_STATES then return false end

    local team = Teams[player:GetTeam()]
    for i = 1, #humanTeamIDs do
        if team:IsAtWar(humanTeamIDs[i]) then return true end
    end
    return false
end

local function SyncUnits(player, enemy)
    for unit in player:Units() do
        if unit:IsCombatUnit() and unit:IsHasPromotion(PROMO_ID) ~= enemy then
            unit:SetHasPromotion(PROMO_ID, enemy)
        end
    end
end

local function OnPlayerDoTurn(playerID)
    local player = Players[playerID]
    if not player:IsAlive() then return end

    RefreshHumans()
    local enemy = IsEnemy(player)

    -- Scan only if state changed, or this player's staggered safety pass is due
    -- (catches captured/gifted units that kept or lack the promotion).
    local due = (Game.GetGameTurn() + playerID) % RECONCILE_INTERVAL == 0
    if appliedState[playerID] ~= enemy or due then
        SyncUnits(player, enemy)
        appliedState[playerID] = enemy
    end
end

GameEvents.PlayerDoTurn.Add(OnPlayerDoTurn)

-- Optional: buff freshly created units immediately instead of next turn.
if GameEvents.UnitCreated then
    GameEvents.UnitCreated.Add(function(playerID, unitID)
        if appliedState[playerID] then
            local unit = Players[playerID]:GetUnitByID(unitID)
            if unit and unit:IsCombatUnit() and not unit:IsHasPromotion(PROMO_ID) then
                unit:SetHasPromotion(PROMO_ID, true)
            end
        end
    end)
end