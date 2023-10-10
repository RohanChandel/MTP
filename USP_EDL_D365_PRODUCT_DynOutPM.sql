﻿CREATE PROC [EXTRACT_MDATA].[USP_EDL_D365_PRODUCT_DynOutPM] @FullLoad [bit],@Batch_Run_Datetime [DATETIME2],@FileGenerationGroup [varchar](10) AS 

BEGIN

	SELECT
		[ITEMNUMBER]
		, ACTION_CODE AS FLAG
		,[INVENTSITEID]
		,[COVERAGEWAREHOUSEID]
		,[METPLANNER]
		,[VENDORPRODUCTNUMBER]
		,[ITEMSTATUS]
		,[PRODUCTDESCRIPTION]
		,[SEARCHNAME]
		,[PdsBestBefore]
		,[HMIMINDICATOR]
		,[DIVISIONCODE]
		,[ISCATCHWEIGHTPRODUCT]
		,[PdsShelfLife]
		,[PRICE]
		,[MTCLegacyCode]
		,[TempDispLimit]
		,[dispatchlimit]
		,[SegregationCode]
		,[LowStorage]
		,[BARCODE]
		,[ITEMSIZE]
		,[METPURCHUNIT]
		,[FACTOR]
		,[UNITID]
		,[LAYERS]
		,[CartonPerLayer]
		,[VENDORACCOUNTNUMBER]
		,[VENDORORGANIZATIONNAME]
		,[NAME]
		,[PLANNERCODE]
		,[WEIGHT]
		,[HEIGHT]
		,[WIDTH]
		,[DEPTH]
		,[SlotLoc1Area]
		,[METSALESUNIT]
		,[EXTERNALWMSUNIT]
		,[METINVENTUNIT]
		,[AMOUNT]
		,[PALLETQTY]
		,[ONORDERQUANTITY]
		,[ORDEREDQUANTITY]
		,[TOTALAVAILABLEQUANTITY]
		,[MEASUREMENTVALUE]
		,[UNITOFMEASUREMENT]
		,[INNEROUTERDESCRIPTION] 
		,[CLASSCODE]
		,[IDENTIFICATIONCODE]
		,[MATERIALDESCRIPTION]
		,[PACKINGGROUPCODE]
		,[SUBRISKCLASS]
		,[LABELCODE]
		,[EFFECTIVEDATE]
		,[EXPIRYDATE]
		,[GRADEIDNAME]
		,[INNERQUANTITY]
		,[CASEQUANTITY]
		,[NOMINALWEIGHT]
		,[PURCHSETUPFLAG]
	FROM [EXTRACT_MDATA].[EDL_D365_PRODUCT_DynOutPM]
    WHERE Batch_Run_Datetime >= @Batch_Run_Datetime
		AND FileGenerationGroup = @FileGenerationGroup
		AND IS_CURRENT_FLAG = 1
END
GO

