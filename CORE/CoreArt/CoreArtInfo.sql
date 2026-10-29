-- written by GAIA using Notepad++
CREATE TABLE IF NOT EXISTS Sapiens_DBUpdates (Name TEXT PRIMARY KEY, Value INTEGER DEFAULT 0);
INSERT OR IGNORE INTO Sapiens_DBUpdates (Name) VALUES ('CoreArtInfo');
--====================================================================================================================
-- FONT ICONS
--====================================================================================================================
INSERT OR REPLACE INTO IconFontTextures (IconFontTexture, IconFontTextureFile) VALUES
	('ICON_FONT_TEXTURE_GAIA_FONT_ATLAS', 	'GAIA_FontIcons'),
	('ICON_FONT_TEXTURE_GAIA_INFINITY', 	'Font_GAIA_Infinity'),
	('ICON_FONT_TEXTURE_GAIA_HOLY_ARTIFACT','Font_GAIA_HolyArtifact'),
	('ICON_FONT_TEXTURE_GAIA_CORPORATION',	'Font_GAIA_Corporation'),
	('ICON_FONT_TEXTURE_GAIA_CINEMA',		'Font_GAIA_Cinema'),
	('ICON_FONT_TEXTURE_GAIA_VIDEOGAME',	'Font_GAIA_Videogame');

INSERT OR REPLACE INTO IconFontMapping (IconName, IconFontTexture,	IconMapping) VALUES
	('ICON_INFINITY', 				'ICON_FONT_TEXTURE_GAIA_INFINITY',			1),
	('ICON_AIRPORT', 				'ICON_FONT_TEXTURE_GAIA_FONT_ATLAS',		1),
	('ICON_AUTOMATED', 				'ICON_FONT_TEXTURE_GAIA_FONT_ATLAS',		3),
	('ICON_CARAVAN', 				'ICON_FONT_TEXTURE_GAIA_FONT_ATLAS',		5),
	('ICON_CARGO_SHIP', 			'ICON_FONT_TEXTURE_GAIA_FONT_ATLAS',		6),
	('ICON_WONDER', 				'ICON_FONT_TEXTURE_GAIA_FONT_ATLAS',		7),
	('ICON_VICTORY_RELIGIOUS', 		'ICON_FONT_TEXTURE_GAIA_FONT_ATLAS',		8),
	('ICON_GREATMUSIC', 			'ICON_FONT_TEXTURE_GAIA_FONT_ATLAS',		9),
	('ICON_GREATWRITING', 			'ICON_FONT_TEXTURE_GAIA_FONT_ATLAS',		10),
	('ICON_GREATART', 				'ICON_FONT_TEXTURE_GAIA_FONT_ATLAS',		11),
	('ICON_ARTIFACT', 				'ICON_FONT_TEXTURE_GAIA_FONT_ATLAS',		12),
	('ICON_SAPPED', 				'ICON_FONT_TEXTURE_GAIA_FONT_ATLAS',		13),
	('ICON_FORT', 					'ICON_FONT_TEXTURE_GAIA_FONT_ATLAS',		14),
	('ICON_VISION', 				'ICON_FONT_TEXTURE_GAIA_FONT_ATLAS',		15),
	('ICON_VICTORY_ECONOMIC', 		'ICON_FONT_TEXTURE_GAIA_FONT_ATLAS',		16),
	('ICON_GAIA_HOLY_ARTIFACT',		'ICON_FONT_TEXTURE_GAIA_HOLY_ARTIFACT',		1),
	('ICON_GAIA_CORPORATION',		'ICON_FONT_TEXTURE_GAIA_CORPORATION',		1),
	('ICON_GAIA_CINEMA',			'ICON_FONT_TEXTURE_GAIA_CINEMA',			1),
	('ICON_GAIA_VIDEOGAME',			'ICON_FONT_TEXTURE_GAIA_VIDEOGAME',			1);

--====================================================================================================================
-- ICON ATLASES
--====================================================================================================================
INSERT INTO IconTextureAtlases
	(Atlas,					IconSize,	Filename,						IconsPerRow,	IconsPerColumn) VALUES
	('GAIA_BLOCKBUSTER_UA',	64,			'GAIA_Blockbuster_UA64.dds',	1,				1),
	('GAIA_BLOCKBUSTER_UA',	45,			'GAIA_Blockbuster_UA45.dds',	1,				1),

	('GAIA_CYBERATTACK_UA',	64,			'GAIA_CyberAttack_UA64.dds',	1,				1),
	('GAIA_CYBERATTACK_UA',	45,			'GAIA_CyberAttack_UA45.dds',	1,				1),

	('GAIA_FOUNDCORP_UA',	64,			'GAIA_FoundCorp_UA64.dds',		1,				1),
	('GAIA_FOUNDCORP_UA',	45,			'GAIA_FoundCorp_UA45.dds',		1,				1),

	('GAIA_FREEPOLICY_UA',	64,			'GAIA_FreePolicy_UA64.dds',		1,				1),
	('GAIA_FREEPOLICY_UA',	45,			'GAIA_FreePolicy_UA45.dds',		1,				1),

	('GAIA_TELEPORT_CAPITAL_UA',	256,		'GAIA_TeleportCap_256.dds',		1,				1),
	('GAIA_TELEPORT_CAPITAL_UA',	64,			'GAIA_TeleportCap_064.dds',		1,				1),
	('GAIA_TELEPORT_CAPITAL_UA',	45,			'GAIA_TeleportCap_045.dds',		1,				1),
	('GAIA_TELEPORT_CAPITAL_UA',	32,			'GAIA_TeleportCap_032.dds',		1,				1);

DELETE FROM IconTextureAtlases WHERE Atlas = 'ABILITY_ATLAS' AND IconSize = 45;
INSERT INTO IconTextureAtlases
	(Atlas,					IconSize,	Filename,						IconsPerRow,	IconsPerColumn) VALUES
	('ABILITY_ATLAS',		45,			'Promotions360.dds',			8,				8);

--====================================================================================================================
-- AUDIO
--====================================================================================================================
INSERT OR IGNORE INTO Audio_Sounds (SoundID, Filename, LoadType) VALUES
('SND_GW_GAIA_RELIGION',	'GAIA_GW_Religion',		'DynamicResident'),
('SND_GW_GAIA_CORPORATION',	'GAIA_GW_Corporation',	'DynamicResident'),
('SND_GW_GAIA_CINEMA',		'GAIA_GW_Cinema',		'DynamicResident'),
('SND_GW_GAIA_VIDEOGAME',	'GAIA_GW_Videogame',	'DynamicResident');

INSERT OR IGNORE INTO Audio_2DSounds (ScriptID, SoundID, SoundType, TaperSoundtrackVolume) VALUES
('AS2D_GW_GAIA_RELIGION',		'SND_GW_GAIA_RELIGION',		'GAME_MUSIC_STINGS',	0.0),
('AS2D_GW_GAIA_CORPORATION',	'SND_GW_GAIA_CORPORATION',	'GAME_MUSIC_STINGS',	0.0),
('AS2D_GW_GAIA_CINEMA',			'SND_GW_GAIA_CINEMA',		'GAME_MUSIC_STINGS',	0.0),
('AS2D_GW_GAIA_VIDEOGAME',		'SND_GW_GAIA_VIDEOGAME',	'GAME_MUSIC_STINGS',	0.0);

--====================================================================================================================
-- PLAYER COLORS
--====================================================================================================================
DELETE FROM Colors WHERE Type = 'COLOR_PLAYER_ETHIOPIA_BACKGROUND';
INSERT INTO Colors (Type, Red, Green, Blue, Alpha) VALUES

-- Ethiopia
	('COLOR_PLAYER_ETHIOPIA_BACKGROUND', 0.1293, 0.3271, 0.1252, 1),

