CREATE TABLE [EXTRACT_MDATA].[EDL_D365_INVENTORY_HSTK]
(
	[PK_HASH] [varbinary](8000) NULL,
	[PROD] [nvarchar](20) NULL,
	[BRCH] [nvarchar](10) NULL,
	[INVENTSTATUSID] [nvarchar](10) NULL,
	[STOH] [numeric](38, 6) NULL,
	[STEB] [varchar](1) NULL,
	[PLLR] [varchar](3) NULL,
	[REC_HASH] [varbinary](8000) NULL,
	[FileGenerationGroup] [varchar](13) NOT NULL,
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