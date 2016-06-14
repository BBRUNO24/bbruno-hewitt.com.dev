@isTest(seeAllData = true)
private class test_ctlrClientAssessmentNew {
    static testMethod void myUnitTest() {
        //Create an account
    	Account account = util_sampleDataGenerator.createAccount_Client();
    	System.assertNotEquals(null, account.Id);
    	
    	//Create a CAS for this account
    	Client_Assessment_Survey__c cas = new Client_Assessment_Survey__c();
    	cas.Account__c = account.Id;
    	cas.Year__c = '2013';
    	cas.Quarter__c = 'Q2';
    	insert cas;
    	System.assertNotEquals(null, cas.Id);
    	
    	//Create a handle to the Selector page
    	PageReference pageRef = Page.ClientAssessmentNew;
        pageRef.getParameters().put('retUrl', '/' + account.Id);
        Test.setCurrentPage(pageRef);
        
    	//Create a controller
    	ApexPages.standardController stdController = new ApexPages.standardController(new Client_Assessment_Survey__c());
    	ctlr_ClientAssessmentNew cusController = new ctlr_ClientAssessmentNew(stdController);
    	
    	//Verify account Id
    	System.assertEquals(cusController.myAccount.Id, account.Id);
    }
}