-- Cultured
	('COLOR_PLAYER_MINOR_BRATISLAVA',     0.878, 0.518, 0.678, 1),
	('COLOR_PLAYER_MINOR_BRUSSELS',       0.703, 0.466, 0.866, 1),
	('COLOR_PLAYER_MINOR_BUCHAREST',      0.682, 0.000, 1.000, 1),
	('COLOR_PLAYER_MINOR_BUENOS_AIRES',   0.678, 0.467, 1.000, 1),
	('COLOR_PLAYER_MINOR_FLORENCE',       1.000, 0.588, 0.909, 1),
	('COLOR_PLAYER_MINOR_KABUL',          0.663, 0.466, 0.678, 1),
	('COLOR_PLAYER_MINOR_KIEV',           0.516, 0.239, 1.000, 1),
	('COLOR_PLAYER_MINOR_KUALA_LUMPUR',   0.752, 0.000, 1.000, 1),
	('COLOR_PLAYER_MINOR_KYZYL',          1.000, 0.278, 0.639, 1),
	('COLOR_PLAYER_MINOR_MILAN',          0.878, 0.009, 1.000, 1),
	('COLOR_PLAYER_MINOR_MONACO',         1.000, 0.227, 1.000, 1),
	('COLOR_PLAYER_MINOR_PRAGUE',         0.552, 0.000, 1.000, 1),
	('COLOR_PLAYER_MINOR_YEREVAN',        0.878, 0.009, 0.494, 1),

-- Maritime
	('COLOR_PLAYER_MINOR_BYBLOS',         0.384, 1.000, 0.000, 1),
	('COLOR_PLAYER_MINOR_CAPE_TOWN',      0.548, 0.769, 0.000, 1),
	('COLOR_PLAYER_MINOR_MANILA',         0.000, 0.814, 0.000, 1),
	('COLOR_PLAYER_MINOR_MOMBASA',        0.000, 0.627, 0.349, 1),
	('COLOR_PLAYER_MINOR_MOGADISHU',      0.478, 1.000, 0.000, 1),
	('COLOR_PLAYER_MINOR_ORMUS',          0.341, 0.749, 0.545, 1),
	('COLOR_PLAYER_MINOR_PANAMA_CITY',    0.788, 1.000, 0.494, 1),
	('COLOR_PLAYER_MINOR_QUEBEC_CITY',    0.458, 1.000, 0.549, 1),
	('COLOR_PLAYER_MINOR_RIGA',           0.000, 1.000, 0.714, 1),
	('COLOR_PLAYER_MINOR_RAGUSA',         0.459, 1.000, 0.745, 1),
	('COLOR_PLAYER_MINOR_SYDNEY',         0.664, 1.000, 0.000, 1),
	('COLOR_PLAYER_MINOR_UR',             0.455, 1.000, 0.259, 1),
	('COLOR_PLAYER_MINOR_VANCOUVER',      0.000, 0.776, 0.427, 1),
	('COLOR_PLAYER_MINOR_WELLINGTON',     0.455, 0.737, 0.259, 1),

-- Mercantile
	('COLOR_PLAYER_MINOR_ANTWERP',        0.886, 0.743, 0.495, 1),
	('COLOR_PLAYER_MINOR_CAHOKIA',        0.717, 0.576, 0.192, 1),
	('COLOR_PLAYER_MINOR_COLOMBO',        1.000, 1.000, 0.000, 1),
	('COLOR_PLAYER_MINOR_GENOA',          1.000, 0.564, 0.000, 1),
	('COLOR_PLAYER_MINOR_HONG_KONG',      1.000, 0.745, 0.000, 1),
	('COLOR_PLAYER_MINOR_MALACCA',        1.000, 0.845, 0.000, 1),
	('COLOR_PLAYER_MINOR_MELBOURNE',      1.000, 1.000, 0.700, 1),
	('COLOR_PLAYER_MINOR_ZANZIBAR',       0.800, 0.745, 0.000, 1),
	('COLOR_PLAYER_MINOR_SAMARKAND',      0.777, 0.676, 0.000, 1),
	('COLOR_PLAYER_MINOR_TYRE',           0.878, 0.737, 0.349, 1),
	('COLOR_PLAYER_MINOR_ZURICH',         1.000, 0.925, 0.000, 1),

-- Militaristic
	('COLOR_PLAYER_MINOR_ALMATY',         0.718, 0.420, 0.318, 1),
	('COLOR_PLAYER_MINOR_BELGRADE',       1.000, 0.420, 0.318, 1),
	('COLOR_PLAYER_MINOR_BUDAPEST',       0.710, 0.298, 0.224, 1),
	('COLOR_PLAYER_MINOR_HANOI',          1.000, 0.227, 0.000, 1),
	('COLOR_PLAYER_MINOR_MBANZA_KONGO',   0.718, 0.447, 0.447, 1),
	('COLOR_PLAYER_MINOR_SIDON',          0.900, 0.337, 0.315, 1),
	('COLOR_PLAYER_MINOR_SOFIA',          0.718, 0.337, 0.337, 1),
	('COLOR_PLAYER_MINOR_VALLETTA',       0.918, 0.557, 0.487, 1),

-- Religious
	('COLOR_PLAYER_MINOR_IFE',            0.608, 0.688, 1.000, 1),
	('COLOR_PLAYER_MINOR_JERUSALEM',      0.818, 0.908, 1.000, 1),
	('COLOR_PLAYER_MINOR_KATHMANDU',      0.192, 0.518, 0.749, 1),
	('COLOR_PLAYER_MINOR_LHASA',          0.620, 0.776, 1.000, 1),
	('COLOR_PLAYER_MINOR_VATICAN_CITY',   0.437, 0.553, 1.000, 1),
	('COLOR_PLAYER_MINOR_WITTENBERG',     0.757, 0.858, 1.000, 1);

--------------------------------------------------------------------------
-- PlayerColors
--------------------------------------------------------------------------
INSERT INTO PlayerColors (Type, PrimaryColor, SecondaryColor, TextColor) VALUES

-- Cultured
	('PLAYERCOLOR_MINOR_BRATISLAVA',    'COLOR_PLAYER_MINOR_ICON', 'COLOR_PLAYER_MINOR_BRATISLAVA',    'COLOR_PLAYER_PEACH_TEXT'),
	('PLAYERCOLOR_MINOR_BRUSSELS',      'COLOR_PLAYER_MINOR_ICON', 'COLOR_PLAYER_MINOR_BRUSSELS',      'COLOR_PLAYER_PEACH_TEXT'),
	('PLAYERCOLOR_MINOR_BUCHAREST',     'COLOR_PLAYER_MINOR_ICON', 'COLOR_PLAYER_MINOR_BUCHAREST',     'COLOR_PLAYER_PEACH_TEXT'),
	('PLAYERCOLOR_MINOR_BUENOS_AIRES',  'COLOR_PLAYER_MINOR_ICON', 'COLOR_PLAYER_MINOR_BUENOS_AIRES',  'COLOR_PLAYER_PEACH_TEXT'),
	('PLAYERCOLOR_MINOR_FLORENCE',      'COLOR_PLAYER_MINOR_ICON', 'COLOR_PLAYER_MINOR_FLORENCE',      'COLOR_PLAYER_PEACH_TEXT'),
	('PLAYERCOLOR_MINOR_KABUL',         'COLOR_PLAYER_MINOR_ICON', 'COLOR_PLAYER_MINOR_KABUL',         'COLOR_PLAYER_PEACH_TEXT'),
	('PLAYERCOLOR_MINOR_KIEV',          'COLOR_PLAYER_MINOR_ICON', 'COLOR_PLAYER_MINOR_KIEV',          'COLOR_PLAYER_PEACH_TEXT'),
	('PLAYERCOLOR_MINOR_KUALA_LUMPUR',  'COLOR_PLAYER_MINOR_ICON', 'COLOR_PLAYER_MINOR_KUALA_LUMPUR',  'COLOR_PLAYER_PEACH_TEXT'),
	('PLAYERCOLOR_MINOR_KYZYL',         'COLOR_PLAYER_MINOR_ICON', 'COLOR_PLAYER_MINOR_KYZYL',         'COLOR_PLAYER_PEACH_TEXT'),
	('PLAYERCOLOR_MINOR_MILAN',         'COLOR_PLAYER_MINOR_ICON', 'COLOR_PLAYER_MINOR_MILAN',         'COLOR_PLAYER_PEACH_TEXT'),
	('PLAYERCOLOR_MINOR_MONACO',        'COLOR_PLAYER_MINOR_ICON', 'COLOR_PLAYER_MINOR_MONACO',        'COLOR_PLAYER_PEACH_TEXT'),
	('PLAYERCOLOR_MINOR_PRAGUE',        'COLOR_PLAYER_MINOR_ICON', 'COLOR_PLAYER_MINOR_PRAGUE',        'COLOR_PLAYER_PEACH_TEXT'),
	('PLAYERCOLOR_MINOR_YEREVAN',       'COLOR_PLAYER_MINOR_ICON', 'COLOR_PLAYER_MINOR_YEREVAN',       'COLOR_PLAYER_PEACH_TEXT'),

