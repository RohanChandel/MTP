﻿CREATE TABLE [EXTRACT_MDATA].[EDL_D365_PRODUCT_DynOutPM]
(
	[PK_HASH] [varbinary](8000) NULL,
	[ITEMNUMBER] [nvarchar](20) NULL,
	[INVENTSITEID] [nvarchar](10) NULL,
	[COVERAGEWAREHOUSEID] [nvarchar](10) NULL,
	[METPLANNER] [nvarchar](3) NULL,
	[VENDORPRODUCTNUMBER] [nvarchar](20) NULL,
	[ITEMSTATUS] [nvarchar](20) NULL,
	[PRODUCTDESCRIPTION] [nvarchar](1000) NULL,
	[SEARCHNAME] [nvarchar](30) NULL,
	[PdsBestBefore] [int] NULL,
	[HMIMINDICATOR] [int] NULL,
	[DIVISIONCODE] [nvarchar](20) NULL,
	[ISCATCHWEIGHTPRODUCT] [int] NULL,
	[PdsShelfLife] [int] NULL,
	[PRICE] [numeric](32, 6) NULL,
	[MTCLegacyCode] [nvarchar](10) NULL,
	[TempDispLimit] [numeric](32, 6) NULL,
	[DispatchLimit] [int] NULL,
	[SegregationCode] [nvarchar](20) NULL,
	[LowStorage] [int] NULL,
	[BARCODE] [nvarchar](80) NULL,
	[ITEMSIZE] [nvarchar](10) NULL,
	[METPURCHUNIT] [nvarchar](10) NULL,
	[FACTOR] [numeric](32, 6) NULL,
	[UNITID] [nvarchar](10) NULL,
	[LAYERS] [numeric](32, 6) NULL,
	[CartonPerLayer] [numeric](32, 6) NULL,
	[VENDORACCOUNTNUMBER] [nvarchar](20) NULL,
	[VENDORORGANIZATIONNAME] [nvarchar](100) NULL,
	[NAME] [varchar](1) NOT NULL,
	[PLANNERCODE] [nvarchar](3) NULL,
	[WEIGHT] [numeric](32, 6) NULL,
	[HEIGHT] [numeric](32, 6) NULL,
	[WIDTH] [numeric](32, 6) NULL,
	[DEPTH] [numeric](32, 6) NULL,
	[SlotLoc1Area] [nvarchar](20) NULL,
	[METSALESUNIT] [nvarchar](10) NULL,
	[EXTERNALWMSUNIT] [int] NULL,
	[METINVENTUNIT] [nvarchar](10) NULL,
	[AMOUNT] [numeric](32, 6) NULL,
	[PALLETQTY] [numeric](32, 6) NULL,
	[ONORDERQUANTITY] [varchar](1) NOT NULL,
	[ORDEREDQUANTITY] [varchar](1) NOT NULL,
	[TOTALAVAILABLEQUANTITY] [varchar](1) NOT NULL,
	[MEASUREMENTVALUE] [varchar](1) NOT NULL,
	[UNITOFMEASUREMENT] [varchar](1) NOT NULL,
	[INNEROUTERDESCRIPTION] [varchar](1) NOT NULL,
	[CLASSCODE] [nvarchar](20) NULL,
	[IDENTIFICATIONCODE] [nvarchar](20) NULL,
	[MATERIALDESCRIPTION] [nvarchar](255) NULL,
	[PACKINGGROUPCODE] [nvarchar](20) NULL,
	[SUBRISKCLASS] [varchar](1) NOT NULL,
	[LABELCODE] [nvarchar](20) NULL,
	[EFFECTIVEDATE] [varchar](1) NOT NULL,
	[EXPIRYDATE] [varchar](1) NOT NULL,
	[GRADEIDNAME] [varchar](1) NOT NULL,
	[INNERQUANTITY] [varchar](1) NOT NULL,
	[CASEQUANTITY] [varchar](1) NOT NULL,
	[NOMINALWEIGHT] [numeric](32, 6) NULL,
	[PURCHSETUPFLAG] [int] NULL,
	[REC_HASH] [varbinary](8000) NULL,
	[FileGenerationGroup] [nvarchar](4) NULL,
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