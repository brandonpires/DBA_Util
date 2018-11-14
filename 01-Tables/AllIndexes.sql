USE DBA_Util
GO


IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'AllIndexes')
BEGIN
    CREATE TABLE AllIndexes
        (all_indexes_id             INT         IDENTITY(1, 1)
         ,database_id               INT
         ,database_name             SYSNAME
         ,schema_id                 INT
         ,schema_name               SYSNAME
         ,object_id                 INT
         ,table_name                SYSNAME
         ,index_id                  INT
         ,index_name                SYSNAME
         ,state                     VARCHAR(8)
         ,type                      VARCHAR(13)
         ,last_user_seek            DATETIME
         ,last_user_scan            DATETIME
         ,last_user_lookup          DATETIME
         ,last_user_update          DATETIME
         ,CONSTRAINT PK_AllIndexes PRIMARY KEY CLUSTERED (all_indexes_id))
END
GO