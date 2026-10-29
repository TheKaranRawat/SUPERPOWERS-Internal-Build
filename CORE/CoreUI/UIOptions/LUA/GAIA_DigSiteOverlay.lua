--====================================================================================================================
-- DIG SITE OVERLAY
--====================================================================================================================

local iArchaeologistClass = GameInfoTypes.UNITCLASS_ARCHAEOLOGIST
local iArtifacts = GameInfoTypes.RESOURCE_ARTIFACTS
local iHiddenArtifacts = GameInfoTypes.RESOURCE_HIDDEN_ARTIFACTS

local hiddenRow = iHiddenArtifacts and GameInfo.Resources{ Type = "RESOURCE_HIDDEN_ARTIFACTS" }()
local revealRow = hiddenRow and hiddenRow.PolicyReveal and GameInfo.Policies[hiddenRow.PolicyReveal]
local iRevealPolicy = revealRow and revealRow.ID or -1

local iMapW = Map.GetGridSize()

local function GetDigTargets(pPlayer)
    local targets = {}
    for pUnit in pPlayer:Units() do
        if pUnit:GetUnitClassType() == iArchaeologistClass then
            local pMissionPlot = pUnit:LastMissionPlot()
            if pMissionPlot then
                targets[pMissionPlot:GetY() * iMapW + pMissionPlot:GetX()] = true
            end
        end
    end
    return targets
end

function ShowDigSitesForUnit(pPlayer, pUnit)
    if not (pPlayer and pUnit) or pUnit:GetUnitClassType() ~= iArchaeologistClass then
        return nil
    end

    local eTeam = pPlayer:GetTeam()
    local bShowHidden = iRevealPolicy >= 0 and pPlayer:HasPolicy(iRevealPolicy)
    local targets = GetDigTargets(pPlayer)
    local iPainted = 0

    for iPlot = 0, Map.GetNumPlots() - 1 do
        local pPlot = Map.GetPlotByIndex(iPlot)
        if pPlot and pPlot:IsRevealed(eTeam) then
            local iResource = pPlot:GetResourceType()
            if iResource == iArtifacts or (bShowHidden and iResource == iHiddenArtifacts) then
                local colour = targets[iPlot] and OverlayColours.DigTarget or OverlayColours.DigSite
                Events.SerialEventHexHighlight(ToHexFromGrid(Vector2(pPlot:GetX(), pPlot:GetY())), true, colour)
                iPainted = iPainted + 1
            end
        end
    end

    return iPainted
end
