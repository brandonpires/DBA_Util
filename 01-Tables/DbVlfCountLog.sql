USE DBA_Util
GO


IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'DbVlfCountLog')
BEGIN
    CREATE TABLE DbVlfCountLog
        (all_dbfiles_id             INT
         ,vlf_count                 INT
         ,record_date_time          DATETIME)
END
GO