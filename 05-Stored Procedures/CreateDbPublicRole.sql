USE DBA_Util
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'CreateDbPublicRole')
    DROP PROCEDURE CreateDbPublicRole
GO


CREATE PROCEDURE CreateDbPublicRole
WITH ENCRYPTION
AS
BEGIN
    DECLARE @db_name SYSNAME
            ,@schema_name SYSNAME
            ,@object_name SYSNAME
            ,@permission_name SYSNAME
            ,@user_name SYSNAME
            ,@sql VARCHAR(MAX)

    IF EXISTS (SELECT 1 FROM tempdb.sys.tables WHERE name = '##DbPublicDbs')
        DROP TABLE ##DbPublicDbs

    CREATE TABLE ##DbPublicDbs (name SYSNAME)


    -- Get names of all databases with db_public
    EXEC sp_msforeachdb 'INSERT INTO ##DbPublicDbs
                         SELECT ''?''
                         FROM [?].sys.database_principals
                         WHERE type = ''R''
                               AND name = ''db_public'''


    -- Cursor containing names of databases without db_public role and not named master or msdb
    DECLARE db_names CURSOR LOCAL FOR SELECT name
                                      FROM sys.databases all_dbs
                                      WHERE NOT EXISTS (SELECT 1
                                                        FROM ##DbPublicDbs db_public_dbs
                                                        WHERE all_dbs.name = db_public_dbs.name)
                                            AND name NOT IN ('master', 'msdb')

    OPEN db_names
    FETCH NEXT FROM db_names INTO @db_name

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Create db_public role in database
        SET @sql = 'USE ['+ @db_name + ']' + CHAR(10)
                 + 'CREATE ROLE db_public'
        EXEC (@sql)


        -- Assign existing users to db_public
        SET @sql = 'DECLARE user_names CURSOR FOR SELECT name' + CHAR(10)
                                               + 'FROM [' + @db_name + '].sys.database_principals' + CHAR(10)
                                               + 'WHERE type IN (''S'', ''U'', ''G'')  -- SQL users, Windows users, Windows groups' + CHAR(10)
                                                     + 'AND name NOT IN (''dbo'', ''sys'', ''INFORMATION_SCHEMA'', ''guest'')' + CHAR(10)
        EXEC (@sql)

        OPEN user_names
        FETCH NEXT FROM user_names INTO @user_name

        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @sql =  'USE [' + @db_name + ']' + CHAR(10)
                      + 'EXEC sp_addrolemember ''db_public'', ''' + @user_name + '''' 
            EXEC (@sql)

            FETCH NEXT FROM user_names INTO @user_name
        END

        CLOSE user_names
        DEALLOCATE user_names


        -- Assign permissions to db_public and revoke permissions to public
        SET @sql = 'DECLARE public_permissions CURSOR FOR SELECT SCHEMA_NAME(schema_id)' + CHAR(10)
                                                              + ',o.name' + CHAR(10)
                                                              + ',p.permission_name' + CHAR(10)
                                                       + 'FROM [' + @db_name + '].sys.database_principals u' + CHAR(10)
                                                            + 'JOIN [' + @db_name + '].sys.database_permissions p ON u.principal_id = p.grantee_principal_id' + CHAR(10)
                                                            + 'JOIN [' + @db_name + '].sys.all_objects o ON p.major_id = o.object_id' + CHAR(10)
                                                       + 'WHERE p.state_desc != ''DENY''' + CHAR(10)
                                                             + 'AND u.name = ''public''' + CHAR(10)
                                                       + 'ORDER BY u.name, o.name, p.permission_name' + CHAR(10)
        EXEC (@sql)

        OPEN public_permissions
        FETCH NEXT FROM public_permissions INTO @schema_name
                                                ,@object_name
                                                ,@permission_name

        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @sql = 'USE [' + @db_name + ']' + CHAR(10)
                       + 'GRANT ' + @permission_name + ' ON [' + @schema_name + '].[' + @object_name + '] TO db_public' + CHAR(10)
                       + 'REVOKE ' + @permission_name + ' ON [' + @schema_name + '].[' + @object_name + '] FROM public'
            EXEC (@sql)

            FETCH NEXT FROM public_permissions INTO @schema_name
                                                    ,@object_name
                                                    ,@permission_name
        END

        CLOSE public_permissions
        DEALLOCATE public_permissions


        FETCH NEXT FROM db_names INTO @db_name
    END

    CLOSE db_names
    DEALLOCATE db_names

    DROP TABLE ##DbPublicDbs
END
GO