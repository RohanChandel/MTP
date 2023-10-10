CREATE PROC EXTRACT_MDATA.USP_EDL_MDATA_ALLOCATIONS_DynOutPubAlloc AS
	WITH met_event_eventorderreleasedate_CTE AS
	(
		SELECT
			  met_event.met_eventid AS met_eventid
			, met_event.met_eventsequenceid AS met_eventsequenceid
			, met_event.met_EventProductCodeNumber AS met_EventProductCodeNumber
			, met_event.met_allocationnotes AS met_allocationnotes
			, met_event.met_portaleffectivedate AS met_portaleffectivedate
			, met_event.met_remoteconfirmdate AS met_remoteconfirmdate
			, met_event.met_eventtypeidname AS met_eventtypeidname
			, met_event.met_description AS met_description
			, met_eventorderreleasedate.met_customerorderreleasedate AS met_customerorderreleasedate
			, DENSE_RANK() OVER (PARTITION by met_event.met_eventid ORDER BY met_event.modifiedon desc) as Rank -- Getting the latest event id record
		FROM EDL_MDATA.met_event as met_event
		left join  EDL_MDATA.met_eventorderreleasedate as met_eventorderreleasedate 
			on met_event.met_eventid =met_eventorderreleasedate.met_eventid 
		WHERE met_event.Is_Current_Flag = 1 
			and met_eventorderreleasedate.Is_Current_Flag = 1
	)



	SELECT DISTINCT
		RelDate.met_eventsequenceid AS [Event ID]
		, RelDate.met_EventProductCodeNumber AS [Event Item Code]
		, REPLACE(REPLACE(RelDate.met_allocationnotes,CHAR(13),''),CHAR(10),'') AS [Allocation Notes]
		, FORMAT(RelDate.met_portaleffectivedate,'dd/MM/yyyy') AS [Publish Date]
		, FORMAT(RelDate.met_remoteconfirmdate,'dd/MM/yyyy') AS [Confirm Date]
		, RelDate.met_eventtypeidname AS [Event Type]
		, REPLACE(REPLACE(RelDate.met_description,CHAR(13),''),CHAR(10),'') AS [Event Name]

		, FORMAT(RelDate.met_customerorderreleasedate,'dd/MM/yyyy') AS [Release Date]

		, Quant.met_customernumber AS [Customer ID]
		, Quant.met_itemnumber AS [Item Code]
		, Quant.met_hasautoapproval AS [AutoApprove]
		, Quant.met_packsize AS [Pack]
		, REPLACE(REPLACE(Quant.met_itemdescription,CHAR(13),''),CHAR(10),'') AS [Product Description]
		, CASE WHEN Quant.met_allocationquantity <= 0 OR  Quant.met_allocationquantity is NULL THEN 0
		  	   WHEN Quant.met_allocationquantity >= 99999 THEN 99999 
		  	   ELSE Quant.met_allocationquantity
		  END AS [Allocation Qty]
		, CASE WHEN Quant.met_minqtycustomercanupdate <= 0 OR Quant.met_minqtycustomercanupdate is NULL THEN 0
		  	   WHEN Quant.met_minqtycustomercanupdate >= 99999 THEN 99999 
		  	   ELSE Quant.met_minqtycustomercanupdate
		  END AS [Min Qty Customer Can Update]
		, CASE WHEN Quant.met_maxqtycustomercanupdate <= 0 OR Quant.met_maxqtycustomercanupdate is NULL THEN 0
		  	   WHEN Quant.met_maxqtycustomercanupdate >= 99999 THEN 99999 
		  	   ELSE Quant.met_maxqtycustomercanupdate
		  END AS [Max Qty Customer Can Update]

		, CASE WHEN DiscLine.met_discountedprice <= 0 OR DiscLine.met_discountedprice is NULL THEN 0
		  	   WHEN DiscLine.met_discountedprice >= 99999 THEN 99999 
		  	   ELSE DiscLine.met_discountedprice
		  END AS [Promo WSL Cost]
		, CASE WHEN DiscLine.met_cashdiscountamount <= 0 OR DiscLine.met_cashdiscountamount is NULL THEN 0
		  	   WHEN DiscLine.met_cashdiscountamount >= 99999 THEN 99999 
		  	   ELSE DiscLine.met_cashdiscountamount
		  END AS [Deal Amount]
		, /*CASE WHEN DiscLine.met_total_price <= 0 OR DiscLine.met_total_price is NULL THEN 0
		  	   WHEN DiscLine.met_total_price >= 99999 THEN 99999 
		  	   ELSE DiscLine.met_total_price
		  END*/ 
		  0 AS TotalPrice -- DiscLine.met_total_price is not available
		, /*CASE WHEN DiscLine.met_promo_unit_cost <= 0 OR DiscLine.met_promo_unit_cost is NULL THEN 0
		  	   WHEN DiscLine.met_promo_unit_cost >= 99999 THEN 99999 
		  	   ELSE DiscLine.met_promo_unit_cost
		  END */ 
		  0 AS PromoUnitCost -- DiscLine.met_promo_unit_cost is not available
		, '' AS [PSRP]
		, '' AS [GP]
		, Quant.met_amendmenttype AS [Amendment Type]
		, ItemMat.UNITOFMEASURE AS [Unit Type]
	FROM met_event_eventorderreleasedate_CTE AS RelDate
	LEFT JOIN EDL_MDATA.met_allocationquantityattachment Quant	
		ON RelDate.met_eventid = Quant.met_eventid
			AND Quant.Is_Current_Flag = 1
	LEFT JOIN EDL_MDATA.met_discount		AS Disc				
		ON RelDate.met_eventid = Disc.met_eventid
			AND Disc.Is_Current_Flag = 1
	LEFT JOIN EDL_MDATA.met_discountline	AS DiscLine			
		ON Disc.met_discountid = DiscLine.met_relateddiscountid
			AND DiscLine.Is_Current_Flag = 1
	LEFT JOIN EDL_D365.HMIMItemMaterial		AS ItemMat			
		ON ItemMat.ITEMID = Quant.met_itemnumber
			AND ItemMat.Is_Current_Flag = 1
	WHERE RelDate.RANK = 1 
	ORDER BY RelDate.met_eventsequenceid ASC