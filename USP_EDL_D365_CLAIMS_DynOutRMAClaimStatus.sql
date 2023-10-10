CREATE PROC [EXTRACT_MDATA].[USP_EDL_D365_CLAIMS_DynOutRMAClaimStatus] @FullLoad [bit],@Batch_Run_Datetime [DATETIME2],@FileGenerationGroup [varchar](10) AS
BEGIN

SELECT FileGenerationGroup AS LEGALENTITY,
	   [CLAIMSTATUS],
	   [CLAIMREFERENCE],
       [REASONCODE],
       'RMA' AS CLAIMTYPE,
	   [CUSTACCOUNT] 
FROM [EXTRACT_MDATA].[EDL_D365_CLAIMS_DynOutRMAClaimStatus]
    WHERE Batch_Run_Datetime >= @Batch_Run_Datetime
		AND FileGenerationGroup = @FileGenerationGroup
		AND IS_CURRENT_FLAG = 1
END
GO


