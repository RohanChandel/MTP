CREATE TABLE [EXTRACT_MDATA].[EDL_D365_PRODUCT_HPRD]
(
	[PK_HASH] [varbinary](8000) NULL,
	[JDPTN] [nvarchar](10) NULL,
	[JITMN] [nvarchar](20) NULL,
	[PUPCN] [nvarchar](80) NULL,
	[PUPBB] [nvarchar](80) NULL,
	[PUPCC] [nvarchar](80) NULL,
	[JPCKI] [nvarchar](6) NULL,
	[JBCCD] [varchar](1) NOT NULL,
	[ICWCD] [varchar](1) NOT NULL,
	[IRWCD] [varchar](1) NOT NULL,
	[JUNMS] [numeric](32, 6) NULL,
	[ISTS] [varchar](1) NULL,
	[ONWT] [numeric](32, 6) NULL,
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