USE DBA_Util
GO


IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'AllIndexes_Delete')
BEGIN
    DROP PROCEDURE AllIndexes_Delete 
END
GO


CREATE PROCEDURE AllIndexes_Delete
WITH ENCRYPTION
AS
BEGIN
    -- Deletes logs and records of indexes for databases that no longer exist or are not online
    DELETE FROM log
    FROM DBA_Util.dbo.IndexDefragmentationLog log
    WHERE NOT EXISTS (SELECT 1
                      FROM DBA_Util.dbo.AllIndexes indexes
                           JOIN sys.databases dbs ON indexes.database_id = dbs.database_id
                      WHERE log.all_indexes_id = indexes.all_indexes_id
                            AND dbs.state = 0)

    DELETE FROM ai
    FROM DBA_Util.dbo.AllIndexes ai
    WHERE NOT EXISTS (SELECT 1
                      FROM sys.databases dbs
                      WHERE ai.database_id = dbs.database_id
                            AND dbs.state = 0)



    DECLARE @sql                VARCHAR(MAX)
            ,@db_name_cursor    SYSNAME


    -- gets all online database names sans tempdb
    DECLARE db_names CURSOR LOCAL FOR SELECT name
                                      FROM sys.databases
                                      WHERE name != 'tempdb'
                                            AND state = 0

    OPEN db_names
    FETCH NEXT FROM db_names INTO @db_name_cursor

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Deletes logs and records of indexes that no longer exist
        SET @sql = 'USE [' + @db_name_cursor + ']' + CHAR(10)
                + ' DELETE FROM log' + CHAR(10)
                + ' FROM DBA_Util.dbo.IndexDefragmentationLog log' + CHAR(10)
                + '      JOIN DBA_Util.dbo.AllIndexes ai ON log.all_indexes_id = ai.all_indexes_id' + CHAR(10)
                + ' WHERE NOT EXISTS (SELECT 1' + CHAR(10)
                + '                   FROM sys.indexes i' + CHAR(10)
                + '                   WHERE ai.object_id = i.object_id' + CHAR(10)
                + '                         AND ai.index_id = i.index_id)' + CHAR(10)
                + '       AND ai.database_id = DB_ID()' + CHAR(10)
                + '' + CHAR(10)
                + ' DELETE FROM ai' + CHAR(10)
                + ' FROM DBA_Util.dbo.AllIndexes ai' + CHAR(10)
                + ' WHERE NOT EXISTS (SELECT 1' + CHAR(10)
                + '                   FROM sys.indexes i' + CHAR(10)
                + '                   WHERE ai.object_id = i.object_id' + CHAR(10)
                + '                         AND ai.index_id = i.index_id)' + CHAR(10)
                + '       AND ai.database_id = DB_ID()'
        EXEC (@sql)

        FETCH NEXT FROM db_names INTO @db_name_cursor
    END

    CLOSE db_names
    DEALLOCATE db_names
END
GO