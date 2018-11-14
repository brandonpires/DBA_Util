USE DBA_Util
GO


IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'JobsOwner_Standardize')
BEGIN
    DROP PROCEDURE JobsOwner_Standardize
END
GO


CREATE PROCEDURE JobsOwner_Standardize
WITH ENCRYPTION
AS
BEGIN
    DECLARE @sql                    VARCHAR(MAX)
            ,@login_name            SYSNAME
            ,@jobs_name_cursor      SYSNAME

    -- gets the sa account name since it probably changed
    SELECT @login_name = name
    FROM sys.sql_logins
    WHERE principal_id = 1

    -- gets all jobs associated with a maintenance plan
    DECLARE jobs CURSOR LOCAL FOR SELECT REPLACE(j.name, '''', '''''')
                                  FROM msdb.dbo.sysjobs j
                                       JOIN msdb.dbo.syscategories c ON j.category_id = c.category_id
                                  WHERE c.name = 'Database Maintenance'
                                  ORDER BY j.name

    OPEN jobs
    FETCH NEXT FROM jobs INTO @jobs_name_cursor

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @sql = 'EXEC msdb.dbo.sp_update_job @job_name = N''' + @jobs_name_cursor + ''', @owner_login_name = N''' + @login_name + ''''

        EXEC (@sql)

        FETCH NEXT FROM jobs INTO @jobs_name_cursor
    END

    CLOSE jobs
    DEALLOCATE jobs
END
GO
