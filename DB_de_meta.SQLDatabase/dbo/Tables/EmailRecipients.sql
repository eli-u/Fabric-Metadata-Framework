CREATE TABLE [dbo].[EmailRecipients] (
    [SystemCode]   VARCHAR (5)   NULL,
    [DatasetName]  VARCHAR (50)  NULL,
    [SystemInfoID] INT           NULL,
    [FirstName]    VARCHAR (100) NULL,
    [LastName]     VARCHAR (100) NULL,
    [EmailAddress] VARCHAR (100) NULL,
    CONSTRAINT [EmailRecipients_FK1] FOREIGN KEY ([SystemCode], [DatasetName]) REFERENCES [dbo].[SystemInfo] ([SystemCode], [DatasetName]),
    CONSTRAINT [EmailRecipients_UK1] UNIQUE NONCLUSTERED ([SystemCode] ASC, [DatasetName] ASC, [EmailAddress] ASC)
);


GO

