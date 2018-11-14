USE DBA_Util
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'BackupNewDatabases')
    DROP PROCEDURE BackupNewDatabases
GO


/* Name:  BackupNewDatabases
 * Description:  This procedure creates a full backup any database that has never been backed up.
 * Preconditions:
 *     - The BackupDatabase procedure exists.
 * Parameters:
 *     - @dir - The backup file directory path.
 * Postconditions:
 *     - A full backup file will be created using the naming convention defined in the new backup device.
 */
CREATE PROCEDURE [dbo].[BackupNewDatabases] (@dir VARCHAR(4000))
WITH ENCRYPTION
AS
BEGIN
    DECLARE @db_name SYSNAME

    -- gets the names of databases that have no records of being backed up in msdb
    DECLARE db_names CURSOR FOR SELECT name
                                FROM master.sys.databases db
                                WHERE NOT EXISTS (SELECT 1
                                                  FROM msdb.dbo.backupset bs
                                                  WHERE db.name = bs.database_name
                                                        AND db.create_date < bs.backup_finish_date)
                                      AND db.name != 'tempdb' -- necessary filter
                                ORDER BY 1 DESC

    OPEN db_names
    FETCH NEXT FROM db_names INTO @db_name

    -- performs a full backup on each database name in db_names
    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC BackupDatabase @db_name
                            ,'Full'
                            ,@dir
        
        FETCH NEXT FROM db_names INTO @db_name
    END

    CLOSE db_names
    DEALLOCATE db_names
END
GO