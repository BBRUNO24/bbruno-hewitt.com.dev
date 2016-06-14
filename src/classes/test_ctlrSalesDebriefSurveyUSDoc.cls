/** Test class for controller. Chintan, June 18, 2014 */
@isTest
private class test_ctlrSalesDebriefSurveyUSDoc {
    @testSetup 
    static void setupClientData() {
        final String REGION = 'North America';
        /*
            Insert the Organizational_Defaults__c
        */
        Organizational_Defaults__c orgDefaultSettings = new Organizational_Defaults__c();
        orgDefaultSettings.Enable_CAPIS_Id_Assignment__c = false;
        insert orgDefaultSettings;
        /*                                                                                                                                                                                                                                    
            Insert the Competitor__c Accounts
        */
        Client_Assessment_Settings__c clientSettings = new Client_Assessment_Settings__c();
        clientSettings.Account_Field_Id__c = '123';
        clientSettings.Global_Region__c = REGION;
        clientSettings.Record_Type_Id__c = '1';
        clientSettings.Name = REGION;
        insert clientSettings;
        /*                                                                                                                                                                                                                                    
            Insert the Competitor__c Accounts
        */
        List<Competitor__c> competitors = new List<Competitor__c>();
        Competitor__c aon = new Competitor__c(name='Aon Hewitt');
        Competitor__c other = new Competitor__c(name='Other');
        competitors.add(aon);
        competitors.add(other);
        insert competitors;
        /*
            Inser the Client_Plan_Settings__c
        */
        Client_Plan_Settings__c clientPlanSettings = new Client_Plan_Settings__c();
        clientPlanSettings.Global_Region__c = REGION;
        clientPlanSettings.Account_Field_Id__c = '12345';
        clientPlanSettings.Name = REGION;
        insert clientPlanSettings;

        Zip_Code_to_Market_Mapping__c zip = new Zip_Code_to_Market_Mapping__c(Name='111', Market__c='New York',Global_Region__c=REGION, Region__c=REGION, Country__c ='United States');
        insert zip;

        Account account = util_sampleDataGenerator.createAccount_Client();
        account.Global_Region__c = REGION;
        account.SDO_Billing_Country_Name__c = 'United States';
        account.BillingPostalCode = '111';
        update account;
    }
    static testMethod void myUnitTest() {
        //Create an Account
    	Account myAccount = [SELECT Id FROM Account LIMIT 1];
        System.assertNotEquals(null, myAccount.Id);
        
        //Create a Contact
        Contact myContact = util_sampleDataGenerator.createContact_External(myAccount.Id);
        System.assertNotEquals(null, myContact.Id);
        System.debug('CPA CONTACT is: ' + myContact);
        
        //Create an opportunity
        Opportunity myOpp = util_sampleDataGenerator.createOpportunity_US(myAccount.id);
        System.assertNotEquals(null, myOpp.Id);
        
        //Create a Survey
        Sales_Debrief_Survey__c mySurvey = new Sales_Debrief_Survey__c();
        mySurvey.Opportunity_ID__c = myOpp.Id;
        mySurvey.RecordTypeId = util_sampleDataGenerator.getRecordType('Sales_Debrief_Survey__c', 'North America Sales Debrief Survey').Id;
        mySurvey.Burning_Platform_Post_Close_Rating__c = '+2';
        mySurvey.Sales_Survey_Type__c = 'Sales Debrief';
        insert mySurvey;
        System.assertNotEquals(null, mySurvey.Id);
        
        //Create an Opportunity Strategy Record
        Opportunity_Strategy__c myStrategy = new Opportunity_Strategy__c();
        myStrategy.Related_Opportunity__c = myOpp.Id;
        insert myStrategy;
        System.assertNotEquals(null, myStrategy.Id);
        
        //Create an Opp Competitive Analysis record
        Opportunity_Competitive_Analysis__c myOca = new Opportunity_Competitive_Analysis__c();
        myOca.Opportunity__c = myOpp.Id;
        myOca.Competitor__c = 'Other';
        myOca.Strength__c = 'My Strengths';
        insert myOca;
        System.assertNotEquals(null, myOca.Id);
        
        //Create Opp Contact Role record
        Opportunity_Contact_Role__c myOcr = new Opportunity_Contact_Role__c();
        myOcr.Opportunity__c = myOpp.Id;
        myOcr.Contact__c = myContact.Id;
        myOcr.Account__c = myAccount.Id;
        insert myOcr;
        System.assertNotEquals(null, myOcr.Id);
        
        Test.startTest();
        
        	//Handle to the Apex page          
        	PageReference pageRef = Page.SalesDebriefSurveyUSDoc;
        	pageRef.getParameters().put('id', mySurvey.Id);
        	Test.setCurrentPage(pageRef);
        
	        //Get controller handles
        	ApexPages.standardController stdController = new ApexPages.standardController(mySurvey);
        	ctlr_SalesDebriefSurveyUSDoc cusController = new ctlr_SalesDebriefSurveyUSDoc(stdController);
        	
        Test.stopTest();
    } //myUnitTest
}