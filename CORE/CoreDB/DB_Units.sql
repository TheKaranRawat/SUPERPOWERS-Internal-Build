-- written by GAIA using Notepad++
CREATE TABLE IF NOT EXISTS Sapiens_DBUpdates (Name TEXT PRIMARY KEY, Value INTEGER DEFAULT 0);
INSERT OR IGNORE INTO Sapiens_DBUpdates (Name) VALUES ('DB_Units');
--====================================================================================================================
-- ETHNIC UNIT NAMES
-- The optional "Named Ethnic Units" mod fills this; CORE declares it empty so the read is always safe.
--====================================================================================================================
CREATE TABLE IF NOT EXISTS _Civilization_UnitNameOverrides (
	CivilizationType						TEXT REFERENCES Civilizations(Type),
	UnitType								TEXT REFERENCES Units(Type),
	EthnicUnitName							TEXT
);

--====================================================================================================================
-- GREAT PERSON UNIQUE-NAME ERAS AND CIVILIZATIONS
--====================================================================================================================
CREATE TABLE IF NOT EXISTS _UniqueName_Era (UniqueName TEXT PRIMARY KEY NOT NULL, EraType TEXT NOT NULL REFERENCES Eras(Type));
CREATE TABLE IF NOT EXISTS _UniqueName_Civilization (UniqueName TEXT NOT NULL, CivilizationType TEXT NOT NULL REFERENCES Civilizations(Type), PRIMARY KEY (UniqueName, CivilizationType));

-- Diagnostics only, never read by the game: the unit upgrade pass records upgrade/obsolescence data it cannot
-- silently repair, so drift is queryable from cache\Civ5DebugDatabase.db after a load
-- (SELECT * FROM _Validate_UnitObsolescence). Empty = clean.
CREATE TABLE IF NOT EXISTS _Validate_UnitObsolescence (UnitType TEXT, Issue TEXT, Detail TEXT);

--====================================================================================================================
-- UNIT TABLE EXTENSIONS
--====================================================================================================================