-- Maritime
	('PLAYERCOLOR_MINOR_BYBLOS',        'COLOR_PLAYER_MINOR_ICON', 'COLOR_PLAYER_MINOR_BYBLOS',        'COLOR_PLAYER_PEACH_TEXT'),
	('PLAYERCOLOR_MINOR_CAPE_TOWN',     'COLOR_PLAYER_MINOR_ICON', 'COLOR_PLAYER_MINOR_CAPE_TOWN',     'COLOR_PLAYER_PEACH_TEXT'),
	('PLAYERCOLOR_MINOR_MANILA',        'COLOR_PLAYER_MINOR_ICON', 'COLOR_PLAYER_MINOR_MANILA',        'COLOR_PLAYER_PEACH_TEXT'),
	('PLAYERCOLOR_MINOR_MOMBASA',       'COLOR_PLAYER_MINOR_ICON', 'COLOR_PLAYER_MINOR_MOMBASA',       'COLOR_PLAYER_PEACH_TEXT'),
	('PLAYERCOLOR_MINOR_MOGADISHU',     'COLOR_PLAYER_MINOR_ICON', 'COLOR_PLAYER_MINOR_MOGADISHU',     'COLOR_PLAYER_PEACH_TEXT'),
	('PLAYERCOLOR_MINOR_ORMUS',         'COLOR_PLAYER_MINOR_ICON', 'COLOR_PLAYER_MINOR_ORMUS',         'COLOR_PLAYER_PEACH_TEXT'),
	('PLAYERCOLOR_MINOR_PANAMA_CITY',   'COLOR_PLAYER_MINOR_ICON', 'COLOR_PLAYER_MINOR_PANAMA_CITY',   'COLOR_PLAYER_PEACH_TEXT'),
	('PLAYERCOLOR_MINOR_QUEBEC_CITY',   'COLOR_PLAYER_MINOR_ICON', 'COLOR_PLAYER_MINOR_QUEBEC_CITY',   'COLOR_PLAYER_PEACH_TEXT'),
	('PLAYERCOLOR_MINOR_RIGA',          'COLOR_PLAYER_MINOR_ICON', 'COLOR_PLAYER_MINOR_RIGA',          'COLOR_PLAYER_PEACH_TEXT'),
	('PLAYERCOLOR_MINOR_RAGUSA',        'COLOR_PLAYER_MINOR_ICON', 'COLOR_PLAYER_MINOR_RAGUSA',        'COLOR_PLAYER_PEACH_TEXT'),
	('PLAYERCOLOR_MINOR_SYDNEY',        'COLOR_PLAYER_MINOR_ICON', 'COLOR_PLAYER_MINOR_SYDNEY',        'COLOR_PLAYER_PEACH_TEXT'),
	('PLAYERCOLOR_MINOR_UR',            'COLOR_PLAYER_MINOR_ICON', 'COLOR_PLAYER_MINOR_UR',            'COLOR_PLAYER_PEACH_TEXT'),
	('PLAYERCOLOR_MINOR_VANCOUVER',     'COLOR_PLAYER_MINOR_ICON', 'COLOR_PLAYER_MINOR_VANCOUVER',     'COLOR_PLAYER_PEACH_TEXT'),
	('PLAYERCOLOR_MINOR_WELLINGTON',    'COLOR_PLAYER_MINOR_ICON', 'COLOR_PLAYER_MINOR_WELLINGTON',    'COLOR_PLAYER_PEACH_TEXT'),

-- Mercantile
	('PLAYERCOLOR_MINOR_ANTWERP',       'COLOR_PLAYER_MINOR_ICON', 'COLOR_PLAYER_MINOR_ANTWERP',       'COLOR_PLAYER_PEACH_TEXT'),
	('PLAYERCOLOR_MINOR_CAHOKIA',       'COLOR_PLAYER_MINOR_ICON', 'COLOR_PLAYER_MINOR_CAHOKIA',       'COLOR_PLAYER_PEACH_TEXT'),
	('PLAYERCOLOR_MINOR_COLOMBO',       'COLOR_PLAYER_MINOR_ICON', 'COLOR_PLAYER_MINOR_COLOMBO',       'COLOR_PLAYER_PEACH_TEXT'),
	('PLAYERCOLOR_MINOR_GENOA',         'COLOR_PLAYER_MINOR_ICON', 'COLOR_PLAYER_MINOR_GENOA',         'COLOR_PLAYER_PEACH_TEXT'),
	('PLAYERCOLOR_MINOR_HONG_KONG',     'COLOR_PLAYER_MINOR_ICON', 'COLOR_PLAYER_MINOR_HONG_KONG',     'COLOR_PLAYER_PEACH_TEXT'),
	('PLAYERCOLOR_MINOR_MALACCA',       'COLOR_PLAYER_MINOR_ICON', 'COLOR_PLAYER_MINOR_MALACCA',       'COLOR_PLAYER_PEACH_TEXT'),
	('PLAYERCOLOR_MINOR_MELBOURNE',     'COLOR_PLAYER_MINOR_ICON', 'COLOR_PLAYER_MINOR_MELBOURNE',     'COLOR_PLAYER_PEACH_TEXT'),
	('PLAYERCOLOR_MINOR_SAMARKAND',     'COLOR_PLAYER_MINOR_ICON', 'COLOR_PLAYER_MINOR_SAMARKAND',     'COLOR_PLAYER_PEACH_TEXT'),
	('PLAYERCOLOR_MINOR_TYRE',          'COLOR_PLAYER_MINOR_ICON', 'COLOR_PLAYER_MINOR_TYRE',          'COLOR_PLAYER_PEACH_TEXT'),
	('PLAYERCOLOR_MINOR_ZANZIBAR',      'COLOR_PLAYER_MINOR_ICON', 'COLOR_PLAYER_MINOR_ZANZIBAR',      'COLOR_PLAYER_PEACH_TEXT'),
	('PLAYERCOLOR_MINOR_ZURICH',        'COLOR_PLAYER_MINOR_ICON', 'COLOR_PLAYER_MINOR_ZURICH',        'COLOR_PLAYER_PEACH_TEXT'),

