local function GetShortTechUniqueBuildables(civType)

	local validUnitBuilds = {}
	local validBuildingBuilds = {}
	local validImprovementBuilds = {}

	-- Units
	for unitClass in GameInfo.UnitClasses() do
		validUnitBuilds[unitClass.Type] = unitClass.DefaultUnit
	end
	for override in GameInfo.Civilization_UnitClassOverrides() do
		if override.CivilizationType == civType then
			validUnitBuilds[override.UnitClassType] = override.UnitType
		end
	end

	-- Buildings
	for buildingClass in GameInfo.BuildingClasses() do
		validBuildingBuilds[buildingClass.Type] = buildingClass.DefaultBuilding
	end
	for override in GameInfo.Civilization_BuildingClassOverrides() do
		if override.CivilizationType == civType then
			validBuildingBuilds[override.BuildingClassType] = override.BuildingType
		end
	end

	-- Improvements
	for improvement in GameInfo.Improvements() do
		if improvement.CivilizationType == civType or improvement.CivilizationType == nil then
			validImprovementBuilds[improvement.Type] = improvement.Type
		else
			validImprovementBuilds[improvement.Type] = nil
		end
	end

	return validUnitBuilds, validBuildingBuilds, validImprovementBuilds
end

function GetShortTechHelp(iTechID, iPlayerID)

	local pPlayer = Players[iPlayerID]
	if not pPlayer or not pPlayer:IsAlive() then return "" end

	local validUnitBuilds, validBuildingBuilds, validImprovementBuilds = GetShortTechUniqueBuildables(GameInfo.Civilizations[pPlayer:GetCivilizationType()].Type)

	local thisTech = GameInfo.Technologies[iTechID]
	if not thisTech then return "" end

	local techType = thisTech.Type
	local condition = "TechType = '" .. techType .. "'"
	local prereqCondition = "PrereqTech = '" .. techType .. "'"
	local otherPrereqCondition = "TechPrereq = '" .. techType .. "'"
	local revealCondition = "TechReveal = '" .. techType .. "'"

	local L = Locale.ConvertTextKey
	local UnlocksString = ""
	
	-- Units
	local UnitString = L("TXT_KEY_GAIA_SHORT_TECH_HELP_UNITS")
	local numUnits = 0
	for unit in GameInfo.Units(prereqCondition) do
		if unit.ShowInPedia and (validUnitBuilds[unit.Class] == unit.Type) then
			if numUnits > 0 then UnitString = UnitString .. "[NEWLINE]" end
			UnitString = UnitString .. " [ICON_BULLET] " .. L(unit.Description)
			numUnits = numUnits + 1
		end
	end
	if numUnits > 0 then UnlocksString = UnlocksString .. UnitString end

	-- Buildings and Wonders
	local BuildingString = L("TXT_KEY_GAIA_SHORT_TECH_HELP_BUILDINGS")
	local WonderString   = L("TXT_KEY_GAIA_SHORT_TECH_HELP_WONDERS")
	local numBuildings, numWonders = 0, 0
	for building in GameInfo.Buildings(prereqCondition) do
		if validBuildingBuilds[building.BuildingClass] == building.Type then
			local buildingClass = GameInfo.BuildingClasses[building.BuildingClass]
			local targetString, targetCount
			if buildingClass.MaxGlobalInstances > 0 then
				targetString, targetCount = WonderString, numWonders
			else
				targetString, targetCount = BuildingString, numBuildings
			end
			if targetCount > 0 then targetString = targetString .. "[NEWLINE]" end
			targetString = targetString .. " [ICON_BULLET] " .. L(building.Description)
			if buildingClass.MaxGlobalInstances > 0 then
				WonderString, numWonders = targetString, numWonders + 1
			else
				BuildingString, numBuildings = targetString, numBuildings + 1
			end
		end
	end
	if numBuildings > 0 then UnlocksString = UnlocksString .. BuildingString end
	if numWonders > 0  then UnlocksString = UnlocksString .. WonderString  end

	-- Projects
	local ProjectString = L("TXT_KEY_GAIA_SHORT_TECH_HELP_PROJECTS")
	local numProjects = 0
	for project in GameInfo.Projects(otherPrereqCondition) do
		if numProjects > 0 then ProjectString = ProjectString .. "[NEWLINE]" end
		ProjectString = ProjectString .. " [ICON_BULLET] " .. L(project.Description)
		numProjects = numProjects + 1
	end
	if numProjects > 0 then UnlocksString = UnlocksString .. ProjectString end

	-- Processes
	local ProcessString = L("TXT_KEY_GAIA_SHORT_TECH_HELP_PROCESSES")
	local numProcesses = 0
	for process in GameInfo.Processes(otherPrereqCondition) do
		if numProcesses > 0 then ProcessString = ProcessString .. "[NEWLINE]" end
		ProcessString = ProcessString .. " [ICON_BULLET] " .. L(process.Description)
		numProcesses = numProcesses + 1
	end
	if numProcesses > 0 then UnlocksString = UnlocksString .. ProcessString end

	-- Resources
	local ResourceString = L("TXT_KEY_GAIA_SHORT_TECH_HELP_RESOURCES")
	local numResources = 0
	for resource in GameInfo.Resources(revealCondition) do
		if numResources == 0 then ResourceString = ResourceString .. " [ICON_BULLET] " end
		if numResources > 0  then ResourceString = ResourceString .. ", " end
		ResourceString = ResourceString .. L(resource.IconString) .. " " .. L(resource.Description)
		numResources = numResources + 1
	end
	if numResources > 0 then UnlocksString = UnlocksString .. ResourceString end

	-- Builds
	local BuildString = L("TXT_KEY_GAIA_SHORT_TECH_HELP_BUILDS")
	local numBuilds = 0
	for build in GameInfo.Builds{ PrereqTech = techType, ShowInPedia = 1 } do
		if not build.ImprovementType or (validImprovementBuilds[build.ImprovementType] == build.ImprovementType) then
			if numBuilds > 0 then BuildString = BuildString .. "[NEWLINE]" end
			BuildString = BuildString .. " [ICON_BULLET] " .. L(build.Description)
			numBuilds = numBuilds + 1
		end
	end
	if numBuilds > 0 then UnlocksString = UnlocksString .. BuildString end

	-- Special Abilities
	local numAbilities = 0
	local abilitiesString = L("TXT_KEY_GAIA_SHORT_TECH_HELP_ACTIONS") .. " [ICON_BULLET] "

	local function AddAbility(textKey, ...)
		if numAbilities > 0 then abilitiesString = abilitiesString .. "[NEWLINE] [ICON_BULLET] " end
		abilitiesString = abilitiesString .. L(textKey, ...)
		numAbilities = numAbilities + 1
	end

	for row in GameInfo.Route_TechMovementChanges(condition) do
		AddAbility("TXT_KEY_CIVILOPEDIA_SPECIALABILITIES_MOVEMENT", GameInfo.Routes[row.RouteType].Description)
	end

	for grant in GameInfo._Tech_PolicyGrant("TechType = '" .. thisTech.Type .. "'") do
		for ext in GameInfo._Policies_Extensions("PolicyType = '" .. grant.PolicyType .. "'") do
			if (ext.iCityExtraWorkRange or 0) > 0 then AddAbility("TXT_KEY_GAIA_SHORT_TECH_HELP_CITY_WORKRANGE") end
		end
	end
	if thisTech.EmbarkedMoveChange > 0 then AddAbility("TXT_KEY_ABLTY_FAST_EMBARK_STRING") end
	if thisTech.AllowsEmbarking then AddAbility("TXT_KEY_ALLOWS_EMBARKING") end
	if thisTech.AllowsDefensiveEmbarking then AddAbility("TXT_KEY_ABLTY_DEFENSIVE_EMBARK_STRING") end
	if thisTech.EmbarkedAllWaterPassage and not Game.IsOption("GAMEOPTION_GAIA_REALISTIC_OCEAN_CROSSING") then AddAbility("TXT_KEY_ABLTY_OCEAN_EMBARK_STRING") end
	if thisTech.AllowEmbassyTradingAllowed then AddAbility("TXT_KEY_ABLTY_ALLOW_EMBASSY_STRING") end
	if thisTech.OpenBordersTradingAllowed then AddAbility("TXT_KEY_ABLTY_OPEN_BORDER_STRING") end
	if thisTech.DefensivePactTradingAllowed then AddAbility("TXT_KEY_ABLTY_D_PACT_STRING") end
	if thisTech.BridgeBuilding then AddAbility("TXT_KEY_ABLTY_BRIDGE_STRING") end
	if thisTech.MapVisible then AddAbility("TXT_KEY_REVEALS_ENTIRE_MAP") end
	if thisTech.InternationalTradeRoutesChange > 0 then AddAbility("TXT_KEY_ADDITIONAL_INTERNATIONAL_TRADE_ROUTE") end

	for row in GameInfo.Technology_TradeRouteDomainExtraRange(condition) do
		if row.Range > 0 then
			if GameInfo.Domains[row.DomainType].ID == DomainTypes.DOMAIN_LAND then
				AddAbility("TXT_KEY_EXTENDS_LAND_TRADE_ROUTE_RANGE")
			elseif GameInfo.Domains[row.DomainType].ID == DomainTypes.DOMAIN_SEA then
				AddAbility("TXT_KEY_EXTENDS_SEA_TRADE_ROUTE_RANGE")
			end
		end
	end

	if thisTech.InfluenceSpreadModifier > 0 then AddAbility("TXT_KEY_DOUBLE_TOURISM") end
	if thisTech.AllowsWorldCongress then AddAbility("TXT_KEY_ALLOWS_WORLD_CONGRESS") end
	if thisTech.ExtraVotesPerDiplomat > 0 then AddAbility("TXT_KEY_EXTRA_VOTES_FROM_DIPLOMATS", thisTech.ExtraVotesPerDiplomat) end

	for row in GameInfo.Technology_FreePromotions(condition) do
		local promotion = GameInfo.UnitPromotions[row.PromotionType]
		if promotion then
			AddAbility("TXT_KEY_FREE_PROMOTION_FROM_TECH", promotion.Description, promotion.Help)
		end
	end

	if thisTech.ResearchAgreementTradingAllowed then AddAbility("TXT_KEY_ABLTY_R_PACT_STRING") end

	if numAbilities > 0 then UnlocksString = UnlocksString .. abilitiesString end

	-- Yields
	local numYields = 0
	local yieldsString = L("TXT_KEY_GAIA_SHORT_TECH_HELP_YIELDS") .. " [ICON_BULLET] "

	for row in GameInfo._Specialist_TechYieldChanges(condition) do
		if numYields > 0 then yieldsString = yieldsString .. "[NEWLINE] [ICON_BULLET] " end
		yieldsString = yieldsString .. L("TXT_KEY_GAIA_SHORT_TECH_HELP_SPECIALISTS",
			GameInfo.Specialists[row.SpecialistType].Description,
			GameInfo.Yields[row.YieldType].Description, row.Yield,
			L(GameInfo.Yields[row.YieldType].IconString))
		numYields = numYields + 1
	end

	for row in GameInfo.Improvement_TechYieldChanges(condition) do
		local improvement = GameInfo.Improvements[row.ImprovementType]
		if improvement then
			if numYields > 0 then yieldsString = yieldsString .. "[NEWLINE] [ICON_BULLET] " end
			yieldsString = yieldsString .. L("TXT_KEY_CIVILOPEDIA_SPECIALABILITIES_YIELDCHANGES",
				improvement.Description,
				GameInfo.Yields[row.YieldType].Description, row.Yield,
				L(GameInfo.Yields[row.YieldType].IconString))
			numYields = numYields + 1
		end
	end

	for row in GameInfo.Improvement_TechNoFreshWaterYieldChanges(condition) do
		local improvement = GameInfo.Improvements[row.ImprovementType]
		if improvement then
			if numYields > 0 then yieldsString = yieldsString .. "[NEWLINE] [ICON_BULLET] " end
			yieldsString = yieldsString .. L("TXT_KEY_CIVILOPEDIA_SPECIALABILITIES_NOFRESHWATERYIELDCHANGES",
				improvement.Description,
				GameInfo.Yields[row.YieldType].Description, row.Yield,
				L(GameInfo.Yields[row.YieldType].IconString))
			numYields = numYields + 1
		end
	end

	for row in GameInfo.Improvement_TechFreshWaterYieldChanges(condition) do
		local improvement = GameInfo.Improvements[row.ImprovementType]
		if improvement then
			if numYields > 0 then yieldsString = yieldsString .. "[NEWLINE] [ICON_BULLET] " end
			yieldsString = yieldsString .. L("TXT_KEY_CIVILOPEDIA_SPECIALABILITIES_FRESHWATERYIELDCHANGES",
				improvement.Description,
				GameInfo.Yields[row.YieldType].Description, row.Yield,
				L(GameInfo.Yields[row.YieldType].IconString))
			numYields = numYields + 1
		end
	end

	if numYields > 0 then UnlocksString = UnlocksString .. yieldsString end

	return UnlocksString
end
