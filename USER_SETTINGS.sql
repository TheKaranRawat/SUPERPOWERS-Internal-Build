-- written by GAIA using Notepad++
CREATE TABLE IF NOT EXISTS Sapiens_DBUpdates (Name TEXT PRIMARY KEY, Value INTEGER DEFAULT 0);
INSERT OR IGNORE INTO Sapiens_DBUpdates (Name) VALUES ('USER_SETTINGS');
--====================================================================================================================
-- GAIA'S CORE MOD -- USER SETTINGS  (the one place to retune the mod's player-facing settings)
--====================================================================================================================
-- Customize your game here: change any value below to taste, save the file, and start a new game.
-- The note after each line explains what it does; the /* */ after a value is its original default, if you want it back.
--====================================================================================================================
REPLACE INTO Defines (Name, Value) VALUES

-- ANIMATION SPEED  (percent, 100 = vanilla. Air = aircraft; non-air = land + naval.)
('GD_AIR_ANIMATION_SPEED',               240),
('GD_NON_AIR_ANIMATION_SPEED',           160),

-- TILE CONQUEST  (GAMEOPTION_GAIA_TILE_CONQUEST. Capital radii are built-in defaults 3/1; the Sapiens modpack widens them to 4/2.)
('GD_TILE_CONQUEST_MAX_RANGE',             6),  -- max range (tiles) from the nearest non-razing friendly city
('GD_TILE_CONQUEST_CITY_RADIUS',           3),  -- working radius of a non-capital city
('GD_TILE_CONQUEST_SAFE_CITY_RADIUS',      1),  -- safe (unconquerable) ring around a non-capital city
('GD_TILE_CONQUEST_NO_CITYSTATES',         1),  -- City-States cannot conquer tiles

-- RETURNING FOG  (GAMEOPTION_GAIA_RETURNING_FOG)
('GD_RETURNING_FOG_PLOTS_PER_TURN',        3),  -- max tiles a team re-fogs per turn
('GD_RETURNING_FOG_PROBABILITY',          33),  -- % chance each eligible (frontier) tile re-fogs
('GD_RETURNING_FOG_KEEP_COAST',            1),  -- coast tiles stay revealed
('GD_RETURNING_FOG_CITY_RADIUS',           1),  -- tiles within this radius of a revealed city stay revealed
('GD_RETURNING_FOG_AFFECT_AI',             1),  -- all teams re-fog (symmetric); 0 = only human teams

-- AI GOLD SPENDING
('GD_AI_GOLD_RESERVE_BASE',               50),  -- gold the AI always keeps in the bank. It spends in the order upgrade units, buy tiles, rush-buy production, and stops when the treasury would drop below this. The figure grows with each era (50 in the Ancient era up to 400 in the Information era) and with slower game speeds. Higher = the AI hoards more and buys less.
('GD_AI_GOLD_RESERVE_DEFICIT_TURNS',       3),  -- while the AI is LOSING gold each turn, it keeps back this many turns' worth of the shortfall on top of the reserve above, so it stops buying and avoids going bankrupt (which would force it to disband units). 0 = off.

-- RELIGION & DIPLOMACY
('GD_OPINION_WEIGHT_SHARED_RELIGION',    -2),  -- opinion bonus between two civs that share a majority religion FOUNDED BY SOMEONE ELSE. Scales with the era's religion emphasis (-2 early, -12 at the Medieval peak). More negative = friendlier; 0 = off.
('GD_RELIGION_PURGE_THRESHOLD_PERCENT',  40),  -- how much of your empire must fall to a rival faith before the AI drops everything to buy Inquisitors and purge its own cities. Lower = reacts sooner. 100 = never, the vanilla ordering.
('GD_LUXURY_BAN_FRIEND_VOTING_SCORE',   -20),  -- how firmly the AI stands by its friends when the World Congress votes to ban a luxury they own. At -20, friends that neither own nor import it vote no unless they are also friends with whoever proposed the ban. -10 = vanilla (they usually vote yes); -35 or lower = they always vote no.
('GD_DEFENSIVE_PACT_DETERRENCE_PERCENT', 100),  -- how much a civ's Defensive Pact partners deter an AI from attacking it. Partners that would join the war count toward that civ's strength, less the farther they are from the attacker. 0 = the AI ignores pacts (vanilla); 200 = partners count double.
('GD_DEFENSIVE_PACT_FRIEND_WAR_PERCENT',  50),  -- how much an AI holds back from attacking a civ whose Defensive Pact partner is its friend, since that friend would join the war against it. Its war plans against that civ are multiplied by this percent for each such friend. 100 = no effect (vanilla); 0 = practically never.
('GD_OPINION_WEIGHT_ATTACKED_FRIENDS_ALLY', 20),  -- opinion penalty, seen by every civ, for attacking a civ whose Defensive Pact partner is your friend, since that friend is pulled into the war against you. Fades over time. 0 = off; 40 = the same fading penalty as declaring war on a friend directly.

-- BARBARIANS
('GD_BARBARIAN_HEAL_RATE',                 0),  -- HP per turn a barbarian LAND unit self-heals on barbarian or unowned land. 0 = vanilla (no self-heal); Sapiens uses 5.

