-- written by GAIA using Notepad++
CREATE TABLE IF NOT EXISTS Sapiens_DBUpdates (Name TEXT PRIMARY KEY, Value INTEGER DEFAULT 0);
INSERT OR IGNORE INTO Sapiens_DBUpdates (Name) VALUES ('DB_ModOptions');
--====================================================================================================================
-- SAPIENS MOD OPTIONS
--====================================================================================================================
-- Must run BEFORE CORE_OPTIONS.sql.
CREATE TABLE IF NOT EXISTS Sapiens_ModOptions (Name TEXT PRIMARY KEY, Value INTEGER DEFAULT 0);

--====================================================================================================================
UPDATE Sapiens_DBUpdates SET Value = 1 WHERE Name = 'DB_ModOptions';
