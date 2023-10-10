CREATE TABLE [EXTRACT_MDATA].[EDL_D365_ITEM_COST_UPDATES]
( 
	[ItemNumber] [nvarchar](20)  NULL,
	[WarehouseId] [nvarchar](20)  NULL,
	[ProformaCost] [numeric](32,6)  NULL,
	[ActualCost] [numeric](32,6)  NULL,
	[POListForPIM] [numeric](32,6)  NULL,
	[ActMktSpreadCalcCode] [nvarchar](20)  NULL,
	[ActMktSpreadCalcRate] [nvarchar](20)  NULL,
	[REC_HASH] [varbinary](8000)  NULL,
	[ACTIONCODE] [varchar](1)  NULL,
	[CREATED_DT] [datetime]  NULL,
	[UPDATED_DT] [datetime]  NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
)
