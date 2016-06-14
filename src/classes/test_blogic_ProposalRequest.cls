@isTest
private class test_blogic_ProposalRequest {
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
            Insert the OpportunityDeletionSettings__c
        */
        OpportunityDeletionSettings__c oppDeleteSettings = new OpportunityDeletionSettings__c();
        oppDeleteSettings.Closed_Approved__c = true;
        oppDeleteSettings.Closed_Lost__c = true;
        oppDeleteSettings.Closed_Won__c = true;
        oppDeleteSettings.Negotiate__c = true;
        oppDeleteSettings.Non_Qualified_Opportunity__c = true;
        oppDeleteSettings.Propose_Solution__c = true;
        oppDeleteSettings.Qualify_Opportunity__c = true;
        insert oppDeleteSettings;

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
    static testMethod void saveProposalRequest() {    
        //Create an Account
        Account account = util_sampleDataGenerator.createAccount_Client();
        System.assertNotEquals(null, account.Id);

        //Create an opportunity
        Opportunity oppty = util_sampleDataGenerator.createOpportunity_US(account.Id);
        System.assertNotEquals(null, oppty.Id);
          
        //Create a product        
        Product2 product = util_sampleDataGenerator.createProduct('LJ TEST PRODUCT', 'Consulting', false, 'Consulting');
        System.assertNotEquals(null, product.Id);                
                  
        //Create a pricebookentry        
        PricebookEntry pbe = util_sampleDataGenerator.createStandardPriceForProduct(product.id, 100.0);       
        System.assertNotEquals(null, pbe.Id);
          
        //Tie the service to the opp
        OpportunityLineItem oli = util_sampleDataGenerator.createOpportunityProduct(oppty.Id, pbe.Id, 5, 150.0); 
        System.assertNotEquals(null, oli.Id);
          
        Test.startTest();
          
        //Create Proposal Request
        Proposal_Request__c myProposal = new Proposal_Request__c();
        myProposal.Type__c = 'Ben Admin Proposal';
        myProposal.Requestor__c = UserInfo.getUserID();
        myProposal.RFP_Type__c = 'RFP';
        myProposal.Status__c = 'New';
        myProposal.What_is_Needed__c = 'Full Sales Support';
        myProposal.Delivery_Method__c = 'CD';
        myProposal.Account_Executive__c = UserInfo.getUserID();
        myProposal.Sales_Executive__c = UserInfo.getUserID();
        myProposal.Date_RFP_Received__c = Date.today();
        myProposal.Proposal_Submission_Due_Date__c = Date.today();
        myProposal.Vendor_Questions_Due_to_Customer__c = Date.today();
        myProposal.Estimated_Completion_Date__c = Date.today();
        myProposal.Expected_RFP_Decision_Date__c = Date.today();
        myProposal.Account__c = account.Id;
        myProposal.Opportunity__c = oppty.Id;
        myProposal.Existing_Aon_Hewitt_Relationship__c = 'Consulting';
          
        insert myProposal;
        System.AssertNotEquals(NULL ,myProposal.Id);
        
        //Pull Associated Services
        List<Associated_Service__c> associatedServices = [select id from Associated_Service__c where Proposal_Request__c = :myProposal.id];
        System.debug('Associated Services ' + associatedServices);
          
        //Verify
        System.assertequals(associatedServices.size(), 1);
        
        //Pull Opp
        oppty = [Select Id, RFP_Created__c from Opportunity Where Id = :oppty.Id];
        
        //Verify
        System.assertEquals(true, oppty.RFP_Created__c);
        
        //Create bundled Opp
        Opportunity bundled = util_sampleDataGenerator.createOpportunity_US(account.Id);
        System.assertNotEquals(bundled.Id, null);
        OpportunityLineItem oli2 = util_sampleDataGenerator.createOpportunityProduct(bundled.Id, pbe.Id, 5, 150.0);
        System.assertNotEquals(oli2.Id, null);
        //Reset flag
        util_globalUtilityMethods.setRunOnceFlag(false);
        bundled = [Select Id, Lead_Opportunity_Name__c from Opportunity Where Id = :bundled.Id];
        bundled.Lead_Opportunity_Name__c = oppty.Id;
        update bundled;
        
        //Pull Associated Services
       	associatedServices = [select id from Associated_Service__c where Proposal_Request__c = :myProposal.id];
        System.debug('Associated Services ' + associatedServices);
          
        //Verify
        System.assertequals(associatedServices.size(), 2);
        
        //Pull Opps
        oppty = [Select Id, RFP_Created__c from Opportunity Where Id = :oppty.Id];
        bundled = [Select Id, RFP_Created__c from Opportunity Where Id = :bundled.Id];
        
        //Verify
        System.assertEquals(true, oppty.RFP_Created__c);
        System.assertEquals(true, bundled.RFP_Created__c);
        
        //add a service
        OpportunityLineItem oli3 = util_sampleDataGenerator.createOpportunityProduct(oppty.Id, pbe.Id, 5, 150.0); 
        System.assertNotEquals(null, oli3.Id);
                
        //Pull Associated Services
       	associatedServices = [select id from Associated_Service__c where Proposal_Request__c = :myProposal.id];
        System.debug('Associated Services ' + associatedServices);
          
        //Verify
        System.assertequals(associatedServices.size(), 3);

        Test.stopTest();
    } //saveProposalRequest
    
    
    static testMethod void testSyncServices() {    
        //Create an Account
        Account account = util_sampleDataGenerator.createAccount_Client();
        System.assertNotEquals(null, account.Id);

        //Create an opportunity
        Opportunity oppty = util_sampleDataGenerator.createOpportunity_US(account.Id);
        System.assertNotEquals(null, oppty.Id);
          
        //Create a product        
        Product2 product = util_sampleDataGenerator.createProduct('LJ TEST PRODUCT', 'Consulting', false, 'Consulting');
        System.assertNotEquals(null, product.Id);                
                  
        //Create a pricebookentry        
        PricebookEntry pbe = util_sampleDataGenerator.createStandardPriceForProduct(product.id, 100.0);       
        System.assertNotEquals(null, pbe.Id);
          
        //Tie two services to the opp
        OpportunityLineItem oli = util_sampleDataGenerator.createOpportunityProduct(oppty.Id, pbe.Id, 5, 150.0);
        System.assertNotEquals(null, oli.Id);
          
        Test.startTest();
          
        //Create Proposal Request
        Proposal_Request__c myProposal = new Proposal_Request__c();
        myProposal.Type__c = 'Ben Admin Proposal';
        myProposal.Requestor__c = UserInfo.getUserID();
        myProposal.RFP_Type__c = 'RFP';
        myProposal.Status__c = 'New';
        myProposal.What_is_Needed__c = 'Full Sales Support';
        myProposal.Delivery_Method__c = 'CD';
        myProposal.Account_Executive__c = UserInfo.getUserID();
        myProposal.Sales_Executive__c = UserInfo.getUserID();
        myProposal.Date_RFP_Received__c = Date.today();
        myProposal.Proposal_Submission_Due_Date__c = Date.today();
        myProposal.Vendor_Questions_Due_to_Customer__c = Date.today();
        myProposal.Estimated_Completion_Date__c = Date.today();
        myProposal.Expected_RFP_Decision_Date__c = Date.today();
        myProposal.Account__c = account.Id;
        myProposal.Opportunity__c = oppty.Id;
        myProposal.Existing_Aon_Hewitt_Relationship__c = 'Consulting';
          
        insert myProposal;
        System.AssertNotEquals(NULL ,myProposal.Id);
        
        //Create bundled Opp
        Opportunity bundled = util_sampleDataGenerator.createOpportunity_US(account.Id);
        System.assertNotEquals(bundled.Id, null);
        OpportunityLineItem oli2 = util_sampleDataGenerator.createOpportunityProduct(bundled.Id, pbe.Id, 5, 150.0);
        OpportunityLineItem oli3 = util_sampleDataGenerator.createOpportunityProduct(bundled.Id, pbe.Id, 5, 150.0);
        System.assertNotEquals(oli2.Id, null);
        System.assertNotEquals(oli3.Id, null);
        //Reset flag
        util_globalUtilityMethods.setRunOnceFlag(false);
        bundled = [Select Id, Lead_Opportunity_Name__c from Opportunity Where Id = :bundled.Id];
        bundled.Lead_Opportunity_Name__c = oppty.Id;
        update bundled;
        
        //delete service
        util_globalUtilityMethods.setRunOnceFlag(false);
        delete oli2;
        
        //Pull Associated Services
       	List<Associated_Service__c> associatedServices = [select id from Associated_Service__c where Proposal_Request__c = :myProposal.id];
        System.debug('Associated Services ' + associatedServices);
          
        //Verify
        System.assertequals(associatedServices.size(), 2);

        Test.stopTest();
    } //testSyncServices
    
    
    static testMethod void testDeleteOpp() {    
        //Create an Account
        Account account = util_sampleDataGenerator.createAccount_Client();
        System.assertNotEquals(null, account.Id);

        //Create an opportunity
        Opportunity oppty = util_sampleDataGenerator.createOpportunity_US(account.Id);
        System.assertNotEquals(null, oppty.Id);
          
        //Create a product        
        Product2 product = util_sampleDataGenerator.createProduct('LJ TEST PRODUCT', 'Consulting', false, 'Consulting');
        System.assertNotEquals(null, product.Id);                
                  
        //Create a pricebookentry        
        PricebookEntry pbe = util_sampleDataGenerator.createStandardPriceForProduct(product.id, 100.0);       
        System.assertNotEquals(null, pbe.Id);
          
        //Tie two services to the opp
        OpportunityLineItem oli = util_sampleDataGenerator.createOpportunityProduct(oppty.Id, pbe.Id, 5, 150.0);
        System.assertNotEquals(null, oli.Id);
          
        Test.startTest();
          
        //Create Proposal Request
        Proposal_Request__c myProposal = new Proposal_Request__c();
        myProposal.Type__c = 'Ben Admin Proposal';
        myProposal.Requestor__c = UserInfo.getUserID();
        myProposal.RFP_Type__c = 'RFP';
        myProposal.Status__c = 'New';
        myProposal.What_is_Needed__c = 'Full Sales Support';
        myProposal.Delivery_Method__c = 'CD';
        myProposal.Account_Executive__c = UserInfo.getUserID();
        myProposal.Sales_Executive__c = UserInfo.getUserID();
        myProposal.Date_RFP_Received__c = Date.today();
        myProposal.Proposal_Submission_Due_Date__c = Date.today();
        myProposal.Vendor_Questions_Due_to_Customer__c = Date.today();
        myProposal.Estimated_Completion_Date__c = Date.today();
        myProposal.Expected_RFP_Decision_Date__c = Date.today();
        myProposal.Account__c = account.Id;
        myProposal.Opportunity__c = oppty.Id;
        myProposal.Existing_Aon_Hewitt_Relationship__c = 'Consulting';
          
        insert myProposal;
        System.AssertNotEquals(NULL ,myProposal.Id);
        
        //Create bundled Opp
        Opportunity bundled = util_sampleDataGenerator.createOpportunity_US(account.Id);
        System.assertNotEquals(bundled.Id, null);
        OpportunityLineItem oli2 = util_sampleDataGenerator.createOpportunityProduct(bundled.Id, pbe.Id, 5, 150.0);
        OpportunityLineItem oli3 = util_sampleDataGenerator.createOpportunityProduct(bundled.Id, pbe.Id, 5, 150.0);
        System.assertNotEquals(oli2.Id, null);
        System.assertNotEquals(oli3.Id, null);
        bundled = [Select Id, Lead_Opportunity_Name__c from Opportunity Where Id = :bundled.Id];
        bundled.Lead_Opportunity_Name__c = oppty.Id;
        update bundled;
        
        //delete opp
        delete bundled;
        
        //Pull Associated Services
       	List<Associated_Service__c> associatedServices = [select id from Associated_Service__c where Proposal_Request__c = :myProposal.id];
        System.debug('Associated Services ' + associatedServices);
          
        //Verify
        System.assertequals(associatedServices.size(), 1);

        Test.stopTest();
    } //testDeleteOpp
    
    
    //00077996-Ritu Sharma-Test code for updateOpportunity function
    static testMethod void test_updateOpportunity() {
        Integer i = 0;
        Account acc = Null;
        Opportunity opp = Null;
        Proposal_Request__c proposal = Null;        
        List<Account> accList = new List<Account>(); 
        List<Opportunity> oppList = new List<Opportunity>();
        List<Proposal_Request__c> proposalList = new List<Proposal_Request__c>();        
        
        //Declaring and Initializing record type ids
        String accRecTypeID = util_sampleDataGenerator.getRecordType('Account', 'Client Account Record Type').Id;
        String oppRecTypeID = util_sampleDataGenerator.getRecordType('Opportunity', 'Oppty Record').Id;
        
        //Creating accounts               
        for (i=0;i<202;i++) {
            acc = new Account();
            acc.RecordTypeId = accRecTypeID;
            acc.Name = 'Test Acc-'+i;
            acc.SDO_Billing_Country_Name__c = 'United States';
            acc.BillingPostalCode = '11111';
            acc.BillingState = 'IL';
            accList.add(acc);
        }
        insert accList;
        
        //Checking if accounts have been inserted
        for (i=0;i<202;i++)
            System.assertNotEquals(null, accList[i].Id);
        
        //Creating opportinities
        for (i=0;i<200;i++) {
            opp = new Opportunity();
            opp.RecordTypeId = oppRecTypeId;
            opp.accountId = accList[i].id;
            opp.name = 'Test Opp-'+i;
            opp.amount = 1000.0;
            opp.StageName = 'Qualify Opportunity';
            opp.CloseDate = Date.today().addDays(30);
            opp.Probability = 25;
            opp.Sourcing_Provider__c=accList[200].id;
            oppList.add(opp);
        }
        insert oppList;
        
        //Checking if opportunities have been inserted
        for (i=0;i<200;i++)
            System.assertNotEquals(null, oppList[i].Id);

        //Creating Proposal Requests        
        for (i=0;i<200;i++) {
            proposal = new Proposal_Request__c();
            proposal.Type__c = 'Ben Admin Proposal';
            proposal.Requestor__c = UserInfo.getUserID();
            proposal.RFP_Type__c = 'RFP';
            proposal.Status__c = 'New';
            proposal.What_is_Needed__c = 'Full Sales Support';
            proposal.Delivery_Method__c = 'CD';
            proposal.Account_Executive__c = UserInfo.getUserID();
            proposal.Sales_Executive__c = UserInfo.getUserID();
            proposal.Date_RFP_Received__c = Date.today();
            proposal.Proposal_Submission_Due_Date__c = Date.today();
            proposal.Vendor_Questions_Due_to_Customer__c = Date.today();
            proposal.Estimated_Completion_Date__c = Date.today();
            proposal.Expected_RFP_Decision_Date__c = Date.today();
            proposal.Account__c = accList[i].Id;
            proposal.Opportunity__c = oppList[i].Id;
            proposal.Existing_Aon_Hewitt_Relationship__c = 'Consulting';
            proposal.Third_Party_Advisors_Involved__c = accList[201].ID;
            proposalList.add(proposal);
        }
        insert proposalList;
        
        //Checking if proposal requests have been inserted
        for (i=0;i<200;i++)
            System.assertNotEquals(null, proposalList[i].Id);            
         
        proposalList = [Select ID,Third_Party_Advisors_Involved__c from Proposal_Request__c where ID IN :proposalList];
        oppList = [Select ID,Sourcing_Provider__c from Opportunity where ID IN:oppList];
        
        //Checking if sourcing provider has been updated in opps
        for (i=0;i<200;i++)        
            System.AssertEquals(proposalList[i].Third_Party_Advisors_Involved__c,oppList[i].Sourcing_Provider__c);      
    }
}