-- Militaristic
	('PLAYERCOLOR_MINOR_ALMATY',        'COLOR_PLAYER_MINOR_ICON', 'COLOR_PLAYER_MINOR_ALMATY',        'COLOR_PLAYER_PEACH_TEXT'),
	('PLAYERCOLOR_MINOR_BELGRADE',      'COLOR_PLAYER_MINOR_ICON', 'COLOR_PLAYER_MINOR_BELGRADE',      'COLOR_PLAYER_PEACH_TEXT'),
	('PLAYERCOLOR_MINOR_BUDAPEST',      'COLOR_PLAYER_MINOR_ICON', 'COLOR_PLAYER_MINOR_BUDAPEST',      'COLOR_PLAYER_PEACH_TEXT'),
	('PLAYERCOLOR_MINOR_HANOI',         'COLOR_PLAYER_MINOR_ICON', 'COLOR_PLAYER_MINOR_HANOI',         'COLOR_PLAYER_PEACH_TEXT'),
	('PLAYERCOLOR_MINOR_MBANZA_KONGO',  'COLOR_PLAYER_MINOR_ICON', 'COLOR_PLAYER_MINOR_MBANZA_KONGO',  'COLOR_PLAYER_PEACH_TEXT'),
	('PLAYERCOLOR_MINOR_SIDON',         'COLOR_PLAYER_MINOR_ICON', 'COLOR_PLAYER_MINOR_SIDON',         'COLOR_PLAYER_PEACH_TEXT'),
	('PLAYERCOLOR_MINOR_SOFIA',         'COLOR_PLAYER_MINOR_ICON', 'COLOR_PLAYER_MINOR_SOFIA',         'COLOR_PLAYER_PEACH_TEXT'),
	('PLAYERCOLOR_MINOR_VALLETTA',      'COLOR_PLAYER_MINOR_ICON', 'COLOR_PLAYER_MINOR_VALLETTA',      'COLOR_PLAYER_PEACH_TEXT'),

-- Religious
	('PLAYERCOLOR_MINOR_IFE',           'COLOR_PLAYER_MINOR_ICON', 'COLOR_PLAYER_MINOR_IFE',           'COLOR_PLAYER_PEACH_TEXT'),
	('PLAYERCOLOR_MINOR_JERUSALEM',     'COLOR_PLAYER_MINOR_ICON', 'COLOR_PLAYER_MINOR_JERUSALEM',     'COLOR_PLAYER_PEACH_TEXT'),
	('PLAYERCOLOR_MINOR_KATHMANDU',     'COLOR_PLAYER_MINOR_ICON', 'COLOR_PLAYER_MINOR_KATHMANDU',     'COLOR_PLAYER_PEACH_TEXT'),
	('PLAYERCOLOR_MINOR_LHASA',         'COLOR_PLAYER_MINOR_ICON', 'COLOR_PLAYER_MINOR_LHASA',         'COLOR_PLAYER_PEACH_TEXT'),
	('PLAYERCOLOR_MINOR_VATICAN_CITY',  'COLOR_PLAYER_MINOR_ICON', 'COLOR_PLAYER_MINOR_VATICAN_CITY',  'COLOR_PLAYER_PEACH_TEXT'),
	('PLAYERCOLOR_MINOR_WITTENBERG',    'COLOR_PLAYER_MINOR_ICON', 'COLOR_PLAYER_MINOR_WITTENBERG',    'COLOR_PLAYER_PEACH_TEXT');

--------------------------------------------------------------------------
-- MINOR CIV DEFAULT COLORS
--------------------------------------------------------------------------

-- Cultured
UPDATE MinorCivilizations SET DefaultPlayerColor = 'PLAYERCOLOR_MINOR_BRATISLAVA'   WHERE Type = 'MINOR_CIV_BRATISLAVA';
UPDATE MinorCivilizations SET DefaultPlayerColor = 'PLAYERCOLOR_MINOR_BRUSSELS'     WHERE Type = 'MINOR_CIV_BRUSSELS';
UPDATE MinorCivilizations SET DefaultPlayerColor = 'PLAYERCOLOR_MINOR_BUCHAREST'    WHERE Type = 'MINOR_CIV_BUCHAREST';
UPDATE MinorCivilizations SET DefaultPlayerColor = 'PLAYERCOLOR_MINOR_BUENOS_AIRES' WHERE Type = 'MINOR_CIV_BUENOS_AIRES';
UPDATE MinorCivilizations SET DefaultPlayerColor = 'PLAYERCOLOR_MINOR_FLORENCE'     WHERE Type = 'MINOR_CIV_FLORENCE';
UPDATE MinorCivilizations SET DefaultPlayerColor = 'PLAYERCOLOR_MINOR_KABUL'        WHERE Type = 'MINOR_CIV_KABUL';
UPDATE MinorCivilizations SET DefaultPlayerColor = 'PLAYERCOLOR_MINOR_KIEV'         WHERE Type = 'MINOR_CIV_KIEV';
UPDATE MinorCivilizations SET DefaultPlayerColor = 'PLAYERCOLOR_MINOR_KUALA_LUMPUR' WHERE Type = 'MINOR_CIV_KUALA_LUMPUR';
UPDATE MinorCivilizations SET DefaultPlayerColor = 'PLAYERCOLOR_MINOR_KYZYL'        WHERE Type = 'MINOR_CIV_KYZYL';
UPDATE MinorCivilizations SET DefaultPlayerColor = 'PLAYERCOLOR_MINOR_MILAN'        WHERE Type = 'MINOR_CIV_MILAN';
UPDATE MinorCivilizations SET DefaultPlayerColor = 'PLAYERCOLOR_MINOR_MONACO'       WHERE Type = 'MINOR_CIV_MONACO';
UPDATE MinorCivilizations SET DefaultPlayerColor = 'PLAYERCOLOR_MINOR_PRAGUE'       WHERE Type = 'MINOR_CIV_PRAGUE';
UPDATE MinorCivilizations SET DefaultPlayerColor = 'PLAYERCOLOR_MINOR_YEREVAN'      WHERE Type = 'MINOR_CIV_YEREVAN';

-- Maritime
UPDATE MinorCivilizations SET DefaultPlayerColor = 'PLAYERCOLOR_MINOR_BYBLOS'        WHERE Type = 'MINOR_CIV_BYBLOS';
UPDATE MinorCivilizations SET DefaultPlayerColor = 'PLAYERCOLOR_MINOR_CAPE_TOWN'     WHERE Type = 'MINOR_CIV_CAPE_TOWN';
UPDATE MinorCivilizations SET DefaultPlayerColor = 'PLAYERCOLOR_MINOR_MANILA'        WHERE Type = 'MINOR_CIV_MANILA';
UPDATE MinorCivilizations SET DefaultPlayerColor = 'PLAYERCOLOR_MINOR_MOMBASA'       WHERE Type = 'MINOR_CIV_MOMBASA';
UPDATE MinorCivilizations SET DefaultPlayerColor = 'PLAYERCOLOR_MINOR_MOGADISHU'     WHERE Type = 'MINOR_CIV_MOGADISHU';
UPDATE MinorCivilizations SET DefaultPlayerColor = 'PLAYERCOLOR_MINOR_ORMUS'         WHERE Type = 'MINOR_CIV_ORMUS';
UPDATE MinorCivilizations SET DefaultPlayerColor = 'PLAYERCOLOR_MINOR_PANAMA_CITY'   WHERE Type = 'MINOR_CIV_PANAMA_CITY';
UPDATE MinorCivilizations SET DefaultPlayerColor = 'PLAYERCOLOR_MINOR_QUEBEC_CITY'   WHERE Type = 'MINOR_CIV_QUEBEC_CITY';
UPDATE MinorCivilizations SET DefaultPlayerColor = 'PLAYERCOLOR_MINOR_RIGA'          WHERE Type = 'MINOR_CIV_RIGA';
UPDATE MinorCivilizations SET DefaultPlayerColor = 'PLAYERCOLOR_MINOR_RAGUSA'        WHERE Type = 'MINOR_CIV_RAGUSA';
UPDATE MinorCivilizations SET DefaultPlayerColor = 'PLAYERCOLOR_MINOR_SYDNEY'        WHERE Type = 'MINOR_CIV_SYDNEY';
UPDATE MinorCivilizations SET DefaultPlayerColor = 'PLAYERCOLOR_MINOR_UR'            WHERE Type = 'MINOR_CIV_UR';
UPDATE MinorCivilizations SET DefaultPlayerColor = 'PLAYERCOLOR_MINOR_VANCOUVER'     WHERE Type = 'MINOR_CIV_VANCOUVER';
UPDATE MinorCivilizations SET DefaultPlayerColor = 'PLAYERCOLOR_MINOR_WELLINGTON'    WHERE Type = 'MINOR_CIV_WELLINGTON';

