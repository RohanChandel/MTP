CREATE TABLE [EXTRACT_MDATA].[EDL_D365_CLAIMS_DynOutFTIClaimStatus]
(
	[PK_HASH] [varbinary](8000) NULL,
	[FileGenerationGroup] [nvarchar](4) NULL,
	[CLAIMSTATUS] [varchar](9) NULL,
	[CLAIMREFERENCE] [nvarchar](20) NULL,
	[REASONCODE] [nvarchar](10) NULL,
	[CUSTACCOUNT] [nvarchar](20) NULL,
	[REC_HASH] [varbinary](8000) NULL,
	[ACTION_CODE] [nvarchar](1) NULL,
	[Is_Delete_Flag] [bit] NULL,
	[Is_Current_Flag] [bit] NULL,
	[Pipeline_Run_Id] [nvarchar](4000) NULL,
	[Batch_Run_Datetime] [datetime2](7) NULL
)
WITH
(
	DISTRIBUTION = HASH ( [PK_HASH] ),
	CLUSTERED COLUMNSTORE INDEX
)
GO

