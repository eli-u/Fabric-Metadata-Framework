CREATE TABLE [dbo].[PipelineLog] (
    [RunID]            VARCHAR (20)  NULL,
    [PipelineID]       VARCHAR (100) NOT NULL,
    [PipelineName]     VARCHAR (100) NOT NULL,
    [SourceToTargetID] INT           NOT NULL,
    [Status]           VARCHAR (100) NULL,
    [StartTime]        DATETIME      NULL,
    [EndTime]          DATETIME      NULL,
    [SnapshotDate]     DATE          NULL,
    [UpdatedAt]        DATETIME      NULL
);


GO

