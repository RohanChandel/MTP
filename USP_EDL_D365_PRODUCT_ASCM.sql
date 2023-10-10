CREATE PROC [EXTRACT_MDATA].[USP_EDL_D365_PRODUCT_ASCM] @FullLoad [bit],@Batch_Run_Datetime [DATETIME2],@FileGenerationGroup [varchar](10) AS

BEGIN
  with HEADER_RECORD AS (
        select
        '00'              AS RECTYPE,
        '09'              AS DATATYPE,
        'R'               AS LOADTYPE,
        'S'               AS LOADSCOPE,
        @FileGenerationGroup AS SCOPEKEY,
        LEFT(CONCAT('PR01A4',' ',format(@Batch_Run_Datetime,'dd/MM/yyyy HH:MM'))+REPLICATE(' ',100),100)  AS RUNTIME
  )

  , DETAIL_RECORD AS (
		SELECT DISTINCT
		  '09'                                                            AS RECTYPE,
		  'ALM'                                                           AS PILLAR,
		  T5.ItemType                                                     AS ITEMTYPE,
		  SUBSTRING(T2.CODE,1,3)                                          AS SUBCOMM, -- Pick only 1st 3 chars
		  @FileGenerationGroup                                            AS STATE,
		  ' '                                                             AS ACTION,
		  LEFT(ISNULL(TRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(T2.NAME, '9', ''), '8', ''), '7', ''),'6', ''),'5',''),'4',''),'3', ''),'2',''),'1',''),'0','')),' ') +REPLICATE(' ',40),40) 
			AS SCOMMDESC
		FROM EDL_D365.ECORESPRODUCTCATEGORY AS T1
		INNER JOIN EDL_D365.ECORESCATEGORY AS T2
			  on T1.CATEGORY = T2.RECID
		INNER JOIN EDL_D365.ECORESPRODUCT AS T3 --need to join T2 & T3 on category name
			  on T1.PRODUCT = T3.RECID
		INNER JOIN EDL_D365.ECORESCATEGORYHIERARCHY AS T4
			  on T1.CATEGORYHIERARCHY = T4.RECID
		INNER JOIN EDL_D365.MetItemSiteSettingsSetup AS T5
		  ON T5.ItemId = T3.DISPLAYPRODUCTNUMBER
		where T4.HIERARCHYMODIFIER = 1
		  AND T5.DATAAREAID='2000'
		  AND T5.PublishPortal =1
		  AND T1.Is_Current_Flag=1 AND T1.Is_Delete_Flag = 0
		  AND T2.Is_Current_Flag=1 AND T1.Is_Delete_Flag = 0
		  AND T3.Is_Current_Flag=1 AND T1.Is_Delete_Flag = 0
		  AND T4.Is_Current_Flag=1 AND T1.Is_Delete_Flag = 0
		  AND T4.Is_Current_Flag=1 AND T1.Is_Delete_Flag = 0
	  )
	,TRAILER_RECORD AS (
		  SELECT
		  '99'                                                    AS RECTYPE,
		  FORMAT(count(*),'0000000')                              AS COUNTS
		  FROM DETAIL_RECORD
	)

	,FINAL AS (
		SELECT
		CONCAT(RECTYPE,'|',DATATYPE,'|',LOADTYPE,'|',LOADSCOPE,'|',SCOPEKEY,'|',RUNTIME,'|') AS DATA
		FROM HEADER_RECORD
			UNION ALL
		SELECT
		CONCAT(RECTYPE,'|',PILLAR,'|',ITEMTYPE,'|',SUBCOMM,'|',STATE,'|',ACTION,'|',SCOMMDESC,'|') AS DATA
		FROM DETAIL_RECORD
			UNION ALL
		SELECT
		CONCAT(RECTYPE,'|',COALESCE(COUNTS,''),'|') AS DATA
		FROM TRAILER_RECORD
	)
	select * FROM FINAL ORDER BY 1 ASC;


END
GO