-- CITY FOUNDING
('GD_CITY_MIN_FOOD_FLAT',                  2),  -- food floor on a FLAT city centre; 3 grants 3 food on flat centres (Sapiens setting). 0 = off.
('GD_CITY_STARTING_RINGS',                 1),  -- rings of tiles a new city claims at founding (0 = centre only, 1 = the 6 adjacent tiles, 2 = 18); unowned plots only.

-- CITY WORK RANGE
('GD_CITY_WORK_RANGE_MAX',                  5),   /* 3 */

-- ENEMY BLOCKADES  (radius in which enemy units deny your cities' worked tiles; clamped 0-3)
('GD_BLOCKADE_RANGE_LAND',                 0),  -- enemy LAND units. 0 = vanilla (land units never blockade); Sapiens uses 1.
('GD_BLOCKADE_RANGE_NAVAL',                2),  -- enemy NAVAL units. 2 = vanilla; Sapiens uses 1.

-- PURCHASING  (credit production already invested in an item when you buy that same item)
('GD_PURCHASE_DISCOUNT_BUILDINGS',         0),  -- % of a building's invested production credited to its gold/faith purchase price. 0 = vanilla (no credit); Sapiens uses 50.
('GD_PURCHASE_DISCOUNT_UNITS',             0),  -- the same credit for gold-purchased units. 0 = vanilla.

-- SLOW TECH  (GAMEOPTION_GAIA_SLOW_TECH)
('GD_ERA_RESEARCH_COST_INCREASE',         10),  -- percent a technology's cost rises for each era up to and including its own, at most 15: 10 = +10% in the Ancient Era, +30% in the Medieval Era, 1.8 times in the Information Era. 0 = no change.

-- TECH CATCH-UP
('GD_TECH_CATCHUP_EXPONENT',             1.0),  -- FLOAT. Bends the known-tech research discount toward civs that fall behind: 1.0 = vanilla (linear), higher = stronger late-game catch-up; Sapiens uses 1.6.

-- INTRINSIC GAME CAPS  (the DLL derives these from the content itself -- no rows to set here)
--   Max spies per civ  = how many Civilization_SpyNames that civ ships (every spy needs a name of its own).
--   Max active religions = the tightest belief pool a religion must draw from (Founder / Enhancer / Follower /
--   Place of Worship / Pantheon), less one for a bonus-belief trait like Byzantium's. Vanilla works out at 7.
--   Raise either by adding beliefs or spy names; there is nothing to edit here.

-- TRADE ROUTES  (range = GD_TR_BASE_LAND_DISTANCE x the world size's iTradeRouteDistanceMod, plus tech extras;
-- duration = GD_TR_BASE_TARGET_TURNS x the game speed's iTradeRouteDurationPercent.)
('GD_TR_BASE_LAND_DISTANCE',              10),  -- base range of LAND routes in tiles; sea routes derive their range from it via GD_TR_SEA_MODIFIER_VS_LAND.
('GD_TR_BASE_TARGET_TURNS',               30),  -- turns a route runs before it expires and picks a new destination.
('GD_TR_SEA_MODIFIER_VS_LAND',           100),  -- extra % yield AND range of SEA routes over land (sea range = land x (100+this)/100). 100 = vanilla: double yield, range 20. Sapiens uses 50.
('GD_TR_BASE_FOOD_VALUE',                300),  -- base food (x100) carried by an internal food route.
('GD_TR_BASE_PRODUCTION_VALUE',          300),  -- base production (x100) carried by an internal production route.

-- UNIT STACKING  (extra stacking slots on city plots; clamped 0-2)
('GD_EXTRA_UNITS_CITIES',                  0),  -- extra slots on any city plot. 0 = vanilla; Sapiens uses 1. Also the floor for the capital.
('GD_EXTRA_UNITS_CAPITAL',                 0),  -- the capital uses max(this, GD_EXTRA_UNITS_CITIES). Sapiens uses 1.

-- WAR & PEACE
('GD_WAR_MINIMUM_TURNS_MAJOR',             5),  -- min turns the AI stays at war with a MAJOR before making peace. Sapiens uses 6.
('GD_WAR_MINIMUM_TURNS_MINOR',             0),  -- min turns at war with a city-state. 0 = vanilla; Sapiens uses 1.
('GD_PEACE_BLOCK_TURNS_CAPTURE_CITY',      0),  -- turns no peace treaty can be signed after either side conquers a city. 0 = off (vanilla).
('GD_PEACE_BLOCK_TURNS_CAPTURE_CAPITAL',   0),  -- same, when the captured city is the victim's ORIGINAL capital (larger window applies). 0 = off; Sapiens uses 1.
('GD_WAR_CONQUEST_PEACE_TURNS',           20),  -- turns of war after which an AI out for conquest will talk peace: a white peace while its war is going nowhere, its own terms while it is winning. 0 = vanilla.
('GD_WAR_STALEMATE_NO_UNIT_TURNS',        20),  -- turns with no unit killed by either side that make the AI offer and accept a white peace. 0 = vanilla.
('GD_WAR_STALEMATE_NO_CITY_TURNS',        40);  -- turns with no city taken by either side that make the AI offer and accept a white peace. 0 = vanilla.

--====================================================================================================================
UPDATE Sapiens_DBUpdates SET Value = 1 WHERE Name = 'USER_SETTINGS';
