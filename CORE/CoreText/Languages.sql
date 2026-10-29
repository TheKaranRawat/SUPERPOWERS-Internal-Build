-- written by GAIA using Notepad++
CREATE TABLE IF NOT EXISTS Sapiens_DBUpdates (Name TEXT PRIMARY KEY, Value INTEGER DEFAULT 0);
INSERT OR IGNORE INTO Sapiens_DBUpdates (Name) VALUES ('Languages');
--====================================================================================================================
-- PT_BR
--====================================================================================================================
CREATE VIEW IF NOT EXISTS Localization.Language_PT_BR AS SELECT Tag, Text, Gender, Plurality FROM LocalizedText WHERE Language = 'pt_BR';
CREATE TRIGGER IF NOT EXISTS Localization.Language_PT_BR_insert INSTEAD OF INSERT ON Language_PT_BR BEGIN INSERT INTO LocalizedText(Language, Tag, Text, Gender, Plurality) VALUES('pt_BR', NEW.Tag, NEW.Text, NEW.Gender, NEW.Plurality); END;
CREATE TRIGGER IF NOT EXISTS Localization.Language_PT_BR_update INSTEAD OF UPDATE ON Language_PT_BR BEGIN UPDATE LocalizedText SET Text = NEW.Text, Gender = NEW.Gender, Plurality = NEW.Plurality WHERE Language = 'pt_BR' AND Tag = NEW.Tag; END;
CREATE TRIGGER IF NOT EXISTS Localization.Language_PT_BR_delete INSTEAD OF DELETE ON Language_PT_BR BEGIN DELETE FROM LocalizedText WHERE Language = 'pt_BR' AND Tag = OLD.Tag; END;
--====================================================================================================================
-- ZH_CN
--====================================================================================================================
CREATE VIEW IF NOT EXISTS Localization.Language_zh_CN AS SELECT Tag, Text, Gender, Plurality FROM LocalizedText WHERE Language = 'zh_CN';
CREATE TRIGGER IF NOT EXISTS Localization.Language_zh_CN_insert INSTEAD OF INSERT ON Language_zh_CN BEGIN INSERT INTO LocalizedText(Language, Tag, Text, Gender, Plurality) VALUES('zh_CN', NEW.Tag, NEW.Text, NEW.Gender, NEW.Plurality); END;
CREATE TRIGGER IF NOT EXISTS Localization.Language_zh_CN_update INSTEAD OF UPDATE ON Language_zh_CN BEGIN UPDATE LocalizedText SET Text = NEW.Text, Gender = NEW.Gender, Plurality = NEW.Plurality WHERE Language = 'zh_CN' AND Tag = NEW.Tag; END;
CREATE TRIGGER IF NOT EXISTS Localization.Language_zh_CN_delete INSTEAD OF DELETE ON Language_zh_CN BEGIN DELETE FROM LocalizedText WHERE Language = 'zh_CN' AND Tag = OLD.Tag; END;
--====================================================================================================================
UPDATE Sapiens_DBUpdates SET Value = 1 WHERE Name = 'Languages';
