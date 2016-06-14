@isTest
private class Test_ctrl_AccountPreview {

	//Hewitt Org test class
    static testMethod void ctrl_AccountPreview_UnitTest() {
    
    	// create a test account
    	Account account = util_sampleDataGenerator.createAccount_Client();
        System.assertNotEquals(null, account.Id);
	
        //start test
        Test.startTest();

		// set up the test page context
		Pagereference pageRef = Page.AccountPreview;
        pageRef.getParameters().put('acctid','1234');
        test.setCurrentPage(pageRef);
        
        // create the test controller
        ApexPages.standardController controller = new ApexPages.standardController(new Account());
        ctrl_AccountPreview extension = new ctrl_AccountPreview( controller );
        System.assertNotEquals(null, extension.init());
        
        pageRef = Page.AccountPreview;
		pageRef.getParameters().put('acctid', account.Id);
		test.setCurrentPage(pageRef);
		
		controller = new ApexPages.standardController(new Account());
        extension = new ctrl_AccountPreview( controller );
		System.assertEquals(null, extension.init());
		
		//STOP test        
        Test.stopTest();

    }
}