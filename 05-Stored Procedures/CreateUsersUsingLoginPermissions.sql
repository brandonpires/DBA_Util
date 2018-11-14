USE DBA_Util
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'CreateUsersUsingLoginPermissions')
    DROP PROCEDURE CreateUsersUsingLoginPermissions
GO


CREATE PROCEDURE CreateUsersUsingLoginPermissions (@model_db_name SYSNAME
                                                   ,@target_db_name SYSNAME)
WITH ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON


    -- If @model_db_name and @target_db_name are names of databases
    IF EXISTS (SELECT 1 FROM sys.databases WHERE name = @model_db_name)
       AND EXISTS (SELECT 1 FROM sys.databases WHERE name = @target_db_name)
    BEGIN
        DECLARE @sql1 NVARCHAR(MAX)
                ,@sql2 NVARCHAR(MAX)


        -- Create all users found in @model_db_name in @target_db_name and alters their default schema
        DECLARE create_user CURSOR FOR SELECT DISTINCT 'USE [' + @target_db_name + ']' + CHAR(10) + 'CREATE USER [' + login_name +'] FOR LOGIN [' + login_name + ']'
                                                       ,'USE [' + @target_db_name + ']' + CHAR(10) + 'ALTER USER [' + login_name + '] WITH DEFAULT_SCHEMA=[dbo]'
                                       FROM DBA_Util.dbo.LoginPermissions
                                       WHERE database_name = @model_db_name
                                             AND login_name != 'sadmin'

        OPEN create_user
        FETCH NEXT FROM create_user INTO @sql1, @sql2

        WHILE @@FETCH_STATUS = 0
        BEGIN
            EXEC (@sql1)
            EXEC (@sql2)
    
            FETCH NEXT FROM create_user INTO @sql1, @sql2
        END

        CLOSE create_user
        DEALLOCATE create_user


        -- Adds roles to the users found in @model_db_name in @target_db_name
        DECLARE add_roles CURSOR FOR SELECT 'USE [' + @target_db_name + ']' + CHAR(10) + 'EXEC sp_addrolemember N''' + permission_name + ''', N''' + login_name + ''''
                                     FROM DBA_Util.dbo.LoginPermissions
                                     WHERE database_name = @model_db_name
                                           AND login_name != 'sadmin'
                                           AND permission_type = 'Database Role'
        OPEN add_roles
        FETCH NEXT FROM add_roles INTO @sql1

        WHILE @@FETCH_STATUS = 0
        BEGIN
            EXEC (@sql1)
    
            FETCH NEXT FROM add_roles INTO @sql1
        END

        CLOSE add_roles
        DEALLOCATE add_roles


        -- Grants permissions to the users found in @model_db_name in @target_db_name
        DECLARE add_permissions CURSOR FOR SELECT 'USE [' + @target_db_name + ']' + CHAR(10) + 'GRANT ' + permission_name + ' TO [' + login_name + ']'
                                     FROM DBA_Util.dbo.LoginPermissions
                                     WHERE database_name = @model_db_name
                                           AND login_name != 'sadmin'
                                           AND permission_type = 'Database Permission'
        OPEN add_permissions
        FETCH NEXT FROM add_permissions INTO @sql1

        WHILE @@FETCH_STATUS = 0
        BEGIN
            EXEC (@sql1)
    
            FETCH NEXT FROM add_permissions INTO @sql1
        END

        CLOSE add_permissions
        DEALLOCATE add_permissions
    END

    SET NOCOUNT OFF
END
GO