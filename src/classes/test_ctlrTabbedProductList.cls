@isTest
private class test_ctlrTabbedProductList {
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
        List<dto_lineItemProduct> productDtos = null;
         
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
        
        User ausUser = [SELECT Id FROM User WHERE Reporting_Country__c = 'Australia' LIMIT 1];
        ausUser.Can_Revenue_Schedule__c = true;
        update ausUser;

        // create an opportunity
        System.debug('creating test opportunity...');
        Opportunity oppty = util_sampleDataGenerator.createOpportunity_US(account.Id);
        oppty.OwnerId = ausUser.Id;
        update oppty;
        System.assertNotEquals(null,oppty.Id);
        System.debug('opportunity created.');
        

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
        System.assertNotEquals(null, pfl3.Id);
        System.debug('field list created.');
        System.debug('creating product field list configuration...');
        Product_Field_List__c pfl4 = util_sampleDataGenerator.createProductFieldList_ReadOnly('Opportunity', 'Amount', 3, oppty.RecordTypeId, oppty.StageName, 'Consulting', null);
        System.assertNotEquals(null, pfl4.Id);
        System.debug('field list created.');
        
        // start the test
        System.debug('starting test...');
        Test.startTest();
        
        // set the test page context
        PageReference requestedPage = Page.Tabbed_Product_List;
        requestedPage.getParameters().put('id',oppty.Id);
        ApexPages.standardController controller = new ApexPages.standardController( oppty );
        ctlr_TabbedProductList controllerExtension = new ctlr_TabbedProductList( controller );
        Test.setCurrentPage(requestedPage);
        
        // Revenue Schedule : Test Begin ----- 
        // Added by : Amrita on “02/24/12”

        System.debug('creating opportunity line item...');
        OpportunityLineItem oli1 = util_sampleDataGenerator.createOpportunityProduct(oppty.Id, pbe1.Id, 3, 75.0);
        System.assertNotEquals(null,oli1.Id);
        System.debug('opportunity product created.');
        System.debug('creating opportunity line item...');
        OpportunityLineItem oli2 = util_sampleDataGenerator.createOpportunityProduct(oppty.Id, pbe2.Id, 2, 25.0);
        System.assertNotEquals(null,oli2.Id);
        System.debug('opportunity product created.');
        
        // initialize the page
        controllerExtension.init();
        
        // get the product dtos
        productDtos = controllerExtension.lineItemProducts;
        
        

        System.runAs(ausUser) {
            // create products on the opportunity
            

            PageReference requestedPage1 = Page.Tabbed_Product_List;

            requestedPage1.getParameters().put('id', oppty.Id);
            ApexPages.standardController controller1 = new ApexPages.standardController( oppty );
            ctlr_TabbedProductList controllerExtension1 = new ctlr_TabbedProductList( controller1 );
            Test.setCurrentPage(requestedPage1);
            String retPage = controllerExtension1.getRevenueSchedulePage();
         
            // Test for apex class "ctrl_OpportunityProductRedirectPage"
            PageReference requestedPage2 = Page.OpportunityProductRedirectPage;
            requestedPage2.getParameters().put('id', oli1.Id);
            ApexPages.standardController controller2 = new ApexPages.standardController( oli1 );
            ctrl_OpportunityProductRedirectPage controllerExtension2 = new ctrl_OpportunityProductRedirectPage( controller2 );
            Test.setCurrentPage(requestedPage2);
            String retPage1 = controllerExtension2.getRevenueSchedulePage();            
            //-----------------------
            
        }
        // Revenue Schedule : Test End ----- 
        
        
        
        // stop the test
        Test.stopTest();
        System.debug('test stopped.');
        
