@isTest
private class test_batchSalesTeamReconciler {
	@testSetup 
	static void setupAonCompetitorData() {
		/*
            Insert the Organizational_Defaults__c
        */
        Organizational_Defaults__c orgDefaultSettings = new Organizational_Defaults__c();
        orgDefaultSettings.Enable_CAPIS_Id_Assignment__c = false;
        orgDefaultSettings.Sales_Team_Reconciler_Last_Run_Date__c = null;
        insert orgDefaultSettings;
		/*                                                                                                                                                                                                                                    
            Insert the Competitor__c Accounts
        */
        List<Competitor__c> competitors = new List<Competitor__c>();
        Competitor__c aon = new Competitor__c(name='Aon Hewitt');
        Competitor__c other = new Competitor__c(name='Other');
        competitors.add(aon);
        competitors.add(other);
        insert competitors;
	}
	static testMethod void testCatchUpForLegacyRecords() {

		// create a test client Account
		Account clientAccount = util_SampleDataGenerator.createAccount_Client();
		System.assertNotEquals(null, clientAccount.Id);
		
		// create a test internal account
		Account internalAccount = util_SampleDataGenerator.createAccount_Client();
		System.assertNotEquals(null, internalAccount.Id);
		
		// create a test internal contact
		Contact internalContact = util_SampleDataGenerator.createContact_Internal(internalAccount.Id);
		System.assertNotEquals(null, internalContact.Id);
		
		// create a test product
		Product2 product = util_SampleDataGenerator.createProduct('TEST PRODUCT', 'Consulting', false, 'Consulting');
		System.assertNotEquals(null, product.Id);
		
		// create a test pricebook entry
		PricebookEntry pbe = util_SampleDataGenerator.createStandardPriceForProduct(product.id, 100.0);
        System.assertNotEquals(null, pbe.Id);
		
		// create a test opportunity
		Opportunity oppty = util_SampleDataGenerator.createOpportunity_US(clientAccount.Id);
        System.assertNotEquals(null, oppty.Id);
		
		// create a test opportunity line item
		OpportunityLineItem opptyLineItem = util_SampleDataGenerator.createOpportunityProduct(oppty.Id, pbe.Id, 5, 100.0);
		System.assertNotEquals(null, opptyLineItem.Id);
		
		// create a test sales team entry for non user
		Sales_Credit__c salesCredit = util_SampleDataGenerator.createSalesCredit(oppty.Id, internalContact.Id);
		System.assertNotEquals(null, salesCredit.Id);
		
		// create a test user
		User user = util_SampleDataGenerator.createHewittStandardUser();
		System.assertNotEquals(null, user.Id);
		
		// associate the test user with the test internal contact
		internalContact.Corresponding_User_Id__c = user.Id;
		update internalContact;
		
		// assert the shadow record exists
		opptyLineItem = [select id, Opportunity_Product__c, Opportunity_Product__r.Product2__c, Opportunity_Product__r.Opportunity__c from OpportunityLineItem where id = :opptyLineItem.Id];
		System.assertNotEquals(null, opptyLineItem);
		System.assertNotEquals(null, opptyLineItem.Opportunity_Product__c);
		System.assertEquals(oppty.Id, opptyLineItem.Opportunity_Product__r.Opportunity__c);
		System.assertEquals(product.Id, opptyLineItem.Opportunity_Product__r.Product2__c);
		
		// assert a junction entry has been made
		OpportunityProduct_SalesTeamCredit__c xref = [Select SalesTeamCreditID__c, Opportunity__c, Opportunity_Product__c From OpportunityProduct_SalesTeamCredit__c Where Opportunity__c = :oppty.Id];
		System.assertEquals(xref.SalesTeamCreditID__c, salesCredit.Id);
		System.assertEquals(xref.Opportunity_Product__c, opptyLineItem.Opportunity_Product__c);
		
		// assert no sales team entry exists
		List <OpportunityTeamMember> teamMembers = [select id from OpportunityTeamMember where OpportunityId = :oppty.Id];
		System.assert(teamMembers.isEmpty());
		
		Test.startTest();
		
			// run the batch job
			batch_SalesTeamReconciler batchJob = new batch_SalesTeamReconciler();
			
			// scope the query to just our test record
			batchJob.query += ' where id = \'' + oppty.Id + '\'';
			
			// execute the batch job
			id batchinstanceid = database.executeBatch(batchJob);
		
		Test.stopTest();
		
		// assert the sales team entry was made
		teamMembers = [select id, UserId from OpportunityTeamMember where OpportunityId = :oppty.Id];
		System.assert(!teamMembers.isEmpty());
		System.assertEquals(teamMembers[0].UserId, user.Id);
		
		// assert the sales team was only increased by a single entry
		System.assertEquals(1, teamMembers.size());
				
	}
/* 
	Shimon Rothschild July 2011
	Testing the else condition and beyond
	if (orgSettings.Sales_Team_Reconciler_Last_Run_Date__c == null) {
			this.query = 'select id, ....} 
	else {
			this.query = 'select id, (select id, Credit_Recipient__c, Credit_Recipient__r.Corresponding_User_Id__c From Sales_Credits__r where Credit_Recipient__r.Corresponding_User_Id__c != null and Credit_Recipient__r.Corresponding_User_Id__r.IsActive = true and Credit_Recipient__r.Corresponding_User_Id__r.Activation_Date__c >= :orgSettings.Sales_Team_Reconciler_Last_Run_Date__c), (Select Id, UserId From OpportunityTeamMembers) from Opportunity';
		}
	
	*/
	static testMethod void testCatchUpForRecentlyActivatedUsers() {
		System.debug('--------------------------- start Shimon');
			
		Organizational_Defaults__c orgSettings = Organizational_Defaults__c.getInstance();
		orgSettings.Sales_Team_Reconciler_Last_Run_Date__c = Date.today() - 1; //modified 11 Jul
		System.debug('--------------------------- orgSettings.Sales_Team_Reconciler_Last_Run_Date__c: ' + orgSettings.Sales_Team_Reconciler_Last_Run_Date__c);
		upsert orgSettings;

		// create a test client Account
		Account clientAccount = util_SampleDataGenerator.createAccount_Client();
		System.assertNotEquals(null,clientAccount.Id);
		
		// create a test internal account
		Account internalAccount = util_SampleDataGenerator.createAccount_Client();
		System.assertNotEquals(null,internalAccount.Id);
		
		// create a test internal contact
		Contact internalContact = util_SampleDataGenerator.createContact_Internal(internalAccount.Id);
		System.assertNotEquals(null,internalContact.Id);
		
		// create a test product
		Product2 product = util_SampleDataGenerator.createProduct('TEST PRODUCT', 'Consulting', false, 'Consulting');
		System.assertNotEquals(null,product.Id);
		
		// create a test pricebook entry
		PricebookEntry pbe = util_SampleDataGenerator.createStandardPriceForProduct(product.id, 100.0);
        System.assertNotEquals(null, pbe.Id);	
        
        // create a test opportunity
		Opportunity oppty = util_SampleDataGenerator.createOpportunity_US(clientAccount.Id);
        System.assertNotEquals(null, oppty.Id);
		
		// create a test opportunity line item
		OpportunityLineItem opptyLineItem = util_SampleDataGenerator.createOpportunityProduct(oppty.Id, pbe.Id, 5, 100.0);
		System.assertNotEquals(null, opptyLineItem.Id);
		
		// create a test sales team entry for non user
		Sales_Credit__c salesCredit = util_SampleDataGenerator.createSalesCredit(oppty.Id, internalContact.Id);
		System.assertNotEquals(null, salesCredit.Id);
		
		// create a test user
		User user = util_SampleDataGenerator.createHewittStandardUser();
		user.Activation_Date__c = System.now(); //Date.today() is Ok but object is date time;// give the user  a date not null
		System.assertNotEquals(null, user.Id);
		
		// associate the test user with the test internal contact
		internalContact.Corresponding_User_Id__c = user.Id;
		
		update internalContact;
		
		// assert the shadow record exists
		opptyLineItem = [select id, Opportunity_Product__c, Opportunity_Product__r.Product2__c, Opportunity_Product__r.Opportunity__c from OpportunityLineItem where id = :opptyLineItem.Id];
		System.assertNotEquals(null, opptyLineItem);
		System.assertNotEquals(null, opptyLineItem.Opportunity_Product__c);
		System.assertEquals(oppty.Id, opptyLineItem.Opportunity_Product__r.Opportunity__c);
		System.assertEquals(product.Id, opptyLineItem.Opportunity_Product__r.Product2__c);
		
		// assert a junction entry has been made
		OpportunityProduct_SalesTeamCredit__c xref = [Select SalesTeamCreditID__c, Opportunity__c, Opportunity_Product__c From OpportunityProduct_SalesTeamCredit__c Where Opportunity__c = :oppty.Id];
		System.assertEquals(xref.SalesTeamCreditID__c, salesCredit.Id);
		System.assertEquals(xref.Opportunity_Product__c, opptyLineItem.Opportunity_Product__c);
		
		// assert no sales team entry exists
		List <OpportunityTeamMember> teamMembers = [select id from OpportunityTeamMember where OpportunityId = :oppty.Id];
		System.assert(teamMembers.isEmpty());
		
		System.debug('starting test context...');
		test.startTest();
		System.debug('test started');
		
		// run the batch job
		System.debug('instantiating batch job...');
		batch_SalesTeamReconciler batchJob = new batch_SalesTeamReconciler();
		System.debug('batch job instantiated');
		
		// scope the query to just our test record
		batchJob.query += ' where id = \'' + oppty.Id + '\'';
		
		// execute the batch job
		System.debug('executing batch job...');
		id batchinstanceid = database.executeBatch(batchJob);
		System.debug('job executed');
		
		System.debug('stopping test context...');
		test.stopTest();
		System.debug('test context stopped');
		
		// assert the sales team entry was made
		teamMembers = [select id, UserId from OpportunityTeamMember where OpportunityId = :oppty.Id];
		System.assert(!teamMembers.isEmpty());
		System.assertEquals(teamMembers[0].UserId, user.Id);
		
		// assert the sales team was only increased by a single entry
		System.assertEquals(1, teamMembers.size());
		
	}

}