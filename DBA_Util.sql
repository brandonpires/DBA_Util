USE master
GO


CREATE DATABASE DBA_Util
    ON PRIMARY (NAME = 'DBA_Util_Data'
                ,FILENAME = '')  -- TODO: Update file name
    LOG ON (NAME = 'DBA_Util_Log'
            ,FILENAME = '')  -- TODO: Update file name
GO


ALTER DATABASE DBA_Util
    SET RECOVERY SIMPLE 
GO