-- written by GAIA using Notepad++
CREATE TABLE IF NOT EXISTS Sapiens_DBUpdates (Name TEXT PRIMARY KEY, Value INTEGER DEFAULT 0);
INSERT OR IGNORE INTO Sapiens_DBUpdates (Name) VALUES ('DB_Buildings');
--====================================================================================================================
-- BUILDING TABLE EXTENSIONS
--====================================================================================================================

------------------------------------------------------------------------------------------------------------------------
-- BUILDINGS
------------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS _Buildings_Extensions (
	BuildingType							TEXT PRIMARY KEY REFERENCES Buildings(Type),

	ShowInPedia								BOOLEAN DEFAULT 1,
	-- Whether the building gets a Civilopedia entry (the Sapiens Civilopedia queries this; set 0 to hide dummy
	-- buildings). No sidecar row = shown.

	AltGreatWorkYieldType						TEXT DEFAULT NULL,
	-- OVERRIDE for the yield type produced by Great Works housed in this building; NULL = YIELD_CULTURE (the default).

	bAddsFreshWater							INTEGER DEFAULT 0,
	-- Provides fresh water to the city

	bAllowsGoldTradeRoutes					INTEGER DEFAULT 0,
	-- (Japan UB BUILDING_JAPAN_OPERA_HOUSE) When 1, a city with this building can establish internal GOLD trade routes (mirror of vanilla AllowsFood/ProductionTradeRoutes).

	bCanBuildAnywhere						INTEGER DEFAULT 0,
	-- Placement: bypasses the "occupied city only" gate so a NoOccupiedUnhappiness building (e.g. Persia's Satrap's Court) can be built anywhere

	bCanPurchaseInPuppets					INTEGER DEFAULT 0,
	-- Building may be Gold/Faith-purchased in a Puppet

	bCapitalOnly							INTEGER DEFAULT 0,
	-- Buildable only in the player's current capital.

	bCityRequiresMajorityReligion			INTEGER DEFAULT 0,
	-- Placement: buildable/purchasable only in a city that already has a FOUNDED majority religion
	-- (GetReligiousMajority() > RELIGION_PANTHEON; a Pantheon alone does NOT qualify). Used by the Monastery and the
	-- wonders that grant a free Monastery (Mt St-Michel, Paro Taktsang).

	bDummy									INTEGER DEFAULT 0,
	-- Hidden/mechanic ("dummy") building: auto-granted, not normally built or purchased. Excluded from the
	-- religion AI's faith-building lists

	bFormerCapitalOnly						INTEGER DEFAULT 0,
	-- Buildable only in a former major capital (an original major capital now owned by someone other than its
	-- original owner, i.e. a conquered enemy capital).

	bIgnoreEraPopRequirement				INTEGER DEFAULT 0,
	-- Opt-out: when 1, this building is exempt from the era-based minimum-population
	-- construct/purchase gate (for situational buildings whose own placement prereqs should be the only limiter).
	-- Absent/0 = building IS gated.

	bLakesideOnly							INTEGER DEFAULT 0,
	-- Placement: city plot must be adjacent to a lake

	bMountainSatisfiesLocalResources		INTEGER DEFAULT 0,
	-- Placement: an owned Mountain among the city's workable plots (Natural Wonders excluded) satisfies the
	-- building's Building_LocalResourceOrs requirement. Combine with bRealMountainRequired to reject Mountains
	-- carrying a Volcano. Used by the Forge (any Mountain) and Stone Works (Volcanoes do not count).

	bNoRiverside							INTEGER DEFAULT 0,
	-- Placement: city plot must NOT be on a river

	bRealMountainRequired					INTEGER DEFAULT 0,
	-- Placement: tightens the vanilla NearbyMountainRequired gate so a Mountain carrying a Volcano does NOT
	-- satisfy it. Volcanoes sit on mountain plots and are not Natural Wonders, so terrain alone would qualify.
	-- Also governs bMountainSatisfiesLocalResources the same way.

	bNotInCapitalOrFormerCapital			INTEGER DEFAULT 0,

	bNotInHolyCity							INTEGER DEFAULT 0,
	-- Placement: may NOT be built or purchased in a Holy City of any religion (inverse of Buildings.HolyCity).

	bPurchaseOnly							INTEGER DEFAULT 0,
	-- Can only be acquired via Gold/Faith purchase, never produced

	bSealift								INTEGER DEFAULT 0,
	-- Sealift port: a land unit that has not moved, in or next to a city holding this building, may sail to a tile in or
	-- next to another of the owner's such cities on the same sea, landing GD_SEALIFT_TRAVEL_TURNS turns later (Sapiens Mod
	-- Option SEALIFT). Sapiens flags every Seaport-class building.

	bSingleTileIsland						INTEGER DEFAULT 0,
	-- Placement: city plot must be a single-tile island

	bWLTKD									INTEGER DEFAULT 0,
	-- When 1, the building triggers a We Love The King Day on first construction (like Taj Mahal -> Golden Age; extends an active WLTKD). Length = CITY_RESOURCE_WLTKD_TURNS x GameSpeeds.iWLTKDPercent.

	ePrereqCSAlly								TEXT DEFAULT NULL REFERENCES MinorCivilizations(Type),
	-- (CSWONDERS) Buildable only while the player is this City-State's Ally and has been for at least
	-- GD_CITYSTATE_WONDER_TURNS consecutive turns
	-- NULL = no gate.

	eRequiresEra								TEXT DEFAULT NULL REFERENCES Eras(Type),
	-- Building unlocks once the player reaches this era (NULL = no era gate). Pair with PrereqTech NULL to keep
	-- the building off the tech tree entirely (e.g. National Parks).

	iAlwaysHeal								INTEGER DEFAULT 0,
	-- Building lets units in the city heal to full every turn regardless of enemy adjacency (e.g. Medical Lab)

	iConversionModifier						INTEGER DEFAULT 0,
	-- Per-city contribution to Religion-spread resistance

	iFollowerPercentRequired				INTEGER DEFAULT 0,
	-- (PILLAR_OF_FAITH) Min % of global population that must follow the owner's founded religion to build this (scaled by Worlds.iFollowerPercentMod).

	iGoldenAgePointsMax						INTEGER DEFAULT 0,
	-- Per-CITY cap on iGoldenAgePointsPerPop below. 0 = uncapped. The cap is per city on purpose: it is what
	-- stops one stacked megacity from trivialising the Golden Age meter.

	iGoldenAgePointsPerPop					INTEGER DEFAULT 0,
	-- Golden Age points this building adds to the owner's meter each turn, per 100 Population of the city that
	-- holds it: the Building_YieldChangesPerPop convention, so 10 = one point per 10 Population. Counted from
	-- REAL copies only and capped by iGoldenAgePointsMax. Accrues only while the owner is NOT already in a
	-- Golden Age, like the excess Happiness it sits beside. 0 = none. (Brazil's Sambadrome.)

	iNumTenetsRequired						INTEGER DEFAULT 0,
	-- Min number of adopted policies in the building's own PolicyBranchType branch (Tenets, for an Ideology) before
	-- it can be built; the branch itself must also be unlocked. 0 = no count. (Ideology national wonders.)

	iOneShotTourismModifier					INTEGER DEFAULT 0,
	-- Percentage bonus to the one-shot Tourism a Great Person BORN in this city carries (Great Musician
	-- Concert Tour, Great Writer/Artist blasts). Locked in at birth like the blast itself, so it rewards
	-- where the Great Person was cultivated rather than where they happen to stand. Summed across the city.

	iProductionCostAddedPerEra				INTEGER DEFAULT 0,
	-- Flat production cost added per player era past the first (keeps cheap
	-- base-cost wonders relevant late).

	bEraCost								INTEGER DEFAULT 0,
	-- This world wonder costs the WonderCost of the first column of its owner's current era in _Era_ColumnCosts (without wonder
	-- prices there, the cheapest world wonder of that era), so its price rises with each new era.

	iRanksUpNSpies							INTEGER DEFAULT 0,
	-- Caps a building's vanilla InstantSpyRankChange to the top N non-maxed spies
	-- instead of ALL of them: highest rank first (Agents before Recruits, never Special Agents). 0 = vanilla (all spies).

	iStrategicResourceInfluenceCost			INTEGER DEFAULT 0,
	-- Influence-cost adjustment applied to an unowned plot holding a revealed STRATEGIC resource when this
	-- city's borders pick their next tile. Follows the cost idiom of the surrounding PLOT_INFLUENCE_* terms:
	-- lower cost wins, so a NEGATIVE value attracts. One ring of distance is worth 100, and the vanilla
	-- "any resource" term is -105, so -100 makes a strategic outbid a luxury by roughly a ring. Summed across
	-- the city's buildings. 0 = vanilla, all resource classes pull equally. (Russia's Krepost.)

	iTradeReligionModifier					INTEGER DEFAULT 0
	-- (Byzantium) Building-level modifier (%) to religious pressure this city sends along trade routes.
);