-- Mercantile
UPDATE MinorCivilizations SET DefaultPlayerColor = 'PLAYERCOLOR_MINOR_ANTWERP'       WHERE Type = 'MINOR_CIV_ANTWERP';
UPDATE MinorCivilizations SET DefaultPlayerColor = 'PLAYERCOLOR_MINOR_CAHOKIA'       WHERE Type = 'MINOR_CIV_CAHOKIA';
UPDATE MinorCivilizations SET DefaultPlayerColor = 'PLAYERCOLOR_MINOR_COLOMBO'       WHERE Type = 'MINOR_CIV_COLOMBO';
UPDATE MinorCivilizations SET DefaultPlayerColor = 'PLAYERCOLOR_MINOR_GENOA'         WHERE Type = 'MINOR_CIV_GENOA';
UPDATE MinorCivilizations SET DefaultPlayerColor = 'PLAYERCOLOR_MINOR_HONG_KONG'     WHERE Type = 'MINOR_CIV_HONG_KONG';
UPDATE MinorCivilizations SET DefaultPlayerColor = 'PLAYERCOLOR_MINOR_MALACCA'       WHERE Type = 'MINOR_CIV_MALACCA';
UPDATE MinorCivilizations SET DefaultPlayerColor = 'PLAYERCOLOR_MINOR_MELBOURNE'     WHERE Type = 'MINOR_CIV_MELBOURNE';
UPDATE MinorCivilizations SET DefaultPlayerColor = 'PLAYERCOLOR_MINOR_SAMARKAND'     WHERE Type = 'MINOR_CIV_SAMARKAND';
UPDATE MinorCivilizations SET DefaultPlayerColor = 'PLAYERCOLOR_MINOR_TYRE'          WHERE Type = 'MINOR_CIV_TYRE';
UPDATE MinorCivilizations SET DefaultPlayerColor = 'PLAYERCOLOR_MINOR_ZANZIBAR'      WHERE Type = 'MINOR_CIV_ZANZIBAR';
UPDATE MinorCivilizations SET DefaultPlayerColor = 'PLAYERCOLOR_MINOR_ZURICH'        WHERE Type = 'MINOR_CIV_ZURICH';

-- Militaristic
UPDATE MinorCivilizations SET DefaultPlayerColor = 'PLAYERCOLOR_MINOR_ALMATY'        WHERE Type = 'MINOR_CIV_ALMATY';
UPDATE MinorCivilizations SET DefaultPlayerColor = 'PLAYERCOLOR_MINOR_BELGRADE'      WHERE Type = 'MINOR_CIV_BELGRADE';
UPDATE MinorCivilizations SET DefaultPlayerColor = 'PLAYERCOLOR_MINOR_BUDAPEST'      WHERE Type = 'MINOR_CIV_BUDAPEST';
UPDATE MinorCivilizations SET DefaultPlayerColor = 'PLAYERCOLOR_MINOR_HANOI'         WHERE Type = 'MINOR_CIV_HANOI';
UPDATE MinorCivilizations SET DefaultPlayerColor = 'PLAYERCOLOR_MINOR_MBANZA_KONGO'  WHERE Type = 'MINOR_CIV_MBANZA_KONGO';
UPDATE MinorCivilizations SET DefaultPlayerColor = 'PLAYERCOLOR_MINOR_SIDON'         WHERE Type = 'MINOR_CIV_SIDON';
UPDATE MinorCivilizations SET DefaultPlayerColor = 'PLAYERCOLOR_MINOR_SOFIA'         WHERE Type = 'MINOR_CIV_SOFIA';
UPDATE MinorCivilizations SET DefaultPlayerColor = 'PLAYERCOLOR_MINOR_VALLETTA'      WHERE Type = 'MINOR_CIV_VALLETTA';

-- Religious
UPDATE MinorCivilizations SET DefaultPlayerColor = 'PLAYERCOLOR_MINOR_BLUE'           WHERE Type = 'MINOR_CIV_GENEVA';
UPDATE MinorCivilizations SET DefaultPlayerColor = 'PLAYERCOLOR_MINOR_IFE'            WHERE Type = 'MINOR_CIV_IFE';
UPDATE MinorCivilizations SET DefaultPlayerColor = 'PLAYERCOLOR_MINOR_JERUSALEM'      WHERE Type = 'MINOR_CIV_JERUSALEM';
UPDATE MinorCivilizations SET DefaultPlayerColor = 'PLAYERCOLOR_MINOR_KATHMANDU'      WHERE Type = 'MINOR_CIV_KATHMANDU';
UPDATE MinorCivilizations SET DefaultPlayerColor = 'PLAYERCOLOR_MINOR_LHASA'          WHERE Type = 'MINOR_CIV_LHASA';
UPDATE MinorCivilizations SET DefaultPlayerColor = 'PLAYERCOLOR_MINOR_VATICAN_CITY'   WHERE Type = 'MINOR_CIV_VATICAN_CITY';
UPDATE MinorCivilizations SET DefaultPlayerColor = 'PLAYERCOLOR_MINOR_WITTENBERG'     WHERE Type = 'MINOR_CIV_WITTENBERG';

--====================================================================================================================
-- ART-DEFINE / GRAPHICS FIXES
--====================================================================================================================

--------------------------------------------------------------------------------
-- Archaeology aesthetics
--------------------------------------------------------------------------------

-- Hidden Antiquity Site
UPDATE ArtDefine_Landmarks
	SET Model = 'hidden_antiquity_site.fxsxml'
	WHERE ResourceType = 'ART_DEF_RESOURCE_HIDDEN_ARTIFACTS' AND ImprovementType = 'ART_DEF_IMPROVEMENT_NONE';

-- Active Archaeological Dig
DELETE FROM ArtDefine_Landmarks
	WHERE ResourceType = 'ART_DEF_RESOURCE_ALL' AND ImprovementType = 'ART_DEF_IMPROVEMENT_ARCHAEOLOGICAL_DIG';

INSERT INTO ArtDefine_Landmarks (Era, State, Scale, ImprovementType, LayoutHandler, ResourceType, Model, TerrainContour)
	SELECT 'Any', 'Any', 0.8, 'ART_DEF_IMPROVEMENT_ARCHAEOLOGICAL_DIG', 'SNAPSHOT', 'ART_DEF_RESOURCE_ARTIFACTS', 'Archaeological_Dig.fxsxml', 1;

INSERT INTO ArtDefine_Landmarks (Era, State, Scale, ImprovementType, LayoutHandler, ResourceType, Model, TerrainContour)
	SELECT 'Any', 'Any', 0.8, 'ART_DEF_IMPROVEMENT_ARCHAEOLOGICAL_DIG', 'SNAPSHOT', 'ART_DEF_RESOURCE_HIDDEN_ARTIFACTS', 'Hidden_Archaeological_Dig.fxsxml', 1;

--------------------------------------------------------------------------------
-- CIVILIAN UNITS change appearance in Modern Era
--------------------------------------------------------------------------------
UPDATE ArtDefine_UnitInfos SET Type = 'ART_DEF_UNIT__WORKER_MODERN' WHERE Type = 'ART_DEF_UNIT__WORKER_LATE';
UPDATE ArtDefine_UnitInfoMemberInfos SET UnitInfoType = 'ART_DEF_UNIT__WORKER_MODERN' WHERE UnitInfoType = 'ART_DEF_UNIT__WORKER_LATE';

