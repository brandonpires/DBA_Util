USE DBA_Util
GO


IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'DbVlfCountLog_InsertNew')
BEGIN
    DROP PROCEDURE DbVlfCountLog_InsertNew
END
GO


CREATE PROCEDURE DbVlfCountLog_InsertNew
WITH ENCRYPTION
AS
BEGIN
    DECLARE @db_name_cursor     SYSNAME
            ,@sql               VARCHAR(MAX)
            ,@record_date_time  DATETIME
    DECLARE @log_info TABLE
        (fileid        TINYINT
         ,file_size    BIGINT
         ,start_offset BIGINT
         ,fseqno       INT 
         ,[status]     TINYINT 
         ,parity       TINYINT 
         ,create_lsn   NUMERIC(25,0))
    DECLARE @log_info_2012 TABLE
        (recovery_unit_id  TINYINT
         ,fileid           TINYINT
         ,file_size        BIGINT
         ,start_offset     BIGINT
         ,fseqno           INT 
         ,[status]         TINYINT 
         ,parity           TINYINT 
         ,create_lsn       NUMERIC(25,0))


    SET @record_date_time = GETDATE()

    -- gets all database names
    DECLARE db_names CURSOR FOR SELECT name
                                FROM sys.databases

    OPEN db_names
    FETCH NEXT FROM db_names INTO @db_name_cursor

    -- gets virtual log file counts for each transaction log file
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @sql = 'DBCC LOGINFO(''' + @db_name_cursor + ''')'

        DELETE FROM @log_info

        IF @@VERSION NOT LIKE '%2008%'
        BEGIN
            INSERT INTO @log_info_2012
            EXEC (@sql)

            INSERT INTO @log_info
            SELECT fileid
                   ,file_size
                   ,start_offset
                   ,fseqno
                   ,[status] 
                   ,parity
                   ,create_lsn
            FROM @log_info_2012
        END
        ELSE
        BEGIN
            INSERT INTO @log_info
            EXEC (@sql)
        END

        INSERT INTO DbVlfCountLog (all_dbfiles_id
                                   ,vlf_count
                                   ,record_date_time)
        SELECT db.all_dbfiles_id
               ,li.vlf_count
               ,@record_date_time
        FROM AllDbFiles db
             JOIN (SELECT fileid
                          ,COUNT(1) AS vlf_count
                   FROM @log_info
                   GROUP BY fileid) li ON db.file_id = li.fileid
        WHERE db.database_name = @db_name_cursor

        FETCH NEXT FROM db_names INTO @db_name_cursor
    END

    CLOSE db_names
    DEALLOCATE db_names
END
GO