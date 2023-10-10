CREATE PROC [EXTRACT_MDATA].[USP_EDL_MDATA_ALLOCATIONS_DynOutFinalisedAllocOrd] AS
	SELECT DISTINCT 
		 T1.met_eventsequenceid AS EventID
		,T2.met_itemnumber AS ItemCode
		,T2.met_customernumber AS CustomerID
		,CASE WHEN T2.met_confirmedorderquantity <= 0 OR  T2.met_confirmedorderquantity is NULL THEN 0
			  WHEN T2.met_confirmedorderquantity >= 99999 THEN 99999 
			  ELSE T2.met_confirmedorderquantity END AS  OrderQty
    FROM EDL_MDATA.met_event T1 
    INNER JOIN EDL_MDATA.met_allocationquantityattachment T2 
        ON T1.met_eventid = T2.met_eventid
    WHERE T1.Is_Current_Flag=1 
        AND T1.Is_Delete_Flag=0
        AND T2.Is_Current_Flag=1 
        AND T2.Is_Delete_Flag=0
    ORDER BY T1.met_eventsequenceid ASC
GO
