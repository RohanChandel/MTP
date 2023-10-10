CREATE PROC [EXTRACT_MDATA].[USP_EDL_D365_PRODUCT_HPRD] @FullLoad [bit],@Batch_Run_Datetime [DATETIME2],@FileGenerationGroup [varchar](10) AS

BEGIN
WITH HEADER_RECORD AS(
    select
    '00'                                                       AS RECTYPE
    ,CASE WHEN @FullLoad = 1 THEN '85' ELSE ' '  END       AS DATATYPE
    ,CASE WHEN @FullLoad = 1 THEN 'R' ELSE 'U'  END        AS LOADTYPE
    ,'S'                                                       AS LOADSCOPE
    ,Left(concat('00',substring(@FILEGENERATIONGROUP, 2, 1) ,REPLICATE(' ',6)),6)     AS SCOPEKEY -- @State_ID+REPLICATE(' ',5)
    ,CONCAT('PR01B7',' ',format(GETDATE(),'dd/MM/yyyy HH:MM')) AS RUNTIME
)
,DETAIL_RECORD AS (
    SELECT 
        83 AS RECTP
        ,JDPTN
        ,RIGHT(REPLICATE(' ',10)+ISNULL(JITMN,' '),10) AS JITMN
         ,CASE WHEN @FullLoad = 1 THEN ' ' 
				WHEN ACTION_CODE = 'M' THEN 'C'
				ELSE ACTION_CODE 
				END															AS ACTN
         ,RIGHT(REPLICATE(' ',25)+ISNULL(PUPCN,' '),25) AS PUPCN
         ,RIGHT(REPLICATE(' ',25)+ISNULL(PUPBB,' '),25) AS PUPBB
         ,RIGHT(REPLICATE(' ',25)+ISNULL(PUPBB,' '),25) AS PUPCC
         ,RIGHT(REPLICATE(' ',2)+ISNULL(cast(JPCKI as varchar(2)),' '),2) AS JPCKI
        --  ,RIGHT(REPLICATE(' ',2)+ISNULL(JPCKI,' '),2) AS JPCKI
         ,JBCCD
         ,ICWCD
         ,IRWCD
         ,JUNMS
         ,ISTS
         ,LEFT(CAST(ONWT as VARCHAR(20)),6) AS ONWT
        FROM [EXTRACT_MDATA].[EDL_D365_PRODUCT_HPRD] 
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
    CONCAT(RECTP,'|',JDPTN,'|',JITMN,'|',ACTN,'|',PUPCN,'|',PUPBB,'|',PUPCC,'|',JPCKI,'|',JBCCD,'|',ICWCD,'|',IRWCD,'|',JUNMS,'|',ISTS,'|',ONWT) AS DATA
    FROM DETAIL_RECORD
  )
  select * FROM FINAL order by 1 ASC
END

GO


