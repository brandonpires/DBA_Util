USE DBA_Util
GO


IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'AllDbBackups_DeleteOld')
BEGIN
    DROP PROCEDURE AllDbBackups_DeleteOld
END
GO


CREATE PROCEDURE AllDbBackups_DeleteOld
WITH ENCRYPTION
AS
BEGIN
    DELETE FROM all_backups
    FROM AllDbBackups all_backups
    WHERE NOT EXISTS (SELECT 1
                      FROM DbBackupFileLog backup_log
                      WHERE all_backups.all_db_backups_id = backup_log.all_db_backups_id)
END
GO