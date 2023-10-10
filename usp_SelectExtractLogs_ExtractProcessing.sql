CREATE PROC [EXTRACT_MDATA].[usp_SelectExtractLogs_ExtractProcessing] @ExtractName [NVARCHAR](MAX),@batch_run_datetime [datetime2] AS

-- convert datetime to string to ensure same datetime precision
DECLARE @batch_run_datetime_input AS NVARCHAR(MAX) = FORMAT(@batch_run_datetime, 'yyyy-MM-dd HH:mm:ss.fff') 

SELECT FileGenerationGroup, KVTargetAzureDataLakeSecretName, KVTargetAzureDataLakeURL, TargetFileSystem, TargetDirectory, TargetFileName, Header, columnDelimiter, QuoteCharacter, EscapeCharacter, WatermarkModifiedDateTime
FROM Ingestion.LogExtractDetail
WHERE ExtractName = @ExtractName
	AND StartTime = @batch_run_datetime_input
	AND Status = 'Started'
GO