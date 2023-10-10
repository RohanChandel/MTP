CREATE TABLE [EXTRACT_MDATA].[EDL_D365_ExciseDeviation_DSCIDUTY]
(
	[PK_HASH] [varbinary](8000) NULL,
	[DISTRIBUTIONCENTRE] [numeric](2, 0) NULL,
	[PRODUCT] [nvarchar](20) NULL,
	[TARIFFCODE] [nvarchar](20) NULL,
	[BOTTLESIZE] [numeric](32, 6) NULL,
	[ORIGINCOUNTRY] [nvarchar](20) NULL,
	[STATCODE] [nvarchar](20) NULL,
	[VALUEFORDUTY] [numeric](32, 6) NULL,
	[ALCOHOLCONTENT] [numeric](32, 6) NULL,
	[DEVELOPINGRATE] [numeric](32, 6) NULL,
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

