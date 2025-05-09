CREATE TABLE [dbo].[SystemInfo] (
    [ID]          INT           IDENTITY (1, 1) NOT NULL,
    [SystemCode]  VARCHAR (5)   NOT NULL,
    [SystemName]  VARCHAR (100) NOT NULL,
    [DatasetName] VARCHAR (50)  NOT NULL,
    [Description] VARCHAR (200) NULL,
    [Status]      VARCHAR (10)  NOT NULL,
    [UpdateAt]    DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [SystemInfo_UK1] UNIQUE NONCLUSTERED ([SystemCode] ASC, [DatasetName] ASC)
);


GO

