USE DBA_Util
GO


IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'AllDbBackups')
BEGIN
    CREATE TABLE AllDbBackups
        (all_db_backups_id          INT         IDENTITY(1, 1)
         ,database_id               INT
         ,database_name             SYSNAME
         ,file_path                 VARCHAR(4000)
         ,CONSTRAINT PK_AllDbBackups PRIMARY KEY CLUSTERED (all_db_backups_id))
END
GO