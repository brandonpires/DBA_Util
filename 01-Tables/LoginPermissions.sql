USE DBA_Util
GO


IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'LoginPermissions')
BEGIN
    CREATE TABLE LoginPermissions
        (database_id                INT
         ,database_name             VARCHAR(128)
         ,login_name                VARCHAR(128)
         ,permission_name           VARCHAR(128)
         ,permission_type           VARCHAR(25))
END
GO



IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'LoginPermissions')
   AND NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('LoginPermissions') AND name = 'is_disabled')
BEGIN
    ALTER TABLE LoginPermissions
        ADD is_disabled VARCHAR(3)
END
GO

