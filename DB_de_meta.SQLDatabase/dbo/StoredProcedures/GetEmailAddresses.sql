
CREATE PROC dbo.GetEmailAddresses(
    @SystemCode varchar(5),
    @DatasetName varchar(50)
)
AS 
 SELECT 
       [SystemCode]
      ,[DatasetName]
      ,[SystemInfoID]
      ,[FirstName]
      ,[LastName]
      ,[EmailAddress]
  FROM [dbo].[EmailRecipients]
 WHERE SystemCode = @SystemCode
   AND DatasetName = @DatasetName

GO

