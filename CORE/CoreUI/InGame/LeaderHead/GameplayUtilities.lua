-- GameplayUtilities.lua
-- Set of common gameplay methods used by multiple UIs and scripts.
------------------------------------------------------------------------------
--	Copyright (c) 2009-2010 Firaxis Games, Inc. All rights reserved.
------------------------------------------------------------------------------

GameplayUtilities = {}
MapModData.leaderTitles = MapModData.leaderTitles or {}

function GameplayUtilities.GetLocalizedLeaderTitle(player)

    local playerID = player:GetID()
    local civID = player:GetCivilizationType()
    local civ = GameInfo.Civilizations[civID]

    local name
    local nickName = player:GetNickName()
    if nickName and #nickName > 0 and Game:IsNetworkMultiPlayer() then
        name = nickName
    elseif PreGame.GetLeaderName(playerID) ~= "" then
        name = PreGame.GetLeaderName(playerID)
    else
        local leaderID = player:GetLeaderType()
        local leaderInfo = GameInfo.Leaders[leaderID]
        name = leaderInfo.Description
    end

    local civDescription
    local civShortDescription = PreGame.GetCivilizationShortDescription(playerID)
    if civShortDescription and #civShortDescription > 0 then
        civDescription = civShortDescription
    else
        civDescription = civ.ShortDescription
    end

    -- Policy-based title
    local strInfo
    local iDominantBranch = player:GetDominantPolicyBranchForTitle()

    local title = MapModData.leaderTitles[playerID]
    if title and title ~= "" then
        strInfo = Locale.ConvertTextKey(title, name, civDescription)
    elseif iDominantBranch ~= -1 then
        local strTitle = GameInfo.PolicyBranchTypes[iDominantBranch].Title
        strInfo = Locale.ConvertTextKey(strTitle, name, civDescription)
    else
        strInfo = Locale.ConvertTextKey("TXT_KEY_LEADER_OF_CIV", name, civDescription)
    end

    return strInfo
end
