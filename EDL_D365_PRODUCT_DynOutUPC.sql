CREATE TABLE [EXTRACT_MDATA].[EDL_D365_PRODUCT_DynOutUPC]
(
	[PK_HASH] [varbinary](8000) NULL,
	[itemid] [nvarchar](20) NULL,
	[InventSiteId] [nvarchar](10) NULL,
	[COVERAGEWAREHOUSEID] [nvarchar](10) NULL,
	[BARCODE] [nvarchar](80) NULL,
	[productquantityunitsymbol] [nvarchar](10) NULL,
	[REC_HASH] [varbinary](8000) NULL,
	[filegenerationgroup] [nvarchar](4) NULL,
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

