USE DBA_Util
GO

IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'IndexDefragmentationLog')
   AND EXISTS (SELECT 1 FROM sys.tables WHERE name = 'AllIndexes')
   AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_IndexDefragmentationLog_AllIndexes')
BEGIN
ALTER TABLE IndexDefragmentationLog
    ADD CONSTRAINT FK_IndexDefragmentationLog_AllIndexes FOREIGN KEY (all_indexes_id)
        REFERENCES AllIndexes (all_indexes_id)
END
GO