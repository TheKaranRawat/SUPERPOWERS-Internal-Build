-- written by GAIA using Notepad++
CREATE TABLE IF NOT EXISTS Sapiens_DBUpdates (Name TEXT PRIMARY KEY, Value INTEGER DEFAULT 0);
INSERT OR IGNORE INTO Sapiens_DBUpdates (Name) VALUES ('DB_Specialists');
--====================================================================================================================
-- SPECIALISTS UI
--====================================================================================================================

ALTER TABLE Specialists ADD SlotTexture TEXT DEFAULT NULL;

--====================================================================================================================
UPDATE Sapiens_DBUpdates SET Value = 1 WHERE Name = 'DB_Specialists';
