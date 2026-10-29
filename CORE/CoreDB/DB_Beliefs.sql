-- written by GAIA using Notepad++
CREATE TABLE IF NOT EXISTS Sapiens_DBUpdates (Name TEXT PRIMARY KEY, Value INTEGER DEFAULT 0);
INSERT OR IGNORE INTO Sapiens_DBUpdates (Name) VALUES ('DB_Beliefs');
--====================================================================================================================
-- BELIEF TABLE EXTENSIONS
--====================================================================================================================

------------------------------------------------------------------------------------------------------------------------
-- BELIEFS
------------------------------------------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS _Beliefs_Extensions (
	BeliefType								TEXT PRIMARY KEY REFERENCES Beliefs(Type),

	CivilizationType						TEXT DEFAULT NULL REFERENCES Civilizations(Type),
	-- Belief is only valid for / available to this Civilization (unique civ belief). NULL = available to all.
	-- PANTHEON beliefs: a civilization with pantheons of its own picks its pantheon from those alone (the generic list
	-- returns only once none of its own is left). Other belief types stay additive.

	iCSYieldBonusFromSharedReligion			INTEGER DEFAULT 0,
	-- % bonus to the yields a player receives from city-states whose majority religion is the player's. 0 = none

	iCityStrengthModifier					INTEGER DEFAULT 0,
	-- flat bonus to defensive city strength in cities whose majority religion holds this belief

	iHappinessPerXForeignFollowers			INTEGER DEFAULT 0,
	-- Non-peaceful twin of vanilla Beliefs.HappinessPerXPeacefulForeignFollowers: +1 Happiness per this-many followers of
	-- your religion in OTHER civs, counting ALL of them (war or peace) instead of only civs you are at peace with. 0 = unused
	-- (default). Provided so a NEW belief can be authored with this behaviour cleanly -- do NOT repurpose the vanilla peaceful
	-- column / "Peace Loving" belief (that would mislabel its tooltip).

	iInquisitorCostModifier					INTEGER DEFAULT 0,
	-- % modifier to Inquisitor faith purchase cost for a player whose religion holds this belief (negative = cheaper). 0 = none

	iMissionaryInfluenceCS					INTEGER DEFAULT 0,
	-- Influence granted with a city-state when a unit of your religion spreads it there (scaled by era). 0 = none

	iPressureChangeTradeRoute				INTEGER DEFAULT 0,
	-- Extra religious pressure (%) transmitted along trade routes from a city
	-- whose majority religion holds this belief. 0 = unused.

	iSettlerProductionModifier				INTEGER DEFAULT 0
	-- % production bonus to Settlers (units with <Found>1) in cities whose majority religion holds this belief
);

-- A belief listed here grants its policy (free) to the player who created the religion it sits in, pantheon
-- included, and loses it when that stops being true; reconciled every turn from the live religion state,
-- no save state. Give each belief its OWN policy: the revoke cannot tell whether another source (a trait
-- policy, a building, an alliance) also granted the same one.
CREATE TABLE IF NOT EXISTS _Belief_GrantedPolicy (
	BeliefType	TEXT PRIMARY KEY NOT NULL REFERENCES Beliefs(Type),
	PolicyType	TEXT NOT NULL REFERENCES Policies(Type)
);

--====================================================================================================================
-- NEW BELIEF TABLES (alphabetical)
--====================================================================================================================

CREATE TABLE IF NOT EXISTS _Belief_CoastalCityYieldChanges (
	BeliefType		TEXT REFERENCES Beliefs(Type),
	YieldType		TEXT REFERENCES Yields(Type),
	Yield			INTEGER NOT NULL,
	PRIMARY KEY (BeliefType, YieldType)
);

CREATE TABLE IF NOT EXISTS _Belief_GreatWorkYieldChanges (
	BeliefType		TEXT REFERENCES Beliefs(Type),
	YieldType		TEXT REFERENCES Yields(Type),
	Yield			INTEGER NOT NULL,
	PRIMARY KEY (BeliefType, YieldType)
);

-- Yield for hills plots worked by a city with this Belief
CREATE TABLE IF NOT EXISTS _Belief_HillsPlotYieldChanges (
	BeliefType		TEXT REFERENCES Beliefs(Type),
	YieldType		TEXT REFERENCES Yields(Type),
	Yield			INTEGER DEFAULT 0,
	PRIMARY KEY (BeliefType, YieldType)
);

-- Yield for mountain plots worked by a city with this Belief
CREATE TABLE IF NOT EXISTS _Belief_MountainPlotYieldChanges (
	BeliefType		TEXT REFERENCES Beliefs(Type),
	YieldType		TEXT REFERENCES Yields(Type),
	Yield			INTEGER DEFAULT 0,
	PRIMARY KEY (BeliefType, YieldType)
);

-- Yield for river plots worked by a city with this Belief
CREATE TABLE IF NOT EXISTS _Belief_RiverPlotYieldChanges (
	BeliefType		TEXT REFERENCES Beliefs(Type),
	YieldType		TEXT REFERENCES Yields(Type),
	Yield			INTEGER DEFAULT 0,
	PRIMARY KEY (BeliefType, YieldType)
);

CREATE TABLE IF NOT EXISTS _Belief_SpecialistYieldChanges (
	BeliefType		TEXT REFERENCES Beliefs(Type),
	SpecialistType	TEXT REFERENCES Specialists(Type),
	YieldType		TEXT REFERENCES Yields(Type),
	Yield			INTEGER,
	PRIMARY KEY (BeliefType, SpecialistType, YieldType)
);

