CREATE PROC [EXTRACT_MDATA].[USP_EDL_D365_PRODUCT_APBR] @FullLoad [bit],@Batch_Run_Datetime [DATETIME2],@FileGenerationGroup [varchar](10) AS

BEGIN

WITH VENDORACCOUNT_CTE as (
	select distinct 
            t1.itemid,
            t1.dataareaid, 
            t20.inventdimid as defaultdimid
    from edl_d365.inventtable T1
	LEFT JOIN EDL_D365.REQITEMTABLE T15
		ON  T15.itemid = T1.itemid
			AND T15.DATAAREAID = T1.DATAAREAID
			AND T15.Is_Current_Flag=1 
			AND T15.is_delete_flag = 0
	INNER JOIN EDL_D365.INVENTDIM T19 
		ON T15.COVINVENTDIMID = T19.INVENTDIMID
			AND T15.dataareaid = T19.dataareaid
			and T19.is_current_flag = 1
			AND T19.is_delete_flag = 0
	INNER JOIN EDL_D365.INVENTDIM T20
		ON t19.inventsiteid = t20.inventsiteid
			and t19.dataareaid = t20.dataareaid 
			and t20.inventlocationid is null
			and t20.is_current_flag = 1
			and t20.is_delete_flag = 0    
	where T1.is_current_flag = 1
		and T1.is_delete_flag = 0
		and T1.dataareaid = 2000
)
, APBR_CTE AS (
	select  distinct
        T1.Itemid as ITEMNO
        ,T4.WAREHOUSE_CODE as BRANCH
        ,inventlocationid
        ,T6.LOWESTQTY as MINORDQTY
        ,case when IISS.METSALESUNIT like 'outer%' then substring(IISS.METSALESUNIT, 6, 4) 
            else '1' end as PACK
        ,case when IISS.METAltSalesUnit is not null then 'Y' 
            else 'N' end as BCFLAG
        ,case when IISS.METSALESUNIT like 'outer%' then 'Y'
            else 'N' end as MULTIPACK
        ,t5.childitemid as SUBNO
        ,INVTM.Price as COSTPRCEX
        ,T1.DistributionMethod as NONSTKFLG
        ,T10.WEIGHT as WEIGHT
        ,T10.HEIGHT as HEIGHT
        ,T10.WIDTH as WIDTH
        ,T10.DEPTH as DEPTH
        ,T1.CartonPerPallet as TIHI  
        from EDL_D365.MetItemSiteSettingsSetup T1
		LEFT JOIN VENDORACCOUNT_CTE VA
			ON T1.ItemID = VA.ItemID
				AND T1.DataAreaID = VA.DataAreaID
		LEFT JOIN edl_d365.InventItemSalesSetup IISS
			ON T1.ItemId = IISS.ItemId
					and VA.defaultdimid = IISS.inventdimid
					AND T1.DataAreaID = IISS.DataAreaID
					AND IISS.Is_Current_Flag = 1
					AND IISS.is_delete_flag = 0
					AND IISS.metsalesunit is not null
		LEFT JOIN EDL_D365.INVENTTABLEMODULE INVTM
			ON T1.itemid = INVTM.itemid
				AND T1.dataareaid = INVTM.dataareaid
				AND INVTM.is_current_flag = 1
				AND INVTM.is_delete_flag = 0
				AND INVTM.TaxItemGroupId is null
		LEFT JOIN EDL_D365.METWHSPhysDimUOMSite T10
			ON T1.ItemId = T10.ItemId
					AND T10.SITEID = T1.InventSiteId
					AND T10.Is_Current_Flag = 1
					AND T10.is_delete_flag = 0
        LEFT JOIN EDL_D365.InventLocation T3
			on T1.inventsiteid = T3.inventsiteid 
				and t1.dataareaid = t3.dataareaid 
				and t3.is_current_flag = 1
				and t3.is_delete_flag = 0 
        INNER JOIN [EDL_MDATA].[XDOCK_Location] T4
	       on t3.inventlocationid = t4.location_id
        LEFT JOIN [EDL_D365].[METSalesItemSubstitutionParentChild] T5
			on T1.itemid = t5.parentitemid
				and t5.is_current_flag = 1
				and t5.is_delete_flag = 0
        LEFT JOIN [EDL_D365].[InventItemPurchSetup] T6
			on T1.itemid = T6.itemid 
				and T1.dataareaid = T6.dataareaid
				and T6.is_current_flag = 1
				and T6.is_delete_flag= 0
        where   T1.PublishPortal = 1
                AND T1.dataareaid = '2000'
                AND T1.is_current_flag =1
                AND T1.is_delete_flag = 0
				AND T4.WAREHOUSE_STATE_CODE = @FileGenerationGroup
	
)

