CREATE PROC [EXTRACT_MDATA].[USP_EDL_D365_BY_ITEMS] @reload [varchar](1) AS
BEGIN
    
	

	DECLARE @ETLDATE AS DATETIME2

	SET @ETLDATE = GETDATE();
	

	WITH CTE_T1 AS (

              select RECID,CODE,NAME,PARENTCATEGORY,level_

              ,min(source_system_valid_from_datetime) as valid_from_date,max(source_system_valid_to_datetime) as valid_to_date from edl_d365.EcoResCategory 

group by RECID,CODE,NAME, PARENTCATEGORY,level_

)

, PRE_FINAL_CTE AS (select case when L7.valid_to_date='9999-12-31T00:00:00.0000000' and L6.valid_to_date='9999-12-31T00:00:00.0000000'

              and L5.valid_to_date='9999-12-31T00:00:00.0000000' and L4.valid_to_date='9999-12-31T00:00:00.0000000'

              and L3.valid_to_date='9999-12-31T00:00:00.0000000' and L2.valid_to_date='9999-12-31T00:00:00.0000000'

              and L1.valid_to_date='9999-12-31T00:00:00.0000000' then 1 else 0 end as Product_Status_code

              ,L7.RECID as L7_RECID,L7.CODE as L7_CODE,L7.NAME as L7_NAME,L7.PARENTCATEGORY as L7_PARENTCATEGORY,L7.level_ as L7_level,L7.valid_from_date as L7_valid_from_date,L7.valid_to_date as L7_valid_to_date

              ,L6.RECID as L6_RECID,L6.CODE as L6_CODE,L6.NAME as L6_NAME,L6.PARENTCATEGORY as L6_PARENTCATEGORY,L6.level_ as L6_level,L6.valid_from_date as L6_valid_from_date,L6.valid_to_date as L6_valid_to_date

              ,L5.RECID as L5_RECID,L5.CODE as L5_CODE,L5.NAME as L5_NAME,L5.PARENTCATEGORY as L5_PARENTCATEGORY,L5.level_ as L5_level,L5.valid_from_date as L5_valid_from_date,L5.valid_to_date as L5_valid_to_date

              ,L4.RECID as L4_RECID,L4.CODE as L4_CODE,L4.NAME as L4_NAME,L4.PARENTCATEGORY as L4_PARENTCATEGORY,L4.level_ as L4_level,L4.valid_from_date as L4_valid_from_date,L4.valid_to_date as L4_valid_to_date

              ,L3.RECID as L3_RECID,L3.CODE as L3_CODE,L3.NAME as L3_NAME,L3.PARENTCATEGORY as L3_PARENTCATEGORY,L3.level_ as L3_level,L3.valid_from_date as L3_valid_from_date,L3.valid_to_date as L3_valid_to_date

              ,L2.RECID as L2_RECID,L2.CODE as L2_CODE,L2.NAME as L2_NAME,L2.PARENTCATEGORY as L2_PARENTCATEGORY,L2.level_ as L2_level,L2.valid_from_date as L2_valid_from_date,L2.valid_to_date as L2_valid_to_date

              ,L1.RECID as L1_RECID,L1.CODE as L1_CODE,L1.NAME as L1_NAME,L1.PARENTCATEGORY as L1_PARENTCATEGORY,L1.level_ as L1_level,L1.valid_from_date as L1_valid_from_date,L1.valid_to_date as L1_valid_to_date

from (select * from CTE_T1 where level_=7) L7

        JOIN (select * from CTE_T1 where level_=6) L6

        ON L7.PARENTCATEGORY=L6.RECID

                             JOIN (select * from CTE_T1 where level_=5) L5

        ON L6.PARENTCATEGORY=L5.RECID

                             JOIN (select * from CTE_T1 where level_=4) L4

        ON L5.PARENTCATEGORY=L4.RECID

                             JOIN (select * from CTE_T1 where level_=3) L3

        ON L4.PARENTCATEGORY=L3.RECID

                             JOIN (select * from CTE_T1 where level_=2) L2

        ON L3.PARENTCATEGORY=L2.RECID

                             JOIN (select * from CTE_T1 where level_=1) L1

        ON L2.PARENTCATEGORY=L1.RECID

 )

