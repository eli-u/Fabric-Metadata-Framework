CREATE   PROC dbo.GetSourceToTargetInfo(
    @SourceSystemCode varchar(5),
    @Stage varchar(50),
    @SourceDatasetName varchar(50)
 )
AS
  SELECT 
         [SourceToTargetID]   
        ,[SourceSystemCode]
        ,[SourceSystem]
        ,[SourceDatasetName]
        ,[SourceDataObjectName]
        ,[SourceContainer]
        ,[SourceRelativePathSchema]
        ,[SourceTechnicalName]
        ,[TargetSystemCode]
        ,[TargetSystem]
        ,[TargetDatasetName]
        ,[TargetDataObjectName]
        ,[TargetContainer]
        ,[TargetRelativePathSchema]
        ,[TargetTechnicalName]
        ,[Stage]
        ,[Status]
    FROM [dbo].[SourceToTargetView]
   WHERE SourceSystemCode = @SourceSystemCode    
    AND  Stage = @Stage
    AND  SourceDatasetName = @SourceDatasetName
    AND  Status = 'Active'
    ORDER BY SourceDatasetName;

RETURN

GO

