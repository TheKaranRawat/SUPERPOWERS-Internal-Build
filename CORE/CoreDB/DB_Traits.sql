-- written by GAIA using Notepad++
CREATE TABLE IF NOT EXISTS Sapiens_DBUpdates (Name TEXT PRIMARY KEY, Value INTEGER DEFAULT 0);
INSERT OR IGNORE INTO Sapiens_DBUpdates (Name) VALUES ('DB_Traits');
--====================================================================================================================
-- TRAIT TABLE EXTENSIONS
--====================================================================================================================
-- Only game-start one-shots and refinements of vanilla Traits columns that genuinely belong to the TRAIT live here;
-- per-civ effects are POLICY_GAIA_<CIV> trait-policies.

CREATE TABLE IF NOT EXISTS _Traits_Extensions (
	TraitType								TEXT PRIMARY KEY REFERENCES Traits(Type),

	bFreePantheon							INTEGER DEFAULT 0,
	-- Civ founds a Pantheon for free / without the usual faith threshold on founding its first city (Celts-style).
	bUniqueLuxuryRequiresCoastal			INTEGER DEFAULT 0
	-- The trait's unique luxuries go only to coastal cities founded after the capital.
);

-- Trait -> policy pairing: the listed policy is granted free at game start to the civ owning the trait
-- (POLICY_GAIA_<CIV>).
-- Being listed here IS the authorization.
CREATE TABLE IF NOT EXISTS _Trait_GrantedPolicy (
	TraitType	TEXT PRIMARY KEY NOT NULL REFERENCES Traits(Type),
	PolicyType	TEXT NOT NULL REFERENCES Policies(Type)
);

--====================================================================================================================
-- NEW TRAIT TABLES
--====================================================================================================================

--====================================================================================================================
-- Build-permission + raze-yield traits
--====================================================================================================================

-- Trait grants a unit class the ability to perform a build it otherwise couldn't
CREATE TABLE IF NOT EXISTS _Trait_UnitClassBuilds (
	TraitType		TEXT REFERENCES Traits(Type),
	UnitClassType	TEXT REFERENCES UnitClasses(Type),
	BuildType		TEXT REFERENCES Builds(Type),
	PRIMARY KEY (TraitType, UnitClassType, BuildType)
);

-- Trait forbids a build entirely; the rows of exclusive replacement improvements are derived at load.
CREATE TABLE IF NOT EXISTS _Trait_NoBuild (
	TraitType	TEXT REFERENCES Traits(Type),
	BuildType	TEXT REFERENCES Builds(Type),
	PRIMARY KEY (TraitType, BuildType)
);

--====================================================================================================================
UPDATE Sapiens_DBUpdates SET Value = 1 WHERE Name = 'DB_Traits';
