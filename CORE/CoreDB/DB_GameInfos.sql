-- written by GAIA using Notepad++
CREATE TABLE IF NOT EXISTS Sapiens_DBUpdates (Name TEXT PRIMARY KEY, Value INTEGER DEFAULT 0);
INSERT OR IGNORE INTO Sapiens_DBUpdates (Name) VALUES ('DB_GameInfos');
--====================================================================================================================
-- BASE-TABLE COLUMNS  (ALTER: GACMOD-only scaling cols on the vanilla tables; DEFAULT 100 = no scaling)
--====================================================================================================================

-- GAME SPEEDS
-- (DEFAULT 100 = vanilla no-scaling)
ALTER TABLE GameSpeeds ADD COLUMN iTradeRouteDurationPercent INTEGER DEFAULT 100;	-- game-speed scaling (%) for trade-route duration (lifespan + plunder memory)
ALTER TABLE GameSpeeds ADD COLUMN iWLTKDPercent INTEGER DEFAULT 100;				-- game-speed scaling (%) for building-triggered WLTKD
ALTER TABLE GameSpeeds ADD COLUMN iEventYieldPercent INTEGER DEFAULT 100;			-- game-speed scaling (%) for instant/event yields
ALTER TABLE GameSpeeds ADD COLUMN iXPNeededPercent INTEGER DEFAULT 100;				-- game-speed scaling (%) for the unit XP-to-level threshold
ALTER TABLE GameSpeeds ADD COLUMN iInfluencePerTurnPercent INTEGER DEFAULT 0;		-- game-speed scaling (%) for the per-turn city-state influence change; 0 = GoldGiftMod (vanilla)
ALTER TABLE GameSpeeds ADD COLUMN iWarTimerPercent INTEGER DEFAULT 100;			-- game-speed scaling (%) for the turns before a stalled or conquest war becomes peaceable

-- Per-speed pacing for every vassalage timer; absent row = 0 = no minimum or wait.
CREATE TABLE IF NOT EXISTS _GameSpeed_Vassalage (
	GameSpeedType				TEXT PRIMARY KEY NOT NULL REFERENCES GameSpeeds(Type),
	iMinVassalTurns				INTEGER DEFAULT 0,	-- min turns of capitulated vassalage before the vassal may break free
	iMinVoluntaryVassalTurns	INTEGER DEFAULT 0,	-- min turns of VOLUNTARY vassalage before the vassal may break free
	iMinVassalTaxTurns			INTEGER DEFAULT 0,	-- min turns between vassal tax-rate changes
	iTurnsBetweenVassals		INTEGER DEFAULT 0,	-- turns to wait after a revoked agreement before signing a new one
	iMinVassalLiberateTurns		INTEGER DEFAULT 0 );	-- min turns of vassalage before the master may liberate

-- WORLDS
ALTER TABLE Worlds ADD COLUMN iTradeRouteDistanceMod INTEGER DEFAULT 100;	-- map-size scaling (%) for trade route distance
ALTER TABLE Worlds ADD COLUMN iFollowerPercentMod INTEGER DEFAULT 100;		-- map-size scaling (%) for a building's iFollowerPercentRequired

--====================================================================================================================
-- GAME INFO TABLE EXTENSIONS (sidecars)
--====================================================================================================================

------------------------------------------------------------------------------------------------------------------------
-- CIVILIZATIONS
------------------------------------------------------------------------------------------------------------------------

