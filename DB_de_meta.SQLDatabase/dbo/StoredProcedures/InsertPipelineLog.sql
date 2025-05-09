CREATE PROC dbo.InsertPipelineLog(
    @RunID varchar(20),
    @PipelineID varchar(100),
    @PipelineName varchar(100),
    @SourceToTargetID int,
    @Status varchar(100),
    @EndTime datetime,
    @StartTime datetime,
    @SnapshotDate date,
    @UpdateAt date
)
AS
    INSERT INTO dbo.PipelineLog(
        RunID,
        PipelineID,
        PipelineName,        
        SourceToTargetID,
        Status,
        StartTime,
        EndTime,
        SnapshotDate,
        UpdatedAt
    )
    VALUES (
            @RunID,
            @PipelineID,
            @PipelineName,            
            @SourceToTargetID,
            @Status,
            @StartTime,
            @EndTime,
            @SnapshotDate,
            @UpdateAt)

GO

