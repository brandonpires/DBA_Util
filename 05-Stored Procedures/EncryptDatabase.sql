USE DBA_Util
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'EncryptDatabase')
    DROP PROCEDURE EncryptDatabase
GO


CREATE PROCEDURE EncryptDatabase (@db_name SYSNAME
                                  ,@cert_name SYSNAME = 'PWC_tdeCert')
WITH ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @sql VARCHAR(MAX)

    SET @sql = 'USE [' + @db_name + ']' + CHAR(10)
             + 'CREATE DATABASE ENCRYPTION KEY' + CHAR(10)
             + '    WITH ALGORITHM = AES_256' + CHAR(10)
             + '    ENCRYPTION BY SERVER CERTIFICATE ' + @cert_name + CHAR(10)

    EXEC (@sql)

    SET @sql = 'USE [master]' + CHAR(10)
             + 'ALTER DATABASE [' + @db_name + ']' + CHAR(10)
             + '    SET ENCRYPTION ON' + CHAR(10)

    EXEC (@sql)

    SET NOCOUNT OFF
END
GO