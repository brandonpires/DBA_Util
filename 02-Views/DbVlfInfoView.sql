USE DBA_Util
GO


IF EXISTS (SELECT 1 FROM sys.views WHERE name = 'DbVlfInfoView')
BEGIN
    DROP VIEW DbVlfInfoView
END
GO


CREATE VIEW DbVlfInfoView
WITH ENCRYPTION
AS
SELECT dbf.database_id
       ,dbf.database_name
       ,dbf.type
       ,vcl.vlf_count
       ,LEFT(dbf.file_path, LEN(dbf.file_path) - CHARINDEX('\', REVERSE(dbf.file_path)) + 1) AS directory_path
       ,RIGHT(dbf.file_path, CHARINDEX('\', REVERSE(dbf.file_path)) - 1) AS file_name
       ,LEFT(dbf.file_path, 1) AS file_drive_letter
       ,dbf.file_path
       ,vcl.record_date_time
FROM AllDbFiles dbf
     JOIN DbVlfCountLog vcl ON dbf.all_dbfiles_id = vcl.all_dbfiles_id
GO