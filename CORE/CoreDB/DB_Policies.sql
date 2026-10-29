-- written by GAIA using Notepad++
CREATE TABLE IF NOT EXISTS Sapiens_DBUpdates (Name TEXT PRIMARY KEY, Value INTEGER DEFAULT 0);
INSERT OR IGNORE INTO Sapiens_DBUpdates (Name) VALUES ('DB_Policies');
--====================================================================================================================
-- POLICY TABLE EXTENSIONS
--====================================================================================================================

CREATE TABLE IF NOT EXISTS _Policies_Extensions (
	PolicyType								TEXT PRIMARY KEY REFERENCES Policies(Type),

	bAlliedCSOverseasTerritory				INTEGER DEFAULT 0,
	-- When set, City-States allied to the policy holder are treated as the holder's overseas
	-- territory for unit passage. Anyone with Open Borders with the holder can transit through
	-- the holder's allied CSs.

	bCanBuyNonAdjacentTiles					INTEGER DEFAULT 0,
	-- Civ may purchase foreign-owned non-city tiles at +50% cost, and the per-city plot-bought cost ramp resets on founding

	bCanCrossIce							INTEGER DEFAULT 0,
	-- Civ-wide grant: combat units may cross ice tiles

	bCanCrossMountains						INTEGER DEFAULT 0,
	-- Civ-wide grant: units may move into/through mountain tiles unconditionally

	bCanFoundOnWater						INTEGER DEFAULT 0,
	-- Civ-wide grant: the player may found cities on ANY water tile (coast, ocean, or lake). Reachability is the real limiter -- a Settler must embark to reach coast, and deep ocean naturally waits for Astronomy embarkation.

	bCanPlunderWithoutWar					INTEGER DEFAULT 0,
	-- The player's units may plunder trade routes without declaring war (Madagascar trait-policy; promotion twin = _UnitPromotions_Extensions.bCanPlunderWithoutWar).

	bCanPurchaseInPuppetsGlobal				INTEGER DEFAULT 0,
	-- Empire-wide (Venice-style): while this policy is adopted, the player may Gold/Faith-purchase ANY unit/building
	-- in their Puppet cities, even for non-Venice civs.
	-- (Per-unit/building opt-in is the separate _Units/_Buildings_Extensions.bCanPurchaseInPuppets.)

	bCanPurchaseMetCivUniqueUnits			INTEGER DEFAULT 0,
	-- The holder may also buy with Gold (never train, never with Faith) the unique units of every major civilization its
	-- team has met (eliminated ones included): the units another civilization fields in place of its class's default.
	-- Never Legendary units or Great People. Every other purchase gate still applies. (Mercenary Army.)

	bCanTrainMetCivUniqueUnits				INTEGER DEFAULT 0,
	-- The holder may also train and buy the unique units of every major civilization its team has met (eliminated ones
	-- included): the units another civilization fields in place of its class's default. Never Legendary units or Great
	-- People. Every other training gate still applies.

	bCanUpgradeVassalCSTerritory					INTEGER DEFAULT 0,
	-- When set, units owned by the policy holder can upgrade while standing in an allied
	-- City-State's or a Vassal's territory, just as they would in the holder's own cities.

	bColonyCityStates						INTEGER DEFAULT 0,
	-- Chartered Colonists founding on a landmass other than the capital's charter a new City-State allied to the holder
	-- instead of a Puppet when the site qualifies (distance to City-States, unclaimed ring, landmass size, per-player cap).

	bConqueredBuildingsToCapital			INTEGER DEFAULT 0,
	-- Conquered cities' buildings are (also) added to the conqueror's capital (Huns).

	bForeignFaithBuildingPurchase			INTEGER DEFAULT 0,
	-- Each of the holder's cities may buy with Faith the Place of Worship of the most-followed FOREIGN religion present
	-- in it, one foreign house per city.

	bFreeTechFromBelief						INTEGER DEFAULT 0,
	-- Free technology each time the player founds a pantheon/religion or adds beliefs (Kongo trait-policy).

	bFreeTechFromPolicyBranch				INTEGER DEFAULT 0,
	-- Free technology each time a social policy branch is completed (Vietnam trait-policy).

	bGGFromBarbarians						INTEGER DEFAULT 0,
	-- Civ earns Great General points from killing Barbarians (vanilla excludes them).

	bInternalCaravansClaimTiles				INTEGER DEFAULT 0,
	-- Internal (non-international) trade routes claim unowned land plots they pass through for the route owner's nearest city (Canada trait-policy).

	bNoAlliedCSInfluenceDecayAtWar			INTEGER DEFAULT 0,
	-- Allied City-States do not lose Influence while the policy holder is at war

	bNoWarSameReligion						INTEGER DEFAULT 0,
	-- Before the Industrial Era, war cannot be declared between this player and civs whose majority religion matches the religion he founded (Madagascar trait-policy).

	bPhoenicianColonies						INTEGER DEFAULT 0,
	-- The player's first 3 expansions (cities 2-4) found City-States (Byblos/Tyre/Sidon) instead of cities (Carthage trait-policy).

	bTechBoostFromCapitalCultureBuildings	INTEGER DEFAULT 0,
	-- Culture buildings constructed in the capital grant a median-tech research boost, mirroring vanilla Korea's science-building boost (Vietnam trait-policy).

	eFreeUnitOnFound						TEXT DEFAULT NULL REFERENCES UnitClasses(Type),
	-- On founding a city, grants one free unit of this UnitClass (the holder's civ unit for the class) at the new city

	iOverseasNewCityExtraPopulation			INTEGER DEFAULT 0,
	-- Extra starting Population for a city the holder founds on a landmass other than the capital's
	-- (the first city and chartered City-States get nothing, puppet colonies do).

	eOverseasFreeUnitOnFound				TEXT DEFAULT NULL REFERENCES UnitClasses(Type),
	-- Like eFreeUnitOnFound, but only for a city founded on a landmass other than the capital's.

	eOverseasFreeBuildingOnFound				TEXT DEFAULT NULL REFERENCES BuildingClasses(Type),
	-- Like eOverseasFreeUnitOnFound, but one free building of this class, placed where its location is valid.

	iAbsentCivUniqueBuildings				INTEGER DEFAULT 0,
	iAbsentCivUniqueNationalWonders			INTEGER DEFAULT 0,
	eAbsentCivUniquesMinEra				TEXT DEFAULT NULL REFERENCES Eras(Type),
	-- The holder takes over this many unique buildings / unique national wonders of civilizations absent at game start,
	-- each from a different civilization. Drawn once on the player's first turn when its civilization can build a
	-- building that grants this policy (_Building_GrantedPolicy), so that building's tooltip can list them; in effect from the
	-- first turn the policy is held, replacing the class's default building in every city, and kept for good.
	-- eAbsentCivUniquesMinEra: only buildings unlocking in this era or later are drawn (tech era or eRequiresEra, whichever is later).

	iAdditionalPersonalQuest				INTEGER DEFAULT 0,
	-- Additional simultaneous minor-civ personal quests allowed

	iBuildingGoldToCulture					INTEGER DEFAULT 0,
	-- % of a building's gold purchase cost converted to a one-time culture bonus

	iCapitalGoldPerVassalScalingEra			INTEGER DEFAULT 0,
	-- Flat Gold per turn in the Capital for each Vassal the holder has, multiplied by (current era + 1).
	-- Summed on demand over the holder's active policies.

	iCityExtraWorkRange						INTEGER DEFAULT 0,
	-- Policy extends each city's workable plot range

	iCityStateAllianceCombatMod				INTEGER DEFAULT 0,
	-- Combat-strength bonus (%) per allied city-state, capped at 5 allies (Greece).

	iCityStrengthModifier					INTEGER DEFAULT 0,
	-- Flat bonus to every city's defensive combat strength

	iCityStrengthPerDamageMax				INTEGER DEFAULT 0,
	-- Every city's defensive combat strength grows with the damage it has taken: +this percent at its last hit point,
	-- linear in damage / max hit points, computed live from the current damage.

	iConversionModifier						INTEGER DEFAULT 0,
	-- Policy contribution to Religion-spread resistance (negative = weaker defense)

	iAttackMod								INTEGER DEFAULT 0,
	-- Attack strength modifier (%) for every unit of the holder. Summed over the active policies.

	iAttackerCombatXPMod					INTEGER DEFAULT 0,
	-- % more experience a unit of the holder earns from combat it started (attacker only; Great General points unchanged).

	iCombatXP								INTEGER DEFAULT 0,
	-- Flat experience every unit of the holder gains per combat, on top of the fight's own experience.

	iDefenseMod								INTEGER DEFAULT 0,
	-- Defense strength modifier (%) for every unit of the holder.

	iExtraHeal								INTEGER DEFAULT 0,
	-- Extra healing per turn for every unit of the holder.

	iExtraNavalMoves						INTEGER DEFAULT 0,
	-- Extra movement for the holder's naval units.

	iSeaTradeRouteTollPercent				INTEGER DEFAULT 0,
	-- Sound Dues: every FOREIGN sea trade route whose path crosses a plot the policy holder owns pays the holder this
	-- share of the route's per-turn Gold (once per route per turn, from the route owner's treasury, never below zero).
	-- Routes that start or end in the holder's own cities are exempt. Summed on demand over the holder's active
	-- policies, so a trait policy (_Trait_GrantedPolicy), a city-state alliance bonus or any other policy grant can carry it.

	iWLTKDModifier							INTEGER DEFAULT 0,
	-- % bonus to the duration of a resource-demand We Love The King Day in every city of the holder (Versailles).
	-- Summed on demand over active policies.

	iExtraMissionarySpreads					INTEGER DEFAULT 0,
	-- Extra spread charges on every Missionary the holder trains, in any city (Great Mosque of Djenne).
	-- Summed on demand over active policies.

	iExtraCityHitPoints						INTEGER DEFAULT 0,
	-- Flat bonus to every city's max hit points

	iExtraCoupChance						INTEGER DEFAULT 0,
	-- Additive % to spy coup success chance

	iExtraHappinessForFollowingCity			INTEGER DEFAULT 0,
	-- Bonus happiness per city following the player's majority religion

	iExtraTradeRoutes						INTEGER DEFAULT 0,
	-- Extra international trade route slots granted to the player

	iFasterPersonalQuest					INTEGER DEFAULT 0,
	-- Speeds up minor-civ personal quest availability

	iGarrisonedMilitaryProductionMod		INTEGER DEFAULT 0,
	-- % production modifier toward military Units in a city that has a garrison (Sikh Empire trait-policy).
	-- The garrison-conditional twin of the unconditional Buildings/Policies.MilitaryProductionModifier.

	iGreatDeveloperRateModifier				INTEGER DEFAULT 0,
	-- % modifier to Great Developer (VideoGames GP) generation rate

	iGreatDirectorRateModifier				INTEGER DEFAULT 0,
	-- % modifier to Great Director generation rate

	iGreatEmissaryRateModifier				INTEGER DEFAULT 0,
	-- % modifier to Great Emissary generation rate

	iGreatGeneralExtraBonus					INTEGER DEFAULT 0,
	-- Flat bonus to the Great General aura combat modifier granted by this policy (City-State Wonders 'Sokoto')

	iGreatThinkerRateModifier				INTEGER DEFAULT 0,
	-- % modifier to Great Thinker generation rate

	iHappinessPerBonusResourceType			INTEGER DEFAULT 0,
	-- Happiness for every different Bonus resource the holder has improved, as if it were a Luxury.


	iInfluenceMeetCS						INTEGER DEFAULT 0,
	-- Flat Influence gained with each City-State on first contact (Siam trait-policy).

	iScienceMeetCS						INTEGER DEFAULT 0,
	-- Flat Science added to the holder's current research on first contact with each City-State.

	iInstantSpyRankChange					INTEGER DEFAULT 0,
	-- One-time promotion of all current spies by this many ranks on adoption

	iKillCultureToBorderGrowthPercent		INTEGER DEFAULT 0,
	-- This share (%) of the Culture the holder earns from a unit kill is ALSO deposited as stored Culture in the
	-- nearest owned city, so kills push that city's borders outward. The player-wide Culture award is unchanged.

	iNumBestMeleeLandUnits					INTEGER DEFAULT 0,
	-- Grants this many copies of the player's strongest trainable non-ranged land unit (warrior fallback) at the capital on adoption

	iNumCitiesFreeDefenseBuilding			INTEGER DEFAULT 0,
	-- Grants a free defense building (cheapest available defensive building) to this many of the player's cities on adoption

	iNumFreeSpies							INTEGER DEFAULT 0,
	-- Grants this many free spies to the player on adoption

	iPeaceWonderProductionMod				INTEGER DEFAULT 0,
	-- % production modifier toward Wonders while at peace (Morocco).

	iProphetSpawnGoldBonusPerFollower		INTEGER DEFAULT 0,
	-- Gold granted per follower when a Great Prophet spawns

	iProphetSpawnGoldenAgeBonusPerFollower	INTEGER DEFAULT 0,
	-- Golden-age points granted per follower when a Great Prophet spawns

	iProphetSpawnProductionBonusPerFollower	INTEGER DEFAULT 0,
	-- Production granted per follower when a Great Prophet spawns

	iProjectProductionMod					INTEGER DEFAULT 0,
	-- % production modifier toward Projects in every city of the holder.

	iQuestRewardMod							INTEGER DEFAULT 0,
	-- % modifier to Influence gained from completing City-State quests; summed into the player's quest-reward bonus (Philanthropy).

	iRemoveCoupCapChance					INTEGER DEFAULT 0,
	-- Additive % that removes the coup success-chance cap

	iResistanceMod							INTEGER DEFAULT 0,
	-- Modifier to post-conquest occupation resistance turns in captured cities (negative = shorter resistance)

	iSeaTradeRouteRangeBonus				INTEGER DEFAULT 0,
	-- Flat bonus (in tiles) to sea trade route range.

	iSpaceshipProductionMod					INTEGER DEFAULT 0,
	-- Production modifier (%) for spaceship parts in every city of the holder. Summed over the active policies.

	iSpaceshipPurchaseMod					INTEGER DEFAULT 0,
	-- Purchase cost modifier (%) for spaceship parts in every city of the holder. Summed over the active policies.

	iSpyRankChange							INTEGER DEFAULT 0,
	-- Bonus starting rank for spies (applied to existing + future spies on adoption)

	iTourismMod								INTEGER DEFAULT 0,
	-- Tourism modifier (%) for every city of the holder, signed: a penalty applies. Summed over the active policies.

	iTradeRouteLandDistanceModifier			INTEGER DEFAULT 0,
	-- Per-policy bonus to land trade route distance

	iTradeRouteSeaDistanceModifier			INTEGER DEFAULT 0,
	-- Per-policy bonus to sea trade route distance

	iTradeRouteVision						INTEGER DEFAULT 0,
	-- Sight range of the player's TRADE units
	-- NOTE: with this feature trade units have NO base vision -- they only see what policies grant.

	iVassalUnitGiftBaseTurns				INTEGER DEFAULT 0,
	-- Average number of turns between free Unit gifts from each of the holder's Vassals (0 = no gifting).
	-- Rolled per vassal per turn at a 1-in-N chance rather than counted down, so no per-vassal state is stored.
	-- Scaled by game speed. The gifted unit is the VASSAL's best trainable land unit, placed at the master's Capital.

	iWarUnitProductionMod					INTEGER DEFAULT 0,
	-- % production modifier toward military Units while at war (Morocco).

	iXPFromGreatGeneralBirth				INTEGER DEFAULT 0,
	-- When a Great General is born, heal all the civ's land combat units and grant them this much XP each (China).

	iXPFromGreatGeneralExpended				INTEGER DEFAULT 0,
	-- When a Great General is expended, grant all the civ's land combat units this much XP each

	iHealFromGreatGeneralExpended			INTEGER DEFAULT 0
	-- HP each land combat unit heals when a Great General is expended; 0 = full heal, negative = none.
);

