CREATE TABLE [EXTRACT_MDATA].[EDL_D365_ExciseDeviation_DSCILQCC]
(
	[PK_HASH] [varbinary](8000) NULL,
	[CountryCode] [nvarchar](20) NULL,
	[CodeDescription] [nvarchar](60) NULL,
	[DevelopingRate] [numeric](32, 6) NULL,
	[REC_HASH] [varbinary](8000) NULL,
	[FileGenerationGroup] [varchar](70) NOT NULL,
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