UPDATE ArtDefine_UnitInfos SET Type = 'ART_DEF_UNIT_WORKBOAT_MODERN' WHERE Type = 'ART_DEF_UNIT_WORKBOAT_LATE';
UPDATE ArtDefine_UnitInfoMemberInfos SET UnitInfoType = 'ART_DEF_UNIT_WORKBOAT_MODERN' WHERE UnitInfoType = 'ART_DEF_UNIT_WORKBOAT_LATE';

UPDATE ArtDefine_UnitInfos SET Type = 'ART_DEF_UNIT_CARAVAN_MODERN' WHERE Type = 'ART_DEF_UNIT_CARAVAN_POSTMODERN';
UPDATE ArtDefine_UnitInfoMemberInfos SET UnitInfoType = 'ART_DEF_UNIT_CARAVAN_MODERN' WHERE UnitInfoType = 'ART_DEF_UNIT_CARAVAN_POSTMODERN';

UPDATE ArtDefine_UnitInfos SET Type = 'ART_DEF_UNIT_CARGO_SHIP_MODERN' WHERE Type = 'ART_DEF_UNIT_CARGO_SHIP_POSTMODERN';
UPDATE ArtDefine_UnitInfoMemberInfos SET UnitInfoType = 'ART_DEF_UNIT_CARGO_SHIP_MODERN' WHERE UnitInfoType = 'ART_DEF_UNIT_CARGO_SHIP_POSTMODERN';

UPDATE ArtDefine_UnitInfos SET Type = 'ART_DEF_UNIT_GENERAL_MODERN' WHERE Type = 'ART_DEF_UNIT_GENERAL_LATE';
UPDATE ArtDefine_UnitInfoMemberInfos SET UnitInfoType = 'ART_DEF_UNIT_GENERAL_MODERN' WHERE UnitInfoType = 'ART_DEF_UNIT_GENERAL_LATE';

UPDATE ArtDefine_UnitInfos SET Type = 'ART_DEF_UNIT_GREAT_ADMIRAL_MODERN' WHERE Type = 'ART_DEF_UNIT_GREAT_ADMIRAL_LATE';
UPDATE ArtDefine_UnitInfoMemberInfos SET UnitInfoType = 'ART_DEF_UNIT_GREAT_ADMIRAL_MODERN' WHERE UnitInfoType = 'ART_DEF_UNIT_GREAT_ADMIRAL_LATE';

--====================================================================================================================
-- LANDMARK ART DEFINE CLEAN UP
--====================================================================================================================

-------------------------------------------------
-- ArtDefine_LandmarkTypes
-------------------------------------------------
DELETE FROM ArtDefine_LandmarkTypes WHERE Type IN (
		'SPECIAL',
		'ART_DEF_FEATURE_HADRIANS_WALL_1',
		'ART_DEF_FEATURE_HADRIANS_WALL_2',
		'ART_DEF_FEATURE_HADRIANS_WALL_3',
		'ART_DEF_IMPROVEMENT_HOLY_SITE',
		'ART_DEF_IMPROVEMENT_TERRACE_FARM',
		'ART_DEF_IMPROVEMENT_POLDER'
);
INSERT INTO ArtDefine_LandmarkTypes
		(Type,												LandmarkType,		FriendlyName)
VALUES	('SPECIAL',											'LayoutHandler',	'Special'),
		('ART_DEF_IMPROVEMENT_HOLY_SITE',					'Improvement',		'HolySite'),
		('ART_DEF_IMPROVEMENT_TERRACE_FARM',				'Improvement',		'TerraceFarm'),
		('ART_DEF_IMPROVEMENT_POLDER',						'Improvement',		'Polder');

-------------------------------------------------
-- ArtDefine_Landmarks
-------------------------------------------------
DELETE FROM ArtDefine_Landmarks WHERE ImprovementType IN (
		'ART_DEF_FEATURE_HADRIANS_WALL_1',
		'ART_DEF_FEATURE_HADRIANS_WALL_2',
		'ART_DEF_FEATURE_HADRIANS_WALL_3',
		'ART_DEF_IMPROVEMENT_HOLY_SITE',
		'ART_DEF_IMPROVEMENT_TERRACE_FARM',
		'ART_DEF_IMPROVEMENT_POLDER'
);
UPDATE ArtDefine_Landmarks SET Scale = 0.9 WHERE ImprovementType IN
		('ART_DEF_IMPROVEMENT_GOODY_HUT',
		'ART_DEF_IMPROVEMENT_FORT');
UPDATE ArtDefine_Landmarks SET Scale= 0.85 WHERE ImprovementType IN 
		('ART_DEF_IMPROVEMENT_TRADING_POST1',
		'ART_DEF_IMPROVEMENT_TRADING_POST2',
		'ART_DEF_IMPROVEMENT_TRADING_POST3',
		'ART_DEF_IMPROVEMENT_TRADING_POST4');
UPDATE ArtDefine_Landmarks SET Scale= 0.80 WHERE ImprovementType IN 
		('ART_DEF_IMPROVEMENT_CITADEL',
		'ART_DEF_IMPROVEMENT_CHATEAU',
		'ART_DEF_IMPROVEMENT_KASBAH');
UPDATE ArtDefine_Landmarks SET Scale= 0.75 WHERE ImprovementType IN
		('ART_DEF_IMPROVEMENT_ACADEMY',
		'ART_DEF_IMPROVEMENT_CUSTOMS_HOUSE',
		'ART_DEF_IMPROVEMENT_MANUFACTORY');

