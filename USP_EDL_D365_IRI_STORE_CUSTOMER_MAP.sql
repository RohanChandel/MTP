CREATE PROC [EXTRACT_MDATA].[USP_EDL_D365_IRI_STORE_CUSTOMER_MAP] @FullLoad [bit],@Batch_Run_Datetime [DATETIME2],@FileGenerationGroup [varchar](100) AS

BEGIN

SELECT Hdc.Customer_Cd,
       Replace ( Hdc.Customer_Nm ,',',' ') New_Cust_Name,
       Hds.Address_Id,
       Replace( Hds.Recent_Store_Nm  ,',',' ') New_Store_Name,
       Hds.Administration_State_Cd,
       Case  
          When Hac.Channel_Report_Grp_Cd ='-'  
          Then Hds.Store_Channel_Cd  
          Else Hac.Channel_Report_Grp_Cd  
       End As  Mapped_Channel_Cd,
       Hds.Mso_Nm     As Baron_Dsc,
       Hac.Channel_Cd As Actual_Channel_Cd
From
       Edl.Hana_Dim_Customer  Hdc
       Inner Join
       Edl.Hana_Dim_Store  Hds
       On Hdc.Store_Sk =  Hds.Store_Sk
       Inner Join
       Edl.Hana_Dim_Channel  Hac
       On  Hds.Store_Channel_Cd  =  Hac.Channel_Cd
Where  Hdc.Bus_Pillar_Cd = 'IGA'
  And  Hdc.Eff_End_Dt = '31-dec-9999'
  And  Hdc.Store_Sk <> -1
  And  Hds.Active_Flag ='Y'
  END
GO