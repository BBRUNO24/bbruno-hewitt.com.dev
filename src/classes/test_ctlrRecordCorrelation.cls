@isTest
private class test_ctlrRecordCorrelation {

    static testMethod void testRecordCorrelation() {
        
        // declare local vars
        PageReference testPage = null;
        ctlr_RecordCorrelation controller  = null;
        
        // create test accounts
    	Account account = util_SampleDataGenerator.createAccount_Client();
    	System.assertNotEquals(null, account.id);
    	
    	Account account2 = util_SampleDataGenerator.createAccount_Client();
    	System.assertNotEquals(null, account2.id);
    	
    	// create sample request
    	String request = '<?xml version="1.0" encoding="UTF-8"?><CorrelationRequest><RecordsToCorrelate><Record><LocalRecordId>' + account.Id;
    	request += '</LocalRecordId><RemoteRecordId>' + account2.Id + '</RemoteRecordId></Record></RecordsToCorrelate></CorrelationRequest>';
    	
    	// start the test context
    	Test.startTest();
    	
    	// create test page context
    	testPage = Page.RecordCorrelation;
    	testPage.getParameters().put('req', request); 
    	Test.setCurrentPage(testPage);
        
        // create a controller instance
        controller = new ctlr_RecordCorrelation();
        
        // process the request
        System.debug('processing the request...');
        controller.init();
        
        // stop the test context
        Test.stopTest();
        
        // assert the results
        account = [select id, Opposite_Org_Account_Id__c from Account where id = :account.Id];
        System.assertEquals(account2.Id, account.Opposite_Org_Account_Id__c);
    }
}