USE DBA_Util
GO


IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'AllFunctionsAndStoredProcedures')
BEGIN
    CREATE TABLE AllFunctionsAndStoredProcedures
        (database_id                INT
         ,database_name             VARCHAR(128)
         ,object_name               VARCHAR(128)
         ,type                      VARCHAR(25))
END
GO