--====================================================================================================================
-- NEW POLICY TABLES (alphabetical)
--====================================================================================================================

-- Per-policy Gold-maintenance modifier for every building of a BuildingClass the holder owns (negative = cheaper;
-- -100 = free). Keyed on BuildingClass so a civ's unique replacement is covered by the same row.
CREATE TABLE IF NOT EXISTS _Policy_BuildingClassMaintenanceMod (
	PolicyType			TEXT REFERENCES Policies(Type),
	BuildingClassType	TEXT REFERENCES BuildingClasses(Type),
	iMod				INTEGER DEFAULT 0,
	PRIMARY KEY (PolicyType, BuildingClassType)
);

-- City-wide modifiers a policy confers on every city that OWNS a building of this BuildingClass. Distinct from
-- Policy_BuildingClassProductionModifiers (which speeds up BUILDING that class) and from
-- Policy_BuildingClassYieldChanges (which pays a flat yield per building of that class).
-- Keyed on BuildingClass so a civ's unique replacement is covered by the same row.
CREATE TABLE IF NOT EXISTS _Policy_BuildingClassCityModifiers (
	PolicyType					TEXT REFERENCES Policies(Type),
	BuildingClassType			TEXT REFERENCES BuildingClasses(Type),
	BuildingProductionModifier	INTEGER DEFAULT 0,
	FoodModifier				INTEGER DEFAULT 0,
	PRIMARY KEY (PolicyType, BuildingClassType)
);

