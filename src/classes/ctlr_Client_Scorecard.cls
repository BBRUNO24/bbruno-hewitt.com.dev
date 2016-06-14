//Implemented for Case 10713. Chintan Adhyapak. June 13, 2012 
public class ctlr_Client_Scorecard {
    //Class to store all the details needed to populate the Scorecard
    public class Scorecard {
        public String accountName                         	{get; set;}
        public String market                              	{get; set;}
        public String ownerName                           	{get; set;}
        public String executiveSponsor                    	{get; set;}
        public List<Internal_Account_Team__c> iatList     	{get; set;}
        //public List<Client_Satisfaction_Data__c> csdList	{get; set;}
        public List<Client_Assessment_Survey__c> casList  	{get; set;}
        public List<Revenue_Sales_Pipeline__c> rspList    	{get; set;}
        public List<HRO_Renewal__c> hroList               	{get; set;}
        public List<Opportunity> winList					{get; set;}
        public List<Opportunity> openList					{get; set;}
        public Map<String, String> csdMap					{get; set;}
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
    public ctlr_Client_Scorecard(ApexPages.StandardController controller) {
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
    }
    
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
        
        //Get Client Satisfaction Data for this and previous year
        myScorecard.csdMap = new Map<String, String> ();
        String prevYearString = String.valueOf(prevYear);
        List<Client_Satisfaction_Data__c >currYearCsd = [SELECT Likelihood_to_Recommend__c, Overall_Satisfaction__c, Year__c, Quarter__c FROM Client_Satisfaction_Data__c 
        	WHERE account__r.Id = :account.Id AND Year__c = :financialYear];
        	//System.debug('CPA currYearCSD likelihood is: ' + currYearCsd[0].Likelihood_to_Recommend__c);
        List<Client_Satisfaction_Data__c >prevYearCsd = [SELECT Likelihood_to_Recommend__c, Overall_Satisfaction__c, Year__c, Quarter__c FROM Client_Satisfaction_Data__c 
        	WHERE account__r.Id = :account.Id AND Year__c = :prevYearString];
        System.debug('CPA prevYearCsd is: ' + prevYearCsd);
        if (currYearCsd.size() > 0) {
        	myScorecard.csdMap.put('CYlikelihood', currYearCsd[0].Likelihood_to_Recommend__c != null ? String.valueOf(currYearCsd[0].Likelihood_to_Recommend__c) : '');
        	myScorecard.csdMap.put('CYsatisfaction', currYearCsd[0].Overall_Satisfaction__c != null ? String.valueOf(currYearCsd[0].Overall_Satisfaction__c) : '');
        } else {
        	myScorecard.csdMap.put('CYlikelihood', 'N/A');
        	myScorecard.csdMap.put('CYsatisfaction', 'N/A');
        }
        if (prevYearCsd.size() > 0) {
        	myScorecard.csdMap.put('PYlikelihood', prevYearCsd[0].Likelihood_to_Recommend__c != null ? String.valueOf(prevYearCsd[0].Likelihood_to_Recommend__c) : '');
        	myScorecard.csdMap.put('PYsatisfaction', prevYearCsd[0].Overall_Satisfaction__c != null ? String.valueOf(prevYearCsd[0].Overall_Satisfaction__c) : '');
        } else {
        	myScorecard.csdMap.put('PYlikelihood', 'N/A');
        	myScorecard.csdMap.put('PYsatisfaction', 'N/A');
        }
        
        myScorecard.casList = [SELECT Overall_Relationship_Status__c,Consulting_Relationship_Status__c,
        	Outsourcing_Relationship_Status__c,ARS_Relationship__c,H_B_Consulting__c,H_W_Admin__c,Absence_Mgmt__c, Risks__c, Opportunities__c,
        	Exchanges__c,Actuarial__c,Investment__c,DB_Admin__c,DC_Admin__c,Advisory__c,Compensation__c,Engagement__c, Advocacy__c, Dependent_Verification__c,
        	Selection_Assessment__c,Talent_Acquisition_Solutions__c,HRE__c,Leadership__c,Communications__c,AMAS_M_A__c,Global_Benefits_Brokerage__c,
        	BPO__c,Spending_Acct_Admin__c,Penetration_Rating__c FROM Client_Assessment_Survey__c WHERE account__r.Id = :this.account.Id AND Year__c = :financialYear 
        	AND Quarter__c = :quarter];
        this.casListSize = myScorecard.casList.size();
        if (casListSize > 0) {
        	this.penetrationScore = myScorecard.casList[0].Penetration_Rating__c;
        }
        
		//Read all fields on Revenue_Sales_Pipeline__c object
        Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Revenue_Sales_Pipeline__c.fields.getMap();
        
        //Create a SOQL string with all fields
        String fieldNames = '';
        for(String fieldName : schemaFieldMap.keySet()) {
        	fieldNames += ',' + fieldName;
        }
        fieldNames = fieldNames.substring(1);
        String soql = 'Select ' + fieldNames + ' From Revenue_Sales_Pipeline__c Where account__r.Id = \'' + account.Id + '\' AND Year__c = \'' + financialYear + '\' AND Quarter__c = \'' + quarter +'\'';
        
        //Read Account data
        myScorecard.rspList = Database.query(soql);
        this.rspListSize = myScorecard.rspList.size();
        System.debug('CPA rspListSize is ' + this.rspListSize);
        
        myScorecard.hroList = [SELECT Services__c,Renewal_Stage__c,Overall_Renewal_Rating__c,Renewal_Lead__r.Name,Min_Contract_End_Date__c FROM HRO_Renewal__c 
       		WHERE account__r.Id = :this.account.Id And Year__c = :financialYear AND Quarter__c = :quarter];
       		
       	myScorecard.winList = [Select Name, StageName, Total_First_Year_Value__c, Current_Provider_Reference__r.Name, LOI_Contract_Date__c From Opportunity 
       			Where AccountId = :account.Id And IsWon = True And LOI_Contract_Date__c = LAST_N_DAYS:365 Order By Total_First_Year_Value__c Desc Limit 5];
       			
       	myScorecard.openList = [Select Name, StageName, Total_First_Year_Value__c, Probability, CloseDate From Opportunity 
       			Where AccountId = :account.Id And (IsClosed = False Or (StageName = 'Closed Won' And LOI_Contract_Date__c = null)) Order By Total_First_Year_Value__c Desc Limit 5];
    } //init
}