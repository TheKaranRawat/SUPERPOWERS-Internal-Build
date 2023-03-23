--==========================================================================================================================	
-- UNITS
--==========================================================================================================================		
--------------------------------------------------------------------------------------------------------------------------
-- Units
--------------------------------------------------------------------------------------------------------------------------
INSERT INTO Units 	
		(Type, 					Class,	CombatClass, PrereqTech, Cost, Combat,	Pillage, RangedCombat, Range, FaithCost, RequiresFaithPurchaseEnabled, Moves, CivilianAttackPriority, Special, Domain, DefaultUnitAI,	Description, 			 Help, 							 Strategy, 							Civilopedia, 					ShowInPedia, OneShotTourism, OneShotTourismPercentOthers, AdvancedStartCost, WorkRate, ObsoleteTech, MilitarySupport, MilitaryProduction, IgnoreBuildingDefense, Mechanized, CombatLimit,  GoldenAgeTurns,  XPValueAttack, XPValueDefense, Conscription, MoveRate, UnitArtInfo, 			 UnitFlagAtlas, 				UnitFlagIconOffset, IconAtlas,					PortraitIndex)
SELECT	'UNIT_SAS_TDF',		Class,	CombatClass, PrereqTech, '250', Combat,	Pillage, RangedCombat, Range, FaithCost, RequiresFaithPurchaseEnabled, Moves, CivilianAttackPriority, Special, Domain, DefaultUnitAI,	'TXT_KEY_UNIT_SAS_TDF', 'TXT_KEY_UNIT_SAS_TDF_HELP', 	 'TXT_KEY_UNIT_SAS_TDF_STRATEGY',  'TXT_KEY_UNIT_SAS_TDF_TEXT',	ShowInPedia, OneShotTourism, OneShotTourismPercentOthers, AdvancedStartCost, WorkRate, ObsoleteTech, MilitarySupport, MilitaryProduction, IgnoreBuildingDefense, Mechanized, CombatLimit,  GoldenAgeTurns,  XPValueAttack, XPValueDefense, Conscription, MoveRate, 'ART_DEF_UNIT_SAS_TDF',	 'SAS_TDF_FLAG',	0,					'SAS_ZELENSKYY_ICON_ATLAS',	2
FROM Units WHERE Type = 'UNIT_BAZOOKA';   	
--------------------------------------------------------------------------------------------------------------------------
-- UnitGameplay2DScripts
--------------------------------------------------------------------------------------------------------------------------
INSERT INTO UnitGameplay2DScripts 	
		(UnitType, 				SelectionSound, FirstSelectionSound)
SELECT	'UNIT_SAS_TDF',		SelectionSound, FirstSelectionSound
FROM UnitGameplay2DScripts WHERE UnitType = 'UNIT_BAZOOKA';
--------------------------------------------------------------------------------------------------------------------------
-- Unit_AITypes
--------------------------------------------------------------------------------------------------------------------------
INSERT INTO Unit_AITypes 	
		(UnitType, 				UnitAIType)
SELECT	'UNIT_SAS_TDF',		UnitAIType
FROM Unit_AITypes WHERE UnitType = 'UNIT_BAZOOKA';
--------------------------------------------------------------------------------------------------------------------------
-- Unit_Flavors
--------------------------------------------------------------------------------------------------------------------------
INSERT INTO Unit_Flavors 	
		(UnitType, 				FlavorType, Flavor)
SELECT	'UNIT_SAS_TDF',		FlavorType, Flavor
FROM Unit_Flavors WHERE UnitType = 'UNIT_BAZOOKA';
------------------------------------------------------------------------------------------------------------------------
-- Unit_ClassUpgrades
------------------------------------------------------------------------------------------------------------------------
INSERT INTO Unit_ClassUpgrades 	
		(UnitType, 				UnitClassType)
SELECT	'UNIT_SAS_TDF',		UnitClassType
FROM Unit_ClassUpgrades WHERE UnitType = 'UNIT_BAZOOKA';
--------------------------------------------------------------------------------------------------------------------------
-- Unit_FreePromotions
--------------------------------------------------------------------------------------------------------------------------
INSERT INTO Unit_FreePromotions 	
		(UnitType, 				PromotionType)
SELECT	'UNIT_SAS_TDF',		PromotionType
FROM Unit_FreePromotions WHERE UnitType = 'UNIT_BAZOOKA';

INSERT INTO Unit_FreePromotions 	
			(UnitType, 				 PromotionType)
