USE DBA_Util
GO


IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'DbFileSizeLog_DeleteOld')
BEGIN
    DROP PROCEDURE DbFileSizeLog_DeleteOld
END
GO


CREATE PROCEDURE DbFileSizeLog_DeleteOld (@days_to_retain TINYINT)
WITH ENCRYPTION
AS
BEGIN
    -- delete logs that are older than the @days_to_retain
    DELETE FROM DBA_Util.dbo.DbFileSizeLog
    WHERE DATEDIFF(DAY, record_date_time, GETDATE()) > @days_to_retain
END
GO