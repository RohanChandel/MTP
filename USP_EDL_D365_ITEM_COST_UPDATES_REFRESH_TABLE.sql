CREATE PROC [EXTRACT_MDATA].[USP_EDL_D365_ITEM_COST_UPDATES_REFRESH_TABLE] @PIPELINETRIGGERTIME [DATETIME] AS

-- FOR UPDATES
BEGIN
  UPDATE [EXTRACT_MDATA].[EDL_D365_ITEM_COST_UPDATES]
  SET ItemNumber               = SOURCE.ItemNumber,
      ACTIONCODE                = 'C',
      WarehouseId               = SOURCE.WarehouseId,
      ProformaCost            = SOURCE.ProformaCost,
  	  ActualCost                = SOURCE.ActualCost,
      POListForPIM                 = SOURCE.POListForPIM,
	    ActMktSpreadCalcCode               = SOURCE.ActMktSpreadCalcCode,
      ActMktSpreadCalcRate               = SOURCE.ActMktSpreadCalcRate,
      --ENDOFRECORD               = SOURCE.ENDOFRECORD, 
      REC_HASH                  = SOURCE.REC_HASH,
      UPDATED_DT                = @PIPELINETRIGGERTIME
	
  FROM       [EXTRACT_MDATA].[V_EDL_D365_ITEM_COST_UPDATES] SOURCE
  INNER JOIN [EXTRACT_MDATA].[EDL_D365_ITEM_COST_UPDATES] TARGET
  ON         SOURCE.ItemNumber = TARGET.ItemNumber 
  AND        SOURCE.WarehouseId = TARGET.WarehouseId 
  --AND        SOURCE.REASONCODE=TARGET.REASONCODE
  --AND        SOURCE.CUSTACCOUNT=TARGET.CUSTACCOUNT
  --AND        SOURCE.CLAIMSTATUS = TARGET.CLAIMSTATUS
  WHERE      ( TARGET.REC_HASH IS NULL 
              OR SOURCE.REC_HASH <> TARGET.REC_HASH
             )
  AND        SOURCE.IS_DELETE_FLAG = 0
END

--FOR INSERTION
BEGIN
    INSERT INTO [EXTRACT_MDATA].[EDL_D365_ITEM_COST_UPDATES]
    SELECT ItemNumber,
      WarehouseId,
      ProformaCost,
  	  ActualCost,
      POListForPIM,
	    ActMktSpreadCalcCode,
     	ActMktSpreadCalcRate,   
      REC_HASH,
      'A' AS ACTIONCODE,
      @PIPELINETRIGGERTIME AS  CREATED_DT,		                
      @PIPELINETRIGGERTIME AS UPDATED_DT
    FROM  [EXTRACT_MDATA].[V_EDL_D365_ITEM_COST_UPDATES]
    WHERE CONCAT(ItemNumber, WarehouseId) 
          NOT IN ( SELECT CONCAT(ItemNumber, WarehouseId) 
                   FROM [EXTRACT_MDATA].[EDL_D365_ITEM_COST_UPDATES]
                 )
END

-- FOR DELETION
BEGIN
    UPDATE [EXTRACT_MDATA].[EDL_D365_ITEM_COST_UPDATES]
    SET
               ACTIONCODE    ='D',
               UPDATED_DT = @PIPELINETRIGGERTIME
    FROM       [EXTRACT_MDATA].[V_EDL_D365_ITEM_COST_UPDATES] SOURCE
    INNER JOIN [EXTRACT_MDATA].[EDL_D365_ITEM_COST_UPDATES] TARGET
        ON         SOURCE.ItemNumber = TARGET.ItemNumber 
        AND        SOURCE.WarehouseId = TARGET.WarehouseId 
        --AND        SOURCE.REASONCODE = TARGET.REASONCODE
        --AND        SOURCE.CUSTACCOUNT = TARGET.CUSTACCOUNT
        --AND        SOURCE.CLAIMSTATUS = TARGET.CLAIMSTATUS
    WHERE      TARGET.ACTIONCODE <>'D' 
        AND    SOURCE.IS_DELETE_FLAG = 1
END