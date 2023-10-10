CREATE TABLE [EXTRACT_MDATA].[EDL_D365_ExciseDeviation_DSCILQSC]
(
	[PK_HASH] [varbinary](8000) NULL,
	[TARIFFITEM] [nvarchar](20) NULL,
	[STATCODE] [nvarchar](20) NULL,
	[DESCRIPTION] [nvarchar](60) NULL,
	[DATAAREAID] [nvarchar](4) NULL,
	[ADVALOREMORBEERSUBSIDYRATE] [numeric](32, 6) NULL,
	[DUTYLAL] [numeric](32, 6) NULL,
	[STRENGTHGREATERTHAN] [numeric](32, 6) NULL,
	[STRENGTHLESSOREQUAL] [numeric](32, 6) NULL,
	[FileGenerationGroup] [varchar](70) NOT NULL,
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