VALUES		('UNIT_SAS_TDF', 'PROMOTION_SAS_TDF_PROMO'),
			('UNIT_SAS_TDF', 'PROMOTION_CAN_MOVE_AFTER_ATTACKING');

INSERT INTO UnitPromotions 
		(Type, 						Description, 						Help, 									Sound, 				CannotBeChosen,	NearbyEnemyCombatMod,	NearbyEnemyCombatRange, IconAtlas,  PortraitIndex,			PediaType, 			PediaEntry)
VALUES	('PROMOTION_SAS_TDF_PROMO',	'TXT_KEY_PROMOTION_SAS_TDF_PROMO',	'TXT_KEY_PROMOTION_SAS_TDF_PROMO_HELP',	'AS2D_IF_LEVELUP', 	1,	'-10',	'1',	'ABILITY_ATLAS', 				59,	'PEDIA_ATTRIBUTES', 'TXT_KEY_PROMOTION_SAS_TDF_PROMO_HELP');
--=======================================================================================================================	
-- BUILDINGS
--=======================================================================================================================	
------------------------------------------------------------------------------------------------------------------------ 	
-- Buildings
------------------------------------------------------------------------------------------------------------------------ 	
INSERT INTO Buildings 	
		(Type, 						BuildingClass,	Cost,	FreeStartEra,	HurryCostModifier,	SpecialistType,	SpecialistCount,	CultureRateModifier,	GoldMaintenance,	GreatWorkSlotType,	GreatWorkCount,	PrereqTech,	Description, 						Civilopedia, 							Help, 									Strategy,								 	ArtDefineTag,	ArtInfoCulturalVariation,	DisplayPosition, 	MinAreaSize,	ConquestProb,	PortraitIndex, 	IconAtlas)
SELECT	('BUILDING_SAS_TV_STATION'),	BuildingClass,	Cost,	FreeStartEra,	HurryCostModifier,	SpecialistType,	SpecialistCount,	CultureRateModifier,	GoldMaintenance,	GreatWorkSlotType,	'2',	PrereqTech,	('TXT_KEY_BUILDING_SAS_TV_STATION'),	('TXT_KEY_BUILDING_SAS_TV_STATION_PEDIA'),	('TXT_KEY_BUILDING_SAS_TV_STATION_HELP'),	('TXT_KEY_BUILDING_SAS_TV_STATION_STRATEGY'),	ArtDefineTag,	ArtInfoCulturalVariation,	DisplayPosition,	MinAreaSize,	0,				3, 				('SAS_ZELENSKYY_ICON_ATLAS')
FROM Buildings WHERE (Type = 'BUILDING_BROADCAST_TOWER');
--==========================================================================================================================	
-- Building_YieldChanges
--==========================================================================================================================	
INSERT INTO Building_YieldChanges
			(BuildingType, 				YieldType, Yield)
SELECT		('BUILDING_SAS_TV_STATION'),	YieldType, Yield
FROM Building_YieldChanges WHERE BuildingType = 'BUILDING_BROADCAST_TOWER';
------------------------------	
-- Building_Flavors
------------------------------		
INSERT INTO Building_Flavors 	
		(BuildingType, 				FlavorType,				Flavor)
SELECT	('BUILDING_SAS_TV_STATION'),	FlavorType,				Flavor
FROM Building_Flavors WHERE (BuildingType = 'BUILDING_BROADCAST_TOWER');
------------------------------------------------------------------------------------------------------------------------
-- BuildingClasses
------------------------------------------------------------------------------------------------------------------------	
INSERT INTO BuildingClasses
		(Type, 								DefaultBuilding, 					Description, NoLimit)
VALUES	('BUILDINGCLASS_DUMMY_SAS_TVDUMMY',	'BUILDING_DUMMY_SAS_TVDUMMY',		'TXT_KEY_BUILDING_DUMMY_SAS_TVDUMMY',	1);
--------------------------------------------------------------------------------------------------------------------------
-- Buildings
--------------------------------------------------------------------------------------------------------------------------
INSERT INTO Buildings 	
		(Type, 							BuildingClass, 							GreatWorkCount,		Cost, FaithCost,   PrereqTech,   NeverCapture,	Description, 							Help)
VALUES	('BUILDING_DUMMY_SAS_TVDUMMY', 	'BUILDINGCLASS_DUMMY_SAS_TVDUMMY', 		-1, 				-1,   -1, 		   null, 		 1,				'TXT_KEY_BUILDING_DUMMY_SAS_TVDUMMY',	'TXT_KEY_BUILDING_DUMMY_SAS_TVDUMMY_HELP');
------------------------------------------------------------------------------------------------------------------------								
-- Building_YieldModifiers																																	
------------------------------------------------------------------------------------------------------------------------		
INSERT INTO Building_YieldModifiers
		(BuildingType,					YieldType,				Yield)