CREATE TABLE IF NOT EXISTS _Building_YieldPerCorporations (
	BuildingType							TEXT NOT NULL REFERENCES Buildings(Type),
	YieldType								TEXT NOT NULL REFERENCES Yields(Type),
	Yield									INTEGER NOT NULL DEFAULT 0,
	Scope									TEXT NOT NULL DEFAULT 'CITY',
	-- Trading floors: the building earns Yield per Great Work of Corporation, counted at Scope.
	-- 'CITY' = works housed in this city; 'PLAYER' = works the owner holds empire-wide;
	-- 'GLOBAL' = works founded anywhere in the world (the BuildingClasses MaxPlayerInstances /
	-- MaxGlobalInstances naming, extended down to city scope). Needs the ECONOMICS mod option.
	PRIMARY KEY (BuildingType, YieldType, Scope)
);

CREATE TABLE IF NOT EXISTS _Building_CityModifiers (
	BuildingType							TEXT PRIMARY KEY REFERENCES Buildings(Type),

	iCityExtraWorkRange						INTEGER DEFAULT 0,
	-- Per-building extension to the city's workable plot range

	iCityExtraStrikeRange					INTEGER DEFAULT 0,
	-- Per-building bonus to city ranged-strike range (capped by GD_CITY_ATTACK_RANGE_MAX)

	iCityAttackModifier						INTEGER DEFAULT 0,
	-- Per-building modifier to city ranged-strike combat strength

	iCityAirStrikeDefense					INTEGER DEFAULT 0,
	-- Per-building bonus to city air-strike defensive interception

	iCityBuildingMaintenanceMod				INTEGER DEFAULT 0,
	-- Per-building % modifier to the city's base building maintenance

	bCityIndirectFire					INTEGER DEFAULT 0
	-- Grants the city indirect-fire capability for ranged strikes
);

