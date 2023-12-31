﻿CREATE PROC [EXTRACT_MDATA].[USP_EDL_D365_PRODUCT_DynOutUPC] @FullLoad [bit],@Batch_Run_Datetime [DATETIME2],@FileGenerationGroup [varchar](10) AS
BEGIN


	SELECT
	[ITEMID],
	ACTION_CODE AS FLAG,
	[INVENTSITEID],
	[COVERAGEWAREHOUSEID],
	[BARCODE],
	[PRODUCTQUANTITYUNITSYMBOL]
	FROM [EXTRACT_MDATA].[EDL_D365_PRODUCT_DynOutUPC]
    WHERE Batch_Run_Datetime >= @Batch_Run_Datetime
		AND FileGenerationGroup = @FileGenerationGroup
		AND IS_CURRENT_FLAG = 1
END
GO


