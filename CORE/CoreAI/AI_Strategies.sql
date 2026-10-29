-- written by GAIA using Notepad++
CREATE TABLE IF NOT EXISTS Sapiens_DBUpdates (Name TEXT PRIMARY KEY, Value INTEGER DEFAULT 0);
INSERT OR IGNORE INTO Sapiens_DBUpdates (Name) VALUES ('AI_Strategies');
--====================================================================================================================
-- AICityStrategies (strategy timing / thresholds)
--====================================================================================================================
UPDATE AICityStrategies SET WeightThreshold = 50  WHERE Type = 'AICITYSTRATEGY_WANT_TILE_IMPROVERS';   /*40*/
UPDATE AICityStrategies SET WeightThreshold = 150 WHERE Type = 'AICITYSTRATEGY_ENOUGH_TILE_IMPROVERS'; /*125*/
UPDATE AICityStrategies SET WeightThreshold = 90 WHERE Type = 'AICITYSTRATEGY_CAPITAL_NEED_SETTLER'; /*130*/

-- LAKEBOUND / ENOUGH_SETTLERS / NEW_CONTINENT_FEEDER
INSERT INTO AICityStrategies (Type, CheckTriggerTurnCount, MinimumNumTurnsExecuted, NoMinorCivs) VALUES
('AICITYSTRATEGY_LAKEBOUND',             1,  75,  1),
('AICITYSTRATEGY_ENOUGH_SETTLERS',       5,  20,  1),
('AICITYSTRATEGY_NEW_CONTINENT_FEEDER',  50, 100, 1);

--====================================================================================================================
-- AICityStrategy_Flavors
--====================================================================================================================

-- TINY_CITY
UPDATE AICityStrategy_Flavors SET Flavor = 100  WHERE AICityStrategyType = 'AICITYSTRATEGY_TINY_CITY' AND FlavorType = 'FLAVOR_GROWTH';           /*10*/
UPDATE AICityStrategy_Flavors SET Flavor = 0    WHERE AICityStrategyType = 'AICITYSTRATEGY_TINY_CITY' AND FlavorType = 'FLAVOR_TILE_IMPROVEMENT'; /*-3*/
UPDATE AICityStrategy_Flavors SET Flavor = -200 WHERE AICityStrategyType = 'AICITYSTRATEGY_TINY_CITY' AND FlavorType = 'FLAVOR_ESPIONAGE';        /*-100*/
INSERT INTO AICityStrategy_Flavors (AICityStrategyType, FlavorType, Flavor) VALUES
('AICITYSTRATEGY_TINY_CITY', 'FLAVOR_CULTURE', 5);

-- SMALL_CITY
INSERT INTO AICityStrategy_Flavors (AICityStrategyType, FlavorType, Flavor) VALUES
('AICITYSTRATEGY_SMALL_CITY', 'FLAVOR_GROWTH', 100),
('AICITYSTRATEGY_SMALL_CITY', 'FLAVOR_OFFENSE', 3),
('AICITYSTRATEGY_SMALL_CITY', 'FLAVOR_EXPANSION', 5),
('AICITYSTRATEGY_SMALL_CITY', 'FLAVOR_TILE_IMPROVEMENT', 0);

-- MEDIUM_CITY
UPDATE AICityStrategy_Flavors SET Flavor = 5    WHERE AICityStrategyType = 'AICITYSTRATEGY_MEDIUM_CITY' AND FlavorType = 'FLAVOR_HAPPINESS';   /*10*/
UPDATE AICityStrategy_Flavors SET Flavor = 5    WHERE AICityStrategyType = 'AICITYSTRATEGY_MEDIUM_CITY' AND FlavorType = 'FLAVOR_GOLD';        /*10*/
INSERT INTO AICityStrategy_Flavors (AICityStrategyType, FlavorType, Flavor) VALUES
('AICITYSTRATEGY_MEDIUM_CITY', 'FLAVOR_OFFENSE', 5),
('AICITYSTRATEGY_MEDIUM_CITY', 'FLAVOR_CULTURE', 5);

-- LARGE_CITY
UPDATE AICityStrategy_Flavors SET Flavor = 15 WHERE AICityStrategyType = 'AICITYSTRATEGY_LARGE_CITY' AND FlavorType = 'FLAVOR_GOLD';      /*25*/
UPDATE AICityStrategy_Flavors SET Flavor = 25 WHERE AICityStrategyType = 'AICITYSTRATEGY_LARGE_CITY' AND FlavorType = 'FLAVOR_GROWTH';    /*15*/

-- LANDLOCKED
INSERT INTO AICityStrategy_Flavors (AICityStrategyType, FlavorType, Flavor) VALUES
('AICITYSTRATEGY_LANDLOCKED', 'FLAVOR_DEFENSE', 5),
('AICITYSTRATEGY_LANDLOCKED', 'FLAVOR_EXPANSION', 5);

-- TILE IMPROVERS
UPDATE AICityStrategy_Flavors SET Flavor = 200  WHERE AICityStrategyType = 'AICITYSTRATEGY_NEED_TILE_IMPROVERS'   AND FlavorType = 'FLAVOR_TILE_IMPROVEMENT'; /*150*/
UPDATE AICityStrategy_Flavors SET Flavor = 70   WHERE AICityStrategyType = 'AICITYSTRATEGY_WANT_TILE_IMPROVERS'   AND FlavorType = 'FLAVOR_TILE_IMPROVEMENT'; /*35*/

