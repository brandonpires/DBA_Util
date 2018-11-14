USE DBA_Util
GO


/*** TABLES ***/
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'DbFileAutogrowthLookup')
BEGIN
    CREATE TABLE DbFileAutogrowthLookup
        (type                        CHAR(4)
         ,lower_mb                   INT
         ,upper_mb                   INT
         ,autogrowth_mb              INT
         ,CONSTRAINT PK_DbFileAutogrowthLookup PRIMARY KEY CLUSTERED (type
                                                                      ,lower_mb
                                                                      ,upper_mb)
        )
END
GO



/*** DATA ***/
DECLARE @type CHAR(4)
SET @type = 'Data'

IF NOT EXISTS (SELECT 1 FROM DbFileAutogrowthLookup WHERE type = @type)
BEGIN
    INSERT INTO DbFileAutogrowthLookup (type, lower_mb, upper_mb, autogrowth_mb)
    SELECT @type, 0, 90, 10
    UNION
    SELECT @type, 100, 350, 50
    UNION
    SELECT @type, 400, 900, 100
    UNION
    SELECT @type, 1000, 1800, 200
    UNION
    SELECT @type, 2000, 4500, 500
    UNION
    SELECT @type, 5000, 9000, 1000
    UNION
    SELECT @type, 10000, 18000, 2000
    UNION
    SELECT @type, 20000, 45000, 5000
    UNION
    SELECT @type, 50000, 2147483647, 10000
END


SET @type = 'TLog'

IF NOT EXISTS (SELECT 1 FROM DbFileAutogrowthLookup WHERE type = @type)
BEGIN
    INSERT INTO DbFileAutogrowthLookup (type, lower_mb, upper_mb, autogrowth_mb)
    SELECT @type, 0, 90, 10
    UNION
    SELECT @type, 100, 180, 20
    UNION
    SELECT @type, 200, 750, 50
    UNION
    SELECT @type, 800, 1900, 100
    UNION
    SELECT @type, 2000, 4800, 200
    UNION
    SELECT @type, 5000, 9500, 500
    UNION
    SELECT @type, 10000, 2147483647, 1000
END