select DISTINCT

                             Product_Status_code

                             ,L7_RECID

                             ,L7_CODE

                             ,L7_NAME

                             ,L7_PARENTCATEGORY

                             ,L7_level

                             ,L7_valid_from_date

                             ,L7_valid_to_date

                             ,L6_RECID

                             ,L6_CODE

                             ,L6_NAME

                             ,L6_PARENTCATEGORY

                             ,L6_level

                             ,L6_valid_from_date

                             ,L6_valid_to_date

                             ,L5_RECID

                             ,L5_CODE

                             ,L5_NAME

                             ,L5_PARENTCATEGORY

                             ,L5_level

                             ,L5_valid_from_date

                             ,L5_valid_to_date

                             ,L4_RECID

                             ,L4_CODE

                             ,L4_NAME

                             ,L4_PARENTCATEGORY

                             ,L4_level

                             ,L4_valid_from_date

                             ,L4_valid_to_date

                             ,L3_RECID

                             ,L3_CODE

                             ,L3_NAME

                             ,L3_PARENTCATEGORY

                             ,L3_level

                             ,L3_valid_from_date

                             ,L3_valid_to_date

                             ,L2_RECID

                             ,L2_CODE

                             ,L2_NAME

                             ,L2_PARENTCATEGORY

                             ,L2_level

                             ,L2_valid_from_date

                             ,L2_valid_to_date

                             ,L1_RECID

                             ,L1_CODE

                             ,L1_NAME

                             ,L1_PARENTCATEGORY

                             ,L1_level

                             ,L1_valid_from_date

                             ,L1_valid_to_date
     INTO [EXTRACT_MDATA].[REFITEM]
              from 

                             PRE_FINAL_CTE

        ;

	

	IF (@reload = 'y')
	
		SELECT *
		INTO [EDL_D365].[EDL_D365_INVENTTABLE_REF]
		FROM [EDL_D365].[INVENTTABLE]
	
	ELSE
	
		SELECT *
		INTO [EDL_D365].[EDL_D365_INVENTTABLE_REF]
		FROM [EDL_D365].[INVENTTABLE]
		 WHERE [CREATEDDATETIME]=GETDATE()-1
		
	

	
	SELECT DISTINCT
	     INVNT.[ITEMID] AS [ITEM]
		,ECO.[NAME] AS [ITEMDESC]
		,'01' AS [PILLAR]
		,L7.[L3_CODE] AS [BIZUNIT]
		,L7.[L4_CODE] AS [Department]
		,L7.[L5_CODE] AS [Category]
		,L7.[L6_CODE] AS [Class]
		,L7.[L7_CODE] AS [Subclass]
		,L8.[SUB] AS [ITEMGROUP]
		,CASE 
			WHEN L10.[NAME] LIKE 'IMPORT%'
				THEN 'IMPORT'
			ELSE 'DOMESTIC'
			END AS [SRCMETHOD]
		,CASE 
			WHEN L9.[FilterCode1] = 'H'
				THEN 1
			WHEN L9.[FilterCode1] = 'I'
				THEN 1
			ELSE 0
			END AS [DangGoods]
		,'' AS [POLADING]
		,L7.[L2_NAME] AS [PILLARDESC]
		,L7.[L3_NAME] AS [BIZDESC]
		,L7.[L4_NAME] AS [DEPTDESC]
		,L7.[L5_NAME] AS [CATDESC]
		,L7.[L6_NAME] AS [CLASSDESC]
		,L7.[L7_NAME] AS [SUBCLASSDESC]
		,CASE 
			WHEN L10.[NAME] LIKE 'IMPORT%'
				THEN '1'
			ELSE '0'
			END AS [INDENTFLAG]
		
		,PAVL.[PdsApprovedVendor] AS [SUPPLIER]
		,MET.[ITEMSIZE] AS [SIZE]
		,L11.[TaxItemGroupId] AS [GSTCODE]
		-- ,CASE 
		-- 	WHEN L11.[TaxItemGroupId] = 'GSTFREE'
		-- 		THEN 1
		-- 	WHEN L11.[TaxItemGroupId] = 'WEG25.5'
		-- 		THEN 3
		-- 	WHEN L11.[TaxItemGroupId] = 'WEG11'
		-- 		THEN 4
		-- 	WHEN L11.[TaxItemGroupId] = 'WEG14.5'
		-- 		THEN 6
		-- 	WHEN L11.[TaxItemGroupId] = 'GST'
		-- 		THEN 7
		-- 	WHEN L11.[TaxItemGroupId] = 'WEG'
		-- 		THEN 8
		-- 	WHEN L11.[TaxItemGroupId] = 'GST9.35'
		-- 		THEN 10
		-- 	WHEN L11.[TaxItemGroupId] = 'GST9.09'
		-- 		THEN 14
		-- 	WHEN L11.[TaxItemGroupId] = 'GST9.18'
		-- 		THEN 15
		-- 	WHEN L11.[TaxItemGroupId] = 'GST1.9'
		-- 		THEN 17
		-- 	WHEN L11.[TaxItemGroupId] = 'GST8.9'
		-- 		THEN 19
		-- 	WHEN L11.[TaxItemGroupId] = 'GST9.43'
		-- 		THEN 25
		-- 	WHEN L11.[TaxItemGroupId] = 'GST0.71'
		-- 		THEN 34
		-- 	WHEN L11.[TaxItemGroupId] = 'GST8.92'
		-- 		THEN 35
		-- 	WHEN L11.[TaxItemGroupId] = 'GST8.43'
		-- 		THEN 36
		-- 	WHEN L11.[TaxItemGroupId] = 'GST8.25'
		-- 		THEN 37
		-- 	WHEN L11.[TaxItemGroupId] = 'GST3.48'
		-- 		THEN 38
		-- 	WHEN L11.[TaxItemGroupId] = 'GST3.63'
		-- 		THEN 39
		-- 	WHEN L11.[TaxItemGroupId] = 'GST0.48'
		-- 		THEN 40
		-- 	WHEN L11.[TaxItemGroupId] = 'GST8.32'
		-- 		THEN 46
		-- 	WHEN L11.[TaxItemGroupId] = 'GST7.22'
		-- 		THEN 52
		-- 	WHEN L11.[TaxItemGroupId] = 'WEG19.95'
		-- 		THEN 60
		-- 	WHEN L11.[TaxItemGroupId] = 'WEG12.18'
		-- 		THEN 67
		-- 	WHEN L11.[TaxItemGroupId] = 'WEG11.6'
		-- 		THEN 68
		-- 	WHEN L11.[TaxItemGroupId] = 'WEG8.12'
		-- 		THEN 69
		-- 	WHEN L11.[TaxItemGroupId] = 'GST14.19'
		-- 		THEN 81
		-- 	WHEN L11.[TaxItemGroupId] = 'WEG10.13'
		-- 		THEN 83
		-- 	WHEN L11.[TaxItemGroupId] = 'WEG9.79'
		-- 		THEN 84
		-- 	WHEN L11.[TaxItemGroupId] = 'WEG19.27'
		-- 		THEN 90
		-- 	WHEN L11.[TaxItemGroupId] = 'WEG14.4'
		-- 		THEN 91
		-- 	WHEN L11.[TaxItemGroupId] = 'WEG15.3'
		-- 		THEN 92
		-- 	WHEN L11.[TaxItemGroupId] = 'GST2.5'
		-- 		THEN 93
		-- 	ELSE 0
		-- 	END AS [GSTCODE]
		,CASE 
			WHEN INVNT.[PdsShelfLife] = 0
				THEN 0
			ELSE 1
			END AS [PERISHABLE]
		,CASE 
			WHEN INVNT.[Is_Delete_Flag] = 'False'
				THEN 0
			ELSE 1
			END AS [DELETE]
		,CASE 
			WHEN INVNT.[IS_DELETE_FLAG] = 'False'
				THEN 0
			WHEN INVNT.[IS_DELETE_FLAG] = 'True'
				THEN 1
			END AS IS_DELETE_FLAG
			--,INVNT.[IS_DELETE_FLAG]
		,HASHBYTES('MD5', CONCAT (
				INVNT.[ITEMID]
				,ECO.[NAME]
				,L7.[L3_CODE]
				,L7.[L4_CODE]
				,L7.[L5_CODE]
				,L7.[L6_CODE]
				,L7.[L7_CODE]
				,L8.[SUB]
				,L10.[NAME]
				,L9.[FilterCode1]
				,L7.[L2_NAME]
				,L7.[L3_NAME]
				,L7.[L4_NAME]
				,L7.[L5_NAME]
				,L7.[L6_NAME]
				,L7.[L7_NAME]
				,PAVL.[PdsApprovedVendor]
				,MET.[ITEMSIZE]
				,L11.[TaxItemGroupId]
				,INVNT.[PdsShelfLife]
				--,INVNT.[Is_Delete_Flag]
				)) AS REC_HASH

	INTO [EDL_D365].[EDL_D365_INVENTVIEW_REF]
	FROM   [EDL_D365].[EDL_D365_INVENTTABLE_REF] INVNT

	LEFT JOIN [EDL_D365].[EcoResProductTranslation] ECO
	ON        INVNT.[PRODUCT] = ECO.[RECID]

	LEFT JOIN EDL_D365.EcoResProductCategory RES_PROD_CAT   
	ON        INVNT.Product = RES_PROD_CAT.Product

	LEFT JOIN [EXTRACT_MDATA].[REFITEM] L7 
	ON        L7.[L7_RECID] = RES_PROD_CAT.Category

	LEFT JOIN (
		         SELECT DISTINCT [ITEMID]
				                ,[Is_Current_Flag]
			                    ,CASE 
                                WHEN [SUBRANGEID] IS NOT NULL THEN
                                CONCAT(SUBRANGEID,'-',SUBRANGEDESC) 
                                WHEN [SUBRANGEID] IS NULL THEN ''
                                END AS SUB

	        	FROM [EDL_D365].[MetItemSiteSettingsSetup]
				

		     )  L8 
	ON        INVNT.[ITEMID] = L8.[ITEMID]

	LEFT JOIN [EDL_D365].[DirPartyTable] L10
	ON        L10.[RECID] = INVNT.[RECID]

	LEFT JOIN [EDL_D365].[MetItemSiteSettingsSetup] L9 
	ON        INVNT.[ITEMID] = L9.[ITEMID]

	LEFT JOIN [EDL_D365].[PdsApprovedVendorList] PAVL 
	ON        INVNT.[ITEMID] = PAVL.[ITEMID] 
	AND       PAVL.[DATAAREAID] = INVNT.[DATAAREAID]

	
	LEFT JOIN [EDL_D365].[METInventTable] MET 
	ON        INVNT.[ITEMID] = MET.[ITEMID]
	AND       INVNT.[DATAAREAID] = MET.[DATAAREAID]

	
	LEFT JOIN [EDL_D365].[InventTableModule] L11 
	ON        INVNT.[ITEMID] = L11.[ITEMID]

	WHERE     L10.[Is_Current_Flag] = 1
	AND       INVNT.[Is_Current_Flag] = 1
	AND       ECO.[Is_Current_Flag] = 1
	AND       RES_PROD_CAT.[Is_Current_Flag] = 1
	AND       L9.[Is_Current_Flag] = 1
	AND       L8.[Is_Current_Flag] = 1
	AND       PAVL.[Is_Current_Flag] = 1
	AND       MET.[Is_Current_Flag] = 1
    AND       L11.[Is_Current_Flag] = 1;

	MERGE EXTRACT_MDATA.EDL_D365_BY_ITEM AS TARGET
	USING [EDL_D365].[EDL_D365_INVENTVIEW_REF] AS SOURCE
		ON TARGET.[ITEM] = SOURCE.[ITEM] AND TARGET.[REC_HASH] = SOURCE.[REC_HASH]
	WHEN MATCHED
		THEN
			UPDATE
			SET TARGET.[ITEM] = SOURCE.[ITEM]
				,TARGET.[ITEMDESC] = SOURCE.[ITEMDESC]
				,TARGET.[PILLAR] = SOURCE.[PILLAR]
				,TARGET.[BIZUNIT] = SOURCE.[BIZUNIT]
				,TARGET.[Department] = SOURCE.[Department]
				,TARGET.[Category] = SOURCE.[Category]
				,TARGET.[Class] = SOURCE.[Class]
				,TARGET.[Subclass] = SOURCE.[Subclass]
				,TARGET.[ITEMGROUP] = SOURCE.[ITEMGROUP]
				,TARGET.[SRCMETHOD] = SOURCE.[SRCMETHOD]
				,TARGET.[DangGoods] = SOURCE.[DangGoods]
				,TARGET.[POLADING] = SOURCE.[POLADING]
				,TARGET.[PILLARDESC] = SOURCE.[PILLARDESC]
				,TARGET.[BIZDESC] = SOURCE.[BIZDESC]
				,TARGET.[DEPTDESC] = SOURCE.[DEPTDESC]
				,TARGET.[CATDESC] = SOURCE.[CATDESC]
				,TARGET.[CLASSDESC] = SOURCE.[CLASSDESC]
				,TARGET.[SUBCLASSDESC] = SOURCE.[SUBCLASSDESC]
				,TARGET.[INDENTFLAG] = SOURCE.[INDENTFLAG]
				,TARGET.[SUPPLIER] = SOURCE.[SUPPLIER]
				,TARGET.[SIZE] = SOURCE.[SIZE]
				,TARGET.[GSTCODE] = SOURCE.[GSTCODE]
				,TARGET.[PERISHABLE] = SOURCE.[PERISHABLE]
				,TARGET.[DELETE] = SOURCE.[DELETE]
				,TARGET.[REC_HASH] = SOURCE.[REC_HASH]
				,TARGET.[UPDATED_DT] = @ETLDATE
	WHEN NOT MATCHED
		THEN
			INSERT (
				[ITEM]
				,[ITEMDESC]
				,[PILLAR]
				,[BIZUNIT]
				,[Department]
				,[Category]
				,[Class]
				,[Subclass]
				,[ITEMGROUP]
				,[SRCMETHOD]
				,[DangGoods]
				,[POLADING]
				,[PILLARDESC]
				,[BIZDESC]
				,[DEPTDESC]
				,[CATDESC]
				,[CLASSDESC]
				,[SUBCLASSDESC]
				,[INDENTFLAG]
				,[SUPPLIER]
				,[SIZE]
				,[GSTCODE]
				,[PERISHABLE]
				,[DELETE]
				,[REC_HASH]
				,[CREATED_DT]
				,[UPDATED_DT]
				)
			VALUES (
				[ITEM]
				,[ITEMDESC]
				,[PILLAR]
				,[BIZUNIT]
				,[Department]
				,[Category]
				,[Class]
				,[Subclass]
				,[ITEMGROUP]
				,[SRCMETHOD]
				,[DangGoods]
				,[POLADING]
				,[PILLARDESC]
				,[BIZDESC]
				,[DEPTDESC]
				,[CATDESC]
				,[CLASSDESC]
				,[SUBCLASSDESC]
				,[INDENTFLAG]
				,[SUPPLIER]
				,[SIZE]
				,[GSTCODE]
				,[PERISHABLE]
				,[DELETE]
				,[REC_HASH]
				,@ETLDATE
				,@ETLDATE
				);		

DROP TABLE [EXTRACT_MDATA].[REFITEM]



DROP TABLE [EDL_D365].[EDL_D365_INVENTVIEW_REF]

DROP TABLE [EDL_D365].[EDL_D365_INVENTTABLE_REF];

END
GO