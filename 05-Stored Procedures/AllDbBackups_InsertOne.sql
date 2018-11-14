USE DBA_Util
GO


IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'AllDbBackups_InsertOne')
BEGIN
    DROP PROCEDURE AllDbBackups_InsertOne
END
GO


CREATE PROCEDURE AllDbBackups_InsertOne (@db_name     SYSNAME
                                         ,@file_path  VARCHAR(4000))
WITH ENCRYPTION
AS
BEGIN
    INSERT INTO AllDbBackups (database_id
                              ,database_name
                              ,file_path)
    VALUES (DB_ID(@db_name)
            ,@db_name
            ,@file_path)

END
GO