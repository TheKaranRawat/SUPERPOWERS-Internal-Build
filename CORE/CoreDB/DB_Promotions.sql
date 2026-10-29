-- written by GAIA using Notepad++
CREATE TABLE IF NOT EXISTS Sapiens_DBUpdates (Name TEXT PRIMARY KEY, Value INTEGER DEFAULT 0);
INSERT OR IGNORE INTO Sapiens_DBUpdates (Name) VALUES ('DB_Promotions');
--====================================================================================================================
-- PROMOTION TABLE EXTENSIONS
--====================================================================================================================

------------------------------------------------------------------------------------------------------------------------
-- UNIT PROMOTIONS
------------------------------------------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS _UnitPromotions_Extensions (
	PromotionType							TEXT PRIMARY KEY REFERENCES UnitPromotions(Type),

	bAngerFreeIntrusion				INTEGER DEFAULT 0,
	-- Promotion grants anger-free intrusion of city-state territory

	bBarbarianOnly						INTEGER DEFAULT 0,
	-- Promotion may only be acquired/held by Barbarian-owned units

	bCanCrossIce							INTEGER DEFAULT 0,
	-- Unit can cross ice tiles

	bCanCrossMountains						INTEGER DEFAULT 0,
	-- Unit can enter mountain tiles

	bCanCrossOceans							INTEGER DEFAULT 0,
	-- Naval unit can cross deep ocean tiles before Astronomy

	bCanFoundCityState						INTEGER DEFAULT 0,
	-- MISSION_GAIA_FOUNDCS: unit can found a City-State (e.g. PROMOTION_GAIA_FOUND_CITYSTATE on the Great Emissary).

	bCanFoundPuppet							INTEGER DEFAULT 0,
	-- Unit founds its city as a Puppet

	bCanPlunderWithoutWar				INTEGER DEFAULT 0,

	bCanTeleportCapital						INTEGER DEFAULT 0,
	-- MISSION_GAIA_TELEPORT_CAPITAL: unit may teleport to its owner's capital from neutral territory (e.g. PROMOTION_GAIA_TELEPORT_CAPITAL on scouts).

	bCoastalRaid							INTEGER DEFAULT 0,
	-- MISSION_GAIA_COASTAL_RAID: while embarked, the unit may pillage an adjacent enemy land improvement without disembarking.

	bFightWellDamaged						INTEGER DEFAULT 0,
	-- Unit ignores the wounded combat penalty -- fights at full strength when damaged (Vietnam 'Du Kich',
	-- Shoshone Great Spirit Lodge; promotion twin of the Japan FightWellDamaged trait).

	bFoundAbroad						INTEGER DEFAULT 0,

	bGGFromBarbarians						INTEGER DEFAULT 0,
	-- Unit earns Great General points from killing Barbarians

	bGainsXPFromScouting				INTEGER DEFAULT 0,
	-- Promotion grants XP from revealing tiles (scouting)

	bIgnoreFeatureDamage					INTEGER DEFAULT 0,
	-- Unit is immune to per-turn damage from features

	bIgnoreTerrainDamage					INTEGER DEFAULT 0,
	-- Unit is immune to per-turn damage from terrains

	bMountainsDoubleMove				INTEGER DEFAULT 0,

	bNearbyFriendlyAffectsSelf			INTEGER DEFAULT 0,
	-- The unit granting the iNearbyFriendlyCombatBonus aura also receives it.

	bNoAttackInOcean					INTEGER DEFAULT 0,
	-- Unit cannot attack into deep-ocean tiles (e.g. PROMOTION_HOVERING_UNIT)

	bSpoils									INTEGER DEFAULT 0,
	-- Spoils: Gold this unit rolls by pillaging a FOREIGN improvement is also banked on the unit and
	-- paid out as Production to the nearest owned city and Culture to the owner (GD_SPOILS_PRODUCTION_PERCENT /
	-- GD_SPOILS_CULTURE_PERCENT) the moment the unit steps onto a plot its owner owns. Lost with the unit.

	bTakesExtraFeatureDamage						INTEGER DEFAULT 0,
	-- Unit takes EXTRA per-turn damage from flagged features

	bTakesExtraTerrainDamage						INTEGER DEFAULT 0,
	-- Unit takes EXTRA per-turn damage from flagged terrains

	eCombatBonusImprovement					TEXT DEFAULT NULL,
	-- Improvement type whose adjacency grants iNearbyImprovementCombatBonus (NULL = no adjacency bonus)

	ePursuitSpentPromotion				TEXT DEFAULT NULL,
	-- Marker promotion applied when iMovesRestoredOnKill fires, which is what makes the refund once-per-turn.

	iAdjacentEnemySlow					INTEGER DEFAULT 0,
	-- Movement points sapped from enemy units that begin adjacent to a unit holding this promotion (e.g. PROMOTION_MINELAYER = 120)

	iAttackFullyHealedMod				INTEGER DEFAULT 0,

	iBarbarianCombatBonus				INTEGER DEFAULT 0,
	-- Combat-strength bonus (%) vs Barbarian units (e.g. PROMOTION_BARBARIAN_BONUS = 33)

	iCommanderExtraBonus						INTEGER DEFAULT 0,
	-- Per-promotion bonus to commander aura combat-strength effect

	iDamageReductionCityAssault			INTEGER DEFAULT 0,
	-- Reduces damage this unit takes when a city attacks it (e.g. PROMOTION_VANGUARD = 50)

	iExtraCombatDamage					INTEGER DEFAULT 0,
	-- Flat change to the damage this unit TAKES in melee, unit ranged, city and air strikes (e.g. PROMOTION_DAUNTLESS = -5)

	iGoodyHutYieldBonus					INTEGER DEFAULT 0,

	iMaxHitPointsChange						INTEGER DEFAULT 0,
	-- Flat change to unit's max HP

	iMaxHitPointsModifier					INTEGER DEFAULT 0,
	-- Percentage modifier to unit's max HP

	iMovesRestoredOnKill				INTEGER DEFAULT 0,
	-- Movement points refunded when this unit destroys an enemy MILITARY unit in melee, at most once per turn
	-- Never fires on civilians, city capture, or ranged, air and splash kills.

	iNearbyEnemyDamage					INTEGER DEFAULT 0,

	iNearbyFriendlyBonusRange			INTEGER DEFAULT 0,
	-- Tile radius of the iNearbyFriendlyCombatBonus aura. 1 = adjacent only.

	iNearbyFriendlyCombatBonus			INTEGER DEFAULT 0,
	-- Combat Strength percentage this unit grants to the SAME PLAYER's units of its OWN domain within
	-- iNearbyFriendlyBonusRange. The recipient takes the single strongest
	-- qualifying aura in range -- auras never sum, so two sources of +10% are still +10%.

	iNearbyImprovementBonusRange			INTEGER DEFAULT 0,
	-- Tile radius for the eCombatBonusImprovement check. 0 = the unit's OWN TILE ONLY (the search loops
	-- -range..range, so a range of 0 visits only plot 0,0). Use 1 for "on or next to".

	iNearbyImprovementCombatBonus			INTEGER DEFAULT 0,
	-- Combat strength bonus (%) near an instance of eCombatBonusImprovement, or of any improvement listed
	-- in _UnitPromotions_CombatBonusImprovementOrs. There is no ownership check: a rival's copy of the
	-- improvement grants the bonus too. Does not stack with the Traits twin -- the larger of the two wins.

	-- Promotion-granted Gaia great-person mission abilities.
	-- A unit holding a promotion with these set can perform the matching mission (stacks with any UnitInfo column).

	iNumFreeLux								INTEGER DEFAULT 0,
	-- MISSION_GAIA_FREELUX ("Grand Voyage"): free luxury resources granted to the empire (e.g. PROMOTION_GRAND_VOYAGE = 2).

	iNumFreePolicies						INTEGER DEFAULT 0,
	-- MISSION_GAIA_FREEPOLICY: free social policies granted (e.g. PROMOTION_GAIA_FREE_POLICY on the Great Thinker = 1).

	iNumFreeTradeRoutes						INTEGER DEFAULT 0,
	-- MISSION_GAIA_EXTRA_TRADEROUTE ("Trade Voyage"): permanent extra trade-route slots granted (e.g. PROMOTION_TRADE_VOYAGE = 1).

	iOpenFromMod						INTEGER DEFAULT 0,

	iPromotionDuration					INTEGER DEFAULT 0,
	-- Timed-promotion duration in turns (0 = permanent).

	iAirReconChange							INTEGER DEFAULT 0,
	-- Modifier to recon (visibility) range

	iRoughFromMod						INTEGER DEFAULT 0,

	iSplashDamageOnMove					INTEGER DEFAULT 0,
	-- Damage dealt to each adjacent enemy combat unit outside cities and forts whenever this unit enters a tile (e.g. PROMOTION_CELTS_HORSEMAN = 5)

	iSplashDamageOnPillage				INTEGER DEFAULT 0,
	-- Damage dealt to each adjacent enemy combat unit outside cities and forts when this unit pillages an improvement other than a road (e.g. PROMOTION_ARABIA_LONGSWORDSMAN = 15)

	iTradeRouteProtectionRange				INTEGER DEFAULT 0,
	-- Tile radius around this unit in which its owner's trade units cannot be plundered (e.g. PROMOTION_VENICE_CARAVEL = 2). 0 = none

	iWorkRateMod							INTEGER DEFAULT 0
	-- % modifier to the unit's work rate (Worker build speed / Great Person tile-improvement rate) while it holds this promotion. 0 = none
);

