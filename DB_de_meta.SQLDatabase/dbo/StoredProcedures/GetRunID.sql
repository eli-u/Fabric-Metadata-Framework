
CREATE PROC GetRunID(
    @SnapshotDate date,
    @BatchID INT,
    @RunNumber INT,
    @RunID varchar(50) OUTPUT
)
AS
DECLARE @BatchString varchar(2)
DECLARE @RunNumberString varchar(2)

IF @BatchID < 10
    SELECT @BatchString = LEFT('0'+CAST(@BatchID AS VARCHAR(2)),2);
ELSE
    SELECT @BatchString = CAST(@BatchID AS VARCHAR(2));

IF @RunNumber < 10
    SELECT @RunNumberString = LEFT('0'+CAST(@RunNumber AS VARCHAR(2)),2);
ELSE
    SELECT @RunNumberString = CAST(@RunNumber AS VARCHAR(2));

SELECT @RunID = CONCAT(REPLACE(CAST(@SnapshotDate AS varchar(11)),'-',''), @BatchString, @RunNumberString)

GO