-- The holder may buy buildings of BuildingClassType with Faith in any non-puppet city, no religion or belief needed, at their
-- own Faith price; buildings without one cost iGoldPricePercent of the city's Gold price (100 = the same number).
CREATE TABLE IF NOT EXISTS _Policy_BuildingClassFaithPurchase (
	PolicyType			TEXT REFERENCES Policies(Type),
	BuildingClassType	TEXT REFERENCES BuildingClasses(Type),
	iGoldPricePercent	INTEGER DEFAULT 100,
	PRIMARY KEY (PolicyType, BuildingClassType)
);

-- Cities of the holder owning a building of BuildingClassType send iModifier % more religious pressure for the holder's
-- religion (the one it founded, else the one in most of its cities). Summed over the listed classes the city owns.
CREATE TABLE IF NOT EXISTS _Policy_BuildingClassPressureModifier (
	PolicyType			TEXT REFERENCES Policies(Type),
	BuildingClassType	TEXT REFERENCES BuildingClasses(Type),
	iModifier			INTEGER DEFAULT 0,
	PRIMARY KEY (PolicyType, BuildingClassType)
);

-- Builds a unit of UnitCombatType may perform while inside a Great General's command range, even though its own
-- Units.Builds rows do not list them.
CREATE TABLE IF NOT EXISTS _Policy_BuildsNearGreatGeneral (
	PolicyType		TEXT REFERENCES Policies(Type),
	BuildType		TEXT REFERENCES Builds(Type),
	UnitCombatType	TEXT REFERENCES UnitCombatInfos(Type),
	PRIMARY KEY (PolicyType, BuildType, UnitCombatType)
);

