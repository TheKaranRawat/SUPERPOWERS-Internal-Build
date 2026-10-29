-- written by GAIA using Notepad++
CREATE TABLE IF NOT EXISTS Sapiens_DBUpdates (Name TEXT PRIMARY KEY, Value INTEGER DEFAULT 0);
INSERT OR IGNORE INTO Sapiens_DBUpdates (Name) VALUES ('GlobalAIDefines');
--====================================================================================================================
-- GLOBAL AI DEFINES
--====================================================================================================================
REPLACE INTO Defines (Name, Value) VALUES
('AI_ATTEMPT_RUSH_OVER_X_TURNS_TO_BUILD',                     5),  /* 15 */
('TECH_PRIORITY_UNIQUE_ITEM',                                15),  /* 5 */
('AI_RESEARCH_WEIGHT_MOD_PER_TURN_LEFT',                   0.04),  /* 0.025 */
('FLAVOR_RANDOMIZATION_RANGE',                                2),  /* 2 */
('PERSONALITY_FLAVOR_MIN_VALUE',                              1),  /* 0 */

('AI_GRAND_STRATEGY_NUM_TURNS_STRATEGY_MUST_BE_ACTIVE',      20),  /* 10 */
('AI_GS_RAND_ROLL',                                          13),  /* 50 */
('AI_GRAND_STRATEGY_CURRENT_STRATEGY_WEIGHT',                50),  /* 50 */
('AI_GRAND_STRATEGY_OTHER_PLAYERS_GS_MULTIPLIER',            10),  /* 50 */
('AI_GRAND_STRATEGY_CONQUEST_AT_WAR_WEIGHT',                 20),  /* 10 */
('AI_GS_CONQUEST_NOBODY_MET_FIRST_TURN',                     40),  /* 20 */
('AI_GRAND_STRATEGY_CONQUEST_NOBODY_MET_WEIGHT',           -100),  /* -50 */
('AI_GRAND_STRATEGY_CONQUEST_POWER_RATIO_MULTIPLIER',       125),  /* 100 */
('AI_GRAND_STRATEGY_CONQUEST_WEIGHT_PER_MAJOR_CONQUERED',    20),  /* 15 */
('AI_GS_CULTURE_RATIO_MULTIPLIER',                           50),  /* 75 */
('AI_GS_TOURISM_RATIO_MULTIPLIER',                          100),  /* 75 */

('AI_STRATEGY_MINIMUM_SETTLE_FERTILITY', 					18000),/*20000*/
('AI_STRATEGY_AREA_IS_FULL_PERCENT',                         80),  /* 50 */
('AI_STRATEGY_EARLY_EXPANSION_NUM_UNOWNED_TILES_REQUIRED',   19),  /* 25 */
('AI_PLOT_VALUE_STRATEGIC_RESOURCE',                         80),  /* 50 */
('AI_PLOT_VALUE_FIERCE_DISPUTE',                              8),  /* 6 */
('AI_GOLD_PRIORITY_MINIMUM_PLOT_BUY_VALUE',                 250),  /* 275 */
('AI_GOLD_BALANCE_TO_HALVE_PLOT_BUY_MINIMUM',               500),  /* 1000 */
('AI_GOLD_PRIORITY_UPGRADE_BASE',                           200),  /* 150 */
('AI_GOLD_PRIORITY_DIPLOMACY_BASE',                          50),  /* 150 */
('AI_GOLD_PRIORITY_DEFENSIVE_BUILDING',                     250),  /* 400 */

('BUILDER_TASKING_PLOT_EVAL_MULTIPLIER_FOOD',                 6),  /* 2 */
('BUILDER_TASKING_PLOT_EVAL_MULTIPLIER_PRODUCTION',           6),  /* 2 */
('BUILDER_TASKING_PLOT_EVAL_MULTIPLIER_GOLD',                 3),  /* 1 */
('BUILDER_TASKING_PLOT_EVAL_MULTIPLIER_SCIENCE',              4),  /* 1 */
('BUILDER_TASKING_PLOT_EVAL_MULTIPLIER_CULTURE',              4),  /* 1 */

