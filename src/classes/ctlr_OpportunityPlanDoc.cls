public with sharing class ctlr_OpportunityPlanDoc {
	//class variables
	public Opportunity_Strategy__c strategy						{get; set;}
	public Opportunity opp										{get; set;}
	public List<Opportunity_Competitive_Analysis__c> compList	{get; set;}
	public List<Opportunity_Contact_Role__c> ocrList			{get; set;}
	public decimal csatScore									{get; set;}
	public String csatYear										{get; set;}
	public List<OpportunityLineItem> oliList					{get; set;}
	public String total											{get; set;}
	public String exchangeTotal									{get; set;}
	public Revenue_Sales_Pipeline__c rsp						{get; set;}
	public String asOfDate										{get; set;}
	public String financialYear									{get; set;}
	public String quarter										{get; set;}
	public integer prevYear										{get; set;}
	public integer prevPrevYear									{get; set;}
	public List<Opportunity> winList							{get; set;}
    public List<Opportunity> openList							{get; set;}
    public Annual_Account_Plan__c clientPlan					{get; set;}
    public String cpYear										{get; set;}
    public Consulting_Service_Provider__c consultingSP          {get; set;}
    public Core_Service_Providers__c outsourcingSP              {get; set;}
    public Point_Solution_Providers__c pointSolutionsSP         {get; set;}
    //public double totalAssesssment								{get; set;}
    public List<Event> allEvents								{get; set;}
	
	/* constructor */
    public ctlr_OpportunityPlanDoc(ApexPages.StandardController controller) {
    	opp = (Opportunity)controller.getRecord();
    	//Read all fieldNames for Opportunity object
        Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Opportunity.fields.getMap();
        
        //Create a SOQL string with all fields
        String fieldNames = 'Account.Legal_Name__c,Sourcing_Provider__r.Name,Owner.Name,Account.Aon_Hewitt_Executive_Sponsor__r.Name,';
        fieldNames += 'Account.Overall_Relationship_Status__c,(Select Id from Opportunities__r),Account.Owner.Name,Current_Provider_Reference__r.Name';
        for(String fieldName : schemaFieldMap.keySet()) {
        	fieldNames += ',' + fieldName;
        }
        String soql = 'Select ' + fieldNames + ' From Opportunity Where Id = \'' + opp.Id + '\'';
        
        //Read all fields of the Opportunity
        opp = Database.query(soql);
        
        //Opp Worknotes newlines
        opp.Description = opp.Description != null ? opp.Description.replaceAll('\n', '<br>') : '';

        //Read Client Satisfaction Data
        List<Client_Satisfaction_Data__c> csdList = [Select Year__c, Overall_Satisfaction__c From Client_Satisfaction_Data__c Where Account__c = :opp.AccountId Order By CreatedDate Desc];
        if (!csdList.isEmpty()) {
        	csatScore = csdList[0].Overall_Satisfaction__c;
        	csatYear = csdList[0].Year__c;
        }
        
        //Read all fields for Opp Strategy object
        schemaFieldMap = Schema.SObjectType.Opportunity_Strategy__c.fields.getMap();
        fieldNames = '';
        for(String fieldName : schemaFieldMap.keySet()) {
        	fieldNames += ',' + fieldName;
        }
        fieldNames = fieldNames.substring(1);
        soql = 'Select ' + fieldNames + ' From Opportunity_Strategy__c Where Related_Opportunity__c = \'' + opp.Id + '\'';
        strategy = Database.query(soql);
        
        //Handle Newlines
        strategy.Solutions__c = strategy.Solutions__c != null ? strategy.Solutions__c.replaceAll('\n', '<br>') : '';
        strategy.Situation__c = strategy.Situation__c != null ? strategy.Situation__c.replaceAll('\n', '<br>') : '';
        strategy.Opportunity__c = strategy.Opportunity__c != null ? strategy.Opportunity__c.replaceAll('\n', '<br>') : '';
        strategy.Walls__c = strategy.Walls__c != null ? strategy.Walls__c.replaceAll('\n', '<br>') : '';
        strategy.Value_Proposition__c = strategy.Value_Proposition__c != null ? strategy.Value_Proposition__c.replaceAll('\n', '<br>') : '';
        strategy.Elevator_Message__c = strategy.Elevator_Message__c != null ? strategy.Elevator_Message__c.replaceAll('\n', '<br>') : '';
        strategy.Steps_to_Win_This_Deal__c = strategy.Steps_to_Win_This_Deal__c != null ? strategy.Steps_to_Win_This_Deal__c.replaceAll('\n', '<br>') : '';
        strategy.Close_This_Deal__c = strategy.Close_This_Deal__c != null ? strategy.Close_This_Deal__c.replaceAll('\n', '<br>') : '';
        strategy.Burning_Platform_Comments__c = strategy.Burning_Platform_Comments__c != null ? strategy.Burning_Platform_Comments__c.replaceAll('\n', '<br>') : '';
        strategy.Relationship_Comments__c = strategy.Relationship_Comments__c != null ? strategy.Relationship_Comments__c.replaceAll('\n', '<br>') : '';
        strategy.Active_Opportunities_Comments__c = strategy.Active_Opportunities_Comments__c != null ? strategy.Active_Opportunities_Comments__c.replaceAll('\n', '<br>') : '';
        strategy.Decision_Making_Process_Comments__c = strategy.Decision_Making_Process_Comments__c != null ? strategy.Decision_Making_Process_Comments__c.replaceAll('\n', '<br>') : '';
        strategy.Solution_Fit_Comments__c = strategy.Solution_Fit_Comments__c != null ? strategy.Solution_Fit_Comments__c.replaceAll('\n', '<br>') : '';
        strategy.Qualifications_References_Comments__c = strategy.Qualifications_References_Comments__c != null ? strategy.Qualifications_References_Comments__c.replaceAll('\n', '<br>') : '';
        strategy.Revenue_Growth_Comments__c = strategy.Revenue_Growth_Comments__c != null ? strategy.Revenue_Growth_Comments__c.replaceAll('\n', '<br>') : '';
        strategy.Firm_Leverage_Comments__c = strategy.Firm_Leverage_Comments__c != null ? strategy.Firm_Leverage_Comments__c.replaceAll('\n', '<br>') : '';
        strategy.Financial_Factors_Comments__c = strategy.Financial_Factors_Comments__c != null ? strategy.Financial_Factors_Comments__c.replaceAll('\n', '<br>') : '';
        strategy.Risk_Factors_Comments__c = strategy.Risk_Factors_Comments__c != null ? strategy.Risk_Factors_Comments__c.replaceAll('\n', '<br>') : '';
        strategy.Competition_Comments__c = strategy.Competition_Comments__c != null ? strategy.Competition_Comments__c.replaceAll('\n', '<br>') : '';
        strategy.Form_of_Contract_Client__c = strategy.Form_of_Contract_Client__c != null ? strategy.Form_of_Contract_Client__c.replaceAll('\n', '<br>') : '';
        strategy.Form_of_Contract_Aon_Hewitt__c = strategy.Form_of_Contract_Aon_Hewitt__c != null ? strategy.Form_of_Contract_Aon_Hewitt__c.replaceAll('\n', '<br>') : '';
        strategy.Term_for_Convenience_Aon_Hewitt__c = strategy.Term_for_Convenience_Aon_Hewitt__c != null ? strategy.Term_for_Convenience_Aon_Hewitt__c.replaceAll('\n', '<br>') : '';
        strategy.Term_for_Convenience_Client__c = strategy.Term_for_Convenience_Client__c != null ? strategy.Term_for_Convenience_Client__c.replaceAll('\n', '<br>') : '';
        strategy.Liability_Cap_Aon_Hewitt__c = strategy.Liability_Cap_Aon_Hewitt__c != null ? strategy.Liability_Cap_Aon_Hewitt__c.replaceAll('\n', '<br>') : '';
        strategy.Liability_Cap_Client__c = strategy.Liability_Cap_Client__c != null ? strategy.Liability_Cap_Client__c.replaceAll('\n', '<br>') : '';
        strategy.Fee_Escalator_Aon_Hewitt__c = strategy.Fee_Escalator_Aon_Hewitt__c != null ? strategy.Fee_Escalator_Aon_Hewitt__c.replaceAll('\n', '<br>') : '';
        strategy.Fee_Escalator_Client__c = strategy.Fee_Escalator_Client__c != null ? strategy.Fee_Escalator_Client__c.replaceAll('\n', '<br>') : '';
        strategy.Service_Levels_Aon_Hewitt__c = strategy.Service_Levels_Aon_Hewitt__c != null ? strategy.Service_Levels_Aon_Hewitt__c.replaceAll('\n', '<br>') : '';
        strategy.Service_Levels_Client__c = strategy.Service_Levels_Client__c != null ? strategy.Service_Levels_Client__c.replaceAll('\n', '<br>') : '';
        strategy.Payment_Terms_Aon_Hewitt__c = strategy.Payment_Terms_Aon_Hewitt__c != null ? strategy.Payment_Terms_Aon_Hewitt__c.replaceAll('\n', '<br>') : '';
        strategy.Payment_Terms_Client__c = strategy.Payment_Terms_Client__c != null ? strategy.Payment_Terms_Client__c.replaceAll('\n', '<br>') : '';
        strategy.Required_Decision_Date_Aon_Hewitt__c = strategy.Required_Decision_Date_Aon_Hewitt__c != null ? strategy.Required_Decision_Date_Aon_Hewitt__c.replaceAll('\n', '<br>') : '';
        strategy.Required_Decision_Date_Client__c = strategy.Required_Decision_Date_Client__c != null ? strategy.Required_Decision_Date_Client__c.replaceAll('\n', '<br>') : '';
        strategy.Other_Key_Terms_Aon_Hewitt__c = strategy.Other_Key_Terms_Aon_Hewitt__c != null ? strategy.Other_Key_Terms_Aon_Hewitt__c.replaceAll('\n', '<br>') : '';
        strategy.Other_Key_Terms_Client__c = strategy.Other_Key_Terms_Client__c != null ? strategy.Other_Key_Terms_Client__c.replaceAll('\n', '<br>') : '';
        strategy.Business_Case_Comments__c = strategy.Business_Case_Comments__c != null ? strategy.Business_Case_Comments__c.replaceAll('\n', '<br>') : '';
        strategy.Champion_Comments__c = strategy.Champion_Comments__c != null ? strategy.Champion_Comments__c.replaceAll('\n', '<br>') : '';
        strategy.Executive_Alignment_Comments__c = strategy.Executive_Alignment_Comments__c != null ? strategy.Executive_Alignment_Comments__c.replaceAll('\n', '<br>') : '';
        strategy.Philosophical_Fit_Comments__c = strategy.Philosophical_Fit_Comments__c != null ? strategy.Philosophical_Fit_Comments__c.replaceAll('\n', '<br>') : '';
        strategy.Rate_Target__c = strategy.Rate_Target__c != null ? strategy.Rate_Target__c.replaceAll('\n', '<br>') : '';
        strategy.Rate_Actual__c = strategy.Rate_Actual__c != null ? strategy.Rate_Actual__c.replaceAll('\n', '<br>') : '';
        strategy.Carrier_Action__c = strategy.Carrier_Action__c != null ? strategy.Carrier_Action__c.replaceAll('\n', '<br>') : '';
        strategy.Next_Steps__c = strategy.Next_Steps__c != null ? strategy.Next_Steps__c.replaceAll('\n', '<br>') : '';
        
        //Set total score & String
        //this.totalAssesssment = strategy.Total__c + strategy.Total_2__c;
        If (strategy.Total__c <= 5) total = 'weak';
        else if (strategy.Total__c <= 8) total = 'average';
        else if (strategy.Total__c > 8) total = 'strong';
        
        If (strategy.Total_2__c <= 3) exchangeTotal = 'weak';
        else if (strategy.Total_2__c <= 6) exchangeTotal = 'average';
        else if (strategy.Total_2__c > 6) exchangeTotal = 'strong';
        
        //Read all fields of all products tied to this opp
        schemaFieldMap = Schema.SObjectType.OpportunityLineItem.fields.getMap();
        fieldNames = 'PriceBookEntry.Product2.Name';
        for(String fieldName : schemaFieldMap.keySet()) {
        	fieldNames += ',' + fieldName;
        }
        //fieldNames = fieldNames.substring(1);
        soql = 'Select ' + fieldNames + ' From OpportunityLineItem Where OpportunityId = \'' + opp.Id + '\'';
        oliList = Database.query(soql);
        
        //Read Bundled Opp Ids
        List<Id> bundledOppIds = new List<Id> ();
        for (Opportunity bundledOpp : opp.Opportunities__r) {
        	bundledOppIds.add(bundledOpp.Id);
        }
        
        //Read Product data for bundled Opps
        soql = 'Select ' + fieldNames + ' From OpportunityLineItem Where OpportunityId in :bundledOppIds';
        List<OpportunityLineItem> bundledOlis = Database.query(soql);
        for (OpportunityLineItem oli : bundledOlis) {
        	oliList.add(oli);
        } 
       
       	//Set Contact List
    	ocrList = [Select Contact__r.Name, Contact__r.Functional_Role__c, Role__c, Comments__c From Opportunity_Contact_Role__c Where Opportunity__c = :opp.Id Order By Contact__r.Name];
    	
    	//handle newlines
    	for (Opportunity_Contact_Role__c ocr : ocrList) {
    		ocr.Comments__c = ocr.Comments__c != null ? ocr.Comments__c.replaceAll('\n', '<br>') : '';
    	}
    	
    	//Read Revenue Data
        schemaFieldMap = Schema.SObjectType.Revenue_Sales_Pipeline__c.fields.getMap();
        
        //Create a SOQL string with all fields
        fieldNames = '';
        for(String fieldName : schemaFieldMap.keySet()) {
        	fieldNames += ',' + fieldName;
        }
        fieldNames = fieldNames.substring(1);
        soql = 'Select ' + fieldNames + ' From Revenue_Sales_Pipeline__c Where Account__c = \'' + opp.AccountId + '\' Order By CreatedDate Desc';
        
        //Query
        List<Revenue_Sales_Pipeline__c> rspList = Database.query(soql);
        
        //Assign Revenue Record
        rsp = new Revenue_Sales_Pipeline__c();
        financialYear = '';
        quarter = '';
        prevYear = 0;
        prevPrevYear = 0;
        asOfDate = '';
        if (rspList.size() > 0) {
        	rsp = rspList[0];
        	this.financialYear = rsp.Year__c;
        	this.quarter = rsp.Quarter__c;
        	this.prevYear=integer.valueof(financialYear);
        	prevYear = prevYear - 1;
        	prevPrevYear = prevYear - 1;
        	if (quarter.equalsIgnoreCase('Q1')) { asOfDate = '31-March-' + financialYear; }
        	else if (quarter.equalsIgnoreCase('Q2')) { asOfDate = '30-June-' + financialYear; }
        	else if (quarter.equalsIgnoreCase('Q3')) { asOfDate = '30-September-' + financialYear; }
        	else if (quarter.equalsIgnoreCase('Q4')) { asOfDate = '31-December-' + financialYear; }
        }
        
        //Pull Won Opps
       	winList = [Select Name, StageName, Total_First_Year_Value__c, Current_Provider_Reference__r.Name, LOI_Contract_Date__c From Opportunity 
       		Where AccountId = :opp.AccountId And IsWon = True And LOI_Contract_Date__c = LAST_N_DAYS:365 Order By Total_First_Year_Value__c Desc Limit 5];
       			
       	//Pull open Opps
       	openList = [Select Name, StageName, Total_First_Year_Value__c, Probability, CloseDate From Opportunity 
       		Where AccountId = :opp.AccountId And (IsClosed = False Or (StageName = 'Closed Won' And LOI_Contract_Date__c = null)) Order By Total_First_Year_Value__c Desc Limit 5];
       	
       	//Pull Client Plan
        schemaFieldMap = Schema.SObjectType.Annual_Account_Plan__c.fields.getMap();
        fieldNames = '';
        for(String fieldName : schemaFieldMap.keySet()) {
        	fieldNames += ',' + fieldName;
        }
        fieldNames = fieldNames.substring(1);
        soql = 'Select ' + fieldNames + ' From Annual_Account_Plan__c Where Account__c = \'' + opp.AccountId + '\' Order By CreatedDate Desc';
        
        //Query
        List<Annual_Account_Plan__c> cpList = Database.query(soql);
        
        //Assign CP
        clientPlan = new Annual_Account_Plan__c();
        cpYear = '';
        System.debug('CPA Client Plan List Size: ' + cpList.size());
        if (cpList.size() > 0) {
        	clientPlan = cpList[0];
        	cpYear = clientPlan.Account_Plan_Year__c;
        	
        	//handle newlines
        	clientPlan.Opportunities_Renewal_Date_Comments__c = clientPlan.Opportunities_Renewal_Date_Comments__c != null ? clientPlan.Opportunities_Renewal_Date_Comments__c.replaceAll('\n', '<br>') : '';
        	clientPlan.Existing_Renewal_Date_Comments__c = clientPlan.Existing_Renewal_Date_Comments__c != null ? clientPlan.Existing_Renewal_Date_Comments__c.replaceAll('\n', '<br>') : '';
        }
        
        //Set Competitor list
    	compList = [Select Competitor__c, Strength__c, Weakness__c, Client_View__c, Estimated_Fees__c from Opportunity_Competitive_Analysis__c 
    		Where Opportunity__c = :opp.Id Order By Competitor__c];
    		
    	//Handle newlines
    	for (Opportunity_Competitive_Analysis__c oca : compList) {
    		oca.Strength__c = oca.Strength__c != null ? oca.Strength__c.replaceAll('\n', '<br>') : '';
    		oca.Weakness__c = oca.Weakness__c != null ? oca.Weakness__c.replaceAll('\n', '<br>') : '';
    		oca.Client_View__c = oca.Client_View__c != null ? oca.Client_View__c.replaceAll('\n', '<br>') : '';
    		oca.Estimated_Fees__c = oca.Estimated_Fees__c != null ? oca.Estimated_Fees__c.replaceAll('\n', '<br>') : '';
    	}
    	
    	//Read Consulting Service Provider Data
        consultingSP = [Select Actuary_Pension_Company__r.Name,Health_Welfare_Consulting__r.Name,Communication_Consulting__r.Name,Executive_Compensation_Mgmt_Consultant__r.Name,
            Global_Benefits_Consulting_Broker__r.Name,HR_M_A_Consulting__r.Name,Retirement_Consultant__r.Name,Broadbased_Compensation_Consultant__r.Name,
            Actuary_Pension_Contract_End_Date__c,Reward__r.Name,FLEX_Benefits__r.Name, Investment__r.Name, Investment_Consultant__r.Name,
            Covenant_Assessment_Advisors__r.Name, Covenant_Assess_Advisors_Contract_End_Dt__c, Retirement_Consultant_DC__r.Name,Global_Actuary__r.Name,
            Global_Accounting__r.Name, International_Retirement_Consulting__r.Name from Consulting_Service_Provider__c
            Where Account__c = :opp.AccountId Limit 1];

        //Read Outsourcing Service Provider Data
        schemaFieldMap = Schema.SObjectType.Core_Service_Providers__c.fields.getMap();
        
        //Create a SOQL string with all fields
        fieldNames = '';
        for(String fieldName : schemaFieldMap.keySet()) {
            fieldNames += ',' + fieldName;
        }
        fieldNames += ',Defined_Benefit_Administrator__r.Name,Defined_Contribution_Administrator__r.Name,Health_Welfare_Administrator__r.Name,';
        fieldNames += 'BPO_HR__r.Name,Payroll__r.Name,Pension_Payroll__r.Name,Recruiting_and_Staffing_Administrator__r.Name,';
        fieldNames += 'Retiree_Medical_Exchange__r.Name,Bundled_Services__r.Name,Flex_Administration__r.Name';
        fieldNames = fieldNames.substring(1);
        soql = 'Select ' + fieldNames + ' From Core_Service_Providers__c Where Account__c = \'' + opp.AccountId + '\' Limit 1';
        
        //Query
        outsourcingSP = Database.query(soql);
        
        //Read Point Solutions Provider Data
        schemaFieldMap = Schema.SObjectType.Point_Solution_Providers__c.fields.getMap();
        
        //Create a SOQL string with all fields
        fieldNames = '';
        for(String fieldName : schemaFieldMap.keySet()) {
            fieldNames += ',' + fieldName;
        }
        fieldNames += ',Advocacy_Services__r.Name,Dependent_Audit_Services__r.Name,Spending_Accounts_FSA__r.Name,Total_Rewards_Solution__r.Name';
        fieldNames = fieldNames.substring(1);
        soql = 'Select ' + fieldNames + ' From Point_Solution_Providers__c Where Account__c = \'' + opp.AccountId + '\' Limit 1';
        
        //Query
        pointSolutionsSP = Database.query(soql);
        
        //Read Events
        allEvents = [Select Owner.Name, ActivityDate, Subject, Type, Description From Event Where WhatId = :opp.Id Order By ActivityDate];
        for (Event evt : allEvents) {
        	evt.Description = evt.Description != null ? evt.Description.replaceAll('\n', '<br>') : '';
        }
    } //constructor
}