USE DBA_Util
GO


IF EXISTS (SELECT 1 FROM sys.views WHERE name = 'DbFilesInfoView')
BEGIN
    DROP VIEW DbFilesInfoView
END
GO


CREATE VIEW DbFilesInfoView
WITH ENCRYPTION
AS
SELECT dbf.database_id
       ,dbf.database_name
       ,dbf.type
       ,fsl.total_space_mb
       ,fsl.used_space_mb AS max_used_space_mb
       ,fsl.total_space_mb - fsl.used_space_mb AS free_space_mb
       ,(fsl.total_space_mb - fsl.used_space_mb) / fsl.total_space_mb * 100 AS free_space_pct
       ,fsl.autogrowth_mb
       ,fsl.max_space_mb
       ,LEFT(dbf.file_path, LEN(dbf.file_path) - CHARINDEX('\', REVERSE(dbf.file_path)) + 1) AS directory_path
       ,RIGHT(dbf.file_path, CHARINDEX('\', REVERSE(dbf.file_path)) - 1) AS file_name
       ,LEFT(dbf.file_path, 1) AS file_drive_letter
       ,dbf.file_path
       ,fsl.record_date_time
FROM AllDbFiles dbf
     JOIN DbFileSizeLog fsl ON dbf.all_dbfiles_id = fsl.all_dbfiles_id
GO