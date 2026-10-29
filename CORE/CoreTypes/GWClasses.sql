-- written by GAIA using Notepad++
CREATE TABLE IF NOT EXISTS Sapiens_DBUpdates (Name TEXT PRIMARY KEY, Value INTEGER DEFAULT 0);
INSERT OR IGNORE INTO Sapiens_DBUpdates (Name) VALUES ('GWClasses');
--====================================================================================================================
-- GREAT WORK CLASSES + SLOTS
--====================================================================================================================
UPDATE GreatWorks SET Image = 'GAIA_GW_Artifact.dds' WHERE GreatWorkClassType = 'GREAT_WORK_ARTIFACT';

---------------------------------------------
-- RELIGION
---------------------------------------------
INSERT OR IGNORE INTO GreatWorkClasses (Type, SlotType) VALUES	('GREAT_WORK_GAIA_HOLY_ARTIFACT', 'GREAT_WORK_SLOT_GAIA_HOLY_ARTIFACT');
INSERT OR IGNORE INTO GreatWorkSlots (Type, SlotsToolTipText, EmptyToolTipText, FilledIcon, EmptyIcon) VALUES
('GREAT_WORK_SLOT_GAIA_HOLY_ARTIFACT', 'TXT_KEY_GREAT_WORK_SLOT_GAIA_HOLY_ARTIFACT_SLOTS_TOOLTIP', 'TXT_KEY_GREAT_WORK_SLOT_GAIA_HOLY_ARTIFACT_EMPTY_TOOLTIP',	'GAIA_GW_Religion_Slots.dds', 'GAIA_GW_Religion_Empty.dds');

---------------------------------------------
-- CORPORATIONS
---------------------------------------------
INSERT OR IGNORE INTO GreatWorkClasses (Type, SlotType) VALUES	('GREAT_WORK_GAIA_CORPORATION',	'GREAT_WORK_SLOT_GAIA_CORPORATION');
INSERT OR IGNORE INTO GreatWorkSlots (Type, SlotsToolTipText, EmptyToolTipText, FilledIcon, EmptyIcon) VALUES
('GREAT_WORK_SLOT_GAIA_CORPORATION', 'TXT_KEY_GREAT_WORK_SLOT_GAIA_CORPORATION_SLOTS_TOOLTIP', 'TXT_KEY_GREAT_WORK_SLOT_GAIA_CORPORATION_EMPTY_TOOLTIP', 'GAIA_GW_Corporation_Slots.dds', 'GAIA_GW_Corporation_Empty.dds');

---------------------------------------------
-- CINEMA
---------------------------------------------
INSERT OR IGNORE INTO GreatWorkClasses (Type, SlotType) VALUES	('GREAT_WORK_GAIA_CINEMA', 'GREAT_WORK_SLOT_GAIA_CINEMA');
INSERT OR IGNORE INTO GreatWorkSlots (Type, SlotsToolTipText, EmptyToolTipText, FilledIcon, EmptyIcon) VALUES
('GREAT_WORK_SLOT_GAIA_CINEMA', 'TXT_KEY_GREAT_WORK_SLOT_GAIA_CINEMA_SLOTS_TOOLTIP', 'TXT_KEY_GREAT_WORK_SLOT_GAIA_CINEMA_EMPTY_TOOLTIP', 'GAIA_GW_Cinema_Slots.dds', 'GAIA_GW_Cinema_Empty.dds');

---------------------------------------------
-- VIDEO GAMES
---------------------------------------------
INSERT OR IGNORE INTO GreatWorkClasses (Type, SlotType) VALUES	('GREAT_WORK_GAIA_VIDEOGAME', 'GREAT_WORK_SLOT_GAIA_VIDEOGAME');
INSERT OR IGNORE INTO GreatWorkSlots (Type, SlotsToolTipText, EmptyToolTipText, FilledIcon, EmptyIcon) VALUES
('GREAT_WORK_SLOT_GAIA_VIDEOGAME', 'TXT_KEY_GREAT_WORK_SLOT_GAIA_VIDEOGAME_SLOTS_TOOLTIP', 'TXT_KEY_GREAT_WORK_SLOT_GAIA_VIDEOGAME_EMPTY_TOOLTIP',	'GAIA_GW_Videogame_Slots.dds', 'GAIA_GW_Videogame_Empty.dds');
--====================================================================================================================
UPDATE Sapiens_DBUpdates SET Value = 1 WHERE Name = 'GWClasses';
