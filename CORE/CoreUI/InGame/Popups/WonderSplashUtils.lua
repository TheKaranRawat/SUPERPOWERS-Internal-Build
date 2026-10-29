--====================================================================================================================
-- SPLASH SCREEN UTILITIES
--====================================================================================================================

-- ---------------------------------------------------------------------------
-- NATIONAL WONDERS
-- ---------------------------------------------------------------------------
local g_NationalWonders = nil
local g_PlayerWonders = nil

local function CacheNationalWonders()
	g_NationalWonders = {}
	for building in GameInfo.Buildings() do
		local buildingClass = GameInfo.BuildingClasses[building.BuildingClass]
		if buildingClass 
			and buildingClass.MaxPlayerInstances == 1 
			and building.WonderSplashImage 
		then
			table.insert(g_NationalWonders, building.ID)
		end
	end
end

local function CachePlayerWonders(pPlayer)
	local playerWonders = {}
	g_PlayerWonders[pPlayer:GetID()] = playerWonders

	for _, iBuilding in ipairs(g_NationalWonders) do
		playerWonders[iBuilding] = (pPlayer:CountNumBuildings(iBuilding) > 0)
	end
end

local function CacheAllPlayerWonders()
	if not g_NationalWonders then
		CacheNationalWonders()
	end

	g_PlayerWonders = {}
	for iPlayer = 0, GameDefines.MAX_MAJOR_CIVS - 1 do
		local pPlayer = Players[iPlayer]
		if pPlayer:IsHuman() then
			CachePlayerWonders(pPlayer)
		end
	end
end

-- ---------------------------------------------------------------------------
-- NATIONAL PROJECTS
-- ---------------------------------------------------------------------------
local g_NationalProjects = nil
local g_PlayerProjects = nil

local lastProject = -1

local function CacheNationalProjects()
	g_NationalProjects = {}
	for project in GameInfo.Projects() do
		if project.MovieDefineTag then
			table.insert(g_NationalProjects, project.ID)
		end
	end
end

local function CachePlayerProjects(pPlayer)
	local playerProjects = {}
	g_PlayerProjects[pPlayer:GetID()] = playerProjects

	local pTeam = Teams[pPlayer:GetTeam()]
	for _, iProject in ipairs(g_NationalProjects) do
		playerProjects[iProject] = pTeam:GetProjectCount(iProject)
	end
end

local function CacheAllPlayerProjects()
	if not g_NationalProjects then
		CacheNationalProjects()
	end

	g_PlayerProjects = {}
	for iPlayer = 0, GameDefines.MAX_MAJOR_CIVS - 1 do
		local pPlayer = Players[iPlayer]
		if pPlayer:IsHuman() then
			CachePlayerProjects(pPlayer)
		end
	end
end

-- ---------------------------------------------------------------------------
-- EVENT HANDLERS
-- ---------------------------------------------------------------------------

local function OnCityChanged(hexPos, iPlayer, iCity, iNewPlayer)
	local pPlayer = Players[iPlayer]
	if pPlayer:IsHuman() then
		if not g_PlayerWonders then
			CacheAllPlayerWonders()
		else
			CachePlayerWonders(pPlayer)
		end
		if not g_PlayerProjects then
			CacheAllPlayerProjects()
		else
			CachePlayerProjects(pPlayer)
		end
	end
end

local function OnCityUpdate()
	local pPlayer = Players[Game.GetActivePlayer()]
	local pTeam = Teams[pPlayer:GetTeam()]

	if pPlayer:IsHuman() then
		if not g_PlayerWonders then
			CacheAllPlayerWonders()
		end
		if not g_PlayerProjects then
			CacheAllPlayerProjects()
		end

		local playerWonders = g_PlayerWonders[pPlayer:GetID()]
		if playerWonders then
			for iBuilding, bBuilt in pairs(playerWonders) do
				if not bBuilt and pPlayer:CountNumBuildings(iBuilding) > 0 then
					playerWonders[iBuilding] = true
					Events.SerialEventGameMessagePopup({
						Type = ButtonPopupTypes.BUTTONPOPUP_WONDER_COMPLETED_ACTIVE_PLAYER,
						Data1 = iBuilding
					})
				end
			end
		end

		local playerProjects = g_PlayerProjects[pPlayer:GetID()]
		if playerProjects then
			for iProject, iBuilt in pairs(playerProjects) do
				if iBuilt < GameInfo.Projects[iProject].MaxTeamInstances then
					local iProjectCount = pTeam:GetProjectCount(iProject)
					if iProjectCount > iBuilt then
						playerProjects[iProject] = iProjectCount
						if lastProject ~= iProject then
							Events.SerialEventGameMessagePopup({
								Type = ButtonPopupTypes.BUTTONPOPUP_WONDER_COMPLETED_ACTIVE_PLAYER,
								Data1 = -1,
								Data2 = iProject
							})
							lastProject = iProject
						end
					end
				end
			end
		end
	end
end

local function OnPlayerChange()
	lastProject = -1
end

-- ---------------------------------------------------------------------------
-- INITIALIZE/REMOVE
-- ---------------------------------------------------------------------------

local function Initialize()
	Events.SerialEventCityDestroyed.Add(OnCityChanged)
	Events.SerialEventCityCaptured.Add(OnCityChanged)
	Events.SerialEventCityInfoDirty.Add(OnCityUpdate)
	Events.SpecificCityInfoDirty.Add(OnCityUpdate)
	Events.GameplaySetActivePlayer.Add(OnPlayerChange)
end

local function Remove()
	Events.SerialEventCityDestroyed.Remove(OnCityChanged)
	Events.SerialEventCityCaptured.Remove(OnCityChanged)
	Events.SerialEventCityInfoDirty.Remove(OnCityUpdate)
	Events.SpecificCityInfoDirty.Remove(OnCityUpdate)
	Events.GameplaySetActivePlayer.Remove(OnPlayerChange)
end

Initialize()
