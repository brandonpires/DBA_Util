USE DBA_Util
GO


IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'AllDbFiles')
BEGIN
    CREATE TABLE AllDbFiles
        (all_dbfiles_id             INT         IDENTITY(1, 1)
         ,database_id               INT
         ,database_name             SYSNAME
         ,file_id                   INT
         ,file_name                 SYSNAME
         ,type                      VARCHAR(13)
         ,CONSTRAINT PK_AllDbFiles PRIMARY KEY CLUSTERED (all_dbfiles_id))
END
GO


IF NOT EXISTS (SELECT 1 FROM sys.tables t JOIN sys.columns c ON t.object_id = c.object_id
               WHERE t.name = 'AllDbFiles' AND c.name = 'file_path')
BEGIN
    ALTER TABLE AllDbFiles
        ADD file_path VARCHAR(4000)
END
GO


IF EXISTS (SELECT 1 FROM sys.tables t JOIN sys.columns c ON t.object_id = c.object_id
           WHERE t.name = 'AllDbFiles' AND c.name = 'file_name')
BEGIN
    ALTER TABLE AllDbFiles
        DROP COLUMN file_name
END
GO


IF NOT EXISTS (SELECT 1 FROM sys.tables t JOIN sys.columns c ON t.object_id = c.object_id
               WHERE t.name = 'AllDbFiles' AND c.name = 'logical_file_name')
BEGIN
    ALTER TABLE AllDbFiles
        ADD logical_file_name SYSNAME
END
GO



/*** DATA ***/
UPDATE dbf
SET logical_file_name = mf.name
FROM AllDbFiles dbf
     JOIN sys.master_files mf ON dbf.file_path = mf.physical_name
WHERE logical_file_name IS NULL