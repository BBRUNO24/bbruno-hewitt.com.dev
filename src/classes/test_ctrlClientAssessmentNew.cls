@isTest
public with sharing class test_ctrlClientAssessmentNew 
{
    static testMethod void unitTest() 
    {
        //Create an Account
        Account account = util_sampleDataGenerator.createAccount_Client();
        System.assertNotEquals(null, account.Id);
        
        //Create Client Assessment Survey        
        Client_Assessment_Survey__c myCas = new Client_Assessment_Survey__c();
        myCas.Account__c = account.Id;
        insert myCas;
        System.assertNotEquals(null, myCas.Id);
        
        Test.startTest();
        
        //Set up the test page
        PageReference testPage = Page.ClientAssessmentNew;
        testPage.getParameters().put('retUrl', '/' + account.Id);
        testPage.getParameters().put('id', myCas.Id);
          
        //Set the test context
        Test.setCurrentPage(testPage);
            
        //Grab an instance to the controller
        //ApexPages.StandardController stdController = new ApexPages.StandardController(account);
        ApexPages.StandardController stdController = new ApexPages.StandardController(myCas);
        ctlr_ClientAssessmentNew myController = new ctlr_ClientAssessmentNew(stdController);              
                     
        Test.stopTest();
    }
}