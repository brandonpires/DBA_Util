USE DBA_Util
GO

IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'DbFileSizeLog')
   AND EXISTS (SELECT 1 FROM sys.tables WHERE name = 'AllDbFiles')
   AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_DbFileSizeLog_AllDbFiles')
BEGIN
ALTER TABLE DbFileSizeLog
    ADD CONSTRAINT FK_DbFileSizeLog_AllDbFiles FOREIGN KEY (all_dbfiles_id)
        REFERENCES AllDbFiles (all_dbfiles_id)
END
GO