-- Per-turn Experience for units of a Domain stationed in any of the holder's cities. The policy-keyed twin of
-- _Building_DomainExperiencePerTurn, and summed together with it under the same
-- GD_CITY_GARRISON_MAX_XP_PER_TURN per-turn throttle and GD_IMPROVEMENT_MAX_XP_VALUE career ceiling. Like that table,
-- it pays nothing to UNITCOMBAT_RECON units.
-- Distinct from _Policy_DomainFreeExperiences, which is XP granted once when a unit is TRAINED.
CREATE TABLE IF NOT EXISTS _Policy_CityDomainExperiencePerTurn (
	PolicyType		TEXT REFERENCES Policies(Type),
	DomainType		TEXT REFERENCES Domains(Type),
	iExperience		INTEGER DEFAULT 0,
	PRIMARY KEY (PolicyType, DomainType)
);

-- Per-policy city yield from unimproved feature tiles adjacent to the city (+1 per tile at Yield 1, doubled at 2 or more)
CREATE TABLE IF NOT EXISTS _Policy_CityYieldFromAdjacentUnimprovedFeature (
	PolicyType		TEXT REFERENCES Policies(Type),
	FeatureType	TEXT REFERENCES Features(Type),
	YieldType		TEXT REFERENCES Yields(Type),
	Yield			INTEGER DEFAULT 0,
	PRIMARY KEY (PolicyType, FeatureType, YieldType)
);

-- Free experience per unit Domain for every unit the policy holder trains, in any city (Japan Grand Temple,
-- Vietnam Heroic Epic through _Building_GrantedPolicy). Summed on demand over active policies.
CREATE TABLE IF NOT EXISTS _Policy_DomainFreeExperiences (
	PolicyType		TEXT NOT NULL REFERENCES Policies(Type),
	DomainType		TEXT NOT NULL REFERENCES Domains(Type),
	iExperience		INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY (PolicyType, DomainType)
);

-- Per-policy faith-purchase grants: which UnitClasses can be faith-purchased after this policy is adopted.
-- Prepopulated below with the 8 vanilla finisher -> unitclass mappings.
CREATE TABLE IF NOT EXISTS _Policy_FaithPurchaseUnlock (
	PolicyType		TEXT REFERENCES Policies(Type),
	UnitClassType	TEXT NOT NULL,
	PRIMARY KEY (PolicyType, UnitClassType)
);

INSERT OR IGNORE INTO _Policy_FaithPurchaseUnlock (PolicyType,                       UnitClassType) VALUES
	('POLICY_AESTHETICS_FINISHER',   'UNITCLASS_WRITER'),
	('POLICY_AESTHETICS_FINISHER',   'UNITCLASS_ARTIST'),
	('POLICY_AESTHETICS_FINISHER',   'UNITCLASS_MUSICIAN'),
	('POLICY_RATIONALISM_FINISHER',  'UNITCLASS_SCIENTIST'),
	('POLICY_COMMERCE_FINISHER',     'UNITCLASS_MERCHANT'),
	('POLICY_TRADITION_FINISHER',    'UNITCLASS_ENGINEER'),
	('POLICY_HONOR_FINISHER',        'UNITCLASS_GREAT_GENERAL'),
	('POLICY_EXPLORATION_FINISHER',  'UNITCLASS_GREAT_ADMIRAL');

