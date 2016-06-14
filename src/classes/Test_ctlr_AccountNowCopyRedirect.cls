@isTest
private class Test_ctlr_AccountNowCopyRedirect {

    static testMethod void ctlr_AccountNowCopyRedirect_UnitTest() {
        
		// create an account
        System.debug('creating test account...');
        Account account = util_SampleDataGenerator.createAccount_Client();
        System.assertNotEquals(null, account.Id);
        System.debug('created account: ' + account);
        
        // create a second account
        System.debug('creating test account...');
        Account account2 = util_SampleDataGenerator.createAccount_Client();
        System.assertNotEquals(null, account.Id);
        System.debug('created account: ' + account);
        
        // update the original account with the opposite org id of the seconf account
        account.Opposite_Org_Account_ID__c = String.valueOf(account2.Id).substring(0, 15);
        update account;
        
        //start test        
        Test.startTest();
        
        // set up the test page
        Pagereference pageRef = Page.AccountNowCopyRedirect;
        pageRef.getParameters().put('acctid', account.Id);
        
        // set the test context
        test.setCurrentPage(pageRef);
        
        // grab an instance to the controller
        ctlr_AccountNowCopyRedirect controller = new ctlr_AccountNowCopyRedirect();
        
        // initialize the page
        controller.init();
        
		// invoke the remote search
        System.assertNotEquals('', ctlr_AccountNowCopyRedirect.findCopiedAccount(account2.Id));
        
        // stop the test context
        Test.stopTest();
    }
}