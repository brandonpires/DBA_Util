USE DBA_Util
GO


IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'DbBackupFileLog_DeleteOld')
BEGIN
    DROP PROCEDURE DbBackupFileLog_DeleteOld
END
GO


CREATE PROCEDURE DbBackupFileLog_DeleteOld (@days_to_retain TINYINT)
WITH ENCRYPTION
AS
BEGIN
    -- delete logs that are older than the @days_to_retain
    DELETE FROM DbBackupFileLog
    WHERE DATEDIFF(DAY, record_date_time, GETDATE()) > @days_to_retain
END
GO