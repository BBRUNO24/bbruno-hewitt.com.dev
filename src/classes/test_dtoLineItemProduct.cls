@isTest
private class test_dtoLineItemProduct {
	@testSetup 
    static void setupClientData() {
        /*
            Insert the Organizational_Defaults__c
        */
        Organizational_Defaults__c orgDefaultSettings = new Organizational_Defaults__c();
        orgDefaultSettings.Enable_CAPIS_Id_Assignment__c = false;
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
        dto_lineItemProduct dto1 = null;
        dto_lineItemProduct dto2 = null;
        
        // create products
        System.debug('create test product...');
        Product2 prod1 = util_sampleDataGenerator.createProduct('Product A', 'Consulting', true, 'Consulting');
        System.assertNotEquals(null,prod1.Id);
		System.debug('product created.');
        System.debug('create test product...');
        Product2 prod2 = util_sampleDataGenerator.createProduct('Product B', 'Consulting', false, 'Consulting');
        System.assertNotEquals(null,prod2.Id);
		System.debug('product created.');
		
		// add standard prices
		System.debug('adding standard price to product...');
		PricebookEntry pbe1 = util_sampleDataGenerator.createStandardPriceForProduct(prod1.Id, 100.0);
		System.assertNotEquals(null,pbe1.Id);
		System.debug('standard price added.');
		System.debug('adding standard price to product...');
		PricebookEntry pbe2 = util_sampleDataGenerator.createStandardPriceForProduct(prod2.Id, 50.0);
		System.assertNotEquals(null,pbe2.Id);
		System.debug('standard price added.');
        
		// create an account
		System.debug('creating test account...'); 
		Account account = util_sampleDataGenerator.createAccount_Client();
		System.assertNotEquals(null,account.Id);
		System.debug('account created.');
        
        // create an opportunity
        System.debug('creating test opportunity...');
        Opportunity oppty = util_sampleDataGenerator.createOpportunity_US(account.Id);
        System.assertNotEquals(null,oppty.Id);
		System.debug('opportunity created.');
        
        // create products on the opportunity
        System.debug('creating opportunity line item...');
        OpportunityLineItem oli1 = util_sampleDataGenerator.createOpportunityProduct(oppty.Id, pbe1.Id, 3, 75.0);
        System.assertNotEquals(null,oli1.Id);
		System.debug('opportunity product created.');
        System.debug('creating opportunity line item...');
        OpportunityLineItem oli2 = util_sampleDataGenerator.createOpportunityProduct(oppty.Id, pbe2.Id, 2, 25.0);
        System.assertNotEquals(null,oli2.Id);
		System.debug('opportunity product created.');

		// delete existing fields for oppty stage & record type
		System.debug('deleting existing product field lists...');
		delete [select id from Product_Field_List__c where Opportunity_Record_Type__c = :oppty.RecordTypeId and Opportunity_Stage__c = :oppty.StageName];
		System.debug('configuration deleted.');
		
		// create a configuration for the read-only interface based on a stage, record type, etc.
		System.debug('creating product field list configuration...');
		Product_Field_List__c pfl1 = util_sampleDataGenerator.createProductFieldList_ReadOnly('OpportunityLineItem', 'Type__c', 1, null, null, null, prod1.Id);
		System.assertNotEquals(null, pfl1.Id);
		System.debug('field list created.');
		System.debug('creating product field list configuration...');
		Product_Field_List__c pfl2 = util_sampleDataGenerator.createProductFieldList_ReadOnly('OpportunityLineItem', 'Platform__c', 1, oppty.RecordTypeId, oppty.StageName, 'Consulting', null);
		System.assertNotEquals(null, pfl2.Id);
		System.debug('field list created.');
		System.debug('creating product field list configuration...');
		Product_Field_List__c pfl3 = util_sampleDataGenerator.createProductFieldList_ReadOnly('OpportunityLineItem', 'Fee_Commission__c', 2, oppty.RecordTypeId, oppty.StageName, 'Consulting', null);
		System.assertNotEquals(null, pfl2.Id);
		System.debug('field list created.');

		// start the test
		System.debug('starting test...');
		Test.startTest();
		
		dto1 = new dto_lineItemProduct(oppty, oli1, pbe1, prod1, new Product_Field_List__c[]{pfl1, pfl2, pfl3});
		dto2 = new dto_lineItemProduct(oppty, oli2, pbe2, prod2, new Product_Field_List__c[]{pfl1, pfl2, pfl3});
	
		// stop the test
		Test.stopTest();
		System.debug('test stopped.');
	
		// assert the results
		System.assertEquals(1, dto1.FieldList.size());
		System.assertEquals(2, dto2.FieldList.size());
		
    }
}