-- written by GAIA using Notepad++
CREATE TABLE IF NOT EXISTS Sapiens_DBUpdates (Name TEXT PRIMARY KEY, Value INTEGER DEFAULT 0);
INSERT OR IGNORE INTO Sapiens_DBUpdates (Name) VALUES ('AI_Tactics');
--====================================================================================================================
-- NEW UNIT AI INFOS
--====================================================================================================================
INSERT OR IGNORE INTO UnitAIInfos
		(Type,						Description)
VALUES	('UNITAI_GAIA_EMISSARY',	'UNITAI_GAIA_EMISSARY'),
		('UNITAI_GAIA_ENVOY',		'UNITAI_GAIA_ENVOY'),
		('UNITAI_GAIA_THINKER',		'UNITAI_GAIA_THINKER'),
		('UNITAI_GAIA_COLONIST',	'UNITAI_GAIA_COLONIST'),
		('UNITAI_GAIA_DIRECTOR',	'UNITAI_GAIA_DIRECTOR'),
		('UNITAI_GAIA_DEVELOPER',	'UNITAI_GAIA_DEVELOPER');

--====================================================================================================================
-- EXTRA UNIT AI ROLES
--====================================================================================================================
INSERT INTO Unit_AITypes (UnitType, UnitAIType) VALUES
('UNIT_SHOSHONE_PATHFINDER',	'UNITAI_EXPLORE'),
('UNIT_MACHINE_GUN',			'UNITAI_DEFENSE'),
('UNIT_PARATROOPER',			'UNITAI_ATTACK'),
('UNIT_PARATROOPER',			'UNITAI_DEFENSE'),
('UNIT_XCOM_SQUAD',				'UNITAI_ATTACK'),
('UNIT_XCOM_SQUAD',				'UNITAI_FAST_ATTACK'),
('UNIT_XCOM_SQUAD',				'UNITAI_DEFENSE'),
('UNIT_MECH',					'UNITAI_DEFENSE'),
('UNIT_MECH',					'UNITAI_COUNTER');

--====================================================================================================================
-- MULTI-UNIT FORMATIONS
--====================================================================================================================
-- GLOBAL FIX
UPDATE MultiUnitFormation_SlotEntries SET SecondaryUnitType = 'UNITAI_RANGED'
	WHERE MultiUnitPositionType = 'MUPOSITION_BOMBARD' AND SecondaryUnitType = 'UNITAI_DEFENSE';

-- Bigger City Attack Force
UPDATE MultiUnitFormation_SlotEntries SET SecondaryUnitType = 'UNITAI_DEFENSE'
	WHERE MultiUnitFormationType = 'MUFORMATION_BIGGER_CITY_ATTACK_FORCE' AND MultiUnitPositionType = 'MUPOSITION_BOMBARD' AND PrimaryUnitType = 'UNITAI_ATTACK' AND SecondaryUnitType = 'UNITAI_RANGED';
UPDATE MultiUnitFormation_SlotEntries SET PrimaryUnitType = 'UNITAI_DEFENSE'
	WHERE MultiUnitFormationType = 'MUFORMATION_BIGGER_CITY_ATTACK_FORCE' AND MultiUnitPositionType = 'MUPOSITION_FRONT_LINE' AND PrimaryUnitType = 'UNITAI_RANGED';
INSERT INTO MultiUnitFormation_SlotEntries (MultiUnitFormationType, PrimaryUnitType, SecondaryUnitType, MultiUnitPositionType, RequiredSlot) VALUES
('MUFORMATION_BIGGER_CITY_ATTACK_FORCE', 'UNITAI_ATTACK', 'UNITAI_DEFENSE', 'MUPOSITION_FRONT_LINE', 0);

