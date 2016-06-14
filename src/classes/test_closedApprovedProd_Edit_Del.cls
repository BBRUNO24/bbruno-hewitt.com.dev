/**
 * Test Class for test for the Class: closedApprovedProd_Edit_Del
 */
@isTest
private class test_closedApprovedProd_Edit_Del {
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

        //Creating an account and contact
        Account acc = util_sampleDataGenerator.createAccount_Client();
        Opportunity opp = util_sampleDataGenerator.createOpportunity_US(acc.Id);
        Contact con = util_sampleDataGenerator.createContact_Internal(acc.ID); 
        //Create a product        
        Product2 product = util_sampleDataGenerator.createProduct('LJ TEST PRODUCT', 'Consulting', false, 'Consulting');
        System.assertNotEquals(null, product.Id);                
                  
        //Create a pricebookentry        
        PricebookEntry pbe = util_sampleDataGenerator.createStandardPriceForProduct(product.id, 100.0);       
        System.assertNotEquals(null, pbe.Id);

        OpportunityLineItem oli = util_sampleDataGenerator.createOpportunityProduct(opp.Id, pbe.Id, 1, 500);
    }
    static testMethod void closedApproved_Prod() {
        
        ApexPages.StandardController controller;
        
        Opportunity opp1 = [Select o.StageName, o.Id From Opportunity o limit 1];
        OpportunityLineItem oli = [Select o.OpportunityId, o.Id From OpportunityLineItem o limit 1];
        string oppId = oli.OpportunityId;
        //Opportunity opp1 = [Select o.StageName, o.Id From Opportunity o where o.Id =: oppId];
        Competitor__c comp1 = [Select c.Id From Competitor__c c limit 1];
                
        
        //Coverage for 'Closed Approved' opp
        opp1.StageName = 'Closed Approved';
        opp1.Chosen_Provider__c = 'test';
        opp1.Chosen_Provider_Reference__c = comp1.Id;
        opp1.Current_Provider__c = 'test';
        opp1.Current_Provider_Reference__c = comp1.Id;
        opp1.Contracting_Entity__c = 'test';
        opp1.Competitor__c = 'test';
        opp1.Reason_Won_or_Lost__c = 'test';
        update opp1;
        
        ApexPages.currentPage().getParameters().put('Id',oli.id);        
        closedApprovedProd_Edit_Del test1 = new closedApprovedProd_Edit_Del(controller);
        
        test1.del();
        test1.edit();
        test1.ret();
        
        //Coverage for 'Non-Closed Approved' opp
        opp1.StageName = 'Closed Won';
        update opp1;
        
        ApexPages.currentPage().getParameters().put('Id',oli.id);
        closedApprovedProd_Edit_Del test2 = new closedApprovedProd_Edit_Del(controller);
               
        test2.del();
        test2.edit();
        test2.ret();
    }
}