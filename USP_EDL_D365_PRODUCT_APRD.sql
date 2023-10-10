CREATE PROC [EXTRACT_MDATA].[USP_EDL_D365_PRODUCT_APRD] @FullLoad [bit],@Batch_Run_Datetime [DATETIME2],@FileGenerationGroup [varchar](10) AS

BEGIN

with HEADER_RECORD AS(
    select
    '00'						AS RECTYPE,
    '02'						AS DATATYPE,
    'R'							AS LOADTYPE,
    'S'							AS LOADSCOPE,
    @FileGenerationGroup        AS SCOPEKEY,

    LEFT(CONCAT('PR01B5',' ',format(@Batch_Run_Datetime,'dd/MM/yyyy HH:MM'))+REPLICATE(' ',100),100)  AS RUNTIME
)
, EcoResReleasedProductV2Entity_CTE AS (
    SELECT 
        distinct
        T1.ITEMID AS ITEMNUMBER,
        substring(t11.vendid,2,1) as PRIMARYVENDORACCOUNTNUMBER_STATE,
        right(t11.vendid,5) as PRIMARYVENDORACCOUNTNUMBER,
        T1.DATAAREAID,
        T8.UNITID AS INVENTORYUNITSYMBOL,
        T9.TAXITEMGROUPID AS SALESSALESTAXITEMGROUPCODE,
        case when T9.TAXITEMGROUPID = 'WEG' then 'GST' else '' end as WEGGSTCODE,
        T10.METPurchUnit AS PURCHASEUNITSYMBOL,
        t1.Product as Product
        -- T7.DESCRIPTION AS PRODUCTDESCRIPTION
    FROM   EDL_D365.INVENTTABLE AS T1 
        INNER JOIN EDL_D365.EcoResProduct T2
                ON T1.itemid = T2.displayproductnumber
                AND T2.Is_Current_Flag = 1
                AND T1.Is_Current_Flag = 1
                AND T2.is_delete_flag = 0
                and t1.is_delete_flag = 0
    LEFT JOIN EDL_D365.INVENTTABLEMODULE AS T8
        ON T1.ITEMID = T8.ITEMID
                AND T1.DATAAREAID = T8.DATAAREAID
                AND T8.MODULETYPE = 0
                AND T8.Is_Current_Flag = 1
                AND T8.Is_Delete_Flag = 0
    LEFT JOIN EDL_D365.INVENTTABLEMODULE AS T9
        ON T1.ITEMID = T9.ITEMID
                AND T1.DATAAREAID = T9.DATAAREAID
                AND T9.MODULETYPE = 2
                AND T9.Is_Current_Flag = 1
                AND T9.Is_DELETE_Flag = 0
    LEFT OUTER JOIN EDL_D365.InventItemPurchSetup AS T10
        ON T1.ITEMID = T10.ITEMID
                AND T1.DATAAREAID = T10.DATAAREAID
                and METPurchUnit is not null
                AND T10.Is_Current_Flag = 1
                AND T10.Is_DELETE_Flag = 0
    left join edl_d365.reqitemtable t11
    on t1.itemid = t11.itemid
    and t1.dataareaid = t11.dataareaid 
    and t11.is_current_flag = 1
    and t11.is_delete_flag = 0
    WHERE  T1.Is_Current_Flag = 1
        and t1.is_delete_flag = 0
        AND T1.DataAreaID = 2000
		AND substring(t11.vendid,2,1) = @FileGenerationGroup
)
,ECORESPRODUCTCATEGORYASSIGNMENTENTITY_CTE AS (
    select 
            b.ITEMID as PRODUCTNUMBER,
            b.DATAAREAID,
            d.NAME as CATEGORY,
            e.NAME as HIERARCHYCATEGORY,
            d.code ,
            f.DESCRIPTION AS PRODUCTDESCRIPTION,
            f.name as PRODUCTDESC
            from edl_d365.ECORESPRODUCTCATEGORY a 
    LEFT JOIN edl_d365.InventTable b
		on b.Product = a.PRODUCT
			and b.is_current_flag = 1
			and b.is_delete_flag = 0
    LEFT JOIN edl_d365.EcoResProduct c
		on c.RECID = a.PRODUCT
			and c.is_current_flag = 1
			and c.is_delete_flag = 0
    LEFT JOIN edl_d365.ECORESCATEGORY d
		on d.RECID = a.CATEGORY
			and d.is_current_flag = 1
			and d.is_delete_flag = 0
    LEFT JOIN edl_d365.ECORESCATEGORYHIERARCHY e
		on e.RECID = a.CATEGORYHIERARCHY
			and e.is_current_flag = 1
			and e.is_delete_flag = 0
    LEFT JOIN EDL_D365.ECORESPRODUCTTRANSLATION f 
        ON b.product  =  f.product
            AND f.Is_Current_Flag = 1 
            AND f.Is_Delete_flag = 0
    where a.is_current_flag = 1
		and a.is_delete_flag = 0
		and b.dataareaid = 2000
)
,ECORESPRODUCTATTRIBUTEVALUEV3ENTITY_CTE AS (   
   SELECT DISTINCT
        T2.NAME                   AS ATTRIBUTENAME
        , T4.TEXTVALUE            AS TEXTVALUE
        ,T3.product
    FROM EDL_D365.ECORESATTRIBUTEVALUE AS T1
    INNER JOIN EDL_D365.ECORESATTRIBUTE AS T2
        ON T1.ATTRIBUTE = T2.RECID
            AND T2.Is_Current_Flag = 1
            and T2.Is_Delete_flag = 0
            and t1.is_current_flag = 1
            and t1.is_delete_flag = 0
    INNER JOIN EDL_D365.ECORESINSTANCEVALUE AS T3
        ON T1.INSTANCEVALUE = T3.RECID
                AND T3.Is_Current_Flag = 1
                AND T3.Is_Delete_Flag = 0
    LEFT OUTER JOIN EDL_D365.ECORESTextVALUE AS T4
        ON T1.VALUE = T4.RECID
            AND T4.Is_Current_Flag = 1
            and T4.Is_Delete_Flag = 0
    WHERE T3.INSTANCERELATIONTYPE IN (4510)
        AND T1.Is_Current_Flag = 1
        AND T1.Is_Delete_Flag = 0
        -- add additional clause to reduce size
        AND T2.NAME IN ('Levy Type', 'Item Brand')
)
, ECORESPRODUCTRETAILCATEGORYHIERARCHY_CTE AS (
    select c.PRODUCT AS PRODUCT
    , a.PARTITION
    , a.RECID as RETAILCATEGORYHIERARCHY
    from EDL_D365.ECORESCATEGORYHIERARCHY a             -- Category master table irrespective of whether a product is assigned to the same or not 
    LEFT JOIN EDL_D365.ECORESCATEGORYHIERARCHYROLE b    -- Category Hierarchy Role master table
        on  a.RECID = b.CATEGORYHIERARCHY
            AND b.Is_Current_Flag = 1
            and b.Is_Delete_Flag = 0
    LEFT JOIN  EDL_D365.EcoResProductCategory c               -- Category Master Table and Role master table that's assocaited with a product
        ON c.CATEGORYHIERARCHY = a.RECID
            AND c.Is_Current_Flag = 1
            AND c.Is_Delete_Flag = 0
    WHERE product is NOT null
    and a.Is_Current_Flag = 1
    and a.Is_Delete_Flag = 0
)
,DETAIL_RECORD AS (
       SELECT distinct
        '02' AS RecType,
        'ALM' AS Pillar,
        RIGHT(REPLICATE('0',6) + T1.ITEMNUMBER,6) AS ItemNo,
        @FileGenerationGroup AS State, --loc.WAREHOUSE_STATE_code AS State,
        ' ' AS Action,
        T2.ItemType,
        -- T3.Code AS SubComm, 
        LEFT(T2.MTCLegacyCode,3) AS SubComm,
        LEFT(T3.PRODUCTDESC+REPLICATE(' ',30),30) AS ItemDesc,
        FORMAT(ISNULL(T4.TAXVALUE*100,0),'00000') AS WetRate,
        ISNULL(T1.PRIMARYVENDORACCOUNTNUMBER, '00000') AS SuppID,
        ISNULL(trim(substring(T5.Textvalue,1,charindex('-', T5.Textvalue) - 1)), '00')  AS LevyType,
        RIGHT(REPLICATE('0',14)+ISNULL(T6.ItemBarCode,'0'),14) AS APN1,
        RIGHT(REPLICATE('0',14)+ISNULL(T6.ItemBarCode,'0'),14) AS APN2,
        RIGHT(REPLICATE('0',14)+ISNULL(T6.ItemBarCode,'0'),14) AS APN3,
        RIGHT(REPLICATE('0',14)+ISNULL(T7.ItemBarCode,'0'),14) AS TUN1,
        RIGHT(REPLICATE('0',14)+ISNULL(T7.ItemBarCode,'0'),14) AS TUN2,
        RIGHT(REPLICATE('0',14)+ISNULL(T7.ItemBarCode,'0'),14) AS TUN3,
        LEFT(ISNULL(T3.CODE,'')+REPLICATE(' ',7),7) AS MSC,
        LEFT(ISNULL(trim(substring(trim(substring(T3.PRODUCTDESCRIPTION,1,len(T3.PRODUCTDESCRIPTION)-len(T11.itemsize))),len(trim(substring(T9.Textvalue,charindex('-', T9.Textvalue) + 1,15)))+1,30)),'')+REPLICATE(' ',60),60) AS CONSUMER,
        LEFT(ISNULL(trim(substring(T9.Textvalue,charindex('-', T9.Textvalue) + 1,15)),'')+REPLICATE(' ',15),15) AS BRANDDESC,
        FORMAT(ISNULL(T10.TAXVALUE * 100,0),'00000') AS GSTRate
    FROM EcoResReleasedProductV2Entity_CTE T1
    INNER JOIN EDL_D365.MetItemSiteSettingsSetup T2  
        ON T1.ITEMNUMBER = T2.ITEMID 
            AND T1.DataAreaID = T2.DataAreaID 
            AND T2.Is_Current_Flag = 1
            and t2.is_delete_flag = 0
    inner join [EDL_MDATA].[XDOCK_Location] loc 
        on t2.inventsiteid = loc.SITEID
        and t1.PRIMARYVENDORACCOUNTNUMBER_STATE = loc.WAREHOUSE_STATE_code
        and loc.WAREHOUSE_STATE is not null
    LEFT  JOIN ECORESPRODUCTCATEGORYASSIGNMENTENTITY_CTE T3 
        ON T1.ItemNumber = T3.ProductNumber
    LEFT  JOIN EDL_D365.TAXTABLE TAXBLE1
        ON T1.SALESSALESTAXITEMGROUPCODE = TAXBLE1.TAXCODE
            AND T1.DataAreaID = TAXBLE1.DataAreaID
            AND TAXBLE1.TaxCode like 'WE%'
            AND TAXBLE1.Is_Current_Flag = 1
            AND TAXBLE1.is_delete_flag = 0
    LEFT JOIN EDL_D365.TAXDATA T4
        ON Isnull(TAXBLE1.TAXONTAX, TAXBLE1.TAXCODE) = T4.TAXCODE 
            AND T1.DataAreaID = T4.DataAreaID
            AND T4.Is_Current_Flag = 1
            AND T4.is_delete_flag = 0
    LEFT JOIN ECORESPRODUCTATTRIBUTEVALUEV3ENTITY_CTE T5 
        ON T1.product = T5.product 
        AND T5.ATTRIBUTENAME = 'Levy Type' 
    LEFT JOIN EDL_D365.InventItemBarcode T6
        ON T1.ItemNumber = T6.ItemID
            AND T1.DataAreaID = T6.DataAreaID
            AND T1.InventoryUnitSymbol = T6.UnitID
            AND T6.Is_Current_Flag = 1
            AND T6.Is_Delete_Flag = 0
    LEFT JOIN EDL_D365.InventItemBarcode T7 
        ON T1.ItemNumber = T7.ItemID
            AND T1.DataAreaID = T6.DataAreaID
            AND T1.PURCHASEUNITSYMBOL = T7.UnitID
            AND T7.Is_Current_Flag = 1
            AND T7.Is_Delete_Flag = 0
    LEFT JOIN ECORESPRODUCTATTRIBUTEVALUEV3ENTITY_CTE T9    
        ON T1.product = T9.product 
            AND T9.ATTRIBUTENAME = 'Item Brand' 
    LEFT  JOIN EDL_D365.TAXTABLE TAXBLE2
        ON (T1.SALESSALESTAXITEMGROUPCODE = TAXBLE2.TAXCODE
            or T1.WEGGSTCODE = TAXBLE2.TAXCODE)
            AND T1.DataAreaID = TAXBLE2.DataAreaID
            AND TAXBLE2.TaxCode like 'GST%'
            AND TAXBLE2.Is_Current_Flag = 1
            AND TAXBLE2.is_delete_flag = 0
    LEFT JOIN EDL_D365.TAXDATA T10                     
        ON Isnull(TAXBLE2.TAXONTAX, TAXBLE2.TAXCODE) = T10.TAXCODE
            AND T1.DataAreaID = T10.DataAreaID
            AND T10.Is_Current_Flag = 1
            and t10.is_delete_flag = 0
    LEFT JOIN EDL_D365.METInventTable T11
        on T1.Itemnumber = t11.itemid
        and t11.dataareaid = 2000
        and t11.is_current_flag= 1
        and t11.is_delete_flag = 0
    WHERE T2.ItemStatus IN ('A', 'N', 'D', 'P', 'Active', 'New')
)
,TRAILER_RECORD AS(
    SELECT
        '99' AS RECTYPE
        ,COUNT(*) AS RECORD_COUNT
    FROM DETAIL_RECORD
)
,FINAL AS
(
    SELECT
    CONCAT(RECTYPE,'|',DATATYPE,'|',LOADTYPE,'|',LOADSCOPE,'|',SCOPEKEY,'|',RUNTIME,'|') AS DATA
    FROM HEADER_RECORD
    UNION ALL
    SELECT
    CONCAT(RECTYPE,'|',PILLAR,'|',ITEMNO,'|',STATE,'|',ACTION,'|',ITEMTYPE,'|',SUBCOMM,'|',ITEMDESC,'|',WETRATE,'|',SUPPID,'|',LEVYTYPE,'|',APN1,'|',APN2,'|',APN3,'|',TUN1,'|',TUN2,'|',TUN3,'|',MSC,'|',CONSUMER,'|',BRANDDESC,'|',GSTRATE,'|' ) AS DATA
    FROM DETAIL_RECORD
    UNION ALL
    SELECT
    CONCAT(RECTYPE,'|',COALESCE(RECORD_COUNT,''),'|') AS DATA
  FROM TRAILER_RECORD
)

  select * FROM FINAL order by 1 ASC;


END
GO


