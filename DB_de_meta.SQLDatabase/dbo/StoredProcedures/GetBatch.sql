
CREATE PROC GetBatch(
    @PSystemCode varchar(5),
    @PFrequency varchar(10)
)
AS
    DECLARE @RunID varchar(50);
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

    SET @TimeZone = (SELECT distinct TimeZone from dbo.Batch WHERE SystemCode = @PSystemCode AND Frequency = @PFrequency)
    SET @CurrentTimeZoneTimeStamp = CAST((GETDATE() AT TIME ZONE 'UTC' AT TIME ZONE @TimeZone) as datetime)
            
    UPDATE dbo.BatchRun
       SET Status = 'IN-PROGRESS',
           StartTime = @CurrentTimeZoneTimeStamp, 
           UpdateAt = @CurrentTimeZoneTimeStamp
     WHERE SystemCode = @PSystemCode
       AND Status = 'NOT-STARTED'
       AND SnapshotDate <= CAST(@CurrentTimeZoneTimeStamp-1 AS Date)
       AND BatchID IN (SELECT BatchID
                         FROM Batch
                        WHERE Status = 'Active'
                          AND SystemCode = @PSystemCode
                          AND Frequency = @PFrequency);

    DECLARE batchrun_cursor CURSOR LOCAL
        FOR SELECT  BatchID,
                    SystemCode,
                    (RunNumber + 1) as RunNumber,
                    @CurrentTimeZoneTimeStamp as StartTime,
                    SnapshotDate,
                    'True' as Restart,
                    'IN-PROGRESS' as Status,
                     CurrentIND,
                     @CurrentTimeZoneTimeStamp as UpdateAt 
            FROM  dbo.BatchRun
            WHERE  SystemCode = @PSystemCode
            AND  SnapshotDate <= CAST(@CurrentTimeZoneTimeStamp-1 AS Date)
            AND CurrentIND = 1
            AND Status IN ('COMPLETED-WITH-ERRORS')
            AND BatchID IN (SELECT BatchID
                              FROM Batch
                             WHERE Status = 'Active'
                               AND SystemCode = @PSystemCode
                               AND Frequency = @PFrequency);  
    
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

    UPDATE dbo.BatchRun
       SET CurrentIND = 0, 
           UpdateAt = @CurrentTimeZoneTimeStamp
     WHERE SystemCode = @PSystemCode
       AND Status = 'COMPLETED-WITH-ERRORS'
       AND CurrentIND = 1
       AND SnapshotDate <= CAST(@CurrentTimeZoneTimeStamp-1 AS Date)
       AND BatchID IN (SELECT BatchID
                              FROM Batch
                             WHERE Status = 'Active'
                               AND SystemCode = @PSystemCode
                               AND Frequency = @PFrequency); 

    WITH TMP_LATEST_BATCH
    AS
    (SELECT BatchID,
            max(SnapshotDate) as SnapshotDate
    FROM BatchRun
    GROUP BY 
        BatchID)
    SELECT  c.RunID
        ,c.RunNumber
        ,c.StartTime
        ,c.EndTime
        ,c.SnapshotDate
        ,c.Restart
        ,c.Status as RunStatus
        ,c.CurrentIND
        ,a.[ID] as BatchID
        ,a.[SystemInfoID]
        ,b.SystemCode
        ,b.SystemName
        ,b.DatasetName
        ,b.[Status] as SystemStatus
        ,a.[ScheduledStartTime] as BatchScheduledStartTime
        ,a.[Frequency] as BatchFrequency
        ,a.[Status] as BatchStatus      
    FROM [dbo].[Batch] a
    INNER JOIN dbo.SystemInfo b
    ON a.SystemInfoID = b.ID
    AND b.[Status] = 'Active'
    INNER JOIN dbo.BatchRun c
    ON a.ID = c.BatchID
    AND c.SnapshotDate <= CAST(@CurrentTimeZoneTimeStamp-1 AS Date)
    AND c.CurrentIND = 1
    AND c.Status = 'IN-PROGRESS'
    INNER JOIN TMP_LATEST_BATCH d
    ON c.SnapshotDate = d.SnapshotDate
    AND c.BatchID = d.BatchID
    WHERE a.[Status] = 'Active'
      AND a.SystemCode = @PSystemCode
      AND a.Frequency = @PFrequency;

    RETURN

GO