-- NAVAL GROWTH / TILE IMPROVEMENT
UPDATE AICityStrategy_Flavors SET Flavor = 200  WHERE AICityStrategyType = 'AICITYSTRATEGY_NEED_NAVAL_TILE_IMPROVEMENT'   AND FlavorType = 'FLAVOR_NAVAL_TILE_IMPROVEMENT'; /*100*/
UPDATE AICityStrategy_Flavors SET Flavor = -3   WHERE AICityStrategyType = 'AICITYSTRATEGY_NEED_NAVAL_TILE_IMPROVEMENT'   AND FlavorType = 'FLAVOR_GROWTH';                 /*-5*/
UPDATE AICityStrategy_Flavors SET Flavor = -200 WHERE AICityStrategyType = 'AICITYSTRATEGY_ENOUGH_NAVAL_TILE_IMPROVEMENT' AND FlavorType = 'FLAVOR_NAVAL_TILE_IMPROVEMENT'; /*-100*/

-- HAVE_TRAINING_FACILITY
UPDATE AICityStrategy_Flavors SET Flavor = 3  WHERE AICityStrategyType = 'AICITYSTRATEGY_HAVE_TRAINING_FACILITY' AND FlavorType = 'FLAVOR_DEFENSE';          /*6*/
UPDATE AICityStrategy_Flavors SET Flavor = -2 WHERE AICityStrategyType = 'AICITYSTRATEGY_HAVE_TRAINING_FACILITY' AND FlavorType = 'FLAVOR_TILE_IMPROVEMENT'; /*-3*/
UPDATE AICityStrategy_Flavors SET Flavor = -2 WHERE AICityStrategyType = 'AICITYSTRATEGY_HAVE_TRAINING_FACILITY' AND FlavorType = 'FLAVOR_EXPANSION';        /*-3*/
UPDATE AICityStrategy_Flavors SET Flavor = -2 WHERE AICityStrategyType = 'AICITYSTRATEGY_HAVE_TRAINING_FACILITY' AND FlavorType = 'FLAVOR_GROWTH';           /*-3*/
UPDATE AICityStrategy_Flavors SET Flavor = -2 WHERE AICityStrategyType = 'AICITYSTRATEGY_HAVE_TRAINING_FACILITY' AND FlavorType = 'FLAVOR_HAPPINESS';        /*-3*/

-- MEDIUM_CITY_HIGH_DIFFICULTY
UPDATE AICityStrategy_Flavors SET Flavor = 20 WHERE AICityStrategyType = 'AICITYSTRATEGY_MEDIUM_CITY_HIGH_DIFFICULTY' AND FlavorType = 'FLAVOR_CITY_DEFENSE';      /*35*/
UPDATE AICityStrategy_Flavors SET Flavor = 15 WHERE AICityStrategyType = 'AICITYSTRATEGY_MEDIUM_CITY_HIGH_DIFFICULTY' AND FlavorType = 'FLAVOR_EXPANSION';         /*10*/
UPDATE AICityStrategy_Flavors SET Flavor = 15 WHERE AICityStrategyType = 'AICITYSTRATEGY_MEDIUM_CITY_HIGH_DIFFICULTY' AND FlavorType = 'FLAVOR_SCIENCE';           /*10*/
UPDATE AICityStrategy_Flavors SET Flavor = 15 WHERE AICityStrategyType = 'AICITYSTRATEGY_MEDIUM_CITY_HIGH_DIFFICULTY' AND FlavorType = 'FLAVOR_CULTURE';           /*10*/
INSERT INTO AICityStrategy_Flavors (AICityStrategyType, FlavorType, Flavor) VALUES
('AICITYSTRATEGY_MEDIUM_CITY_HIGH_DIFFICULTY', 'FLAVOR_GROWTH', 15);

-- ORIGINAL_CAPITAL (on top of tiny/small/etc.)
UPDATE AICityStrategy_Flavors SET Flavor = 18 WHERE AICityStrategyType = 'AICITYSTRATEGY_ORIGINAL_CAPITAL' AND FlavorType = 'FLAVOR_CITY_DEFENSE'; /*35*/
INSERT INTO AICityStrategy_Flavors (AICityStrategyType, FlavorType, Flavor) VALUES
('AICITYSTRATEGY_ORIGINAL_CAPITAL', 'FLAVOR_GROWTH', 5),
('AICITYSTRATEGY_ORIGINAL_CAPITAL', 'FLAVOR_CULTURE', 5),
('AICITYSTRATEGY_ORIGINAL_CAPITAL', 'FLAVOR_EXPANSION', 5),
('AICITYSTRATEGY_ORIGINAL_CAPITAL', 'FLAVOR_WONDER', 5);

-- FIRST BUILDINGS / TRADE ROUTES / IMPROVEMENT PRODUCTION
UPDATE AICityStrategy_Flavors SET Flavor = 300  WHERE AICityStrategyType = 'AICITYSTRATEGY_FIRST_CULTURE_BUILDING'                 AND FlavorType = 'FLAVOR_CULTURE';             /*150*/
UPDATE AICityStrategy_Flavors SET Flavor = 200  WHERE AICityStrategyType = 'AICITYSTRATEGY_FIRST_CULTURE_BUILDING_EMERGENCY'       AND FlavorType = 'FLAVOR_CULTURE';             /*100*/
UPDATE AICityStrategy_Flavors SET Flavor = 100  WHERE AICityStrategyType = 'AICITYSTRATEGY_FIRST_FAITH_BUILDING'                   AND FlavorType = 'FLAVOR_RELIGION';            /*50*/
UPDATE AICityStrategy_Flavors SET Flavor = 120  WHERE AICityStrategyType = 'AICITYSTRATEGY_FIRST_PRODUCTION_BUILDING'              AND FlavorType = 'FLAVOR_PRODUCTION';          /*200*/

