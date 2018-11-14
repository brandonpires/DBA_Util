USE DBA_Util
GO


IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'DbFileSizeLog_InsertNew')
BEGIN
    DROP PROCEDURE DbFileSizeLog_InsertNew
END
GO


CREATE PROCEDURE DbFileSizeLog_InsertNew
WITH ENCRYPTION
AS
BEGIN
    DECLARE @collation          SYSNAME
            ,@db_name_cursor    SYSNAME
            ,@sql               VARCHAR(MAX)
            ,@record_date_time  DATETIME

    SET @record_date_time = GETDATE()
    SET @collation = CONVERT(SYSNAME, DATABASEPROPERTYEX('DBA_Util', 'Collation'))

    -- gets all database names
    DECLARE db_names CURSOR FOR SELECT name
                                FROM sys.databases
                                WHERE state = 0

    OPEN db_names
    FETCH NEXT FROM db_names INTO @db_name_cursor

    -- inserts logs for new database files
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @sql = 'USE [' + @db_name_cursor + ']' + CHAR(10)
                + CHAR(10)
                + ' INSERT INTO DBA_Util.dbo.DbFileSizeLog (all_dbfiles_id' + CHAR(10)
                + '                                         ,total_space_mb' + CHAR(10)
                + '                                         ,used_space_mb' + CHAR(10)
                + '                                         ,autogrowth_mb' + CHAR(10)
                + '                                         ,max_space_mb' + CHAR(10)
                + '                                         ,record_date_time)' + CHAR(10)
                + ' SELECT all_dbfiles_id' + CHAR(10)
                + '        ,ROUND(size * 8.00 / 1024.00, 2) AS total_space_mb' + CHAR(10)
                + '        ,ROUND(FILEPROPERTY(name, ''spaceused'') * 8.00 / 1024.00, 2) AS used_space_mb' + CHAR(10)
                + '        ,ROUND(growth * 8.00 / 1024.00, 2) AS autogrowth_mb' + CHAR(10)
                + '        ,CASE' + CHAR(10)
                + '            WHEN max_size IN (-1, 268435456) THEN NULL' + CHAR(10)
                + '            ELSE ROUND(max_size * 8.00 / 1024.00, 2)' + CHAR(10)
                + '         END AS max_space_mb' + CHAR(10)
                + '        ,CONVERT(DATETIME, ''' + CONVERT(VARCHAR(4000), @record_date_time, 113) + ''') AS record_date_time' + CHAR(10)
                + ' FROM DBA_Util.dbo.AllDbFiles adf' + CHAR(10)
                + '      JOIN sys.database_files df ON adf.file_path = df.physical_name COLLATE ' + @collation + CHAR(10)
                + '                                    AND adf.type = CASE df.type' + CHAR(10)
                + '                                                       WHEN 0 THEN ''Data''' + CHAR(10)
                + '                                                       WHEN 1 THEN ''TLog''' + CHAR(10)
                + '                                                   END'
                + ' WHERE adf.database_id = DB_ID()'
        EXEC (@sql)

        FETCH NEXT FROM db_names INTO @db_name_cursor
    END

    CLOSE db_names
    DEALLOCATE db_names
END
GO