, HEADER_RECORD AS(
    select
    '00'              AS RECTYPE,
    '24'              AS DATATYPE,
    'R'               AS LOADTYPE,
    'B'               AS LOADSCOPE,    
    LEFT(RIGHT(concat('000',MIN(BRANCH)),3) + REPLICATE(' ',6),6)  AS SCOPEKEY,
    LEFT(CONCAT('PR01B7',' ',format(@Batch_Run_Datetime,'dd/MM/yyyy HH:MM'))+REPLICATE(' ',100),100)  AS RUNTIME
    from APBR_CTE	
)


,DETAIL_RECORD AS (
    SELECT 
        '24' as RECTYPE, 
        'ALM' as PILLAR, 
        @FileGenerationGroup AS State,
        LEFT(ITEMNO+REPLICATE('0',6),6)  AS ITEMNO,
        RIGHT(concat('000',BRANCH),3) as BRANCH,
        '' as ACTION,
        RIGHT(REPLICATE('0',3) + cast(MINORDQTY as varchar),3) AS MINORDQTY,
        RIGHT(concat('000',PACK),3)  AS PACK,
        BCFLAG,
        MULTIPACK,
        LEFT(coalesce(SUBNO,'')+REPLICATE('0',6),6)  AS SUBNO,
        RIGHT(REPLICATE('0',7)+cast(CAST(COSTPRCEX*100 AS int) as varchar) ,  7 ) as COSTPRCEX,
        coalesce(NONSTKFLG,' ') as NONSTKFLG,
        -- NONSTKFLG,
        RIGHT(REPLICATE('0',9)+cast(CAST(WEIGHT*100 AS int) as varchar) ,  9 )  AS WEIGHT,
        RIGHT(REPLICATE('0',7)+cast(CAST(HEIGHT*100 AS int) as varchar) ,  7 )  AS HEIGHT,
        RIGHT(REPLICATE('0',7)+cast(CAST(WIDTH*100 AS int) as varchar) ,  7 )  AS WIDTH,
        RIGHT(REPLICATE('0',7)+cast(CAST(DEPTH*100 AS int) as varchar) ,  7 )  AS DEPTH,
        RIGHT(REPLICATE('0',4) + cast(TIHI as varchar),4)  AS TIHI
        from APBR_CTE
)
,TRAILER_RECORD AS(
    SELECT
        '99' AS RECTYPE
        ,COUNT(*) AS RECORD_COUNT
    FROM APBR_CTE
)
,FINAL AS
(
    SELECT
    CONCAT(RECTYPE,'|',DATATYPE,'|',LOADTYPE,'|',LOADSCOPE,'|',SCOPEKEY,'|',RUNTIME,'|') AS DATA
    FROM HEADER_RECORD
    UNION ALL
    SELECT
    CONCAT(RECTYPE,'|',PILLAR,'|',State,'|',ITEMNO,'|',BRANCH,'|',ACTION,'|',MINORDQTY,'|',PACK,'|',BCFLAG,'|',MULTIPACK,'|',SUBNO,'|',COSTPRCEX,'|',NONSTKFLG,'|',WEIGHT,'|',HEIGHT,'|',WIDTH,'|',DEPTH,'|',TIHI,'|' ) AS DATA
    FROM DETAIL_RECORD
    UNION ALL
    SELECT
    CONCAT(RECTYPE,'|',COALESCE(RECORD_COUNT,''),'|') AS DATA
  FROM TRAILER_RECORD
)
  select * FROM FINAL order by 1 ASC;


END

GO