VALUES	('BUILDING_DUMMY_SAS_TVDUMMY',	'YIELD_CULTURE',		2);
--==========================================================================================================================	
-- LEADERS
--==========================================================================================================================	
----------------------------------------------------------------------------------------------------------------------------
-- Leaders
--------------------------------------------------------------------------------------------------------------------------			
INSERT INTO Leaders 
		(Type, 							 Description, 							 Civilopedia, 								CivilopediaTag, 	ArtDefineTag, 									VictoryCompetitiveness, WonderCompetitiveness, 	MinorCivCompetitiveness, 	Boldness, 	DiploBalance, 	WarmongerHate, 	DenounceWillingness, 	DoFWillingness, Loyalty, 	Neediness, 	Forgiveness, 	Chattiness,	Meanness, 	IconAtlas, 						PortraitIndex)
VALUES	('LEADER_SAS_ZELENSKYY',	 'TXT_KEY_LEADER_SAS_ZELENSKYY',	'TXT_KEY_LEADER_SAS_ZELENSKYY_PEDIA',	'TXT_KEY_CIVILOPEDIA_LEADERS_SAS_ZELENSKYY',	'Sas_Zelenskyy_Scene.xml',	8, 						5, 						5, 							9, 			7, 				7, 				7, 						7, 				9, 			8, 			2, 				4, 			6, 			'SAS_ZELENSKYY_ICON_ATLAS', 1);
--------------------------------------------------------------------------------------------------------------------------		
-- Leader_MajorCivApproachBiases
--------------------------------------------------------------------------------------------------------------------------						
INSERT INTO Leader_MajorCivApproachBiases 
		(LeaderType, 					 MajorCivApproachType, 				Bias)
VALUES	('LEADER_SAS_ZELENSKYY',	'MAJOR_CIV_APPROACH_WAR', 			6),
		('LEADER_SAS_ZELENSKYY',	'MAJOR_CIV_APPROACH_HOSTILE', 		5),
		('LEADER_SAS_ZELENSKYY',	'MAJOR_CIV_APPROACH_DECEPTIVE', 	3),
		('LEADER_SAS_ZELENSKYY',	'MAJOR_CIV_APPROACH_GUARDED', 		8),
		('LEADER_SAS_ZELENSKYY',	'MAJOR_CIV_APPROACH_AFRAID', 		3),
		('LEADER_SAS_ZELENSKYY',	'MAJOR_CIV_APPROACH_FRIENDLY', 		8),
		('LEADER_SAS_ZELENSKYY',	'MAJOR_CIV_APPROACH_NEUTRAL', 		9);
--------------------------------------------------------------------------------------------------------------------------	
-- Leader_MajorCivApproachBiases
--------------------------------------------------------------------------------------------------------------------------							
INSERT INTO Leader_MinorCivApproachBiases 
		(LeaderType, 					 MinorCivApproachType, 				Bias)
VALUES	('LEADER_SAS_ZELENSKYY',	'MINOR_CIV_APPROACH_IGNORE', 		7),
		('LEADER_SAS_ZELENSKYY',	'MINOR_CIV_APPROACH_FRIENDLY', 		8),
		('LEADER_SAS_ZELENSKYY',	'MINOR_CIV_APPROACH_PROTECTIVE', 	8),
		('LEADER_SAS_ZELENSKYY',	'MINOR_CIV_APPROACH_CONQUEST', 		4),
		('LEADER_SAS_ZELENSKYY',	'MINOR_CIV_APPROACH_BULLY', 		5);
--------------------------------------------------------------------------------------------------------------------------	
-- Leader_Flavors
--------------------------------------------------------------------------------------------------------------------------							
INSERT INTO Leader_Flavors 
		(LeaderType, 					 FlavorType, 						Flavor)
