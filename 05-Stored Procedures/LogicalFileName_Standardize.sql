USE DBA_Util
GO


IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'LogicalFileName_Standardize')
BEGIN
    DROP PROCEDURE LogicalFileName_Standardize 
END
GO


CREATE PROCEDURE LogicalFileName_Standardize (@first_run BIT = 0)
WITH ENCRYPTION
AS
BEGIN
    DECLARE @sql VARCHAR(MAX)


    SET @sql = '
        -- if the database is not a snapshot database
        IF EXISTS (SELECT 1 FROM sys.databases WHERE name = ''?'' AND source_database_id IS NULL)
        BEGIN
            DECLARE @file_name SYSNAME
                    ,@first_run BIT

            SET @first_run = ' + CONVERT(VARCHAR, @first_run) + '

            SELECT @file_name = name
            FROM [?].sys.database_files
            WHERE type_desc = ''ROWS''
                  AND name != ''?_Data''
                  AND file_id = 1
                  AND DB_ID(''?'') > 4

            IF @file_name IS NOT NULL
            BEGIN
                EXEC (''ALTER DATABASE [?] MODIFY FILE (NAME='''''' + @file_name + '''''', NEWNAME=''''?_Data'''')'')
            END

            SELECT @file_name = name
            FROM [?].sys.database_files
            WHERE type_desc = ''LOG''
                  AND (@first_run = 1
                       OR name != ''?_Log'')
                  AND DB_ID(''?'') > 4

            IF @file_name IS NOT NULL
            BEGIN
                IF @first_run = 0
                BEGIN
                    EXEC (''ALTER DATABASE [?] MODIFY FILE (NAME='''''' + @file_name + '''''', NEWNAME=''''?_Log'''')'')
                END
                ELSE
                BEGIN
                    EXEC (''ALTER DATABASE [?] MODIFY FILE (NAME='''''' + @file_name + '''''', NEWNAME=''''?_Loga'''')'')
                    EXEC (''ALTER DATABASE [?] MODIFY FILE (NAME=''''?_Loga'''', NEWNAME=''''?_Log'''')'')
                END
            END
        END'

    EXEC sp_msforeachdb @sql
END
GO
