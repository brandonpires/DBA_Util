USE DBA_Util
GO

IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'DbBackupFileLog')
   AND EXISTS (SELECT 1 FROM sys.tables WHERE name = 'AllDbBackups')
   AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_DbBackupFileLog_AllDbs')
BEGIN
ALTER TABLE DbBackupFileLog
    ADD CONSTRAINT FK_DbBackupFileLog_AllDbs FOREIGN KEY (all_db_backups_id)
        REFERENCES AllDbBackups (all_db_backups_id)
END
GO