CREATE PROC [EXTRACT_MDATA].[USP_EXTRACTWATERMARKLOG] @EXTRACTNAME [nvarchar](200),@ACTION [INT] AS 

BEGIN

  -- get max updated_dt from table
    DECLARE @vi DATETIME
    DECLARE @vQuery NVARCHAR(1000) = N'SELECT @viOUT = MAX(UPDATED_DT) FROM EXTRACT_MDATA.'+ @EXTRACTNAME
    EXEC SP_EXECUTESQL 
            @Query  = @vQuery
          , @Params = N'@viOUT DATETIME OUTPUT'
          , @viOUT = @vi OUTPUT

  -- get modifieddatetime from watermarklog
    DECLARE @watermark_updated_dt AS DATETIME = (SELECT MODIFIEDDATETIME FROM [EXTRACT_MDATA].[ExtractWatermarkLog] WHERE EXTRACTNAME = @EXTRACTNAME)

  -- 1. Update WatermarkLog Table if there is any updates
  IF @ACTION = 1
    BEGIN
      IF @vi>@watermark_updated_dt
      UPDATE [EXTRACT_MDATA].[ExtractWatermarkLog]
          SET MODIFIEDDATETIME = @vi
          WHERE EXTRACTNAME = @EXTRACTNAME
    END

  ELSE 

    -- 2. check if updated_dt in table is later than watermarklog
    IF @ACTION = 2
    BEGIN
      --SELECT CASE WHEN @vi>@watermark_updated_dt THEN 1 ELSE 0 END AS IsUpdated
      SELECT 1 AS IsUpdated
    END

    -- 3. get FileGenerationGroup from table for new/updated rows
    IF @ACTION = 3
    BEGIN
      DECLARE @FileGenerationGroupQuery NVARCHAR(4000) = N'SELECT DISTINCT FileGenerationGroup FROM EXTRACT_MDATA.'+@EXTRACTNAME+ ' WHERE UPDATED_DT > (Select modifieddatetime from [EXTRACT_MDATA].[ExtractWatermarkLog] where extractname = '''+@EXTRACTNAME+''')'
      EXEC SP_EXECUTESQL @Query  = @FileGenerationGroupQuery
    END

    -- 4. for dallas extraction
    IF @ACTION = 4
    BEGIN
      DECLARE @FileGenerationGroupQuery2 NVARCHAR(4000) = N'SELECT DISTINCT dallas_server, dallas_instance, FileGenerationGroup FROM EXTRACT_MDATA.'+@EXTRACTNAME+ ' WHERE dallas_server is not null and dallas_instance is not null and UPDATED_DT > (Select modifieddatetime from [EXTRACT_MDATA].[ExtractWatermarkLog] where extractname = '''+@EXTRACTNAME+''')'
      EXEC SP_EXECUTESQL @Query  = @FileGenerationGroupQuery2
    END

        -- 4. for CLAIMS extraction
    IF @ACTION = 5
    BEGIN
      DECLARE @FileGenerationGroupQuery3 NVARCHAR(4000) = N'SELECT DISTINCT LEGALENTITY FROM EXTRACT_MDATA.'+@EXTRACTNAME+ ' WHERE UPDATED_DT > (Select modifieddatetime from [EXTRACT_MDATA].[ExtractWatermarkLog] where extractname = '''+@EXTRACTNAME+''')'
      --DECLARE @FileGenerationGroupQuery3 NVARCHAR(4000) = N'SELECT DISTINCT LEGALENTITY FROM EXTRACT_MDATA.'+@EXTRACTNAME+ ' WHERE UPDATED_DT >= (Select modifieddatetime from [EXTRACT_MDATA].[ExtractWatermarkLog] where extractname = '''+@EXTRACTNAME+''')'
      EXEC SP_EXECUTESQL @Query  = @FileGenerationGroupQuery3
    END

END