-- Per-policy yield bonus on feature tiles
CREATE TABLE IF NOT EXISTS _Policy_FeatureYieldChanges (
	PolicyType		TEXT REFERENCES Policies(Type),
	FeatureType	TEXT REFERENCES Features(Type),
	YieldType		TEXT REFERENCES Yields(Type),
	Yield			INTEGER DEFAULT 0,
	PRIMARY KEY (PolicyType, FeatureType, YieldType)
);

-- Free building granted by a policy: BuildingClassType is free in iCount cities of the holder, the Capital first.
CREATE TABLE IF NOT EXISTS _Policy_FreeBuildingInXCities (
	PolicyType			TEXT REFERENCES Policies(Type),
	BuildingClassType	TEXT REFERENCES BuildingClasses(Type),
	iCount				INTEGER DEFAULT 0,
	PRIMARY KEY (PolicyType, BuildingClassType)
);

-- Fresh-water cities add iMod% of their POSITIVE Food surplus, capped at iCap whole Food/turn (0 = uncapped).
-- Vanilla Policies.CityGrowthMod is the ungated, uncapped twin; the two stack. A starving city is never affected.
-- Own table rather than two _Policies_Extensions columns: a cap is meaningless without the mod it caps.
CREATE TABLE IF NOT EXISTS _Policy_FreshWaterCityGrowth (
	PolicyType	TEXT PRIMARY KEY REFERENCES Policies(Type),
	iMod		INTEGER DEFAULT 0,
	iCap		INTEGER DEFAULT 0
);

-- Per-policy, per-UnitClass Great Person rate modifier during Golden Ages
CREATE TABLE IF NOT EXISTS _Policy_GoldenAgeGreatPersonRateModifier (
	PolicyType			TEXT REFERENCES Policies(Type),
	UnitClassType		TEXT REFERENCES UnitClasses(Type),
	iModifier			INTEGER,
	PRIMARY KEY (PolicyType, UnitClassType)
);

-- Per-policy, per-UnitClass yield granted when a Great Person of that type is expended
-- Use this when a policy grants DIFFERENT yield bonuses per Great Person type
-- (e.g. Patronage gives +50 influence per Great Diplomat, +20 per Merchant).
-- For "all Great People uniformly" policy bonuses, use vanilla Policy_UnitCombatProductionModifiers
-- (or similar) with UnitCombatType = UNITCOMBAT_GREAT_PERSON.
CREATE TABLE IF NOT EXISTS _Policy_GreatPersonExpendedYield (
	PolicyType			TEXT REFERENCES Policies(Type),
	UnitClassType		TEXT REFERENCES UnitClasses(Type),
	YieldType			TEXT REFERENCES Yields(Type),
	Yield				INTEGER,
	PRIMARY KEY (PolicyType, UnitClassType, YieldType)
);

-- Expending a Great Person spreads the holder's religion (the one it founded, else the one in most of its cities) to every
-- city within iRange plots of the unit, any owner: iMissionaryPercent of one Missionary spread each.
CREATE TABLE IF NOT EXISTS _Policy_GreatPersonExpendPressure (
	PolicyType			TEXT PRIMARY KEY REFERENCES Policies(Type),
	iMissionaryPercent	INTEGER DEFAULT 0,
	iRange				INTEGER DEFAULT 0
);

-- Per-policy yield change on every Great Work of a given class
-- Applies to each Great Work of
-- that class in the player's cities; also shown in the Great Work tooltip.
CREATE TABLE IF NOT EXISTS _Policy_GreatWorkClassYieldChanges (
	PolicyType			TEXT REFERENCES Policies(Type),
	GreatWorkClassType	TEXT REFERENCES GreatWorkClasses(Type),
	YieldType			TEXT REFERENCES Yields(Type),
	Yield				INTEGER DEFAULT 0,
	PRIMARY KEY (PolicyType, GreatWorkClassType, YieldType)
);

-- Yield bonus for hills plots worked by cities of a player adopting this Policy
CREATE TABLE IF NOT EXISTS _Policy_HillsPlotYieldChanges (
	PolicyType		TEXT REFERENCES Policies(Type),
	YieldType		TEXT REFERENCES Yields(Type),
	Yield			INTEGER DEFAULT 0,
	PRIMARY KEY (PolicyType, YieldType)
);

-- % Gold purchase cost modifier for the holder's land combat units in a city, for every building of BuildingClassType that city
-- owns (negative = cheaper). Summed over the listed classes the city owns.
CREATE TABLE IF NOT EXISTS _Policy_LandUnitPurchaseCostPerBuilding (
	PolicyType			TEXT REFERENCES Policies(Type),
	BuildingClassType	TEXT REFERENCES BuildingClasses(Type),
	iMod				INTEGER DEFAULT 0,
	PRIMARY KEY (PolicyType, BuildingClassType)
);

-- Yield bonus for mountain plots worked by cities of a player adopting this Policy
CREATE TABLE IF NOT EXISTS _Policy_MountainPlotYieldChanges (
	PolicyType		TEXT REFERENCES Policies(Type),
	YieldType		TEXT REFERENCES Yields(Type),
	Yield			INTEGER DEFAULT 0,
	PRIMARY KEY (PolicyType, YieldType)
);

