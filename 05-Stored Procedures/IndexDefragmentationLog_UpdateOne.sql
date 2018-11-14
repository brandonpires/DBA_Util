USE DBA_Util
GO


IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'IndexDefragmentationLog_UpdateOne')
BEGIN
    DROP PROCEDURE IndexDefragmentationLog_UpdateOne
END
GO


CREATE PROCEDURE IndexDefragmentationLog_UpdateOne (@all_indexes_id   INT
                                                    ,@defragment_type VARCHAR(10)
                                                    ,@start_date_time DATETIME
                                                    ,@end_date_time   DATETIME)
WITH ENCRYPTION
AS
BEGIN
    -- updates a log record with information on the defragmentation
    UPDATE IndexDefragmentationLog
    SET type = @defragment_type
        ,start_date_time = @start_date_time
        ,end_date_time = @end_date_time
    WHERE all_indexes_id = @all_indexes_id
          AND post_avg_fragmentation_pct IS NULL
          AND record_date_time = (SELECT MAX(record_date_time)
                                  FROM IndexDefragmentationLog)
END
GO