--====================================================================================================================
-- BASIC CITY ATTACK FORCE
--====================================================================================================================
DELETE FROM MultiUnitFormation_SlotEntries WHERE MultiUnitFormationType = 'MUFORMATION_BASIC_CITY_ATTACK_FORCE';
INSERT INTO MultiUnitFormation_SlotEntries (MultiUnitFormationType, PrimaryUnitType, SecondaryUnitType, MultiUnitPositionType, RequiredSlot) VALUES
('MUFORMATION_BASIC_CITY_ATTACK_FORCE', 'UNITAI_CITY_BOMBARD', 'UNITAI_RANGED',      'MUPOSITION_BOMBARD',           1),
('MUFORMATION_BASIC_CITY_ATTACK_FORCE', 'UNITAI_CITY_BOMBARD', 'UNITAI_RANGED',      'MUPOSITION_BOMBARD',           1),
('MUFORMATION_BASIC_CITY_ATTACK_FORCE', 'UNITAI_CITY_BOMBARD', 'UNITAI_RANGED',      'MUPOSITION_BOMBARD',           0),
('MUFORMATION_BASIC_CITY_ATTACK_FORCE', 'UNITAI_CITY_BOMBARD', 'UNITAI_RANGED',      'MUPOSITION_BOMBARD',           0),
('MUFORMATION_BASIC_CITY_ATTACK_FORCE', 'UNITAI_CITY_BOMBARD', 'UNITAI_CITY_BOMBARD','MUPOSITION_BOMBARD',           0),
('MUFORMATION_BASIC_CITY_ATTACK_FORCE', 'UNITAI_CITY_BOMBARD', 'UNITAI_CITY_BOMBARD','MUPOSITION_BOMBARD',           0),
('MUFORMATION_BASIC_CITY_ATTACK_FORCE', 'UNITAI_ATTACK',       'UNITAI_DEFENSE',     'MUPOSITION_FRONT_LINE',        1),
('MUFORMATION_BASIC_CITY_ATTACK_FORCE', 'UNITAI_ATTACK',       'UNITAI_COUNTER',     'MUPOSITION_FRONT_LINE',        1),
('MUFORMATION_BASIC_CITY_ATTACK_FORCE', 'UNITAI_ATTACK',       'UNITAI_COUNTER',     'MUPOSITION_FRONT_LINE',        1),
('MUFORMATION_BASIC_CITY_ATTACK_FORCE', 'UNITAI_ATTACK',       'UNITAI_DEFENSE',     'MUPOSITION_FRONT_LINE',        1),
('MUFORMATION_BASIC_CITY_ATTACK_FORCE', 'UNITAI_ATTACK',       'UNITAI_DEFENSE',     'MUPOSITION_FRONT_LINE',        0),
('MUFORMATION_BASIC_CITY_ATTACK_FORCE', 'UNITAI_ATTACK',       'UNITAI_DEFENSE',     'MUPOSITION_FRONT_LINE',        0),
('MUFORMATION_BASIC_CITY_ATTACK_FORCE', 'UNITAI_GENERAL',      'UNITAI_GENERAL',     'MUPOSITION_CIVILIAN_SUPPORT',  0);

