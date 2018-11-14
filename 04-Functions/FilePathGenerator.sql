USE DBA_Util
GO

IF EXISTS (SELECT 1 FROM sys.objects WHERE type = 'FN' AND name = 'FilePathGenerator')
    DROP FUNCTION FilePathGenerator
GO

CREATE FUNCTION FilePathGenerator (@root_dir VARCHAR(4000)
                                   ,@sub_dir SYSNAME
                                   ,@file_name SYSNAME
                                   ,@use_underscore BIT = 'TRUE')
RETURNS VARCHAR(MAX)
WITH ENCRYPTION
AS
BEGIN
    DECLARE @now      DATETIME
            ,@file_path VARCHAR(MAX)

    SET @now = GETDATE()
    SET @sub_dir = ISNULL(@sub_dir, '')

    -- add '\' as the last character to @dir if '\' is not already the last character
    IF RIGHT(@root_dir, 1) != '\'
        SET @root_dir = @root_dir + '\'

    
    IF LEN(@sub_dir) > 0
    BEGIN
        -- removes the first character from @sub_dir if it is '\'
        IF LEFT(@sub_dir, 1) = '\'
            SET @sub_dir = RIGHT(@sub_dir, LEN(@sub_dir) - 1)


        -- add '\' as the last character to @sub_dir if '\' is not already the last character
        IF RIGHT(@sub_dir, 1) != '\'
           AND @file_name != ''
            SET @sub_dir = @sub_dir + '\'
    END


    SET @file_path = @root_dir + @sub_dir


    -- creates the directory for the @sub_dir database backups
    EXEC master.dbo.xp_create_subdir @file_path


    -- creates the full path, including the file name, for the backup
    IF @file_name != ''
    BEGIN
        SET @file_name = @file_name
                         + '_' + CONVERT(VARCHAR, DATEPART(YEAR, @now))
                         + '_' + RIGHT('0' + CONVERT(VARCHAR, DATEPART(MONTH, @now)), 2)
                         + '_' + RIGHT('0' + CONVERT(VARCHAR, DATEPART(DAY, @now)), 2)
                         + '_' + RIGHT('0' + CONVERT(VARCHAR, DATEPART(HOUR, @now)), 2)
                               + RIGHT('0' + CONVERT(VARCHAR, DATEPART(MINUTE, @now)), 2)
                               + RIGHT('0' + CONVERT(VARCHAR, DATEPART(SECOND, @now)), 2)
                         + '_' + RIGHT('000000' + CONVERT(VARCHAR, DATEPART(MICROSECOND, @now)), 7)
    END

    IF @use_underscore = 'FALSE'
        SET @file_name = REPLACE(@file_name, '_', '')

    SET @file_path = @file_path + @file_name

    RETURN @file_path

END
GO