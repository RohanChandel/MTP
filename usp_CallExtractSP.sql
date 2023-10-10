CREATE PROC [EXTRACT_MDATA].[usp_CallExtractSP] @FullLoad [bit],@Batch_Run_Datetime [DATETIME2],@FileGenerationGroup [varchar](100),@ExtractSPName [varchar](100),@ExtractSPSchema [varchar](100) AS

-- IF @Batch_Run_Datetime IS NULL then set a date. 
SET @Batch_Run_Datetime = CASE WHEN @Batch_Run_Datetime IS NULL THEN CAST('1990-01-01' AS DateTime2) ELSE @Batch_Run_Datetime END

DECLARE @Full_Refresh_input as nvarchar(1) = CASE WHEN @FullLoad = 1 THEN '1' ELSE '0' END
DECLARE @current_timestamp_input NVARCHAR(MAX) = '''' + FORMAT(@batch_run_datetime, 'yyyy-MM-dd HH:mm:ss.fff') + ''''
DECLARE @FileGenerationGroup_input NVARCHAR(MAX) = '''' + @FileGenerationGroup+ ''''

DECLARE @ExecuteExtractSP_SQL NVARCHAR(MAX) = '
   EXECUTE '+@ExtractSPSchema+'.'+@ExtractSPName+'
	@FullLoad = '+ @Full_Refresh_input +'
	,@Batch_Run_Datetime = '+ @current_timestamp_input +'
	,@FileGenerationGroup = ' + @FileGenerationGroup_input

EXEC (@ExecuteExtractSP_SQL)
GO