-- TERRAIN / MISC CITY STRATEGIES
UPDATE AICityStrategy_Flavors SET Flavor = 5  WHERE AICityStrategyType = 'AICITYSTRATEGY_COAST_CITY'            AND FlavorType = 'FLAVOR_GOLD';         /*10*/
UPDATE AICityStrategy_Flavors SET Flavor = 80 WHERE AICityStrategyType = 'AICITYSTRATEGY_MANY_TECHS_STOLEN'     AND FlavorType = 'FLAVOR_ESPIONAGE';    /*40*/
UPDATE AICityStrategy_Flavors SET Flavor = 40 WHERE AICityStrategyType = 'AICITYSTRATEGY_KEY_SCIENCE_CITY'      AND FlavorType = 'FLAVOR_ESPIONAGE';    /*20*/
UPDATE AICityStrategy_Flavors SET Flavor = 40 WHERE AICityStrategyType = 'AICITYSTRATEGY_GOOD_AIRLIFT_CITY'     AND FlavorType = 'FLAVOR_AIRLIFT';      /*80*/

-- LAKEBOUND / ENOUGH_SETTLERS / NEW_CONTINENT_FEEDER
INSERT INTO AICityStrategy_Flavors (AICityStrategyType, FlavorType, Flavor) VALUES
('AICITYSTRATEGY_LAKEBOUND',            'FLAVOR_NAVAL',        -500),
('AICITYSTRATEGY_LAKEBOUND',            'FLAVOR_NAVAL_RECON',  -500),
('AICITYSTRATEGY_ENOUGH_SETTLERS',      'FLAVOR_EXPANSION',    -200),
('AICITYSTRATEGY_ENOUGH_SETTLERS',      'FLAVOR_DEFENSE',        30),
('AICITYSTRATEGY_ENOUGH_SETTLERS',      'FLAVOR_OFFENSE',        30),
('AICITYSTRATEGY_NEW_CONTINENT_FEEDER', 'FLAVOR_EXPANSION',     100),
('AICITYSTRATEGY_NEW_CONTINENT_FEEDER', 'FLAVOR_DEFENSE',        50),
('AICITYSTRATEGY_NEW_CONTINENT_FEEDER', 'FLAVOR_RECON',          50),
('AICITYSTRATEGY_NEW_CONTINENT_FEEDER', 'FLAVOR_NAVAL_RECON',   100);

--====================================================================================================================
--============================================  MILITARY STRATEGY FLAVORS  =============================================
--====================================================================================================================

--====================================================================================================================
-- AIMilitaryStrategies (strategy timing / thresholds)
--====================================================================================================================
UPDATE AIMilitaryStrategies SET CheckTriggerTurnCount = 2 WHERE Type = 'MILITARYAISTRATEGY_ERADICATE_BARBARIANS'; /*5*/

--====================================================================================================================
-- PLAYER FLAVORS
--====================================================================================================================

-- EMPIRE_DEFENSE
UPDATE AIMilitaryStrategy_Player_Flavors SET Flavor = 20 WHERE AIMilitaryStrategyType = 'MILITARYAISTRATEGY_EMPIRE_DEFENSE' AND FlavorType = 'FLAVOR_DEFENSE';           /*25*/

-- EMPIRE_DEFENSE_CRITICAL
UPDATE AIMilitaryStrategy_Player_Flavors SET Flavor = 40  WHERE AIMilitaryStrategyType = 'MILITARYAISTRATEGY_EMPIRE_DEFENSE_CRITICAL' AND FlavorType = 'FLAVOR_DEFENSE';     /*60*/
INSERT INTO AIMilitaryStrategy_Player_Flavors (AIMilitaryStrategyType, FlavorType, Flavor) VALUES
('MILITARYAISTRATEGY_EMPIRE_DEFENSE_CRITICAL', 'FLAVOR_GROWTH', 0),
('MILITARYAISTRATEGY_EMPIRE_DEFENSE_CRITICAL', 'FLAVOR_SCIENCE', 0);

-- NAVAL UNITS
UPDATE AIMilitaryStrategy_Player_Flavors SET Flavor = 0   WHERE AIMilitaryStrategyType = 'MILITARYAISTRATEGY_ENOUGH_NAVAL_UNITS'        AND FlavorType = 'FLAVOR_NAVAL';       /*10*/

-- WAR_MOBILIZATION
UPDATE AIMilitaryStrategy_Player_Flavors SET Flavor = -5  WHERE AIMilitaryStrategyType = 'MILITARYAISTRATEGY_WAR_MOBILIZATION' AND FlavorType = 'FLAVOR_GROWTH';            /*-10*/
UPDATE AIMilitaryStrategy_Player_Flavors SET Flavor = -5  WHERE AIMilitaryStrategyType = 'MILITARYAISTRATEGY_WAR_MOBILIZATION' AND FlavorType = 'FLAVOR_EXPANSION';         /*-10*/

-- WINNING / LOSING WARS
UPDATE AIMilitaryStrategy_Player_Flavors SET Flavor = 20  WHERE AIMilitaryStrategyType = 'MILITARYAISTRATEGY_LOSING_WARS'  AND FlavorType = 'FLAVOR_CITY_DEFENSE'; /*25*/

INSERT INTO AIMilitaryStrategy_Player_Flavors (AIMilitaryStrategyType, FlavorType, Flavor) VALUES
('MILITARYAISTRATEGY_AT_WAR',					'FLAVOR_NUKE',	20),
('MILITARYAISTRATEGY_EMPIRE_DEFENSE',			'FLAVOR_NUKE',	15),
('MILITARYAISTRATEGY_EMPIRE_DEFENSE_CRITICAL',	'FLAVOR_NUKE',	50),
('MILITARYAISTRATEGY_WAR_MOBILIZATION',			'FLAVOR_NUKE',	10),
('MILITARYAISTRATEGY_LOSING_WARS',				'FLAVOR_NUKE',	30);