CREATE TABLE IF NOT EXISTS _Building_NearbyPromotion (
	BuildingType							TEXT NOT NULL REFERENCES Buildings(Type),
	PromotionType							TEXT NOT NULL REFERENCES UnitPromotions(Type),
	iPromotionRange						INTEGER DEFAULT 0,
	-- One row per (building, promotion): the promotion is granted to the owner's units within iPromotionRange tiles of a city
	-- holding BuildingType.
	PRIMARY KEY (BuildingType, PromotionType)
);

-- City-strike debuff. When a city holding BuildingType lands a ranged strike on a surviving enemy unit, it rolls
-- iDebuffChance% to apply eDebuffPromotion to that unit. One row per building.
CREATE TABLE IF NOT EXISTS _Building_CityStrikeDebuff (
	BuildingType							TEXT PRIMARY KEY REFERENCES Buildings(Type),
	eDebuffPromotion						TEXT DEFAULT NULL REFERENCES UnitPromotions(Type),
	iDebuffChance							INTEGER DEFAULT 0
);

------------------------------------------------------------------------------------------------------------------------
-- BUILDING CLASSES
------------------------------------------------------------------------------------------------------------------------

-- Repeatable building classes (per-city analogue of _Project_Repeats): a row here MAKES the class repeatable
-- (row-presence = authorization; absent row = vanilla one-per-city).
CREATE TABLE IF NOT EXISTS _BuildingClass_Repeats (
	BuildingClassType						TEXT PRIMARY KEY REFERENCES BuildingClasses(Type),

	iExtraCostPerRepeat						INTEGER DEFAULT 0,
	-- Flat production added to the cost per instance already built in the city

	iMaxCityInstances						INTEGER DEFAULT -1
	-- Max instances of a building of this class allowed in a SINGLE city: -1 = unlimited (default for a present row);
	-- N>1 = up to N per city (e.g. a faith-stacking building); 0 = disabled (can never be built)
);

--====================================================================================================================
-- Per-Building sidecar tables (Hills/Mountain plot yields + internal-TR yields)
--====================================================================================================================

-- Yield bonus on Hills plots worked by a city with this Building (parallel to vanilla Building_LakePlotYieldChanges)
CREATE TABLE IF NOT EXISTS _Building_HillsPlotYieldChanges (
	BuildingType	TEXT REFERENCES Buildings(Type),
	YieldType		TEXT REFERENCES Yields(Type),
	Yield			INTEGER DEFAULT 0,
	PRIMARY KEY (BuildingType, YieldType)
);

-- Yield bonus on Mountain plots worked by a city with this Building (parallel to vanilla Building_LakePlotYieldChanges)
CREATE TABLE IF NOT EXISTS _Building_MountainPlotYieldChanges (
	BuildingType	TEXT REFERENCES Buildings(Type),
	YieldType		TEXT REFERENCES Yields(Type),
	Yield			INTEGER DEFAULT 0,
	PRIMARY KEY (BuildingType, YieldType)
);

-- Flat yield added to the city holding this Building while the city's own plot is on a river
CREATE TABLE IF NOT EXISTS _Building_RiverCityYieldChanges (
	BuildingType	TEXT NOT NULL REFERENCES Buildings(Type),
	YieldType		TEXT NOT NULL REFERENCES Yields(Type),
	Yield			INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY (BuildingType, YieldType)
);

-- Flat yield added to INTERNAL trade routes originating from a city with this Building
CREATE TABLE IF NOT EXISTS _Building_InternalTradeRouteYieldChanges (
	BuildingType	TEXT REFERENCES Buildings(Type),
	YieldType		TEXT REFERENCES Yields(Type),
	Yield			INTEGER DEFAULT 0,
	PRIMARY KEY (BuildingType, YieldType)
);

-- Percent city yield modifier per owned INTERNATIONAL trade route departing the city
CREATE TABLE IF NOT EXISTS _Building_YieldModifierPerTradeRoute (
	BuildingType	TEXT REFERENCES Buildings(Type),
	YieldType		TEXT REFERENCES Yields(Type),
	Yield			INTEGER DEFAULT 0,
	PRIMARY KEY (BuildingType, YieldType)
);