-- Multi-row companion to _UnitPromotions_Extensions.eCombatBonusImprovement, which holds only ONE
-- improvement type. The promotion's iNearbyImprovementCombatBonus applies near eCombatBonusImprovement
-- OR near any improvement listed here, which lets a single promotion cover a whole upgrade family
-- (e.g. Kontor -> Caravan Village -> Sogdian Quarter) instead of silently dropping when a tile upgrades.
-- Magnitude and radius stay on the Extensions columns; this table only widens WHICH improvements match.
CREATE TABLE IF NOT EXISTS _UnitPromotions_CombatBonusImprovementOrs (
	PromotionType						TEXT REFERENCES UnitPromotions(Type),
	ImprovementType						TEXT REFERENCES Improvements(Type),
	PRIMARY KEY (PromotionType, ImprovementType)
);

-- Unit classes a promotion's friendly combat aura is limited to. No rows = every class.
CREATE TABLE IF NOT EXISTS _UnitPromotions_NearbyFriendlyUnitCombats (
	PromotionType						TEXT REFERENCES UnitPromotions(Type),
	UnitCombatType						TEXT REFERENCES UnitCombatInfos(Type),
	PRIMARY KEY (PromotionType, UnitCombatType)
);

-- On-hit promotion-transfer (debuff). An attacker, or a non-ranged defender in melee, whose promotion has a row here
-- rolls iDebuffChance% to apply eDebuffPromotion to its opponent.
CREATE TABLE IF NOT EXISTS _UnitPromotions_Debuffs (
	PromotionType						TEXT PRIMARY KEY REFERENCES UnitPromotions(Type),
	eDebuffPromotion					TEXT DEFAULT NULL,
	iDebuffChance						INTEGER DEFAULT 0
);

