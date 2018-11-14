USE DBA_Util
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'CreateContentDb')
    DROP PROCEDURE CreateContentDb
GO


CREATE PROCEDURE CreateContentDb (@db_name SYSNAME)
WITH ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON


    -- If a database with @db_name doesn't exist
    IF @db_name IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = @db_name)
    BEGIN
        DECLARE @sql                   NVARCHAR(MAX)
                ,@db_name_prefix       SYSNAME
                ,@model_db_name        SYSNAME
                ,@datafile_size        VARCHAR(10)
                ,@datafile_filegrowth  VARCHAR(10)
                ,@tlog_size            VARCHAR(10)
                ,@tlog_filegrowth      VARCHAR(10)
                ,@valid_db_name        BIT

        SET @model_db_name = (SELECT TOP 1 name FROM master.sys.databases WHERE name LIKE '%Content' ORDER BY create_date DESC)
        SET @db_name_prefix = LEFT(@model_db_name, CHARINDEX('_', @model_db_name))
        SET @valid_db_name = 1


        -- Gets the model database's data file size and file growth
        SELECT TOP 1 @datafile_size = CONVERT(VARCHAR(10), dfsl.total_space_mb)
                     ,@datafile_filegrowth = CONVERT(VARCHAR(10), dfsl.autogrowth_mb)
        FROM AllDbFiles adf
             JOIN DbFileSizeLog dfsl ON adf.all_dbfiles_id = dfsl.all_dbfiles_id
        WHERE adf.database_name = 'model'
              AND adf.type = 'Data'
        ORDER BY record_date_time DESC


        -- Gets the model database's transaction log file size and file growth
        SELECT TOP 1 @tlog_size = CONVERT(VARCHAR(10), dfsl.total_space_mb)
                     ,@tlog_filegrowth = CONVERT(VARCHAR(10), dfsl.autogrowth_mb)
        FROM AllDbFiles adf
             JOIN DbFileSizeLog dfsl ON adf.all_dbfiles_id = dfsl.all_dbfiles_id
        WHERE adf.database_name = 'model'
              AND adf.type = 'TLog'
        ORDER BY record_date_time DESC


        -- If no databases exist in the instance with the named prefix
        IF @db_name_prefix IS NULL
        BEGIN
            PRINT 'This instance ' + @@SERVERNAME + ' has no other content databases.'
            SET @valid_db_name = 0
        END


        -- If @db_name doesn't end with _Content
        IF @db_name NOT LIKE '%[_]Content' COLLATE SQL_Latin1_General_CP1_CS_AS
        BEGIN
            PRINT '''' + @db_name + ''' is an invalid database name.  It must end with ''_Content'' (case-sensitive).'
            SET @valid_db_name = 0
        END


        -- If @db_name doesn't start with the standard content database prefix
        IF @db_name NOT LIKE @db_name_prefix + '%' COLLATE SQL_Latin1_General_CP1_CS_AS
        BEGIN
            PRINT '''' + @db_name + ''' is an invalid database name.  It must start with ''' + @db_name_prefix + ''' (case-sensitive).'
            SET @valid_db_name = 0
        END

 
        -- If @db_name after the @db_name_prefix doesn't start with a capital letter
        IF SUBSTRING(@db_name, LEN(@db_name_prefix) + 1, 1) NOT LIKE '[A-Z]' COLLATE SQL_Latin1_General_CP1_CS_AS
        BEGIN
            PRINT '''' + @db_name + ''' is an invalid database name.  It must start with a captial letter after ''' + @db_name_prefix + '''.'
            SET @valid_db_name = 0
        END


        -- If all prior checks pass
        IF @valid_db_name = 1
        BEGIN
            SET @sql = 'CREATE DATABASE [' + @db_name + ']
                            ON PRIMARY (NAME = N''' + @db_name + '_Data'', FILENAME = N''J:\' + @db_name + '_Data.mdf'', SIZE = ' + @datafile_size + 'MB , FILEGROWTH = ' + @datafile_filegrowth + 'MB)
                               LOG ON (NAME = N''' + @db_name + '_Log'', FILENAME = N''K:\' + @db_name + '_Log.ldf'', SIZE = ' + @tlog_size + 'MB , FILEGROWTH = ' + @tlog_filegrowth + 'MB)
                            COLLATE Latin1_General_CI_AS_KS_WS'
            EXEC (@sql)


            SET @sql = 'ALTER DATABASE [' + @db_name + '] SET COMPATIBILITY_LEVEL = 100'
            EXEC (@sql)


            SET @sql = 'EXEC [' + @db_name + '].dbo.sp_changedbowner @loginame = N''sadmin'', @map = false'
            EXEC (@sql)


            EXEC CreateUsersUsingLoginPermissions @model_db_name, @db_name
            EXEC LoginPermissions_Refresh
        END
    END
    -- If a database with @db_name doesn't exist
    ELSE
    BEGIN
        IF @db_name IS NOT NULL
        BEGIN
            PRINT '''' + @db_name + ''' already exists.'
        END
        ELSE
        BEGIN
            PRINT '''@db_name'' is required.'
        END
    END


    SET NOCOUNT OFF
END
GO


GRANT EXECUTE ON CreateContentDb TO [TEST\UIS SharePoint Administrators] -- TODO: Update login
GO