('AI_MILITARY_THREAT_WEIGHT_SEVERE',                          9),  /* 6 */
('AI_MILITARY_THREAT_WEIGHT_CRITICAL',                       27),  /* 10 */
('AI_STRATEGY_DEFEND_MY_LANDS_UNITS_PER_CITY',              1.5),  /* 1.0 */

('AI_CITY_SPECIALIZATION_REEVALUATION_INTERVAL',             10),  /* 50 */
('AI_CITY_SPECIALIZATION_FOOD_WEIGHT_NUM_CITIES',           -25),  /* -50 */
('AI_CITY_SPECIALIZATION_PRODUCTION_WEIGHT_NEXT_WONDER',      1),  /* 0.2 */
('AI_CITY_SPECIALIZATION_SCIENCE_WEIGHT_FLAVOR_SCIENCE',     40),  /* 20 */
('AI_CITY_SPECIALIZATION_SCIENCE_WEIGHT_FLAVOR_SPACESHIP',   40),  /* 10 */

('AI_CITYSTRATEGY_MEDIUM_CITY_POP_THRESHOLD',                 6),  /* 5 */
('AI_CITYSTRATEGY_LARGE_CITY_POP_THRESHOLD',                 15),  /* 12 */
('AI_CITYSTRATEGY_YIELD_DEFICIENT_GOLD',                    0.5),  /* 0.0 */

('AI_CITIZEN_VALUE_FOOD',                                    16),  /* 14 */
('AI_CITIZEN_VALUE_PRODUCTION',                              12),  /* 12 */
('AI_CITIZEN_VALUE_GOLD',                                     6),  /* 8 */
('AI_CITIZEN_VALUE_SCIENCE',                                  9),  /* 7 */
('AI_CITIZEN_VALUE_CULTURE',                                  8),  /* 15 */
('AI_CITIZEN_VALUE_FAITH',                                    7),  /* 5 */

('AI_OPERATIONAL_CITY_ATTACK_DEPLOY_RANGE',                   6),  /* 5 */
('AI_OPERATIONAL_PILLAGE_ENEMY_DEPLOY_RANGE',                 3),  /* 5 */
('AI_OPERATIONAL_PERCENT_DANGER_FOR_FORWARD_MUSTER',         25),  /* 20 */
('AI_OPERATIONAL_MAX_RECRUIT_TURNS_DEFAULT',                  6),  /* 5 */
('AI_OPERATIONAL_MAX_RECRUIT_TURNS_ENEMY_TERRITORY',         12),  /* 10 */

('AI_TACTICAL_MAP_UNIT_STRENGTH_MULTIPLIER',                 20),  /* 10 */
('AI_TACTICAL_MAP_DOMINANCE_PERCENTAGE',                     40),  /* 25 */

('AI_TACTICAL_MOVE_PRIORITY_RANDOMNESS',                      3),  /* 6 */
('AI_TACTICAL_BARBARIAN_PRIORITY_CAPTURE_CITY',              11),  /* 9 */

('AI_HOMELAND_MOVE_PRIORITY_RANDOMNESS',                      5),  /* 10 */
('AI_HOMELAND_MAX_UPGRADE_MOVE_TURNS',                       10),  /* 5 */
('AI_HOMELAND_MAX_DEFENSIVE_MOVE_TURNS',                      3),  /* 4 */

('AI_DIPLO_LAND_DISPUTE_WEIGHT_FIERCE',                       9),  /* 5 */

('AI_DANGER_MAJOR_APPROACH_DECEPTIVE',                      0.4),  /* 0.1 */
('AI_DANGER_MAJOR_APPROACH_HOSTILE',                        0.8),  /* 0.2 */
('AI_DANGER_MINOR_APPROACH_BULLY',                          0.8),  /* 0.9 */

