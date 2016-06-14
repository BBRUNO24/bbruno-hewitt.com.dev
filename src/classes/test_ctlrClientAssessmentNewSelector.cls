@isTest
public with sharing class test_ctlrClientAssessmentNewSelector {
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
	private static testMethod void test_Selector() {
    	
        Id accountId = [SELECT Id FROM Account LIMIT 1].Id;
    	//Create a handle to the Selector page
    	PageReference pageRef = Page.ClientAssessmentNewSelector;
        pageRef.getParameters().put('retUrl', '/' + accountId);
        Test.setCurrentPage(pageRef);
        
    	//Create a controller
    	ApexPages.standardController stdController = new ApexPages.standardController(new Client_Assessment_Survey__c());
    	ctlr_ClientAssessmentNewSelector cusController = new ctlr_ClientAssessmentNewSelector(stdController);
    	
    	//call init
    	pageRef = cusController.init();
        System.assertNotEquals(null, pageRef, 'It should not return a null page ref');
    	System.debug('CPA init URL is: ' + pageRef.getUrl());
    	System.assertEquals(pageRef.getUrl().contains('ClientAssessmentNew'), true);
    	
    	//Call Returnback
    	pageRef = cusController.returnBack();
    	System.debug('CPA returnBack URL is: ' + pageRef.getUrl());
    	System.assertEquals(pageRef.getUrl().equals('/' +accountId), true);
	}
}