VALUES	('LEADER_SAS_ZELENSKYY',	'FLAVOR_OFFENSE', 					8),
		('LEADER_SAS_ZELENSKYY',	'FLAVOR_DEFENSE', 					9),
		('LEADER_SAS_ZELENSKYY',	'FLAVOR_CITY_DEFENSE', 				6),
		('LEADER_SAS_ZELENSKYY',	'FLAVOR_MILITARY_TRAINING', 		7),
		('LEADER_SAS_ZELENSKYY',	'FLAVOR_RECON', 					5),
		('LEADER_SAS_ZELENSKYY',	'FLAVOR_RANGED', 					8),
		('LEADER_SAS_ZELENSKYY',	'FLAVOR_MOBILE', 					8),
		('LEADER_SAS_ZELENSKYY',	'FLAVOR_NAVAL', 					7),
		('LEADER_SAS_ZELENSKYY',	'FLAVOR_NAVAL_RECON', 				5),
		('LEADER_SAS_ZELENSKYY',	'FLAVOR_NAVAL_GROWTH', 				7),
		('LEADER_SAS_ZELENSKYY',	'FLAVOR_NAVAL_TILE_IMPROVEMENT', 	7),
		('LEADER_SAS_ZELENSKYY',	'FLAVOR_AIR', 						9),
		('LEADER_SAS_ZELENSKYY',	'FLAVOR_EXPANSION', 				7),
		('LEADER_SAS_ZELENSKYY',	'FLAVOR_GROWTH', 					7),
		('LEADER_SAS_ZELENSKYY',	'FLAVOR_TILE_IMPROVEMENT', 			7),
		('LEADER_SAS_ZELENSKYY',	'FLAVOR_INFRASTRUCTURE', 			7),
		('LEADER_SAS_ZELENSKYY',	'FLAVOR_PRODUCTION', 				6),
		('LEADER_SAS_ZELENSKYY',	'FLAVOR_GOLD', 						6),
		('LEADER_SAS_ZELENSKYY',	'FLAVOR_SCIENCE', 					7),
		('LEADER_SAS_ZELENSKYY',	'FLAVOR_CULTURE', 					8),
		('LEADER_SAS_ZELENSKYY',	'FLAVOR_HAPPINESS', 				7),
		('LEADER_SAS_ZELENSKYY',	'FLAVOR_GREAT_PEOPLE', 				7),
		('LEADER_SAS_ZELENSKYY',	'FLAVOR_WONDER', 					5),
		('LEADER_SAS_ZELENSKYY',	'FLAVOR_RELIGION', 					6),
		('LEADER_SAS_ZELENSKYY',	'FLAVOR_DIPLOMACY', 				8),
		('LEADER_SAS_ZELENSKYY',	'FLAVOR_SPACESHIP', 				6),
		('LEADER_SAS_ZELENSKYY',	'FLAVOR_WATER_CONNECTION', 			7),
		('LEADER_SAS_ZELENSKYY',	'FLAVOR_NUKE', 						6),
		('LEADER_SAS_ZELENSKYY',	'FLAVOR_USE_NUKE', 					6),
		('LEADER_SAS_ZELENSKYY',	'FLAVOR_ESPIONAGE', 				7),
		('LEADER_SAS_ZELENSKYY',	'FLAVOR_AIRLIFT', 					9),
		('LEADER_SAS_ZELENSKYY',	'FLAVOR_I_TRADE_DESTINATION', 		8),
		('LEADER_SAS_ZELENSKYY',	'FLAVOR_I_TRADE_ORIGIN', 			6),
		('LEADER_SAS_ZELENSKYY',	'FLAVOR_I_SEA_TRADE_ROUTE', 		8),
		('LEADER_SAS_ZELENSKYY',	'FLAVOR_I_LAND_TRADE_ROUTE', 		5),
		('LEADER_SAS_ZELENSKYY',	'FLAVOR_ARCHAEOLOGY', 				4),
		('LEADER_SAS_ZELENSKYY',	'FLAVOR_AIR_CARRIER', 				3);
--------------------------------------------------------------------------------------------------------------------------	
-- Leader_Traits
--------------------------------------------------------------------------------------------------------------------------	
INSERT INTO Leader_Traits 
		(LeaderType, 					TraitType)
VALUES	('LEADER_SAS_ZELENSKYY',	'TRAIT_SAS_ZELENSKYY');
--==========================================================================================================================	
-- TRAITS
--==========================================================================================================================	
----------------------------------------------------------------------------------------------------------------------------
-- Traits
--------------------------------------------------------------------------------------------------------------------------	
INSERT INTO Traits 
		(Type, 						 Description, 						 ShortDescription)
VALUES	('TRAIT_SAS_ZELENSKYY',  'TXT_KEY_TRAIT_SAS_ZELENSKYY',	 'TXT_KEY_TRAIT_SAS_ZELENSKYY_SHORT');
--==========================================================================================================================	
-- DIPLOMACY
--==========================================================================================================================	
----------------------------------------------------------------------------------------------------------------------------
-- Diplomacy_Responses
--------------------------------------------------------------------------------------------------------------------------
INSERT INTO Diplomacy_Responses
		(LeaderType, 					ResponseType, 								Response, 															Bias)
