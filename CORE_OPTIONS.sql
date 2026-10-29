-- written by GAIA using Notepad++
CREATE TABLE IF NOT EXISTS Sapiens_DBUpdates (Name TEXT PRIMARY KEY, Value INTEGER DEFAULT 0);
INSERT OR IGNORE INTO Sapiens_DBUpdates (Name) VALUES ('CORE_OPTIONS');
--====================================================================================================================
-- CORE OPTIONS  (on/off switches for the Sapiens DLL's optional features)
--====================================================================================================================
REPLACE INTO Sapiens_ModOptions (Name, Value) VALUES
('AI_DANGER_AT_WAR_ONLY',      1),  -- the AI danger map only tracks civs actually at war with its owner (barbarians always count)
('AI_RANDOM_RELIGION',         1),  -- AI whose favoured religion is already taken founds a random remaining one, not the first
('AI_SETTLERS',                1);  -- AI keeps expanding while good land remains anywhere on the map, and escorts its settlers
REPLACE INTO Defines (Name, Value) VALUES
	('GD_AI_CAPITAL_SETTLER_MAX_CITIES',       7);  -- the AI capital keeps pushing settlers while its cities plus settlers are below this. Lower = fewer AI cities; vanilla 3.
REPLACE INTO Sapiens_ModOptions (Name, Value) VALUES
('AI_STRATEGY',                1),  -- AI strategy and economy retune: wonders, Great People, happiness, army sizing
('AI_TACTICS',                 1);  -- sharper wartime AI: stacked city defence, smarter siege, healing and retreat
REPLACE INTO Defines (Name, Value) VALUES
	('GD_AI_TACTICS_REPOSITION_CAP',          12);  -- max AI battlefield-reposition searches per player per turn. Lower = faster turns, higher = smarter combat AI. 0 = off; up to ~100 is safe but slow in big wars.
REPLACE INTO Sapiens_ModOptions (Name, Value) VALUES
('AI_TROOP_CONVOYS',           1);  -- AI naval invasions and overseas settlers sail in troop transports when a mod supplies them
REPLACE INTO Defines (Name, Value) VALUES
	('GD_TROOP_CONVOY_WAIT_TURNS',             8);  -- turns an AI naval invasion waits for missing troop transports to be gathered, bought or built before it sails without them. 0 = never waits
REPLACE INTO Sapiens_ModOptions (Name, Value) VALUES
('AI_UNIT_UPGRADES',           1),  -- the AI upgrades its units before it plans the turn, so it modernizes its army even in the middle of a war
('AI_WARMONGER',               1),  -- warmonger judgement weighs captured capitals and city size; pact allies react; an army busy with barbarians or another war no longer alarms a neighbour, nor do scouts, explorers, city founders or units under Open Borders or a Defensive Pact, and the border warning needs three units; an AI that clearly outguns a nuclear rival is wary of it, not afraid
('AI_WORKERS',                 1),  -- AI workers stop targeting the same tile or roaming cross-map for distant jobs, and pick nearby jobs by real travel time
('ASTAR_HEAP_OPEN_LIST',       1),  -- pathfinder open lists run as binary heaps: much cheaper searches late game (equal-cost route tie-breaks may differ from vanilla)
('CIVILIAN_STACKING',          1),  -- civilian units of different classes may share a tile (two of the same class still block each other)
('COMMANDERS_NEAREST_CITY',    1),  -- a combat-earned Great General or Admiral spawns at the nearest friendly city
('DISBAND_UNITS_REWORK',       1),  -- AI retires obsolete units and gifts spares to a city-state; disbanding spares veterans
('DUMMY_POLICIES',             1),  -- hidden helper policies no longer count toward score, happiness or policy cost
('FORCE_LOGGING',              1),  -- turns the game's logging on for you, so a bug report needs no config.ini edit
('FREE_UNITS_PRODUCTION_XP',   1),  -- a combat unit granted free by a building/wonder trains with that city's production XP and promotions
('INDEFINITE_TRADE_ROUTES',    1),  -- single-player trade routes keep looping until you recall the unit, instead of expiring
('LOCKED_BULB_VALUES',         1),  -- a Great Scientist or Writer locks in its output when created, not when used
('NO_ENEMY_REPAIRS',           1),  -- workers cannot repair a pillaged improvement in the lands of a civ you are at war with (roads still can)
('PARATROOPS_AA_DAMAGE',       1),  -- anti-air fire can hit paratroopers during a drop (vanilla bugfix)
('QUICK_AI_ANIMATIONS',        1),  -- AI-only combat and movement resolve instantly while off-screen; anything in your line of sight still animates
('RANDOM_CITY_NAMES',          1);  -- a civ's later cities take random names; the first few stay canonical
REPLACE INTO Defines (Name, Value) VALUES
	('GD_TOP_N_CITY_NAMES',                    3);  -- this many of a civ's first cities keep their canonical names; later ones draw randomly.
REPLACE INTO Sapiens_ModOptions (Name, Value) VALUES
('ROUTE_TO_BUILDS_ROAD_FIRST', 1),  -- human Route-To lays road first, then upgrades to railroad on a second pass
('STARTING_PLOT_ALWAYS_FOUNDABLE', 1),  -- a civ's first city can always be founded on its own starting plot, whatever the terrain and feature rules say (water and mountains still block)
('WAKE_UNITS_FOR_UPGRADE',     1),  -- wakes your parked units once they can be upgraded, and notifies you once
('WLTKD_RESET',                1);  -- the We Love the King Day luxury demand refreshes each cycle instead of sticking

--====================================================================================================================
UPDATE Sapiens_DBUpdates SET Value = 1 WHERE Name = 'CORE_OPTIONS';