--====================================================================================================================
-- CITY FLAVORS
--====================================================================================================================

-- EMPIRE_DEFENSE
UPDATE AIMilitaryStrategy_City_Flavors SET Flavor = 20  WHERE AIMilitaryStrategyType = 'MILITARYAISTRATEGY_EMPIRE_DEFENSE' AND FlavorType = 'FLAVOR_DEFENSE';           /*25*/
UPDATE AIMilitaryStrategy_City_Flavors SET Flavor = 15  WHERE AIMilitaryStrategyType = 'MILITARYAISTRATEGY_EMPIRE_DEFENSE' AND FlavorType = 'FLAVOR_MILITARY_TRAINING'; /*10*/

-- EMPIRE_DEFENSE_CRITICAL
UPDATE AIMilitaryStrategy_City_Flavors SET Flavor = 50  WHERE AIMilitaryStrategyType = 'MILITARYAISTRATEGY_EMPIRE_DEFENSE_CRITICAL' AND FlavorType = 'FLAVOR_DEFENSE';          /*60*/

-- AT_WAR
INSERT INTO AIMilitaryStrategy_City_Flavors (AIMilitaryStrategyType, FlavorType, Flavor) VALUES
('MILITARYAISTRATEGY_AT_WAR', 'FLAVOR_GREAT_PEOPLE', 0);

-- WAR_MOBILIZATION
UPDATE AIMilitaryStrategy_City_Flavors SET Flavor = 30   WHERE AIMilitaryStrategyType = 'MILITARYAISTRATEGY_WAR_MOBILIZATION' AND FlavorType = 'FLAVOR_OFFENSE';           /*15*/
UPDATE AIMilitaryStrategy_City_Flavors SET Flavor = 30   WHERE AIMilitaryStrategyType = 'MILITARYAISTRATEGY_WAR_MOBILIZATION' AND FlavorType = 'FLAVOR_MILITARY_TRAINING'; /*25*/
UPDATE AIMilitaryStrategy_City_Flavors SET Flavor = -25  WHERE AIMilitaryStrategyType = 'MILITARYAISTRATEGY_WAR_MOBILIZATION' AND FlavorType = 'FLAVOR_GROWTH';            /*-50*/
UPDATE AIMilitaryStrategy_City_Flavors SET Flavor = -25  WHERE AIMilitaryStrategyType = 'MILITARYAISTRATEGY_WAR_MOBILIZATION' AND FlavorType = 'FLAVOR_EXPANSION';         /*-50*/
INSERT INTO AIMilitaryStrategy_City_Flavors (AIMilitaryStrategyType, FlavorType, Flavor) VALUES
('MILITARYAISTRATEGY_WAR_MOBILIZATION', 'FLAVOR_GREAT_PEOPLE', 0),
('MILITARYAISTRATEGY_WAR_MOBILIZATION', 'FLAVOR_AIR', 0);

-- WINNING / LOSING WARS
UPDATE AIMilitaryStrategy_City_Flavors SET Flavor = 10  WHERE AIMilitaryStrategyType = 'MILITARYAISTRATEGY_WINNING_WARS' AND FlavorType = 'FLAVOR_OFFENSE';          /*5*/
UPDATE AIMilitaryStrategy_City_Flavors SET Flavor = 0   WHERE AIMilitaryStrategyType = 'MILITARYAISTRATEGY_LOSING_WARS'  AND FlavorType = 'FLAVOR_OFFENSE';          /*-5*/
UPDATE AIMilitaryStrategy_City_Flavors SET Flavor = 10  WHERE AIMilitaryStrategyType = 'MILITARYAISTRATEGY_LOSING_WARS'  AND FlavorType = 'FLAVOR_DEFENSE';          /*5*/
UPDATE AIMilitaryStrategy_City_Flavors SET Flavor = 50  WHERE AIMilitaryStrategyType = 'MILITARYAISTRATEGY_LOSING_WARS'  AND FlavorType = 'FLAVOR_CITY_DEFENSE';     /*25*/

INSERT INTO AIMilitaryStrategy_City_Flavors (AIMilitaryStrategyType, FlavorType, Flavor) VALUES
('MILITARYAISTRATEGY_AT_WAR',					'FLAVOR_NUKE',	20),
('MILITARYAISTRATEGY_EMPIRE_DEFENSE',			'FLAVOR_NUKE',	15),
('MILITARYAISTRATEGY_EMPIRE_DEFENSE_CRITICAL',	'FLAVOR_NUKE',	50),
('MILITARYAISTRATEGY_WAR_MOBILIZATION',			'FLAVOR_NUKE',	10),
('MILITARYAISTRATEGY_LOSING_WARS',				'FLAVOR_NUKE',	30);

--====================================================================================================================
--============================================  ECONOMIC STRATEGY FLAVORS  =============================================
--====================================================================================================================

