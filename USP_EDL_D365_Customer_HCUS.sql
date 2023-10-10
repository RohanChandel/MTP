CREATE PROC [EXTRACT_MDATA].[USP_EDL_D365_Customer_HCUS] @FullLoad [bit],@Batch_Run_Datetime [DATETIME2],@FileGenerationGroup [varchar](10) AS

BEGIN
	
	WITH HEADER_RECORD AS
	(
		SELECT
		'80'              AS RECTYPE,
		'81'              AS DATATYPE,
		CASE WHEN @FullLoad = 1 THEN 'R' ELSE 'U' END AS LOADTYPE,
		'S'               AS LOADSCOPE,
		LEFT(@FileGenerationGroup+REPLICATE(' ',6),6) AS SCOPEKEY,
		LEFT(CONCAT('PR01A6',' ',format(GETDATE(),'dd/MM/yyyy HH:MM'))+REPLICATE(' ',100),100)  AS RUNTIME
	)											
	, DETAIL_RECORD AS (
		SELECT
			81																AS Record_Type
			,METINDUSTRYKEY													AS Business_Pillar
			,WAREHOUSEID													AS Location
			,RIGHT(REPLICATE('0',10)+[CUSTOMERACCOUNT],10)					AS Customer_Code
			,CASE WHEN @FullLoad = 1 THEN ' ' 
				WHEN ACTION_CODE = 'M' THEN 'C'
				ELSE ACTION_CODE 
				END															AS Action_Code
			,[CREDMANACCOUNTSTATUSID]										AS Status
			,WAREHOUSEID													AS Warehouse
			,LEFT(ISNULL(METCUSTOPERGROUPID,' ')+REPLICATE(' ',5),5)		AS Customer_Group
			,LEFT(ISNULL(METCUSTOPERGROUPID,' ')+REPLICATE(' ',10),10)		AS Order_Guide
			,LEFT(ISNULL([ORGANIZATIONNAME],' ')+REPLICATE(' ',30),30)		AS Business_Name
			,LEFT(ISNULL([BusinessAddressStreet],' ')+REPLICATE(' ',25),25) AS BusinessAddressStreet
			,LEFT(ISNULL([BusinessAddressCity],' ')+REPLICATE(' ',15),15)	AS BusinessAddressCity
			,LEFT(ISNULL([BusinessAddressState],' ')+REPLICATE(' ',3),3)	AS BusinessAddressState
			,LEFT(ISNULL([BusinessAddressZipCode],' ')+REPLICATE(' ',10),10)		AS BusinessAddressZipCode
			,RIGHT(REPLICATE('0',3)+ISNULL(TRIM(REPLACE(BusinessPhoneCountryRegionCode,'+','')),0),3)	AS Phone_Area_Code
			,RIGHT(REPLICATE('0',10)+ISNULL(TRIM(REPLACE(BusinessPhone,'+','')),0),10)					AS Phone
			,RIGHT(REPLICATE('0',3)+ISNULL(TRIM(REPLACE(BusinessFaxCountryRegionCode,'+','')),0),3)		AS Fax_Area_Code
			,RIGHT(REPLICATE('0',10)+ISNULL(TRIM(REPLACE(BusinessFax,'+','')),0),10)					AS Fax
			,[LiquorLicenceNumberValid]										AS Liquor_Status
			,'A'															AS Cust_Type
			,LEFT(ISNULL([AgentOrSalesRepCode],' ')+REPLICATE(' ',6),6)		AS Agent_Or_SalesRep_Code
			,[AgentOrSalesRepType]											AS Agent_Or_SalesRep_Type
			,LEFT(ISNULL([TAXEXEMPTNUMBER],' ')+REPLICATE(' ',14),14)		AS ABN 
			,LEFT(ISNULL([InvoiceEmail],' ')+REPLICATE(' ',50),50)			AS InvoiceEmail
			,LEFT(ISNULL([METCSLEGALENTITY],' ')+REPLICATE(' ',40),40)		AS Business_Legal_Entity
			,LEFT(ISNULL([StoreOwnerFirstName],' ')+REPLICATE(' ',40),40)	AS Owners_Personal_First_Name
			,LEFT(ISNULL([StoreOwnerLastName],' ')+REPLICATE(' ',40),40)	AS Owners_Personal_Last_Name
			,RIGHT(REPLICATE('0',10)+ISNULL([StoreOwnerPhoneNumber],0),10)	AS Owners_Contact_Phone_Number
			,LEFT(ISNULL([REGISTRATIONNUMBER],' ')+REPLICATE(' ',11),11)	AS ACN
			,LEFT(ISNULL([InvoiceAddressStreet],' ')+REPLICATE(' ',25),25)  AS InvoiceAddressStreet
			,LEFT(ISNULL([InvoiceAddressCity],' ')+REPLICATE(' ',15),15)	AS InvoiceAddressCity
			,LEFT(ISNULL([InvoiceAddressState],' ')+REPLICATE(' ',3),3)		AS InvoiceAddressState
			,LEFT(ISNULL([InvoiceAddressZipCode],' ')+REPLICATE(' ',10),10) AS InvoiceAddressZipCode
			,LEFT(ISNULL([LineOfBusinessID],' ')+REPLICATE(' ',25),25)		AS Nature_of_Business
			,LEFT(ISNULL([LiquorLicenceNumber],' ')+REPLICATE(' ',15),15)	AS Liquor_Licence
			,[TobaccoLicenseNumberValid]									AS Tobacco_Status
			,LEFT(ISNULL([TobaccoLicenceNumber],' ')+REPLICATE(' ',15),15)  AS Tobacco_License
			,ISNULL(FORMAT([TobaccoLicenceExpiryDate], 'dd/MM/yyy'),REPLICATE(' ',10))					AS Tobacco_Expiry_Date
			,LEFT(ISNULL([MailBrochureFlag],' ')+REPLICATE(' ',25),25)		AS Mail_Brochure_Flag
			,LEFT(ISNULL([BusinessEmail],' ')+REPLICATE(' ',50),50)			AS AR_Email
			,LEFT(ISNULL([BusinessEmail],' ')+REPLICATE(' ',50),50)			AS Customer_Service_Email_Address
		FROM [EXTRACT_MDATA].[EDL_D365_Customer_HCUS]
		WHERE 
			IS_Current_Flag = 1
			AND ((@FullLoad = 0 AND batch_run_datetime >= @Batch_Run_Datetime) OR (@FullLoad = 1 AND ACTION_CODE <>'D'))
			AND FileGenerationGroup = @FileGenerationGroup
	)
	,FINAL_CTE AS (
		SELECT
			CONCAT(RECTYPE,'|',DATATYPE,'|',LOADTYPE,'|',LOADSCOPE,'|',SCOPEKEY,'|',RUNTIME,'|') AS DATA
			FROM HEADER_RECORD
			UNION ALL
			SELECT CONCAT(Record_Type
				,'|',Business_Pillar
				,'|',Location
				,'|',Customer_Code
				,'|',Action_Code
				,'|',Status
				,'|',Warehouse
				,'|',Customer_Group
				,'|',Order_Guide
				,'|',Business_Name
				,'|',BusinessAddressStreet
				,'|',BusinessAddressCity
				,'|',BusinessAddressState
				,'|',BusinessAddressZipCode
				,'|',Phone_Area_Code
				,'|',Phone
				,'|',Fax_Area_Code
				,'|',Fax
				,'|',Liquor_Status
				,'|',Cust_Type
				,'|',Agent_Or_SalesRep_Code
				,'|',Agent_Or_SalesRep_Type
				,'|',ABN
				,'|',InvoiceEmail
				,'|',Business_Legal_Entity
				,'|',Owners_Personal_First_Name
				,'|',Owners_Personal_Last_Name
				,'|',Owners_Contact_Phone_Number
				,'|',ACN
				,'|',InvoiceAddressStreet
				,'|',InvoiceAddressCity
				,'|',InvoiceAddressState
				,'|',InvoiceAddressZipCode
				,'|',Nature_of_Business
				,'|',Liquor_Licence
				,'|',Tobacco_Status
				,'|',Tobacco_License
				,'|',Tobacco_Expiry_Date
				,'|',Mail_Brochure_Flag
				,'|',AR_Email
				,'|',Customer_Service_Email_Address
				,'|'
				) AS DATA
			FROM DETAIL_RECORD

	)

SELECT * 
FROM FINAL_CTE	
ORDER BY 1
  
END
GO


