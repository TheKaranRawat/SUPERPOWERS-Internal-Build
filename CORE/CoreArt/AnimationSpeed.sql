-- written by GAIA using Notepad++
CREATE TABLE IF NOT EXISTS Sapiens_DBUpdates (Name TEXT PRIMARY KEY, Value INTEGER DEFAULT 0);
INSERT OR IGNORE INTO Sapiens_DBUpdates (Name) VALUES ('AnimationSpeed');
--====================================================================================================================
-- ANIMATION SPEED -- engine
--====================================================================================================================

--====================================================================================================================
-- NORMALIZE
--====================================================================================================================
INSERT OR REPLACE INTO Defines (Name, Value) SELECT 'MOD_NON_AIR_ANIMATION_SPEED',
       (Value * 0.5 / (SELECT TurnRateMin FROM ArtDefine_UnitMemberCombats WHERE UnitMemberType = 'ART_DEF_UNIT_MEMBER_KNIGHT'))
FROM Defines WHERE Name = 'GD_NON_AIR_ANIMATION_SPEED';

INSERT OR REPLACE INTO Defines (Name, Value) SELECT 'MOD_AIR_ANIMATION_SPEED',
       (Value * 2.0 / (SELECT MoveRate FROM ArtDefine_UnitMemberCombats WHERE UnitMemberType = 'ART_DEF_UNIT_MEMBER_STEALTHBOMBER'))
FROM Defines WHERE Name = 'GD_AIR_ANIMATION_SPEED';

--====================================================================================================================
-- FASTER ANIMATIONS
--====================================================================================================================

-- ArtDefine_UnitMemberCombats
UPDATE ArtDefine_UnitMemberCombats
SET
    TurnRateMin = CASE
        WHEN MoveRate > 0 AND MoveRate < 2.88 THEN TurnRateMin * (SELECT Value FROM Defines WHERE Name = 'MOD_AIR_ANIMATION_SPEED') / 100.0
        WHEN MoveRate IS NULL AND TurnRateMin > 0 THEN TurnRateMin * (SELECT Value FROM Defines WHERE Name = 'MOD_NON_AIR_ANIMATION_SPEED') / 100.0
        ELSE TurnRateMin
    END,
    TurnRateMax = CASE
        WHEN MoveRate > 0 AND MoveRate < 2.88 THEN TurnRateMax * (SELECT Value FROM Defines WHERE Name = 'MOD_AIR_ANIMATION_SPEED') / 100.0
        WHEN MoveRate IS NULL AND TurnRateMax > 0 THEN TurnRateMax * (SELECT Value FROM Defines WHERE Name = 'MOD_NON_AIR_ANIMATION_SPEED') / 100.0
        ELSE TurnRateMax
    END,
    MoveRate = CASE
        WHEN MoveRate > 0 AND MoveRate < 2.88 THEN MoveRate * (SELECT Value FROM Defines WHERE Name = 'MOD_AIR_ANIMATION_SPEED') / 100.0
        ELSE MoveRate
    END,
    ShortMoveRate = CASE
        WHEN MoveRate IS NULL AND ShortMoveRate > 0 THEN ShortMoveRate * (SELECT Value FROM Defines WHERE Name = 'MOD_NON_AIR_ANIMATION_SPEED') / 100.0
        ELSE ShortMoveRate
    END,
    TurnFacingRateMin = CASE
        WHEN MoveRate IS NULL AND TurnFacingRateMin > 0 THEN TurnFacingRateMin * (SELECT Value FROM Defines WHERE Name = 'MOD_NON_AIR_ANIMATION_SPEED') / 100.0
        ELSE TurnFacingRateMin
    END,
    TurnFacingRateMax = CASE
        WHEN MoveRate IS NULL AND TurnFacingRateMax > 0 THEN TurnFacingRateMax * (SELECT Value FROM Defines WHERE Name = 'MOD_NON_AIR_ANIMATION_SPEED') / 100.0
        ELSE TurnFacingRateMax
    END;

