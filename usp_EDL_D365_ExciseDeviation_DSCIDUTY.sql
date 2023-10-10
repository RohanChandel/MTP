﻿CREATE PROC [EXTRACT_MDATA].[usp_EDL_D365_ExciseDeviation_DSCIDUTY] @FullLoad [bit],@Batch_Run_Datetime [DATETIME2],@FileGenerationGroup [varchar](10) AS

BEGIN

	SELECT 'PDUTY'  RECORD_ID,
		   ACTION_CODE AS [ACTIONCODE],
		   [DISTRIBUTIONCENTRE],
		   RIGHT(CONCAT(REPLICATE('0', 18), PRODUCT), 18) as PRODUCT,
		   left(CONCAT( TARIFFCODE,REPLICATE(' ', 13)), 13) as TARIFFCODE,
		   right(CONCAT(REPLICATE('0', 7), CAST(BOTTLESIZE * 1000 AS INT)), 7) as BOTTLESIZE,
		   LEFT(CONCAT(ORIGINCOUNTRY, REPLICATE(' ', 5)), 5) as ORIGINCOUNTRY,
		   RIGHT(CONCAT(REPLICATE('0', 4), STATCODE), 4) as STATCODE,
		   RIGHT(CONCAT(REPLICATE('0', 7), CAST(VALUEFORDUTY * 100 AS INT)), 7) as VALUEFORDUTY,
		   RIGHT(CONCAT(REPLICATE('0', 5), CAST(ALCOHOLCONTENT * 100 AS INT)), 5) as ALCOHOLCONTENT,
		   RIGHT(CONCAT(REPLICATE('0', 5), CAST(DEVELOPINGRATE * 100 AS INT)), 5) as DEVELOPINGRATE,
			'???' AS PERCENTAGEP2,
			'?????????????' AS TARIFFCODEP2,
			'?????' AS ORIGINCOUNTRYP2,
			'????' AS STATISCALCODEP2,
			'???????' AS VALUEFORDUTYP2,
			'?????' AS ALCOHALCONTENTP2,
			'?????' AS DEVELOPCOUNTRYRATEP2,
			'^M'  AS ENDOFRECORD
	FROM [EXTRACT_MDATA].[EDL_D365_ExciseDeviation_DSCIDUTY]
    WHERE Batch_Run_Datetime >= @Batch_Run_Datetime
		AND FileGenerationGroup = @FileGenerationGroup
		AND IS_CURRENT_FLAG = 1
END
GO

