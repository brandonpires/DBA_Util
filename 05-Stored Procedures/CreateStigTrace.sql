/**
 *  The default value for @trace_max_space_mb parameter should be set to an appropriate size for the instance.  That value can be found
 *  in the CreateStigTrace Excel Workbook in the SQL Server directory.
 *
 */


USE DBA_Util
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'CreateStigTrace')
    DROP PROCEDURE CreateStigTrace
GO


CREATE PROCEDURE CreateStigTrace (@trace_max_space_mb BIGINT = 100000
                                  ,@trace_option INT = 6
                                  ,@trace_directory NVARCHAR(245) = 'F:\Audit_Trace\')
WITH ENCRYPTION
AS
BEGIN
    DECLARE @rc                    INT
            ,@trace_id             INT
            ,@trace_filepath       NVARCHAR(245)
            ,@trace_max_file_size  BIGINT
            ,@trace_file_count     INT
            ,@event_id             INT
            ,@event_on             BIT


    SET @trace_id = NULL
    SET @trace_filepath = dbo.FilePathGenerator(@trace_directory, '', 'StigTrace', 'FALSE')
    SET @trace_max_file_size = (CASE
                                     WHEN @trace_max_space_mb >= 200 THEN 200
                                     ELSE @trace_max_space_mb / 2
                                END)
    SET @trace_file_count = @trace_max_space_mb / @trace_max_file_size


    SELECT @trace_id = traceid
    FROM ::fn_trace_getinfo(DEFAULT)
    WHERE CONVERT(NVARCHAR(245), value) LIKE '%' + @trace_filepath + '%'

    IF @trace_id IS NOT NULL
    BEGIN
        EXEC sp_trace_setstatus @trace_id, 0 -- stop trace
        EXEC sp_trace_setstatus @trace_id, 2 -- close trace and delete trace definition
    END


    EXEC @rc = sp_trace_create @trace_id OUTPUT
                               ,@trace_option
                               ,@trace_filepath
                               ,@trace_max_file_size
                               ,NULL
                               ,@trace_file_count

    IF (@rc = 0)
    BEGIN
        SET @event_on = 1

        -- Audit Login:  Occurs when a user successfully logs in to SQL Server.
        SET @event_id = 14
        EXEC sp_trace_setevent @trace_id, @event_id, 1, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 6, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 7, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 8, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 10, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 11, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 12, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 14, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 23, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 26, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 35, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 41, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 60, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 64, @event_on

        -- Audit Logout:  Occurs when a user logs out of SQL Server.
        SET @event_id = 15
        EXEC sp_trace_setevent @trace_id, @event_id, 6, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 7, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 8, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 10, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 11, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 12, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 13, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 14, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 15, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 23, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 26, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 35, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 41, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 60, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 64, @event_on


        -- Audit Server Starts and Stops:  Occurs when the SQL Server service state is modified.
        SET @event_id = 18
        EXEC sp_trace_setevent @trace_id, @event_id, 6, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 7, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 8, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 10, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 11, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 12, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 14, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 23, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 26, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 41, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 60, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 64, @event_on


        -- Audit Login Failed:  Indicates that a login attempt to SQL Server from a client failed.
        SET @event_id = 20
        EXEC sp_trace_setevent @trace_id, @event_id, 1, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 6, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 7, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 8, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 10, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 11, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 12, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 14, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 23, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 26, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 31, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 35, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 60, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 64, @event_on


        -- Audit Statement GDR Event:  Occurs every time a GRANT, DENY, REVOKE for a statement permission is issued by any user in SQL Server.
        SET @event_id = 102
        EXEC sp_trace_setevent @trace_id, @event_id, 1, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 6, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 7, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 8, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 10, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 11, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 12, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 14, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 19, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 23, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 26, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 28, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 34, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 35, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 37, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 39, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 40, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 41, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 42, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 43, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 60, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 64, @event_on


        -- Audit Object GDR Event:  Occurs every time a GRANT, DENY, REVOKE for an object permission is issued by any user in SQL Server.
        SET @event_id = 103
        EXEC sp_trace_setevent @trace_id, @event_id, 1, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 6, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 7, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 8, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 10, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 11, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 12, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 14, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 19, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 23, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 26, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 28, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 34, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 35, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 37, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 39, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 40, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 41, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 42, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 43, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 44, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 59, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 60, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 64, @event_on


        -- Audit AddLogin Event:  Occurs when a SQL Server login is added or removed; for sp_addlogin and sp_droplogin.
        SET @event_id = 104
        EXEC sp_trace_setevent @trace_id, @event_id, 6, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 7, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 8, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 10, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 11, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 12, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 14, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 23, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 26, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 35, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 41, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 42, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 43, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 60, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 64, @event_on


        -- Audit Login GDR Event:  Occurs when a Windows login right is added or removed; for sp_grantlogin, sp_revokelogin, and sp_denylogin.
        SET @event_id = 105
        EXEC sp_trace_setevent @trace_id, @event_id, 6, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 7, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 8, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 10, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 11, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 12, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 14, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 23, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 26, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 35, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 41, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 42, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 43, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 60, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 64, @event_on


        -- Audit Login Change Property Event:  Occurs when a property of a login, except passwords, is modified; for sp_defaultdb and sp_defaultlanguage.
        SET @event_id = 106
        EXEC sp_trace_setevent @trace_id, @event_id, 1, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 6, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 7, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 8, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 10, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 11, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 12, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 14, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 23, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 26, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 28, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 34, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 35, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 37, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 41, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 42, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 43, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 60, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 64, @event_on


        -- Audit Login Change Password Event:  Occurs when a SQL Server login password is changed.  Passwords are not recorded.
        SET @event_id = 107
        EXEC sp_trace_setevent @trace_id, @event_id, 1, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 6, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 7, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 8, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 10, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 11, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 12, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 14, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 23, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 26, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 28, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 34, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 35, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 37, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 41, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 42, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 43, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 60, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 64, @event_on


        -- Audit Add Login to Server Role Event:  Occurs when a login is added or removed from a fixed server role; for sp_addsrvrolemember, and sp_dropsrvrolemember.
        SET @event_id = 108
        EXEC sp_trace_setevent @trace_id, @event_id, 1, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 6, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 7, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 8, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 10, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 11, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 12, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 14, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 23, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 26, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 28, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 34, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 35, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 37, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 38, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 40, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 41, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 42, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 43, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 60, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 64, @event_on


        -- Audit Add DB User Event:  Occurs when a login is added or removed as a database user (Windows or SQL Server) to a database; for sp_grantdbaccess, sp_revokedbaccess, sp_adduser, and sp_dropuser.
        SET @event_id = 109
        EXEC sp_trace_setevent @trace_id, @event_id, 6, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 7, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 8, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 10, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 11, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 12, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 14, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 21, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 23, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 26, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 35, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 37, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 38, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 39, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 40, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 41, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 42, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 43, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 44, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 51, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 60, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 64, @event_on


        -- Audit Add Member to DB Role Event:  Occurs when a login is added or removed as a database user (fixed or user-defined) to a database; for sp_addrolemember, sp_droprolemember, and sp_changegroup.
        SET @event_id = 110
        EXEC sp_trace_setevent @trace_id, @event_id, 1, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 6, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 7, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 8, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 10, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 11, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 12, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 14, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 23, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 26, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 28, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 34, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 35, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 37, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 38, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 39, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 40, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 41, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 60, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 64, @event_on


        -- Audit Add Role Event:  Occurs when a login is added or removed as a database user to a database; for sp_addrole and sp_droprole.
        SET @event_id = 111
        EXEC sp_trace_setevent @trace_id, @event_id, 6, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 7, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 8, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 10, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 11, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 12, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 14, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 23, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 26, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 35, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 38, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 40, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 41, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 60, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 64, @event_on


        -- Audit App Role Change Password Event:  Occurs when a password of an application role is changed.
        SET @event_id = 112
        EXEC sp_trace_setevent @trace_id, @event_id, 1, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 6, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 7, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 8, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 10, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 11, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 12, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 14, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 23, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 26, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 28, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 34, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 35, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 37, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 38, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 40, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 41, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 60, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 64, @event_on


        -- Audit Statement Permission Event:  Occurs when a statement permission (such as CREATE TABLE) is used.
        SET @event_id = 113
        EXEC sp_trace_setevent @trace_id, @event_id, 1, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 6, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 7, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 8, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 10, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 11, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 12, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 14, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 19, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 23, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 26, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 35, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 40, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 41, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 60, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 64, @event_on


        -- Audit Backup/Restore Event:  Occurs when a BACKUP or RESTORE command is issued.
        SET @event_id = 115
        EXEC sp_trace_setevent @trace_id, @event_id, 1, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 6, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 7, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 8, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 10, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 11, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 12, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 14, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 23, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 26, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 35, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 40, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 41, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 60, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 64, @event_on


        -- Audit DBCC Event:  Occurs when DBCC commands are issued.
        SET @event_id = 116
        EXEC sp_trace_setevent @trace_id, @event_id, 1, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 6, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 7, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 8, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 10, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 11, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 12, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 14, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 23, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 26, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 35, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 37, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 40, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 41, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 44, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 60, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 64, @event_on


        -- Audit Change Audit Event:  Occurs when audit trace modifications are made.
        SET @event_id = 117
        EXEC sp_trace_setevent @trace_id, @event_id, 1, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 6, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 7, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 8, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 10, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 11, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 12, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 14, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 23, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 26, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 35, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 37, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 40, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 41, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 44, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 60, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 64, @event_on


        -- Audit Object Derived Permission Event:  Occurs when a CREATE, ALTER, and DROP object commands are issued.
        SET @event_id = 118
        EXEC sp_trace_setevent @trace_id, @event_id, 1, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 6, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 7, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 8, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 10, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 11, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 12, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 14, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 23, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 26, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 28, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 34, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 35, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 37, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 40, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 41, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 60, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 64, @event_on


        -- Audit Database Management Event:  Occurs when a CREATE, ALTER, or DROP statement executes on database objects, such as schemas.
        SET @event_id = 128
        EXEC sp_trace_setevent @trace_id, @event_id, 1, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 6, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 7, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 8, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 10, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 11, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 12, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 14, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 23, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 26, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 28, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 34, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 35, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 37, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 40, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 41, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 60, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 64, @event_on


        -- Audit Database Object Management Event:  Occurs when a CREATE, ALTER, or DROP statement executes on database objects, such as schemas.
        SET @event_id = 129
        EXEC sp_trace_setevent @trace_id, @event_id, 1, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 6, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 7, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 8, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 10, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 11, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 12, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 14, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 23, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 26, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 28, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 34, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 35, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 37, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 40, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 41, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 60, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 64, @event_on


        -- Audit Database Principal Management Event:  Occurs when principals, such as users, are created, altered, or dropped from a database.
        SET @event_id = 130
        EXEC sp_trace_setevent @trace_id, @event_id, 1, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 6, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 7, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 8, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 10, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 11, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 12, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 14, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 23, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 26, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 28, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 34, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 35, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 37, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 40, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 41, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 60, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 64, @event_on


        -- Audit Schema Object Management Event:  Occurs when server objects are created, altered, or dropped.
        SET @event_id = 131
        EXEC sp_trace_setevent @trace_id, @event_id, 1, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 6, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 7, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 8, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 10, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 11, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 12, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 14, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 23, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 26, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 28, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 34, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 35, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 37, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 40, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 41, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 59, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 60, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 64, @event_on


        -- Audit Server Principal Impersonation Event:  Occurs when there is an impersonation within server scope, such as EXECUTE AS LOGIN.
        SET @event_id = 132
        EXEC sp_trace_setevent @trace_id, @event_id, 1, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 6, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 7, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 8, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 10, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 11, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 12, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 14, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 23, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 26, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 28, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 34, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 35, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 40, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 41, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 60, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 64, @event_on


        -- Audit Database Principal Impersonation Event:  Occurs when an impersonation occurs within the database scope, such as EXECUTE AS USER or SETUSER.
        SET @event_id = 133
        EXEC sp_trace_setevent @trace_id, @event_id, 1, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 6, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 7, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 8, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 10, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 11, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 12, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 14, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 23, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 26, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 28, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 34, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 35, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 38, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 40, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 41, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 60, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 64, @event_on


        -- Audit Server Object Take Ownership Event:  Occurs when the owner is changed for objects in server scope.
        SET @event_id = 134
        EXEC sp_trace_setevent @trace_id, @event_id, 1, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 6, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 7, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 8, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 10, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 11, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 12, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 14, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 23, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 26, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 28, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 34, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 35, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 37, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 39, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 40, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 41, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 42, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 43, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 60, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 64, @event_on


        -- Audit Database Object Take Ownership Event: Occurs when a change of owner for objects within database scope occurs.
        SET @event_id = 135
        EXEC sp_trace_setevent @trace_id, @event_id, 1, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 6, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 7, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 8, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 10, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 11, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 12, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 14, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 23, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 26, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 28, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 34, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 35, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 37, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 39, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 40, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 41, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 60, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 64, @event_on


        -- Audit Change Database Owner:  Occurs when ALTER AUTHORIZATION is used to change the owner of a database and permissions are checked to do that.
        SET @event_id = 152
        EXEC sp_trace_setevent @trace_id, @event_id, 1, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 6, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 7, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 8, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 10, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 11, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 12, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 14, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 23, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 26, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 35, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 39, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 40, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 41, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 42, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 43, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 60, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 64, @event_on


        -- Audit Schema Object Take Ownership Event:  Occurs when ALTER AUTHORIZATION is used to assign an owner to an object and permissions are checked to do that.
        SET @event_id = 153
        EXEC sp_trace_setevent @trace_id, @event_id, 1, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 6, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 7, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 8, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 10, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 11, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 12, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 14, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 23, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 26, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 28, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 34, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 35, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 37, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 39, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 40, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 41, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 59, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 60, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 64, @event_on


        -- Audit Server Scope GDR Event:  Indicates that a grant, deny, or revoke event for permissions in server scope occurred, such as creating a login.
        SET @event_id = 170
        EXEC sp_trace_setevent @trace_id, @event_id, 1, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 6, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 7, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 8, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 10, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 11, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 12, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 14, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 19, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 23, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 26, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 28, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 34, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 35, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 37, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 40, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 41, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 42, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 43, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 60, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 64, @event_on


        -- Audit Server Object GDR Event:  Indicates that a grant, deny, or revoke event for a schema object, such as a table or function, occurred.
        SET @event_id = 171
        EXEC sp_trace_setevent @trace_id, @event_id, 1, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 6, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 7, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 8, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 10, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 11, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 12, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 14, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 19, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 23, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 26, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 28, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 34, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 35, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 37, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 40, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 41, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 42, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 43, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 60, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 64, @event_on


        -- Audit Database Object GDR Event:  Indicates that a grant, deny, or revoke event for database objects, such as assemblies and schemas, occurred.
        SET @event_id = 172
        EXEC sp_trace_setevent @trace_id, @event_id, 1, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 6, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 7, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 8, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 10, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 11, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 12, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 14, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 19, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 23, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 26, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 28, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 34, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 35, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 37, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 39, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 40, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 41, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 42, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 43, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 60, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 64, @event_on


        -- Audit Server Operation Event:  Occurs when Security Audit operations such as altering settings, resources, external access, or authorization are used.
        SET @event_id = 173
        EXEC sp_trace_setevent @trace_id, @event_id, 1, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 6, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 7, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 8, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 10, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 11, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 12, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 14, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 23, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 26, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 28, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 34, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 35, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 37, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 40, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 41, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 60, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 64, @event_on


        -- Audit Server Alter Trace Event:  Occurs when a statement checks for the ALTER TRACE permission.
        SET @event_id = 175
        EXEC sp_trace_setevent @trace_id, @event_id, 1, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 6, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 7, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 8, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 10, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 11, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 12, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 14, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 23, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 26, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 28, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 34, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 35, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 37, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 40, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 41, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 60, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 64, @event_on


        -- Audit Server Object Management Event:  Occurs when server objects are created, altered, or dropped.
        SET @event_id = 176
        EXEC sp_trace_setevent @trace_id, @event_id, 1, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 6, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 7, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 8, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 10, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 11, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 12, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 14, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 23, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 26, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 28, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 34, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 35, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 37, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 40, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 41, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 45, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 46, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 60, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 64, @event_on


        -- Audit Server Principal Management Event:  Occurs when server principals are created, altered, or dropped.
        SET @event_id = 177
        EXEC sp_trace_setevent @trace_id, @event_id, 1, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 6, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 7, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 8, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 10, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 11, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 12, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 14, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 23, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 26, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 28, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 34, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 35, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 37, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 39, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 40, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 41, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 42, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 43, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 45, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 60, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 64, @event_on


        -- Audit Database Operation Event:  Occurs when database operations occur, such as checkpoint or subscribe query notification.
        SET @event_id = 178
        EXEC sp_trace_setevent @trace_id, @event_id, 1, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 6, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 7, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 8, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 10, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 11, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 12, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 14, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 23, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 26, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 28, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 34, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 35, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 37, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 40, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 41, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 60, @event_on
        EXEC sp_trace_setevent @trace_id, @event_id, 64, @event_on

       
        -- Set the trace status to start.
        EXEC SP_TRACE_SETSTATUS @trace_id, 1
    END
END
GO