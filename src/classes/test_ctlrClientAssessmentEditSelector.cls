@isTest(seeAllData = true)
private class test_ctlrClientAssessmentEditSelector {
    static testMethod void myUnitTest() {
        //Create an account
    	Account account = util_sampleDataGenerator.createAccount_Client();
    	System.assertNotEquals(null, account.Id);
    	
    	//Create a CAS for this account
    	Client_Assessment_Survey__c cas = new Client_Assessment_Survey__c();
    	cas.Account__c = account.Id;
    	cas.Year__c = '2013';
    	cas.Quarter__c = 'Q2';
    	cas.RecordTypeId = [SELECT Id,Name FROM RecordType WHERE SobjectType='Client_Assessment_Survey__c' and Name = 'APAC Client Assessment Record'].Id;
    	insert cas;
    	System.assertNotEquals(null, cas.Id);
    	
    	//Create a controller
    	ApexPages.standardController stdController = new ApexPages.standardController(cas);
    	ctlr_ClientAssessmentEditSelector cusController = new ctlr_ClientAssessmentEditSelector(stdController);
    	
    	//initialize
    	PageReference pageRef = cusController.init();
    	
    	//Verify
    	System.assertEquals(pageRef.getUrl().contains('ClientAssessmentEdit_APAC'), true);
    	
    	//Return
    	pageRef = cusController.returnBack();
    	
    	//Verify
    	System.assertEquals(pageRef.getUrl().equals('/' + cas.Id), true);
    }
}