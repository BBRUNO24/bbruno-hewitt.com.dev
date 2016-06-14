@isTest
private class test_blogicSalesDebriefSurvey {
    @testSetup 
    static void setupTestData() {
        /*
            Insert the Organizational_Defaults__c
        */
        Organizational_Defaults__c orgDefaultSettings = new Organizational_Defaults__c();
        orgDefaultSettings.Enable_CAPIS_Id_Assignment__c = false;
        orgDefaultSettings.Sales_Team_Reconciler_Last_Run_Date__c = null;
        insert orgDefaultSettings;

        /*
            Insert Sales_Debrief_Survey_Settings__c
        */
        Sales_Debrief_Survey_Settings__c debriefSurveySettings = new Sales_Debrief_Survey_Settings__c();
        debriefSurveySettings.name = 'Asia Pacific End Of Project';
        debriefSurveySettings.Opportunity_Field_Id__c = '345';
        debriefSurveySettings.Survey_Type__c = 'Survey';
        debriefSurveySettings.Account_Field_Id__c = '1234';

        insert debriefSurveySettings;

        /*                                                                                                                                                                                                                                    
            Insert the Competitor__c Accounts
        */
        List<Competitor__c> competitors = new List<Competitor__c>();
        Competitor__c aon = new Competitor__c(name='Aon Hewitt');
        Competitor__c other = new Competitor__c(name='Other');
        competitors.add(aon);
        competitors.add(other);
        insert competitors;

        //Creating an account and contact
        Account acc = util_sampleDataGenerator.createAccount_Client();
        Opportunity opp = util_sampleDataGenerator.createOpportunity_US(acc.Id);
        Contact con = util_sampleDataGenerator.createContact_Internal(acc.ID); 
        //Create a product        
        Product2 product = util_sampleDataGenerator.createProduct('LJ TEST PRODUCT', 'Consulting', false, 'Consulting');
        System.assertNotEquals(null, product.Id);                
                  
        //Create a pricebookentry        
        PricebookEntry pbe = util_sampleDataGenerator.createStandardPriceForProduct(product.id, 100.0);       
        System.assertNotEquals(null, pbe.Id);

        OpportunityLineItem oli = util_sampleDataGenerator.createOpportunityProduct(opp.Id, pbe.Id, 1, 500);
    }
    //Test the AFTER INSERT trigger
    static testMethod void saveSurvey() {    
        Test.startTest();
        //Create an Account
       //Create an Account with no Global Region Set
        Account account = new Account();
        account.RecordTypeId = util_sampleDataGenerator.getRecordType('Account', 'Client Account Record Type').Id;
        account.Name = 'Apex Test Account';
        account.SDO_Billing_Country_Name__c = 'Tuvalu';
        account.Global_Region__c = 'Asia Pacific';
        account.Region_Market_Override__c = true;
        insert account;
        
        //CModBegin SunnyM for Case 00070499 on 2July2013
        //Create External Contact
        Contact contact = util_sampleDataGenerator.createContact_External(account.Id);
        System.assertNotEquals(null, contact.Id);
        
        Contact internalContact = util_sampleDataGenerator.createContact_Internal(account.Id);
        System.assertNotEquals(null, internalContact.Id);
 
        //Create test user
        User user = util_sampleDataGenerator.createHewittStandardUser();
        System.assertNotEquals(null, user.Id);
        
        //Update internal contact
        internalContact.Corresponding_User_Id__c = user.Id; 
        update internalContact;
        //CModEnd SunnyM for Case 00070499 on 2July2013
          
        //Create two opportunities
        List<Opportunity> oppList = new List<Opportunity> ();
        Id opptyRecTypeID = util_sampleDataGenerator.getRecordType('Opportunity', 'Oppty Record').Id;
        
        Opportunity oppty1 = new Opportunity();
        oppty1.RecordTypeId = opptyRecTypeID;
        oppty1.accountId = account.Id;
        oppty1.name = 'Apex Test Opporunity 1';
        oppty1.amount = 1000.00;
        oppty1.StageName = 'Qualify Opportunity';
        oppty1.CloseDate = Date.today().addDays(30);
        oppty1.Probability = 25;
        oppList.add(oppty1);
        
        Opportunity oppty2 = new Opportunity();
        oppty2.RecordTypeId = opptyRecTypeID;
        oppty2.accountId = account.Id;
        oppty2.name = 'Apex Test Opporunity 2';
        oppty2.amount = 1000.00;
        oppty2.StageName = 'Qualify Opportunity';
        oppty2.CloseDate = Date.today().addDays(30);
        oppty2.Probability = 25;
        oppList.add(oppty2);
        
        insert oppList;
        System.assertNotEquals(null, oppty1.Id);
        System.assertNotEquals(null, oppty2.Id);
          
        //Create product        
        Product2 product = util_sampleDataGenerator.createProduct('LJ TEST PRODUCT', 'Consulting', false, 'Consulting');
        System.assertNotEquals(null, product.Id);                
                  
        //Create a pricebookentry        
        PricebookEntry pbe = util_sampleDataGenerator.createStandardPriceForProduct(product.id, 100.0);       
        System.assertNotEquals(null, pbe.Id);
          
        //Tie services to opps
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem> ();
        
		OpportunityLineItem oli1 = new OpportunityLineItem();
        oli1.OpportunityId = oppty1.Id;
        oli1.PricebookEntryId = pbe.Id;
        oli1.Quantity = 5;
        oli1.UnitPrice = 150.0;
        oli1.Recurring_Non_Recurring__c = 'Recurring';
        oli1.Fee_Commission__c = 'Fee';
        oli1.Type__c = 'New Client Sale - A';
        oli1.First_Year_Value__c = 10;
        oliList.add(oli1);
        
        OpportunityLineItem oli2 = new OpportunityLineItem();
        oli2.OpportunityId = oppty2.Id;
        oli2.PricebookEntryId = pbe.Id;
        oli2.Quantity = 8;
        oli2.UnitPrice = 275.0;
        oli2.Recurring_Non_Recurring__c = 'Recurring';
        oli2.Fee_Commission__c = 'Fee';
        oli2.Type__c = 'New Client Sale - A';
        oli2.First_Year_Value__c = 10;
        oliList.add(oli2);
        
        insert oliList; 
        System.assertNotEquals(null, oli1.Id);
        System.assertNotEquals(null, oli2.Id);
          
        //Create bundled Opp
        oppty2 = [Select Id, Lead_Opportunity_Name__c from Opportunity Where Id = :oppty2.Id];
        oppty2.Lead_Opportunity_Name__c = oppty1.Id;
        update oppty2;
          
        //Create a Sales Debrief Survey
        Sales_Debrief_Survey__c mySurvey = new Sales_Debrief_Survey__c();
        mySurvey.Sales_Survey_Type__c = 'Sales Debrief';
        mySurvey.Account__c = account.Id;
        mySurvey.Opportunity_ID__c = oppty1.Id;
        mySurvey.Due_Date__c = date.today();
        mysurvey.Contact__c = contact.Id;
        mysurvey.Interviewer_Name__c = internalContact.Id;
        insert mySurvey;
        System.debug('My Survey is' + mySurvey.Id);
        System.debug('My Survey is for IDE' + mySurvey.Id);
        System.AssertNotEquals(NULL ,mySurvey.Id);

        //Pull Associated Services
        List<Associated_Service__c> associatedServices = [select id from Associated_Service__c where Sales_Debrief_Survey__c = :mySurvey.id];
        System.debug('Associated Services ' + associatedServices);
          
        //Verify
        System.assertequals(associatedServices.size(), 2);
        
        //CModBegin SunnyM for Case 00070499 on 2July2013        
        List<Task> CheckTaskCreated = [select id from task where WHATID = :oppty1.Id and SUBJECT = 'Sales Debrief Survey'];
        System.debug('Task created size' +CheckTaskCreated.size());
        System.assertNotEquals(CheckTaskCreated.size(), 0);
        Test.stopTest();
        //CModEnd SunnyM for Case 00070499 on 2July2013
    } //saveSurvey
    
    
    
