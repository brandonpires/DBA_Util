USE DBA_Util
GO


IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'LoginPermissions_Refresh')
BEGIN
    DROP PROCEDURE LoginPermissions_Refresh 
END
GO


CREATE PROCEDURE LoginPermissions_Refresh
WITH ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON

    -- clear table (it doesn't take long to insert all the records again)
    TRUNCATE TABLE LoginPermissions


    -- insert server-level permissions
    INSERT INTO LoginPermissions
    SELECT NULL AS database_id
           ,NULL AS database_name
           ,l.name AS login_name
           ,r.name AS permission_name
           ,'Server Role' AS permission_type
           ,CASE l.is_disabled
                 WHEN 1 THEN 'Yes'
                 WHEN 0 THEN 'No'
            END AS is_disabled
    FROM sys.server_principals l
         LEFT JOIN sys.server_role_members rl ON l.principal_id = rl.member_principal_id
         JOIN sys.server_principals r ON rl.role_principal_id = r.principal_id
    WHERE l.type IN ('S', 'U', 'G')


    -- insert database-level permissions for each database
    EXEC sp_MSforeachdb '
        USE [?]
        INSERT INTO DBA_Util.dbo.LoginPermissions
        SELECT DB_ID(''?'') AS database_id
               ,''?'' AS database_name
               ,l.name AS login_name
               ,r.name AS permission_name
               ,''Database Role'' AS permission_type
               ,CASE l.is_disabled
                     WHEN 1 THEN ''Yes''
                     WHEN 0 THEN ''No''
                END AS is_disabled
        FROM sys.database_principals u
             LEFT JOIN sys.database_role_members ru ON u.principal_id = ru.member_principal_id
             LEFT JOIN sys.database_principals r ON ru.role_principal_id = r.principal_id
             JOIN sys.server_principals l ON u.sid = l.sid
        WHERE u.type IN (''S'', ''U'', ''G'')

        INSERT INTO DBA_Util.dbo.LoginPermissions
        SELECT DB_ID(''?'') AS database_id
               ,''?'' AS database_name
               ,l.name AS login_name
               ,p.permission_name COLLATE SQL_Latin1_General_CP1_CI_AS
               ,''Database Permission'' AS permission_type
               ,CASE l.is_disabled
                     WHEN 1 THEN ''Yes''
                     WHEN 0 THEN ''No''
                END AS is_disabled
        FROM sys.database_principals u
             JOIN sys.database_permissions p ON u.principal_id = p.grantee_principal_id
             JOIN sys.server_principals l ON u.sid = l.sid
        WHERE u.name != ''public''
              AND permission_name != ''CONNECT''
    '

    SET NOCOUNT OFF
END
GO