INSERT INTO ArtDefine_Landmarks 
(Era,			State,					Scale,	ImprovementType,					LayoutHandler,	ResourceType,							Model,								TerrainContour,	Tech) VALUES
-- Holy Site
('Any',			'Constructed',			0.75,	'ART_DEF_IMPROVEMENT_HOLY_SITE',	'SNAPSHOT',		'ART_DEF_RESOURCE_ALL',					'Holy_Site.fxsxml',					1,				NULL),
('Any',			'Pillaged',				0.75,	'ART_DEF_IMPROVEMENT_HOLY_SITE',	'SNAPSHOT',		'ART_DEF_RESOURCE_ALL',					'Holy_Site_PIL.fxsxml',				1,				NULL),
-- Terrace Farm
('Any',			'UnderConstruction',	1.0,	'ART_DEF_IMPROVEMENT_TERRACE_FARM',	'SNAPSHOT',		'ART_DEF_RESOURCE_ALL',					'HB_Incan_Terrace_Farm.fxsxml',		1,				NULL),
('Any',			'Constructed',			1.0,	'ART_DEF_IMPROVEMENT_TERRACE_FARM',	'SNAPSHOT',		'ART_DEF_RESOURCE_ALL',					'Incan_Terrace_Farm.fxsxml',		1,				NULL),
('Any',			'Pillaged',				1.0,	'ART_DEF_IMPROVEMENT_TERRACE_FARM',	'SNAPSHOT',		'ART_DEF_RESOURCE_ALL',					'PL_Incan_Terrace_Farm.fxsxml',		1,				NULL),
-- Polder
('Ancient',		'UnderConstruction',	1.0,	'ART_DEF_IMPROVEMENT_POLDER',		'SNAPSHOT',		'ART_DEF_RESOURCE_ALL',					'HB_ANC_Polder.fxsxml',				1,				NULL),
('Ancient',		'UnderConstruction',	1.0,	'ART_DEF_IMPROVEMENT_POLDER',		'ANIMATED',		'ART_DEF_RESOURCE_ALL',					'ANC_Polder.fxsxml',				1,				NULL),
('Ancient',		'Constructed',			1.0,	'ART_DEF_IMPROVEMENT_POLDER',		'SNAPSHOT',		'ART_DEF_RESOURCE_ALL',					'Polder_Blank.fxsxml',				1,				NULL),
('Ancient',		'Constructed',			1.0,	'ART_DEF_IMPROVEMENT_POLDER',		'ANIMATED',		'ART_DEF_RESOURCE_ALL',					'ANC_Polder.fxsxml',				1,				NULL),
('Ancient',		'Pillaged',				1.0,	'ART_DEF_IMPROVEMENT_POLDER',		'SNAPSHOT',		'ART_DEF_RESOURCE_ALL',					'PL_ANC_Polder.fxsxml',				1,				NULL),
('Ancient',		'Pillaged',				1.0,	'ART_DEF_IMPROVEMENT_POLDER',		'ANIMATED',		'ART_DEF_RESOURCE_ALL',					'ANC_Polder.fxsxml',				1,				NULL),
('Ancient',		'UnderConstruction',	1.0,	'ART_DEF_IMPROVEMENT_POLDER',		'SNAPSHOT',		'ART_DEF_RESOURCE_ALL',					'HB_IND_Polder.fxsxml',				1,				'TECH_ECONOMICS'),
('Ancient',		'UnderConstruction',	1.0,	'ART_DEF_IMPROVEMENT_POLDER',		'ANIMATED',		'ART_DEF_RESOURCE_ALL',					'IND_Polder.fxsxml',				1,				'TECH_ECONOMICS'),
('Ancient',		'Constructed',			1.0,	'ART_DEF_IMPROVEMENT_POLDER',		'SNAPSHOT',		'ART_DEF_RESOURCE_ALL',					'Polder_Blank.fxsxml',				1,				'TECH_ECONOMICS'),
('Ancient',		'Constructed',			1.0,	'ART_DEF_IMPROVEMENT_POLDER',		'ANIMATED',		'ART_DEF_RESOURCE_ALL',					'IND_Polder.fxsxml',				1,				'TECH_ECONOMICS'),
('Ancient',		'Pillaged',				1.0,	'ART_DEF_IMPROVEMENT_POLDER',		'SNAPSHOT',		'ART_DEF_RESOURCE_ALL',					'PL_IND_Polder.fxsxml',				1,				'TECH_ECONOMICS'),
('Ancient',		'Pillaged',				1.0,	'ART_DEF_IMPROVEMENT_POLDER',		'ANIMATED',		'ART_DEF_RESOURCE_ALL',					'IND_Polder.fxsxml',				1,				'TECH_ECONOMICS'),
('Industrial',	'UnderConstruction',	1.0,	'ART_DEF_IMPROVEMENT_POLDER',		'SNAPSHOT',		'ART_DEF_RESOURCE_ALL',					'HB_IND_Polder.fxsxml',				1,				NULL),
('Industrial',	'UnderConstruction',	1.0,	'ART_DEF_IMPROVEMENT_POLDER',		'ANIMATED',		'ART_DEF_RESOURCE_ALL',					'IND_Polder.fxsxml',				1,				NULL),
('Industrial',	'Constructed',			1.0,	'ART_DEF_IMPROVEMENT_POLDER',		'SNAPSHOT',		'ART_DEF_RESOURCE_ALL',					'Polder_Blank.fxsxml',				1,				NULL),
('Industrial',	'Constructed',			1.0,	'ART_DEF_IMPROVEMENT_POLDER',		'ANIMATED',		'ART_DEF_RESOURCE_ALL',					'IND_Polder.fxsxml',				1,				NULL),
('Industrial',	'Pillaged',				1.0,	'ART_DEF_IMPROVEMENT_POLDER',		'SNAPSHOT',		'ART_DEF_RESOURCE_ALL',					'PL_IND_Polder.fxsxml',				1,				NULL),
('Industrial',	'Pillaged',				1.0,	'ART_DEF_IMPROVEMENT_POLDER',		'ANIMATED',		'ART_DEF_RESOURCE_ALL',					'IND_Polder.fxsxml',				1,				NULL);

-------------------------------------------------
-- ArtDefine_StrategicView
-------------------------------------------------
DELETE FROM ArtDefine_StrategicView WHERE StrategicViewType IN
('ART_DEF_FEATURE_HADRIANS_WALL_1', 'ART_DEF_FEATURE_HADRIANS_WALL_2', 'ART_DEF_FEATURE_HADRIANS_WALL_3');

--------------------------------------------------------------------------------
-- Barbarian civilization art
--------------------------------------------------------------------------------

UPDATE Civilizations SET
		ArtStyleType   = 'ARTSTYLE_EUROPEAN',
		ArtStyleSuffix = '_EURO',
		ArtStylePrefix = 'EUROPEAN',
		ArtDefineTag   = 'ART_DEF_CIVILIZATION_ROME'
WHERE Type = 'CIVILIZATION_BARBARIAN';

--====================================================================================================================
-- TERRAIN: mountain strategic-view art fallback
--====================================================================================================================
DROP TABLE IF EXISTS Terrain_ArtDefine_StrategicView;
CREATE TEMP TABLE Terrain_ArtDefine_StrategicView AS SELECT * FROM ArtDefine_StrategicView WHERE TileType = 'Terrain';
DELETE FROM ArtDefine_StrategicView WHERE TileType = 'Terrain';
INSERT OR REPLACE INTO ArtDefine_StrategicView (StrategicViewType, TileType, Asset)
VALUES ('ART_DEF_TERRAIN_MOUNTAIN', 'Terrain', 'SV_TerrainHexGrasslands.dds');
INSERT INTO ArtDefine_StrategicView SELECT * FROM Terrain_ArtDefine_StrategicView AS t
	WHERE NOT EXISTS (SELECT 1 FROM ArtDefine_StrategicView AS a WHERE a.StrategicViewType = t.StrategicViewType);
DROP TABLE IF EXISTS Terrain_ArtDefine_StrategicView;

--====================================================================================================================
-- UNIT ART DEFINES
--====================================================================================================================

-------------------------------------------------
-- CARTHAGE FOREST ELEPHANT
-------------------------------------------------
UPDATE Units SET MoveRate = 'PHANT' WHERE Type = 'UNIT_CARTHAGINIAN_FOREST_ELEPHANT';
UPDATE ArtDefine_UnitMemberCombats SET
		HasShortRangedAttack = NULL,
		HasLongRangedAttack = NULL,
		ReformBeforeCombat = 2,
		RushAttackFormation = 'ChariotElephant'
WHERE UnitMemberType = 'ART_DEF_UNIT_MEMBER_U_CARTHAGE_AFRICANFOREST_ELEPHANT';
UPDATE ArtDefine_UnitMemberCombatWeapons SET WeaponTypeSoundOverrideTag = 'SPEAR' WHERE UnitMemberType = 'ART_DEF_UNIT_MEMBER_U_CARTHAGE_AFRICANFOREST_ELEPHANT';

-------------------------------------------------
-- GREAT ADMIRAL
-------------------------------------------------
UPDATE ArtDefine_UnitMemberCombats SET MoveRate = 2.0 WHERE UnitMemberType = 'ART_DEF_UNIT_MEMBER_GREAT_ADMIRAL_LATE';

-------------------------------------------------
-- AIR UNITS
-------------------------------------------------
UPDATE ArtDefine_UnitMemberInfos SET Scale = 0.078 WHERE Type = 'ART_DEF_UNIT_MEMBER_WW1_FIGHTER';						/*0.09*/
UPDATE ArtDefine_UnitMemberInfos SET Scale = 0.085 WHERE Type = 'ART_DEF_UNIT_MEMBER_FIGHTER';							/*0.08*/
UPDATE ArtDefine_UnitMemberInfos SET Scale = 0.077 WHERE Type = 'ART_DEF_UNIT_MEMBER_U_JAPANESE_ZERO';					/*0.07*/
UPDATE ArtDefine_UnitMemberInfos SET Scale = 0.097 WHERE Type = 'ART_DEF_UNIT_MEMBER_JETFIGHTER';						/*0.09*/
UPDATE ArtDefine_UnitMemberInfos SET Scale = 0.063 WHERE Type = 'ART_DEF_UNIT_MEMBER_WW1_BOMBER';						/*0.08*/
UPDATE ArtDefine_UnitMemberInfos SET Scale = 0.085 WHERE Type = 'ART_DEF_UNIT_MEMBER_BOMBER';							/*0.08*/
UPDATE ArtDefine_UnitMemberInfos SET Scale = 0.087 WHERE Type = 'ART_DEF_UNIT_MEMBER_U_AMERICAN_B17';					/*0.08*/
UPDATE ArtDefine_UnitMemberInfos SET Scale = 0.088 WHERE Type = 'ART_DEF_UNIT_MEMBER_STEALTHBOMBER';					/*0.08*/

