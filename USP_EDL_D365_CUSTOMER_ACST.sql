CREATE PROC [EXTRACT_MDATA].[USP_EDL_D365_CUSTOMER_ACST] @FullLoad [bit],@Batch_Run_Datetime [DATETIME2],@FileGenerationGroup [varchar](10) AS
BEGIN

  WITH
  HEADER_RECORD AS (
      select
      '00'              AS RECTYPE,
      '01'              AS DATATYPE,
      'R'               AS LOADTYPE,
      'S'               AS LOADSCOPE,
      LEFT(SUBSTRING(@FileGenerationGroup,1,1)+REPLICATE(' ',6),6) AS SCOPEKEY,
      LEFT(CONCAT('PR01A6',' ',format(@Batch_Run_Datetime,'dd/MM/yyyy HH:MM'))+REPLICATE(' ',100),100)  AS RUNTIME
  )


/* Start of CTE for getting FIXEDCHARGEAMOUNT */
, DIRPARTYBASEENTITY_CTE2 AS  (
    select
    T1.RECID,
    T1.NAME,
    T1.PRIMARYADDRESSLOCATION,
    T2D.Location AS DeliveryAddressLocation,

    T1.PARTYTYPE,
    T1.PARTITION,
    T1.DIRPARTYLOCATIONRECID,
    T1.PRIMARYCONTACTEMAIL,
    T1.PRIMARYCONTACTFAX,

    T1.PRIMARYCONTACTPHONE

    FROM EXTRACT_MDATA.V_ENTITY_DIRPARTYBASEENTITY T1
    LEFT JOIN EXTRACT_MDATA.V_ENTITY_AllAddressLocation as T2D 
        ON T1.RECID = T2D.RECID
            AND T2D.ADDRESSLOCATIONROLES = 'Delivery'


)
,SALESAUTOMATICSALESDOCUMENTLINECHARGEENTITY_CTE AS
(
  Select
  T2.ACCOUNTCODE AS ACCOUNTCODE,
  T2.ACCOUNTRELATION,
  (CAST ((CASE WHEN 0 = T2.ACCOUNTCODE THEN T2.ACCOUNTRELATION ELSE '' END) AS NVARCHAR (20))) AS CHARGINGCUSTOMERACCOUNTNUMBER,
  (CAST ((CASE WHEN 0 = T1.MARKUPCATEGORY THEN T1.VALUE ELSE 0 END) AS NUMERIC (32, 6))) AS FIXEDCHARGEAMOUNT
  FROM   EDL_D365.MARKUPAUTOLINE AS T1
  INNER JOIN EDL_D365.MARKUPAUTOTABLE AS T2
  on  T1.DATAAREAID = T2.DATAAREAID
	AND T2.MARKUPRETURN = 0
  --AND T2.MODULETYPE = 1   /* This filter is dropping records */
  AND T2.MODULECATEGORY = 1
  AND T1.TABLERECID = T2.RECID
)
/* End of CTE for getting FIXEDCHARGEAMOUNT */
,DETAIL_RECORD AS   ( /*Added distinct by to avoid duplicates */
    SELECT distinct
          '01'	                                                             AS RECTYPE,
          --LEFT(ISNULL(REPLACE(RIGHT(DEFAULTDIMENSIONDISPLAYVALUE,5),'-',''),' ')+REPLICATE(' ',3),3)  
          'ALM' AS PILLAR,
          RIGHT(REPLICATE('0',6)+ISNULL(T1.ACCOUNTNUM,' '),6)              AS CUSTNO, --8chars proper data/6 chars data drop(Int team needs 6)
          SUBSTRING(T1.ACCOUNTNUM,2,1)                                     AS STATE,
          ' '                                                                AS ACTION,
          RIGHT(REPLICATE('0',3)+ISNULL(T1.INVENTLOCATION,' ') ,3)                AS BRANCH,
          LEFT(ISNULL(T12.CustOperGroupId,' ')+REPLICATE(' ',5),5)               AS CUSTGROUP,
          LEFT(ISNULL(T12.CustOperGroupId,' ')+REPLICATE(' ',5),5)               AS WSLEID,
          LEFT(ISNULL(T5.NAME,' ')+REPLICATE(' ',30),30)                    AS CUSTNAME,
          LEFT(ISNULL(T14D.STREET,' ')+REPLICATE(' ',25),25)       AS CUSTSTREET,
          LEFT(ISNULL(T14D.CITY,' ')+REPLICATE(' ',20),20)         AS CUSTSUB,
          RIGHT(REPLICATE('0',4)+ISNULL(T14D.ZIPCODE,' '),4)       AS CUSTPOST,
          LEFT(ISNULL(T5.PRIMARYCONTACTPHONE,' ')+REPLICATE(' ',12),12)         AS BUSPHONE,
          LEFT(ISNULL(T5.PRIMARYCONTACTFAX,' ')+REPLICATE('0',12),12)           AS FAXNO,
          case when T1.BLOCKED  = 1 then 'Y' else 'N'end                    AS STOPFLAG,
          LEFT((' ')+REPLICATE(' ',50),50)                                    AS DELINSTR,
          '0'                                                                 AS LEADTIME,
          ' '                                                                 AS INVZIPFLAG,
          'Y'                                                                 AS SHOWPRICE,                        
          LEFT(('%')+REPLICATE(' ',1),1)                                      AS ADMFEETYPE,
          RIGHT(REPLICATE('0',5)+('0'),5)                                     AS ADMFEECART,
          RIGHT(REPLICATE('0',4)+('%'),5)                                     AS FINFEEPERC,
          LEFT(('%')+REPLICATE(' ',1),1)                                      AS DELFEETYPE,
          '00000'                                                                 AS DELFEEKEG,
          '00000'                                                                 AS DELFEECART,
          --LEFT(ISNULL(ADDRESSLOCATIONROLES,' ')+REPLICATE(' ',30),30)         AS ADDRTYPE,
          LEFT('Delivery'+REPLICATE(' ',30),30)                           AS ADDRTYPE,
          LEFT(ISNULL(T5.PRIMARYCONTACTEMAIL,' ')+REPLICATE(' ',100),100)        AS EMAIL,
          LEFT(ISNULL(LIQ.LiquorLicenceNumber,' ')+REPLICATE(' ',15),15)          AS LICNUMTEST,
/* Change in LIcenseType derivation */          
         -- LEFT(ISNULL(LiquorLicenceType,' ')+REPLICATE(' ',1),1)              AS LIQLICTYPETEST,
          CASE 
              WHEN LEFT(ISNULL(LIQ.LiquorLicenceType,' ')+REPLICATE(' ',1),1) =0 THEN 'R'
              WHEN LEFT(ISNULL(LIQ.LiquorLicenceType,' ')+REPLICATE(' ',1),1) =1 THEN 'S'
              WHEN LEFT(ISNULL(LIQ.LiquorLicenceType,' ')+REPLICATE(' ',1),1) =2 THEN 'B'
              WHEN LEFT(ISNULL(LIQ.LiquorLicenceType,' ')+REPLICATE(' ',1),1) =3 THEN 'E'
              WHEN LEFT(ISNULL(LIQ.LiquorLicenceType,' ')+REPLICATE(' ',1),1) =4 THEN 'D'
              WHEN LEFT(ISNULL(LIQ.LiquorLicenceType,' ')+REPLICATE(' ',1),1) =5 THEN 'G'
              WHEN LEFT(ISNULL(LIQ.LiquorLicenceType,' ')+REPLICATE(' ',1),1) =6 THEN 'X'
              WHEN LEFT(ISNULL(LIQ.LiquorLicenceType,' ')+REPLICATE(' ',1),1) =7 THEN 'I'
              WHEN LEFT(ISNULL(LIQ.LiquorLicenceType,' ')+REPLICATE(' ',1),1) =8 THEN 'U'
                    END                                                   AS LIQLICTYPETEST,
          '   '                                                           AS CUSTTYPE,
          ' '                                                             AS TRADETYPE,
          LIQ.LiquorLicencestate                                          AS LiquorLicencestate,          
          '120000'                                                        AS CUTTIMMON,
          'Monday    '                                                    AS DELCUTMON,
          '120000'                                                        AS CUTTIMTUE,
          'Tuesday   '                                                    AS DELCUTTUE,
          '120000'                                                        AS CUTTIMWED,
          'Wednesday '                                                    AS DELCUTWED,
          '120000'                                                        AS CUTTIMTHU,
          'Thursday  '                                                    AS DELCUTTHU,
          '120000'                                                        AS CUTTIMFRI,
          'Friday    '                                                    AS DELCUTFRI,
          '120000'                                                        AS CUTTIMSAT,
          'Saturday  '                                                    AS DELCUTSAT,
          '120000'                                                        AS CUTTIMSUN,
          'Sunday    '                                                    AS DELCUTSUN,
          '  '                                                            AS CMPID,
          LEFT(ISNULL(T1.CommissionGroup,' ')+REPLICATE(' ',3),3)   AS REPTERID1,
          'TBC                 '                                          AS REPTERNAM1,
          '   '                                                           AS REPTERID2,
          '                    '                                          AS REPTERNAM2,
          '        '                                                      AS LASTBUYDTE,
          LEFT(ISNULL(T14D.STATE,' ')+REPLICATE(' ',3),3)       AS DELSTATE,
          RIGHT(REPLICATE('0',5)+ISNULL(S.FIXEDCHARGEAMOUNT,'0'),5)          AS WRAPRCODE
      FROM EDL_D365.CUSTTABLE AS T1
      INNER JOIN DIRPARTYBASEENTITY_CTE2 AS T5
        ON (T1.PARTY = T5.RECID AND T1.Is_Current_Flag =1)
      LEFT JOIN EDL_D365.METCUSTTABLE AS T12
        ON T1.ACCOUNTNUM = T12.ACCOUNTNUM
            AND T1.DATAAREAID = T12.DATAAREAID
            AND T12.Is_Current_Flag =1
            AND T12.Is_Delete_Flag = 0
      LEFT JOIN EXTRACT_MDATA.V_ENTITY_LOGISTICSPOSTALADDRESSBASEENTITY AS T14D
        ON T5.DeliveryADDRESSLOCATION = T14D.LOCATIONRECID
            AND( T14D.VALIDFROM <= SYSUTCDATETIME()  
                AND T14D.VALIDTO >= SYSUTCDATETIME()
                )
      LEFT OUTER JOIN [EDL_D365].[METCustLiquorLicenseTable] LIQ            --Moving this join from View to SP for Liqno & Liqtype
        ON T1.ACCOUNTNUM = LIQ.CustomerNumber
            AND UPPER(
                CASE SUBSTRING(T1.ACCOUNTNUM,2,1)
                WHEN '1' THEN 'NSW' 
                WHEN '2' THEN 'VIC' 
                WHEN '3' THEN 'QLD' 
                WHEN '4' THEN 'WA' 
                WHEN '5' THEN 'SA' 
                WHEN '6' THEN 'NT' 
                WHEN '7' THEN 'TAS' 
                WHEN '8' THEN 'ACT' 
                WHEN '9' THEN 'NZ' 
                ELSE NULL END
            ) = UPPER(LIQ.LiquorLicencestate)
            AND LIQ.Is_Current_Flag = 1  
      LEFT OUTER JOIN SALESAUTOMATICSALESDOCUMENTLINECHARGEENTITY_CTE  S
        ON  T1.ACCOUNTNUM=S.CHARGINGCUSTOMERACCOUNTNUMBER
      LEFT JOIN EDL_D365.CommissionSalesGroup CSG
        ON T1.CommissionGroup = CSG.GroupId
          AND CSG.Is_Current_Flag = 1
            AND CSG.Is_Delete_Flag = 0

        where T1.DATAAREAID IN ('2000')
        AND T1.CustGroup = 'MT01'
        AND (CAST(T1.BLOCKED AS VARCHAR(10)) ='No' or T1.BLOCKED =0)  
        --AND V.ADDRESSLOCATIONROLES ='Delivery'                        /* Adding this filter to pick only Delivery ADDRESS */   
        AND SUBSTRING(T1.ACCOUNTNUM,2,1) = @FileGenerationGroup

  )