-- OR requirements for local features: building is buildable if ANY listed Feature lies on one of the city's own tiles
-- (e.g. Angkor Wat / Chichen Itza requiring Jungle or Forest).
CREATE TABLE IF NOT EXISTS _Building_LocalFeatureOrs (
	BuildingType	TEXT NOT NULL REFERENCES Buildings(Type),
	FeatureType		TEXT NOT NULL REFERENCES Features(Type),
	PRIMARY KEY (BuildingType, FeatureType)
);

-- OR requirements for local improvements: building is buildable if ANY listed Improvement (unpillaged) lies on
-- one of the city's own tiles (e.g. the Herbalist requiring a Plantation).
CREATE TABLE IF NOT EXISTS _Building_LocalImprovementOrs (
	BuildingType	TEXT NOT NULL REFERENCES Buildings(Type),
	ImprovementType	TEXT NOT NULL REFERENCES Improvements(Type),
	PRIMARY KEY (BuildingType, ImprovementType)
);

-- OR requirements for resources in the vicinity: building is buildable if ANY of the city's own tiles carries a
-- listed Resource, improved or not.
-- Distinct from the vanilla Building_LocalResourceOrs table, which requires the resource to be improved and
-- linked to the city. The two are separate predicates and AND with each other, so a building
-- listed in both needs a connected resource AND a resource in the vicinity. Pick one table per building.
CREATE TABLE IF NOT EXISTS _Building_LocalResourceVicinityOrs (
	BuildingType	TEXT NOT NULL REFERENCES Buildings(Type),
	ResourceType	TEXT NOT NULL REFERENCES Resources(Type),
	PRIMARY KEY (BuildingType, ResourceType)
);

-- Per-turn XP granted to the owner's units garrisoned in a city with this building, by unit Domain
-- (e.g. an Airport grants XP to DOMAIN_AIR only).
-- The per-domain total a garrisoned unit gains this way is capped per turn by the global GD_CITY_GARRISON_MAX_XP_PER_TURN
-- UNITCOMBAT_RECON units are excluded outright: scouts belong in the field, not training in a city.
CREATE TABLE IF NOT EXISTS _Building_DomainExperiencePerTurn (
	BuildingType	TEXT NOT NULL REFERENCES Buildings(Type),
	DomainType		TEXT NOT NULL REFERENCES Domains(Type),
	iExperience		INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY (BuildingType, DomainType)
);

-- One-time instant yield on construction of this building (used like Goody Huts, e.g. Stonehenge).
CREATE TABLE IF NOT EXISTS _Building_YieldOnConstruction (
	BuildingType	TEXT NOT NULL REFERENCES Buildings(Type),
	YieldType		TEXT NOT NULL REFERENCES Yields(Type),
	Yield			INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY (BuildingType, YieldType)
);

-- EventYield (stateless, recomputed at the event -- NOT serialized). Yield granted whenever ANY
-- building is constructed in this building's city
CREATE TABLE IF NOT EXISTS _Building_YieldPerBuildingConstructed (
	BuildingType	TEXT NOT NULL REFERENCES Buildings(Type),
	YieldType		TEXT NOT NULL REFERENCES Yields(Type),
	Yield			INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY (BuildingType, YieldType)
);

-- The city holding BuildingType gains (Yield x Social Policies owned / 100) of YieldType, so Yield is a
-- PER-100 rate: 50 = one yield per two policies, the same ratio vanilla's Prora Resort uses for Happiness
-- via the Buildings.HappinessPerXPolicies column (which is Happiness-only and player-wide, hence this table).
-- Counted as a building yield so the city screen attributes it to the building, and read
-- live so adopting a policy shows immediately with no recompute hook.
CREATE TABLE IF NOT EXISTS _Building_YieldPer100XPolicies (
	BuildingType	TEXT NOT NULL REFERENCES Buildings(Type),
	YieldType		TEXT NOT NULL REFERENCES Yields(Type),
	Yield			INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY (BuildingType, YieldType)
);

-- STATEFUL per-turn yield x the owner's current count of allied / friendly city-states. A row with iMaxYield above 0
-- is paid LIVE instead, at most iMaxYield per building.
CREATE TABLE IF NOT EXISTS _Building_YieldPerAlly (
	BuildingType	TEXT NOT NULL REFERENCES Buildings(Type),
	YieldType		TEXT NOT NULL REFERENCES Yields(Type),
	Yield			INTEGER NOT NULL DEFAULT 0,
	iMaxYield		INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY (BuildingType, YieldType)
);
CREATE TABLE IF NOT EXISTS _Building_YieldPerFriend (
	BuildingType	TEXT NOT NULL REFERENCES Buildings(Type),
	YieldType		TEXT NOT NULL REFERENCES Yields(Type),
	Yield			INTEGER NOT NULL DEFAULT 0,
	iMaxYield		INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY (BuildingType, YieldType)
);

