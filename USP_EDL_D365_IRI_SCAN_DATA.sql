CREATE PROC [EXTRACT_MDATA].[USP_EDL_D365_IRI_SCAN_DATA] @FullLoad [bit],@Batch_Run_Datetime [DATETIME2],@FileGenerationGroup [varchar](100) AS

BEGIN

IF  EXISTS (SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('[EXTRACT_MDATA].[IRI_SCAN_DATA_EXTRACT]'))
DROP TABLE [EXTRACT_MDATA].[IRI_SCAN_DATA_EXTRACT];

CREATE TABLE [EXTRACT_MDATA].[IRI_SCAN_DATA_EXTRACT] 
WITH
(
 DISTRIBUTION = ROUND_ROBIN
 ,CLUSTERED COLUMNSTORE INDEX

) AS
SELECT 
        REPLACE(CONVERT(VARCHAR(9), HDD.Prom_Wk_End_Dt, 6), ' ', '-') AS Wk_End_Dt,
        HFRSI.Store_Sk as Address_Id,
        HDS.Recent_Store_Nm as Recent_Store_Nm,
        HDS.Administration_State_Cd as Administration_State_Cd,
        CASE
        WHEN HDC.Channel_Report_Grp_Cd ='-'
        THEN HDC.Channel_Cd 
        ELSE HDC.Channel_Report_Grp_Cd
        END Store_Channel_Cd,
        max(CASE 
          WHEN Substring(HFRSI.Gtin_Cd , 1,3) ='Plu'
          THEN CONCAT('000',Substring( HFRSI.Gtin_Cd,4,11)) 
          ELSE  HFRSI.Gtin_Cd  
        END) as Plu_Cd,
        HDP.Product_Cd as Product_Cd,
        HDP.Product_Desc as Product_Desc,
        CASE   
          WHEN  HDP.Product_Cd Like 'S%'  
          THEN 'D'  
          ELSE 'W'  
        END Product_Type,
        HDP.Msc_Dept_Cd as Msc_Dept_Cd,
        HDP.Msc_Dept_Nm as Msc_Dept_Nm,   
        HDP.Msc_Category_Cd as Msc_Category_Cd,
        HDP.Msc_Category_Nm as Msc_Category_Nm,  
        HDP.Msc_Commodity_Cd as Msc_Commodity_Cd,
        HDP.Msc_Commodity_Nm as Msc_Commodity_Nm,
        HDP.Msc_Sub_Comm_Cd as MSC_SUB_COMMODITY_CD,
        HDP.Msc_Sub_Comm_Nm as MSC_SUB_COMMODITY_NM,   
        SUM(HFRSI.Sales_Excl_Gst_Xmt) as Sales_Excl_Gst_Xmt,
        SUM(HFRSI.Sales_Incl_Gst_Xmt) as Sales_Incl_Gst_Xmt,  
        SUM(HFRSI.Sales_Qty) as Sales_Qty 
FROM
        Edl.Hana_Fct_Retail_Sales_Item HFRSI   
        INNER JOIN Edl.Hana_Dim_Date HDD
        ON HFRSI.Date_Sk =HDD.Date_Sk
        INNER JOIN Edl.Hana_Dim_Product HDP
        ON HFRSI.Product_Sk =HDP.Product_Sk 
        INNER JOIN Edl.Hana_Dim_Store HDS
        ON HFRSI.Store_Sk =HDS.Store_Sk
        INNER JOIN Edl.Hana_Dim_Channel HDC
        ON HDS.Store_Channel_Cd = HDC.Channel_Cd

WHERE HDD."GREG_DATE"> '2023-06-20 00:00:00.000'
AND   HDD."GREG_DATE"<= '2023-06-27 00:00:00.000'
AND   HDP.RETAIL_DEPARTMENT_CD != '06'
AND   HDC.IRI_IND = 'Y'
GROUP BY REPLACE(CONVERT(VARCHAR(9), HDD.Prom_Wk_End_Dt, 6), ' ', '-'),
         HFRSI.Store_Sk,
         HDS.Recent_Store_Nm,
         HDS.Administration_State_Cd,
         CASE
           WHEN HDC.Channel_Report_Grp_Cd ='-'
           THEN HDC.Channel_Cd 
           ELSE HDC.Channel_Report_Grp_Cd
         END ,
         HDP.Product_Cd ,
         HDP.Product_Desc,
         CASE   
           WHEN  HDP.Product_Cd Like 'S%'  
           THEN 'D'  
           ELSE 'W'  
         END,
         Msc_Dept_Cd,
         Msc_Dept_Nm,   
         Msc_Category_Cd,
         Msc_Category_Nm,  
         Msc_Commodity_Cd,
         Msc_Commodity_Nm,  
         Msc_Sub_Comm_Cd,
         Msc_Sub_Comm_Nm
END
BEGIN
SELECT TOP 13 Irsea.Administration_State_Cd ,
        Irsea.Store_Channel_Cd ,
        Irsea.Address_Id ,
        Irsea.Recent_Store_Nm ,
        Irsea.Plu_Cd ,
        Irsea.Product_Desc ,
        Irsea.Msc_Sub_Commodity_Cd ,
        Irsea.Msc_Sub_Commodity_Nm ,
        Irsea.Msc_Commodity_Cd ,
        Irsea.Msc_Commodity_Nm ,
        Irsea.Msc_Category_Cd ,
        Irsea.Msc_Category_Nm ,
        Irsea.Msc_Dept_Cd ,
        Irsea.Msc_Dept_Nm ,
        Irsea.Product_Cd ,
        Irsea.Sales_Qty ,
        Irsea.Sales_Excl_Gst_Xmt ,
        Irsea.Sales_Incl_Gst_Xmt ,
        Irsea.Product_Type ,
        Irsea.Wk_End_Dt ,
        CASE When Psup.Supplier_Cd Is Null 
        THEN '-' 
        ELSE  Psup.Supplier_Cd  
        End Supplier_Cd_Txt,
        CASE When  Psup.Supplier_Nm Is Null  
        THEN 'Unknown Supplier' 
        ELSE  Psup.Supplier_Nm  
        End Supplier_Nm_Txt
FROM
    [Extract_Mdata].[Iri_Scan_Data_Extract] Irsea
 LEFT OUTER JOIN
        (SELECT
                Rssv.Product_Cd ,
                Rssv.Supplier_Cd ,
                Rssv.Supplier_Nm ,
                Rssv.Pillar_State_Cd
         From
                Edw.Ref_Scan_Supplier_V Rssv) Psup
  On    Irsea.Administration_State_Cd = Psup.Pillar_State_Cd
  And   Irsea.Product_Cd =   Psup.Product_Cd
  Inner Join  Edl.Hana_Dim_Store  Hds
  On          Irsea.Address_Id =  Hds.Address_Id
  Inner Join Edl.Hana_Ref_Mso  Hrm
  On    Hds.Mso_Cd = Hrm.Mso_Cd
  Where  Hrm.Mso_Exclusion_Ind = 'Y' 
END
GO