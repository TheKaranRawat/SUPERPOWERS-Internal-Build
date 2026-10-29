-- written by GAIA using Notepad++
CREATE TABLE IF NOT EXISTS Sapiens_DBUpdates (Name TEXT PRIMARY KEY, Value INTEGER DEFAULT 0);
INSERT OR IGNORE INTO Sapiens_DBUpdates (Name) VALUES ('DB_Improvements');
--====================================================================================================================
-- IMPROVEMENT TABLE EXTENSIONS
--====================================================================================================================

------------------------------------------------------------------------------------------------------------------------
-- IMPROVEMENTS
------------------------------------------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS _Improvements_Extensions (
	ImprovementType						TEXT PRIMARY KEY REFERENCES Improvements(Type),

	bAddsFreshWater							INTEGER DEFAULT 0,
	-- Provides fresh water to adjacent tiles (same effect as river adjacency)

	bAllowsAirliftFrom						INTEGER DEFAULT 0,
	-- Air units may take off from this improvement (e.g. Forward Airbase)

	bAllowsAirliftTo						INTEGER DEFAULT 0,
	-- Air units may land at this improvement

	bAllowsDocking							INTEGER DEFAULT 0,
	-- Naval units can dock

	bAllowsRebaseTo							INTEGER DEFAULT 0,
	-- Air units may rebase to this improvement

	bBridge									INTEGER DEFAULT 0,
	-- Category tag: improvement is a Bridge (content-driven; e.g. the Golden Gate Bridge wonder grants bonus yields to all bBridge improvements)

	bCSLegation							INTEGER DEFAULT 0,
	-- city-state legation

	bCanal									INTEGER DEFAULT 0,
	-- Connects adjacent water plots (naval can transit, works inland, no coastal gating)

	bCityside							INTEGER DEFAULT 0,
	-- must be built adjacent to a city

	bClaimsTerritory						INTEGER DEFAULT 0,
	-- Building this improvement claims its plot (and surrounding tiles) for the owner, citadel-style (e.g. upgraded Fort)

	bGarrison								INTEGER DEFAULT 0,
	-- Counts as garrison: +1 unit stack room on the plot

	bMountainsMakesValid					INTEGER DEFAULT 0,
	-- Makes mountain plots passable to land units when plot has a road/rail route

	bNegatesFeatureDamage					INTEGER DEFAULT 0,
	-- Improvement on the plot negates feature damage (e.g. igloo on ice, station on volcano)

	bNegatesTerrainDamage					INTEGER DEFAULT 0,
	-- Improvement on the plot negates terrain damage (e.g. tunnel in mountain)

	bNeutralTerritory					INTEGER DEFAULT 0,
	-- can only be built in neutral (unowned) territory

	bNoCityAdjacent							INTEGER DEFAULT 0,
	-- Cannot be built adjacent to a city (e.g. Citadel)

	bNoFollowUp								INTEGER DEFAULT 0,
	-- Attackers in this improvement do not get a follow-up attack after a kill

	bRequiresFreshWater						INTEGER DEFAULT 0,
	-- Hard placement gate: the plot must be Fresh Water (river/lake/oasis adjacency). The exact inverse of the
	-- vanilla NoFreshWater column. Note vanilla FreshWaterMakesValid is PERMISSIVE (it only adds validity) and
	-- cannot express a requirement, and iRequiresXAdjacentWater counts adjacent WATER PLOTS, which a riverside
	-- tile has none of -- neither is a substitute.

	bSpawnsAdmiraltyLuxury					INTEGER DEFAULT 0,
	-- On build, spawns a random aquatic luxury (a Resource with bAdmiraltyLuxury) on this plot (e.g. the AdmiraltyFort)

	bTunnel									INTEGER DEFAULT 0,
	-- Category tag: improvement is a Tunnel (content-driven; e.g. the Laerdal Tunnel wonder grants bonus yields to all bTunnel improvements)

	eCoastalArtImprovement				TEXT DEFAULT NULL REFERENCES Improvements(Type),
	-- render-only: on coastal land or a lake shore this improvement is drawn with the named improvement's art; gameplay still sees this improvement

	eFeature							TEXT DEFAULT NULL REFERENCES Features(Type),
	-- associated feature

	eFreePromotion						TEXT DEFAULT NULL REFERENCES UnitPromotions(Type),
	-- free promotion to the owner's units while they hold this plot

	iFriendlyBombRadius					INTEGER DEFAULT 0,
	-- friendly bombard radius from this plot

	iLeagueVotes						INTEGER DEFAULT 0,
	-- World Congress votes while owning this improvement

	iPlotHealPerTurn						INTEGER DEFAULT 0,
	-- Friendly units on this improvement heal this many extra HP per turn

	iRequiresXAdjacentWater				INTEGER DEFAULT 0,
	-- requires at least this many adjacent water tiles

	iSeedBonusResourceRadius				INTEGER DEFAULT 0,
	-- On build, plants one random Bonus resource on an owned land plot within this radius (own plot included) that can
	-- carry it; nothing is planted while a Bonus resource already lies within the radius (a one-shot). 0 = off.

	iVision									INTEGER DEFAULT 0
	-- Extra sight radius granted to the owner from this improvement's plot (e.g. Feitoria)
);

