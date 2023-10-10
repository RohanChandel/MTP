CREATE PROC [EXTRACT_MDATA].[USP_EDL_D365_PRODUCT_ACOM] @FullLoad [bit],@Batch_Run_Datetime [DATETIME2],@FileGenerationGroup [varchar](10) AS

BEGIN
      with HEADER_RECORD AS (
            select
            '00'              AS RECTYPE,
            '08'              AS DATATYPE,
            'R'               AS LOADTYPE,
            'S'               AS LOADSCOPE,
            @FileGenerationGroup			AS SCOPEKEY,
            LEFT(CONCAT('PR01A3',' ',format(@Batch_Run_Datetime,'dd/MM/yyyy HH:MM'))+REPLICATE(' ',100),100)  AS RUNTIME

      )

      ,DETAIL_RECORD AS (
            SELECT DISTINCT
            '08'                                                             AS RECTYPE,
            'ALM'                                                            AS PILLAR,
            @FileGenerationGroup                                                     AS STATE,
            T.ITEMTYPE                                                         AS ITEM_TYPE,
            ' '                                                            AS ACTION,
            T.DESCRIPTION                                                      AS ITEM_DESC
            from EDL_D365.METITEMTYPE T --METITEMTYPEENTITY
            where T.DATAAREAID='2000'
                  and T.Is_Current_flag=1
                  and T.Is_Delete_Flag = 0
      )
      ,TRAILER_RECORD AS (
		  SELECT
			  '99'                                                    AS RECTYPE,
			  FORMAT(count(*),'0000000')                              AS COUNTS
		  FROM
		  DETAIL_RECORD
      )
      SELECT
      CONCAT(RECTYPE,'|',DATATYPE,'|',LOADTYPE,'|',LOADSCOPE,'|',SCOPEKEY,'|',RUNTIME,'|') AS DATA
      FROM HEADER_RECORD
      UNION ALL
      SELECT
      CONCAT(RECTYPE, '|',PILLAR,'|',STATE,'|',ITEM_TYPE,'|',ACTION,'|',ITEM_DESC,'|') AS DATA
      FROM DETAIL_RECORD
      UNION ALL
      SELECT
      CONCAT(RECTYPE,'|',COALESCE(COUNTS,''),'|') AS DATA
      FROM TRAILER_RECORD;



END
GO