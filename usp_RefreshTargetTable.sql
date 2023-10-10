CREATE PROC [EXTRACT_MDATA].[usp_RefreshTargetTable] @PipelineRunID [NVARCHAR](MAX),@view_schema [NVARCHAR](MAX),@view_name [NVARCHAR](MAX),@table_schema [NVARCHAR](MAX),@table_name [NVARCHAR](MAX),@batch_run_datetime [datetime2] AS

DECLARE @PipelineRunID_input NVARCHAR(MAX) = '''' + @PipelineRunID + ''''				
DECLARE @current_timestamp_input NVARCHAR(MAX) = '''' + FORMAT(@batch_run_datetime, 'yyyy-MM-dd HH:mm:ss.fff') + ''''		


-- Get all columns' names of view
DECLARE @column_list_view NVARCHAR(MAX) = (
    SELECT STRING_AGG(CAST(column_name AS NVARCHAR(MAX)), N', ') WITHIN GROUP (ORDER BY ORDINAL_POSITION)
    FROM information_schema.columns 
    WHERE table_schema = @view_schema
    AND table_name = @view_name
)

-- Get all columns' names for table
DECLARE @column_list_table NVARCHAR(MAX) = @column_list_view
            + ', ACTION_CODE' 
            + ', IS_CURRENT_FLAG'
			+ ', IS_DELETE_FLAG'
            + ', PIPELINE_RUN_ID'
			+ ', BATCH_RUN_DATETIME'

