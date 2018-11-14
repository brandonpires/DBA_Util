USE DBA_Util
GO


IF EXISTS (SELECT 1 FROM sys.views WHERE name = 'DbBackupsInfoView')
BEGIN
    DROP VIEW DbBackupsInfoView
END
GO


CREATE VIEW DbBackupsInfoView
WITH ENCRYPTION
AS
SELECT database_id
       ,database_name
       ,file_path
       ,type AS backup_type
       ,status
       ,record_date_time
FROM AllDbBackups db
     JOIN DbBackupFileLog bfl ON db.all_db_backups_id = bfl.all_db_backups_id
GO