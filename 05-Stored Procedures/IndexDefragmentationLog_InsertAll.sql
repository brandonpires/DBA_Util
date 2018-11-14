USE DBA_Util
GO


IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'IndexDefragmentationLog_InsertAll')
BEGIN
    DROP PROCEDURE IndexDefragmentationLog_InsertAll
END
GO


CREATE PROCEDURE IndexDefragmentationLog_InsertAll
WITH ENCRYPTION
AS
BEGIN
    DECLARE @sql                       VARCHAR(MAX)
            ,@db_id_cursor             VARCHAR(3)
            ,@db_name_cursor           SYSNAME
            ,@record_date_time         DATETIME
            ,@default_record_date_time VARCHAR(10)

    SET @record_date_time = GETDATE()
    SET @default_record_date_time = '1/1/1900'


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
                + ' INSERT INTO DBA_Util.dbo.IndexDefragmentationLog (all_indexes_id' + CHAR(10)
                + '                                                   ,index_size_mb' + CHAR(10)
                + '                                                   ,pre_avg_fragmentation_pct' + CHAR(10)
                + '                                                   ,fill_factor' + CHAR(10)
                + '                                                   ,record_date_time)' + CHAR(10)
                + ' SELECT ai.all_indexes_id' + CHAR(10)
                + '        ,SUM(ps.record_count * avg_record_size_in_bytes / 1024 / 1024)' + CHAR(10) -- converts bytes to megabytes
                + '        ,MAX(ps.avg_fragmentation_in_percent)' + CHAR(10)
                + '        ,i.fill_factor' + CHAR(10)
                + '        ,''' + @default_record_date_time + '''' + CHAR(10)
                + ' FROM DBA_Util.dbo.AllIndexes ai' + CHAR(10)
                + '      JOIN sys.dm_db_index_physical_stats(' + @db_id_cursor + ', NULL, NULL, NULL,''SAMPLED'') ps ON ai.database_id = ps.database_id' + CHAR(10)
                + '                                                                                             AND ai.object_id = ps.object_id' + CHAR(10)
                + '                                                                                             AND ai.index_id = ps.index_id' + CHAR(10)
                + '      JOIN sys.indexes i ON ai.object_id = i.object_id' + CHAR(10)
                + '                            AND ai.index_id = i.index_id' + CHAR(10)
                + ' WHERE ai.state = ''Enabled''' + CHAR(10)
                + '       AND EXISTS (SELECT 1' + CHAR(10)
                + '                   FROM sys.databases dbs' + CHAR(10)
                + '                   WHERE ai.database_id = dbs.database_id' + CHAR(10)
                + '                         AND dbs.state = 0)' + CHAR(10)
                + ' GROUP BY ai.all_indexes_id' + CHAR(10)
                + '          ,i.fill_factor' + CHAR(10)

        EXEC (@sql)

        FETCH NEXT FROM dbs INTO @db_id_cursor, @db_name_cursor
    END

    CLOSE dbs
    DEALLOCATE dbs


    UPDATE IndexDefragmentationLog
    SET record_date_time = @record_date_time
    WHERE record_date_time = @default_record_date_time
END
GO