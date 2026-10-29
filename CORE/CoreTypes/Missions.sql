-- written by GAIA using Notepad++
CREATE TABLE IF NOT EXISTS Sapiens_DBUpdates (Name TEXT PRIMARY KEY, Value INTEGER DEFAULT 0);
INSERT OR IGNORE INTO Sapiens_DBUpdates (Name) VALUES ('Missions');
--====================================================================================================================
-- UNIT MISSIONS
--====================================================================================================================

-- BLOCKBUSTER
INSERT OR IGNORE INTO Missions
	(Type, Description, Help, DisabledHelp, EntityEventType, Time, Target, Build, Sound, HotKey, AltDown, ShiftDown, CtrlDown, HotKeyPriority, HotKeyAlt, AltDownAlt, ShiftDownAlt, CtrlDownAlt, HotKeyPriorityAlt, OrderPriority, Visible, IconIndex, IconAtlas)
VALUES ('MISSION_GAIA_BLOCKBUSTER', 'TXT_KEY_MISSION_GAIA_BLOCKBUSTER', 'TXT_KEY_MISSION_GAIA_BLOCKBUSTER_HELP', 'TXT_KEY_MISSION_GAIA_BLOCKBUSTER_DISABLED_HELP', 'ENTITY_EVENT_GREAT_EVENT', 20, 0, 0, 0, NULL, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 199, 1, 0, 'GAIA_BLOCKBUSTER_UA');

-- CYBER ATTACK
INSERT OR IGNORE INTO Missions
	(Type, Description, Help, DisabledHelp, EntityEventType, Time, Target, Build, Sound, HotKey, AltDown, ShiftDown, CtrlDown, HotKeyPriority, HotKeyAlt, AltDownAlt, ShiftDownAlt, CtrlDownAlt, HotKeyPriorityAlt, OrderPriority, Visible, IconIndex, IconAtlas)
VALUES ('MISSION_GAIA_CYBERATTACK', 'TXT_KEY_MISSION_GAIA_CYBERATTACK', 'TXT_KEY_MISSION_GAIA_CYBERATTACK_HELP', 'TXT_KEY_MISSION_GAIA_CYBERATTACK_DISABLED_HELP', 'ENTITY_EVENT_GREAT_EVENT', 20, 0, 0, 0, NULL, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 199, 1, 0, 'GAIA_CYBERATTACK_UA');

-- EXTRA TRADE ROUTE
INSERT OR IGNORE INTO Missions
	(Type, Description, Help, DisabledHelp, EntityEventType, Time, Target, Build, Sound, HotKey, AltDown, ShiftDown, CtrlDown, HotKeyPriority, HotKeyAlt, AltDownAlt, ShiftDownAlt, CtrlDownAlt, HotKeyPriorityAlt, OrderPriority, Visible, IconIndex, IconAtlas)
VALUES ('MISSION_GAIA_EXTRA_TRADEROUTE', 'TXT_KEY_MISSION_GAIA_EXTRA_TRADEROUTE', 'TXT_KEY_MISSION_GAIA_EXTRA_TRADEROUTE_HELP', 'TXT_KEY_MISSION_GAIA_EXTRA_TRADEROUTE_DISABLED_HELP', 'ENTITY_EVENT_GREAT_EVENT', 20, 0, 0, 0, NULL, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 199, 1, 0, 'UNIT_ACTION_ATLAS_TRADE');

-- FOUND CORPORATION
INSERT OR IGNORE INTO Missions
	(Type, Description, Help, DisabledHelp, Time, Target, Build, Sound, AltDown, ShiftDown, CtrlDown, HotKeyPriority, HotKeyAlt, AltDownAlt, ShiftDownAlt, CtrlDownAlt, HotKeyPriorityAlt, OrderPriority, Visible, IconIndex, IconAtlas)
VALUES ('MISSION_GAIA_FOUNDCORP', 'TXT_KEY_MISSION_GAIA_FOUNDCORP', 'TXT_KEY_MISSION_GAIA_FOUNDCORP_HELP', 'TXT_KEY_MISSION_GAIA_FOUNDCORP_DISABLED_HELP', 20, 0, 0, 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 202, 1, 0, 'GAIA_FOUNDCORP_UA');

-- FOUND CITY-STATE (clones MISSION_FOUND, overriding text + icon)
INSERT OR IGNORE INTO Missions
	(Type, Description, Help, DisabledHelp, IconAtlas, IconIndex,
	 EntityEventType, Time, Target, Build, Sound, HotKey, AltDown, ShiftDown, CtrlDown, HotKeyPriority, HotKeyAlt, AltDownAlt, ShiftDownAlt, CtrlDownAlt, HotKeyPriorityAlt, OrderPriority, Visible)
