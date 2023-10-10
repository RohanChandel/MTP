CREATE VIEW [e4i].[ConfigurationEntity_V] AS (
SELECT
       [Id]
      ,[CreationTime]
      ,[IsActive]
      ,[TriggerName]
      ,[EntityName]
      ,[SourceSystem]
      ,[SourceType]
      ,[SourceColumns]
	  ,CASE 
	       WHEN IsSourceIncrementalLoad = 1 THEN 
	            CASE 
				WHEN [SourceSystem] = 'Salesforce Loyalty' THEN 
		             'SELECT ' + SourceColumns + ' FROM ' + EntityName + ' WHERE ' + SourceIncrementalDateColumn + ' >= '+ replace(concat(convert(varchar, ISNULL(m.[SourceWatermarkDateTime],'2000-01-01'), 121),'Z'), ' ', 'T')
                ELSE
					 'SELECT ' + SourceColumns + ' FROM ' + EntityName + SourceWhereCondition + ' AND ' + SourceIncrementalDateColumn + ' >= '''+  replace(concat(convert(varchar, ISNULL([SourceWatermarkDateTime],'2000-01-01'), 121),'Z'), ' ', 'T') + ''''
                END
		   ELSE		
	            CASE 
			    WHEN [SourceSystem] = 'Salesforce Loyalty' THEN 
		             'SELECT ' + SourceColumns + ' FROM ' + EntityName
			    ELSE
					 'SELECT ' + SourceColumns + ' FROM ' + EntityName + REPLACE(SourceWhereCondition, '{WatermarkToken}', ''''+ replace(concat(convert(varchar, ISNULL([SitePOSAuditWatermarkDateTime],'2000-01-01'), 121),'Z'), ' ', 'T') + '''')
			    END
           END AS [SourceSelectQuery]
		   ,abc.[SitePOSAuditWatermarkDateTime]
	   ,CASE 
	        WHEN IsSourceIncrementalLoad = 1 THEN 
	            CASE 
				WHEN [SourceSystem] = 'Salesforce Loyalty' THEN 
		             'SELECT COUNT(Id) FROM '+ EntityName + ' WHERE ' + SourceIncrementalDateColumn + ' >= '+  replace(concat(convert(varchar, ISNULL([SourceWatermarkDateTime],'2000-01-01'), 121),'Z'), ' ', 'T')
                ELSE
 				     'SELECT COUNT(*) AS CountRows FROM ' + EntityName + SourceWhereCondition + ' AND ' + SourceIncrementalDateColumn + ' >= '''+  replace(concat(convert(varchar, ISNULL([SourceWatermarkDateTime],'2000-01-01'), 121),'Z'), ' ', 'T') + ''''
                END
		    ELSE		
	            CASE 
			    WHEN [SourceSystem] = 'Salesforce Loyalty' THEN 
		             'SELECT COUNT(Id) FROM ' + EntityName
			    ELSE
 				     'SELECT COUNT(*) AS CountRows FROM ' + EntityName + REPLACE(SourceWhereCondition, '{WatermarkToken}', ''''+ replace(concat(convert(varchar, ISNULL([SitePOSAuditWatermarkDateTime],'2000-01-01'), 121),'Z'), ' ', 'T') + '''')
			    END
            END AS [SourceCountQuery]
	   ,CASE 
	         WHEN [SourceSystem] = 'Salesforce Loyalty' THEN 
				  'SELECT COUNT(Id) FROM ' + EntityName
			 ELSE
				  'SELECT COUNT(*) AS CountRows FROM ' + EntityName + REPLACE(SourceWhereCondition, '{WatermarkToken}', ''''+ '2000-01-01T00:00:22.023Z' + '''')
			 END AS [SourceFullCountQuery]
      ,[SourceKeyVaultSecret]
      ,[IsSourceIncrementalLoad]
      ,[SourceIncrementalDateColumn]
      ,ISNULL([SourceWatermarkDateTime],'2000-01-01') AS [SourceWatermarkDateTime]
      ,[RootFlag]
      ,[RootLocation]
      ,[RootManifestFilePath]
      ,[ChangefeedLocation]
      ,[ChangefeedManifestFilePath]
      ,[ChangefeedLastModifiedTime]
      ,[PrimaryKeyList]
      ,[SourceLakeDatabase]
      ,[SourceLakeSchema]
      ,[SourceLakeTable]
      ,[TargetType]
      ,[TargetKeyVaultSecret]
      ,[TargetStagingSchema]
      ,[TargetStagingTable]
      ,[TargetFileType]
      ,[TargetFileLocation]
      ,[TargetFileEncoding]
      ,[TargetFileDelimiter]
      ,[TargetFileEscapeChar]
      ,[TargetFileQuoteChar]
      ,[IsGroupLevelEotExtension]
      ,[DefaultLoadType]
      ,[StringSeparator]
      ,[Tolerance]
      ,[LogRetentionInDays]
      ,[ContainerName]
      ,[MoveToProcessing]
      ,[MoveToArchive]
      ,[SourceDirectory]
      ,[ProcessingDirectory]
      ,[ArchiveDirectory]
      ,[ValidFromDateTime]
      ,[ValidToDateTime]
      ,[IsCurrentRow]
      ,[KV_StorageAccountURL]
      ,[KV_StorageAccountSecretKey]
	  FROM [e4i].[ConfigurationEntity] m, (SELECT r.[SourceWatermarkDateTime] AS [SitePOSAuditWatermarkDateTime] FROM [e4i].[ConfigurationEntity] r WHERE r.[EntityName] = 'dbo.SitePOSAudit') abc
	  WHERE IsActive = 1
);
GO
