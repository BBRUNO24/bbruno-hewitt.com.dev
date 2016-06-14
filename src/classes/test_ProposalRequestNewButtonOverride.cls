@isTest
private class test_ProposalRequestNewButtonOverride {
    @testSetup static void setupAonData() {
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

    static testMethod void unitTestMethod() {
        //Create an account
        Account acc = util_sampleDataGenerator.createAccount_Client();
        System.assertNotEquals(null, acc.Id);
        
        //Create a Competitor
        Competitor__c myCompetitor = new Competitor__c();
        myCompetitor.Name = 'Hot Shot Competitor';
        insert myCompetitor;
        System.assertNotEquals(null, myCompetitor.Id);
        
        //Create an opportunity
        Opportunity myOpp = util_sampleDataGenerator.createOpportunity_US(acc.id);
        System.assertNotEquals(null, myOpp.Id);
        myOpp.Current_Provider_Reference__c = myCompetitor.Id;
        myOpp.Competitor__c = 'CIGNA';
        update myOpp;
        
        //Create a product        
        Product2 product = util_sampleDataGenerator.createProduct('CHINTAN PRODUCT', 'Consulting', false, 'Consulting');
        System.assertNotEquals(null, product.Id);                
                  
        //Create a pricebookentry        
        PricebookEntry pbe = util_sampleDataGenerator.createStandardPriceForProduct(product.id, 100.0);       
        System.assertNotEquals(null, pbe.Id);
          
        OpportunityLineItem oli = util_sampleDataGenerator.createOpportunityProduct(myOpp.Id, pbe.Id, 5, 150.0); 
        System.assertNotEquals(null, oli.Id);
        oli = [Select Service_Start_Date__c from OpportunityLineItem Where Id = :oli.Id];
        oli.Service_Start_Date__c = Date.today();
        update oli;        
      
        Test.startTest();
        
            //Set up the test page
            Pagereference pageRef = Page.ProposalRequestNewButtonOverride;
            pageRef.getParameters().put('retURL', ' ' + myOpp.Id);
        
            //Set the test context
            test.setCurrentPage(pageRef);
            System.debug('CPA CurrentPage URL is: ' + pageRef.getUrl());
        
            //Grab an instance to the controller
            ApexPages.StandardController stdController = new ApexPages.StandardController(new Proposal_Request__c());
            ctlr_ProposalRequestNewButtonOverride myController = new ctlr_ProposalRequestNewButtonOverride(stdController);
            myController.oppId = myOpp.Id;
        
            //Set this opp as Bundled
            Opportunity myParentOpp = util_sampleDataGenerator.createOpportunity_US(acc.id);
        	System.assertNotEquals(null, myParentOpp.Id);
            myOpp = [Select Id, Lead_Opportunity_Name__c, Bundled_Opportunity__c from Opportunity Where Id = :myOpp.Id];
            myOpp.Bundled_Opportunity__c = true;
            myOpp.Lead_Opportunity_Name__c = myParentOpp.Id;
            update myOpp;
            myOpp = [Select Id, Bundled_Opportunity__c from Opportunity Where Id = :myOpp.Id];
            System.debug('CPA Bundled is: ' + myOpp.Bundled_Opportunity__c);
            
            //Verify initialization and no redirection
            pageRef = myController.init();
            System.assertEquals(pageRef, null);
            System.debug('CPA trapped error for bundle');
            
            //Update opp Stage
            myOpp = [Select Id, StageName, Probability, Bundled_Opportunity__c from Opportunity Where Id = :myOpp.Id];
            myOpp.StageName = 'Propose Solution';
            myOpp.Probability = 25;
            myOpp.Bundled_Opportunity__c = false;
            update myOpp;
            
            //Verify initialization
            pageRef = myController.init();
            String nextPage = pageRef.getUrl();
            System.debug('CPA nextPage is: ' + nextPage);
            //The name of the opp is Killer Whale Opportunity
            System.assertEquals(nextPage.contains('Killer+Whale'), true);
            
            //Verify the Return button functionality
            pageRef = myController.returnBack();
            System.assertEquals(pageRef.getUrl(), '/' + myOpp.Id);
            
        Test.stopTest();
    } //unitTestMethod
}