CREATE TABLE [dbo].[Batch] (
    [ID]                 INT           IDENTITY (1, 1) NOT NULL,
    [SystemInfoID]       INT           NOT NULL,
    [SystemCode]         VARCHAR (5)   NOT NULL,
    [ScheduledStartTime] VARCHAR (10)  NULL,
    [TimeZone]           VARCHAR (100) NULL,
    [Frequency]          VARCHAR (10)  NOT NULL,
    [Status]             VARCHAR (20)  NOT NULL,
    [UpdateAt]           DATETIME      NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [Batch_FK1] FOREIGN KEY ([SystemInfoID]) REFERENCES [dbo].[SystemInfo] ([ID]),
    CONSTRAINT [Batch_UK1] UNIQUE NONCLUSTERED ([SystemInfoID] ASC)
);


GO

