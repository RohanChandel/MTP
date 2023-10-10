CREATE PROC [EXTRACT_MDATA].[USP_EDL_D365_PRODUCT_HPRO] @FullLoad [bit],@Batch_Run_Datetime [DATETIME2],@FileGenerationGroup [varchar](10) AS

BEGIN
WITH HEADER_RECORD AS(
    select
    '80'                                                       AS RECTYPE
    ,CASE WHEN @FullLoad = 1 THEN '85' ELSE ' '  END       AS DATATYPE
    ,CASE WHEN @FullLoad = 1 THEN 'R' ELSE 'U'  END        AS LOADTYPE
    ,'S'                                                       AS LOADSCOPE
    ,Left(concat('00',substring(@FILEGENERATIONGROUP, 2, 1) ,REPLICATE(' ',6)),6)     AS SCOPEKEY  -- @State_ID+REPLICATE(' ',5)
    ,CONCAT('PR01BX',' ',format(GETDATE(),'dd/MM/yyyy HH:MM')) AS RUNTIME
)
,DETAIL_RECORD AS (
    SELECT 
        '85' AS RECTP
         ,JDPTN --Have to Change the logic
         ,CASE WHEN @FullLoad = 1 THEN ' ' ELSE ACTION_CODE END AS ACTN
         ,RIGHT(REPLICATE(' ',10)+ISNULL(JITMN,' '),10) AS JITMN
         ,RIGHT(REPLICATE(' ',10)+ISNULL(PUPCP,' '),10) AS PUPCP
         ,ISTS
        FROM [EXTRACT_MDATA].[EDL_D365_PRODUCT_HPRO] 
		WHERE IS_Current_Flag = 1
			AND ((@FullLoad = 0 AND batch_run_datetime >= @Batch_Run_Datetime) OR (@FullLoad = 1 AND ACTION_CODE <>'D'))
			AND FileGenerationGroup = @FileGenerationGroup
)

,FINAL AS
(
    SELECT
    CONCAT(RECTYPE,'|',DATATYPE,'|',LOADTYPE,'|',LOADSCOPE,'|',SCOPEKEY,'|',RUNTIME,'|') AS DATA
    FROM HEADER_RECORD
    UNION ALL
    SELECT
    CONCAT(RECTP,'|',JDPTN,'|',ACTN,'|',JITMN,'|',PUPCP,'|',ISTS,'|' ) AS DATA
    FROM DETAIL_RECORD
  )
  select * FROM FINAL order by 1 ASC
END

GO


