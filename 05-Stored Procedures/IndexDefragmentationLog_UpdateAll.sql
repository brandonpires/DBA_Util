USE DBA_Util
GO


IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'IndexDefragmentationLog_UpdateAll')
BEGIN
    DROP PROCEDURE IndexDefragmentationLog_UpdateAll
END
GO


CREATE PROCEDURE IndexDefragmentationLog_UpdateAll
WITH ENCRYPTION
AS
BEGIN
    DECLARE @sql                       VARCHAR(MAX)
            ,@db_id_cursor             VARCHAR(3)
            ,@db_name_cursor           SYSNAME

    -- gets all online database names sans tempdb
    DECLARE dbs CURSOR LOCAL FOR SELECT CONVERT(VARCHAR(3), database_id), name
                                      FROM sys.databases
                                      WHERE name != 'tempdb'
                                            AND state = 0

    OPEN dbs
    FETCH NEXT FROM dbs INTO @db_id_cursor, @db_name_cursor

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @sql = 'USE [' + @db_name_cursor + ']' + CHAR(10)
                + ' UPDATE log' + CHAR(10)
                + ' SET post_avg_fragmentation_pct = avg_fragmentation_in_percent' + CHAR(10)
                + ' FROM DBA_Util.dbo.IndexDefragmentationLog log' + CHAR(10)
                + '      JOIN DBA_Util.dbo.AllIndexes ai ON log.all_indexes_id = ai.all_indexes_id' + CHAR(10)
                + '      JOIN (SELECT database_id' + CHAR(10)
                + '                   ,object_id' + CHAR(10)
                + '                   ,index_id' + CHAR(10)
                + '                   ,MAX(avg_fragmentation_in_percent) AS avg_fragmentation_in_percent' + CHAR(10)
                + '            FROM sys.dm_db_index_physical_stats(' + @db_id_cursor + ', NULL, NULL, NULL,''SAMPLED'')' + CHAR(10)
                + '            GROUP BY database_id' + CHAR(10)
                + '                     ,object_id' + CHAR(10)
                + '                     ,index_id) ps ON ai.database_id = ps.database_id' + CHAR(10)
                + '                                      AND ai.object_id = ps.object_id' + CHAR(10)
                + '                                      AND ai.index_id = ps.index_id' + CHAR(10)
                + ' WHERE log.post_avg_fragmentation_pct IS NULL' + CHAR(10)
                + '       AND log.type IS NOT NULL' + CHAR(10)
                + '       AND record_date_time = (SELECT MAX(record_date_time)' + CHAR(10)
                + '                               FROM DBA_Util.dbo.IndexDefragmentationLog)' + CHAR(10)

        EXEC (@sql)

        FETCH NEXT FROM dbs INTO @db_id_cursor, @db_name_cursor
    END

    CLOSE dbs
    DEALLOCATE dbs
END
GO