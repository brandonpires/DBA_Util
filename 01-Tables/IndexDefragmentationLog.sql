USE DBA_Util
GO


IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'IndexDefragmentationLog')
BEGIN
    CREATE TABLE IndexDefragmentationLog
        (all_indexes_id              INT
         ,fill_factor                TINYINT
         ,pre_avg_fragmentation_pct  FLOAT
         ,post_avg_fragmentation_pct FLOAT 
         ,index_size_mb              FLOAT
         ,type                       VARCHAR(10)
         ,start_date_time            DATETIME
         ,end_date_time              DATETIME
         ,record_date_time           DATETIME)
END
GO