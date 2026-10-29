-- written by GAIA using Notepad++
CREATE TABLE IF NOT EXISTS Sapiens_DBUpdates (Name TEXT PRIMARY KEY, Value INTEGER DEFAULT 0);
INSERT OR IGNORE INTO Sapiens_DBUpdates (Name) VALUES ('CivNames_en_US');
--====================================================================================================================
-- ALPHABETIC CIVILIZATIONS
--====================================================================================================================
UPDATE Language_en_US SET Text = 'Aztec'		WHERE Tag = 'TXT_KEY_CIV_AZTEC_SHORT_DESC';
UPDATE Language_en_US SET Text = 'Celts'		WHERE Tag = 'TXT_KEY_CIV_CELTS_SHORT_DESC';
UPDATE Language_en_US SET Text = 'Huns'			WHERE Tag = 'TXT_KEY_CIV_HUNS_SHORT_DESC';
UPDATE Language_en_US SET Text = 'Inca'			WHERE Tag = 'TXT_KEY_CIV_INCA_SHORT_DESC';
UPDATE Language_en_US SET Text = 'Iroquois'		WHERE Tag = 'TXT_KEY_CIV_IROQUOIS_SHORT_DESC';
UPDATE Language_en_US SET Text = 'Maya'			WHERE Tag = 'TXT_KEY_CIV_MAYA_SHORT_DESC';
UPDATE Language_en_US SET Text = 'Netherlands'	WHERE Tag = 'TXT_KEY_CIV_NETHERLANDS_SHORT_DESC';
UPDATE Language_en_US SET Text = 'Ottoman'		WHERE Tag = 'TXT_KEY_CIV_OTTOMAN_SHORT_DESC';
UPDATE Language_en_US SET Text = 'Shoshone'		WHERE Tag = 'TXT_KEY_CIV_SHOSHONE_SHORT_DESC';
UPDATE Language_en_US SET Text = 'Zulu'			WHERE Tag = 'TXT_KEY_CIV_ZULU_SHORT_DESC';
--====================================================================================================================
UPDATE Sapiens_DBUpdates SET Value = 1 WHERE Name = 'CivNames_en_US';
