CREATE TABLE [dbo].[DataObjectMetadata] (
    [ID]                 INT           IDENTITY (1, 1) NOT NULL,
    [SystemInfoID]       INT           NOT NULL,
    [DataObjectInfo]     VARCHAR (100) NOT NULL,
    [DataObjectName]     VARCHAR (50)  NOT NULL,
    [DataObjectType]     VARCHAR (20)  NOT NULL,
    [Container]          VARCHAR (50)  NULL,
    [RelativePathSchema] VARCHAR (100) NULL,
    [TechnicalName]      VARCHAR (50)  NOT NULL,
    [UpdatedAt]          DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [DataObjectMetadata_FK1] FOREIGN KEY ([SystemInfoID]) REFERENCES [dbo].[SystemInfo] ([ID]),
    CONSTRAINT [DataObjectMetadata_UK1] UNIQUE NONCLUSTERED ([DataObjectName] ASC, [RelativePathSchema] ASC)
);


GO