-- Resource the improvement places on its plot when built (linked pair: a quantity is meaningless without the
-- resource). One resource per improvement.
CREATE TABLE IF NOT EXISTS _Improvement_ResourceQuantity (
	ImprovementType	TEXT PRIMARY KEY NOT NULL REFERENCES Improvements(Type),
	ResourceType	TEXT NOT NULL REFERENCES Resources(Type),
	iQuantity		INTEGER NOT NULL DEFAULT 1
);

-- Special-unit basing ("airfield carrier"; linked pair: capacity is meaningless without the unit class).
-- The improvement can station iCargoSpace units of the given special class (e.g. Airbase/Outpost = FIGHTER,
-- Vault = MISSILE, Mongol Ger Camp = ENTRENCHED). One row per class; each class has its own capacity
-- (Admiral Fort = FIGHTER 2 + ENTRENCHED 1).
CREATE TABLE IF NOT EXISTS _Improvement_Cargo (
	ImprovementType	TEXT NOT NULL REFERENCES Improvements(Type),
	SpecialUnitType	TEXT NOT NULL REFERENCES SpecialUnits(Type),
	iCargoSpace		INTEGER NOT NULL DEFAULT 1,
	PRIMARY KEY (ImprovementType, SpecialUnitType)
);

-- Units created on the plot for the builder when this improvement is built (a completed build only, never an
-- improvement upgrade). The unit steps up its upgrade line while the builder already has the next step's tech.
-- An air unit is created only while the plot has a free cargo slot of its class.
CREATE TABLE IF NOT EXISTS _Improvement_FreeUnitWhenBuilt (
	ImprovementType	TEXT NOT NULL REFERENCES Improvements(Type),
	UnitType		TEXT NOT NULL REFERENCES Units(Type),
	iQuantity		INTEGER NOT NULL DEFAULT 1,
	PRIMARY KEY (ImprovementType, UnitType)
);

------------------------------------------------------------------------------------------------------------------------
-- BUILD EXTENSIONS
-- Build-level flags from _Builds_Extensions
------------------------------------------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS _Builds_Extensions (
	BuildType								TEXT PRIMARY KEY REFERENCES Builds(Type),

	bKillOnlyCivilian						INTEGER DEFAULT 0,
	-- On completion, a Kill build consumes the builder only if it is a civilian unit

	bRemoveImprovement						INTEGER DEFAULT 0,
	-- Build action removes the existing improvement on the plot

	eObsoleteTech							TEXT DEFAULT NULL REFERENCES Technologies(Type)
	-- This build action obsoletes once the player has this tech
);

--====================================================================================================================
-- NEW IMPROVEMENT TABLES
--====================================================================================================================

CREATE TABLE IF NOT EXISTS _Improvement_YieldAdjacentSameType (
	ImprovementType	TEXT REFERENCES Improvements(Type),
	YieldType			TEXT REFERENCES Yields(Type),
	Yield				INTEGER,
	PRIMARY KEY (ImprovementType, YieldType)
);

