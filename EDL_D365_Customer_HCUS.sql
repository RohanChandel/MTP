CREATE TABLE [EXTRACT_MDATA].[EDL_D365_Customer_HCUS]
(
	[PK_Hash] [varbinary](8000) NULL,
	[METINDUSTRYKEY] [nvarchar](4) NULL,
	[WAREHOUSEID] [nvarchar](10) NULL,
	[CUSTOMERACCOUNT] [nvarchar](20) NULL,
	[CREDMANACCOUNTSTATUSID] [nvarchar](1) NULL,
	[METCUSTOPERGROUPID] [nvarchar](20) NULL,
	[ORGANIZATIONNAME] [nvarchar](100) NULL,
	[BusinessAddressStreet] [nvarchar](4000) NULL,
	[BusinessAddressCity] [nvarchar](4000) NULL,
	[BusinessAddressState] [nvarchar](4000) NULL,
	[BusinessAddressZipCode] [nvarchar](4000) NULL,
	[BusinessPhoneCountryRegionCode] [nvarchar](5) NULL,
	[BusinessPhone] [nvarchar](255) NULL,
	[BusinessFaxCountryRegionCode] [nvarchar](5) NULL,
	[BusinessFax] [nvarchar](255) NULL,
	[LiquorLicenceNumberValid] [varchar](1) NOT NULL,
	[AgentOrSalesRepCode] [nvarchar](1999) NULL,
	[AgentOrSalesRepType] [varchar](1) NOT NULL,
	[TAXEXEMPTNUMBER] [nvarchar](20) NULL,
	[InvoiceEmail] [nvarchar](255) NULL,
	[METCSLEGALENTITY] [nvarchar](4) NULL,
	[StoreOwnerFirstName] [nvarchar](35) NULL,
	[StoreOwnerLastName] [nvarchar](35) NULL,
	[StoreOwnerPhoneNumber] [nvarchar](255) NULL,
	[REGISTRATIONNUMBER] [nvarchar](60) NULL,
	[InvoiceAddressStreet] [nvarchar](4000) NULL,
	[InvoiceAddressCity] [nvarchar](4000) NULL,
	[InvoiceAddressState] [nvarchar](4000) NULL,
	[InvoiceAddressZipCode] [nvarchar](4000) NULL,
	[LineOfBusinessID] [nvarchar](10) NULL,
	[LiquorLicenceNumber] [nvarchar](60) NULL,
	[TobaccoLicenseNumberValid] [varchar](1) NOT NULL,
	[TobaccoLicenceNumber] [nvarchar](60) NULL,
	[TobaccoLicenceExpiryDate] [datetime] NULL,
	[MailBrochureFlag] [int] NOT NULL,
	[BusinessEmail] [nvarchar](255) NULL,
	[REC_HASH] [varbinary](8000) NULL,
	[SITEID] [nvarchar](10) NULL,
	[FileGenerationGroup] [nvarchar](2) NOT NULL,
	[ACTION_CODE] [nvarchar](1) NULL,
	[Is_Delete_Flag] [bit] NULL,
	[Is_Current_Flag] [bit] NULL,
	[Pipeline_Run_Id] [nvarchar](4000) NULL,
	[Batch_Run_Datetime] [datetime2](7) NULL
)
WITH
(
	DISTRIBUTION = HASH ( [PK_Hash] ),
	CLUSTERED COLUMNSTORE INDEX
)
GO


