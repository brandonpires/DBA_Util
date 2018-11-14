USE DBA_Util
GO


IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'BrentOzar_Blitz')
BEGIN
    CREATE TABLE BrentOzar_Blitz
        (ID                  INT               IDENTITY(1,1) NOT NULL
         ,ServerName         NVARCHAR(128)                   NULL
         ,CheckDate          DATETIMEOFFSET(7)               NULL
         ,Priority           TINYINT                         NULL
         ,FindingsGroup      VARCHAR(50)                     NULL
         ,Finding            VARCHAR(200)                    NULL
         ,DatabaseName       NVARCHAR(128)                   NULL
         ,URL                VARCHAR(200)                    NULL
         ,Details            NVARCHAR(4000)                  NULL
         ,QueryPlan          XML                             NULL
         ,QueryPlanFiltered  NVARCHAR(max)                   NULL
         ,CheckID            INT                             NULL
         ,CONSTRAINT [PK_BrentOzar_Blitz] PRIMARY KEY CLUSTERED (ID ASC))
END
GO
