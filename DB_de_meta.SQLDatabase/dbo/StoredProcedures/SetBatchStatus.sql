
CREATE PROC SetBatchStatus(
    @PSystemCode varchar(5),
    @PFrequency varchar(10)
)
AS

    DECLARE @batchStatus varchar(25);
    DECLARE @RunID varchar(50);
    DECLARE @PipelineStatus varchar(25);
    DECLARE @RC int;
    DECLARE @SnapshotDate date;
    DECLARE @BatchID int;
    DECLARE @RunNumber int;
    DECLARE @SystemCode varchar(5);
    DECLARE @StartTime datetime;
    DECLARE @Restart varchar(10);
    DECLARE @Status varchar(20);
    DECLARE @CurrentIND int; 
    DECLARE @UpdateAt datetime;
    DECLARE @CurrentTimeZoneTimeStamp datetime;
    DECLARE @TimeZone varchar(100); 
    SELECT @batchStatus = 'UNDEFINED';

    SET @TimeZone = (SELECT distinct TimeZone from dbo.Batch WHERE SystemCode = @PSystemCode AND Frequency = @PFrequency)
    SET @CurrentTimeZoneTimeStamp = CAST((GETDATE() AT TIME ZONE 'UTC' AT TIME ZONE @TimeZone) as datetime)

    UPDATE dbo.BatchRun
       SET CurrentIND = -1,
           UpdateAt = @CurrentTimeZoneTimeStamp
     WHERE Status = 'COMPLETED-SUCCESSFULLY'
       AND CurrentIND = 0
       AND SnapshotDate < CAST(@CurrentTimeZoneTimeStamp-1 AS Date)
       AND BatchID in (SELECT BatchID
                      FROM Batch
                      WHERE SystemCode = @PSystemCode
                        AND Frequency = @PFrequency)

    --SET PREVIOUS RUN TO ARCHIVE  

    DECLARE batchrun_status_cursor CURSOR LOCAL
        FOR SELECT distinct 
                a.RunID,
                a.[Status] as PipelineStatus
              FROM 
                dbo.PipelineLog a
            INNER JOIN dbo.BatchRun b
            ON b.RunID = a.RunID
            WHERE a.[Status] in ('Failed')
            AND a.EndTime is not null
            AND b.[Status] = 'IN-PROGRESS';

    OPEN batchrun_status_cursor;
    FETCH NEXT FROM batchrun_status_cursor INTO @RunID, @PipelineStatus;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF @PipelineStatus = 'Failed'
            SELECT @batchStatus = 'COMPLETED-WITH-ERRORS'
            UPDATE dbo.BatchRun
               SET [Status] = @batchStatus,
               UpdateAt = @CurrentTimeZoneTimeStamp,
               EndTime = @CurrentTimeZoneTimeStamp
             WHERE RunID = @RunID        
        FETCH NEXT FROM batchrun_status_cursor INTO @RunID, @PipelineStatus;
    END;

    CLOSE batchrun_status_cursor;

     UPDATE dbo.BatchRun
       SET [Status] = 'COMPLETED-SUCCESSFULLY',
       UpdateAt = @CurrentTimeZoneTimeStamp,
       EndTime = @CurrentTimeZoneTimeStamp,
       CurrentIND = 0
     WHERE RunID in (SELECT distinct 
                    a.RunID
                    FROM 
                        dbo.PipelineLog a
                    INNER JOIN dbo.BatchRun b
                    ON b.RunID = a.RunID
                    WHERE a.[Status] in ('Failed','Success')
                    AND a.EndTime is not null
                    AND b.[Status] = 'IN-PROGRESS')
       AND [Status] != 'COMPLETED-WITH-ERRORS';    

       --CREATE NEW BATCH
        DECLARE batchrun_cursor CURSOR LOCAL
            FOR
                SELECT  BatchID,
                        SystemCode,
                        1 as RunNumber,
                        null as StartTime,
                        dateadd(day, 1, SnapshotDate) as SnapshotDate,
                        'False' as Restart,
                        'NOT-STARTED' as Status,
                         1 as CurrentIND,
                         @CurrentTimeZoneTimeStamp as UpdateAt 
                FROM  dbo.BatchRun
                WHERE  SystemCode = 'OWS'
                AND  SnapshotDate <= CAST(@CurrentTimeZoneTimeStamp-1 AS Date)
                AND CurrentIND = 0
                AND Status IN ('COMPLETED-SUCCESSFULLY')
                AND BatchID IN (SELECT BatchID
                                    FROM Batch
                                    WHERE Status = 'Active'
                                    AND SystemCode = @PSystemCode
                                    AND Frequency =  @PFrequency)
                AND BatchID NOT IN (SELECT BatchID
                                    FROM dbo.BatchRun
                                    WHERE [Status] in ('NOT-STARTED','IN-PROGRESS'))
    
        OPEN batchrun_cursor;
        FETCH NEXT FROM batchrun_cursor INTO @BatchID, @SystemCode, @RunNumber, @StartTime, @SnapshotDate, @Restart, @Status, @CurrentIND, @UpdateAt;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            EXECUTE @RC = [dbo].[GetRunID] 
                    @SnapshotDate
                    ,@BatchID
                    ,@RunNumber
                    ,@RunID OUTPUT

            INSERT INTO dbo.BatchRun(
                RunID,
                BatchID,
                SystemCode,
                RunNumber,
                StartTime,
                SnapshotDate,
                Restart,
                Status,
                CurrentIND,
                UpdateAt
            )
            VALUES(
                @RunID,
                @BatchID,
                @SystemCode,
                @RunNumber,
                @StartTime,
                @SnapshotDate,
                @Restart,
                @Status,
                @CurrentIND,
                @UpdateAt
            );

            FETCH NEXT FROM batchrun_cursor INTO @BatchID, @SystemCode, @RunNumber, @StartTime, @SnapshotDate, @Restart, @Status, @CurrentIND,  @UpdateAt;
            
        END;

        CLOSE batchrun_cursor;

GO