-- Yield % in every city of the holder while its team is at war with no major civilization (wars with City-States do not count).
CREATE TABLE IF NOT EXISTS _Policy_PeaceYieldModifiers (
	PolicyType		TEXT REFERENCES Policies(Type),
	YieldType		TEXT REFERENCES Yields(Type),
	Yield			INTEGER DEFAULT 0,
	PRIMARY KEY (PolicyType, YieldType)
);

-- Per-policy bonus to cities in which at least iMinReligions religions are PRESENT (any follower count),
-- as opposed to the majority-religion tests the rest of the religion API uses. Pantheons do not count.
-- One coupled effect, so the threshold and both payloads share a row (Sikh Empire trait-policy).
CREATE TABLE IF NOT EXISTS _Policy_ReligionsPresentThreshold (
	PolicyType		TEXT PRIMARY KEY REFERENCES Policies(Type),
	iMinReligions	INTEGER DEFAULT 0,
	-- Religions with followers needed to qualify. 0 disables the row.
	iHappiness		INTEGER DEFAULT 0,
	-- Flat local Happiness granted to each qualifying city.
	iGrowthMod		INTEGER DEFAULT 0
	-- % food-surplus modifier in each qualifying city.
);

-- Per-policy yield scaled by the number of DIFFERENT improved Resource types a city works.
-- Grants Yield per iPerNumResourceTypes distinct worked improved Resources, capped at iMaxYield.
-- bRequiresCapitalConnection gates the city bonus on a route connection to the Capital;
-- bAppliesToInternalTrade instead applies the bonus to internal trade routes involving the Capital,
-- scaled by the ORIGIN city's count. (Hebrews trait-policy 'Seven Species'.)
CREATE TABLE IF NOT EXISTS _Policy_ResourceDiversityYields (
	PolicyType					TEXT REFERENCES Policies(Type),
	YieldType					TEXT REFERENCES Yields(Type),
	iPerNumResourceTypes		INTEGER DEFAULT 2,
	iMaxYield					INTEGER DEFAULT 4,
	bRequiresCapitalConnection	INTEGER DEFAULT 1,
	bAppliesToInternalTrade		INTEGER DEFAULT 0,
	PRIMARY KEY (PolicyType, YieldType, bAppliesToInternalTrade)
);

-- Per-policy yield bonus on resource tiles
CREATE TABLE IF NOT EXISTS _Policy_ResourceYieldChanges (
	PolicyType		TEXT REFERENCES Policies(Type),
	ResourceType	TEXT REFERENCES Resources(Type),
	YieldType		TEXT REFERENCES Yields(Type),
	Yield			INTEGER DEFAULT 0,
	PRIMARY KEY (PolicyType, ResourceType, YieldType)
);

-- Per-policy yield bonus per specialist
CREATE TABLE IF NOT EXISTS _Policy_SpecialistYieldChanges (
	PolicyType		TEXT REFERENCES Policies(Type),
	SpecialistType	TEXT REFERENCES Specialists(Type),
	YieldType		TEXT REFERENCES Yields(Type),
	Yield			INTEGER,
	PRIMARY KEY (PolicyType, SpecialistType, YieldType)
);

-- Per-policy yield bonus per specialist, PER owned trade route connected to that specialist's city
-- (either endpoint). The row holds the per-route rate.
CREATE TABLE IF NOT EXISTS _Policy_SpecialistYieldChangesPerTradeRoute (
	PolicyType		TEXT REFERENCES Policies(Type),
	SpecialistType	TEXT REFERENCES Specialists(Type),
	YieldType		TEXT REFERENCES Yields(Type),
	Yield			INTEGER,
	PRIMARY KEY (PolicyType, SpecialistType, YieldType)
);

-- Yield on plots of TerrainType the holder owns (Coast includes lakes), from EraType on when set (NULL = always).
CREATE TABLE IF NOT EXISTS _Policy_TerrainYieldChanges (
	PolicyType		TEXT REFERENCES Policies(Type),
	TerrainType		TEXT REFERENCES Terrains(Type),
	YieldType		TEXT REFERENCES Yields(Type),
	Yield			INTEGER DEFAULT 0,
	EraType			TEXT DEFAULT NULL REFERENCES Eras(Type),
	PRIMARY KEY (PolicyType, TerrainType, YieldType, EraType)
);

-- Every city of the holder generates Tourism equal to iPercent of its Faith (before % modifiers), once the holder's team has
-- TechType (NULL = always).
CREATE TABLE IF NOT EXISTS _Policy_TourismFromFaith (
	PolicyType		TEXT PRIMARY KEY REFERENCES Policies(Type),
	iPercent		INTEGER DEFAULT 0,
	TechType		TEXT DEFAULT NULL REFERENCES Technologies(Type)
);