--====================================================================================================================
-- AIEconomicStrategies (strategy timing / thresholds)
--====================================================================================================================
UPDATE AIEconomicStrategies SET MinimumNumTurnsExecuted = 1, CheckTriggerTurnCount = 1 WHERE Type = 'ECONOMICAISTRATEGY_LOSING_MONEY'; /*5,5*/
UPDATE AIEconomicStrategies SET MinimumNumTurnsExecuted = 20, FirstTurnExecuted = 40 WHERE Type = 'ECONOMICAISTRATEGY_GS_CONQUEST'; /*25,75*/
UPDATE AIEconomicStrategies SET MinimumNumTurnsExecuted = 20, FirstTurnExecuted = 40 WHERE Type = 'ECONOMICAISTRATEGY_GS_CULTURE'; /*25,75*/
UPDATE AIEconomicStrategies SET MinimumNumTurnsExecuted = 20, FirstTurnExecuted = 40 WHERE Type = 'ECONOMICAISTRATEGY_GS_DIPLOMACY'; /*25,75*/
UPDATE AIEconomicStrategies SET MinimumNumTurnsExecuted = 20, FirstTurnExecuted = 40 WHERE Type = 'ECONOMICAISTRATEGY_GS_SPACESHIP'; /*25,75*/
UPDATE AIEconomicStrategies SET MinimumNumTurnsExecuted = 20, WeightThreshold = 4, FirstTurnExecuted = 18 WHERE Type = 'ECONOMICAISTRATEGY_EARLY_EXPANSION'; /*10,3,0*/
UPDATE AIEconomicStrategies SET WeightThreshold = 6 WHERE Type = 'ECONOMICAISTRATEGY_EXPAND_LIKE_CRAZY';   /*10*/

--====================================================================================================================
-- PLAYER FLAVORS (techs, policies)
--====================================================================================================================

-- RECON
UPDATE AIEconomicStrategy_Player_Flavors SET Flavor = 10 WHERE AIEconomicStrategyType = 'ECONOMICAISTRATEGY_NEED_RECON'            AND FlavorType = 'FLAVOR_RECON';       /*10*/
UPDATE AIEconomicStrategy_Player_Flavors SET Flavor = 25 WHERE AIEconomicStrategyType = 'ECONOMICAISTRATEGY_REALLY_NEED_RECON_SEA' AND FlavorType = 'FLAVOR_NAVAL_RECON'; /*50*/
UPDATE AIEconomicStrategy_Player_Flavors SET Flavor = 5  WHERE AIEconomicStrategyType = 'ECONOMICAISTRATEGY_REALLY_NEED_RECON_SEA' AND FlavorType = 'FLAVOR_NAVAL';       /*10*/

-- EARLY_EXPANSION
UPDATE AIEconomicStrategy_Player_Flavors SET Flavor = 20 WHERE AIEconomicStrategyType = 'ECONOMICAISTRATEGY_EARLY_EXPANSION' AND FlavorType = 'FLAVOR_EXPANSION';        /*10*/
UPDATE AIEconomicStrategy_Player_Flavors SET Flavor = 5  WHERE AIEconomicStrategyType = 'ECONOMICAISTRATEGY_EARLY_EXPANSION' AND FlavorType = 'FLAVOR_TILE_IMPROVEMENT'; /*10*/
INSERT INTO AIEconomicStrategy_Player_Flavors (AIEconomicStrategyType, FlavorType, Flavor) VALUES
('ECONOMICAISTRATEGY_EARLY_EXPANSION', 'FLAVOR_GROWTH', 10),
('ECONOMICAISTRATEGY_EARLY_EXPANSION', 'FLAVOR_DEFENSE', 10),
('ECONOMICAISTRATEGY_EARLY_EXPANSION', 'FLAVOR_NAVAL', 10),
('ECONOMICAISTRATEGY_EARLY_EXPANSION', 'FLAVOR_NAVAL_RECON', 5);

-- NEED_HAPPINESS
UPDATE AIEconomicStrategy_Player_Flavors SET Flavor = 350 WHERE AIEconomicStrategyType = 'ECONOMICAISTRATEGY_NEED_HAPPINESS_CRITICAL' AND FlavorType = 'FLAVOR_HAPPINESS'; /*250*/
UPDATE AIEconomicStrategies               SET WeightThreshold = -2 WHERE Type = 'ECONOMICAISTRATEGY_NEED_HAPPINESS_CRITICAL'; /*-3*/

-- LOSING_MONEY
INSERT INTO AIEconomicStrategy_Player_Flavors (AIEconomicStrategyType, FlavorType, Flavor) VALUES
('ECONOMICAISTRATEGY_LOSING_MONEY', 'FLAVOR_NAVAL', -10),
('ECONOMICAISTRATEGY_LOSING_MONEY', 'FLAVOR_RANGED', -10),
('ECONOMICAISTRATEGY_LOSING_MONEY', 'FLAVOR_MOBILE', -10);

-- LIKE_CRAZY
UPDATE AIEconomicStrategy_Player_Flavors SET Flavor = 20 WHERE AIEconomicStrategyType = 'ECONOMICAISTRATEGY_EXPAND_LIKE_CRAZY' AND FlavorType = 'FLAVOR_EXPANSION'; /*10*/
UPDATE AIEconomicStrategy_Player_Flavors SET Flavor = 20 WHERE AIEconomicStrategyType = 'ECONOMICAISTRATEGY_GROW_LIKE_CRAZY'   AND FlavorType = 'FLAVOR_GROWTH';    /*10*/

-- GS_CULTURE
UPDATE AIEconomicStrategy_Player_Flavors SET Flavor = 15  WHERE AIEconomicStrategyType = 'ECONOMICAISTRATEGY_GS_CULTURE' AND FlavorType = 'FLAVOR_DEFENSE';      /*20*/
UPDATE AIEconomicStrategy_Player_Flavors SET Flavor = 40  WHERE AIEconomicStrategyType = 'ECONOMICAISTRATEGY_GS_CULTURE' AND FlavorType = 'FLAVOR_WONDER';       /*35*/
INSERT INTO AIEconomicStrategy_Player_Flavors (AIEconomicStrategyType, FlavorType, Flavor) VALUES
('ECONOMICAISTRATEGY_GS_CULTURE', 'FLAVOR_SCIENCE', 8),
('ECONOMICAISTRATEGY_GS_CULTURE', 'FLAVOR_RELIGION', 0),
('ECONOMICAISTRATEGY_GS_CULTURE', 'FLAVOR_TOURISM', 50);

