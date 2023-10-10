﻿CREATE TABLE [EXTRACT_MDATA].[EDL_D365_VENDOR_DynOutVM]
(
	[PK_HASH] [varbinary](8000) NULL,
	[VENDORACCOUNTNUMBER] [nvarchar](20) NULL,
	[ASSIGNEDSITE] [nvarchar](10) NULL,
	[ASSIGNEDWH] [nvarchar](10) NULL,
	[VENDORORGANIZATIONNAME] [nvarchar](100) NULL,
	[DEFAULTPROCUMENTWAREHOUSEID] [nvarchar](10) NULL,
	[PLANNERCODE] [nvarchar](3) NULL,
	[VENDORBUSINESSADDRESSSTREET] [nvarchar](4000) NULL,
	[VENDORBUSINESSADDRESSCITY] [nvarchar](4000) NULL,
	[VENDORBUSINESSADDRESSSTATEID] [nvarchar](4000) NULL,
	[VENDORBUSINESSADDRESSZIPCODE] [nvarchar](4000) NULL,
	[VENDORBUSINESSADDRESSCOUNTRYREGIONID] [nvarchar](10) NULL,
	[VENDORDELIVERYADDRESSSTREET] [nvarchar](4000) NULL,
	[VENDORDELIVERYADDRESSCITY] [nvarchar](4000) NULL,
	[VENDORDELIVERYADDRESSSTATEID] [nvarchar](4000) NULL,
	[VENDORDELIVERYADDRESSZIPCODE] [nvarchar](4000) NULL,
	[VENDORDELIVERYADDRESSCOUNTRYREGIONID] [nvarchar](10) NULL,
	[VENDOROTHERADDRESSSTREET] [nvarchar](4000) NULL,
	[VENDOROTHERADDRESSCITY] [nvarchar](4000) NULL,
	[VENDOROTHERADDRESSSTATEID] [nvarchar](4000) NULL,
	[VENDOROTHERADDRESSZIPCODE] [nvarchar](4000) NULL,
	[VENDOROTHERADDRESSCOUNTRYREGIONID] [nvarchar](10) NULL,
	[VENDORPRIMARYCONTACTPERSONID] [nvarchar](20) NULL,
	[VENDORPRIMARYPHONENUMBER] [nvarchar](255) NULL,
	[VENDORPRIMARYFAXNUMBER] [nvarchar](255) NULL,
	[PRIMARYCONTACTPERSONID] [nvarchar](20) NULL,
	[CONTACTPERSONNAME] [nvarchar](100) NULL,
	[CONTACTPERSONADDRESSSTREET] [nvarchar](4000) NULL,
	[CONTACTPERSONADDRESSCITY] [nvarchar](4000) NULL,
	[CONTACTPERSONADDRESSSTATEID] [nvarchar](4000) NULL,
	[CONTACTPERSONADDRESSZIPCODE] [nvarchar](4000) NULL,
	[CONTACTPERSONADDRESSCOUNTRYREGIONID] [nvarchar](10) NULL,
	[CONTACTPERSONPHONENUMBER] [nvarchar](255) NULL,
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