VALUES 	('LEADER_SAS_ZELENSKYY',	'RESPONSE_AI_DOF_BACKSTAB', 				'TXT_KEY_LEADER_SAS_ZELENSKYY_DENOUNCE_FRIEND%', 				500),
		('LEADER_SAS_ZELENSKYY',	'RESPONSE_ATTACKED_HOSTILE', 				'TXT_KEY_LEADER_SAS_ZELENSKYY_ATTACKED_HOSTILE%', 				500),
		('LEADER_SAS_ZELENSKYY',	'RESPONSE_DEFEATED', 						'TXT_KEY_LEADER_SAS_ZELENSKYY_DEFEATED%', 						500),
		('LEADER_SAS_ZELENSKYY',	'RESPONSE_DOW_GENERIC', 					'TXT_KEY_LEADER_SAS_ZELENSKYY_DOW_GENERIC%', 					500),
		('LEADER_SAS_ZELENSKYY',	'RESPONSE_FIRST_GREETING', 					'TXT_KEY_LEADER_SAS_ZELENSKYY_FIRSTGREETING%', 					500),
		('LEADER_SAS_ZELENSKYY',	'RESPONSE_RESPONSE_TO_BEING_DENOUNCED',		'TXT_KEY_LEADER_SAS_ZELENSKYY_RESPONSE_TO_BEING_DENOUNCED%', 	500),
		('LEADER_SAS_ZELENSKYY',	'RESPONSE_WORK_AGAINST_SOMEONE', 			'TXT_KEY_LEADER_SAS_ZELENSKYY_DENOUNCE%', 						500),
		('LEADER_SAS_ZELENSKYY',	'RESPONSE_WORK_WITH_US', 					'TXT_KEY_LEADER_SAS_ZELENSKYY_DEC_FRIENDSHIP%', 				500);
--==========================================================================================================================	
-- CIVILIZATIONS
--==========================================================================================================================	
----------------------------------------------------------------------------------------------------------------------------
-- Civilizations
--------------------------------------------------------------------------------------------------------------------------		
INSERT INTO Civilizations 	
		(Type, 									SoundtrackTag,  MapImage, 							DawnOfManQuote, 								DawnOfManImage,					Description,								ShortDescription,								Adjective,										Civilopedia,												CivilopediaTag,										DefaultPlayerColor,					ArtDefineTag, ArtStyleType, ArtStyleSuffix, ArtStylePrefix, IconAtlas,							PortraitIndex,	AlphaIconAtlas)
SELECT	'CIVILIZATION_SAS_ZELENSKYY',		'Russia', 		'SasZelenskyy412.dds',		'TXT_KEY_CIV_DAWN_SAS_ZELENSKYY_TEXT',	'Sas_Zelenskyy_DOM.dds',	'TXT_KEY_CIV_SAS_ZELENSKYY_DESC', 	'TXT_KEY_CIV_SAS_ZELENSKYY_SHORT_DESC',	'TXT_KEY_CIV_SAS_ZELENSKYY_ADJECTIVE',	'TXT_KEY_CIV5_SAS_ZELENSKYY_TEXT_1',		'TXT_KEY_CIV5_SAS_ZELENSKYY',		'PLAYERCOLOR_SAS_ZELENSKYY',	ArtDefineTag, ArtStyleType, ArtStyleSuffix, ArtStylePrefix, 'SAS_ZELENSKYY_ICON_ATLAS',	0,				'SAS_ZELENSKYY_ALPHA_ATLAS'
FROM Civilizations WHERE Type = 'CIVILIZATION_RUSSIA';
------------------------------------------------------------------------------------------------------------------------	
-- Civilization_SpyNames
------------------------------------------------------------------------------------------------------------------------	
INSERT INTO Civilization_SpyNames 
		(CivilizationType, 					SpyName)
