/** Test class for controller. Chintan, June 18, 2014 */
@isTest
private class test_ctlrSalesDebriefSurveyUS {
    @testSetup 
    static void setupAonCompetitorData() {
        /*
            Insert the Organizational_Defaults__c
        */
        Organizational_Defaults__c orgDefaultSettings = new Organizational_Defaults__c();
        orgDefaultSettings.Enable_CAPIS_Id_Assignment__c = false;
        orgDefaultSettings.Sales_Team_Reconciler_Last_Run_Date__c = null;
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
        
        //Create a Contact
        Contact myContact = util_sampleDataGenerator.createContact_External(myAccount.Id);
        System.assertNotEquals(null, myContact.Id);
        System.debug('CPA CONTACT is: ' + myContact);
        
        //Create an opportunity
        Opportunity myOpp = util_sampleDataGenerator.createOpportunity_US(myAccount.id);
        System.assertNotEquals(null, myOpp.Id);
        System.debug('CPA OPP is: ' + myOpp);

        Map <String, Schema.RecordTypeInfo> recordTypesadjustment = Sales_Debrief_Survey__c.sObjectType.getDescribe().getRecordTypeInfosByName();
        Id RecTypeIdinadj = recordTypesadjustment.get('North America Sales Debrief Survey').getRecordTypeId();

        Sales_Debrief_Survey__c mySurvey = new Sales_Debrief_Survey__c();
        mySurvey.Opportunity_ID__c = myOpp.Id;
        mySurvey.RecordTypeId = RecTypeIdinadj;
        mySurvey.Account__c = myOpp.AccountId;
        mySurvey.Due_Date__c = myOpp.CloseDate.addDays(60);
        mySurvey.Sales_Survey_Type__c = 'Sales Debrief';
        mySurvey.Interviewer_Name__c = [SELECT Id FROM Contact WHERE Corresponding_User_Id__c = :UserInfo.getUserId() LIMIT 1].Id;
        insert mySurvey;
        
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
        	PageReference pageRef = Page.SalesDebriefSurveyUS;
        	pageRef.getParameters().put('oppId', myOpp.Id);
        	pageRef.getParameters().put('RecordType', util_sampleDataGenerator.getRecordType('Sales_Debrief_Survey__c', 'North America Sales Debrief Survey').Id);
        	Test.setCurrentPage(pageRef);
        
	        //Get controller handles
        	ApexPages.standardController stdController = new ApexPages.standardController(myOpp);
        	ctlr_SalesDebriefSurveyUS cusController = new ctlr_SalesDebriefSurveyUS(stdController);
        
	        //init
        	cusController.init();
        	
        	//Get a handle on the survey
        	mySurvey = cusController.mySurvey;
        	mySurvey.Burning_Platform_Post_Close_Rating__c = '+2';
        
        	//save
        	pageRef = cusController.autosave();
        	
        	//Save and Close
        	PageReference temp = cusController.saveAndClose();
        	
        	//Return
        	temp = cusController.returnBack();
        	
        	//PDF
        	temp = cusController.generatePDF();
        
        Test.stopTest();
	} //myUnitTest
}