UPDATE ArtDefine_UnitMemberCombats SET MoveRate = 1.6 	WHERE UnitMemberType = 'ART_DEF_UNIT_MEMBER_BOMBER';			/*1.8*/
UPDATE ArtDefine_UnitMemberCombats SET MoveRate = 1.7 	WHERE UnitMemberType = 'ART_DEF_UNIT_MEMBER_U_AMERICAN_B17';	/*1.2*/
UPDATE ArtDefine_UnitMemberCombats SET MoveRate = 1.3 	WHERE UnitMemberType = 'ART_DEF_UNIT_MEMBER_WW1_FIGHTER';		/*1.6*/
UPDATE ArtDefine_UnitMemberCombats SET MoveRate = 1.7 	WHERE UnitMemberType = 'ART_DEF_UNIT_MEMBER_FIGHTER';			/*1.6*/
UPDATE ArtDefine_UnitMemberCombats SET MoveRate = 1.72 	WHERE UnitMemberType = 'ART_DEF_UNIT_MEMBER_U_JAPANESE_ZERO';	/*1.6*/
UPDATE ArtDefine_UnitMemberCombats SET MoveRate = 2.5 	WHERE UnitMemberType = 'ART_DEF_UNIT_MEMBER_JETFIGHTER';		/*3*/
UPDATE ArtDefine_UnitMemberCombats SET MoveRate = 1.36 	WHERE UnitMemberType = 'ART_DEF_UNIT_MEMBER_WW1_BOMBER';		/*1.2*/

UPDATE ArtDefine_UnitMemberCombats SET TurnRateMin = 0.37 WHERE UnitMemberType = 'ART_DEF_UNIT_MEMBER_WW1_FIGHTER';		/*0.25*/
UPDATE ArtDefine_UnitMemberCombats SET TurnRateMax = 0.41 WHERE UnitMemberType = 'ART_DEF_UNIT_MEMBER_WW1_FIGHTER';		/*0.5*/
UPDATE ArtDefine_UnitMemberCombats SET TurnRateMin = 0.35 WHERE UnitMemberType = 'ART_DEF_UNIT_MEMBER_U_JAPANESE_ZERO';	/*0.25*/
UPDATE ArtDefine_UnitMemberCombats SET TurnRateMax = 0.45 WHERE UnitMemberType = 'ART_DEF_UNIT_MEMBER_U_JAPANESE_ZERO';	/*0.5*/
UPDATE ArtDefine_UnitMemberCombats SET TurnRateMin = 0.21 WHERE UnitMemberType = 'ART_DEF_UNIT_MEMBER_WW1_BOMBER';		/*0.1*/
UPDATE ArtDefine_UnitMemberCombats SET TurnRateMax = 0.31 WHERE UnitMemberType = 'ART_DEF_UNIT_MEMBER_WW1_BOMBER';		/*0.25*/
UPDATE ArtDefine_UnitMemberCombats SET TurnRateMin = 0.21 WHERE UnitMemberType = 'ART_DEF_UNIT_MEMBER_U_AMERICAN_B17';	/*0.1*/
UPDATE ArtDefine_UnitMemberCombats SET TurnRateMax = 0.31 WHERE UnitMemberType = 'ART_DEF_UNIT_MEMBER_U_AMERICAN_B17';	/*0.25*/
UPDATE ArtDefine_UnitMemberCombats SET TurnRateMin = 0.32 WHERE UnitMemberType = 'ART_DEF_UNIT_MEMBER_BOMBER';			/*0.15*/
UPDATE ArtDefine_UnitMemberCombats SET TurnRateMax = 0.42 WHERE UnitMemberType = 'ART_DEF_UNIT_MEMBER_BOMBER';			/*0.35*/

UPDATE ArtDefine_UnitMemberCombats SET AttackRadius = 125 WHERE UnitMemberType = 'ART_DEF_UNIT_MEMBER_JETFIGHTER';		/*135*/

UPDATE ArtDefine_UnitMemberCombatWeapons SET ProjectileSpeed = 1 	WHERE UnitMemberType = 'ART_DEF_UNIT_MEMBER_WW1_FIGHTER' AND "Index" = 1 AND SubIndex = 1;			/*1.3*/
UPDATE ArtDefine_UnitMemberCombatWeapons SET ProjectileSpeed = 1.5 	WHERE UnitMemberType = 'ART_DEF_UNIT_MEMBER_FIGHTER' AND "Index" = 0 AND SubIndex = 1;			/*3*/
UPDATE ArtDefine_UnitMemberCombatWeapons SET ProjectileSpeed = 1.6 	WHERE UnitMemberType = 'ART_DEF_UNIT_MEMBER_U_JAPANESE_ZERO' AND "Index" = 0 AND SubIndex = 1;	/*1.3*/
UPDATE ArtDefine_UnitMemberCombatWeapons SET ProjectileSpeed = 2.3 	WHERE UnitMemberType = 'ART_DEF_UNIT_MEMBER_JETFIGHTER' AND "Index" = 0 AND SubIndex = 0;		/*3*/
UPDATE ArtDefine_UnitMemberCombatWeapons SET ProjectileSpeed = 2.4 	WHERE UnitMemberType = 'ART_DEF_UNIT_MEMBER_JETFIGHTER' AND "Index" = 1 AND SubIndex = 1;		/*3*/

UPDATE ArtDefine_UnitInfoMemberInfos SET NumMembers = 3 WHERE UnitInfoType = 'ART_DEF_UNIT_JET_FIGHTER'; /*1*/

UPDATE ArtDefine_UnitMemberCombats SET AttackAltitude = 90, MoveRate = 4.8 WHERE UnitMemberType = 'ART_DEF_UNIT_MEMBER_GUIDEDMISSILE';
UPDATE ArtDefine_UnitMemberCombatWeapons SET WeaponTypeSoundOverrideTag = 'EXPLOSION1TON' WHERE UnitMemberType = 'ART_DEF_UNIT_MEMBER_GUIDEDMISSILE';

--====================================================================================================================
-- UNIT SOUND CORRECTIONS
--====================================================================================================================
DELETE FROM UnitGameplay2DScripts WHERE UnitType IN
('UNIT_BARBARIAN_HORSEMAN', 'UNIT_BARBARIAN_WARRIOR', 'UNIT_GATLINGGUN', 'UNIT_PRIVATEER', 'UNIT_SWEDISH_CAROLEAN');
INSERT INTO UnitGameplay2DScripts (UnitType, FirstSelectionSound, SelectionSound) VALUES
('UNIT_BARBARIAN_HORSEMAN','AS2D_BIRTH_HORSEMAN','AS2D_SELECT_HORSEMAN'),
('UNIT_BARBARIAN_WARRIOR','AS2D_BIRTH_WARRIER','AS2D_SELECT_WARRIER'),
('UNIT_GATLINGGUN','AS2D_BIRTH_CANNON','AS2D_SELECT_CANNON'),
('UNIT_PRIVATEER','AS2D_BIRTH_FRIGATE','AS2D_SELECT_FRIGATE'),
('UNIT_SWEDISH_CAROLEAN','AS2D_BIRTH_MUSKETMAN','AS2D_SELECT_MUSKETMAN');
--====================================================================================================================
UPDATE Sapiens_DBUpdates SET Value = 1 WHERE Name = 'CoreArtInfo';