-- STATEFUL per-turn yield x the number of OUTGOING INTERNATIONAL trade routes departing this city,
-- capped at MaxInstances routes (-1 = uncapped). Counts only routes the city originates, unlike the
-- _Belief_YieldPerActiveTradeRoute twin (Divine Heralds), which is uncapped and counts routes in
-- both directions.
-- CAP LIMITATION: the per-city accumulator holds a summed rate and a summed ceiling, so the cap is
-- exact for any number of Buildings that share a MaxInstances for a given yield, but is over-generous
-- if two Buildings in one city cap the SAME yield at DIFFERENT values (it would cap at the sum of
-- their ceilings rather than each individually). Give same-yield Buildings the same MaxInstances.
CREATE TABLE IF NOT EXISTS _Building_YieldPerActiveTradeRoute (
	BuildingType	TEXT NOT NULL REFERENCES Buildings(Type),
	YieldType		TEXT NOT NULL REFERENCES Yields(Type),
	Yield			INTEGER NOT NULL DEFAULT 0,
	MaxInstances	INTEGER NOT NULL DEFAULT -1,
	PRIMARY KEY (BuildingType, YieldType)
);

-- STATEFUL yield % MODIFIER applied while the owner is in a golden age (Yield = percent).
CREATE TABLE IF NOT EXISTS _Building_GoldenAgeYieldMod (
	BuildingType	TEXT NOT NULL REFERENCES Buildings(Type),
	YieldType		TEXT NOT NULL REFERENCES Yields(Type),
	Yield			INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY (BuildingType, YieldType)
);

-- STATEFUL yield in this city per great work the owner has, empire-wide. A row with iMaxYield above 0 is paid LIVE
-- instead, at most iMaxYield per building.
CREATE TABLE IF NOT EXISTS _Building_YieldPerEmpireGreatWork (
	BuildingType	TEXT NOT NULL REFERENCES Buildings(Type),
	YieldType		TEXT NOT NULL REFERENCES Yields(Type),
	Yield			INTEGER NOT NULL DEFAULT 0,
	iMaxYield		INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY (BuildingType, YieldType)
);

-- LIVE Happiness for the owner: Happiness for every city that holds a building of BuildingClassType (the owner's
-- building for that class). A city counts once per BuildingType, at the highest Happiness among its listed classes.
CREATE TABLE IF NOT EXISTS _Building_HappinessPerCityWithClass (
	BuildingType		TEXT NOT NULL REFERENCES Buildings(Type),
	BuildingClassType	TEXT NOT NULL REFERENCES BuildingClasses(Type),
	Happiness			INTEGER NOT NULL DEFAULT 1,
	PRIMARY KEY (BuildingType, BuildingClassType)
);

-- LIVE yield in this city per DIFFERENT civilization (majors and city-states) that created a Great Work of GreatWorkClass
-- displayed anywhere in the owner's empire (an Artifact's creator is the civilization of its dig site), capped at iMaxCivs
-- civilizations when above 0.
CREATE TABLE IF NOT EXISTS _Building_YieldPerGreatWorkCivilization (
	BuildingType	TEXT NOT NULL REFERENCES Buildings(Type),
	GreatWorkClass	TEXT NOT NULL REFERENCES GreatWorkClasses(Type),
	YieldType		TEXT NOT NULL REFERENCES Yields(Type),
	Yield			INTEGER NOT NULL DEFAULT 0,
	iMaxCivs		INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY (BuildingType, GreatWorkClass, YieldType)
);
-- LIVE yield in this city per unit of ResourceType the owner has available (total minus what units and buildings consume,
-- imports included), capped at iMaxYield when above 0.
CREATE TABLE IF NOT EXISTS _Building_YieldPerUnusedResource (
	BuildingType	TEXT NOT NULL REFERENCES Buildings(Type),
	ResourceType	TEXT NOT NULL REFERENCES Resources(Type),
	YieldType		TEXT NOT NULL REFERENCES Yields(Type),
	Yield			INTEGER NOT NULL DEFAULT 0,
	iMaxYield		INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY (BuildingType, ResourceType, YieldType)
);
-- LIVE yield in this city per building of the class the owner has, empire-wide.
CREATE TABLE IF NOT EXISTS _Building_YieldPerEmpireBuildingClass (
	BuildingType		TEXT NOT NULL REFERENCES Buildings(Type),
	BuildingClassType	TEXT NOT NULL REFERENCES BuildingClasses(Type),
	YieldType			TEXT NOT NULL REFERENCES Yields(Type),
	Yield				INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY (BuildingType, BuildingClassType, YieldType)
);
-- LIVE: iPercent of a technology's research cost goes to the owner's overflow research whenever a tech completes through research.
CREATE TABLE IF NOT EXISTS _Building_ResearchOnTechDiscovery (
	BuildingType	TEXT PRIMARY KEY NOT NULL REFERENCES Buildings(Type),
	iPercent		INTEGER NOT NULL DEFAULT 0
);
-- STATEFUL yield in this city per great work in this city.
CREATE TABLE IF NOT EXISTS _Building_YieldPerLocalGreatWork (
	BuildingType	TEXT NOT NULL REFERENCES Buildings(Type),
	YieldType		TEXT NOT NULL REFERENCES Yields(Type),
	Yield			INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY (BuildingType, YieldType)
);

