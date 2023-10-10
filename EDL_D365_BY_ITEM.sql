CREATE TABLE [EXTRACT_MDATA].[EDL_D365_BY_ITEM]
( 
	[ITEM] [nvarchar](100)  NULL,
	[ACTIONCODE] [nvarchar](100)  NULL,
	[ITEMDESC] [nvarchar](100)  NULL,
	[PILLAR] [nvarchar](100)  NULL,
	[BIZUNIT] [nvarchar](100)  NULL,
	[Department] [nvarchar](100)  NULL,
	[Category] [nvarchar](100)  NULL,
	[Class] [nvarchar](100)  NULL,
	[Subclass] [nvarchar](100)  NULL,
	[ITEMGROUP] [nvarchar](100)  NULL,
	[SRCMETHOD] [nvarchar](100)  NULL,
	[DangGoods] [nvarchar](100)  NULL,
	[POLADING] [nvarchar](100)  NULL,
	[PILLARDESC] [nvarchar](100)  NULL,
	[BIZDESC] [nvarchar](100)  NULL,
	[DEPTDESC] [nvarchar](100)  NULL,
	[CATDESC] [nvarchar](100)  NULL,
	[CLASSDESC] [nvarchar](100)  NULL,
	[SUBCLASSDESC] [nvarchar](100)  NULL,
	[INDENTFLAG] [nvarchar](100)  NULL,
	[SUPPLIER] [nvarchar](100)  NULL,
	[SIZE] [nvarchar](100)  NULL,
	[GSTCODE] [nvarchar](100)  NULL,
	[PERISHABLE] [nvarchar](100)  NULL,
	[DELETE] [nvarchar](100)  NULL,
	[REC_HASH] [varbinary](8000)  NULL,
	[CREATED_DT] [datetime]  NULL,
	[UPDATED_DT] [datetime]  NULL
)
WITH
(
	DISTRIBUTION = HASH ( [ITEM] ),
	CLUSTERED COLUMNSTORE INDEX
)
GO