-- Debuff immunity. A unit holding PromotionType is immune to eDebuffPromotion.
-- e.g. (PROMOTION_STUN_IMMUNITY, PROMOTION_STUNNED). One debuff per immunity
-- promotion (PromotionType is the key)
CREATE TABLE IF NOT EXISTS _UnitPromotions_DebuffImmunity (
	PromotionType						TEXT PRIMARY KEY REFERENCES UnitPromotions(Type),
	eDebuffPromotion					TEXT DEFAULT NULL
);

CREATE TABLE IF NOT EXISTS _UnitPromotions_PromotionRanks (
	PromotionType			TEXT PRIMARY KEY REFERENCES UnitPromotions(Type),	-- the "from" rank ;
	eNextPromotion			TEXT DEFAULT '',				-- the "to" rank reached when the trigger is met
	iTurnIntervalTrigger	INTEGER DEFAULT 0,				-- >0: advance one rung every N turns (game-speed scaled)
	iUnitLevelTrigger		INTEGER DEFAULT 0,				-- >0: advance once the unit's level >= N (absolute, NOT game-speed scaled)
	iGrantedXP100			INTEGER DEFAULT 0				-- XP (x100) granted when advancing to eNextPromotion
);

--====================================================================================================================
-- NEW PROMOTION TABLES
--====================================================================================================================

------------------------------------------------------------------------------------------------------------------------
-- YIELD JOINS
------------------------------------------------------------------------------------------------------------------------

-- Yield is percentage of combat str of killed unit
CREATE TABLE IF NOT EXISTS _UnitPromotions_YieldFromBarbarianKills (
	PromotionType	TEXT REFERENCES UnitPromotions(Type),
	YieldType		TEXT REFERENCES Yields(Type),
	Yield			INTEGER,
	PRIMARY KEY (PromotionType, YieldType)
);

-- Yield is percentage of combat str of killed unit
CREATE TABLE IF NOT EXISTS _UnitPromotions_YieldFromKills (
	PromotionType	TEXT REFERENCES UnitPromotions(Type),
	YieldType		TEXT REFERENCES Yields(Type),
	Yield			INTEGER,
	PRIMARY KEY (PromotionType, YieldType)
);

-- Yield is percentage of the Gold a pillage rolled (100 = the same amount again in this yield). Nothing is
-- granted when the pillage produced no Gold: routes, or an improvement inside the pillager's own borders.
CREATE TABLE IF NOT EXISTS _UnitPromotions_YieldFromPillageGold (
	PromotionType	TEXT REFERENCES UnitPromotions(Type),
	YieldType		TEXT REFERENCES Yields(Type),
	YieldPercent	INTEGER,
	PRIMARY KEY (PromotionType, YieldType)
);

-- Yield to a city per garrisoned unit holding this promotion
CREATE TABLE IF NOT EXISTS _UnitPromotions_GarrisonedCityYieldChanges (
	PromotionType	TEXT REFERENCES UnitPromotions(Type),
	YieldType		TEXT REFERENCES Yields(Type),
	Yield			INTEGER DEFAULT 0,
	PRIMARY KEY (PromotionType, YieldType)
);

--====================================================================================================================
UPDATE Sapiens_DBUpdates SET Value = 1 WHERE Name = 'DB_Promotions';
