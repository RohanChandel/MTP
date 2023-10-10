CREATE VIEW [e4i].[Reconcile_RS_SourceToTarget_V] 
AS 
WITH 
  LogRecon AS
  (
  SELECT BatchDateTime AS LatestBatchDateTime
       , Source AS SourceObject
	   , Substring(Destination, 20, 100) AS TargetObject
	   , SourceObjectRowCount
	   , SourceQueryRowCount
	   , RowsCopied AS RowsCopiedToCsvFile 
  FROM [e4i].[LogExtractDetails]
  WHERE [BatchDateTime] = --B INNER JOIN
  ( SELECT MAX(BatchDateTime) Max_BatchDateTime
    FROM [e4i].[LogExtractDetails]
	WHERE SourceType = 'SqlServer'
	AND TriggerName like 'rs%'
	AND Destination like '%RS%')
  AND CopyActivityRunId IS NOT NULL ),
  StgMdataRecon AS
  (
	 SELECT 'RS_Department' AS table_name, COUNT(*) AS row_count FROM [STG_MDATA].[RS_Department] UNION
	 SELECT 'RS_Product' AS table_name, COUNT(*) AS row_count FROM [STG_MDATA].[RS_Product] UNION
	 SELECT 'RS_ProductProm' AS table_name, COUNT(*) AS row_count FROM [STG_MDATA].[RS_ProductProm] UNION
	 SELECT 'RS_SaleProm' AS table_name, COUNT(*) AS row_count FROM [STG_MDATA].[RS_SaleProm] UNION
	 SELECT 'RS_SalesTransaction' AS table_name, COUNT(*) AS row_count FROM [STG_MDATA].[RS_SalesTransaction] UNION
	 SELECT 'RS_Site' AS table_name, COUNT(*) AS row_count FROM [STG_MDATA].[RS_Site] UNION
	 SELECT 'RS_SitePOS' AS table_name, COUNT(*) AS row_count FROM [STG_MDATA].[RS_SitePOS] UNION
	 SELECT 'RS_SitePOSAudit' AS table_name, COUNT(*) AS row_count FROM [STG_MDATA].[RS_SitePOSAudit] UNION
	 SELECT 'RS_Tender' AS table_name, COUNT(*) AS row_count FROM [STG_MDATA].[RS_Tender]  ),
   EdlMdataRecon AS
   (
   	 SELECT 'RS_Department' AS table_name, COUNT(*) AS row_count FROM [EDL_MDATA].[RS_Department] WHERE Is_Current_Flag = 1 UNION
	 SELECT 'RS_Product' AS table_name, COUNT(*) AS row_count FROM [EDL_MDATA].[RS_Product] WHERE Is_Current_Flag = 1 UNION
	 SELECT 'RS_ProductProm' AS table_name, COUNT(*) AS row_count FROM [EDL_MDATA].[RS_ProductProm] WHERE Is_Current_Flag = 1 UNION
	 SELECT 'RS_SaleProm' AS table_name, COUNT(*) AS row_count FROM [EDL_MDATA].[RS_SaleProm] WHERE Is_Current_Flag = 1 UNION
	 SELECT 'RS_SalesTransaction' AS table_name, COUNT(*) AS row_count FROM [EDL_MDATA].[RS_SalesTransaction] WHERE Is_Current_Flag = 1 UNION
	 SELECT 'RS_Site' AS table_name, COUNT(*) AS row_count FROM [EDL_MDATA].[RS_Site] WHERE Is_Current_Flag = 1 UNION
	 SELECT 'RS_SitePOS' AS table_name, COUNT(*) AS row_count FROM [EDL_MDATA].[RS_SitePOS] WHERE Is_Current_Flag = 1 UNION
	 SELECT 'RS_SitePOSAudit' AS table_name, COUNT(*) AS row_count FROM [EDL_MDATA].[RS_SitePOSAudit] WHERE Is_Current_Flag = 1 UNION
	 SELECT 'RS_Tender' AS table_name, COUNT(*) AS row_count FROM [EDL_MDATA].[RS_Tender] WHERE Is_Current_Flag = 1  
    )

	SELECT 
		 LogRecon.LatestBatchDateTime
       , LogRecon.SourceObject
	   , LogRecon.SourceObjectRowCount
	   , LogRecon.SourceQueryRowCount
	   , LogRecon.TargetObject AS TargetCsvFileName
	   , LogRecon.RowsCopiedToCsvFile
	   , StgMdataRecon.table_name AS StgTableName
	   , StgMdataRecon.row_count AS StgTableRowCount
	   , StgMdataRecon.row_count - LogRecon.RowsCopiedToCsvFile AS StgTableToCsvFileRowDiff
	   , EdlMdataRecon.table_name AS EdlMdataTableName
	   , EdlMdataRecon.row_count AS EdlMdataTableRowCount
	   , EdlMdataRecon.row_count - SourceObjectRowCount AS EdlTableToSourceObjectRowDiff
	FROM
	    EdlMdataRecon INNER JOIN LogRecon      ON EdlMdataRecon.table_name = LogRecon.TargetObject
		              INNER JOIN StgMdataRecon ON StgMdataRecon.table_name = EdlMdataRecon.table_name;
GO