VALUES	('CIVILIZATION_SAS_ZELENSKYY',	'TXT_KEY_SPY_NAME_CIV_SAS_ZELENSKYY_0'),
		('CIVILIZATION_SAS_ZELENSKYY',	'TXT_KEY_SPY_NAME_CIV_SAS_ZELENSKYY_1'),
		('CIVILIZATION_SAS_ZELENSKYY',	'TXT_KEY_SPY_NAME_CIV_SAS_ZELENSKYY_2'),
		('CIVILIZATION_SAS_ZELENSKYY',	'TXT_KEY_SPY_NAME_CIV_SAS_ZELENSKYY_3'),
		('CIVILIZATION_SAS_ZELENSKYY',	'TXT_KEY_SPY_NAME_CIV_SAS_ZELENSKYY_4'),
		('CIVILIZATION_SAS_ZELENSKYY',	'TXT_KEY_SPY_NAME_CIV_SAS_ZELENSKYY_5'),
		('CIVILIZATION_SAS_ZELENSKYY',	'TXT_KEY_SPY_NAME_CIV_SAS_ZELENSKYY_6'),
		('CIVILIZATION_SAS_ZELENSKYY',	'TXT_KEY_SPY_NAME_CIV_SAS_ZELENSKYY_7'),
		('CIVILIZATION_SAS_ZELENSKYY',	'TXT_KEY_SPY_NAME_CIV_SAS_ZELENSKYY_8'),
		('CIVILIZATION_SAS_ZELENSKYY',	'TXT_KEY_SPY_NAME_CIV_SAS_ZELENSKYY_9');
------------------------------------------------------------------------------------------------------------------------	
-- Civilization_CityNames
------------------------------------------------------------------------------------------------------------------------	
INSERT INTO Civilization_CityNames 
		(CivilizationType, 						CityName)
