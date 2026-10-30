-- written by GAIA using Notepad++
CREATE TABLE IF NOT EXISTS Sapiens_DBUpdates (Name TEXT PRIMARY KEY, Value INTEGER DEFAULT 0);
INSERT OR IGNORE INTO Sapiens_DBUpdates (Name) VALUES ('GameOptions');
--====================================================================================================================
-- GAMEPLAY OPTIONS
--====================================================================================================================
CREATE TEMP TABLE Sapiens_GameOptionsConfig (
	GOType		TEXT	NOT NULL,
	GOVisible	INTEGER	NOT NULL,
	GODef		INTEGER NOT NULL,
	GOSP		INTEGER NOT NULL,
	GOMP		INTEGER NOT NULL,
	PRIMARY KEY (GOType)
);

INSERT INTO Sapiens_GameOptionsConfig
(GOType,                        GOVisible,  GODef,  GOSP,   GOMP) VALUES
('AI_ONE_CITY_CHALLENGE',       1,          0,      1,      1),
('BEST_STARTING_LOCATION',      1,          0,      1,      1),
('FRIENDLY_CITADELS',           1,          0,      1,      1),
('GOODY_HUTS_RECON_ONLY',       1,          0,      1,      1),
('GOODY_HUTS_SCIENCE',          1,          0,      1,      1),
('NO_AI_WONDERS',               1,          0,      1,      1),
('NO_COMBAT_RANDOMNESS',        1,          1,      1,      1),
('NO_RESEARCH_AGREEMENTS',      1,          0,      1,      1),
('REALISTIC_OCEAN_CROSSING',    0,          0,      1,      1),
('REMOVE_XP_CAP',               1,          0,      1,      1),
('RETURNING_FOG',               1,          0,      1,      1),
('SLOW_TECH',                   1,          0,      1,      1),
('TILE_CONQUEST',               1,          0,      1,      1),
('TWO_UNITS_PER_TILE',          1,          1,      1,      1),
('UNWELCOME_PROPHETS',			1,          0,      1,      1),
('VASSALAGE',                   1,          0,      1,      1),
('WONDER_RACE_NOTIFICATIONS',   1,          0,      1,      1);

INSERT OR REPLACE INTO GameOptions
        (Type,                        Description,                         Help,                                            "Visible",  "Default", "SupportsSinglePlayer", "SupportsMultiplayer")
SELECT  'GAMEOPTION_GAIA_'||GOType,   'TXT_KEY_GAME_OPTION_GAIA_'||GOType, 'TXT_KEY_GAME_OPTION_GAIA_'||GOType||'_HELP',    GOVisible,  GODef,     GOSP,                   GOMP
FROM Sapiens_GameOptionsConfig;

DROP TABLE Sapiens_GameOptionsConfig;
--====================================================================================================================
-- VANILLA HIDDEN OPTIONS -- UNHIDE
--====================================================================================================================
   UPDATE GameOptions SET Visible = 1 WHERE Type = 'GAMEOPTION_NO_LEAGUES';

--====================================================================================================================
-- VASSALAGE
--====================================================================================================================

INSERT INTO PostDefines (Name, Key, "Table") VALUES ('PD_START_ERA_VASSALAGE', 'ERA_MEDIEVAL', 'Eras');

INSERT OR REPLACE INTO Resolutions
		(Type,								Description,								Help,											VoterDecision,						ProposerDecision,			TechPrereqAnyMember)
VALUES	('RESOLUTION_GAIA_END_ALL_VASSALS',	'TXT_KEY_RESOLUTION_GAIA_END_ALL_VASSALS',	'TXT_KEY_RESOLUTION_GAIA_END_ALL_VASSALS_HELP',	'RESOLUTION_DECISION_YES_OR_NO',	'RESOLUTION_DECISION_NONE', 'TECH_RADIO');
		
INSERT OR IGNORE INTO _Resolutions_Extensions (ResolutionType) VALUES ('RESOLUTION_GAIA_END_ALL_VASSALS');
UPDATE _Resolutions_Extensions SET bEndAllCurrentVassals = 1 WHERE ResolutionType = 'RESOLUTION_GAIA_END_ALL_VASSALS';

INSERT OR REPLACE INTO _GameSpeed_Vassalage
(GameSpeedType,			iMinVassalTurns, iMinVoluntaryVassalTurns, iMinVassalTaxTurns, iTurnsBetweenVassals, iMinVassalLiberateTurns) VALUES
('GAMESPEED_QUICK',		40,				 20,					   15,				   20,					40),
('GAMESPEED_STANDARD',	50,				 25,					   25,				   30,					50),
('GAMESPEED_EPIC',		60,				 30,					   35,				   45,					60),
('GAMESPEED_MARATHON',	100,			 50,					   75,				   60,					100);
--====================================================================================================================
UPDATE Sapiens_DBUpdates SET Value = 1 WHERE Name = 'GameOptions';