CREATE TABLE IF NOT EXISTS _Belief_UnimprovedFeatureYieldChanges (
	BeliefType		TEXT REFERENCES Beliefs(Type),
	FeatureType	TEXT REFERENCES Features(Type),
	YieldType		TEXT REFERENCES Yields(Type),
	Yield			INTEGER,
	PRIMARY KEY (BeliefType, FeatureType, YieldType)
);

-- Instant yield to the city when an inquisitor of this belief's religion removes heresy
CREATE TABLE IF NOT EXISTS _Belief_YieldFromRemoveHeresy (
	BeliefType		TEXT REFERENCES Beliefs(Type),
	YieldType		TEXT REFERENCES Yields(Type),
	Yield			INTEGER,
	PRIMARY KEY (BeliefType, YieldType)
);

------------------------------------------------------------------------------------------------------------------------
-- Founder/Enhancer belief mechanics
------------------------------------------------------------------------------------------------------------------------

-- Free unit promotion(s) granted to units built in a city whose majority religion holds this belief (Spirit Walkers, Work Ethic)
CREATE TABLE IF NOT EXISTS _Belief_TrainedUnitPromotions (
	BeliefType		TEXT REFERENCES Beliefs(Type),
	PromotionType	TEXT REFERENCES UnitPromotions(Type),
	PRIMARY KEY (BeliefType, PromotionType)
);

-- Ongoing yield per active trade route to/from a city whose majority religion holds this belief (Divine Heralds)
CREATE TABLE IF NOT EXISTS _Belief_YieldPerActiveTradeRoute (
	BeliefType		TEXT REFERENCES Beliefs(Type),
	YieldType		TEXT REFERENCES Yields(Type),
	Yield			INTEGER DEFAULT 0,
	PRIMARY KEY (BeliefType, YieldType)
);

------------------------------------------------------------------------------------------------------------------------
-- Pantheon Rework mechanics
------------------------------------------------------------------------------------------------------------------------

-- Yield on lake plots worked by a city with this Belief (1D; sibling of Hills/Mountain/River)
CREATE TABLE IF NOT EXISTS _Belief_LakePlotYieldChanges (
	BeliefType		TEXT REFERENCES Beliefs(Type),
	YieldType		TEXT REFERENCES Yields(Type),
	Yield			INTEGER DEFAULT 0,
	PRIMARY KEY (BeliefType, YieldType)
);

-- Yield on a worked plot of this Terrain when it has an improvement connecting its resource (2D Terrain x Yield)
CREATE TABLE IF NOT EXISTS _Belief_ImprovedResourceTerrainYieldChanges (
	BeliefType		TEXT REFERENCES Beliefs(Type),
	TerrainType	TEXT REFERENCES Terrains(Type),
	YieldType		TEXT REFERENCES Yields(Type),
	Yield			INTEGER DEFAULT 0,
	PRIMARY KEY (BeliefType, TerrainType, YieldType)
);

-- Yield on a worked plot with this Improvement when it is valid for the plot's resource (2D Improvement x Yield)
CREATE TABLE IF NOT EXISTS _Belief_ResourceImprovementYieldChanges (
	BeliefType			TEXT REFERENCES Beliefs(Type),
	ImprovementType	TEXT REFERENCES Improvements(Type),
	YieldType			TEXT REFERENCES Yields(Type),
	Yield				INTEGER DEFAULT 0,
	PRIMARY KEY (BeliefType, ImprovementType, YieldType)
);

-- Ongoing per-turn city yield x number of unique luxuries the owner has
CREATE TABLE IF NOT EXISTS _Belief_YieldPerUniqueLuxuryOwned (
	BeliefType		TEXT REFERENCES Beliefs(Type),
	YieldType		TEXT REFERENCES Yields(Type),
	Yield			INTEGER DEFAULT 0,
	PRIMARY KEY (BeliefType, YieldType)
);

-- Ongoing per-turn city yield per N worked tiles of this Terrain (2D Terrain x Yield; value is x100 -> /100 at apply)
CREATE TABLE IF NOT EXISTS _Belief_YieldPerXWorkedTerrain100 (
	BeliefType		TEXT REFERENCES Beliefs(Type),
	TerrainType	TEXT REFERENCES Terrains(Type),
	YieldType		TEXT REFERENCES Yields(Type),
	Yield			INTEGER DEFAULT 0,
	PRIMARY KEY (BeliefType, TerrainType, YieldType)
);

------------------------------------------------------------------------------------------------------------------------
-- Religion -> Place of Worship mapping.
------------------------------------------------------------------------------------------------------------------------

-- Each religion's thematic "Place of Worship" -- the follower belief (one whose Belief_BuildingClassFaithPurchase
-- rows unlock a building) an AI founding this religion PREFERS for its founding follower slot. SOFT mapping: taken
-- when still available, otherwise the AI falls back to normal belief scoring; humans choose freely and never see it.
-- One row per religion (1:1).
CREATE TABLE IF NOT EXISTS _Religion_PlacesOfWorship (
	ReligionType	TEXT PRIMARY KEY REFERENCES Religions(Type),
	BeliefType		TEXT REFERENCES Beliefs(Type)
);

--====================================================================================================================
UPDATE Sapiens_DBUpdates SET Value = 1 WHERE Name = 'DB_Beliefs';
