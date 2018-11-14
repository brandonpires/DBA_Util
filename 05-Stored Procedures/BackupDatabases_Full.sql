USE DBA_Util
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'BackupDatabases_Full')
    DROP PROCEDURE BackupDatabases_Full
GO


/* Name:  BackupDatabases_Full
 * Description:  This procedure creates a full backup for a database within that database's backup sub-directory.
 * Preconditions:
 *     - The BackupDatabase procedure exists.
 *     - The BackupDevice_RefreshOne procedure exists.
 *     - A full or differential backup file was created using the BackupNewDatabases or BackupDatabase_Differential procedures, respectively.
 * Parameters:
 *     - @dir - The backup file directory path.
 * Postconditions:
 *     - A backup device for the database will be created.  Details on that can be found in the BackupDevice_RefreshOne procedure.
 *     - A transaction log backup will be created in the latest full or differential backup file for that database.
 *     - A full backup file will be created using the naming convention defined in the new backup device.
 */
CREATE PROCEDURE [dbo].[BackupDatabases_Full] (@dir VARCHAR(4000))
WITH ENCRYPTION
AS
BEGIN
    DECLARE @db_name SYSNAME

    -- gets the database names, sans the exclusions
    DECLARE db_names CURSOR LOCAL STATIC FOR SELECT name
                                             FROM master.sys.databases db
                                             WHERE state = 0 -- online database
                                                   AND name != 'tempdb' -- necessary filter
                                             ORDER BY name

    OPEN db_names
    FETCH NEXT FROM db_names INTO @db_name

    -- performs a differential backup on each database name in db_names
    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC BackupDatabase @db_name
                            ,'Transaction Log'
                            ,@dir

        EXEC BackupDatabase @db_name
                            ,'Full'
                            ,@dir
        
        FETCH NEXT FROM db_names INTO @db_name
    END

    CLOSE db_names
    DEALLOCATE db_names
END
GO