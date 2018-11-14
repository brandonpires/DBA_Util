USE DBA_Util
GO


IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'AllDbFiles_Refresh')
BEGIN
    DROP PROCEDURE AllDbFiles_Refresh 
END
GO


CREATE PROCEDURE AllDbFiles_Refresh
WITH ENCRYPTION
AS
BEGIN
    -- delete file size logs for database files that no longer exist
    DELETE FROM l
    FROM DbFileSizeLog l
    WHERE NOT EXISTS (SELECT 1
                      FROM sys.master_files mf
                           JOIN AllDbFiles dbf ON mf.database_id = dbf.database_id
                                                  AND mf.physical_name = dbf.file_path
                      WHERE dbf.all_dbfiles_id = l.all_dbfiles_id)


    -- delete virtual log file logs for database files that no longer exist
    DELETE FROM l
    FROM DbVlfCountLog l
    WHERE NOT EXISTS (SELECT 1
                      FROM sys.master_files mf
                           JOIN AllDbFiles dbf ON mf.database_id = dbf.database_id
                                                  AND mf.physical_name = dbf.file_path
                      WHERE dbf.all_dbfiles_id = l.all_dbfiles_id)


    -- merge database file records
    MERGE AllDbFiles dbf
    USING (SELECT database_id
                  ,DB_NAME(database_id) AS database_name
                  ,file_id
                  ,CASE type
                       WHEN 0 THEN 'Data'
                       WHEN 1 THEN 'TLog'
                   END AS type
                  ,physical_name AS file_path
                  ,name AS logical_file_name
                  ,state
           FROM sys.master_files) mf
    ON dbf.database_id = mf.database_id
       AND dbf.file_path = mf.file_path
    WHEN MATCHED AND dbf.logical_file_name != mf.logical_file_name THEN
        UPDATE
        SET dbf.logical_file_name = mf.logical_file_name
    WHEN NOT MATCHED BY TARGET AND mf.state = 0 THEN
        INSERT (database_id
                ,database_name
                ,file_id
                ,type
                ,file_path
                ,logical_file_name)
        VALUES (database_id
                  ,database_name
                  ,file_id
                  ,type
                  ,file_path
                  ,logical_file_name)
    WHEN NOT MATCHED BY SOURCE THEN
        DELETE;
END
GO