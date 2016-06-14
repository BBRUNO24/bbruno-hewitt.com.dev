/* Controller class for the Client Scorecard for APAC
 * Case 98847. October 28, 2013. Chintan */
public without sharing class ctlr_Client_Scorecard_APAC {
	//Class to store all the details needed to populate the Scorecard
    public class Scorecard {
        public String accountName                         	{get; set;}
        public String market                              	{get; set;}
        public String ownerName                           	{get; set;}
        public String executiveSponsor                    	{get; set;}
        public List<Internal_Account_Team__c> iatList     	{get; set;}
        public List<Client_Assessment_Survey__c> casList  	{get; set;}
        public List<Opportunity> winList					{get; set;}
        public List<Opportunity> openList					{get; set;}
        public List<Opportunity> lostList					{get; set;}
        public Map<String, String> cssMap					{get; set;}
    }
    
    private final Account account;
    public String financialYear 	{get; set;} //user selected parameter from selection panel
    public String quarter       	{get; set;} //user selected parameter from selection panel
    public Scorecard myScorecard	{get; set;} //used to store all data tied to the account that needs to be printed
    public integer prevYear			{get; set;} //Stores the value of the Previous Year
    public integer prevPrevYear		{get; set;}
    public integer rspListSize		{get; set;} //The size of rspList
    public integer casListSize		{get; set;} //The size of casList
    public decimal penetrationScore	{get; set;}	//The Penetration Score
    public String asOfDate			{get; set;} //the as of date to print on the Revenue table
    public String currYear			{get; set;} //The Current Year
    public integer score			{get; set;} //The Client Promise Score for the current year
    
    
    // Constructor
    public ctlr_Client_Scorecard_APAC(ApexPages.StandardController controller) {
        Account currAcct = (Account)controller.getRecord();
        this.account = [SELECT Legal_Name__c, Market__c, Owner.Name, Aon_Hewitt_Executive_Sponsor__c, Client_Promise_Required__c  FROM Account WHERE ID = :currAcct.ID];

        // Getting the selected financial year and quarter from the query string to populate the data on page
        this.financialYear = ApexPages.currentPage().getParameters().get('year');
        this.quarter = ApexPages.currentPage().getParameters().get('quarter');
        this.prevYear=integer.valueof(financialYear);
        prevYear = prevYear - 1;
        prevPrevYear = prevYear - 1;
        if (quarter.equalsIgnoreCase('Q1')) { asOfDate = 'March 31, ' + financialYear; }
        else if (quarter.equalsIgnoreCase('Q2')) { asOfDate = 'June 30, ' + financialYear; }
        else if (quarter.equalsIgnoreCase('Q3')) { asOfDate = 'September 30, ' + financialYear; }
        else if (quarter.equalsIgnoreCase('Q4')) { asOfDate = 'December 31, ' + financialYear; }
        
        //Look for a Client Plan record for the same Year
        currYear = String.valueOf(System.today().year());
        List<Annual_Account_Plan__c> planList = [Select  Client_Promise_Score__c From Annual_Account_Plan__c 
        		Where Account_Plan_Year__c = :currYear And Account__c = :account.Id Limit 1];
    	
    	//Read Client Promise Score
    	score = planList.size() > 0 ? Integer.valueOf(planList[0].Client_Promise_Score__c) : 0;
        
        //get data
        init();
    } //ctlr_Client_Scorecard_APAC
    
    
    //Initialize everything
    public void init() {
        System.Debug('CPA Invoking init with Year ' + financialYear + ' and Quarter ' + quarter);
        this.myScorecard = new Scorecard();
        myScorecard.accountName = this.account.Legal_Name__c;
        myScorecard.market = this.account.Market__c;
        myScorecard.ownerName = this.account.Owner.Name;
        List<contact> execSponsorList = [SELECT Name FROM Contact WHERE Id = :this.account.Aon_Hewitt_Executive_Sponsor__c];
        if (execSponsorList.size() > 0) {
        	myScorecard.executiveSponsor = execSponsorList[0].Name;
        }
        
        myScorecard.iatList = [SELECT Contact_Role__c, Contact__r.Name FROM Internal_Account_Team__c WHERE account__r.Id = :this.account.Id];
        
        //Get Client Satisfaction Survey data for this and previous year
        myScorecard.cssMap = new Map<String, String> ();
        String prevYearString = String.valueOf(prevYear);
        List<Client_Satisfaction_Survey__c >currYearCss = [SELECT Recommend_Aon_Hewitt_to_others__c, Overall_Satisfaction__c, Survey_Year__c FROM Client_Satisfaction_Survey__c 
        	WHERE account__r.Id = :account.Id AND Survey_Year__c = :financialYear Order By CreatedDate Desc];
        List<Client_Satisfaction_Survey__c >prevYearCss = [SELECT Recommend_Aon_Hewitt_to_others__c, Overall_Satisfaction__c, Survey_Year__c FROM Client_Satisfaction_Survey__c 
        	WHERE account__r.Id = :account.Id AND Survey_Year__c = :prevYearString Order By CreatedDate Desc];
        if (currYearCss.size() > 0) {
        	//Calculate avg score from all surveys for the year
        	Decimal avgScore = 0;
        	Decimal avgSat = 0;
        	
        	for (Client_Satisfaction_Survey__c css : currYearCss) {
        		avgScore += css.Recommend_Aon_Hewitt_to_others__c;
        		avgSat += css.Overall_Satisfaction__c;
        	}
        	
        	//Set decimal
        	avgScore = avgScore.divide(currYearCss.size(), 1);
        	avgSat = avgSat.divide(currYearCss.size(), 1);
        	
        	myScorecard.cssMap.put('CYlikelihood', String.valueOf(avgScore));
        	myScorecard.cssMap.put('CYsatisfaction', String.valueOf(avgSat));
        } else {
        	myScorecard.cssMap.put('CYlikelihood', 'N/A');
        	myScorecard.cssMap.put('CYsatisfaction', 'N/A');
        }
        if (prevYearCss.size() > 0) {
        	//Calculate avg score from all surveys for the year
        	Decimal avgScore = 0;
        	Decimal avgSat = 0;
        	
        	for (Client_Satisfaction_Survey__c css : prevYearCss) {
        		avgScore += css.Recommend_Aon_Hewitt_to_others__c;
        		avgSat += css.Overall_Satisfaction__c;
        	}
       	
        	//Set decimal
        	avgScore = avgScore.divide(prevYearCss.size(), 1);
        	avgSat = avgSat.divide(prevYearCss.size(), 1);
        	
        	myScorecard.cssMap.put('PYlikelihood',String.valueOf(avgScore));
        	myScorecard.cssMap.put('PYsatisfaction', String.valueOf(avgSat));
        } else {
        	myScorecard.cssMap.put('PYlikelihood', 'N/A');
        	myScorecard.cssMap.put('PYsatisfaction', 'N/A');
        }
        
        //Read all fields on Client_Assessment_Survey__c object
        Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Client_Assessment_Survey__c.fields.getMap();
        
        //Create a SOQL string with all fields
        String fieldNames = '';
        for(String fieldName : schemaFieldMap.keySet()) {
        	fieldNames += ',' + fieldName;
        }
        fieldNames = fieldNames.substring(1);
        String soql = 'Select ' + fieldNames + ' From Client_Assessment_Survey__c Where account__r.Id = \'' + account.Id + '\' AND Year__c = \'' + financialYear + '\' AND Quarter__c = \'' + quarter +'\'';
        
        //Read CAS data
        myScorecard.casList = Database.query(soql);
        this.casListSize = myScorecard.casList.size();
        integer notViableCount = 0;
        if (casListSize > 0) {
        	Client_Assessment_Survey__c myCas = myScorecard.casList[0];
        	//this.penetrationScore = myScorecard.casList[0].APAC_Penetration_Rating__c;
        	//Changing formula for Case 204141, Chintan, March 26, 2015
        	this.penetrationScore = myCas.APAC_Score_1__c + myCas.APAC_Score_2__c;
        	System.debug('CPA score 1: ' + myCas.APAC_Score_1__c);
        	System.debug('CPA score 2: ' + myCas.APAC_Score_2__c);
        	System.debug('CPA Calculation: ' + myCas.Retirement_Plan_Administration_Rating__c + '+' + myCas.Accounting_Services_Rating__c + '+' + myCas.Financial_Planning_Rating__c +'+' + myCas.Investment_Consulting_Rating__c  + '+' + myCas.Group_Insurance_Rating__c  + '+' + myCas.Corporate_Health_Rating__c  + '+' + myCas.Personal_Accident_Rating__c + '+' + myCas.Corporate_Travel_Rating__c + '+' + myCas.Expat_or_Non_Resident_Medical_Rating__c  + '+' + myCas.Life_Disability_Consulting_Rating__c  + '+' + myCas.Mergers_Acquisitions_Rating__c  + '+' + myCas.Global_Benefits_Rating__c  + '+' + myCas.Workers_Compensation_Rating__c + '+' + myCas.Workforce_Risk_Rating__c + '+' + myCas.Cornerstone_OnDemand_Services_Rating__c);
        	System.debug('CPA Cornerstone OnDemand Rating: ' + myCas.Cornerstone_OnDemand_Services_Rating__c);
        	System.debug('CPA Financial Planning Rating: ' + myCas.Financial_Planning_Rating__c);
        	System.debug('CPA Life Disability Rating: ' + myCas.Life_Disability_Consulting_Rating__c);
        	System.debug('CPA Accounting Services Rating: ' + myCas.Accounting_Services_Rating__c);
        	System.debug('CPA Corporate Travel Rating: ' + myCas.Corporate_Travel_Rating__c);
        	System.debug('CPA Expat or Non Resident Rating: ' + myCas.Expat_or_Non_Resident_Medical_Rating__c);
        	System.debug('CPA Workers Comp Rating: ' + myCas.Workers_Compensation_Rating__c);
        	
        	System.debug('CPA penetration total: ' + this.penetrationScore);
        	//Figure out what to divide this total by. We need to subtract two times the number of 'Not Viable' responses
   			for(String fieldName : schemaFieldMap.keySet()) {
   				Schema.DescribeFieldResult dfr = (schemaFieldMap.get(fieldName)).getDescribe(); 
   				if (dfr.getType() == Schema.Displaytype.Picklist) {
   					String value = (String)myCas.get(fieldName);
   					notViableCount = (value != null && value.equalsIgnoreCase('Not Viable')) ? notViableCount + 1 : notViableCount;
   				}
  			}
  			System.debug('CPA Final notViableCount is: ' + notViableCount);
  			this.penetrationScore = (notViableCount != 34) ? this.penetrationScore / (68 - (2 * notViableCount)) : 0;
  			this.penetrationScore *= 100;
  			System.debug('CPA Penetration Score is: ' + this.penetrationScore);
  			//System.debug('CPA final pentrationScore is: ' + this.penetrationScore);
        } else {
        	soql = 'Select ' + fieldNames + ' From Client_Assessment_Survey__c Where account__r.Id = \'' + account.Id + '\' AND Year__c = \'' + financialYear + '\' Order By CreatedDate Desc Limit 1';
        	myScorecard.casList = Database.query(soql);
        	this.casListSize = myScorecard.casList.size();
        	if (casListSize > 0) {
        		Client_Assessment_Survey__c myCas = myScorecard.casList[0];
        		//this.penetrationScore = myScorecard.casList[0].APAC_Penetration_Rating__c;
        		//Changing formula for Case 204141, Chintan, March 26, 2015
        		this.penetrationScore = myCas.APAC_Score_1__c + myCas.APAC_Score_2__c;
        		System.debug('CPA score 1: ' + myCas.APAC_Score_1__c);
        		System.debug('CPA score 2: ' + myCas.APAC_Score_2__c);
        		System.debug('CPA Calculation: ' + myCas.Retirement_Plan_Administration_Rating__c + '+' + myCas.Accounting_Services_Rating__c + '+' + myCas.Financial_Planning_Rating__c +'+' + myCas.Investment_Consulting_Rating__c  + '+' + myCas.Group_Insurance_Rating__c  + '+' + myCas.Corporate_Health_Rating__c  + '+' + myCas.Personal_Accident_Rating__c + '+' + myCas.Corporate_Travel_Rating__c + '+' + myCas.Expat_or_Non_Resident_Medical_Rating__c  + '+' + myCas.Life_Disability_Consulting_Rating__c  + '+' + myCas.Mergers_Acquisitions_Rating__c  + '+' + myCas.Global_Benefits_Rating__c  + '+' + myCas.Workers_Compensation_Rating__c + '+' + myCas.Workforce_Risk_Rating__c + '+' + myCas.Cornerstone_OnDemand_Services_Rating__c);
        		System.debug('CPA Cornerstone OnDemand Rating: ' + myCas.Cornerstone_OnDemand_Services_Rating__c);
        		System.debug('CPA Financial Planning Rating: ' + myCas.Financial_Planning_Rating__c);
        		System.debug('CPA Life Disability Rating: ' + myCas.Life_Disability_Consulting_Rating__c);
        		System.debug('CPA Accounting Services Rating: ' + myCas.Accounting_Services_Rating__c);
        		System.debug('CPA Corporate Travel Rating: ' + myCas.Corporate_Travel_Rating__c);
        		System.debug('CPA Expat or Non Resident Rating: ' + myCas.Expat_or_Non_Resident_Medical_Rating__c);
        		System.debug('CPA Workers Comp Rating: ' + myCas.Workers_Compensation_Rating__c);
        	
        		System.debug('CPA penetration total: ' + this.penetrationScore);
        		//Figure out what to divide this total by. We need to subtract two times the number of 'Not Viable' responses
   				for(String fieldName : schemaFieldMap.keySet()) {
   					Schema.DescribeFieldResult dfr = (schemaFieldMap.get(fieldName)).getDescribe(); 
   					if (dfr.getType() == Schema.Displaytype.Picklist) {
	   					String value = (String)myCas.get(fieldName);
   						notViableCount = (value != null && value.equalsIgnoreCase('Not Viable')) ? notViableCount + 1 : notViableCount;
   					}
  				}
  				System.debug('CPA Final notViableCount is: ' + notViableCount);
  				this.penetrationScore = (notViableCount != 34) ? this.penetrationScore / (68 - (2 * notViableCount)) : 0;
  				this.penetrationScore *= 100;
  				System.debug('CPA Penetration Score is: ' + this.penetrationScore);
        	}
        }
        
       	myScorecard.winList = [Select Name, Opportunity_Closed_Date__c, Total_First_Year_Value__c, Current_Provider_Reference__r.Name, Reason_Won_or_Lost__c From Opportunity 
       			Where AccountId = :account.Id And StageName = 'Closed Won' Order By Total_First_Year_Value__c Desc Limit 5];
       	
       	myScorecard.openList = [Select Name, StageName, Total_First_Year_Value__c, Probability, CloseDate From Opportunity 
       			Where AccountId = :account.Id And IsClosed = False Order By Total_First_Year_Value__c Desc Limit 5];
       	
       	myScorecard.lostList = [Select Name, Opportunity_Closed_Date__c, Total_First_Year_Value__c, Chosen_Provider_Reference__r.Name, Reason_Won_or_Lost__c From Opportunity 
       			Where AccountId = :account.Id And StageName = 'Closed Lost' Order By Total_First_Year_Value__c Desc Limit 5];
    } //init
}