USE DBA_Util
GO


IF EXISTS (SELECT 1 FROM sys.views WHERE name = 'IndexDefragmentationLogView')
BEGIN
    DROP VIEW IndexDefragmentationLogView
END
GO


CREATE VIEW IndexDefragmentationLogView
WITH ENCRYPTION
AS
SELECT ai.database_name
       ,ai.schema_name
       ,ai.table_name
       ,ai.index_name
       ,ai.state
       ,ai.type AS index_type
       ,log.fill_factor
       ,log.pre_avg_fragmentation_pct
       ,log.post_avg_fragmentation_pct
       ,log.index_size_mb
       ,ai.last_user_seek
       ,ai.last_user_scan
       ,ai.last_user_lookup
       ,ai.last_user_update
       ,log.type AS defragment_type
       ,log.start_date_time
       ,log.end_date_time
       ,log.record_date_time
       ,DATEDIFF(SECOND, log.start_date_time, log.end_date_time) AS last_defragment_duration_sec
FROM DBA_Util.dbo.AllIndexes ai
     JOIN DBA_Util.dbo.IndexDefragmentationLog log ON ai.all_indexes_id = log.all_indexes_id
GO