/** Test class for controller. Chintan, June 18, 2014 */
@isTest
private class test_ctlrSDSurveyEditButtonOverride {
    @testSetup 
    static void setupAonCompetitorData() {
        /*
            Insert the Organizational_Defaults__c
        */
        Organizational_Defaults__c orgDefaultSettings = new Organizational_Defaults__c();
        orgDefaultSettings.Enable_CAPIS_Id_Assignment__c = false;
        orgDefaultSettings.Sales_Team_Reconciler_Last_Run_Date__c = null;
        insert orgDefaultSettings;

        Sales_Debrief_Survey_Settings__c debriefSettings = new Sales_Debrief_Survey_Settings__c();
        debriefSettings.Name = 'North America Sales Debrief';
        debriefSettings.Record_Type__c = util_sampleDataGenerator.getRecordType('Sales_Debrief_Survey__c', 'North America Sales Debrief Survey').Id;
        debriefSettings.Opportunity_Field_Id__c = '1';
        debriefSettings.Account_Field_Id__c = '2';
        debriefSettings.Survey_Type__c = 'Sales Debrief';
        insert debriefSettings;
        /*                                                                                                                                                                                                                                    
            Insert the Competitor__c Accounts
        */
        List<Competitor__c> competitors = new List<Competitor__c>();
        Competitor__c aon = new Competitor__c(name='Aon Hewitt');
        Competitor__c other = new Competitor__c(name='Other');
        competitors.add(aon);
        competitors.add(other);
        insert competitors;


        Map <String, Schema.RecordTypeInfo> recordTypesadjustment = Contact.sObjectType.getDescribe().getRecordTypeInfosByName();
        Id RecTypeIdinadj = recordTypesadjustment.get('Internal Contact Record Type').getRecordTypeId();

        Contact c = new Contact();
        c.FirstName = 'Aon';
        c.LastName = 'Testing';
        c.Corresponding_User_Id__c = UserInfo.getUserId();
        c.RecordTypeId = RecTypeIdinadj;
        insert c;
    }
	static testMethod void myUnitTest() {
		//Create an Account
    	Account myAccount = util_sampleDataGenerator.createAccount_Client();
        myAccount.Global_Region__c = 'North America';
        myAccount.Region_Market_Override__c = true;
        update myAccount;
        System.assertNotEquals(null, myAccount.Id);
        
        //Create an opportunity
        Opportunity myOpp = util_sampleDataGenerator.createOpportunity_US(myAccount.id);
        System.assertNotEquals(null, myOpp.Id);
        
        //Create a Survey
        Sales_Debrief_Survey__c mySurvey = new Sales_Debrief_Survey__c();
        mySurvey.Opportunity_ID__c = myOpp.Id;
        mySurvey.RecordTypeId = util_sampleDataGenerator.getRecordType('Sales_Debrief_Survey__c', 'APAC Sales Debrief Survey 2013').Id;
        insert mySurvey;
        System.assertNotEquals(null, mySurvey.Id);
      
        Test.startTest();
        
        	//Set up the test page
        	Pagereference pageRef = Page.SalesDebriefSurveyEditButtonOverride;
        	
        	//Set the test context
        	Test.setCurrentPage(pageRef);
        	System.debug('CHINTAN CurrentPage URL is: ' + pageRef.getUrl());
        
        	//Grab an instance to the controller
        	ApexPages.StandardController stdController = new ApexPages.StandardController(mySurvey);
        	ctlr_SalesDebriefEditButtonOverride myController = new ctlr_SalesDebriefEditButtonOverride(stdController);
        	
        	//init non NA survey
        	pageRef = myController.init();
        	
        	//Pull Survey record
        	mySurvey = [Select Id, RecordTypeId From Sales_Debrief_Survey__c Where Id = :mySurvey.Id];
        	mySurvey.RecordTypeId = util_sampleDataGenerator.getRecordType('Sales_Debrief_Survey__c', 'North America Sales Debrief Survey').Id;
        	update mySurvey;
        	
        	//myController.survey = mySurvey;
        	
        	//init NA survey
        	pageRef = myController.init();
            System.assertNotEquals(null, pageRef, 'It shuld have a pageref');

        Test.stopTest();
	} //myUnitTest
}