USE DBA_Util
GO


IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'CheckDbIntegrity')
BEGIN
    DROP PROCEDURE CheckDbIntegrity
END
GO


CREATE PROCEDURE CheckDbIntegrity (@data_drive_letter CHAR(1) = NULL
                                   ,@use_trace_flags BIT = 'TRUE')
WITH ENCRYPTION
AS
BEGIN
    DECLARE @db_name SYSNAME

    -- gets the database names with database files on the @data_drive_letter drive
    DECLARE db_names CURSOR FOR SELECT DISTINCT DB_NAME(database_id)
                                FROM master.sys.master_files mf
                                WHERE (LEFT(mf.physical_name, 1) = @data_drive_letter
                                       OR @data_drive_letter IS NULL)
                                      AND mf.type = 0
                                      AND EXISTS (SELECT 1
                                                  FROM sys.databases db
                                                  WHERE mf.database_id = db.database_id
                                                        AND db.state = 0) -- database is online


    OPEN db_names 
    FETCH NEXT FROM db_names INTO @db_name


    -- turns on performance optimizing trace flags for the session
    IF @use_trace_flags = 'TRUE'
    BEGIN
        DBCC TRACEON (2549, 2562) WITH NO_INFOMSGS
    END

    -- performs a dbcc checkdb on each database name in db_names
    WHILE @@FETCH_STATUS = 0
    BEGIN
        BEGIN TRY
            DBCC CHECKDB (@db_name) WITH NO_INFOMSGS
        END TRY
        BEGIN CATCH
            -- Do nothing
        END CATCH

        FETCH NEXT FROM db_names INTO @db_name
    END

    -- turns off performance optimizing trace flags for the session
    IF @use_trace_flags = 'TRUE'
    BEGIN
        DBCC TRACEOFF (2549, 2562) WITH NO_INFOMSGS
    END


    CLOSE db_names 
    DEALLOCATE db_names 
END
GO