USE DBA_Util
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'BackupDatabase')
    DROP PROCEDURE BackupDatabase
GO


/* Name:  BackupDatabase
 * Description:  This procedure creates a backup and backup file for a specified type of backup.
 * Preconditions:
 *     - The BackupDevice_RefreshOne procedure exists.
 *     - The DbBackupFileLog_InsertNew procedure exists.  This is for logging purposes.
 * Parameters:
 *     - @db_name - The name of an existing database.
 *     - @backup_type - Full, differential, or transaction log
 *     - @backup_dir - The backup file directory.
 * Postconditions:
 *     - A backup device for the database will be created.  Details on that can be found in the BackupDevice_RefreshOne procedure.
 *     - A transaction log backup will be created in the latest full or differential backup file for that database.
 *     - A full backup file will be created using the naming convention defined in the new backup device.
 */
CREATE PROCEDURE BackupDatabase (@db_name       SYSNAME
                                 ,@backup_type  VARCHAR(15) = 'FULL'
                                 ,@backup_dir   VARCHAR(4000) = NULL)
WITH ENCRYPTION
AS
BEGIN
    -- if the database is not a snapshot database
    IF EXISTS (SELECT 1 FROM sys.databases WHERE name = @db_name
                                                 AND source_database_id IS NULL)
    BEGIN
        DECLARE @sql NVARCHAR(MAX)
                ,@status VARCHAR(7)


        -- Refresh backup device location
        IF @backup_type NOT LIKE 'T%' -- Full or Differential
        BEGIN
            EXEC BackupDevice_RefreshOne @db_name
                                         ,@backup_type
                                         ,@backup_dir

        END


        -- Perform backup
        IF @backup_type LIKE 'F%' -- Full
        BEGIN
            BEGIN TRY
                SET @sql = 'BACKUP DATABASE ['+ @db_name + ']' + CHAR(10)
                           + 'TO [' + @db_name + '_backup_device]' + CHAR(10)
                           + 'WITH COMPRESSION'
                EXEC (@sql)

                SET @status = 'Success'
            END TRY
            BEGIN CATCH
                SET @status = 'Fail'
            END CATCH
        END

        IF @backup_type LIKE 'D%' -- Differential
        BEGIN
            BEGIN TRY
                SET @sql = 'BACKUP DATABASE ['+ @db_name + ']' + CHAR(10)
                           + 'TO [' + @db_name + '_backup_device]' + CHAR(10)
                           + 'WITH DIFFERENTIAL, COMPRESSION'
                EXEC (@sql)

                SET @status = 'Success'
            END TRY
            BEGIN CATCH
                SET @status = 'Fail'
            END CATCH
        END
     
        IF @backup_type LIKE 'T%' -- Transaction Log
           AND EXISTS (SELECT 1 FROM sys.databases WHERE name = @db_name AND recovery_model_desc != 'Simple') -- Full or Bulk logged recovery model
        BEGIN
            BEGIN TRY
                SET @sql = 'BACKUP LOG ['+ @db_name + ']' + CHAR(10)
                            + 'TO [' + @db_name + '_backup_device]' + CHAR(10)
                            + 'WITH COMPRESSION'
                EXEC (@sql)

                SET @status = 'Success'
            END TRY
            BEGIN CATCH
                SET @status = 'Fail'
            END CATCH
        END

        EXEC DbBackupFileLog_InsertNew @db_name
                                       ,@status
                                       ,@backup_type
    END
END
GO
