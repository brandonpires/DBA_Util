USE DBA_Util
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'BackupDevice_DeleteOld')
    DROP PROCEDURE BackupDevice_DeleteOld
GO


/* Name:  BackupDevice_DeleteOld
 * Description:  This procedure deletes a backup device for a database that no longer exists.
 * Preconditions: None
 * Parameters: None
 * Postconditions:
 *     - Any backup devices that are associated with a database that no longer exists is deleted.
 */
CREATE PROCEDURE BackupDevice_DeleteOld
WITH ENCRYPTION
AS
BEGIN
    DECLARE @backup_device_name SYSNAME

    DECLARE bak_names CURSOR FOR SELECT name
                                FROM master.sys.backup_devices bak
                                WHERE NOT EXISTS (SELECT 1
                                                  FROM master.sys.databases db
                                                  WHERE REPLACE(bak.name, '_backup_device', '') = db.name)

    OPEN bak_names
    FETCH NEXT FROM bak_names INTO @backup_device_name

    -- drops a backup device for a database that doesn't exist
    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC sp_dropdevice @backup_device_name

        FETCH NEXT FROM bak_names INTO @backup_device_name
    END

    CLOSE bak_names
    DEALLOCATE bak_names
END
GO
