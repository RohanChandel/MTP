﻿CREATE PROC [EXTRACT_MDATA].[USP_EDL_D365_CUSTOMER_DynOutCM]  @FullLoad [bit],@Batch_Run_Datetime [DATETIME2],@FileGenerationGroup [varchar](10) AS

BEGIN

	SELECT
	[CUSTOMERACCOUNT] ,
	ACTION_CODE AS FLAG ,
	[ORGANIZATIONNAME],
	[PRIMARYCONTACTPHONEDESCRIPTION] ,
	[BUSINESSADDRESSSTREET],
	[BUSINESSADDRESSCITY],
	[BUSINESSADDRESSSTATE],
	[BUSINESSADDRESSZIPCODE],
	[BUSINESSADDRESSCOUNTRYREGIONID],
	[DELIVERYADDRESSSTREET],
	[DELIVERYADDRESSCITY],
	[DELIVERYADDRESSSTATE],
	[DELIVERYADDRESSZIPCODE],
	[DELIVERYADDRESSCOUNTRYREGIONID],
	[OTHERADDRESSSTREET],
	[OTHERADDRESSCITY],
	[OTHERADDRESSSTATE],
	[OTHERADDRESSZIPCODE],
	[OTHERADDRESSCOUNTRYREGIONID],
	[PRIMARYCONTACTPHONE] ,
	[SITEID] ,
--	[DELIVERYADDRESSCOUNTRYREGIONID] ,
	[METINDUSTRYKEY],
	[DEFAULTDIMENSIONDISPLAYVALUE] ,
	[METWAREHOUSEINSTRUCTION] ,
	[SPECIALINSTRUCTIONS] ,
	[ONHOLDSTATUS] ,
	[CUSTOMERGROUPID],
	[SALESTAXGROUP],
	[METCBCTCLASS],
	[INVOICEACCOUNT],
	[TECCUSTPOINTOFSALEID],
	[METVILLAGENAME],
	[CREDITRATING],
	[CTStopDate],
	[CREDMANACCOUNTSTATUSID],
	[METCLOSEDDATE],
	[STATEVALUE],
	[ALLOWBACKORDERS],
	[LEGACYNUM]
	FROM [EXTRACT_MDATA].[EDL_D365_CUSTOMER_DynOutCM]
    WHERE Batch_Run_Datetime >= @Batch_Run_Datetime
		AND FileGenerationGroup = @FileGenerationGroup
		AND IS_CURRENT_FLAG = 1
END
GO