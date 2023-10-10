CREATE TABLE [EXTRACT_MDATA].[EDL_D365_PRICING_PRICE_MATCH]
( 
	[ITEM_ID] [nvarchar](max)  NULL,
	[FAMILY_ID] [nvarchar](max)  NULL,
	[GROUP_CODE] [nvarchar](max)  NULL,
	[START_DATE] [nvarchar](max)  NULL,
	[END_DATE] [nvarchar](max)  NULL,
	[AMOUNT] [nvarchar](max)  NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	HEAP
)