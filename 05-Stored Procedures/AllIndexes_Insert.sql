USE DBA_Util
GO


IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'AllIndexes_Insert')
BEGIN
    DROP PROCEDURE AllIndexes_Insert
END
GO


CREATE PROCEDURE AllIndexes_Insert
WITH ENCRYPTION
AS
BEGIN
    DECLARE @sql                VARCHAR(MAX)
            ,@db_name_cursor    SYSNAME

    DECLARE db_names CURSOR LOCAL FOR SELECT name
                                      FROM sys.databases
                                      WHERE name != 'tempdb'
                                            AND state = 0  -- database is online

    OPEN db_names
    FETCH NEXT FROM db_names INTO @db_name_cursor

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- inserts records for new indexes
        SET @sql = 'USE [' + @db_name_cursor + ']' + CHAR(10)
                + ' INSERT INTO DBA_Util.dbo.AllIndexes (database_id' + CHAR(10)
                + '                                      ,database_name' + CHAR(10)
                + '                                      ,schema_id' + CHAR(10)
                + '                                      ,schema_name' + CHAR(10)
                + '                                      ,object_id' + CHAR(10)
                + '                                      ,table_name' + CHAR(10)
                + '                                      ,index_id' + CHAR(10)
                + '                                      ,index_name' + CHAR(10)
                + '                                      ,state' + CHAR(10)
                + '                                      ,type)' + CHAR(10)
                + ' SELECT DB_ID()                      AS database_id' + CHAR(10)
                + '        ,''' + @db_name_cursor + ''' AS database_name' + CHAR(10)
                + '        ,s.schema_id                 AS schema_id' + CHAR(10)
                + '        ,s.name                      AS schema_name' + CHAR(10)
                + '        ,t.object_id                 AS object_id' + CHAR(10)
                + '        ,t.name                      AS table_name' + CHAR(10)
                + '        ,i.index_id                  AS index_id' + CHAR(10)
                + '        ,i.name                      AS index_name' + CHAR(10)
                + '        ,CASE i.is_disabled WHEN 0 THEN ''Enabled'' ELSE ''Disabled'' END AS state' + CHAR(10)
                + '        ,CASE i.type' + CHAR(10)
                + '              WHEN 1 THEN ''Clustered''' + CHAR(10)
                + '              WHEN 2 THEN ''Non-Clustered''' + CHAR(10)
                + '              WHEN 3 THEN ''XML''' + CHAR(10)
                + '              WHEN 4 THEN ''Spatial''' + CHAR(10)
                + '              ELSE i.type_desc' + CHAR(10)
                + '         END AS type' + CHAR(10)
                + ' FROM sys.tables t' + CHAR(10)
                + '      JOIN sys.schemas s ON t.schema_id = s.schema_id' + CHAR(10)
                + '      JOIN sys.indexes i ON t.object_id = i.object_id' + CHAR(10)
                + ' WHERE i.is_hypothetical = 0' + CHAR(10)
                + '       AND i.type != 0' + CHAR(10)
                + '       AND NOT EXISTS (SELECT 1' + CHAR(10)
                + '                       FROM DBA_Util.dbo.AllIndexes ai' + CHAR(10)
                + '                       WHERE ai.database_id = DB_ID()' + CHAR(10)
                + '                             AND ai.object_id = t.object_id' + CHAR(10)
                + '                             AND ai.index_id = i.index_id)' + CHAR(10)
        EXEC (@sql)

        FETCH NEXT FROM db_names INTO @db_name_cursor
    END

    CLOSE db_names
    DEALLOCATE db_names
END
GO