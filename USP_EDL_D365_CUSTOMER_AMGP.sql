CREATE PROC [EXTRACT_MDATA].[USP_EDL_D365_CUSTOMER_AMGP] @FullLoad [bit],@Batch_Run_Datetime [DATETIME2],@FileGenerationGroup [varchar](10) AS

BEGIN

  WITH
  HEADER_RECORD AS
  (
      select
      '00'              AS RECTYPE,
      '07'              AS DATATYPE,
      'R'               AS LOADTYPE,
      'S'               AS LOADSCOPE,
      CAST(@FileGenerationGroup AS VARCHAR(1))+REPLICATE(' ',6) AS SCOPEKEY,
      LEFT(CONCAT('PR01A5 ',format(@Batch_Run_Datetime,'dd/MM/yyyy HH:MM'))+REPLICATE(' ',100),100)  AS RUNTIME
  )
  ,DETAIL_RECORD AS (
    SELECT
          '07'	                                                          AS RECTYPE,
          'ALM'                                                           AS PILLAR,
          @FileGenerationGroup                                            AS STATE,
          LEFT(ISNULL(CustomerOperationsGroup,' ')+REPLICATE(' ',5),5)    AS MAJGROUP,
          ' '                                                             AS ACTION,
          LEFT(ISNULL(Description,' ')+REPLICATE(' ',30),30)              AS MAJGRPNAME,
          'N'                                                             AS IBABRAND,
          'N'                                                             AS IBAFOCUS
      FROM EDL_D365.METCustomerOperationsGroup T1
      WHERE T1.DataAreaID = 2000
		AND SUBSTRING(CustomerOperationsGroup,2,1) =  @FileGenerationGroup
        AND T1.Is_Current_Flag = 1
        AND T1.Is_delete_flag = 0

  )
,TRAILER_RECORD AS (
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
    CONCAT(RECTYPE,'|',PILLAR,'|',STATE,'|',MAJGROUP,'|',ACTION,'|',MAJGRPNAME,'|',IBABRAND,'|',IBAFOCUS,'|') AS DATA
  FROM DETAIL_RECORD
  UNION ALL
  SELECT
  CONCAT(RECTYPE,'|',COALESCE(COUNTS,''),'|') AS DATA
  FROM TRAILER_RECORD
) 
Select * FROM FINAL_CTE order by 1 ASC

END
GO


