CREATE PROC [EXTRACT_MDATA].[USP_EDL_D365_INVENTORY_HSTK] @FullLoad [bit],@Batch_Run_Datetime [DATETIME2],@FileGenerationGroup [varchar](10) AS


BEGIN

WITH HEADER_RECORD AS(
    select
    '00'                                                 AS RECTYPE
    ,'89'                                                AS DATATYPE
    ,CASE WHEN @FullLoad = 1 THEN 'R' ELSE 'U'  END  AS LOADTYPE
    ,'B'                                                 AS LOADSCOPE
    ,Left(concat('00',SUBSTRING(@FILEGENERATIONGROUP, 2,3),REPLICATE(' ',6)),6)     AS SCOPEKEY
    ,CONCAT('PR01A2',' ',format(GETDATE(),'dd/MM/yyyy HH:MM')) AS RUNTIME 
)
,DETAIL_RECORD AS (
    SELECT 
 		89 AS [RTYP]
		,[PLLR]
		,[STEB]
		,RIGHT(REPLICATE(' ',10)+ISNULL(PROD,' '),10) AS [PROD]
        ,[BRCH]
		,CASE WHEN ACTION_CODE = 'M' THEN 'C' ELSE ACTION_CODE END AS [ACTN]
		,[STOH]
		,CASE WHEN INVENTSTATUSID = 'Available' THEN 'A'
			WHEN INVENTSTATUSID = 'Hold' THEN 'N'
			ELSE INVENTSTATUSID 
		END [AVAL] 
	from [EXTRACT_MDATA].[EDL_D365_INVENTORY_HSTK] 
    WHERE 	IS_Current_Flag = 1
		AND ((@FullLoad = 0 AND batch_run_datetime > = @Batch_Run_Datetime) OR (@FullLoad = 1 AND ACTION_CODE <>'D'))
		AND FILEGENERATIONGROUP = @FILEGENERATIONGROUP
)
,FINAL AS
(
    SELECT
    CONCAT(RECTYPE,'|',DATATYPE,'|',LOADTYPE,'|',LOADSCOPE,'|',SCOPEKEY,'|',RUNTIME) AS DATA
    FROM HEADER_RECORD
    UNION ALL
    SELECT
    CONCAT(RTYP,'|',PLLR,'|',STEB,'|',PROD,'|',BRCH,'|',ACTN,'|',STOH,'|',AVAL) AS DATA
    FROM DETAIL_RECORD   
)
  select * FROM FINAL order by 1 ASC;
END

GO


