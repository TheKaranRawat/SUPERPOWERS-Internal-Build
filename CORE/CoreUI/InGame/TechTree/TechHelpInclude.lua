include "ShortTechHelp"

local g_bEraRestrictedTech = false
for row in GameInfo.Sapiens_ModOptions{Name = "ERA_RESTRICTED_TECH"} do
    g_bEraRestrictedTech = (row.Value == 1)
end

local g_tGateTechs = {}
if g_bEraRestrictedTech then
    for row in GameInfo.Technologies() do
        local pEra = GameInfo.Eras[row.Era]
        if pEra and not row.Disable then
            table.insert(g_tGateTechs, {ID = row.ID, Type = row.Type, EraID = pEra.ID})
        end
    end
end

function GetHelpTextForTech(iTechID)

    local pTechInfo = GameInfo.Technologies[iTechID]
    if not pTechInfo then return "" end

    local pActiveTeam = Teams[Game.GetActiveTeam()]
    local pActivePlayer = Players[Game.GetActivePlayer()]
    local pTeamTechs = pActiveTeam:GetTeamTechs()
    local iTechCost = pActivePlayer:GetResearchCost(iTechID)
    local bHasTech = pTeamTechs:HasTech(iTechID)

    local L = Locale.ConvertTextKey
    local tip = ""

    -- Name
    tip = tip .. Locale.ToUpper(L(pTechInfo.Description))

    if bHasTech then
        tip = tip .. " [COLOR_POSITIVE_TEXT](" .. L("TXT_KEY_RESEARCHED") .. ")[ENDCOLOR]"
    end

    -- Cost/Progress
    local iProgress = pActivePlayer:GetResearchProgress(iTechID)
    local bShowProgress = iProgress > 0 and not bHasTech

    tip = tip .. "[NEWLINE][NEWLINE]"
    if bShowProgress then
        tip = tip .. L("TXT_KEY_TECH_HELP_COST_WITH_PROGRESS", iProgress, iTechCost)
    else
        tip = tip .. L("TXT_KEY_TECH_HELP_COST", iTechCost)
    end

    if g_bEraRestrictedTech and not bHasTech then
        local pTechEra = GameInfo.Eras[pTechInfo.Era]
        local pGateEra = pTechEra and GameInfo.Eras[pTechEra.ID - 2]
        if pGateEra then
            local tCivDisabled = {}
            local pCiv = GameInfo.Civilizations[pActivePlayer:GetCivilizationType()]
            if pCiv then
                for row in GameInfo.Civilization_DisableTechs{CivilizationType = pCiv.Type} do
                    tCivDisabled[row.TechType] = true
                end
            end
            for _, tGateTech in ipairs(g_tGateTechs) do
                if tGateTech.EraID <= pGateEra.ID and not tCivDisabled[tGateTech.Type] and not pTeamTechs:HasTech(tGateTech.ID) then
                    tip = tip .. "[NEWLINE][COLOR_NEGATIVE_TEXT]" .. L("TXT_KEY_GAIA_TECH_REQUIRES_ERA", L(pGateEra.Description)) .. "[ENDCOLOR]"
                    break
                end
            end
        end
    end

    -- Leads To
    local tLeadsTo = {}
    for row in GameInfo.Technology_PrereqTechs() do
        local pPrereqTech = GameInfo.Technologies[row.PrereqTech]
        local pLeadsToTech = GameInfo.Technologies[row.TechType]
        if pPrereqTech and pLeadsToTech and pTechInfo.ID == pPrereqTech.ID then
            table.insert(tLeadsTo, "[COLOR_POSITIVE_TEXT]" .. L(pLeadsToTech.Description) .. "[ENDCOLOR]")
        end
    end

    if #tLeadsTo > 0 then
        tip = tip .. "[NEWLINE]" .. L("TXT_KEY_TECH_HELP_LEADS_TO", table.concat(tLeadsTo, ", "))
    end

    -- Unlocks (Short Tech Help)
    local strUnlocks = GetShortTechHelp(iTechID, Game.GetActivePlayer())
    if strUnlocks ~= "" then
        tip = tip .. "[NEWLINE][NEWLINE]" .. strUnlocks
    end

    return tip
end