VALUES	('CIVILIZATION_SAS_ZELENSKYY',	'TXT_KEY_CITY_NAME_SAS_ZELENSKYY_1'),
		('CIVILIZATION_SAS_ZELENSKYY',	'TXT_KEY_CITY_NAME_SAS_ZELENSKYY_2'),
		('CIVILIZATION_SAS_ZELENSKYY',	'TXT_KEY_CITY_NAME_SAS_ZELENSKYY_3'),
		('CIVILIZATION_SAS_ZELENSKYY',	'TXT_KEY_CITY_NAME_SAS_ZELENSKYY_4'),
		('CIVILIZATION_SAS_ZELENSKYY',	'TXT_KEY_CITY_NAME_SAS_ZELENSKYY_5'),
		('CIVILIZATION_SAS_ZELENSKYY',	'TXT_KEY_CITY_NAME_SAS_ZELENSKYY_6'),
		('CIVILIZATION_SAS_ZELENSKYY',	'TXT_KEY_CITY_NAME_SAS_ZELENSKYY_7'),
		('CIVILIZATION_SAS_ZELENSKYY',	'TXT_KEY_CITY_NAME_SAS_ZELENSKYY_8'),
		('CIVILIZATION_SAS_ZELENSKYY',	'TXT_KEY_CITY_NAME_SAS_ZELENSKYY_9'),
		('CIVILIZATION_SAS_ZELENSKYY',	'TXT_KEY_CITY_NAME_SAS_ZELENSKYY_10'),
		('CIVILIZATION_SAS_ZELENSKYY',	'TXT_KEY_CITY_NAME_SAS_ZELENSKYY_11'),
		('CIVILIZATION_SAS_ZELENSKYY',	'TXT_KEY_CITY_NAME_SAS_ZELENSKYY_12'),
		('CIVILIZATION_SAS_ZELENSKYY',	'TXT_KEY_CITY_NAME_SAS_ZELENSKYY_13'),
		('CIVILIZATION_SAS_ZELENSKYY',	'TXT_KEY_CITY_NAME_SAS_ZELENSKYY_14'),
		('CIVILIZATION_SAS_ZELENSKYY',	'TXT_KEY_CITY_NAME_SAS_ZELENSKYY_15'),
		('CIVILIZATION_SAS_ZELENSKYY',	'TXT_KEY_CITY_NAME_SAS_ZELENSKYY_16'),
		('CIVILIZATION_SAS_ZELENSKYY',	'TXT_KEY_CITY_NAME_SAS_ZELENSKYY_17'),
		('CIVILIZATION_SAS_ZELENSKYY',	'TXT_KEY_CITY_NAME_SAS_ZELENSKYY_18'),
		('CIVILIZATION_SAS_ZELENSKYY',	'TXT_KEY_CITY_NAME_SAS_ZELENSKYY_19'),
		('CIVILIZATION_SAS_ZELENSKYY',	'TXT_KEY_CITY_NAME_SAS_ZELENSKYY_20'),
		('CIVILIZATION_SAS_ZELENSKYY',	'TXT_KEY_CITY_NAME_SAS_ZELENSKYY_21'),
		('CIVILIZATION_SAS_ZELENSKYY',	'TXT_KEY_CITY_NAME_SAS_ZELENSKYY_22'),
		('CIVILIZATION_SAS_ZELENSKYY',	'TXT_KEY_CITY_NAME_SAS_ZELENSKYY_23'),
		('CIVILIZATION_SAS_ZELENSKYY',	'TXT_KEY_CITY_NAME_SAS_ZELENSKYY_24'),
		('CIVILIZATION_SAS_ZELENSKYY',	'TXT_KEY_CITY_NAME_SAS_ZELENSKYY_25'),
		('CIVILIZATION_SAS_ZELENSKYY',	'TXT_KEY_CITY_NAME_SAS_ZELENSKYY_26'),
		('CIVILIZATION_SAS_ZELENSKYY',	'TXT_KEY_CITY_NAME_SAS_ZELENSKYY_27'),
		('CIVILIZATION_SAS_ZELENSKYY',	'TXT_KEY_CITY_NAME_SAS_ZELENSKYY_28'),
		('CIVILIZATION_SAS_ZELENSKYY',	'TXT_KEY_CITY_NAME_SAS_ZELENSKYY_29'),
		('CIVILIZATION_SAS_ZELENSKYY',	'TXT_KEY_CITY_NAME_SAS_ZELENSKYY_30'),
		('CIVILIZATION_SAS_ZELENSKYY',	'TXT_KEY_CITY_NAME_SAS_ZELENSKYY_31'),
		('CIVILIZATION_SAS_ZELENSKYY',	'TXT_KEY_CITY_NAME_SAS_ZELENSKYY_32'),
		('CIVILIZATION_SAS_ZELENSKYY',	'TXT_KEY_CITY_NAME_SAS_ZELENSKYY_33'),
		('CIVILIZATION_SAS_ZELENSKYY',	'TXT_KEY_CITY_NAME_SAS_ZELENSKYY_34'),
		('CIVILIZATION_SAS_ZELENSKYY',	'TXT_KEY_CITY_NAME_SAS_ZELENSKYY_35'),
		('CIVILIZATION_SAS_ZELENSKYY',	'TXT_KEY_CITY_NAME_SAS_ZELENSKYY_36'),
		('CIVILIZATION_SAS_ZELENSKYY',	'TXT_KEY_CITY_NAME_SAS_ZELENSKYY_37'),
		('CIVILIZATION_SAS_ZELENSKYY',	'TXT_KEY_CITY_NAME_SAS_ZELENSKYY_38'),
		('CIVILIZATION_SAS_ZELENSKYY',	'TXT_KEY_CITY_NAME_SAS_ZELENSKYY_39'),
		('CIVILIZATION_SAS_ZELENSKYY',	'TXT_KEY_CITY_NAME_SAS_ZELENSKYY_40'),
		('CIVILIZATION_SAS_ZELENSKYY',	'TXT_KEY_CITY_NAME_SAS_ZELENSKYY_41'),
		('CIVILIZATION_SAS_ZELENSKYY',	'TXT_KEY_CITY_NAME_SAS_ZELENSKYY_42'),
		('CIVILIZATION_SAS_ZELENSKYY',	'TXT_KEY_CITY_NAME_SAS_ZELENSKYY_43'),
		('CIVILIZATION_SAS_ZELENSKYY',	'TXT_KEY_CITY_NAME_SAS_ZELENSKYY_44'),
		('CIVILIZATION_SAS_ZELENSKYY',	'TXT_KEY_CITY_NAME_SAS_ZELENSKYY_45'),
		('CIVILIZATION_SAS_ZELENSKYY',	'TXT_KEY_CITY_NAME_SAS_ZELENSKYY_46'),
		('CIVILIZATION_SAS_ZELENSKYY',	'TXT_KEY_CITY_NAME_SAS_ZELENSKYY_47'),
		('CIVILIZATION_SAS_ZELENSKYY',	'TXT_KEY_CITY_NAME_SAS_ZELENSKYY_48'),
		('CIVILIZATION_SAS_ZELENSKYY',	'TXT_KEY_CITY_NAME_SAS_ZELENSKYY_49'),
		('CIVILIZATION_SAS_ZELENSKYY',	'TXT_KEY_CITY_NAME_SAS_ZELENSKYY_50'),
		('CIVILIZATION_SAS_ZELENSKYY',	'TXT_KEY_CITY_NAME_SAS_ZELENSKYY_51'),
		('CIVILIZATION_SAS_ZELENSKYY',	'TXT_KEY_CITY_NAME_SAS_ZELENSKYY_52'),
		('CIVILIZATION_SAS_ZELENSKYY',	'TXT_KEY_CITY_NAME_SAS_ZELENSKYY_53'),
		('CIVILIZATION_SAS_ZELENSKYY',	'TXT_KEY_CITY_NAME_SAS_ZELENSKYY_54'),
		('CIVILIZATION_SAS_ZELENSKYY',	'TXT_KEY_CITY_NAME_SAS_ZELENSKYY_55'),
		('CIVILIZATION_SAS_ZELENSKYY',	'TXT_KEY_CITY_NAME_SAS_ZELENSKYY_56'),
		('CIVILIZATION_SAS_ZELENSKYY',	'TXT_KEY_CITY_NAME_SAS_ZELENSKYY_57'),
		('CIVILIZATION_SAS_ZELENSKYY',	'TXT_KEY_CITY_NAME_SAS_ZELENSKYY_58'),
		('CIVILIZATION_SAS_ZELENSKYY',	'TXT_KEY_CITY_NAME_SAS_ZELENSKYY_59'),
		('CIVILIZATION_SAS_ZELENSKYY',	'TXT_KEY_CITY_NAME_SAS_ZELENSKYY_60');