-- MovementRates
UPDATE MovementRates
SET
    TotalTime = TotalTime / ((SELECT Value FROM Defines WHERE Name = 'MOD_NON_AIR_ANIMATION_SPEED') / 100.0),
    EaseIn    = EaseIn    / ((SELECT Value FROM Defines WHERE Name = 'MOD_NON_AIR_ANIMATION_SPEED') / 100.0),
    EaseOut   = EaseOut   / ((SELECT Value FROM Defines WHERE Name = 'MOD_NON_AIR_ANIMATION_SPEED') / 100.0);

UPDATE MovementRates SET TotalTime = 0.01 WHERE Type = 'AIR_REBASE';

-- AnimationPaths
UPDATE AnimationPaths SET MissionPath = 0 WHERE Type IN ('ANIMATIONPATH_AIRFADEIN', 'ANIMATIONPATH_AIRFADEOUT');

--====================================================================================================================
-- TRIGGER
--====================================================================================================================
CREATE TRIGGER IF NOT EXISTS GAIA_AnimationSpeed_ArtDefine
AFTER INSERT ON ArtDefine_UnitMemberCombats
WHEN NOT EXISTS (
    SELECT 1 FROM ArtDefine_UnitMemberCombats AS a
    WHERE a.UnitMemberType <> NEW.UnitMemberType
      AND a.MoveRate IS NEW.MoveRate AND a.ShortMoveRate IS NEW.ShortMoveRate
      AND a.TurnRateMin IS NEW.TurnRateMin AND a.TurnRateMax IS NEW.TurnRateMax
      AND a.TurnFacingRateMin IS NEW.TurnFacingRateMin AND a.TurnFacingRateMax IS NEW.TurnFacingRateMax
)
BEGIN
    UPDATE ArtDefine_UnitMemberCombats
    SET
        TurnRateMin = CASE
            WHEN NEW.MoveRate > 0 AND NEW.MoveRate < 2.88 THEN TurnRateMin * (SELECT Value FROM Defines WHERE Name = 'MOD_AIR_ANIMATION_SPEED') / 100.0
            WHEN NEW.MoveRate IS NULL AND TurnRateMin > 0 THEN TurnRateMin * (SELECT Value FROM Defines WHERE Name = 'MOD_NON_AIR_ANIMATION_SPEED') / 100.0
            ELSE TurnRateMin
        END,
        TurnRateMax = CASE
            WHEN NEW.MoveRate > 0 AND NEW.MoveRate < 2.88 THEN TurnRateMax * (SELECT Value FROM Defines WHERE Name = 'MOD_AIR_ANIMATION_SPEED') / 100.0
            WHEN NEW.MoveRate IS NULL AND TurnRateMax > 0 THEN TurnRateMax * (SELECT Value FROM Defines WHERE Name = 'MOD_NON_AIR_ANIMATION_SPEED') / 100.0
            ELSE TurnRateMax
        END,
        MoveRate = CASE
            WHEN NEW.MoveRate > 0 AND NEW.MoveRate < 2.88 THEN MoveRate * (SELECT Value FROM Defines WHERE Name = 'MOD_AIR_ANIMATION_SPEED') / 100.0
            ELSE MoveRate
        END,
        ShortMoveRate = CASE
            WHEN NEW.MoveRate IS NULL AND ShortMoveRate > 0 THEN ShortMoveRate * (SELECT Value FROM Defines WHERE Name = 'MOD_NON_AIR_ANIMATION_SPEED') / 100.0
            ELSE ShortMoveRate
        END,
        TurnFacingRateMin = CASE
            WHEN NEW.MoveRate IS NULL AND TurnFacingRateMin > 0 THEN TurnFacingRateMin * (SELECT Value FROM Defines WHERE Name = 'MOD_NON_AIR_ANIMATION_SPEED') / 100.0
            ELSE TurnFacingRateMin
        END,
        TurnFacingRateMax = CASE
            WHEN NEW.MoveRate IS NULL AND TurnFacingRateMax > 0 THEN TurnFacingRateMax * (SELECT Value FROM Defines WHERE Name = 'MOD_NON_AIR_ANIMATION_SPEED') / 100.0
            ELSE TurnFacingRateMax
        END
    WHERE UnitMemberType = NEW.UnitMemberType;
END;
--====================================================================================================================
UPDATE Sapiens_DBUpdates SET Value = 1 WHERE Name = 'AnimationSpeed';