--====================================================================================================================
-- CITY STATE ATTACK FORCE (rebuild)
--====================================================================================================================
DELETE FROM MultiUnitFormation_SlotEntries WHERE MultiUnitFormationType = 'MUFORMATION_CITY_STATE_ATTACK_FORCE';
INSERT INTO MultiUnitFormation_SlotEntries (MultiUnitFormationType, PrimaryUnitType, SecondaryUnitType, MultiUnitPositionType, RequiredSlot) VALUES
('MUFORMATION_CITY_STATE_ATTACK_FORCE', 'UNITAI_CITY_BOMBARD', 'UNITAI_RANGED',       'MUPOSITION_BOMBARD',          1),
('MUFORMATION_CITY_STATE_ATTACK_FORCE', 'UNITAI_CITY_BOMBARD', 'UNITAI_RANGED',       'MUPOSITION_BOMBARD',          1),
('MUFORMATION_CITY_STATE_ATTACK_FORCE', 'UNITAI_CITY_BOMBARD', 'UNITAI_RANGED',       'MUPOSITION_BOMBARD',          0),
('MUFORMATION_CITY_STATE_ATTACK_FORCE', 'UNITAI_CITY_BOMBARD', 'UNITAI_CITY_BOMBARD', 'MUPOSITION_BOMBARD',          0),
('MUFORMATION_CITY_STATE_ATTACK_FORCE', 'UNITAI_CITY_BOMBARD', 'UNITAI_CITY_BOMBARD', 'MUPOSITION_BOMBARD',          0),
('MUFORMATION_CITY_STATE_ATTACK_FORCE', 'UNITAI_ATTACK',       'UNITAI_DEFENSE',      'MUPOSITION_FRONT_LINE',       1),
('MUFORMATION_CITY_STATE_ATTACK_FORCE', 'UNITAI_ATTACK',       'UNITAI_DEFENSE',      'MUPOSITION_FRONT_LINE',       1),
('MUFORMATION_CITY_STATE_ATTACK_FORCE', 'UNITAI_ATTACK',       'UNITAI_DEFENSE',      'MUPOSITION_FRONT_LINE',       1),
('MUFORMATION_CITY_STATE_ATTACK_FORCE', 'UNITAI_ATTACK',       'UNITAI_DEFENSE',      'MUPOSITION_FRONT_LINE',       0),
('MUFORMATION_CITY_STATE_ATTACK_FORCE', 'UNITAI_ATTACK',       'UNITAI_DEFENSE',      'MUPOSITION_FRONT_LINE',       0),
('MUFORMATION_CITY_STATE_ATTACK_FORCE', 'UNITAI_ATTACK',       'UNITAI_DEFENSE',      'MUPOSITION_FRONT_LINE',       0),
('MUFORMATION_CITY_STATE_ATTACK_FORCE', 'UNITAI_GENERAL',      'UNITAI_GENERAL',      'MUPOSITION_CIVILIAN_SUPPORT', 0);

--====================================================================================================================
-- FAST PILLAGERS
--====================================================================================================================
DELETE FROM MultiUnitFormation_SlotEntries WHERE MultiUnitFormationType = 'MUFORMATION_FAST_PILLAGERS';
INSERT INTO MultiUnitFormation_SlotEntries (MultiUnitFormationType, PrimaryUnitType, SecondaryUnitType, MultiUnitPositionType, RequiredSlot) VALUES
('MUFORMATION_FAST_PILLAGERS', 'UNITAI_FAST_ATTACK', 'UNITAI_FAST_ATTACK', 'MUPOSITION_FRONT_LINE', 1),
('MUFORMATION_FAST_PILLAGERS', 'UNITAI_FAST_ATTACK', 'UNITAI_FAST_ATTACK', 'MUPOSITION_FRONT_LINE', 0),
('MUFORMATION_FAST_PILLAGERS', 'UNITAI_FAST_ATTACK', 'UNITAI_FAST_ATTACK', 'MUPOSITION_FRONT_LINE', 0);

--====================================================================================================================
-- ANTI-BARBARIAN TEAM
--====================================================================================================================
DELETE FROM MultiUnitFormation_SlotEntries WHERE MultiUnitFormationType = 'MUFORMATION_ANTI_BARBARIAN_TEAM';
INSERT INTO MultiUnitFormation_SlotEntries (MultiUnitFormationType, PrimaryUnitType, SecondaryUnitType, MultiUnitPositionType, RequiredSlot) VALUES
('MUFORMATION_ANTI_BARBARIAN_TEAM', 'UNITAI_RANGED',      'UNITAI_CITY_BOMBARD', 'MUPOSITION_BOMBARD',    0),
('MUFORMATION_ANTI_BARBARIAN_TEAM', 'UNITAI_FAST_ATTACK', 'UNITAI_DEFENSE',      'MUPOSITION_FRONT_LINE', 1),
('MUFORMATION_ANTI_BARBARIAN_TEAM', 'UNITAI_FAST_ATTACK', 'UNITAI_DEFENSE',      'MUPOSITION_FRONT_LINE', 0),
('MUFORMATION_ANTI_BARBARIAN_TEAM', 'UNITAI_FAST_ATTACK', 'UNITAI_DEFENSE',      'MUPOSITION_FRONT_LINE', 0);