('RELIGION_BELIEF_SCORE_UNOWNED_PLOT_MULTIPLIER',             5),  /* 3 */
('RELIGION_BELIEF_SCORE_OWNED_PLOT_MULTIPLIER',               6),  /* 5 */
('RELIGION_BELIEF_SCORE_WORKED_PLOT_MULTIPLIER',              6),  /* 8 */
('RELIGION_BELIEF_SCORE_CITY_MULTIPLIER',                     5),  /* 3 */
('RELIGION_MISSIONARY_RANGE_IN_TURNS',                        8),  /* 10 */

('NORMAL_ANNEX',                                            0.4),  /* 0.5 */
('AGGRESSIVE_ANNEX',                                        0.8),  /* 0.75 */

('IDEOLOGY_PERCENT_CLEAR_VICTORY_PREF',                      50),  /* 25 */
('IDEOLOGY_SCORE_HOSTILE',                                   20),  /* 8 */
('IDEOLOGY_SCORE_GUARDED',                                   10),  /* 4 */
('IDEOLOGY_SCORE_AFRAID',                                    10),  /* 6 */
('IDEOLOGY_SCORE_FRIENDLY',                                  20),  /* 12 */
('IDEOLOGY_SCORE_HAPPINESS',                                  5),  /* 3 */
('IDEOLOGY_SCORE_PER_FREE_TENET',                            40),  /* 36 */
('IDEOLOGY_SCORE_GRAND_STRATS',                             400),  /* 300 */

('SETTLER_FOOD_MULTIPLIER',                                  16),  /* 15 */
('SETTLER_PRODUCTION_MULTIPLIER',                            12),  /* 3 */
('SETTLER_GOLD_MULTIPLIER',                                   6),  /* 3 */
('SETTLER_SCIENCE_MULTIPLIER',                                9),  /* 1 */
('SETTLER_FAITH_MULTIPLIER',                                  7),  /* 1 */

('AI_HOMELAND_GREAT_PERSON_TURNS_TO_WAIT',                   15),  /* 10 */
('AI_CITY_SPECIALIZATION_EARLIEST_TURN',                     45),  /* 25 */
('AI_CITYSTRATEGY_OPERATION_UNIT_BASE_WEIGHT',             2000),  /* 1500 */
('AI_CITYSTRATEGY_OPERATION_UNIT_FLAVOR_MULTIPLIER',        350),  /* 250 */
('AI_GOLD_PRIORITY_UPGRADE_PER_FLAVOR_POINT',                50),  /* 25 */
('AI_CITYSTRATEGY_ARMY_UNIT_BASE_WEIGHT',                  1500),  /* 750 */
('BUILDER_TASKING_BASELINE_BUILD_IMPROVEMENTS',               2),  /* 1 */
('BUILDER_TASKING_BASELINE_BUILD_RESOURCE_IMPROVEMENTS',     20),  /* 10 */
('BUILDER_TASKING_BASELINE_SCRUB_FALLOUT',                10000),  /* 20000 */
('BUILDER_TASKING_BASELINE_ADDS_CULTURE',                    75),  /* 100 */
('BUILDER_TASKING_BASELINE_BUILD_ROUTES',                    50),  /* 100 */
('BUILDER_TASKING_BASELINE_REPAIR',                         125),  /* 250 */
('AI_GRAND_STRATEGY_CONQUEST_WEIGHT_PER_MAJOR_ATTACKED',     15),  /* 10 */
('AI_GS_CULTURE_AHEAD_WEIGHT',                               30),  /* 50 */
('AI_GS_CULTURE_INFLUENTIAL_CIV_MOD',                        30),  /* 50 */
('AI_GRAND_STRATEGY_UN_EACH_MINOR_ATTACKED_WEIGHT',         -15),  /* -30 */
('AI_STRATEGY_NAVAL_UNITS_PER_CITY',                        0.7),  /* 1 */
('AI_STRATEGY_MILITARY_RESERVE_PERCENTAGE',                  27),  /* 35 */
('AI_DIPLO_LAND_DISPUTE_WEIGHT_STRONG',                       5);  /* 3 */
--====================================================================================================================
UPDATE Sapiens_DBUpdates SET Value = 1 WHERE Name = 'GlobalAIDefines';