-- Insert view into #Temptable so that dataset freezes for this operation. Use CTAS to improve performance
DECLARE @Select_Into_TempTable AS VARCHAR(MAX) = (
    'CREATE TABLE #TempTable
    WITH (
    DISTRIBUTION = HASH(PK_HASH)
    , CLUSTERED COLUMNSTORE INDEX
    )
    AS
    SELECT ' + @column_list_view + ' 
    FROM ' + @view_schema +'.'+@view_name )

EXEC (@Select_Into_TempTable )



-- DELETE, UPDATE, INSERT
--==========================================================================================================
-- DELETING RECORDS
-- if PK_HASH not found in #TempTable then Insert the record as IS_DELETE_FLAG = 1
    DECLARE @Insert_Deleted_Records_SQL NVARCHAR(MAX) = 'INSERT INTO ' + @table_schema +'.'+ @table_name + ' (
    ' +
    @column_list_table +' ) 
    SELECT ' + @column_list_view +
    ',''D'' AS ACTION_CODE, ' +
    '1 AS IS_CURRENT_FLAG, ' +
    '1 AS IS_DELETE_FLAG, ' +
    @PipelineRunID_input + '  AS PIPELINE_RUN_ID, ' + 
    @current_timestamp_input+ '  AS BATCH_RUN_DATETIME
    FROM ' +@table_schema + '.' + @table_name +' 
    WHERE  
        Is_Current_Flag = 1
        AND Is_Delete_Flag = 0
        AND PK_HASH NOT IN ( 
                SELECT DISTINCT PK_HASH FROM #TempTable
        )'

    -- if PK_HASH not found in #TempTable then Update Current Flag = 0 
    DECLARE @Update_Deleted_Records_SQL NVARCHAR(MAX) = 'UPDATE ' + @table_schema +'.'+ @table_name + '  
    SET IS_CURRENT_FLAG = 0,
    PIPELINE_RUN_ID = ' +@PipelineRunID_input + ',
    BATCH_RUN_DATETIME = ' +@current_timestamp_input+ '
    FROM ' +@table_schema + '.' + @table_name +' 
    WHERE  
        Is_Current_Flag = 1
        AND Is_Delete_Flag = 0
        AND PK_HASH NOT IN ( 
                SELECT DISTINCT PK_HASH FROM #TempTable
        )'

EXEC(@Insert_Deleted_Records_SQL+@Update_Deleted_Records_SQL)
--==========================================================================================================

--==========================================================================================================
-- UPDATING RECORDS
-- if combination of PK_HASH and REC_HASH not found in #TempTable then Insert the record 
DECLARE @Insert_Updated_Records_SQL NVARCHAR(MAX) = 'INSERT INTO ' + @table_schema +'.'+ @table_name + ' (
' +
@column_list_table +' ) 
SELECT ' + @column_list_view +
',''M'' AS ACTION_CODE, ' +
'1 AS IS_CURRENT_FLAG, ' +
'0 AS IS_DELETE_FLAG, ' +
@PipelineRunID_input + ' AS PIPELINE_RUN_ID, ' + 
@current_timestamp_input+ ' AS BATCH_RUN_DATETIME
FROM #TempTable 
WHERE PK_HASH IN (SELECT PK_HASH FROM ' + @table_schema + '.' +@table_name + ') AND
	CONCAT(PK_HASH , REC_HASH) NOT IN (
		SELECT DISTINCT CONCAT(PK_HASH, REC_HASH) 
		FROM ' + @table_schema + '.' +@table_name + '
		WHERE IS_CURRENT_FLAG = 1 
			AND IS_DELETE_FLAG = 0
)'

-- if combincation of PK_HASH and REC_HASH not found in #TempTable then Update Current Flag = 0 
DECLARE @Update_Updated_Records_SQL NVARCHAR(MAX) = 'UPDATE ' + @table_schema +'.'+ @table_name + '  
SET IS_CURRENT_FLAG = 0,
PIPELINE_RUN_ID = ' +@PipelineRunID_input + ',
BATCH_RUN_DATETIME = ' +@current_timestamp_input+ '
FROM ' +@table_schema + '.' + @table_name +' 
WHERE  
    Is_Current_Flag = 1
    AND Is_Delete_Flag = 0
	AND PK_HASH IN (SELECT PK_HASH FROM #TempTable)
    AND CONCAT(PK_HASH , REC_HASH) NOT IN ( 
            SELECT DISTINCT CONCAT(PK_HASH,REC_HASH) FROM #TempTable
    )'

EXEC(@Insert_Updated_Records_SQL+@Update_Updated_Records_SQL)
--==========================================================================================================


--==========================================================================================================
-- INSERTING NEW RECORDS
-- Insert new values from view to target table if PK_HASH not found in Target Table
DECLARE @Insert_New_Records_SQL NVARCHAR(MAX) = 'INSERT INTO ' + @table_schema +'.'+ @table_name + ' (
    ' +
    @column_list_table +' ) 
    SELECT ' + @column_list_view +
    ',''A'' AS ACTION_CODE, ' +
    '1 AS IS_CURRENT_FLAG, ' +
    '0 AS IS_DELETE_FLAG, ' +
    @PipelineRunID_input + ' AS PIPELINE_RUN_ID, ' + 
    @current_timestamp_input+ ' AS BATCH_RUN_DATETIME
    FROM #TempTable 
    WHERE  PK_HASH NOT IN ( 
        SELECT DISTINCT PK_HASH
        FROM ' + @table_schema + '.' +@table_name + '
        WHERE IS_CURRENT_FLAG = 1 
            AND IS_DELETE_FLAG = 0
    )'

-- Update old Deleted Records to Is_current_Flag = 0 when it is found in  #Temptable
DECLARE @Update_ReInserted_Records_SQL NVARCHAR(MAX) = N'UPDATE ' + @table_schema +'.'+ @table_name + '
    SET IS_CURRENT_FLAG = 0,
        PIPELINE_RUN_ID = ' +@PipelineRunID_input + ',
        BATCH_RUN_DATETIME = ' + @current_timestamp_input + '
    WHERE IS_CURRENT_FLAG = 1 
            AND IS_DELETE_FLAG = 1
            AND PK_HASH IN ( 
                SELECT DISTINCT PK_HASH
                FROM #TempTable
            )'

EXEC(@Insert_New_Records_SQL+@Update_ReInserted_Records_SQL)
--==========================================================================================================

DROP TABLE #TempTable


GO