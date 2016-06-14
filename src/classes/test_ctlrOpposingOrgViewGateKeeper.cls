@isTest
private class test_ctlrOpposingOrgViewGateKeeper {
	/*
    static testMethod void testAccountTeamMemberScrub_AccessGranted() {
        
        // create a test account
        Account account = util_sampleDataGenerator.createAccount_Client();
        
        // create a test account for the internal contact
        Account account2 = util_sampleDataGenerator.createAccount_Client();
        
        // create a test user
        User user = util_sampleDataGenerator.createHewittStandardUser();
        
        // create a corresponding internal contact record
        Contact contact = util_sampleDataGenerator.createContact_Internal(account2.Id);
        contact.Corresponding_User_Id__c = user.Id;
        update Contact;
        
        // update the user association to the contact record
        user.Internal_Contact_Id__c = contact.Id;
        update user;

		// set the opposite org id and account owner
        account.Opposite_Org_Account_ID__c = 'TESTORGID';
        account.OwnerId = user.Id;
        update account;
        
        // add the user to the account team
        Internal_Account_Team__c teamMember = util_sampleDataGenerator.createInternalAccountTeamMember(account.Id, contact.Id, 'TEST MEMBER');
        
        // set up the custom setting access to ensure the override has not been applied to this user
        AccountCreateProcess__c appSettings = AccountCreateProcess__c.getInstance();
        
        // create an instance for the test user
        AccountCreateProcess__c userSettings = appSettings.clone(false, true, false, false);
        userSettings.SetupOwnerId = user.Id;
        userSettings.Account_Team_Scrub_Override__c = false;
        insert userSettings;
        System.assertNotEquals(null, userSettings.Id);
        
        // start the test
        Test.startTest();
        
        System.runAs(user) {
        	// create test page
        	PageReference testPage = Page.OpposingOrgViewGateKeeper;
        	// add the account id
        	testPage.getParameters().put('accountid', account.Id);
        	// set the test page context
        	Test.setCurrentPage(testPage);
        	// create a controller instance
        	ctlr_OpposingOrgViewGateKeeper controller = new ctlr_OpposingOrgViewGateKeeper();
        	// attempt to access the page
        	PageReference redirect = controller.checkAccountTeamMembership();
        	// assert the result
        	System.assertNotEquals(null, redirect);
        }
        
        // stop the test
        Test.stopTest();
        
    }
    
    static testMethod void testAccountTeamMemberScrub_AccessDenied() {
        // create a test account
        Account account = util_sampleDataGenerator.createAccount_Client();
        
        // create a test account for the internal contact
        Account account2 = util_sampleDataGenerator.createAccount_Client();
        
        // create a test user
        User user = util_sampleDataGenerator.createHewittStandardUser();
        
        // create a corresponding internal contact record
        Contact contact = util_sampleDataGenerator.createContact_Internal(account2.Id);
        contact.Corresponding_User_Id__c = user.Id;
        update Contact;
        
        // update the user association to the contact record
        user.Internal_Contact_Id__c = contact.Id;
        update user;

		// set the opposite org id and account owner
        account.Opposite_Org_Account_ID__c = 'TESTORGID';
        update account;
        
        // set up the custom setting access to ensure the override has not been applied to this user
        AccountCreateProcess__c appSettings = AccountCreateProcess__c.getInstance();
        
        // create an instance for the test user
        AccountCreateProcess__c userSettings = appSettings.clone(false, true, false, false);
        userSettings.SetupOwnerId = user.Id;
        userSettings.Account_Team_Scrub_Override__c = false;
        insert userSettings;
        System.assertNotEquals(null, userSettings.Id);
        
        // start the test
        Test.startTest();
        
        System.runAs(user) {
        	// create test page
        	PageReference testPage = Page.OpposingOrgViewGateKeeper;
        	// add the account id
        	testPage.getParameters().put('accountid', account.Id);
        	// set the test page context
        	Test.setCurrentPage(testPage);
        	// create a controller instance
        	ctlr_OpposingOrgViewGateKeeper controller = new ctlr_OpposingOrgViewGateKeeper();
        	// attempt to access the page
        	PageReference redirect = controller.checkAccountTeamMembership();
        	// assert the result
        	System.assertEquals(null, redirect);
        }
        
        // stop the test
        Test.stopTest();
    }*/
    
    static testMethod void testAccountTeamMemberScrub_Override() {
        // create a test account
        Account account = util_sampleDataGenerator.createAccount_Client();
        
        // create a test account for the internal contact
        Account account2 = util_sampleDataGenerator.createAccount_Client();
        
        // create a test user
        User user = util_sampleDataGenerator.createHewittStandardUser();
        
        // create a corresponding internal contact record
        Contact contact = util_sampleDataGenerator.createContact_Internal(account2.Id);
        contact.Corresponding_User_Id__c = user.Id;
        update Contact;
        
        // update the user association to the contact record
        user.Internal_Contact_Id__c = contact.Id;
        update user;

		// set the opposite org id and account owner
        account.Opposite_Org_Account_ID__c = 'TESTORGID';
        update account;
        
        // create an account read access for the user
        AccountShare share = new AccountShare(AccountId = account.Id, UserOrGroupId = user.Id, AccountAccessLevel = 'Read', CaseAccessLevel = 'Read', OpportunityAccessLevel = 'Read', ContactAccessLevel = 'Read');
        insert share;
        
        // set up the custom setting access to ensure the override has not been applied to this user
        AccountCreateProcess__c appSettings = AccountCreateProcess__c.getInstance();
        
        // create an instance for the test user
        AccountCreateProcess__c userSettings = appSettings.clone(false, true, false, false);
        userSettings.SetupOwnerId = user.Id;
        userSettings.Account_Team_Scrub_Override__c = false;
        userSettings.Account_Team_Scrub_Override__c = true;
        insert userSettings;
        System.assertNotEquals(null, userSettings.Id);
        
        // start the test
        Test.startTest();
        
        System.runAs(user) {
        	// create test page
        	PageReference testPage = Page.OpposingOrgViewGateKeeper;
        	// add the account id
        	testPage.getParameters().put('accountid', account.Id);
        	// set the test page context
        	Test.setCurrentPage(testPage);
        	// create a controller instance
        	ctlr_OpposingOrgViewGateKeeper controller = new ctlr_OpposingOrgViewGateKeeper();
        	// attempt to access the page
        	PageReference redirect = controller.checkAccountTeamMembership();
        	// assert the result
        	System.assertNotEquals(null, redirect);
        }
        
        // stop the test
        Test.stopTest();
    }
}