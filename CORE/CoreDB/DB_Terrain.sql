-- written by GAIA using Notepad++
CREATE TABLE IF NOT EXISTS Sapiens_DBUpdates (Name TEXT PRIMARY KEY, Value INTEGER DEFAULT 0);
INSERT OR IGNORE INTO Sapiens_DBUpdates (Name) VALUES ('DB_Terrain');
--====================================================================================================================
-- TERRAIN TABLE EXTENSIONS
--====================================================================================================================

------------------------------------------------------------------------------------------------------------------------
-- TERRAINS
------------------------------------------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS _Terrains_Extensions (
	TerrainType							TEXT PRIMARY KEY REFERENCES Terrains(Type),

	iExtraTurnDamage						INTEGER DEFAULT 0,
	-- EXTRA per-turn damage (only applied to units with bTakesExtraTerrainDamage promotion)

	iTurnDamage								INTEGER DEFAULT 0
	-- Base per-turn damage to ALL units on this terrain (bypassed by bIgnoreTerrainDamage promotion)
);

------------------------------------------------------------------------------------------------------------------------
-- FEATURES
------------------------------------------------------------------------------------------------------------------------

-- Remove the conflict between FEATURE_LAKE == FEATURE_ICE and FEATURE_RIVER == FEATURE_JUNGLE
UPDATE FakeFeatures SET ID=ID+200;

CREATE TABLE IF NOT EXISTS _Features_Extensions (
	FeatureType							TEXT PRIMARY KEY REFERENCES Features(Type),

	bIsSettlement						INTEGER DEFAULT 0,
	-- settlement: a Great Emissary may found a City-State on this feature

	bPseudoNaturalWonder				INTEGER DEFAULT 0,
	-- treat as a natural wonder for IsNaturalWonder(orPseudoNatural) checks (start placement, NW popup, Sapiens yields) without being a real one

	eTerritoryFreePromotion				TEXT DEFAULT NULL REFERENCES UnitPromotions(Type),

	iExtraTurnDamage					INTEGER DEFAULT 0,
	-- EXTRA per-turn damage (only applied to units with bTakesExtraFeatureDamage promotion;
	-- additive to vanilla Features.TurnDamage which stays in vanilla schema)

	iFoodFromRemoval					INTEGER DEFAULT 0
	-- food granted to the working city when a build clears this feature
);

-- Policy granted to the FIRST major-civ finder of this natural wonder (alongside FirstFinderGold).
CREATE TABLE IF NOT EXISTS _Feature_FirstFinderPolicy (
	FeatureType		TEXT PRIMARY KEY REFERENCES Features(Type),
	ePolicyType		TEXT DEFAULT NULL REFERENCES Policies(Type)
);

--====================================================================================================================
-- NEW TERRAIN TABLES
--====================================================================================================================

------------------------------------------------------------------------------------------------------------------------
-- FEATURE YIELDS
------------------------------------------------------------------------------------------------------------------------

-- Per-era feature yield: on each era advance, the team's feature-yield for this feature gains Yield
CREATE TABLE IF NOT EXISTS _Feature_YieldPerEra (
	FeatureType	TEXT REFERENCES Features(Type),
	YieldType		TEXT REFERENCES Yields(Type),
	Yield			INTEGER,
	PRIMARY KEY (FeatureType, YieldType)
);

------------------------------------------------------------------------------------------------------------------------
-- TERRAIN YIELDS
------------------------------------------------------------------------------------------------------------------------

-- Bonus yield granted to this terrain for each ADJACENT feature of the given type
CREATE TABLE IF NOT EXISTS _Terrain_YieldChangesFromAdjacentFeature (
	TerrainType	TEXT REFERENCES Terrains(Type),
	FeatureType	TEXT REFERENCES Features(Type),
	YieldType		TEXT REFERENCES Yields(Type),
	Yield			INTEGER
);

--====================================================================================================================
-- RESOURCES
--====================================================================================================================

-- A resource whose monopoly grants a policy: the player who holds the monopoly on it (global for a luxury, strategic
-- for a strategic resource) holds PolicyType and loses it with the monopoly. The policy carries every effect.
CREATE TABLE IF NOT EXISTS _Resource_MonopolyPolicyGrant (
	ResourceType	TEXT PRIMARY KEY REFERENCES Resources(Type),
	PolicyType		TEXT REFERENCES Policies(Type)
);

-- Resource-gated Production modifiers.
-- Building mod = per-resource pairing table; Unit mod = per-(resource, unit combat class) rows so any
-- number of combat classes can be boosted
CREATE TABLE IF NOT EXISTS _Resources_Extensions (
	ResourceType						TEXT PRIMARY KEY REFERENCES Resources(Type),

	bMonopoly								INTEGER DEFAULT 0,
	-- resource can form a monopoly

	bAdmiraltyLuxury							INTEGER DEFAULT 0,
	-- Eligible for the AdmiraltyFort's random aquatic-luxury spawn (paired with _Improvements_Extensions.bSpawnsAdmiraltyLuxury)

	eLuxuryCategory							TEXT DEFAULT NULL
	-- Where a luxury comes from, NULL for anything that is not a luxury. A source, not a habitat.
	--   REGIONAL      the map generator assigns it to a region
	--   GLOBAL        map-generated, outside the regional assignment
	--   AQUATIC       spawned by the AdmiraltyFort
	--   MANUFACTURED  granted by a building or an improvement
	--   MERCANTILE    city-state only
);

-- Resource-gated Building Production modifier (linked pair: the obsolete era is meaningless without the
-- modifier).
CREATE TABLE IF NOT EXISTS _Resource_BuildingProductionMod (
	ResourceType		TEXT PRIMARY KEY NOT NULL REFERENCES Resources(Type),
	iProductionMod		INTEGER DEFAULT 0,
	eObsoleteEra		TEXT DEFAULT NULL REFERENCES Eras(Type)
);

CREATE TABLE IF NOT EXISTS _Resource_UnitProductionMod (
	ResourceType		TEXT NOT NULL REFERENCES Resources(Type),
	UnitCombatType		TEXT NOT NULL REFERENCES UnitCombatInfos(Type),
	iProductionMod		INTEGER DEFAULT 0,
	eObsoleteEra		TEXT DEFAULT NULL REFERENCES Eras(Type),
	PRIMARY KEY (ResourceType, UnitCombatType)
);

--====================================================================================================================
UPDATE Sapiens_DBUpdates SET Value = 1 WHERE Name = 'DB_Terrain';
