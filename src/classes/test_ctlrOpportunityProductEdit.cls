@isTest
private class test_ctlrOpportunityProductEdit {
    @testSetup 
    static void setupTestData() {
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
    static testMethod void myUnitTest() {
        
        // declare local vars
        PageReference requestedPage = null;
        ApexPages.standardController controller = null;
        ctlr_OpportunityProductEdit controllerExtension = null;
        
        // create an admin
        System.debug('creating test admin user...');
        User adminUser = util_sampleDataGenerator.createAdminUser();
        System.assertNotEquals(null, adminUser.Id);
        System.debug('created user: ' + adminUser);
        
        // create a practice
        System.debug('creating a sample practice...');
        Product_Practice__c practice = new Product_Practice__c();
        practice.Name = 'LJ TEST PRACTICE'; 
        insert practice;
        System.assertNotEquals(null, practice.Id);
        System.debug('created practice: ' + practice);
        
        // create a product
        System.debug('creating a sample product...');
        Product2 product = util_SampleDataGenerator.createProduct('LJ TEST PRODUCT', 'Consulting', false, 'Consulting');
        System.assertNotEquals(null, product.Id);
        product.Practice__c = practice.Name;
        update product;
        System.debug('created product');
        
        // create a standard pricebook entry
        System.debug('adding new product to standard pricebook...');
        PricebookEntry pbe = util_SampleDataGenerator.createStandardPriceForProduct(product.id, 100.0);
        System.assertNotEquals(null, pbe.Id);
        System.debug('pricebook entry created: ' + pbe);
        
        // create an account
        System.debug('creating test account...');
        Account account = util_SampleDataGenerator.createAccount_Client();
        System.assertNotEquals(null, account.Id);
        System.debug('created account: ' + account);
        
        // create an opportunity
        System.debug('creating test opportunity...');
        Opportunity oppty = util_SampleDataGenerator.createOpportunity_US(account.Id);
        System.assertNotEquals(null, oppty.Id);
        System.debug('created oppty: ' + oppty);
        
        // start test
        System.debug('starting the test context...');
        Test.startTest();

		// switch context to the test user
		System.debug('switching running user context to admin user...');
		System.runAs(adminUser) {
			
			// set the test page context
			requestedPage = Page.OpportunityProductEdit;
			requestedPage.getParameters().put('RecordType',oppty.recordtypeid);
			requestedPage.getParameters().put('stage',oppty.stagename);
			requestedPage.getParameters().put('pbId',Test.getStandardPricebookId());
			requestedPage.getParameters().put('peId',pbe.Id);
			requestedPage.getParameters().put('oId',oppty.Id);
			Test.setCurrentPage(requestedPage);
			
			// set the page controller
			controller = new ApexPages.standardController(new OpportunityLineItem());
			controllerExtension = new ctlr_OpportunityProductEdit( controller );
			
			// call additional methods
			controllerExtension.jsonMessagesString = '{"Id":"00kQ0000006LKhQIAW","OpportunityId":"006Q0000007CHOJIA4","PricebookEntryId":"01u30000005Fe99AAC","isSuccess":"false","Errors":[{"Error":{"Message":"Please enter the Eligible Participants/Units for the Outsourcing Service.","StatusCode":"FIELD_CUSTOM_VALIDATION_EXCEPTION","Fields":[]}}]}';
			controllerExtension.refreshMessages();
			
		}
    }
}