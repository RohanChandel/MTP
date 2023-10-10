CREATE PROC [EXTRACT_MDATA].[USP_EDL_D365_PRODUCT_APBG]  @FullLoad [bit],@Batch_Run_Datetime [DATETIME2],@FileGenerationGroup [varchar](10) AS

BEGIN

with APBG_CTE as(
    SELECT 	distinct 
            T1.Itemid			AS ITEMNO,
            T4.WAREHOUSE_CODE	AS BRANCH,
	        T2.reference		AS MAJORID
	from EDL_D365.MetItemSiteSettingsSetup T1
	left join [EDL_D365].[METSalesOrderGuideItem] AS T2
		ON T1.itemid = T2.itemid
			AND T2.DataAreaID = T1.DataAreaID
			AND T2.is_current_flag = 1 AND T2.is_delete_flag = 0
	LEFT JOIN EDL_D365.InventLocation T3
		on T1.inventsiteid = T3.inventsiteid 
			and t1.dataareaid = t3.dataareaid 
			and t3.is_current_flag = 1 and t3.is_delete_flag = 0 
	INNER JOIN [EDL_MDATA].[XDOCK_Location] T4
		on t3.inventlocationid = t4.location_id
	WHERE T1.DataAreaID = '2000'
		AND T1.PublishPortal = 1
		AND T1.is_current_flag = 1 AND T1.is_delete_flag = 0
		AND T4.WAREHOUSE_STATE_CODE = @FileGenerationGroup
)
,HEADER_RECORD AS(
	SELECT
		'00' AS RECTYPE
		, '25' AS DATATYPE
	 	, 'R' AS LOADTYPE
		, 'B' AS LOADSCOPE
		, LEFT(RIGHT(concat('000',MIN(BRANCH)),3) + REPLICATE(' ',6),6)  AS SCOPEKEY
		, LEFT(CONCAT('PR03A1',' ',format(@Batch_Run_Datetime,'dd/MM/yyyy HH:MM'))+REPLICATE(' ',100),100)  AS RUNTIME
        FROM APBG_CTE
)

,DETAIL_RECORD AS(
	SELECT 
	 	'25' AS RECTYPE
		, 'ALM' as PILLAR
		, @FileGenerationGroup AS State
		, LEFT(ITEMNO+REPLICATE('0',6),6)  AS ITEMNO
		, RIGHT(concat('000',BRANCH),3) as BRANCH
		, MAJORID
		, ' ' AS ACTION
	FROM APBG_CTE AS T1
)

,TRAILER_RECORD AS(

	SELECT 
		'99' AS RECTYPE
		, COUNT(*) AS RECORD_COUNT
	FROM APBG_CTE

)
, FINAL AS (
    SELECT
    CONCAT(RECTYPE,'|',DATATYPE,'|',LOADTYPE,'|',LOADSCOPE,'|',SCOPEKEY,'|',RUNTIME,'|') AS DATA
    FROM HEADER_RECORD
    UNION ALL
    SELECT
    CONCAT(RECTYPE,'|',PILLAR,'|',State,'|',ITEMNO,'|',BRANCH, '|', MAJORID,'|',ACTION,'|') AS DATA
    FROM DETAIL_RECORD
    UNION ALL
    SELECT
    CONCAT(RECTYPE,'|',COALESCE(RECORD_COUNT,''),'|') AS DATA
  FROM TRAILER_RECORD
)
  select * FROM FINAL order by 1 ASC;



END
GO


