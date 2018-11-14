USE DBA_Util
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'BackupDevice_RefreshOne')
    DROP PROCEDURE BackupDevice_RefreshOne
GO


/* Name:  BackupDevice_RefreshOne
 * Description: This procedure creates a backup device for one database and a sub-directory within a designated backup directory.
 * Preconditions:
 *     - master.dbo.xp_create_subdir procedure creates a directory.  Since this is an undocumented procedure, it may change from version to version without warning.
 *     - AllDbBackups_InsertOne procedure exists.  This is for logging purposes.
 * Parameters:
 *     - @db_name - The name of a database.
 *     - @backup_type - The type of backup.  Although there are full, differential, and transaction log backups, this only cares if the backup is a full or differential backup.
 *     - @backup_dir - The backup file directory.
 * Postconditions:
 *     - A backup device for the database will be created.
 *     - A sub-directory for the backup will be created with the database name.
 */
CREATE PROCEDURE BackupDevice_RefreshOne (@db_name       SYSNAME
                                          ,@backup_type  VARCHAR(15) = 'Full'
                                          ,@backup_dir   VARCHAR(4000))
WITH ENCRYPTION
AS
BEGIN
    IF DB_ID(@db_name) IS NOT NULL -- is a database
       AND @backup_type NOT LIKE 'T%' -- full or differential backup type
    BEGIN
        DECLARE @backup_file_name     SYSNAME
                ,@backup_subdir       VARCHAR(4000)
                ,@backup_path         VARCHAR(MAX)
                ,@backup_device_name  SYSNAME


        IF @backup_type LIKE 'F%'
        BEGIN
            SET @backup_file_name = @db_name + '_fulltran'
            SET @backup_path = dbo.FilePathGenerator(@backup_dir, @db_name, @backup_file_name, 'TRUE') + '.bak'
        END
        ELSE
        BEGIN
            SET @backup_file_name = @db_name + '_difftran'
            SET @backup_path = dbo.FilePathGenerator(@backup_dir, @db_name, @backup_file_name, 'TRUE') + '.dif'
        END
       
        SET @backup_device_name = @db_name + '_backup_device'
        SET @backup_subdir = dbo.FilePathGenerator(@backup_dir, @db_name, '', 'TRUE')

        EXEC master.dbo.xp_create_subdir @backup_subdir
 
        IF EXISTS (SELECT 1 FROM sys.backup_devices WHERE name = @backup_device_name)
            EXEC sp_dropdevice @backup_device_name


        EXEC sp_addumpdevice 'disk'
                             ,@backup_device_name
                             ,@backup_path

        EXEC AllDbBackups_InsertOne @db_name
                                    ,@backup_path
    END
END
GO
