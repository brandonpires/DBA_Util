USE DBA_Util
GO


/*** TABLES ***/
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'DbFileSizeLog')
BEGIN
    CREATE TABLE DbFileSizeLog
        (all_dbfiles_id              INT
         ,used_space_mb              FLOAT
         ,total_space_mb             FLOAT
         ,record_date_time           DATETIME)
END
GO


IF EXISTS (SELECT 1 FROM sys.tables t JOIN sys.columns c ON t.object_id = c.object_id
           WHERE t.name = 'DbFileSizeLog' AND c.name = 'all_dbfiles_id')
BEGIN 
    ALTER TABLE DbFileSizeLog
        ALTER COLUMN all_dbfiles_id INT NOT NULL
END
GO


IF EXISTS (SELECT 1 FROM sys.tables t JOIN sys.columns c ON t.object_id = c.object_id
           WHERE t.name = 'DbFileSizeLog' AND c.name = 'record_date_time')
BEGIN
    ALTER TABLE DbFileSizeLog
        ALTER COLUMN record_date_time DATETIME NOT NULL
END
GO


IF (NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = 'PK_DbFileSizeLog')
    AND EXISTS (SELECT 1 FROM sys.columns 
                WHERE object_id = OBJECT_ID('DbFileSizeLog') AND name IN ('all_dbfiles_id', 'record_date_time') AND is_nullable = 0))
BEGIN
    ALTER TABLE DbFileSizeLog ADD CONSTRAINT PK_DbFileSizeLog PRIMARY KEY CLUSTERED
        (all_dbfiles_id
         ,record_date_time)
END
GO


IF NOT EXISTS (SELECT 1 FROM sys.tables t JOIN sys.columns c ON t.object_id = c.object_id
               WHERE t.name = 'DbFileSizeLog' AND c.name = 'autogrowth_mb')
BEGIN
    ALTER TABLE DbFileSizeLog
        ADD autogrowth_mb FLOAT
END
GO


IF NOT EXISTS (SELECT 1 FROM sys.tables t JOIN sys.columns c ON t.object_id = c.object_id
               WHERE t.name = 'DbFileSizeLog' AND c.name = 'max_space_mb')
BEGIN
    ALTER TABLE DbFileSizeLog
        ADD max_space_mb FLOAT
END
GO



/*** INDEXES ***/
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_DbFileSizeLog_01')
BEGIN
    CREATE NONCLUSTERED INDEX IX_DbFileSizeLog_01 ON DbFileSizeLog
        (all_dbfiles_id
         ,total_space_mb
         ,used_space_mb)
END
GO


IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_DbFileSizeLog_02')
BEGIN
    CREATE NONCLUSTERED INDEX IX_DbFileSizeLog_02 ON DbFileSizeLog
        (record_date_time)
END
GO