USE DBA_Util
GO


IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'DefragmentIndexes')
BEGIN
    DROP PROCEDURE DefragmentIndexes 
END
GO


CREATE PROCEDURE DefragmentIndexes (@fragment_pct_floor     FLOAT = 0
                                    ,@fragment_pct_ceiling  FLOAT = 100
                                    ,@index_size_mb_floor   FLOAT = 0
                                    ,@index_size_mb_ceiling FLOAT = NULL
                                    ,@defragment_type       VARCHAR(10) = 'REBUILD')
WITH ENCRYPTION
AS
BEGIN
    DECLARE @all_indexes_id INT
            ,@db_name       SYSNAME
            ,@schema_name   SYSNAME
            ,@table_name    SYSNAME
            ,@index_name    SYSNAME
            ,@sql           NVARCHAR(4000)
            ,@start_time    DATETIME
            ,@end_time      DATETIME

    SET @defragment_type = UPPER(@defragment_type)

    IF @defragment_type NOT IN ('REBUILD', 'REORGANIZE')
    BEGIN
        SET @defragment_type = 'REBUILD'
    END

    -- gets all indexes that match the criteria for a rebuild or a reorganize
    DECLARE names CURSOR STATIC LOCAL FOR SELECT log.all_indexes_id
                                                 ,database_name
                                                 ,schema_name
                                                 ,table_name
                                                 ,index_name
                                         FROM AllIndexes ai
                                              JOIN IndexDefragmentationLog log ON ai.all_indexes_id = log.all_indexes_id
                                         WHERE pre_avg_fragmentation_pct > @fragment_pct_floor
                                               AND pre_avg_fragmentation_pct <= @fragment_pct_ceiling
                                               AND index_size_mb > @index_size_mb_floor
                                               AND (@index_size_mb_ceiling IS NULL
                                                    OR index_size_mb <= @index_size_mb_ceiling)
                                               AND post_avg_fragmentation_pct IS NULL
                                               AND record_date_time = (SELECT MAX(record_date_time)
                                                                       FROM IndexDefragmentationLog)
                                               AND EXISTS (SELECT 1
                                                           FROM sys.databases db
                                                           WHERE ai.database_id = db.database_id
                                                                 AND db.state = 0) -- database is online

    OPEN names
    FETCH NEXT FROM names INTO @all_indexes_id, @db_name, @schema_name, @table_name, @index_name

    -- performs the index defragmentation
    WHILE @@FETCH_STATUS = 0
    BEGIN
        BEGIN TRY
            SET @start_time = GETDATE()

            -- Base alter index statement
            SET @sql = 'USE [' + @db_name + ']' + CHAR(10)
                        + ' ALTER INDEX [' + @index_name + '] ON [' + @schema_name + '].[' + @table_name + '] ' + CHAR(10)
                        + '     ' + @defragment_type
                    
            IF @defragment_type = 'REBUILD'
                SET @sql = @sql + ' WITH (SORT_IN_TEMPDB = ON, MAXDOP = 0, ONLINE = ON)'

            EXEC (@sql)

            SET @end_time = GETDATE()

            EXEC IndexDefragmentationLog_UpdateOne @all_indexes_id
                                                   ,@defragment_type
                                                   ,@start_time
                                                   ,@end_time
        END TRY
        BEGIN CATCH
            -- Do nothing
        END CATCH

        FETCH NEXT FROM names INTO @all_indexes_id, @db_name, @schema_name, @table_name, @index_name
    END

    CLOSE names
    DEALLOCATE names
END
GO