-- Bonus yield when adjacent to at least TWO of the same improvement (improvement "triangles").
CREATE TABLE IF NOT EXISTS _Improvement_YieldAdjacentTwoSameType (
	ImprovementType	TEXT REFERENCES Improvements(Type),
	YieldType		TEXT REFERENCES Yields(Type),
	Yield			INTEGER DEFAULT 0,
	PRIMARY KEY (ImprovementType, YieldType)
);

-- Per-turn XP granted to the owner's units standing on this improvement, by unit Domain
-- with domain granularity, e.g. a coastal fort can grant XP to DOMAIN_SEA only.
CREATE TABLE IF NOT EXISTS _Improvement_DomainExperiencePerTurn (
	ImprovementType	TEXT REFERENCES Improvements(Type),
	DomainType			TEXT REFERENCES Domains(Type),
	iExperience			INTEGER DEFAULT 0,
	PRIMARY KEY (ImprovementType, DomainType)
);

-- XP granted to units of this Domain trained in a city per worked plot of this improvement, capped at iMaxExperience
-- (0 = no cap).
CREATE TABLE IF NOT EXISTS _Improvement_TrainedUnitExperience (
	ImprovementType	TEXT REFERENCES Improvements(Type),
	DomainType			TEXT REFERENCES Domains(Type),
	iExperience			INTEGER DEFAULT 0,
	iMaxExperience		INTEGER DEFAULT 0,
	PRIMARY KEY (ImprovementType, DomainType)
);

--====================================================================================================================
-- Replacement improvements
--====================================================================================================================

-- ImprovementType stands in for ReplacesImprovementType. After every mod has loaded (the post-build statements
-- Sapiens registers in _PostBuildSQL) every row keyed on the base is copied to the replacement, so uniques from
-- any mod are covered: adjacency both ways, belief/policy/trait/tech/building/route/resource yields, building and
-- promotion requirements, improvement prerequisites. An explicit row on the replacement wins; a two-base
-- replacement takes the larger value per key. Placement (resources, terrains, features, builds) is not copied.
-- bExclusive = 1: the owning civilization also loses the base's build (derived into _Trait_NoBuild).
CREATE TABLE IF NOT EXISTS _Improvement_Replaces (
	ImprovementType			TEXT REFERENCES Improvements(Type),
	ReplacesImprovementType	TEXT REFERENCES Improvements(Type),
	bExclusive				INTEGER DEFAULT 0,
	PRIMARY KEY (ImprovementType, ReplacesImprovementType)
);

-- ImprovementType grants Yield to EVERY adjacent unique improvement (Improvements.SpecificCivRequired = 1); the
-- yield lands on the unique improvement's tile. Expanded into _Improvement_AdjacentImprovementYieldChanges by the
-- same post-build statements, so it reaches uniques from every mod and needs no trigger.
CREATE TABLE IF NOT EXISTS _Improvement_GrantsToUniqueImprovements (
	ImprovementType	TEXT REFERENCES Improvements(Type),
	YieldType		TEXT REFERENCES Yields(Type),
	Yield			INTEGER DEFAULT 0,
	PRIMARY KEY (ImprovementType, YieldType)
);
--====================================================================================================================
-- Cross-type adjacency yields
--====================================================================================================================

-- ImprovementType GRANTS Yield to every ADJACENT tile improved with AdjacentImprovementType.
-- Read a row left to right: "<ImprovementType> gives <Yield> <YieldType> to adjacent <AdjacentImprovementType>".
-- e.g. ('IMPROVEMENT_MADAGASCAR_ROVA', 'IMPROVEMENT_PLANTATION', 'YIELD_FAITH', 1)
--      = a Rova gives +1 Faith to each adjacent Plantation. The yield lands on the PLANTATION's tile.
CREATE TABLE IF NOT EXISTS _Improvement_AdjacentImprovementYieldChanges (
	ImprovementType			TEXT REFERENCES Improvements(Type),
	AdjacentImprovementType	TEXT REFERENCES Improvements(Type),
	YieldType				TEXT REFERENCES Yields(Type),
	Yield					INTEGER DEFAULT 0,
	PRIMARY KEY (ImprovementType, AdjacentImprovementType, YieldType)
);

