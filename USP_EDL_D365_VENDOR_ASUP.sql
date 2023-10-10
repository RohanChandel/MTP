CREATE PROC [EXTRACT_MDATA].[USP_EDL_D365_VENDOR_ASUP] @FullLoad [bit],@Batch_Run_Datetime [DATETIME2],@FileGenerationGroup [varchar](10) AS
BEGIN

  WITH
  HEADER_RECORD AS (
      select
      '00'              AS RECTYPE,
      '18'              AS DATATYPE,
      'R'               AS LOADTYPE,
      'S'               AS LOADSCOPE,
      LEFT(SUBSTRING(@FileGenerationGroup,1,1)+REPLICATE(' ',6),6) AS SCOPEKEY,
      LEFT(CONCAT('PR01B5',' ',format(GETDATE(),'dd/MM/yyyy HH:MM'))+REPLICATE(' ',100),100)  AS RUNTIME
  )
  ,DETAIL_RECORD AS (
	  SELECT DISTINCT 
		'18'																AS RECTYPE
		,'ALM'																AS PILLAR
        , RIGHT(REPLICATE('0',5)+SUBSTRING(T1.ACCOUNTNUM,3,7),5)			AS SUPPID
		, @FileGenerationGroup												AS STATE
		, ' '																AS ACTION
		, LEFT(ISNULL(T10.NAME,' ')+REPLICATE(' ',30),30)					AS SUPPNAME
		, LEFT(ISNULL(lpaB.STREET,' ')+REPLICATE(' ',25),25)				AS SUPPSTR
		, LEFT(ISNULL(lpaB.CITY,' ')+REPLICATE(' ',50),50)					AS SUPPSUB
		, RIGHT(REPLICATE('0',4)+ISNULL(lpaB.ZIPCODE,0),4)					AS SUPPPOCD
		, '00000'															AS MASSUPPID
		, LEFT(ISNULL(lpaB.STATE,' ')+REPLICATE(' ',3),3)					AS VENDSTATE
    FROM EDL_D365.VENDTABLE AS T1
    INNER JOIN EXTRACT_MDATA.V_ENTITY_DIRPARTYBASEENTITY AS T10
        ON T1.PARTY = T10.RECID
    LEFT JOIN EDL_D365.METvendtable T2
		ON T1.accountnum = t2.accountnum
			and t1.dataareaid = t2.dataareaid
			and t2.is_current_flag =1
			and t2.is_delete_flag= 0
    LEFT OUTER JOIN EXTRACT_MDATA.V_ENTITY_LOGISTICSPOSTALADDRESSBASEENTITY AS T19
        ON T10.PRIMARYADDRESSLOCATION = T19.LOCATIONRECID
            AND T19.VALIDFROM <= GETUTCDATE()
            AND T19.VALIDTO >= GETUTCDATE()
    -- Join with EXTRACT_MDATA.V_ENTITY_AllAddressLocation to get Business Addresses primary and non-primary
    LEFT JOIN EXTRACT_MDATA.V_ENTITY_AllAddressLocation T19B
      ON T10.RECID = T19B.RECID
        AND T19B.ADDRESSLOCATIONROLES = 'Business'
	LEFT JOIN EXTRACT_MDATA.V_ENTITY_LOGISTICSPOSTALADDRESSBASEENTITY lpaB
		ON T19B.Location = lpaB.LOCATIONRECID
			AND lpaB.VALIDFROM <= SYSUTCDATETIME()  
            AND lpaB.VALIDTO >= SYSUTCDATETIME()
    WHERE  T1.Is_Current_Flag=1
		and T1.is_delete_flag = 0
		and T1.DATAAREAID = 2000
		and T1.VENDGROUP = 'TVBF'
		and t2.vendstatus <> 3																-- status is not delete
		and SUBSTRING(T1.ACCOUNTNUM,2,1) = @FileGenerationGroup	

  )

  ,TRAILER_RECORD AS  (
    SELECT
    '99'                                                    AS RECTYPE,
    FORMAT(count(*),'0000000')                              AS COUNTS
    FROM
      DETAIL_RECORD
  )
	,FINAL AS (
	  SELECT
	  CONCAT(RECTYPE,'|',DATATYPE,'|',LOADTYPE,'|',LOADSCOPE,'|',SCOPEKEY,'|',RUNTIME,'|') AS DATA
	  FROM HEADER_RECORD
	  UNION ALL
	  SELECT
	  CONCAT(RECTYPE,'|',PILLAR,'|',SUPPID,'|',STATE,'|',ACTION,'|',SUPPNAME,'|',SUPPSTR,'|',SUPPSUB,'|',SUPPPOCD,'|',MASSUPPID,'|',VENDSTATE,'|' ) AS DATA
	  FROM DETAIL_RECORD
	  UNION ALL
	  SELECT
	  CONCAT(RECTYPE,'|',COALESCE(COUNTS,''),'|') AS DATA
	  FROM TRAILER_RECORD
	)
  select * FROM FINAL order by 1 ASC;

END

GO