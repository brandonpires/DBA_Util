USE DBA_Util
GO


IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'DbBackupFileLog_InsertNew')
BEGIN
    DROP PROCEDURE DbBackupFileLog_InsertNew
END
GO


CREATE PROCEDURE DbBackupFileLog_InsertNew (@db_name  SYSNAME
                                            ,@status  VARCHAR(7)
                                            ,@type    VARCHAR(15))
WITH ENCRYPTION
AS
BEGIN
    DECLARE @device_name SYSNAME
    SET @device_name = @db_name + '_backup_device'

    INSERT INTO DbBackupFileLog (all_db_backups_id
                                 ,status
                                 ,record_date_time
                                 ,type)
    SELECT all_db_backups_id
           ,@status
           ,GETDATE()
           ,@type
    FROM AllDbBackups
    WHERE database_name = @db_name
          AND file_path = (SELECT physical_name
                           FROM sys.backup_devices
                           WHERE name = @device_name)
END
GO