-- GS_CONQUEST
INSERT INTO AIEconomicStrategy_Player_Flavors (AIEconomicStrategyType, FlavorType, Flavor) VALUES
('ECONOMICAISTRATEGY_GS_CONQUEST', 'FLAVOR_GROWTH', 15),
('ECONOMICAISTRATEGY_GS_CONQUEST', 'FLAVOR_SCIENCE', 10),
('ECONOMICAISTRATEGY_GS_CONQUEST', 'FLAVOR_RANGED', 0),
('ECONOMICAISTRATEGY_GS_CONQUEST', 'FLAVOR_MOBILE', 0),
('ECONOMICAISTRATEGY_GS_CONQUEST', 'FLAVOR_GOLD', 5);

-- GS_DIPLOMACY
INSERT INTO AIEconomicStrategy_Player_Flavors (AIEconomicStrategyType, FlavorType, Flavor) VALUES
('ECONOMICAISTRATEGY_GS_DIPLOMACY', 'FLAVOR_GROWTH', 25),
('ECONOMICAISTRATEGY_GS_DIPLOMACY', 'FLAVOR_SCIENCE', 0),
('ECONOMICAISTRATEGY_GS_DIPLOMACY', 'FLAVOR_CULTURE', 0);

-- GS_SPACESHIP
UPDATE AIEconomicStrategy_Player_Flavors SET Flavor = 35 WHERE AIEconomicStrategyType = 'ECONOMICAISTRATEGY_GS_SPACESHIP' AND FlavorType = 'FLAVOR_SCIENCE';    /*20*/
UPDATE AIEconomicStrategy_Player_Flavors SET Flavor = 20 WHERE AIEconomicStrategyType = 'ECONOMICAISTRATEGY_GS_SPACESHIP' AND FlavorType = 'FLAVOR_GROWTH';     /*10*/
INSERT INTO AIEconomicStrategy_Player_Flavors (AIEconomicStrategyType, FlavorType, Flavor) VALUES
('ECONOMICAISTRATEGY_GS_SPACESHIP', 'FLAVOR_GOLD', 5);

-- GS_SPACESHIP_HOMESTRETCH
INSERT INTO AIEconomicStrategy_Player_Flavors (AIEconomicStrategyType, FlavorType, Flavor) VALUES
('ECONOMICAISTRATEGY_GS_SPACESHIP_HOMESTRETCH', 'FLAVOR_GOLD', 10),
('ECONOMICAISTRATEGY_GS_SPACESHIP_HOMESTRETCH', 'FLAVOR_PRODUCTION', 15);

-- MAP / RELIGION / TECH LEADER
UPDATE AIEconomicStrategy_Player_Flavors SET Flavor = 30 WHERE AIEconomicStrategyType = 'ECONOMICAISTRATEGY_STARTED_PIETY'          AND FlavorType = 'FLAVOR_RELIGION';         /*20*/

--====================================================================================================================
-- CITY FLAVORS (production)
--====================================================================================================================

-- EARLY_EXPANSION
UPDATE AIEconomicStrategy_City_Flavors SET Flavor = 10 WHERE AIEconomicStrategyType = 'ECONOMICAISTRATEGY_EARLY_EXPANSION' AND FlavorType = 'FLAVOR_TILE_IMPROVEMENT'; /*5*/
UPDATE AIEconomicStrategy_City_Flavors SET Flavor = -2 WHERE AIEconomicStrategyType = 'ECONOMICAISTRATEGY_EARLY_EXPANSION' AND FlavorType = 'FLAVOR_CULTURE';          /*-4*/
INSERT INTO AIEconomicStrategy_City_Flavors (AIEconomicStrategyType, FlavorType, Flavor) VALUES
('ECONOMICAISTRATEGY_EARLY_EXPANSION', 'FLAVOR_GROWTH', 0),
('ECONOMICAISTRATEGY_EARLY_EXPANSION', 'FLAVOR_DEFENSE', 10);

-- NEED_HAPPINESS
UPDATE AIEconomicStrategy_City_Flavors SET Flavor = 70   WHERE AIEconomicStrategyType = 'ECONOMICAISTRATEGY_NEED_HAPPINESS'          AND FlavorType = 'FLAVOR_HAPPINESS'; /*35*/
UPDATE AIEconomicStrategy_City_Flavors SET Flavor = -10  WHERE AIEconomicStrategyType = 'ECONOMICAISTRATEGY_NEED_HAPPINESS'          AND FlavorType = 'FLAVOR_GROWTH';    /*-5*/
UPDATE AIEconomicStrategy_City_Flavors SET Flavor = 350  WHERE AIEconomicStrategyType = 'ECONOMICAISTRATEGY_NEED_HAPPINESS_CRITICAL' AND FlavorType = 'FLAVOR_HAPPINESS'; /*250*/
UPDATE AIEconomicStrategy_City_Flavors SET Flavor = -150 WHERE AIEconomicStrategyType = 'ECONOMICAISTRATEGY_NEED_HAPPINESS_CRITICAL' AND FlavorType = 'FLAVOR_GROWTH';    /*-100*/

