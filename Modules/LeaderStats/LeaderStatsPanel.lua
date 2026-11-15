local g_iPlayer = -1

local function Refresh()
    if g_iPlayer < 0 then return end
    local pl = Players[g_iPlayer]
    if not pl or not pl:IsAlive() then return end

    -- Hide sensitive numbers for human opponents in MP
    local hidden = pl:IsHuman() and Game.IsNetworkMultiPlayer()
    local function V(s) return hidden and "?" or s end

    -- One pass over units: army vs navy
    local army, navy = 0, 0
    for unit in pl:Units() do
        if unit:IsCombatUnit() then
            local d = unit:GetDomainType()
            if d == DomainTypes.DOMAIN_LAND then army = army + 1
            elseif d == DomainTypes.DOMAIN_SEA then navy = navy + 1 end
        end
    end

    -- One pass over cities: population
    local pop = 0
    for city in pl:Cities() do pop = pop + city:GetPopulation() end

    local techs = Teams[pl:GetTeam()]:GetTeamTechs():GetNumTechsKnown()

    local ideo = "None"
    local branch = pl:GetLateGamePolicyTree()
    if branch and branch >= 0 then
        ideo = Locale.ConvertTextKey(GameInfo.PolicyBranchTypes[branch].Description)
    end

    local supplied = pl:GetNumUnitsSupplied()
    local over     = pl:GetNumUnitsOutOfSupply()

    Controls.Title:SetText(Locale.ConvertTextKey(pl:GetCivilizationShortDescriptionKey()))
    Controls.Army:SetText(army .. " land / " .. navy .. " naval")
    Controls.Supply:SetText(V((supplied - over) .. "/" .. supplied .. "  |  " .. pl:GetMilitaryMight()))
    Controls.Gold:SetText(V(math.floor(pl:GetGold()) .. "  (" .. string.format("%+d", pl:CalculateGoldRate()) .. "/turn)"))
    Controls.Sci:SetText(V(string.format("%+d", pl:GetScience()) .. "/turn  |  " .. techs .. " techs"))
    Controls.Cities:SetText(pl:GetNumCities() .. " / " .. pop)
    Controls.Ideo:SetText(ideo)
end

--[[ tab button 
Controls.TabButton:RegisterCallback(Mouse.eLClick, function()
    local show = Controls.Panel:IsHidden()
    Controls.Panel:SetHide(not show)
    if show then Refresh() end        -- compute only when opened
end)
]]--

LuaEvents.LeaderStatsSetPlayer.Add(function(iPlayer)
    g_iPlayer = iPlayer
    Refresh()
end)

LuaEvents.LeaderStatsHide.Add(function()
    g_iPlayer = -1
end)

ContextPtr:SetShowHideHandler(function(bIsHide)
    if not bIsHide then Refresh() end
end)