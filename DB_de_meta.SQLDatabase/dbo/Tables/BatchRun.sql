CREATE TABLE [dbo].[BatchRun] (
    [RunID]        VARCHAR (20) NOT NULL,
    [BatchID]      INT          NOT NULL,
    [SystemCode]   VARCHAR (5)  NOT NULL,
    [RunNumber]    INT          NOT NULL,
    [StartTime]    DATETIME     NULL,
    [EndTime]      DATETIME     NULL,
    [SnapshotDate] DATE         NULL,
    [Restart]      VARCHAR (10) NULL,
    [Status]       VARCHAR (25) NULL,
    [CurrentIND]   INT          NULL,
    [UpdateAt]     DATETIME     NOT NULL,
    CONSTRAINT [BatchRun_FK1] FOREIGN KEY ([BatchID]) REFERENCES [dbo].[Batch] ([ID])
);


GO