--====================================================================================================================
-- MORE ranged-slot secondary fixes
--====================================================================================================================
UPDATE MultiUnitFormation_SlotEntries SET SecondaryUnitType = 'UNITAI_RANGED'
	WHERE MultiUnitFormationType = 'MUFORMATION_RAPID_RESPONSE_FORCE' AND PrimaryUnitType = 'UNITAI_RANGED';
UPDATE MultiUnitFormation_SlotEntries SET SecondaryUnitType = 'UNITAI_CITY_BOMBARD'
	WHERE MultiUnitFormationType = 'MUFORMATION_CLOSE_CITY_DEFENSE' AND PrimaryUnitType = 'UNITAI_RANGED';

--====================================================================================================================
-- SMALL CITY ATTACK FORCE (rebuild)
--====================================================================================================================
DELETE FROM MultiUnitFormation_SlotEntries WHERE MultiUnitFormationType = 'MUFORMATION_SMALL_CITY_ATTACK_FORCE';
INSERT INTO MultiUnitFormation_SlotEntries (MultiUnitFormationType, PrimaryUnitType, SecondaryUnitType, MultiUnitPositionType, RequiredSlot) VALUES
('MUFORMATION_SMALL_CITY_ATTACK_FORCE', 'UNITAI_CITY_BOMBARD', 'UNITAI_RANGED',       'MUPOSITION_BOMBARD',          1),
('MUFORMATION_SMALL_CITY_ATTACK_FORCE', 'UNITAI_CITY_BOMBARD', 'UNITAI_RANGED',       'MUPOSITION_BOMBARD',          0),
('MUFORMATION_SMALL_CITY_ATTACK_FORCE', 'UNITAI_CITY_BOMBARD', 'UNITAI_RANGED',       'MUPOSITION_BOMBARD',          1),
('MUFORMATION_SMALL_CITY_ATTACK_FORCE', 'UNITAI_CITY_BOMBARD', 'UNITAI_CITY_BOMBARD', 'MUPOSITION_BOMBARD',          0),
('MUFORMATION_SMALL_CITY_ATTACK_FORCE', 'UNITAI_ATTACK',       'UNITAI_DEFENSE',      'MUPOSITION_FRONT_LINE',       1),
('MUFORMATION_SMALL_CITY_ATTACK_FORCE', 'UNITAI_ATTACK',       'UNITAI_DEFENSE',      'MUPOSITION_FRONT_LINE',       1),
('MUFORMATION_SMALL_CITY_ATTACK_FORCE', 'UNITAI_ATTACK',       'UNITAI_DEFENSE',      'MUPOSITION_FRONT_LINE',       0),
('MUFORMATION_SMALL_CITY_ATTACK_FORCE', 'UNITAI_ATTACK',       'UNITAI_DEFENSE',      'MUPOSITION_FRONT_LINE',       0),
('MUFORMATION_SMALL_CITY_ATTACK_FORCE', 'UNITAI_ATTACK',       'UNITAI_DEFENSE',      'MUPOSITION_FRONT_LINE',       0),
('MUFORMATION_SMALL_CITY_ATTACK_FORCE', 'UNITAI_GENERAL',      'UNITAI_GENERAL',      'MUPOSITION_CIVILIAN_SUPPORT', 0);

