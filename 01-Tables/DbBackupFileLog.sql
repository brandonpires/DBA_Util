USE DBA_Util
GO


IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'DbBackupFileLog')
BEGIN
    CREATE TABLE DbBackupFileLog
        (all_db_backups_id          INT
         ,status                    VARCHAR(7)
         ,record_date_time          DATETIME)
END
GO


IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('DbBackupFileLog') AND name = 'type')
BEGIN
    ALTER TABLE DbBackupFileLog
        ADD type VARCHAR(15)
END
GO