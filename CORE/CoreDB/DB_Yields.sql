-- written by GAIA using Notepad++
CREATE TABLE IF NOT EXISTS Sapiens_DBUpdates (Name TEXT PRIMARY KEY, Value INTEGER DEFAULT 0);
INSERT OR IGNORE INTO Sapiens_DBUpdates (Name) VALUES ('DB_Yields');
--====================================================================================================================
-- YIELDS UI
--====================================================================================================================

-- Extend vanilla Yields with UI display columns
ALTER TABLE Yields ADD ColorString  TEXT     DEFAULT '[COLOR_WHITE]';
ALTER TABLE Yields ADD ImageTexture TEXT     DEFAULT 'YieldAtlas.dds';
ALTER TABLE Yields ADD ImageOffset  INTEGER  DEFAULT 0;

-- Set yield-specific display colors
UPDATE Yields SET ColorString='[COLOR_MAGENTA]' WHERE Type='YIELD_CULTURE';
UPDATE Yields SET ColorString='[COLOR_WHITE]'   WHERE Type='YIELD_FAITH';
UPDATE Yields SET ColorString='[COLOR_GREEN]'   WHERE Type='YIELD_FOOD';
UPDATE Yields SET ColorString='[COLOR_YELLOW]'  WHERE Type='YIELD_GOLD';
UPDATE Yields SET ColorString='[COLOR_YELLOW]'  WHERE Type='YIELD_PRODUCTION';
UPDATE Yields SET ColorString='[COLOR_BLUE]'    WHERE Type='YIELD_SCIENCE';

-- Set yield-specific UI texture offsets (within the 4-up YieldAtlas.dds: F=0, P=128, G=256, S=384)
UPDATE Yields SET ImageOffset=128 WHERE Type='YIELD_PRODUCTION';
UPDATE Yields SET ImageOffset=256 WHERE Type='YIELD_GOLD';
UPDATE Yields SET ImageOffset=384 WHERE Type='YIELD_SCIENCE';

-- Set custom texture paths where applicable (CULTURE/FAITH have dedicated 128px atlases)
UPDATE Yields SET ImageTexture='YieldAtlas_128_Culture.dds' WHERE Type='YIELD_CULTURE';
UPDATE Yields SET ImageTexture='YieldAtlas_128_Faith.dds'   WHERE Type='YIELD_FAITH';

--====================================================================================================================
-- TOURISM
--====================================================================================================================
-- Do not change order!
INSERT OR IGNORE INTO Yields (ID, Type, Description,  IconString,         ColorString,     ImageTexture,                   MinCity, AIWeightPercent) VALUES
	(6, 'YIELD_TOURISM', 'TXT_KEY_GAIA_YIELD_NAME_TOURISM',     '[ICON_TOURISM]',   '[COLOR_WHITE]', 'YieldAtlas_128_Tourism.dds',   0, 80);

INSERT INTO Flavors (Type) VALUES ('FLAVOR_TOURISM');
INSERT INTO Leader_Flavors (LeaderType, FlavorType, Flavor) SELECT Type, 'FLAVOR_TOURISM', 5 FROM Leaders;

INSERT INTO PostDefines (Name, Key, "Table") VALUES
	('PD_START_ERA_TOURISM', 'ERA_ANCIENT', 'Eras');

--====================================================================================================================
UPDATE Sapiens_DBUpdates SET Value = 1 WHERE Name = 'DB_Yields';
