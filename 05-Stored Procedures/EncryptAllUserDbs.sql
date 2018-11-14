USE DBA_Util
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'EncryptAllUserDbs')
    DROP PROCEDURE EncryptAllUserDbs
GO


CREATE PROCEDURE EncryptAllUserDbs (@cert_name SYSNAME = 'PWC_tdeCert')
WITH ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @db_name SYSNAME

    DECLARE db_names CURSOR FOR SELECT name
                                FROM sys.databases d
                                WHERE database_id > 4
                                      AND NOT EXISTS (SELECT 1
                                                      FROM sys.dm_database_encryption_keys dek
                                                      WHERE d.database_id = dek.database_id
                                                            AND encryption_state NOT IN (2, 3))

    OPEN db_names
    FETCH NEXT FROM db_names INTO @db_name

    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC EncryptDatabase @db_name, @cert_name

        FETCH NEXT FROM db_names INTO @db_name
    END

    CLOSE db_names
    DEALLOCATE db_names

    SET NOCOUNT OFF
END
GO