SELECT
	'MISSION_GAIA_FOUNDCS', 'TXT_KEY_MISSION_GAIA_FOUNDCS', 'TXT_KEY_MISSION_GAIA_FOUNDCS_HELP', 'TXT_KEY_MISSION_GAIA_FOUNDCS_DISABLED_HELP', 'UNIT_ACTION_ATLAS', 0,
	 EntityEventType, Time, Target, Build, Sound, HotKey, AltDown, ShiftDown, CtrlDown, HotKeyPriority, HotKeyAlt, AltDownAlt, ShiftDownAlt, CtrlDownAlt, HotKeyPriorityAlt, OrderPriority, Visible
FROM Missions WHERE Type = 'MISSION_FOUND';

INSERT OR IGNORE INTO Missions
	(Type, Description, Help, DisabledHelp, IconAtlas, IconIndex,
	 EntityEventType, Time, Target, Build, Sound, HotKey, AltDown, ShiftDown, CtrlDown, HotKeyPriority, HotKeyAlt, AltDownAlt, ShiftDownAlt, CtrlDownAlt, HotKeyPriorityAlt, OrderPriority, Visible)
SELECT
	'MISSION_GAIA_COASTAL_RAID', 'TXT_KEY_MISSION_GAIA_COASTAL_RAID', 'TXT_KEY_MISSION_GAIA_COASTAL_RAID_HELP', 'TXT_KEY_MISSION_GAIA_COASTAL_RAID_DISABLED_HELP', IconAtlas, IconIndex,
	 EntityEventType, Time, Target, Build, Sound, NULL, 0, 0, 0, 0, NULL, 0, 0, 0, 0, OrderPriority, Visible
FROM Missions WHERE Type = 'MISSION_PILLAGE';

-- FREE LUXURY
INSERT OR IGNORE INTO Missions
	(Type, Description, Help, DisabledHelp, EntityEventType, Time, Target, Build, Sound, HotKey, AltDown, ShiftDown, CtrlDown, HotKeyPriority, HotKeyAlt, AltDownAlt, ShiftDownAlt, CtrlDownAlt, HotKeyPriorityAlt, OrderPriority, Visible, IconIndex, IconAtlas)
VALUES ('MISSION_GAIA_FREELUX', 'TXT_KEY_MISSION_GAIA_FREELUX', 'TXT_KEY_MISSION_GAIA_FREELUX_HELP', 'TXT_KEY_MISSION_GAIA_FREELUX_DISABLED_HELP', 'ENTITY_EVENT_GREAT_EVENT', 20, 0, 0, 0, NULL, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 199, 1, 16, 'UNIT_ACTION_ATLAS');

-- FREE POLICY
INSERT OR IGNORE INTO Missions
	(Type, Description, Help, DisabledHelp, EntityEventType, Time, Target, Build, Sound, HotKey, AltDown, ShiftDown, CtrlDown, HotKeyPriority, HotKeyAlt, AltDownAlt, ShiftDownAlt, CtrlDownAlt, HotKeyPriorityAlt, OrderPriority, Visible, IconIndex, IconAtlas)
VALUES ('MISSION_GAIA_FREEPOLICY', 'TXT_KEY_MISSION_GAIA_FREEPOLICY', 'TXT_KEY_MISSION_GAIA_FREEPOLICY_HELP', 'TXT_KEY_MISSION_GAIA_FREEPOLICY_DISABLED_HELP', 'ENTITY_EVENT_GREAT_EVENT', 20, 0, 0, 0, NULL, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 199, 1, 0, 'GAIA_FREEPOLICY_UA');

-- TELEPORT TO CAPITAL
INSERT OR IGNORE INTO Missions
	(Type, Description, Help, DisabledHelp, EntityEventType, Time, Target, Build, Sound, HotKey, AltDown, ShiftDown, CtrlDown, HotKeyPriority, HotKeyAlt, AltDownAlt, ShiftDownAlt, CtrlDownAlt, HotKeyPriorityAlt, OrderPriority, Visible, IconIndex, IconAtlas)
VALUES ('MISSION_GAIA_TELEPORT_CAPITAL', 'TXT_KEY_MISSION_GAIA_TELEPORT_CAPITAL', 'TXT_KEY_MISSION_GAIA_TELEPORT_CAPITAL_HELP', 'TXT_KEY_MISSION_GAIA_TELEPORT_CAPITAL_DISABLED_HELP', 'ENTITY_EVENT_GREAT_EVENT', 20, 0, 0, 0, NULL, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 199, 1, 0, 'GAIA_TELEPORT_CAPITAL_UA');

-- TRANSFORM
INSERT OR IGNORE INTO Missions
	(Type, Description, Help, DisabledHelp, EntityEventType, Time, Target, Build, Sound, HotKey, AltDown, ShiftDown, CtrlDown, HotKeyPriority, HotKeyAlt, AltDownAlt, ShiftDownAlt, CtrlDownAlt, HotKeyPriorityAlt, OrderPriority, Visible, IconIndex, IconAtlas)