-- LOSING_MONEY
UPDATE AIEconomicStrategy_City_Flavors SET Flavor = 15  WHERE AIEconomicStrategyType = 'ECONOMICAISTRATEGY_LOSING_MONEY' AND FlavorType = 'FLAVOR_GOLD';               /*25*/
INSERT INTO AIEconomicStrategy_City_Flavors (AIEconomicStrategyType, FlavorType, Flavor) VALUES
('ECONOMICAISTRATEGY_LOSING_MONEY', 'FLAVOR_NAVAL', -10),
('ECONOMICAISTRATEGY_LOSING_MONEY', 'FLAVOR_RANGED', -10),
('ECONOMICAISTRATEGY_LOSING_MONEY', 'FLAVOR_MOBILE', -10);

-- LIKE_CRAZY
UPDATE AIEconomicStrategy_City_Flavors SET Flavor = 20 WHERE AIEconomicStrategyType = 'ECONOMICAISTRATEGY_EXPAND_LIKE_CRAZY' AND FlavorType = 'FLAVOR_EXPANSION'; /*10*/
UPDATE AIEconomicStrategy_City_Flavors SET Flavor = 20 WHERE AIEconomicStrategyType = 'ECONOMICAISTRATEGY_GROW_LIKE_CRAZY'   AND FlavorType = 'FLAVOR_GROWTH';    /*10*/

-- GS_CULTURE
UPDATE AIEconomicStrategy_City_Flavors SET Flavor = 15  WHERE AIEconomicStrategyType = 'ECONOMICAISTRATEGY_GS_CULTURE' AND FlavorType = 'FLAVOR_DEFENSE';      /*20*/
INSERT INTO AIEconomicStrategy_City_Flavors (AIEconomicStrategyType, FlavorType, Flavor) VALUES
('ECONOMICAISTRATEGY_GS_CULTURE', 'FLAVOR_RELIGION', 0),
('ECONOMICAISTRATEGY_GS_CULTURE', 'FLAVOR_TOURISM', 50),
('ECONOMICAISTRATEGY_GS_CULTURE', 'FLAVOR_GREAT_PEOPLE', 0),
('ECONOMICAISTRATEGY_GS_CULTURE', 'FLAVOR_SCIENCE', 0);

-- GS_CONQUEST
UPDATE AIEconomicStrategy_City_Flavors SET Flavor = 15  WHERE AIEconomicStrategyType = 'ECONOMICAISTRATEGY_GS_CONQUEST' AND FlavorType = 'FLAVOR_DEFENSE';           /*10*/
UPDATE AIEconomicStrategy_City_Flavors SET Flavor = 30  WHERE AIEconomicStrategyType = 'ECONOMICAISTRATEGY_GS_CONQUEST' AND FlavorType = 'FLAVOR_MILITARY_TRAINING'; /*20*/
INSERT INTO AIEconomicStrategy_City_Flavors (AIEconomicStrategyType, FlavorType, Flavor) VALUES
('ECONOMICAISTRATEGY_GS_CONQUEST', 'FLAVOR_GROWTH', 15),
('ECONOMICAISTRATEGY_GS_CONQUEST', 'FLAVOR_SCIENCE', 0),
('ECONOMICAISTRATEGY_GS_CONQUEST', 'FLAVOR_CULTURE', 0),
('ECONOMICAISTRATEGY_GS_CONQUEST', 'FLAVOR_GOLD', 0),
('ECONOMICAISTRATEGY_GS_CONQUEST', 'FLAVOR_MOBILE', 5);

-- GS_DIPLOMACY
INSERT INTO AIEconomicStrategy_City_Flavors (AIEconomicStrategyType, FlavorType, Flavor) VALUES
('ECONOMICAISTRATEGY_GS_DIPLOMACY', 'FLAVOR_SCIENCE', 0);

-- GS_SPACESHIP
INSERT INTO AIEconomicStrategy_City_Flavors (AIEconomicStrategyType, FlavorType, Flavor) VALUES
('ECONOMICAISTRATEGY_GS_SPACESHIP', 'FLAVOR_CULTURE', 0),
('ECONOMICAISTRATEGY_GS_SPACESHIP', 'FLAVOR_DEFENSE', 0),
('ECONOMICAISTRATEGY_GS_SPACESHIP', 'FLAVOR_AIR', 0),
('ECONOMICAISTRATEGY_GS_SPACESHIP', 'FLAVOR_GROWTH', 20),
('ECONOMICAISTRATEGY_GS_SPACESHIP', 'FLAVOR_GOLD', 5);

-- GS_SPACESHIP_HOMESTRETCH
INSERT INTO AIEconomicStrategy_City_Flavors (AIEconomicStrategyType, FlavorType, Flavor) VALUES
('ECONOMICAISTRATEGY_GS_SPACESHIP_HOMESTRETCH', 'FLAVOR_GOLD', 10),
('ECONOMICAISTRATEGY_GS_SPACESHIP_HOMESTRETCH', 'FLAVOR_PRODUCTION', 15);

UPDATE AIEconomicStrategy_City_Flavors SET Flavor = 40   WHERE AIEconomicStrategyType = 'ECONOMICAISTRATEGY_DEVELOPING_RELIGION'    AND FlavorType = 'FLAVOR_RELIGION';         /*30*/
UPDATE AIEconomicStrategy_City_Flavors SET Flavor = 80   WHERE AIEconomicStrategyType = 'ECONOMICAISTRATEGY_NEED_ARCHAEOLOGISTS'    AND FlavorType = 'FLAVOR_ARCHAEOLOGY';      /*40*/
UPDATE AIEconomicStrategy_City_Flavors SET Flavor = 60   WHERE AIEconomicStrategyType = 'ECONOMICAISTRATEGY_STARTED_PIETY'          AND FlavorType = 'FLAVOR_RELIGION';         /*40*/

