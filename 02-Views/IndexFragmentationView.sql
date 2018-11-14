USE DBA_Util
GO


IF EXISTS (SELECT 1 FROM sys.views WHERE name = 'IndexFragmentationView')
BEGIN
    DROP VIEW IndexFragmentationView
END
GO


CREATE VIEW IndexFragmentationView
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
       ,log.start_date_time AS last_defragment_start
       ,log.end_date_time AS last_defragment_end
       ,DATEDIFF(SECOND, log.start_date_time, log.end_date_time) AS last_defragment_duration_sec
FROM DBA_Util.dbo.AllIndexes ai
     JOIN DBA_Util.dbo.IndexDefragmentationLog log ON ai.all_indexes_id = log.all_indexes_id
WHERE EXISTS (SELECT max_date.all_indexes_id
              FROM DBA_Util.dbo.IndexDefragmentationLog max_date
              WHERE log.all_indexes_id = max_date.all_indexes_id
                    AND max_date.post_avg_fragmentation_pct IS NOT NULL
              GROUP BY max_date.all_indexes_id
              HAVING MAX(max_date.record_date_time) = log.record_date_time)  -- logs with the latest record_date_time for indexes that have been defragmented
       OR EXISTS (SELECT never_defragged.all_indexes_id
                  FROM DBA_Util.dbo.IndexDefragmentationLog never_defragged
                  WHERE log.all_indexes_id = never_defragged.all_indexes_id
                  GROUP BY never_defragged.all_indexes_id
                  HAVING MAX(never_defragged.record_date_time) = log.record_date_time
                         AND MAX(never_defragged.start_date_time) IS NULL)  -- logs with the latest record_date_time for indexes that have never been defragmented
GO