USE DBA_Util
GO


IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'DbFileAutogrowth_Standardize')
BEGIN
    DROP PROCEDURE DbFileAutogrowth_Standardize 
END
GO


CREATE PROCEDURE DbFileAutogrowth_Standardize
WITH ENCRYPTION
AS
BEGIN
    DECLARE @sql                    VARCHAR(MAX)
            ,@db_name               SYSNAME
            ,@db_logical_file_name  SYSNAME
            ,@db_file_growth        INT



    DECLARE dbf CURSOR LOCAL FOR SELECT database_name, logical_file_name, fal.autogrowth_mb
                                 FROM AllDbFiles dbf
                                      JOIN DbFileSizeLog fsl ON dbf.all_dbfiles_id = fsl.all_dbfiles_id
                                      JOIN DbFileAutogrowthLookup fal ON dbf.type = fal.type
	                                                                 AND fsl.total_space_mb BETWEEN fal.lower_mb AND fal.upper_mb
                                                                         AND fsl.autogrowth_mb != fal.autogrowth_mb
                                 WHERE dbf.database_name != 'tempdb'
                                       AND fsl.record_date_time = (SELECT MAX(record_date_time)
                                                                   FROM DbFilesInfoView)
                                       AND EXISTS (SELECT 1
                                                   FROM sys.databases db
                                                   WHERE dbf.database_name = db.name)


    OPEN dbf
    FETCH NEXT FROM dbf INTO @db_name, @db_logical_file_name, @db_file_growth

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @sql = 'ALTER DATABASE [' + @db_name + '] MODIFY FILE (NAME = N''' + @db_logical_file_name + ''', FILEGROWTH = ' + CONVERT(VARCHAR(10), @db_file_growth) + 'MB)'
        EXEC (@sql)
        FETCH NEXT FROM dbf INTO @db_name, @db_logical_file_name, @db_file_growth
    END

    CLOSE dbf
    DEALLOCATE dbf
END
GO