--====================================================================================================================
-- RELIGIOUS_CIV
--====================================================================================================================
INSERT INTO AIEconomicStrategies (Type, NoMinorCivs, MinimumNumTurnsExecuted, CheckTriggerTurnCount) VALUES
('ECONOMICAISTRATEGY_RELIGIOUS_CIV', 1, 10, 10);
INSERT INTO AIEconomicStrategy_Player_Flavors (AIEconomicStrategyType, FlavorType, Flavor) VALUES
('ECONOMICAISTRATEGY_RELIGIOUS_CIV', 'FLAVOR_RELIGION', 20);
INSERT INTO AIEconomicStrategy_City_Flavors (AIEconomicStrategyType, FlavorType, Flavor) VALUES
('ECONOMICAISTRATEGY_RELIGIOUS_CIV', 'FLAVOR_RELIGION', 10);

--====================================================================================================================
-- AIGrandStrategy_Flavors
--====================================================================================================================
UPDATE AIGrandStrategy_Flavors SET Flavor = 16 WHERE AIGrandStrategyType = 'AIGRANDSTRATEGY_SPACESHIP'; /*13*/

--====================================================================================================================
-- AIGrandStrategy_Yields
--====================================================================================================================
UPDATE AIGrandStrategy_Yields SET Yield = 50 WHERE AIGrandStrategyType = 'AIGRANDSTRATEGY_CULTURE' AND YieldType = 'YIELD_SCIENCE'; /*50*/
INSERT INTO AIGrandStrategy_Yields (AIGrandStrategyType, YieldType, Yield) VALUES
('AIGRANDSTRATEGY_CONQUEST',		'YIELD_GOLD',		50),
('AIGRANDSTRATEGY_UNITED_NATIONS',	'YIELD_SCIENCE',	50),
('AIGRANDSTRATEGY_SPACESHIP',		'YIELD_FOOD',		50);

--====================================================================================================================
-- AIGrandStrategy_FlavorMods
--====================================================================================================================
-- Conquest
UPDATE AIGrandStrategy_FlavorMods SET Flavor = 3 WHERE AIGrandStrategyType = 'AIGRANDSTRATEGY_CONQUEST' AND FlavorType = 'FLAVOR_OFFENSE';           /*2*/
UPDATE AIGrandStrategy_FlavorMods SET Flavor = 2 WHERE AIGrandStrategyType = 'AIGRANDSTRATEGY_CONQUEST' AND FlavorType = 'FLAVOR_EXPANSION';         /*1*/
UPDATE AIGrandStrategy_FlavorMods SET Flavor = 2 WHERE AIGrandStrategyType = 'AIGRANDSTRATEGY_CONQUEST' AND FlavorType = 'FLAVOR_MILITARY_TRAINING'; /*1*/
UPDATE AIGrandStrategy_FlavorMods SET Flavor = 2 WHERE AIGrandStrategyType = 'AIGRANDSTRATEGY_CONQUEST' AND FlavorType = 'FLAVOR_AIR';               /*1*/
UPDATE AIGrandStrategy_FlavorMods SET Flavor = 6 WHERE AIGrandStrategyType = 'AIGRANDSTRATEGY_CONQUEST' AND FlavorType = 'FLAVOR_NUKE';              /*1*/
-- Culture
UPDATE AIGrandStrategy_FlavorMods SET Flavor = 3 WHERE AIGrandStrategyType = 'AIGRANDSTRATEGY_CULTURE' AND FlavorType = 'FLAVOR_CULTURE';  /*2*/
UPDATE AIGrandStrategy_FlavorMods SET Flavor = 2 WHERE AIGrandStrategyType = 'AIGRANDSTRATEGY_CULTURE' AND FlavorType = 'FLAVOR_RELIGION'; /*1*/
-- Spaceship: slightly higher influence
UPDATE AIGrandStrategy_FlavorMods SET Flavor = 4  WHERE AIGrandStrategyType = 'AIGRANDSTRATEGY_SPACESHIP' AND FlavorType = 'FLAVOR_SPACESHIP';  /*2*/
UPDATE AIGrandStrategy_FlavorMods SET Flavor = 3  WHERE AIGrandStrategyType = 'AIGRANDSTRATEGY_SPACESHIP' AND FlavorType = 'FLAVOR_SCIENCE';    /*2*/
UPDATE AIGrandStrategy_FlavorMods SET Flavor = 2  WHERE AIGrandStrategyType = 'AIGRANDSTRATEGY_SPACESHIP' AND FlavorType = 'FLAVOR_PRODUCTION'; /*1*/
UPDATE AIGrandStrategy_FlavorMods SET Flavor = -2 WHERE AIGrandStrategyType = 'AIGRANDSTRATEGY_SPACESHIP' AND FlavorType = 'FLAVOR_RELIGION';   /*-5*/

INSERT INTO AIGrandStrategy_FlavorMods (AIGrandStrategyType, FlavorType, Flavor) VALUES
('AIGRANDSTRATEGY_CONQUEST',	'FLAVOR_MOBILE',			2),
('AIGRANDSTRATEGY_CONQUEST',	'FLAVOR_DEFENSE',			1),
('AIGRANDSTRATEGY_CONQUEST',	'FLAVOR_NAVAL',				1),
('AIGRANDSTRATEGY_CONQUEST',	'FLAVOR_WATER_CONNECTION',	3),
('AIGRANDSTRATEGY_SPACESHIP',	'FLAVOR_GREAT_PEOPLE',		1),
('AIGRANDSTRATEGY_SPACESHIP',	'FLAVOR_GOLD',				1);
--====================================================================================================================
UPDATE Sapiens_DBUpdates SET Value = 1 WHERE Name = 'AI_Strategies';
