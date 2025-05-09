CREATE TABLE [dbo].[SourceToTargetMetadata] (
    [ID]                  INT          IDENTITY (1, 1) NOT NULL,
    [SourceID]            INT          NOT NULL,
    [TargetID]            INT          NOT NULL,
    [DepSourceToTargetID] INT          NULL,
    [Stage]               VARCHAR (50) NOT NULL,
    [Status]              VARCHAR (10) NOT NULL,
    [UpdateAt]            DATETIME     NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [SourceToTargetMetadata_FK1] FOREIGN KEY ([SourceID]) REFERENCES [dbo].[DataObjectMetadata] ([ID]),
    CONSTRAINT [SourceToTargetMetadata_FK2] FOREIGN KEY ([TargetID]) REFERENCES [dbo].[DataObjectMetadata] ([ID]),
    CONSTRAINT [SourceToTargetMetadata_UK1] UNIQUE NONCLUSTERED ([SourceID] ASC, [TargetID] ASC)
);


GO

