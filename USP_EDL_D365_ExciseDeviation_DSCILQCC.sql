CREATE PROC [EXTRACT_MDATA].[usp_EDL_D365_ExciseDeviation_DSCILQCC] @FullLoad [bit],@Batch_Run_Datetime [DATETIME2],@FileGenerationGroup [varchar](10) AS

BEGIN

  SELECT
    'LQCNC' AS RECORD_ID,
    ACTION_CODE AS ACTIONCODE,
    LEFT(ISNULL(COUNTRYCODE,' ')+REPLICATE(' ',5),5) AS COUNTRYCODE,
    LEFT(ISNULL([CodeDescription],' ')+REPLICATE(' ',25),25) AS COUNTRYDESCRIPTION,
    FORMAT([DevelopingRate] * 100,'00000') AS DevelopingRate,
	'|' AS EndPipe
    FROM [EXTRACT_MDATA].[EDL_D365_ExciseDeviation_DSCILQCC]
    WHERE Batch_Run_Datetime >= @Batch_Run_Datetime
		AND FileGenerationGroup = @FileGenerationGroup
		AND IS_CURRENT_FLAG = 1
END
GO


