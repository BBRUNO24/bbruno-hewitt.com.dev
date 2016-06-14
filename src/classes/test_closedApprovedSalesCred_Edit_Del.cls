/**
 * Test Class for test for the Class: closedApprovedSalesCred_Edit_Del
 */
@isTest
private class test_closedApprovedSalesCred_Edit_Del {
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
    }
    static testMethod void closedApproved_salesCred() {
        ApexPages.StandardController controller;        
        
        Opportunity opp1 = [Select o.StageName, o.Id From Opportunity o limit 1];
        Competitor__c comp1 = [Select c.Id From Competitor__c c limit 1];

        Contact con = [SELECT Id FROM Contact LIMIT 1];
        
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
        
        Sales_Credit__c scTest = new Sales_Credit__c(Credit_Recipient__c = con.ID,Sales_Credit__c = 10,Sales_Assist_Credit__c = 10,Dual_Initiation_Credit__c = 10,Related_Opportunity__c = opp1.Id);
        insert scTest;
        
        ApexPages.currentPage().getParameters().put('Id',scTest.id);        
        closedApprovedSalesCred_Edit_Del test1 = new closedApprovedSalesCred_Edit_Del(controller);
        
        test1.edit();
        test1.ret();
        test1.del();
        
       /* Opportunity opp = util_sampleDataGenerator.createOpportunity_US([SELECT Id FROM Account LIMIT 1].Id);        
        //Coverage for 'Non-Closed Approved' opp
        opp.StageName = 'Closed Won';
        update opp;
        
        Sales_Credit__c scTest2 = new Sales_Credit__c (Credit_Recipient__c = con.ID,Sales_Credit__c = 10, Sales_Assist_Credit__c = 10,Dual_Initiation_Credit__c = 10,Related_Opportunity__c = opp.Id);
        insert scTest2;
        
        ApexPages.currentPage().getParameters().put('Id',scTest2.id);
        closedApprovedSalesCred_Edit_Del test2 = new closedApprovedSalesCred_Edit_Del(controller);
 
        test2.edit();
        test2.ret();               
        test2.del(); */              
    }
}