        // assert the results
        System.assertEquals(2, productDtos.size());     
    }
    
    /* static testMethod void myUnitTestRevSchedule() {
        
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
        
       
        // start the test
        System.debug('starting test...');
        Test.startTest();
        
        // Revenue Schedule : Test Begin ----- 
        // Added by : Amrita on “02/24/12”
        // Create Opportunity with other user login
        User otherUser = util_sampleDataGenerator.createHewittStandardUser();
        Account otherAccount = util_sampleDataGenerator.createAccount('Amrita Other TEST ACCOUNT', util_sampleDataGenerator.getRecordType('Account', 'Client Account Record Type').Id, 'United States', 'IL');
        Opportunity otherOpp1 = util_sampleDataGenerator.createOpportunity_US(otherAccount.Id);
        otherOpp1.OwnerId = otherUser.Id;
        OpportunityLineItem otherOppLi = util_sampleDataGenerator.createOpportunityProduct(otherOpp1.Id, pbe1.Id, 3, 75.0);
       //-----------------------
        
        // Test Revenue Schedule through Australian user
        User ausUser = util_sampleDataGenerator.createHewittStandardUser();
        ausUser.Reporting_Country__c = 'Australia';
        update ausUser;
        System.runAs(ausUser) { 

            // Test when Logged-In user is the Opportunity Owner
            PageReference requestedPage1 = Page.Tabbed_Product_List;
            Account account1 = util_sampleDataGenerator.createAccount('Amrita TEST ACCOUNT', util_sampleDataGenerator.getRecordType('Account', 'Client Account Record Type').Id, 'United States', 'IL');
            Opportunity opp1 = util_sampleDataGenerator.createOpportunity_US(account1.Id);
            OpportunityLineItem oppLi1 = util_sampleDataGenerator.createOpportunityProduct(opp1.Id, pbe1.Id, 3, 75.0);
            requestedPage1.getParameters().put('id',opp1.Id);
            ApexPages.standardController controller1 = new ApexPages.standardController( opp1 );
            ctlr_TabbedProductList controllerExtension1 = new ctlr_TabbedProductList( controller1 );
            Test.setCurrentPage(requestedPage1);
            String retPage = controllerExtension1.getRevenueSchedulePage();
            //-----------------------

            // Test when Logged-In user is NOT the Opportunity Owner
            PageReference requestedPage2 = Page.Tabbed_Product_List;
            requestedPage2.getParameters().put('id',otherOpp1.Id);
            ApexPages.standardController controller2 = new ApexPages.standardController( otherOpp1 );
            ctlr_TabbedProductList controllerExtension2 = new ctlr_TabbedProductList( controller2 );
            Test.setCurrentPage(requestedPage2);
            //String retPage2 = controllerExtension2.getRevenueSchedulePage();
            //-----------------------
         
            // Test for apex class "ctrl_OpportunityProductRedirectPage"
            PageReference requestedPage3 = Page.OpportunityProductRedirectPage;
            requestedPage3.getParameters().put('id',oppLi1.Id);
            ApexPages.standardController controller3 = new ApexPages.standardController( oppLi1 );
            ctrl_OpportunityProductRedirectPage controllerExtension3 = new ctrl_OpportunityProductRedirectPage( controller3 );
            Test.setCurrentPage(requestedPage3);
            String retPage3 = controllerExtension3.getRevenueSchedulePage();            
            //-----------------------
        }
        
        
        // Test Revenue Schedule through Non-Australian user
        User nonAusUser = util_sampleDataGenerator.createHewittStandardUser();
        nonAusUser.Reporting_Country__c = 'India';
        update nonAusUser;
        System.runAs(nonAusUser) {
            // Test when Logged-In user is the Opportunity Owner
            PageReference requestedPage1 = Page.Tabbed_Product_List;
            Account account1 = util_sampleDataGenerator.createAccount('Amrita2 TEST ACCOUNT', util_sampleDataGenerator.getRecordType('Account', 'Client Account Record Type').Id, 'United States', 'IL');
            Opportunity opp1 = util_sampleDataGenerator.createOpportunity_US(account1.Id);
            OpportunityLineItem oppLi1 = util_sampleDataGenerator.createOpportunityProduct(opp1.Id, pbe1.Id, 3, 75.0);
            requestedPage1.getParameters().put('id',opp1.Id);
            ApexPages.standardController controller1 = new ApexPages.standardController( opp1 );
            ctlr_TabbedProductList controllerExtension1 = new ctlr_TabbedProductList( controller1 );
            Test.setCurrentPage(requestedPage1);
            String retPage = controllerExtension1.getRevenueSchedulePage();
            //-----------------------

            // Test when Logged-In user is NOT the Opportunity Owner
            PageReference requestedPage2 = Page.Tabbed_Product_List;
            requestedPage2.getParameters().put('id',otherOpp1.Id);
            ApexPages.standardController controller2 = new ApexPages.standardController( otherOpp1 );
            ctlr_TabbedProductList controllerExtension2 = new ctlr_TabbedProductList( controller2 );
            Test.setCurrentPage(requestedPage2);
            //String retPage1 = controllerExtension2.getRevenueSchedulePage();
            //-----------------------
        }

        // Revenue Schedule : Test End ----- 
        // stop the test
        Test.stopTest();
        System.debug('test stopped.');
    }*/
}