    //CSModBegin SunnyM 00070499 2July2013
    static testMethod void test_createTaskRelatedtoDebriefSurvey() 
    {        
        Test.startTest();
        //Create an Account
        Account account = new Account();
        account.RecordTypeId = util_sampleDataGenerator.getRecordType('Account', 'Client Account Record Type').Id;
        account.Name = 'Apex Test Account';
        account.SDO_Billing_Country_Name__c = 'Tuvalu';
        account.Global_Region__c = 'Asia Pacific';
        account.Region_Market_Override__c = true;
        insert account;        
        System.assertNotEquals(null, account.Id);
        
        List<Contact> contactList = new List<Contact> ();
        //Create External Contact
        Contact contact = new Contact();
        contact.RecordTypeId = util_sampleDataGenerator.getRecordType('Contact', 'External Contact Record Type').Id;
        contact.FirstName = 'Apex Test';
        contact.LastName = 'External Contact';
        contact.email = util_globalUtilityMethods.generateRandomString(10)+'@aon.com';
        contact.AccountId = account.Id;
        contact.SDO_Mailing_Country_Name__c = 'United States';
        contact.Functional_Role__c = 'Other - Other';
        contact.Contact_Status__c = 'Active';
        contactList.add(contact);
        
        //Create Internal Contact
        Contact internalContact = new Contact();
        internalContact.RecordTypeId = util_sampleDataGenerator.getRecordType('Contact', 'Internal Contact Record Type').Id;
        internalContact.FirstName = 'Apex Test';
        internalContact.LastName = 'Internal Contact';
        internalContact.email = util_globalUtilityMethods.generateRandomString(10)+'@aon.com';
        internalContact.AccountId = account.Id;
        internalContact.SDO_Mailing_Country_Name__c = 'United States';
        internalContact.Functional_Role__c = 'Other - Other';
        internalContact.Contact_Status__c = 'Active';
        internalContact.Associate_ID__c = 'A00000';
		internalContact.Aon_Hewitt_Employee_Status__c = 'Active';
		contactList.add(internalContact);
		
		insert contactList;
        System.assertNotEquals(null, contact.Id);
        System.assertNotEquals(null, internalContact.Id);
 
        //Create test user
        User user = util_sampleDataGenerator.createHewittStandardUser();
        System.assertNotEquals(null, user.Id);
        
        //Update internal contact
        internalContact.Corresponding_User_Id__c = user.Id; 
        update internalContact;
          
        //Create two opportunities
        List<Opportunity> oppList = new List<Opportunity> ();
        Id opptyRecTypeID = util_sampleDataGenerator.getRecordType('Opportunity', 'Oppty Record').Id;
        
        Opportunity oppty1 = new Opportunity();
        oppty1.RecordTypeId = opptyRecTypeID;
        oppty1.accountId = account.Id;
        oppty1.name = 'Apex Test Opporunity 1';
        oppty1.amount = 1000.00;
        oppty1.StageName = 'Qualify Opportunity';
        oppty1.CloseDate = Date.today().addDays(30);
        oppty1.Probability = 25;
        oppList.add(oppty1);
        
        Opportunity oppty2 = new Opportunity();
        oppty2.RecordTypeId = opptyRecTypeID;
        oppty2.accountId = account.Id;
        oppty2.name = 'Apex Test Opporunity 2';
        oppty2.amount = 1000.00;
        oppty2.StageName = 'Qualify Opportunity';
        oppty2.CloseDate = Date.today().addDays(30);
        oppty2.Probability = 25;
        oppList.add(oppty2);
        
        insert oppList;
        System.assertNotEquals(null, oppty1.Id);
        System.assertNotEquals(null, oppty2.Id);
          
        //Create a product        
        Product2 product = util_sampleDataGenerator.createProduct('LJ TEST PRODUCT', 'Consulting', false, 'Consulting');
        System.assertNotEquals(null, product.Id);                
                  
        //Create a pricebookentry        
        PricebookEntry pbe = util_sampleDataGenerator.createStandardPriceForProduct(product.id, 100.0);       
        System.assertNotEquals(null, pbe.Id);
          
        //Tie services to opps
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem> ();
        
		OpportunityLineItem oli1 = new OpportunityLineItem();
        oli1.OpportunityId = oppty1.Id;
        oli1.PricebookEntryId = pbe.Id;
        oli1.Quantity = 5;
        oli1.UnitPrice = 150.0;
        oli1.Recurring_Non_Recurring__c = 'Recurring';
        oli1.Fee_Commission__c = 'Fee';
        oli1.Type__c = 'New Client Sale - A';
        oli1.First_Year_Value__c = 10;
        oliList.add(oli1);
        
        OpportunityLineItem oli2 = new OpportunityLineItem();
        oli2.OpportunityId = oppty2.Id;
        oli2.PricebookEntryId = pbe.Id;
        oli2.Quantity = 8;
        oli2.UnitPrice = 275.0;
        oli2.Recurring_Non_Recurring__c = 'Recurring';
        oli2.Fee_Commission__c = 'Fee';
        oli2.Type__c = 'New Client Sale - A';
        oli2.First_Year_Value__c = 10;
        oliList.add(oli2);
        
        insert oliList; 
        System.assertNotEquals(null, oli1.Id);
        System.assertNotEquals(null, oli2.Id);
          
        //Create bundled Opp
        oppty2 = [Select Id, Lead_Opportunity_Name__c from Opportunity Where Id = :oppty2.Id];
        oppty2.Lead_Opportunity_Name__c = oppty1.Id;
        update oppty2;
        
        List<Sales_Debrief_Survey__c> mySurveyList = new List<Sales_Debrief_Survey__c>();        
        for (integer i=0; i<200; i++) 
        {
            //Create a Sales Debrief Survey
            Sales_Debrief_Survey__c mySurvey = new Sales_Debrief_Survey__c();
            mySurvey.Account__c = account.Id;
            mySurvey.Opportunity_ID__c = oppty1.Id;
            mySurvey.Due_Date__c = date.today();
            mysurvey.Contact__c = contact.Id;
            mysurvey.Interviewer_Name__c = internalContact.Id;
            mySurvey.Sales_Survey_Type__c = 'Sales Debrief';
            mySurveyList.add(mysurvey);
        }        
        insert mySurveyList;          
        
        //Validating the inserts
        List<Task> CheckTaskCreated = [select id from task where WHATID = :oppty1.Id and SUBJECT = 'Sales Debrief Survey'];
        System.AssertEquals(CheckTaskCreated.size(),mySurveyList.size());
        
        Test.stopTest();        
    }   
}