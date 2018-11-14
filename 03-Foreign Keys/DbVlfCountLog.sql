USE DBA_Util
GO

IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'DbVlfCountLog')
   AND EXISTS (SELECT 1 FROM sys.tables WHERE name = 'AllDbFiles')
   AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_DbVlfCountLog_AllDbFiles')
BEGIN
ALTER TABLE DbVlfCountLog
    ADD CONSTRAINT FK_DbVlfCountLog_AllDbFiles FOREIGN KEY (all_dbfiles_id)
        REFERENCES AllDbFiles (all_dbfiles_id)
END
GO