-- This improvement gains Yield per ADJACENT resource of ResourceType.
CREATE TABLE IF NOT EXISTS _Improvement_AdjacentResourceYieldChanges (
	ImprovementType	TEXT REFERENCES Improvements(Type),
	ResourceType		TEXT REFERENCES Resources(Type),
	YieldType			TEXT REFERENCES Yields(Type),
	Yield				INTEGER DEFAULT 0,
	PRIMARY KEY (ImprovementType, ResourceType, YieldType)
);

-- This improvement gains Yield per ADJACENT terrain of TerrainType.
CREATE TABLE IF NOT EXISTS _Improvement_AdjacentTerrainYieldChanges (
	ImprovementType	TEXT REFERENCES Improvements(Type),
	TerrainType		TEXT REFERENCES Terrains(Type),
	YieldType			TEXT REFERENCES Yields(Type),
	Yield				INTEGER DEFAULT 0,
	PRIMARY KEY (ImprovementType, TerrainType, YieldType)
);

-- ImprovementType GRANTS Yield to every ADJACENT tile of TerrainType that has the same owner.
CREATE TABLE IF NOT EXISTS _Improvement_YieldToAdjacentTerrain (
	ImprovementType	TEXT REFERENCES Improvements(Type),
	TerrainType		TEXT REFERENCES Terrains(Type),
	YieldType			TEXT REFERENCES Yields(Type),
	Yield				INTEGER DEFAULT 0,
	PRIMARY KEY (ImprovementType, TerrainType, YieldType)
);

-- This improvement gains Yield per ADJACENT feature of FeatureType.
CREATE TABLE IF NOT EXISTS _Improvement_AdjacentFeatureYieldChanges (
	ImprovementType	TEXT REFERENCES Improvements(Type),
	FeatureType		TEXT REFERENCES Features(Type),
	YieldType			TEXT REFERENCES Yields(Type),
	Yield				INTEGER DEFAULT 0,
	PRIMARY KEY (ImprovementType, FeatureType, YieldType)
);

-- This improvement gains Yield when ADJACENT to an owned City
CREATE TABLE IF NOT EXISTS _Improvement_AdjacentCityYieldChanges (
	ImprovementType	TEXT REFERENCES Improvements(Type),
	YieldType			TEXT REFERENCES Yields(Type),
	Yield				INTEGER DEFAULT 0,
	PRIMARY KEY (ImprovementType, YieldType)
);

--====================================================================================================================
-- ADJACENCY PLACEMENT RESTRICTIONS
--====================================================================================================================

-- ImprovementType may NOT be built on a plot adjacent to OtherImprovementType.
-- Generalises the vanilla Improvements.NoTwoAdjacent flag, which only ever blocks an improvement
-- against ITSELF, to arbitrary cross-type pairs. Needed for upgrade families (Trading Post ->
-- Village -> Town), where every member is a distinct ImprovementType and so slips past NoTwoAdjacent.
-- Directional: to block both orders, insert both (A,B) and (B,A).
CREATE TABLE IF NOT EXISTS _Improvement_NoAdjacentImprovements (
	ImprovementType			TEXT REFERENCES Improvements(Type),
	OtherImprovementType	TEXT REFERENCES Improvements(Type),
	PRIMARY KEY (ImprovementType, OtherImprovementType)
);

-- Terrain allow-list. Unlike the vanilla Improvement_ValidTerrains, which only ENABLES a plot, rows here
-- RESTRICT: an improvement with any row is rejected on every terrain not listed. No rows = no restriction.
CREATE TABLE IF NOT EXISTS _Improvement_RequiredTerrains (
	ImprovementType			TEXT REFERENCES Improvements(Type),
	TerrainType				TEXT REFERENCES Terrains(Type),
	PRIMARY KEY (ImprovementType, TerrainType)
);

--====================================================================================================================
UPDATE Sapiens_DBUpdates SET Value = 1 WHERE Name = 'DB_Improvements';
