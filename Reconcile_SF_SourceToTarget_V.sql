CREATE VIEW [e4i].[Reconcile_SF_SourceToTarget_V] AS WITH 
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
	WHERE SourceType = 'SalesforceServiceCloud')
  AND CopyActivityRunId IS NOT NULL ),
  StgMdataRecon AS
  (
   SELECT 'SF_Account' AS table_name, COUNT(*) AS row_count FROM [STG_MDATA].[SF_Account] UNION 
   SELECT 'SF_AccountExtra' AS table_name, COUNT(*) AS row_count FROM [STG_MDATA].[SF_AccountExtra] UNION 
   SELECT 'SF_JournalSubType' AS table_name, COUNT(*) AS row_count FROM [STG_MDATA].[SF_JournalSubType] UNION 
   SELECT 'SF_JournalType' AS table_name, COUNT(*) AS row_count FROM [STG_MDATA].[SF_JournalType] UNION 
   SELECT 'SF_LoyaltyLedger' AS table_name, COUNT(*) AS row_count FROM [STG_MDATA].[SF_LoyaltyLedger] UNION 
   SELECT 'SF_LoyaltyMemberCurrency' AS table_name, COUNT(*) AS row_count FROM [STG_MDATA].[SF_LoyaltyMemberCurrency] UNION 
   SELECT 'SF_LoyaltyMemberTier' AS table_name, COUNT(*) AS row_count FROM [STG_MDATA].[SF_LoyaltyMemberTier] UNION 
   SELECT 'SF_LoyaltyProgram' AS table_name, COUNT(*) AS row_count FROM [STG_MDATA].[SF_LoyaltyProgram] UNION 
   SELECT 'SF_LoyaltyProgramCurrency' AS table_name, COUNT(*) AS row_count FROM [STG_MDATA].[SF_LoyaltyProgramCurrency] UNION 
   SELECT 'SF_LoyaltyProgramMember' AS table_name, COUNT(*) AS row_count FROM [STG_MDATA].[SF_LoyaltyProgramMember] UNION 
   SELECT 'SF_LoyaltyTier' AS table_name, COUNT(*) AS row_count FROM [STG_MDATA].[SF_LoyaltyTier] UNION 
   SELECT 'SF_LoyaltyTierGroup' AS table_name, COUNT(*) AS row_count FROM [STG_MDATA].[SF_LoyaltyTierGroup] UNION 
   SELECT 'SF_Order' AS table_name, COUNT(*) AS row_count FROM [STG_MDATA].[SF_Order] UNION 
   SELECT 'SF_OrderItem' AS table_name, COUNT(*) AS row_count FROM [STG_MDATA].[SF_OrderItem] UNION 
   SELECT 'SF_PartnerNetworkConnection' AS table_name, COUNT(*) AS row_count FROM [STG_MDATA].[SF_PartnerNetworkConnection] UNION 
   SELECT 'SF_Pricebook2' AS table_name, COUNT(*) AS row_count FROM [STG_MDATA].[SF_Pricebook2] UNION 
   SELECT 'SF_PricebookEntry' AS table_name, COUNT(*) AS row_count FROM [STG_MDATA].[SF_PricebookEntry] UNION 
   SELECT 'SF_Product2' AS table_name, COUNT(*) AS row_count FROM [STG_MDATA].[SF_Product2] UNION 
   SELECT 'SF_ProductCatalog' AS table_name, COUNT(*) AS row_count FROM [STG_MDATA].[SF_ProductCatalog] UNION 
   SELECT 'SF_ProductCategory' AS table_name, COUNT(*) AS row_count FROM [STG_MDATA].[SF_ProductCategory] UNION 
   SELECT 'SF_ProductCategoryProduct' AS table_name, COUNT(*) AS row_count FROM [STG_MDATA].[SF_ProductCategoryProduct] UNION 
   SELECT 'SF_Promotion' AS table_name, COUNT(*) AS row_count FROM [STG_MDATA].[SF_Promotion] UNION 
   SELECT 'SF_RecordType' AS table_name, COUNT(*) AS row_count FROM [STG_MDATA].[SF_RecordType] UNION 
   SELECT 'SF_TransactionJournal' AS table_name, COUNT(*) AS row_count FROM [STG_MDATA].[SF_TransactionJournal] UNION 
   SELECT 'SF_Voucher' AS table_name, COUNT(*) AS row_count FROM [STG_MDATA].[SF_Voucher] UNION 
   SELECT 'SF_VoucherDefinition' AS table_name, COUNT(*) AS row_count FROM [STG_MDATA].[SF_VoucherDefinition] ),
   EdlMdataRecon AS
   (
    SELECT 'SF_Account' AS table_name, COUNT(*) AS row_count FROM [EDL_MDATA].[SF_Account] WHERE Is_Current_Flag = 1 UNION 
    SELECT 'SF_AccountExtra' AS table_name, COUNT(*) AS row_count FROM [EDL_MDATA].[SF_AccountExtra] WHERE Is_Current_Flag = 1 UNION 
    SELECT 'SF_JournalSubType' AS table_name, COUNT(*) AS row_count FROM [EDL_MDATA].[SF_JournalSubType] WHERE Is_Current_Flag = 1 UNION 
    SELECT 'SF_JournalType' AS table_name, COUNT(*) AS row_count FROM [EDL_MDATA].[SF_JournalType] WHERE Is_Current_Flag = 1 UNION 
    SELECT 'SF_LoyaltyLedger' AS table_name, COUNT(*) AS row_count FROM [EDL_MDATA].[SF_LoyaltyLedger] WHERE Is_Current_Flag = 1 UNION 
    SELECT 'SF_LoyaltyMemberCurrency' AS table_name, COUNT(*) AS row_count FROM [EDL_MDATA].[SF_LoyaltyMemberCurrency] WHERE Is_Current_Flag = 1 UNION 
    SELECT 'SF_LoyaltyMemberTier' AS table_name, COUNT(*) AS row_count FROM [EDL_MDATA].[SF_LoyaltyMemberTier] WHERE Is_Current_Flag = 1 UNION 
    SELECT 'SF_LoyaltyProgram' AS table_name, COUNT(*) AS row_count FROM [EDL_MDATA].[SF_LoyaltyProgram] WHERE Is_Current_Flag = 1 UNION 
    SELECT 'SF_LoyaltyProgramCurrency' AS table_name, COUNT(*) AS row_count FROM [EDL_MDATA].[SF_LoyaltyProgramCurrency] WHERE Is_Current_Flag = 1 UNION 
    SELECT 'SF_LoyaltyProgramMember' AS table_name, COUNT(*) AS row_count FROM [EDL_MDATA].[SF_LoyaltyProgramMember] WHERE Is_Current_Flag = 1 UNION 
    SELECT 'SF_LoyaltyTier' AS table_name, COUNT(*) AS row_count FROM [EDL_MDATA].[SF_LoyaltyTier] WHERE Is_Current_Flag = 1 UNION 
    SELECT 'SF_LoyaltyTierGroup' AS table_name, COUNT(*) AS row_count FROM [EDL_MDATA].[SF_LoyaltyTierGroup] WHERE Is_Current_Flag = 1 UNION 
    SELECT 'SF_Order' AS table_name, COUNT(*) AS row_count FROM [EDL_MDATA].[SF_Order] WHERE Is_Current_Flag = 1 UNION 
    SELECT 'SF_OrderItem' AS table_name, COUNT(*) AS row_count FROM [EDL_MDATA].[SF_OrderItem] WHERE Is_Current_Flag = 1 UNION 
    SELECT 'SF_PartnerNetworkConnection' AS table_name, COUNT(*) AS row_count FROM [EDL_MDATA].[SF_PartnerNetworkConnection] WHERE Is_Current_Flag = 1 UNION 
    SELECT 'SF_Pricebook2' AS table_name, COUNT(*) AS row_count FROM [EDL_MDATA].[SF_Pricebook2] WHERE Is_Current_Flag = 1 UNION 
    SELECT 'SF_PricebookEntry' AS table_name, COUNT(*) AS row_count FROM [EDL_MDATA].[SF_PricebookEntry] WHERE Is_Current_Flag = 1 UNION 
    SELECT 'SF_Product2' AS table_name, COUNT(*) AS row_count FROM [EDL_MDATA].[SF_Product2] WHERE Is_Current_Flag = 1 UNION 
    SELECT 'SF_ProductCatalog' AS table_name, COUNT(*) AS row_count FROM [EDL_MDATA].[SF_ProductCatalog] WHERE Is_Current_Flag = 1 UNION 
    SELECT 'SF_ProductCategory' AS table_name, COUNT(*) AS row_count FROM [EDL_MDATA].[SF_ProductCategory] WHERE Is_Current_Flag = 1 UNION 
    SELECT 'SF_ProductCategoryProduct' AS table_name, COUNT(*) AS row_count FROM [EDL_MDATA].[SF_ProductCategoryProduct] WHERE Is_Current_Flag = 1 UNION 
    SELECT 'SF_Promotion' AS table_name, COUNT(*) AS row_count FROM [EDL_MDATA].[SF_Promotion] WHERE Is_Current_Flag = 1 UNION 
    SELECT 'SF_RecordType' AS table_name, COUNT(*) AS row_count FROM [EDL_MDATA].[SF_RecordType] WHERE Is_Current_Flag = 1 UNION 
    SELECT 'SF_TransactionJournal' AS table_name, COUNT(*) AS row_count FROM [EDL_MDATA].[SF_TransactionJournal] WHERE Is_Current_Flag = 1 UNION 
    SELECT 'SF_Voucher' AS table_name, COUNT(*) AS row_count FROM [EDL_MDATA].[SF_Voucher] WHERE Is_Current_Flag = 1 UNION 
    SELECT 'SF_VoucherDefinition' AS table_name, COUNT(*) AS row_count FROM [EDL_MDATA].[SF_VoucherDefinition] WHERE Is_Current_Flag = 1 
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