,TRAILER_RECORD AS
(
  SELECT
  '99'                                                    AS RECTYPE,
  FORMAT(count(*),'0000000')                              AS COUNTS
  FROM
    DETAIL_RECORD
)
,FINAL_CTE AS (
  SELECT
  CONCAT(RECTYPE,'|',DATATYPE,'|',LOADTYPE,'|',LOADSCOPE,'|',SCOPEKEY,'|',RUNTIME,'|') AS DATA
  FROM HEADER_RECORD
  UNION ALL
  SELECT
    CONCAT(RECTYPE,'|',PILLAR,'|',CUSTNO,'|',STATE,'|',ACTION,'|',BRANCH,'|',CUSTGROUP,'|',WSLEID,'|',CUSTNAME,'|',CUSTSTREET,'|',CUSTSUB,'|',
    CUSTPOST,'|',BUSPHONE,'|',FAXNO,'|',STOPFLAG,'|',DELINSTR,'|',LEADTIME,'|',INVZIPFLAG,'|',SHOWPRICE,'|',ADMFEETYPE,'|',ADMFEECART,'|',
    FINFEEPERC,'|',DELFEETYPE,'|',DELFEEKEG,'|',DELFEECART,'|',ADDRTYPE,'|',EMAIL,'|',LICNUMTEST,'|',LIQLICTYPETEST,'|',
    CUSTTYPE, '|', TRADETYPE, '|', CUTTIMMON,'|',
    DELCUTMON,'|',CUTTIMTUE,'|',DELCUTTUE,'|',CUTTIMWED,'|',DELCUTWED,'|',CUTTIMTHU,'|',DELCUTTHU,'|',CUTTIMFRI,'|',DELCUTFRI,'|',
    CUTTIMSAT,'|',DELCUTSAT,'|',CUTTIMSUN,'|',DELCUTSUN,'|',
    CMPID, '|', REPTERID1, '|', REPTERNAM1, '|', REPTERID2, '|', REPTERNAM2, '|', LASTBUYDTE,'|', 
    DELSTATE,'|',WRAPRCODE,'|') AS DATA
  FROM DETAIL_RECORD
  UNION ALL
  SELECT
  CONCAT(RECTYPE,'|',COALESCE(COUNTS,''),'|') AS DATA
  FROM TRAILER_RECORD
)
Select * FROM FINAL_CTE order by 1 ASC

END

GO