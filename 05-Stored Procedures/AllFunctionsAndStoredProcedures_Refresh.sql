USE DBA_Util
GO


IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'AllFunctionsAndStoredProcedures_Refresh')
BEGIN
    DROP PROCEDURE AllFunctionsAndStoredProcedures_Refresh 
END
GO


CREATE PROCEDURE AllFunctionsAndStoredProcedures_Refresh
WITH ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON

    -- clear table (it doesn't take long to insert all the records again)
    TRUNCATE TABLE AllFunctionsAndStoredProcedures


    -- insert functions and stored procedures for each database
    EXEC sp_MSforeachdb '
        INSERT INTO DBA_Util.dbo.AllFunctionsAndStoredProcedures
        SELECT DB_ID(''?'') AS database_id
               ,''?''       AS database_name
               ,name        AS object_name
               ,CASE type
                     WHEN ''P''  THEN ''Stored Procedure''
                     WHEN ''FN'' THEN ''Function''
                END
        FROM [?].sys.objects
        WHERE type IN (''FN'', ''P'')
              AND is_ms_shipped != 1'

    SET NOCOUNT OFF
END
GO