-- Scaled yield on the holder's international trade routes, paid to the origin owner: Yield for every iPer of what sScaling
-- counts, capped at iMax (0 = no cap). Gold, Production, Culture, Faith, Science and Tourism; never Food.
-- sScaling: DESTINATION_LUXURY (different Luxuries connected to the destination city), ORIGIN_LUXURY (the same at the
-- origin city), OWN_ROUTES_TO_DESTINATION (the holder's other routes ending in the same city), ROUTE_TILES (route length),
-- ORIGIN_FOLLOWERS (followers of the holder's religion in the origin city), TO_CITY_STATE (flat, routes to a City-State),
-- FIRST_ROUTE_TO_EACH_CIV (flat, on a city's first route to each different foreign major civilization).
CREATE TABLE IF NOT EXISTS _Policy_TradeRouteScaledYield (
	PolicyType		TEXT REFERENCES Policies(Type),
	YieldType		TEXT REFERENCES Yields(Type),
	sScaling		TEXT NOT NULL,
	Yield			INTEGER DEFAULT 0,
	iPer			INTEGER DEFAULT 1,
	iMax			INTEGER DEFAULT 0,
	PRIMARY KEY (PolicyType, YieldType, sScaling)
);

-- Per-policy flat yield on each trade route the holder sends, by domain
CREATE TABLE IF NOT EXISTS _Policy_TradeRouteYieldByDomain (
	PolicyType		TEXT REFERENCES Policies(Type),
	DomainType		TEXT REFERENCES Domains(Type),
	YieldType		TEXT REFERENCES Yields(Type),
	Yield			INTEGER DEFAULT 0,
	PRIMARY KEY (PolicyType, DomainType, YieldType)
);

-- % production-COST modifier for units of a combat class
CREATE TABLE IF NOT EXISTS _Policy_UnitCombatProductionCostMod (
	PolicyType		TEXT REFERENCES Policies(Type),
	UnitCombatType	TEXT REFERENCES UnitCombatInfos(Type),
	iCostMod		INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY (PolicyType, UnitCombatType)
);

-- Yield % in every city of the holder for every Great Person it has earned (all types, free ones included), capped at iMaxMod.
CREATE TABLE IF NOT EXISTS _Policy_YieldModPerGreatPerson (
	PolicyType		TEXT REFERENCES Policies(Type),
	YieldType		TEXT REFERENCES Yields(Type),
	iModPerGP		INTEGER DEFAULT 0,
	iMaxMod			INTEGER DEFAULT 0,
	PRIMARY KEY (PolicyType, YieldType)
);

-- Per-policy yield in every city connected to the Capital
CREATE TABLE IF NOT EXISTS _Policy_CapitalConnectionYield (
	PolicyType		TEXT REFERENCES Policies(Type),
	YieldType		TEXT REFERENCES Yields(Type),
	Yield			INTEGER DEFAULT 0,
	PRIMARY KEY (PolicyType, YieldType)
);

-- Per-policy yield granted when the holder clears a Barbarian Camp. Unlike the kill tables this is a FLAT amount,
-- not a share of combat strength. With bScalesWithEra the amount is multiplied by (current era + 1).
-- Food and Production land in the nearest owned city; Gold, Culture, Faith and Science land on the player.
-- Additive on top of the per-difficulty _HandicapInfos_Extensions camp yields.
CREATE TABLE IF NOT EXISTS _Policy_YieldFromBarbarianCampCleared (
	PolicyType		TEXT REFERENCES Policies(Type),
	YieldType		TEXT REFERENCES Yields(Type),
	Yield			INTEGER DEFAULT 0,
	bScalesWithEra	INTEGER DEFAULT 0,
	PRIMARY KEY (PolicyType, YieldType)
);

-- Instant yield granted each time a city grows through its food box (NOT on conquest, annexation or a Settler's
-- pop cost). The grown city gets Yield + iYieldPerPop per point of its NEW Population, scaled by game speed.
-- Food and Production land in the grown city; Gold, Culture, Faith and Science land on the player.
CREATE TABLE IF NOT EXISTS _Policy_YieldFromCityGrowth (
	PolicyType		TEXT REFERENCES Policies(Type),
	YieldType		TEXT REFERENCES Yields(Type),
	Yield			INTEGER DEFAULT 0,
	iYieldPerPop	INTEGER DEFAULT 0,
	PRIMARY KEY (PolicyType, YieldType)
);

-- Per-policy yield from any unit kill.
-- Yield is percentage of combat strength of the killed unit.
CREATE TABLE IF NOT EXISTS _Policy_YieldFromKills (
	PolicyType		TEXT REFERENCES Policies(Type),
	YieldType		TEXT REFERENCES Yields(Type),
	Yield			INTEGER,
	PRIMARY KEY (PolicyType, YieldType)
);

-- Player-wide belief effects ride a policy granted to the religion's creator; every
-- table below is summed over the holder's active policies. Instant yield to the builder when an improvement is completed.
CREATE TABLE IF NOT EXISTS _Policy_YieldFromImprovementBuild (
	PolicyType		TEXT REFERENCES Policies(Type),
	YieldType		TEXT REFERENCES Yields(Type),
	Yield		INTEGER DEFAULT 0,
	PRIMARY KEY (PolicyType, YieldType)
);

-- Instant yield to the conqueror when a city is captured.
CREATE TABLE IF NOT EXISTS _Policy_YieldFromCityConquest (
	PolicyType		TEXT REFERENCES Policies(Type),
	YieldType		TEXT REFERENCES Yields(Type),
	Yield		INTEGER DEFAULT 0,
	PRIMARY KEY (PolicyType, YieldType)
);

-- Instant yield to the owner when one of their units pillages.
CREATE TABLE IF NOT EXISTS _Policy_YieldFromPillage (
	PolicyType		TEXT REFERENCES Policies(Type),
	YieldType		TEXT REFERENCES Yields(Type),
	Yield		INTEGER DEFAULT 0,
	PRIMARY KEY (PolicyType, YieldType)
);

-- Instant yield when a (non-wonder) building is constructed.
CREATE TABLE IF NOT EXISTS _Policy_YieldPerBuildingConstructed (
	PolicyType		TEXT REFERENCES Policies(Type),
	YieldType		TEXT REFERENCES Yields(Type),
	Yield		INTEGER DEFAULT 0,
	PRIMARY KEY (PolicyType, YieldType)
);

-- Adds iValue% of every city's base eYieldIn to that city's eYieldOut, in all cities of the policy's owner: the
-- empire-wide twin of _Building_YieldFromYieldPercent. The source yield is not reduced.
CREATE TABLE IF NOT EXISTS _Policy_YieldFromYieldPercent (
	PolicyType		TEXT NOT NULL REFERENCES Policies(Type),
	eYieldIn		TEXT NOT NULL REFERENCES Yields(Type),
	eYieldOut		TEXT NOT NULL REFERENCES Yields(Type),
	iValue			INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY (PolicyType, eYieldIn, eYieldOut)
);

-- Instant yield when the holder adopts a policy, x min(followers of the holder's religion, iMaxFollowers);
-- iMaxFollowers 0 = GD_BELIEFS_MAX_FOLLOWER_SCALING (same on every yield row of a policy).
CREATE TABLE IF NOT EXISTS _Policy_YieldOnPolicyUnlockPerFollower (
	PolicyType		TEXT REFERENCES Policies(Type),
	YieldType		TEXT REFERENCES Yields(Type),
	Yield		INTEGER DEFAULT 0,
	iMaxFollowers	INTEGER DEFAULT 0,
	PRIMARY KEY (PolicyType, YieldType)
);

-- Instant yield when the holder completes a World Wonder, x min(cities following the holder's religion, iMaxCities);
-- iMaxCities 0 = GD_BELIEFS_MAX_CITY_SCALING (same on every yield row of a policy).
CREATE TABLE IF NOT EXISTS _Policy_YieldOnWonderConstructionPerCity (
	PolicyType		TEXT REFERENCES Policies(Type),
	YieldType		TEXT REFERENCES Yields(Type),
	Yield		INTEGER DEFAULT 0,
	iMaxCities	INTEGER DEFAULT 0,
	PRIMARY KEY (PolicyType, YieldType)
);

-- Per-turn yield per city following the holder's religion.
CREATE TABLE IF NOT EXISTS _Policy_YieldPerFollowingCity (
	PolicyType		TEXT REFERENCES Policies(Type),
	YieldType		TEXT REFERENCES Yields(Type),
	Yield		INTEGER DEFAULT 0,
	PRIMARY KEY (PolicyType, YieldType)
);

-- Per-turn yield per iPerXFollowers followers of the holder's religion.
CREATE TABLE IF NOT EXISTS _Policy_YieldPerXFollowers (
	PolicyType		TEXT REFERENCES Policies(Type),
	YieldType		TEXT REFERENCES Yields(Type),
	iPerXFollowers		INTEGER DEFAULT 0,
	PRIMARY KEY (PolicyType, YieldType)
);

-- Per-turn yield per iPerXFollowers followers of the holder's religion living in city-states.
CREATE TABLE IF NOT EXISTS _Policy_YieldPerXCityStateFollowers (
	PolicyType		TEXT REFERENCES Policies(Type),
	YieldType		TEXT REFERENCES Yields(Type),
	iPerXFollowers		INTEGER DEFAULT 0,
	PRIMARY KEY (PolicyType, YieldType)
);

-- At the start of the holder's turn, every combat unit at war with the holder standing on a plot the holder owns that carries
-- FeatureType is rolled once: with iChance (%) it takes iDamage hit points (never lethal). With a PromotionType the first hit
-- also gives it (make it timed so it lifts again) and a unit already carrying it keeps taking the damage; without one the
-- damage comes alone, like a Citadel's.
CREATE TABLE IF NOT EXISTS _Policy_FeatureHazards (
	PolicyType		TEXT NOT NULL REFERENCES Policies(Type),
	FeatureType		TEXT NOT NULL REFERENCES Features(Type),
	PromotionType	TEXT REFERENCES UnitPromotions(Type),
	iChance			INTEGER NOT NULL DEFAULT 0,
	iDamage			INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY (PolicyType, FeatureType)
);

-- Worked strategic-resource tile yield that switches on once the holder's TEAM has TechType.
CREATE TABLE IF NOT EXISTS _Policy_YieldChangesStrategicResourcesTech (
	PolicyType		TEXT REFERENCES Policies(Type),
	TechType		TEXT REFERENCES Technologies(Type),
	YieldType		TEXT REFERENCES Yields(Type),
	Yield			INTEGER DEFAULT 0,
	PRIMARY KEY (PolicyType, TechType, YieldType)
);

-- Capital gains iYield100 (per 100) per population of a razed conquered city, e.g. 25 = 0.25 per pop.
CREATE TABLE IF NOT EXISTS _Policy_CapitalYieldChangesPerPopRazed (
	PolicyType		TEXT REFERENCES Policies(Type),
	YieldType		TEXT REFERENCES Yields(Type),
	iYield100		INTEGER DEFAULT 0,
	PRIMARY KEY (PolicyType, YieldType)
);

-- Policy branches that also need a number of technologies of their EraPrereq era before they can be unlocked (0 = the era alone)
CREATE TABLE IF NOT EXISTS _PolicyBranchTypes_EraPrereqTechCount (
	PolicyBranchType	TEXT PRIMARY KEY REFERENCES PolicyBranchTypes(Type),
	iTechCount			INTEGER DEFAULT 0
);

--====================================================================================================================
UPDATE Sapiens_DBUpdates SET Value = 1 WHERE Name = 'DB_Policies';
