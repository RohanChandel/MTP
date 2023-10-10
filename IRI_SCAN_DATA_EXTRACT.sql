CREATE TABLE [EXTRACT_MDATA].[IRI_SCAN_DATA_EXTRACT]
( 
	[Wk_End_Dt] [varchar](8000)  NULL,
	[Address_Id] [bigint]  NULL,
	[Recent_Store_Nm] [varchar](104)  NULL,
	[Administration_State_Cd] [varchar](8)  NULL,
	[Store_Channel_Cd] [varchar](16)  NULL,
	[Plu_Cd] [varchar](14)  NULL,
	[Product_Cd] [varchar](60)  NULL,
	[Product_Desc] [varchar](80)  NULL,
	[Product_Type] [varchar](1)  NOT NULL,
	[Msc_Dept_Cd] [varchar](8)  NULL,
	[Msc_Dept_Nm] [varchar](40)  NULL,
	[Msc_Category_Cd] [varchar](8)  NULL,
	[Msc_Category_Nm] [varchar](40)  NULL,
	[Msc_Commodity_Cd] [varchar](8)  NULL,
	[Msc_Commodity_Nm] [varchar](40)  NULL,
	[MSC_SUB_COMMODITY_CD] [varchar](8)  NULL,
	[MSC_SUB_COMMODITY_NM] [varchar](60)  NULL,
	[Sales_Excl_Gst_Xmt] [float]  NULL,
	[Sales_Incl_Gst_Xmt] [float]  NULL,
	[Sales_Qty] [float]  NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
)
GO