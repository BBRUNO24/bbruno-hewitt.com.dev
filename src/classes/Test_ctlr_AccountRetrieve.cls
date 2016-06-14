@isTest
private class Test_ctlr_AccountRetrieve {
/*
    static testMethod void ctlr_AccountRetrieve_UnitTest() {
        
        // declare local vars
        ctlr_AccountRetrieve controller = null;
        Pagereference pageRef = null;
        
        // create the account
        Account account = util_SampleDataGenerator.createAccount_Client();
        System.assertNotEquals(null, account.Id);
        
        //start test        
        Test.startTest();
        
        // create the page referernce
        pageRef = Page.AccountRetrieve;
        pageRef.getParameters().put('acctid', account.Id);
        
        // set the test page context
        test.setCurrentPage(pageRef);
        
        // create a controller instance
        controller = new ctlr_AccountRetrieve();
        
        // assert the init method
        System.assertEquals(null, controller.init()); 

		// create a new page reference        
        pageRef = Page.AccountRetrieve;
        pageref.getParameters().put('acctid', '');
        
        // reset the test page context 
        test.setCurrentPage(pageRef);
        
        // create a new controller instance
        controller = new ctlr_AccountRetrieve();
        
        // assert the results
        System.assertEquals(null, controller.init());
        System.assert( controller.responseXmlString.contains('ERROR') );
        
        // stop the test context
        Test.stopTest();
    }
*/    
}