-- City-States a Civilization reserves: while the civ is in game the listed minors never spawn at game start, staying
-- available for runtime founding (e.g. Carthage's Phoenician colonies).
CREATE TABLE IF NOT EXISTS _Civilization_CityStateOverrides (
	CivilizationType	TEXT NOT NULL REFERENCES Civilizations(Type),
	MinorCivType		TEXT NOT NULL REFERENCES MinorCivilizations(Type),
	PRIMARY KEY (CivilizationType, MinorCivType)
);

-- Example -- Carthage's Phoenician colonies:
--     INSERT INTO _Civilization_CityStateOverrides (CivilizationType, MinorCivType) VALUES
--         ('CIVILIZATION_CARTHAGE', 'MINOR_CIV_BYBLOS'), ('CIVILIZATION_CARTHAGE', 'MINOR_CIV_TYRE');

-- Embarked-unit graphic a Civilization uses (per-civ boat); an absent row = vanilla era-boats.
-- UnitArtInfo = an ART_DEF_UNIT_* (ART_DEF_UNIT__EMBARK_AFRI / _ASIA / _AMER).
CREATE TABLE IF NOT EXISTS _Civilization_EmbarkationOverrides (
	CivType		TEXT NOT NULL PRIMARY KEY REFERENCES Civilizations(Type),
	UnitArtInfo	TEXT NOT NULL
);

-- Mountain-city graphic a Civilization uses; an absent row = the vanilla bare mountain city.
-- Founding on a Mountain requires a policy with _Policies_Extensions.bCanCrossMountains, so only a civ
-- holding such a policy can ever reach this (currently Georgia and Inca, both via their trait-policy).
-- ImprovementType = a GraphicalOnly improvement; it carries the ArtDefineTag for the look.
CREATE TABLE IF NOT EXISTS _Civilization_MountainCityOverrides (
	CivilizationType	TEXT NOT NULL PRIMARY KEY REFERENCES Civilizations(Type),
	ImprovementType		TEXT NOT NULL REFERENCES Improvements(Type)
);

-- Start-bias companions to the vanilla Civilization_Start_* family.
-- Row present + true = the civ's start position seeks that terrain.
CREATE TABLE IF NOT EXISTS _Civilization_Start_Prefer_Mountain (
	CivilizationType	TEXT NOT NULL REFERENCES Civilizations(Type),
	StartPreferMountain	BOOLEAN DEFAULT 0
);

CREATE TABLE IF NOT EXISTS _Civilization_Start_Prefer_Snow (
	CivilizationType	TEXT NOT NULL REFERENCES Civilizations(Type),
	StartPreferSnow		BOOLEAN DEFAULT 0
);

------------------------------------------------------------------------------------------------------------------------
-- MINOR CIVILIZATIONS (City-States)
------------------------------------------------------------------------------------------------------------------------

-- City-State leader names/portraits for the City-State leader UI.
CREATE TABLE IF NOT EXISTS _MinorCivilization_Leaders (
	MinorCivType		TEXT NOT NULL PRIMARY KEY REFERENCES MinorCivilizations(Type),
	CSLeaderName		TEXT DEFAULT NULL,
	CSLeaderIcon		TEXT NOT NULL,
	CSLeaderArtist		TEXT DEFAULT NULL
);

-- Per-City-State Suzerainty (ally) bonuses: free policy held while Ally, plus ally/wonder help text for the CS UI.
CREATE TABLE IF NOT EXISTS _MinorCivilization_AllyBonuses (
	MinorCivType		TEXT NOT NULL PRIMARY KEY REFERENCES MinorCivilizations(Type),
	AllyBonusPolicy		TEXT DEFAULT NULL REFERENCES Policies(Type),
	AllyBonusHelp		TEXT DEFAULT NULL,
	CSWonderHelp		TEXT DEFAULT NULL
);

-- Per-City-State unique luxury: the OnlyMinorCivs resource a Mercantile City-State places on its first city instead of a random one.
-- BuildingType: the hidden building that grants it instead, used while the CS_LUXURY_BUILDING mod option is on.
CREATE TABLE IF NOT EXISTS _MinorCivilization_UniqueLuxury (
	MinorCivType		TEXT NOT NULL PRIMARY KEY REFERENCES MinorCivilizations(Type),
	ResourceType		TEXT NOT NULL REFERENCES Resources(Type),
	BuildingType		TEXT DEFAULT NULL REFERENCES Buildings(Type)
);

------------------------------------------------------------------------------------------------------------------------
-- GOODY HUTS (ancient ruins)
------------------------------------------------------------------------------------------------------------------------

-- Extra goody-hut effects, applied on hut pickup.
CREATE TABLE IF NOT EXISTS _GoodyHuts_Extensions (
	GoodyType								TEXT PRIMARY KEY REFERENCES GoodyHuts(Type),

	iFreeTiles								INTEGER DEFAULT 0,
	-- Number of tiles the closest city immediately acquires (its next buyable plots). 0 = none

	iProduction								INTEGER DEFAULT 0,
	-- Production granted to the closest city. 0 = none

	iScience								INTEGER DEFAULT 0
	-- Beakers granted, banked as research overflow toward the current/next tech. 0 = none
);

------------------------------------------------------------------------------------------------------------------------
-- HANDICAPS (difficulty)
------------------------------------------------------------------------------------------------------------------------

-- Difficulty-scaled AI and barbarian-camp extras.
CREATE TABLE IF NOT EXISTS _HandicapInfos_Extensions (
	HandicapType							TEXT PRIMARY KEY REFERENCES HandicapInfos(Type),

	iBarbCampFood							INTEGER DEFAULT 0,
	-- Food granted to the nearest city when a Barbarian camp is cleared (keys off the game difficulty). 0 = vanilla (gold only)

	iBarbCampProduction						INTEGER DEFAULT 0,
	-- Production granted to the nearest city when a Barbarian camp is cleared. 0 = vanilla (gold only)

	iMinorCivGoldFreeUnits					INTEGER DEFAULT 0
	-- Units a city-state pays no gold maintenance on. Keys off the GAME difficulty, not the minor's own
	-- handicap row (frozen at Prince by MINOR_CIV_HANDICAP), so city-state economy scales with difficulty
	-- the way their production already does via AITrainPercent. 0 = vanilla (every unit paid from the first)
);

------------------------------------------------------------------------------------------------------------------------
-- WORLDS (map sizes)
------------------------------------------------------------------------------------------------------------------------

-- Map-size-scaled AI extras.
CREATE TABLE IF NOT EXISTS _Worlds_Extensions (
	WorldSizeType							TEXT PRIMARY KEY REFERENCES Worlds(Type),

	iFarSiteDistancePercent					INTEGER DEFAULT 100
	-- % of the difficulty's sea barbarian target range an AI founder carried in its own ship keeps between its capital and its site on this map size. 100 = no scaling
);

------------------------------------------------------------------------------------------------------------------------
-- PROCESSES
------------------------------------------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS _Processes_Extensions (
	ProcessType					TEXT PRIMARY KEY REFERENCES Processes(Type),

	bProductionStorage				BOOLEAN DEFAULT 0,
	-- Process stockpiles [ICON_PRODUCTION] into overflow per era (gated by GAMEOPTION_GAIA_PRODUCTION_STORAGE)

	ePolicyPrereq					TEXT DEFAULT NULL REFERENCES Policies(Type)
	-- Process is only offered once this policy is adopted (NULL = no gate)
);

------------------------------------------------------------------------------------------------------------------------
-- PROJECTS
------------------------------------------------------------------------------------------------------------------------

-- Policy granted to the player who completes a Project FIRST (Manhattan / Apollo / National Rail first-mover bonus).
CREATE TABLE IF NOT EXISTS _Project_PolicyIfFirst (
	ProjectType		TEXT PRIMARY KEY REFERENCES Projects(Type),
	ePolicyType		TEXT DEFAULT NULL REFERENCES Policies(Type)
);

-- Repeatable projects (e.g. PROSPECTING): a row makes the project repeatable (row-presence = authorization).
CREATE TABLE IF NOT EXISTS _Project_Repeats (
	ProjectType							TEXT PRIMARY KEY REFERENCES Projects(Type),

	iExtraCostPerRepeat					INTEGER DEFAULT 0,
	-- Flat production added to the cost per prior completion by the team, applied after all cost scaling.

	iMaxRepeats							INTEGER DEFAULT 1
	-- Maximum completions per team; -1 = infinite
);

-- Resource bonuses granted when a Project is completed (first completer for normal projects, every completion for repeatable).
CREATE TABLE IF NOT EXISTS _Project_ResourceQuantity (
	ProjectType		TEXT REFERENCES Projects(Type),
	ResourceType	TEXT REFERENCES Resources(Type),
	iQuantity		INTEGER,
	PRIMARY KEY (ProjectType, ResourceType)
);

------------------------------------------------------------------------------------------------------------------------
-- CORPORATIONS
------------------------------------------------------------------------------------------------------------------------

-- Corporate market-share tier policies (Mod Option ECONOMICS): the civ whose held Great Works of Corporation
-- reach a tier (GD_CORPORATIONS_TIER<n>_WORKS, highest tier only) holds that tier's PolicyType and loses it
-- with the tier. The policy carries every effect.
CREATE TABLE IF NOT EXISTS _Corporation_ShareTierPolicyGrant (
	iTier									INTEGER PRIMARY KEY,
	-- Share tier this row pairs (1..3)

	PolicyType								TEXT REFERENCES Policies(Type)
);

------------------------------------------------------------------------------------------------------------------------
-- ERAS
------------------------------------------------------------------------------------------------------------------------

-- Costs of each tech-tree column, with the era the column belongs to.
CREATE TABLE IF NOT EXISTS _Era_ColumnCosts (
	GridX									INTEGER PRIMARY KEY,
	EraType									TEXT,
	-- Era the column belongs to; Slow Tech prices the column by it.
	TechCost								INTEGER NOT NULL,
	-- Research cost of every technology in this column, instead of its own Cost.
	WonderCost								INTEGER
	-- Production cost of every world wonder whose tech sits in this column.
);

------------------------------------------------------------------------------------------------------------------------
-- TECHNOLOGIES
------------------------------------------------------------------------------------------------------------------------

-- Specialist yields granted when a Technology is researched (shown in the Tech Award popup).
CREATE TABLE IF NOT EXISTS _Specialist_TechYieldChanges (
	SpecialistType	TEXT REFERENCES Specialists(Type),
	TechType		TEXT REFERENCES Technologies(Type),
	YieldType		TEXT REFERENCES Yields(Type),
	Yield			INTEGER,
	PRIMARY KEY (SpecialistType, TechType, YieldType)
);

CREATE TABLE IF NOT EXISTS _Technologies_Extensions (
	TechType								TEXT PRIMARY KEY REFERENCES Technologies(Type),

	bCorporations							INTEGER DEFAULT 0
	-- Researching this tech enables founding Corporations (Great Merchants may create their Corporation great work).
);

-- A technology whose discovery grants a policy: every player of a team that knows TechType holds PolicyType.
-- The policy carries the effect.
CREATE TABLE IF NOT EXISTS _Tech_PolicyGrant (
	TechType								TEXT PRIMARY KEY REFERENCES Technologies(Type),
	PolicyType								TEXT NOT NULL REFERENCES Policies(Type)
);

------------------------------------------------------------------------------------------------------------------------
-- VICTORIES
------------------------------------------------------------------------------------------------------------------------

-- GAIA Economic/Religious victory flags (default 0 = not a Gaia victory).
CREATE TABLE IF NOT EXISTS _Victories_Extensions (
	VictoryType							TEXT PRIMARY KEY REFERENCES Victories(Type),
	bEconomic								INTEGER DEFAULT 0,
	-- Economic victory flag (National Rail + a gold target + a % of map luxuries)
	bReligious								INTEGER DEFAULT 0
	-- Religious victory flag (a % of cities + a follower threshold)
);

------------------------------------------------------------------------------------------------------------------------
-- RESOLUTIONS (World Congress)
------------------------------------------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS _Resolutions_Extensions (
	ResolutionType							TEXT PRIMARY KEY REFERENCES Resolutions(Type),

	bEmbargoIdeology						INTEGER DEFAULT 0,
	-- Ideological Divide: embargo trade between opposing ideologies

	bEndAllCurrentVassals					INTEGER DEFAULT 0
	-- Passing this resolution immediately ends all current vassalage agreements (only under GAMEOPTION_GAIA_VASSALAGE)
);

-- A resolution that grants a policy: every member of a league in which a resolution of ResolutionType is active holds
-- PolicyType and loses it on repeal. The policy carries the effect.
CREATE TABLE IF NOT EXISTS _Resolution_PolicyGrant (
	ResolutionType							TEXT PRIMARY KEY REFERENCES Resolutions(Type),
	PolicyType								TEXT NOT NULL REFERENCES Policies(Type)
);

-- A World Congress project reward that grants a policy: the civ that reaches the reward's tier holds PolicyType from then
-- on (tiers fall through, a first place receives every tier's reward). The policy carries the effect.
CREATE TABLE IF NOT EXISTS _LeagueProjectReward_PolicyGrant (
	RewardType								TEXT PRIMARY KEY REFERENCES LeagueProjectRewards(Type),
	PolicyType								TEXT NOT NULL REFERENCES Policies(Type)
);

--====================================================================================================================
-- POST-BUILD SQL
--====================================================================================================================
-- Statements the Core DLL runs once the WHOLE database exists: after every mod has loaded, before any info class
-- is cached. The engine's PostDefines table is
-- the model, generalised to arbitrary SQL: a mod registers here whatever has to see every other mod's rows.
-- Rows run in iOrder, then insertion order. They run on EVERY launch, so each statement must be idempotent
-- (INSERT OR IGNORE, NOT EXISTS guards). A failing statement is logged to SapiensMod.log and skipped, the rest
-- still run. One statement per row, no trailing semicolon; a quote inside the text is doubled as SQL requires.
CREATE TABLE IF NOT EXISTS _PostBuildSQL (
	Name	TEXT PRIMARY KEY,
	iOrder	INTEGER DEFAULT 0,
	SQL		TEXT NOT NULL
);
--====================================================================================================================
UPDATE Sapiens_DBUpdates SET Value = 1 WHERE Name = 'DB_GameInfos';
