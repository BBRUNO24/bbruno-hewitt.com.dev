@isTest
private class test_SalesDebriefSurveyNewButtonOverride {
    @testSetup 
    static void setupAonCompetitorData() {
        /*
            Insert the Organizational_Defaults__c
        */
        Organizational_Defaults__c orgDefaultSettings = new Organizational_Defaults__c();
        orgDefaultSettings.Enable_CAPIS_Id_Assignment__c = false;
        insert orgDefaultSettings;
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
            Insert Sales_Debrief_Survey_Settings__c
        */
        Sales_Debrief_Survey_Settings__c debriefSurveySettings = new Sales_Debrief_Survey_Settings__c();
        debriefSurveySettings.name = 'Asia Pacific End Of Project';
        debriefSurveySettings.Opportunity_Field_Id__c = '345';
        debriefSurveySettings.Survey_Type__c = 'Survey';
        debriefSurveySettings.Account_Field_Id__c = '1234';

        insert debriefSurveySettings;

    }
    //Test that New button override button functionality
    static testMethod void unitTestMethod() {
    	//Create an Account with no Global Region Set
    	Account myAccount = new Account();
    	myAccount.RecordTypeId = util_sampleDataGenerator.getRecordType('Account', 'Client Account Record Type').Id;
    	myAccount.Name = 'Apex Test Account';
    	myAccount.SDO_Billing_Country_Name__c = 'Tuvalu';
    	myAccount.Global_Region__c = 'No Global Region';
    	insert myAccount;
        System.assertNotEquals(null, myAccount.Id);
        System.debug('CHINTAN Global Region is: ' + myAccount.Global_Region__c);
        
        //Create an opportunity
        Opportunity myOpp = util_sampleDataGenerator.createOpportunity_US(myAccount.id);
        System.assertNotEquals(null, myOpp.Id);        
      
        Test.startTest();
        
        	//Set up the test page
        	Pagereference pageRef = Page.SalesDebriefSurveyNewButtonOverride;
        
        	//Set the test context
        	test.setCurrentPage(pageRef);
        	System.debug('CHINTAN CurrentPage URL is: ' + pageRef.getUrl());
        
        	//Grab an instance to the controller
        	ApexPages.StandardController stdController = new ApexPages.StandardController(new Sales_Debrief_Survey__c());
        	ctlr_SalesDebriefSurveyNewButtonOverride myController = new ctlr_SalesDebriefSurveyNewButtonOverride(stdController);
        	myController.oppId = myOpp.Id;
        
        	//Verify initialization
        	myController.selectedSurvey = 'End Of Project';
        	pageRef = myController.createSurveyRecord();
        	System.assertEquals(null, pageRef);
        	
        	//Update Account to Asia Pac Region
        	myAccount.Global_Region__c = 'Asia Pacific';
        	update myAccount;
        	
        	//Verify initialization again
        	pageRef = myController.createSurveyRecord();
        	String nextPage = pageRef.getUrl();
        	//The name of the opp is 'Killer Whale Opportunity'
        	System.assertEquals(nextPage.contains('Killer+Whale'), true);

        	//Verify the Return button functionality
        	pageRef = myController.returnBack();
        	System.assertEquals(pageRef.getUrl(), '/' + myOpp.Id);
        	
        Test.stopTest();
    } //unitTestMethod
}