CREATE TABLE IF NOT EXISTS _Units_Extensions (
	UnitType								TEXT PRIMARY KEY REFERENCES Units(Type),

	bCanPurchaseInPuppets					INTEGER DEFAULT 0,
	-- Unit may be Gold/Faith-purchased in a Puppet city even for non-Venice civs (absent/0 = vanilla puppet block).

	bGoodwillMission						INTEGER DEFAULT 0,
	-- Unit can be expended on a Goodwill Mission inside another major civilization's borders, improving that leader's opinion of its owner.

	bNeverObsoletes							INTEGER DEFAULT 0,
	-- Unit never goes obsolete even though it has an upgrade path. Absent/0 = it goes obsolete once the
	-- upgrade unit THIS player fields becomes available. Units.ObsoleteTech is
	-- ignored.

	bNoCSGifts							INTEGER DEFAULT 0,
	-- Excludes from Minor Civ military unit gifts

	bNoFoundAbroad						INTEGER DEFAULT 0,
	-- Never founds a city abroad: found-abroad promotions are neither granted to it nor honoured on it

	bNoRebase								INTEGER DEFAULT 0,
	-- Air unit can never rebase: it stays on the base it was created on, and may upgrade there even outside a city

	bNoSupply								INTEGER DEFAULT 0,
	-- Unit does not consume an army-supply slot

	bNoTrain							INTEGER DEFAULT 0,
	-- Unit can never be trained or purchased; it exists only to be granted (by a building, a policy, a
	-- transform, a goody hut, ...). Gated once in the DLL, upstream of every production AND purchase path.

	bRequiresWar							INTEGER DEFAULT 0,
	-- Unit can be trained or purchased only while its owner is at war with a major civilization; units already in the
	-- field stay after peace.

	bWLTKDOnBirth							INTEGER DEFAULT 0,
	-- Creating this unit triggers a We Love The King Day in its birth city (or the owner's capital), like a building's bWLTKD.

	eRequiresEra							TEXT DEFAULT NULL REFERENCES Eras(Type),
	-- Unit unlocks once the player reaches this era (NULL = no era gate). Pair with PrereqTech NULL to keep the
	-- unit off the tech tree entirely.

	eRequiresRoute							TEXT DEFAULT NULL REFERENCES Routes(Type),
	-- Unit may only move onto plots carrying a route of at least this tier (ROUTE_ROAD = road or rail; ROUTE_RAILROAD = rail only),
	-- or into any city; NULL = no restriction.

	eTransformClass							TEXT DEFAULT NULL REFERENCES UnitClasses(Type),
	-- UnitClass this unit can transform into in-place (e.g. Worker <-> Workboat, Caravan <-> Cargo Ship); NULL = none.

	iExtraCostPerEra						INTEGER DEFAULT 0,
	-- Additional production/purchase cost added per era elapsed since the unit became available (scales cost over time)

	iGoldenAgeOnBirthPercent				INTEGER DEFAULT 0,
	-- Creating this unit starts (or extends) an empire-wide Golden Age at this percent of a normal one's length
	-- (applied after game speed and all length modifiers, floored); 0 = off. The Golden Age twin of bWLTKDOnBirth.

	iExpendHealRange						INTEGER DEFAULT 0
	-- When this Great Person is expended, the owner's land combat units within this many tiles of it are fully healed;
	-- 0 = off.
);

-- MISSION_GAIA_BLOCKBUSTER (Great Director active mission): gold + tourism blast.
CREATE TABLE IF NOT EXISTS _Unit_Blockbuster (
	UnitType								TEXT PRIMARY KEY REFERENCES Units(Type),
	iBlockbusterGold						INTEGER DEFAULT 0,
	-- base gold granted on use (scaled by game speed)
	iBlockbusterGoldPerEra					INTEGER DEFAULT 0,
	-- additional gold per current era (added to iBlockbusterGold before game-speed scaling)
	iBlockbusterTourism						INTEGER DEFAULT 0
	-- tourism-blast multiplier
);

-- Envoy / Great-Emissary City-State mission tuning.
CREATE TABLE IF NOT EXISTS _Unit_CSInfluence (
	UnitType								TEXT PRIMARY KEY REFERENCES Units(Type),
	iCSMissionInfluence						INTEGER DEFAULT 0,
	-- per-unit base trade-mission influence (0 = global MINOR_FRIENDSHIP_FROM_TRADE_MISSION).
	iCSMissionInfPerEra						INTEGER DEFAULT 0,
	-- trade-mission influence added per era.
	iCSRestingPointChange					INTEGER DEFAULT 0
	-- permanent CS friendship resting-point change for the owner.
);

-- Era-scaled units. A unit listed here takes the given base CombatStrength
-- when its team reaches EraType (later eras override earlier ones; new units catch up at creation).
CREATE TABLE IF NOT EXISTS _Unit_EraCombatStrength (
	UnitType								TEXT NOT NULL REFERENCES Units(Type),
	EraType									TEXT NOT NULL REFERENCES Eras(Type),
	CombatStrength							INTEGER DEFAULT 0
);

-- ...and is permanently granted PromotionType when its team reaches EraType.
CREATE TABLE IF NOT EXISTS _Unit_EraUnitPromotions (
	UnitType								TEXT NOT NULL REFERENCES Units(Type),
	PromotionType							TEXT NOT NULL REFERENCES UnitPromotions(Type),
	EraType									TEXT NOT NULL REFERENCES Eras(Type)
);

-- Trade-route resource planting (e.g. the Dominican Caribbean Trader): once one of this unit's trade routes has
-- been active for GD_TR_PLANT_RESOURCE_TURNS (game-speed scaled) turns, ResourceType is planted on a valid
-- plot near the destination city; iMinorInfluence is granted when it lands in or next to City-State land.
CREATE TABLE IF NOT EXISTS _Unit_TradeRoutePlantResource (
	UnitType								TEXT PRIMARY KEY REFERENCES Units(Type),
	ResourceType							TEXT NOT NULL REFERENCES Resources(Type),
	iQuantity								INTEGER DEFAULT 1,
	iMinorInfluence							INTEGER DEFAULT 0
);

-- MISSION_GAIA_CYBERATTACK (Great Developer active mission): inflicts anarchy.
CREATE TABLE IF NOT EXISTS _Unit_HackerAnarchyTurns (
	UnitType								TEXT PRIMARY KEY REFERENCES Units(Type),
	iHackerAnarchyTurnsPeace				INTEGER DEFAULT 0,
	-- turns of anarchy inflicted on all other major civs while the owner is at peace
	iHackerAnarchyTurnsWar					INTEGER DEFAULT 0
	-- turns of anarchy inflicted on civs at war with the owner (0 = no cyberattack)
);

CREATE TABLE IF NOT EXISTS _UnitCombatClass_DefaultUnits (
	CombatClass								TEXT PRIMARY KEY REFERENCES UnitCombatInfos(Type),
	-- Combat class shown in the Promotion Tree viewer
	DefaultUnitType							TEXT REFERENCES Units(Type)
	-- Unit whose icon/name represents the combat class in the Promotion Tree
);

-- Promotion combat class override: which UNITCOMBAT a unit draws promotions from (NULL/absent = vanilla CombatClass fallback).
-- Dedicated table for clean per-unit / unique-unit overrides (content uses INSERT OR REPLACE).
CREATE TABLE IF NOT EXISTS _Unit_PromotionCombatClass (
	UnitType					TEXT PRIMARY KEY REFERENCES Units(Type),
	ePromotionCombatClass		TEXT REFERENCES UnitCombatInfos(Type)
);

-- Each row grants the unit a free building (by BuildingClass) in the city it founds.
CREATE TABLE IF NOT EXISTS _Unit_FreeBuildingsOnFound (
	UnitType			TEXT NOT NULL REFERENCES Units(Type),
	BuildingClassType	TEXT NOT NULL REFERENCES BuildingClasses(Type),
	PRIMARY KEY (UnitType, BuildingClassType)
);

--====================================================================================================================
-- NEW UNIT TABLES
--====================================================================================================================

-- Unit CLASSES that may request a military escort. Keyed by class, so a civ's unique replacement inherits the flag.
CREATE TABLE IF NOT EXISTS _GAIA_Escort_Classes (
	UnitClassType		TEXT PRIMARY KEY REFERENCES UnitClasses(Type),
	bEscortable			INTEGER DEFAULT 1
);

-- BuildingClass prerequisites for PURCHASING this unit: the city must contain every listed BuildingClass.
CREATE TABLE IF NOT EXISTS _Unit_PurchaseBuildingClassRequireds (
	UnitType			TEXT NOT NULL REFERENCES Units(Type),
	BuildingClassType	TEXT NOT NULL REFERENCES BuildingClasses(Type),
	PRIMARY KEY (UnitType, BuildingClassType)
);

-- Trainable, purchasable or upgradable-into only while the empire owns at least iNumRequired buildings
-- of the class.
CREATE TABLE IF NOT EXISTS _Unit_PrereqEmpireBuildingClasses (
	UnitType			TEXT NOT NULL REFERENCES Units(Type),
	BuildingClassType	TEXT NOT NULL REFERENCES BuildingClasses(Type),
	iNumRequired		INTEGER NOT NULL DEFAULT 1,
	PRIMARY KEY (UnitType, BuildingClassType)
);

-- Promotions a unit leaves behind when it transforms or upgrades into this unit type.
CREATE TABLE IF NOT EXISTS _Unit_LostPromotions (
	UnitType			TEXT NOT NULL REFERENCES Units(Type),
	PromotionType		TEXT NOT NULL REFERENCES UnitPromotions(Type),
	PRIMARY KEY (UnitType, PromotionType)
);

--====================================================================================================================
UPDATE Sapiens_DBUpdates SET Value = 1 WHERE Name = 'DB_Units';