-- Building grants a LOCAL yield to every building of a class in the same city.
CREATE TABLE IF NOT EXISTS _Building_BuildingClassLocalYieldChanges (
	BuildingType		TEXT NOT NULL REFERENCES Buildings(Type),
	BuildingClassType	TEXT NOT NULL REFERENCES BuildingClasses(Type),
	YieldType			TEXT NOT NULL REFERENCES Yields(Type),
	iYieldChange		INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY (BuildingType, BuildingClassType, YieldType)
);

-- LOCAL (this-city) extra yield for a worked Specialist type (e.g. Madagascar's National Epic: +1 Culture from every Specialist in its city).
CREATE TABLE IF NOT EXISTS _Building_SpecialistYieldChangesLocal (
	BuildingType		TEXT NOT NULL REFERENCES Buildings(Type),
	SpecialistType		TEXT NOT NULL REFERENCES Specialists(Type),
	YieldType			TEXT NOT NULL REFERENCES Yields(Type),
	Yield				INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY (BuildingType, SpecialistType, YieldType)
);

-- Great Person rate modifier (%) in this city for the Great Person points of one specialist type.
CREATE TABLE IF NOT EXISTS _Building_SpecialistGreatPersonRateModifier (
	BuildingType		TEXT NOT NULL REFERENCES Buildings(Type),
	SpecialistType		TEXT NOT NULL REFERENCES Specialists(Type),
	iModifier			INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY (BuildingType, SpecialistType)
);

-- LOCAL (this-city) extra yield to all improvements of a type (e.g. UB grants +yield to its civ's wells/mines).
CREATE TABLE IF NOT EXISTS _Building_ImprovementYieldChanges (
	BuildingType		TEXT NOT NULL REFERENCES Buildings(Type),
	ImprovementType	TEXT NOT NULL REFERENCES Improvements(Type),
	YieldType			TEXT NOT NULL REFERENCES Yields(Type),
	Yield				INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY (BuildingType, ImprovementType, YieldType)
);

-- LOCAL city yield per worked plot of an improvement (unpillaged), capped at iMaxYield when above 0. Paid as building
-- yield, Culture and Faith included; shown live in the building tooltip.
CREATE TABLE IF NOT EXISTS _Building_YieldPerWorkedImprovement (
	BuildingType		TEXT NOT NULL REFERENCES Buildings(Type),
	ImprovementType	TEXT NOT NULL REFERENCES Improvements(Type),
	YieldType			TEXT NOT NULL REFERENCES Yields(Type),
	Yield				INTEGER NOT NULL DEFAULT 0,
	iMaxYield			INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY (BuildingType, ImprovementType, YieldType)
);

-- LOCAL religious pressure per worked plot of an improvement (unpillaged): +iModifier percent to the pressure the city
-- sends, capped at iMaxModifier when above 0, on top of the building's own ReligiousPressureModifier. Shown live in
-- the building tooltip.
CREATE TABLE IF NOT EXISTS _Building_PressurePerWorkedImprovement (
	BuildingType		TEXT NOT NULL REFERENCES Buildings(Type),
	ImprovementType	TEXT NOT NULL REFERENCES Improvements(Type),
	iModifier			INTEGER NOT NULL DEFAULT 0,
	iMaxModifier		INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY (BuildingType, ImprovementType)
);

-- ONE-SHOT terraform on first construction -- plant up to iNumPlots tiles of FeatureType within
-- iRadius of the city, between iMinLatitude and iMaxLatitude.
-- Defaults let content specify just (BuildingType, FeatureType, iNumPlots): iRadius=3 (work radius), full latitude band.
CREATE TABLE IF NOT EXISTS _Building_FeaturePlotsToPlace (
	BuildingType	TEXT NOT NULL REFERENCES Buildings(Type),
	FeatureType	TEXT NOT NULL REFERENCES Features(Type),
	iNumPlots		INTEGER NOT NULL DEFAULT 0,
	iRadius			INTEGER NOT NULL DEFAULT 3,
	iMinLatitude	INTEGER NOT NULL DEFAULT 0,
	iMaxLatitude	INTEGER NOT NULL DEFAULT 90,
	bImprovedPlots	INTEGER NOT NULL DEFAULT 0,
	-- 1 = also plant on improved plots the feature keeps valid (the feature allows improvements and no build that makes the
	-- improvement clears it: a Farm clears Forest), and on resource plots only through such an improvement and only where the
	-- resource can stand under the feature. 0 = empty land only (no improvement, no resource).
	bRequiresFreshWater	INTEGER NOT NULL DEFAULT 0,
	-- 1 = plant only on fresh-water plots (Marsh by rivers and lakes). These rows are placed first, before every other row.
	bNoAdjacentSame	INTEGER NOT NULL DEFAULT 0,
	-- 1 = never next to the same feature (Atolls). Oasis needs no flag: Features.NoAdjacent already keeps oases apart, and a
	-- placed oasis makes its neighbours fresh water, which the built-in Oasis rule excludes.
	-- The other rows run in Features ID order (Jungle, Marsh, Oasis, Flood Plains, Forest, ... Atoll), each within its own
	-- radius and latitude band, and every plot must allow the feature (terrain, flatlands, coast and river rules).
	PRIMARY KEY (BuildingType, FeatureType)
);

-- Per-turn Influence (x100) with every City-State connected to this building's city by an active trade
-- route (e.g. Canada's Hockey Rink). Best city value per City-State;
-- routes and cities do not stack.
CREATE TABLE IF NOT EXISTS _Building_TradeRouteCSInfluencePerTurn (
	BuildingType							TEXT PRIMARY KEY REFERENCES Buildings(Type),
	iInfluenceTimes100						INTEGER DEFAULT 100
);

-- Convert iValue% of YieldIn into YieldOut, city-local (e.g. Greece Amphitheater: 10% of Production -> Culture).
CREATE TABLE IF NOT EXISTS _Building_YieldFromYieldPercent (
	BuildingType	TEXT NOT NULL REFERENCES Buildings(Type),
	eYieldIn		TEXT NOT NULL REFERENCES Yields(Type),
	eYieldOut		TEXT NOT NULL REFERENCES Yields(Type),
	iValue			INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY (BuildingType, eYieldIn, eYieldOut)
);

-- Share of the city's FOOD SURPLUS (Food produced minus Food eaten, positive only, zero under Avoid Growth,
-- growth modifiers excluded) added to YieldType as base yield. Summed from the city's buildings into a
-- per-city cache rebuilt on load, so it is never serialized.
CREATE TABLE IF NOT EXISTS _Building_YieldFromFoodSurplusPercent (
	BuildingType	TEXT NOT NULL REFERENCES Buildings(Type),
	YieldType		TEXT NOT NULL REFERENCES Yields(Type),
	iPercent		INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY (BuildingType, YieldType)
);

-- Percent modifier to the yield the city gets from running ProcessType while it owns this building
-- (+20 = that Process converts 20% more Production). Summed from the city's buildings on demand.
CREATE TABLE IF NOT EXISTS _Building_ProcessModifiers (
	BuildingType	TEXT NOT NULL REFERENCES Buildings(Type),
	ProcessType		TEXT NOT NULL REFERENCES Processes(Type),
	iModifier		INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY (BuildingType, ProcessType)
);

-- Extra yield from a Resource worked by this city, but ONLY when that resource's tile is improved (and the
-- improvement is not pillaged). Improved-only variant of Building_ResourceYieldChanges.
CREATE TABLE IF NOT EXISTS _Building_ImprovedResourceYieldChanges (
	BuildingType	TEXT REFERENCES Buildings(Type),
	ResourceType	TEXT REFERENCES Resources(Type),
	YieldType		TEXT REFERENCES Yields(Type),
	Yield			INTEGER DEFAULT 0,
	PRIMARY KEY (BuildingType, ResourceType, YieldType)
);

-- Constructable only while the empire owns at least iNumRequired buildings of the class. Unscaled, unlike
-- vanilla Building_PrereqBuildingClasses, whose count multiplies with world size and so cannot express an
-- N=1 gate on a one-per-player prerequisite on the largest maps.
CREATE TABLE IF NOT EXISTS _Building_PrereqEmpireBuildingClasses (
	BuildingType		TEXT NOT NULL REFERENCES Buildings(Type),
	BuildingClassType	TEXT NOT NULL REFERENCES BuildingClasses(Type),
	iNumRequired		INTEGER NOT NULL DEFAULT 1,
	PRIMARY KEY (BuildingType, BuildingClassType)
);

-- BuildingType is not constructible while the empire owns or builds BuildingClassType, and vice versa.
CREATE TABLE IF NOT EXISTS _Building_MutuallyExclusiveEmpire (
	BuildingType		TEXT NOT NULL REFERENCES Buildings(Type),
	BuildingClassType	TEXT NOT NULL REFERENCES BuildingClasses(Type),
	PRIMARY KEY (BuildingType, BuildingClassType)
);

-- On construction, place ResourceQuantityToPlace of ResourceType on up to NumPlots eligible tiles in the city's
-- working range (deterministic ring-plot order, no RNG -> MP-safe).
CREATE TABLE IF NOT EXISTS _Building_ResourcePlotsToPlace (
	BuildingType				TEXT NOT NULL REFERENCES Buildings(Type),
	ResourceType				TEXT NOT NULL REFERENCES Resources(Type),
	iNumPlots					INTEGER DEFAULT 1,
	iResourceQuantityToPlace		INTEGER DEFAULT 1,
	PRIMARY KEY (BuildingType, ResourceType)
);

-- On construction, the city claims up to NumPlots unowned, unimproved tiles holding ResourceType (visible to the
-- owner) in its working range, nearest first (deterministic ring-plot order, no RNG -> MP-safe). A tile the building
-- places the same resource on at construction is claimed as well and does not count.
CREATE TABLE IF NOT EXISTS _Building_ResourcePlotsToClaim (
	BuildingType	TEXT NOT NULL REFERENCES Buildings(Type),
	ResourceType	TEXT NOT NULL REFERENCES Resources(Type),
	iNumPlots		INTEGER DEFAULT 1,
	PRIMARY KEY (BuildingType, ResourceType)
);

-- Building requires the player to have adopted PolicyType before it can be constructed (Policy National Wonders = finisher wonders).
CREATE TABLE IF NOT EXISTS _Building_Policy (
	BuildingType	TEXT PRIMARY KEY NOT NULL REFERENCES Buildings(Type),
	PolicyType		TEXT NOT NULL REFERENCES Policies(Type)
);

-- Owning at least one copy of BuildingType grants PolicyType (free) and the last copy lost revokes it. Reconciled
-- every turn from the buildings actually owned, so it needs no state. Give each building its OWN policy: the revoke
-- cannot tell whether another source (a trait policy, an alliance bonus) also granted the same one.
CREATE TABLE IF NOT EXISTS _Building_GrantedPolicy (
	BuildingType	TEXT PRIMARY KEY NOT NULL REFERENCES Buildings(Type),
	PolicyType		TEXT NOT NULL REFERENCES Policies(Type)
);

-- Per-building yield scaled by the number of DIFFERENT improved Resource types the city works.
-- Grants Yield per iPerNumResourceTypes distinct worked improved Resources, capped at iMaxYield.
-- (Hebrews LMLK Storehouse.)
CREATE TABLE IF NOT EXISTS _Building_ResourceDiversityYields (
	BuildingType			TEXT REFERENCES Buildings(Type),
	YieldType				TEXT REFERENCES Yields(Type),
	iPerNumResourceTypes	INTEGER DEFAULT 3,
	iMaxYield				INTEGER DEFAULT 3,
	PRIMARY KEY (BuildingType, YieldType)
);

-- Resource-buildings list many local-resource prereqs (a building may accept any of N plantation luxuries, N>5).
-- Vanilla NUM_BUILDING_RESOURCE_PREREQS = 5 truncates the OR-list to the first 5; bump so all are honored.
REPLACE INTO Defines (Name, Value) VALUES ('NUM_BUILDING_RESOURCE_PREREQS', 20) /* vanilla 5 */;

--====================================================================================================================
-- MOD SUPPORT -- nearby-resource building gates
--====================================================================================================================
-- Rows of the Lua hook table Building_RequireNearbyResourcesORS move to _Building_LocalResourceVicinityOrs.
CREATE TABLE IF NOT EXISTS Building_RequireNearbyResourcesORS (
	BuildingType	TEXT,
	ResourceType	TEXT
);

-- Rows already present when this runs.
INSERT OR IGNORE INTO _Building_LocalResourceVicinityOrs (BuildingType, ResourceType)
SELECT h.BuildingType, h.ResourceType FROM Building_RequireNearbyResourcesORS h
WHERE EXISTS (SELECT 1 FROM Buildings  WHERE Type = h.BuildingType)
  AND EXISTS (SELECT 1 FROM Resources  WHERE Type = h.ResourceType);

-- Retire a hook row once its native row exists.
DELETE FROM Building_RequireNearbyResourcesORS
WHERE EXISTS (
	SELECT 1 FROM _Building_LocalResourceVicinityOrs v
	WHERE v.BuildingType = Building_RequireNearbyResourcesORS.BuildingType
	  AND v.ResourceType = Building_RequireNearbyResourcesORS.ResourceType);

-- Rows that arrive later, when the carrying mod loads after this one.
CREATE TRIGGER IF NOT EXISTS GAIA_NearbyResourceHook
AFTER INSERT ON Building_RequireNearbyResourcesORS
BEGIN
	INSERT OR IGNORE INTO _Building_LocalResourceVicinityOrs (BuildingType, ResourceType)
	SELECT NEW.BuildingType, NEW.ResourceType
	WHERE EXISTS (SELECT 1 FROM Buildings  WHERE Type = NEW.BuildingType)
	  AND EXISTS (SELECT 1 FROM Resources  WHERE Type = NEW.ResourceType);

	DELETE FROM Building_RequireNearbyResourcesORS
	WHERE rowid = NEW.rowid
	  AND EXISTS (
		SELECT 1 FROM _Building_LocalResourceVicinityOrs v
		WHERE v.BuildingType = NEW.BuildingType AND v.ResourceType = NEW.ResourceType);
END;

--====================================================================================================================
UPDATE Sapiens_DBUpdates SET Value = 1 WHERE Name = 'DB_Buildings';
