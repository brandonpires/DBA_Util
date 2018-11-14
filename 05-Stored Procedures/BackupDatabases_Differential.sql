USE DBA_Util
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'BackupDatabases_Differential')
    DROP PROCEDURE BackupDatabases_Differential
GO


/* Name:  BackupDatabases_Differential
 * Description:  This procedure creates a differential backup for a database within that database's backup sub-directory.
 * Preconditions:
 *     - The BackupDatabase procedure exists.
 * Parameters:
 *     - @dir - The backup file directory path.
 * Postconditions:
 *     - A backup device for the database will be created.  Details on that can be found in the BackupDevice_RefreshOne procedure.
 *     - A differential backup file will be created using the naming convention defined in the new backup device.
 */
CREATE PROCEDURE [dbo].[BackupDatabases_Differential] (@dir VARCHAR(4000))
WITH ENCRYPTION
AS
BEGIN
    DECLARE @db_name SYSNAME

    -- gets the database names, sans the exclusions
    DECLARE db_names CURSOR LOCAL STATIC FOR SELECT name
                                             FROM master.sys.databases db
                                             WHERE state = 0 -- online database
                                                   AND name NOT LIKE 'Search%' -- HARD-CODED FILTER
                                                   AND name NOT LIKE '%SRCH%' -- HARD-CODED FILTER
                                                   AND name NOT LIKE '%TelligentAnalytics' -- HARD-CODED FILTER
                                                   AND name NOT LIKE '%APAN_METRICS' -- HARD-CODED FILTER
                                                   AND name NOT IN ('master', 'tempdb') -- necessary filter
                                             ORDER BY name

    OPEN db_names
    FETCH NEXT FROM db_names INTO @db_name

    -- performs a transaction log and differential backup on each database name in db_names
    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC BackupDatabase @db_name
                            ,'Transaction Log'
                            ,@dir

        EXEC BackupDatabase @db_name
                            ,'Differential'
                            ,@dir
        
        FETCH NEXT FROM db_names INTO @db_name
    END

    CLOSE db_names
    DEALLOCATE db_names
END
GO