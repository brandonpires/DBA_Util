USE DBA_Util
GO


IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'AllIndexes_Update')
BEGIN
    DROP PROCEDURE AllIndexes_Update 
END
GO


CREATE PROCEDURE AllIndexes_Update
WITH ENCRYPTION
AS
BEGIN
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
         --  Updates the state of each index
         SET @sql = 'USE [' + @db_name_cursor + ']' + CHAR(10)
                + ' UPDATE ai' + CHAR(10)
                + ' SET ai.state = CASE i.is_disabled WHEN 0 THEN ''Enabled'' ELSE ''Disabled'' END' + CHAR(10)
                + ' FROM DBA_Util.dbo.AllIndexes ai' + CHAR(10)
                + '      JOIN sys.indexes i ON ai.object_id = i.object_id' + CHAR(10)
                + '                            AND ai.index_id = i.index_id' + CHAR(10)
                + ' WHERE ai.database_id = DB_ID()' + CHAR(10)
        EXEC (@sql)

        FETCH NEXT FROM db_names INTO @db_name_cursor
    END

    CLOSE db_names
    DEALLOCATE db_names


    -- updates last used statistics
    UPDATE ai
    SET ai.last_user_seek = ISNULL(us.last_user_seek, ai.last_user_seek)
        ,ai.last_user_scan = ISNULL(us.last_user_scan, ai.last_user_scan)
        ,ai.last_user_lookup = ISNULL(us.last_user_lookup, ai.last_user_lookup)
        ,ai.last_user_update = ISNULL(us.last_user_update, ai.last_user_update)
    FROM DBA_Util.dbo.AllIndexes ai
         JOIN master.sys.dm_db_index_usage_stats us ON ai.database_id = us.database_id
                                                       AND ai.object_id = us.object_id
                                                       AND ai.index_id = us.index_id
END
GO