--====================================================================================================================
-- EARLY RUSH
--====================================================================================================================
DELETE FROM MultiUnitFormation_SlotEntries WHERE MultiUnitFormationType = 'MUFORMATION_EARLY_RUSH';
INSERT INTO MultiUnitFormation_SlotEntries (MultiUnitFormationType, PrimaryUnitType, SecondaryUnitType, MultiUnitPositionType, RequiredSlot) VALUES
('MUFORMATION_EARLY_RUSH', 'UNITAI_ATTACK',       'UNITAI_DEFENSE', 'MUPOSITION_FRONT_LINE',       1),
('MUFORMATION_EARLY_RUSH', 'UNITAI_ATTACK',       'UNITAI_DEFENSE', 'MUPOSITION_FRONT_LINE',       1),
('MUFORMATION_EARLY_RUSH', 'UNITAI_ATTACK',       'UNITAI_DEFENSE', 'MUPOSITION_FRONT_LINE',       1),
('MUFORMATION_EARLY_RUSH', 'UNITAI_ATTACK',       'UNITAI_DEFENSE', 'MUPOSITION_FRONT_LINE',       0),
('MUFORMATION_EARLY_RUSH', 'UNITAI_ATTACK',       'UNITAI_DEFENSE', 'MUPOSITION_FRONT_LINE',       0),
('MUFORMATION_EARLY_RUSH', 'UNITAI_ATTACK',       'UNITAI_DEFENSE', 'MUPOSITION_FRONT_LINE',       0),
('MUFORMATION_EARLY_RUSH', 'UNITAI_CITY_BOMBARD', 'UNITAI_RANGED',  'MUPOSITION_BOMBARD',          1),
('MUFORMATION_EARLY_RUSH', 'UNITAI_CITY_BOMBARD', 'UNITAI_RANGED',  'MUPOSITION_BOMBARD',          1),
('MUFORMATION_EARLY_RUSH', 'UNITAI_CITY_BOMBARD', 'UNITAI_RANGED',  'MUPOSITION_BOMBARD',          0),
('MUFORMATION_EARLY_RUSH', 'UNITAI_CITY_BOMBARD', 'UNITAI_RANGED',  'MUPOSITION_BOMBARD',          0),
('MUFORMATION_EARLY_RUSH', 'UNITAI_GENERAL',      'UNITAI_GENERAL', 'MUPOSITION_CIVILIAN_SUPPORT', 0);

--====================================================================================================================
-- TACTICAL MOVES
--====================================================================================================================

-- OPERATIONS CAN NOW RECRUIT FROM THESE MOVES
UPDATE TacticalMoves SET OperationsCanRecruit = 1 WHERE Type = 'TACTICAL_PILLAGE';
UPDATE TacticalMoves SET OperationsCanRecruit = 1 WHERE Type = 'TACTICAL_SAFE_BOMBARDS';
UPDATE TacticalMoves SET OperationsCanRecruit = 1 WHERE Type = 'TACTICAL_BASTION_ALREADY_THERE';
UPDATE TacticalMoves SET OperationsCanRecruit = 1 WHERE Type = 'TACTICAL_GARRISON_ALREADY_THERE';
UPDATE TacticalMoves SET OperationsCanRecruit = 1 WHERE Type = 'TACTICAL_GUARD_IMPROVEMENT_ALREADY_THERE';
UPDATE TacticalMoves SET OperationsCanRecruit = 1 WHERE Type = 'TACTICAL_PILLAGE_CITADEL';
UPDATE TacticalMoves SET OperationsCanRecruit = 1 WHERE Type = 'TACTICAL_PILLAGE_RESOURCE';
UPDATE TacticalMoves SET OperationsCanRecruit = 1 WHERE Type = 'TACTICAL_PILLAGE_CITADEL_NEXT_TURN';
UPDATE TacticalMoves SET OperationsCanRecruit = 1 WHERE Type = 'TACTICAL_PILLAGE_RESOURCE_NEXT_TURN';
UPDATE TacticalMoves SET OperationsCanRecruit = 1 WHERE Type = 'TACTICAL_PILLAGE_NEXT_TURN';

-- PRIORITY RE-ORDERING
UPDATE TacticalMoves SET Priority = 20 WHERE Type = 'TACTICAL_TO_SAFETY';
UPDATE TacticalMoves SET Priority = 13 WHERE Type = 'TACTICAL_BARBARIAN_CAMP';
UPDATE TacticalMoves SET Priority = 12 WHERE Type = 'TACTICAL_DAMAGE_CITY';
UPDATE TacticalMoves SET Priority = 11 WHERE Type = 'TACTICAL_ATTRIT_LOW_UNIT';
UPDATE TacticalMoves SET Priority = 10 WHERE Type = 'TACTICAL_HEAL';
--====================================================================================================================
UPDATE Sapiens_DBUpdates SET Value = 1 WHERE Name = 'AI_Tactics';
