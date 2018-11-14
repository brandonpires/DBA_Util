USE DBA_Util
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'BackupDatabases_TransactionLog')
    DROP PROCEDURE BackupDatabases_TransactionLog
GO


/* Name:  BackupDatabases_TransactionLog
 * Description:  This procedure appends a transaction log backup for a database within that database's latest full or differential backup file.
 * Preconditions:
 *     - The BackupDatabase procedure exists.
 * Parameters:
 *     - @dir - The backup file directory path.
 * Postconditions:
 *     - A transaction log backup will be created in the latest full or differential backup file for that database.
 *     - Transaction log backups will only be attempted on databases that don't have the SIMPLE recovery model and is neither the master or tempdb database.
 */
CREATE PROCEDURE [dbo].[BackupDatabases_TransactionLog] (@dir VARCHAR(4000))
WITH ENCRYPTION
AS
BEGIN
    DECLARE @db_name SYSNAME

    -- gets the database names, sans the exclusions
    DECLARE db_names CURSOR LOCAL STATIC FOR SELECT name
                                             FROM master.sys.databases db
                                             WHERE state = 0 -- online database
                                                   AND recovery_model_desc != 'SIMPLE' -- database allows for transaction log backups
                                                   AND name NOT LIKE 'Search%' -- HARD-CODED FILTER
                                                   AND name NOT LIKE '%SRCH%' -- HARD-CODED FILTER
                                                   AND name NOT LIKE '%TelligentAnalytics' -- HARD-CODED FILTER
                                                   AND name NOT LIKE '%APAN_METRICS' -- HARD-CODED FILTER
                                                   AND name NOT IN ('master', 'tempdb') -- necessary filter
                                             ORDER BY name

    OPEN db_names
    FETCH NEXT FROM db_names INTO @db_name

    -- performs a transaction log backup on each database name in db_names
    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC BackupDatabase @db_name
                            ,'Transaction Log'
                            ,@dir
        
        FETCH NEXT FROM db_names INTO @db_name
    END

    CLOSE db_names
    DEALLOCATE db_names
END
GO