VALUES ('MISSION_GAIA_TRANSFORM', 'TXT_KEY_MISSION_GAIA_TRANSFORM', 'TXT_KEY_MISSION_GAIA_TRANSFORM_HELP', 'TXT_KEY_MISSION_GAIA_TRANSFORM_DISABLED_HELP', 'ENTITY_EVENT_GREAT_EVENT', 20, 0, 0, 0, NULL, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 199, 1, 35, 'PROMOTION_ATLAS');

-- GOODWILL MISSION
INSERT OR IGNORE INTO Missions
	(Type, Description, Help, DisabledHelp, IconAtlas, IconIndex,
	 EntityEventType, Time, Target, Build, Sound, HotKey, AltDown, ShiftDown, CtrlDown, HotKeyPriority, HotKeyAlt, AltDownAlt, ShiftDownAlt, CtrlDownAlt, HotKeyPriorityAlt, OrderPriority, Visible)
SELECT
	'MISSION_GAIA_GOODWILL', 'TXT_KEY_MISSION_GAIA_GOODWILL', 'TXT_KEY_MISSION_GAIA_GOODWILL_HELP', 'TXT_KEY_MISSION_GAIA_GOODWILL_DISABLED_HELP', IconAtlas, IconIndex,
	 EntityEventType, Time, Target, Build, Sound, NULL, 0, 0, 0, 0, NULL, 0, 0, 0, 0, OrderPriority, Visible
FROM Missions WHERE Type = 'MISSION_TRADE';

INSERT OR IGNORE INTO Missions
	(Type, Description, Help, DisabledHelp, IconAtlas, IconIndex,
	 EntityEventType, Time, Target, Build, Sound, HotKey, AltDown, ShiftDown, CtrlDown, HotKeyPriority, HotKeyAlt, AltDownAlt, ShiftDownAlt, CtrlDownAlt, HotKeyPriorityAlt, OrderPriority, Visible)
SELECT
	'MISSION_GAIA_SEALIFT', 'TXT_KEY_MISSION_GAIA_SEALIFT', 'TXT_KEY_MISSION_GAIA_SEALIFT_HELP', 'TXT_KEY_MISSION_GAIA_SEALIFT_DISABLED_HELP', IconAtlas, IconIndex,
	 EntityEventType, Time, Target, Build, Sound, NULL, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 150, 1
FROM Missions WHERE Type = 'MISSION_EMBARK';

--====================================================================================================================
-- ID CONTIGUITY
--====================================================================================================================
CREATE TABLE IDRemapper ( id INTEGER PRIMARY KEY AUTOINCREMENT, Type TEXT );
INSERT INTO IDRemapper (Type) SELECT Type FROM Missions ORDER BY ID;
UPDATE Missions SET ID = ( SELECT IDRemapper.id-1 FROM IDRemapper WHERE Missions.Type = IDRemapper.Type);
DROP TABLE IDRemapper;

UPDATE sqlite_sequence SET seq = (SELECT COUNT(ID) FROM Missions)-1 WHERE name = 'Missions';

--====================================================================================================================
-- AUTOMATES
--====================================================================================================================
INSERT OR IGNORE INTO Automates
		(Type,						Description,							Help,											DisabledHelp,											HotKey,	OrderPriority,	Command,			Automate,					Visible,	IconIndex,	IconAtlas)
VALUES	('AUTOMATE_MISSIONARY',		'TXT_KEY_GAIA_UNIT_AUTOMATION_SPREAD_RELIGION',	'TXT_KEY_GAIA_UNIT_AUTOMATION_SPREAD_RELIGION_HELP',		'TXT_KEY_GAIA_UNIT_AUTOMATION_SPREAD_RELIGION_DISABLED_HELP',		'KB_E',	1,				'COMMAND_AUTOMATE',	'AUTOMATE_MISSIONARY',		1,			43,			'UNIT_ACTION_ATLAS'),
		('AUTOMATE_ARCHAEOLOGIST',	'TXT_KEY_GAIA_UNIT_AUTOMATION_EXCAVATE','TXT_KEY_GAIA_UNIT_AUTOMATION_EXCAVATE_HELP',	'TXT_KEY_GAIA_UNIT_AUTOMATION_EXCAVATE_DISABLED_HELP',	'KB_E',	1,				'COMMAND_AUTOMATE',	'AUTOMATE_ARCHAEOLOGIST',	1,			43,			'UNIT_ACTION_ATLAS');
--====================================================================================================================
UPDATE Sapiens_DBUpdates SET Value = 1 WHERE Name = 'Missions';
