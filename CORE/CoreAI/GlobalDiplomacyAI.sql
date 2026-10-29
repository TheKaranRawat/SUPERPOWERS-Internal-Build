-- written by GAIA using Notepad++
CREATE TABLE IF NOT EXISTS Sapiens_DBUpdates (Name TEXT PRIMARY KEY, Value INTEGER DEFAULT 0);
INSERT OR IGNORE INTO Sapiens_DBUpdates (Name) VALUES ('GlobalDiplomacyAI');
--====================================================================================================================
-- GLOBAL DIPLOMACY AI DEFINES
--====================================================================================================================
REPLACE INTO Defines (Name, Value) VALUES
('OPINION_WEIGHT_NUKED_MAX',                             100),  /* 50 */
('MINOR_APPROACH_WAR_CONQUEST_GRAND_STRATEGY',             5),  /* 8 */
('MINOR_APPROACH_WAR_CONQUEST_GRAND_STRATEGY_NEIGHBORS',  20),  /* 10 */
('MINOR_APPROACH_CONQUEST_PROXIMITY_NEIGHBORS',            2),  /* 1 */
('MINOR_APPROACH_WAR_TARGET_IMPOSSIBLE',                   0),  /* 10 */
('MINOR_APPROACH_WAR_TARGET_BAD',                         10),  /* 20 */
('MINOR_APPROACH_WAR_TARGET_AVERAGE',                     50),  /* 40 */
('MINOR_APPROACH_WAR_TARGET_FAVORABLE',                  100),  /* 110 */
('MINOR_APPROACH_WAR_TARGET_SOFT',                       150),  /* 130 */
('OPINION_WEIGHT_LAND_NONE',                              -3),  /* -6 */
('OPINION_WEIGHT_LAND_WEAK',                               6),  /* 10 */
('OPINION_WEIGHT_LAND_STRONG',                            25),  /* 20 */
('OPINION_WEIGHT_LAND_FIERCE',                            60),  /* 30 */
('OPINION_WEIGHT_VICTORY_NONE',                           -3),  /* -6 */
('OPINION_WEIGHT_VICTORY_WEAK',                            6),  /* 10 */
('OPINION_WEIGHT_VICTORY_STRONG',                         25),  /* 20 */
('OPINION_WEIGHT_VICTORY_FIERCE',                         60),  /* 30 */
('OPINION_WEIGHT_WONDER_NONE',                             0),  /* 0 */
('OPINION_WEIGHT_WONDER_WEAK',                             5),  /* 10 */
('OPINION_WEIGHT_WONDER_STRONG',                          10),  /* 15 */
('OPINION_WEIGHT_WONDER_FIERCE',                          20),  /* 20 */
('OPINION_WEIGHT_MINOR_CIV_NONE',                          0),  /* 0 */
('OPINION_WEIGHT_MINOR_CIV_WEAK',                          5),  /* 10 */
('OPINION_WEIGHT_MINOR_CIV_STRONG',                       20),  /* 20 */
('OPINION_WEIGHT_MINOR_CIV_FIERCE',                       50),  /* 30 */
('MILITARY_AGGRESSIVE_POSTURE_THRESHOLD_LOW',              5),  /* 10 */
('MILITARY_AGGRESSIVE_POSTURE_THRESHOLD_MEDIUM',          15),  /* 30 */
('MILITARY_AGGRESSIVE_POSTURE_THRESHOLD_HIGH',            25),  /* 50 */
('MILITARY_AGGRESSIVE_POSTURE_THRESHOLD_INCREDIBLE',      40),  /* 80 */
('MILITARY_STRENGTH_RATIO_MULTIPLIER',                   125),  /* 100 */
('ECONOMIC_STRENGTH_RATIO_MULTIPLIER',                   110),  /* 100 */
('MINOR_APPROACH_WAR_CULTURE_GRAND_STRATEGY',            -10),  /* -20 */
('APPROACH_DECEPTIVE_IGNORED_EXPANSION_PROMISE',          -2),  /* -4 */
('APPROACH_WAR_RECKLESS_EXPANDER',                       135),  /* 160 */
('APPROACH_WAR_PROXIMITY_NEIGHBORS',                     140),  /* 115 */
('APPROACH_OPINION_UNFORGIVABLE_WAR',                     12),  /* 10 */
('APPROACH_OPINION_ENEMY_WAR',                             9),  /* 8 */
('APPROACH_OPINION_COMPETITOR_WAR',                        6),  /* 4 */
('MINOR_APPROACH_PROTECTIVE_CONQUEST_GRAND_STRATEGY',     -8),  /* -15 */
('MINOR_APPROACH_WAR_PLANNING_WAR_WITH_ANOTHER_PLAYER',   -8),  /* -15 */
('APPROACH_WAR_CONQUEST_GRAND_STRATEGY',                  10),  /* 5 */
('APPROACH_FRIENDLY_DEMAND',                              -3),  /* -6 */
('APPROACH_WAR_PROXIMITY_DISTANT',                        25),  /* 50 */
('APPROACH_WAR_PROXIMITY_FAR',                            30),  /* 60 */
('APPROACH_DECEPTIVE_DENOUNCED',                         -50),  /* -100 */
('APPROACH_DECEPTIVE_WORKING_WITH_PLAYER',                 1),  /* 3 */
('LAND_DISPUTE_STRONG_THRESHOLD',                        240),  /* 230 */
('EXPANSION_CAPITAL_DISTANCE_AGGRESSIVE_POSTURE_LOW',      8),  /* 9 */
('OPINION_WEIGHT_WARMONGER_CRITICAL',                     50),  /* 100 */
('OPINION_WEIGHT_WARMONGER_SEVERE',                       40),  /* 70 */
('OPINION_WEIGHT_WARMONGER_MAJOR',                        25),  /* 40 */
('OPINION_WEIGHT_WARMONGER_MINOR',                        10),  /* 15 */
('OPINION_WEIGHT_DOF_WITH_FRIEND',                       -25),  /* -15 */
('OPINION_WEIGHT_DOF',                                   -70),  /* -35 */
('WAR_PROJECTION_THEIR_ECONOMIC_STRENGTH_STRONG',         -6),  /* -12 */
('WAR_PROJECTION_THEIR_ECONOMIC_STRENGTH_POWERFUL',      -15),  /* -30 */
('WAR_PROJECTION_THEIR_ECONOMIC_STRENGTH_IMMENSE',       -25),  /* -50 */
('WAR_PROJECTION_WAR_DAMAGE_THEM_CRIPPLED',               70),  /* 40 */
('OPINION_WEIGHT_WE_LIKED_THEIR_PROPOSAL',               -10),  /* -15 */
('OPINION_WEIGHT_WE_DISLIKED_THEIR_PROPOSAL',             10),  /* 15 */
('OPINION_WEIGHT_THEY_SUPPORTED_OUR_PROPOSAL',           -10),  /* -20 */
('OPINION_WEIGHT_THEY_FOILED_OUR_PROPOSAL',               15),  /* 20 */
('OPINION_WEIGHT_RECKLESS_EXPANDER',                      35),  /* 35 */
('WAR_PROJECTION_RECKLESS_EXPANDER',                      25),  /* 25 */
('WARMONGER_THREAT_PER_TURN_DECAY',                       -7),  /* -5 */
('WARMONGER_THREAT_MINOR_THRESHOLD',                      20),  /* 20 */
('WARMONGER_THREAT_MAJOR_THRESHOLD',                      50),  /* 50 */
('WARMONGER_THREAT_SEVERE_THRESHOLD',                    100),  /* 100 */
('WARMONGER_THREAT_CRITICAL_THRESHOLD',                  200),  /* 200 */
('WARMONGER_THREAT_MINOR_ATTACKED_WEIGHT',               250),  /* 125 */
('WARMONGER_THREAT_MAJOR_ATTACKED_WEIGHT',               250),  /* 250 */
('WARMONGER_THREAT_MINOR_CONQUERED_WEIGHT',             1000),  /* 1000 */
('WARMONGER_THREAT_MAJOR_CONQUERED_WEIGHT',             1000),  /* 1000 */
('WARMONGER_THREAT_PERSONALITY_MOD',                      10),  /* 10 */
('WARMONGER_THREAT_SEVERE_PERCENT_THRESHOLD',             25),  /* 25 */
('WARMONGER_THREAT_CRITICAL_PERCENT_THRESHOLD',           40);  /* 40 */
--====================================================================================================================
UPDATE Sapiens_DBUpdates SET Value = 1 WHERE Name = 'GlobalDiplomacyAI';