--------------------------------------------------------------------------------------------------------------------------	
-- Civilization_FreeBuildingClasses
--------------------------------------------------------------------------------------------------------------------------			
INSERT INTO Civilization_FreeBuildingClasses 
		(CivilizationType, 					BuildingClassType)
SELECT	'CIVILIZATION_SAS_ZELENSKYY', 	BuildingClassType
FROM Civilization_FreeBuildingClasses WHERE CivilizationType = 'CIVILIZATION_RUSSIA';
--------------------------------------------------------------------------------------------------------------------------		
-- Civilization_FreeTechs
--------------------------------------------------------------------------------------------------------------------------			
INSERT INTO Civilization_FreeTechs 
		(CivilizationType, 					TechType)
SELECT	'CIVILIZATION_SAS_ZELENSKYY', 	TechType
FROM Civilization_FreeTechs WHERE CivilizationType = 'CIVILIZATION_RUSSIA';
--------------------------------------------------------------------------------------------------------------------------	
-- Civilization_FreeUnits
--------------------------------------------------------------------------------------------------------------------------		
INSERT INTO Civilization_FreeUnits 
		(CivilizationType, 					UnitClassType, Count, UnitAIType)
SELECT	'CIVILIZATION_SAS_ZELENSKYY', 	UnitClassType, Count, UnitAIType
FROM Civilization_FreeUnits WHERE CivilizationType = 'CIVILIZATION_RUSSIA';
--------------------------------------------------------------------------------------------------------------------------	
-- Civilization_Leaders
--------------------------------------------------------------------------------------------------------------------------		
INSERT INTO Civilization_Leaders 
		(CivilizationType, 					LeaderheadType)
VALUES	('CIVILIZATION_SAS_ZELENSKYY',	'LEADER_SAS_ZELENSKYY');
--------------------------------------------------------------------------------------------------------------------------	
-- Civilization_UnitClassOverrides 
--------------------------------------------------------------------------------------------------------------------------		
INSERT INTO Civilization_UnitClassOverrides 
		(CivilizationType, 					UnitClassType, 				UnitType)
VALUES	('CIVILIZATION_SAS_ZELENSKYY', 	'UNITCLASS_BAZOOKA',			'UNIT_SAS_TDF');
--------------------------------------------------------------------------------------------------------------------------	
-- Civilization_BuildingClassOverrides 
--------------------------------------------------------------------------------------------------------------------------		
INSERT INTO Civilization_BuildingClassOverrides 
		(CivilizationType, 					BuildingClassType, 			BuildingType)
VALUES	('CIVILIZATION_SAS_ZELENSKYY', 	'BUILDINGCLASS_BROADCAST_TOWER',	'BUILDING_SAS_TV_STATION');
--------------------------------	
-- Civilization_Start_Region_Priority
--------------------------------	
INSERT INTO Civilization_Start_Region_Priority 
		(CivilizationType, 				RegionType)
VALUES	('CIVILIZATION_SAS_ZELENSKYY',	'REGION_GRASS');
------------------------------------------------------------------------------------------------------------------------	
-- Civilization_Religions
------------------------------------------------------------------------------------------------------------------------			
INSERT INTO Civilization_Religions 
		(CivilizationType, 							ReligionType)
VALUES	('CIVILIZATION_SAS_ZELENSKYY',		'RELIGION_ORTHODOXY');