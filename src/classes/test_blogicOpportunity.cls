@isTest
private class test_blogicOpportunity{
    @testSetup 
    static void setupTestData() {

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

        /*
            Insert the OpportunityDeletionSettings__c
        */
        OpportunityDeletionSettings__c oppDeleteSettings = new OpportunityDeletionSettings__c();
        oppDeleteSettings.Closed_Approved__c = true;
        oppDeleteSettings.Closed_Lost__c = true;
        oppDeleteSettings.Closed_Won__c = true;
        oppDeleteSettings.Negotiate__c = true;
        oppDeleteSettings.Non_Qualified_Opportunity__c = true;
        oppDeleteSettings.Propose_Solution__c = false;
        oppDeleteSettings.Qualify_Opportunity__c = true;
        insert oppDeleteSettings;
    }
    static testMethod void testCreateShadowOpportunityProducts() {
        // create a product
        Product2 product = util_sampleDataGenerator.createProduct('LJ TEST PRODUCT', 'Consulting', false, 'Consulting');
        System.assertNotEquals(null, product.Id);
        
        // create a pricebookentry
        PricebookEntry pbe = util_sampleDataGenerator.createStandardPriceForProduct(product.id, 100.0);
        System.assertNotEquals(null, pbe.Id);
        
        // create an account
        Account account = util_sampleDataGenerator.createAccount_Client();
        System.assertNotEquals(null, account.Id);
        
        // create an opportunity
        Opportunity oppty = util_sampleDataGenerator.createOpportunity_US(account.Id);
        System.assertNotEquals(null, oppty.Id);
        
        // start test
        test.startTest();
        
        // create a opportunity line item
        OpportunityLineItem oli = util_sampleDataGenerator.createOpportunityProduct(oppty.Id, pbe.Id, 5, 150.0);
        System.assertNotEquals(null, oli.Id);
        
        // stop test
        test.stopTest();
        
        // assert results
        oli = [select id, opportunity_product__c from OpportunityLineItem where id = :oli.Id];
        System.assertNotEquals(null, oli.Opportunity_Product__c);
        Opportunity_Product__c shadowOli = [select id, name, opportunity__c, product2__c from Opportunity_Product__c where Id = :oli.Opportunity_Product__c];
        System.assertEquals('LJ TEST PRODUCT', shadowOli.Name);
        System.assertEquals(oppty.Id, shadowOli.opportunity__c);
        System.assertEquals(product.Id, shadowOli.product2__c);
    } //testCreateShadowOpportunityProducts
    
    
    static testMethod void testDeleteShadowOpportunityProducts() {
        // create a product
        Product2 product = util_sampleDataGenerator.createProduct('LJ TEST PRODUCT', 'Consulting', false, 'Consulting');
        System.assertNotEquals(null, product.Id);
        
        // create a pricebookentry
        PricebookEntry pbe = util_sampleDataGenerator.createStandardPriceForProduct(product.id, 100.0);
        System.assertNotEquals(null, pbe.Id);
        
        // create an account
        Account account = util_sampleDataGenerator.createAccount_Client();
        System.assertNotEquals(null, account.Id);
        
        // create an opportunity
        Opportunity oppty = util_sampleDataGenerator.createOpportunity_US(account.Id);
        System.assertNotEquals(null, oppty.Id);
        
        // create a opportunity line item
        OpportunityLineItem oli = util_sampleDataGenerator.createOpportunityProduct(oppty.Id, pbe.Id, 5, 150.0);
        System.assertNotEquals(null, oli.Id);
        
        // verify an opportunity product was populated
        oli = [select id, opportunity_product__c from OpportunityLineItem where id = :oli.Id];
        System.assertNotEquals(null, oli.Opportunity_Product__c);
        
        String oldOpptyProductId = oli.Opportunity_Product__c;
        
        // start test
        test.startTest();
        
        delete oli;
        
        test.stopTest();
        
        // verify the shadow record was deleted
        Integer recordCount = [select count() from Opportunity_Product__c where id = :oldOpptyProductId];
        System.assertEquals(0,recordCount);
    } //testDeleteShadowOpportunityProducts
    
    
    static testMethod void testUpdateShadowOpportunityProducts() {
        
        // create a product
        Product2 product = util_sampleDataGenerator.createProduct('LJ TEST PRODUCT', 'Consulting', false, 'Consulting');
        System.assertNotEquals(null, product.Id);
        
        // create a pricebookentry
        PricebookEntry pbe = util_sampleDataGenerator.createStandardPriceForProduct(product.id, 100.0);
        System.assertNotEquals(null, pbe.Id);
        
        // create an account
        Account account = util_sampleDataGenerator.createAccount_Client();
        System.assertNotEquals(null, account.Id);
        
        // create an opportunity
        Opportunity oppty = util_sampleDataGenerator.createOpportunity_US(account.Id);
        System.assertNotEquals(null, oppty.Id);
        
        // create a opportunity line item
        OpportunityLineItem oli = util_sampleDataGenerator.createOpportunityProduct(oppty.Id, pbe.Id, 5, 150.0);
        System.assertNotEquals(null, oli.Id);
        
        // verify an opportunity product was populated
        oli = [select id, quantity, opportunity_product__c from OpportunityLineItem where id = :oli.Id];
        System.assertNotEquals(null, oli.Opportunity_Product__c);
        
        // verify the quantity is not equals to 6
        Opportunity_Product__c opptyProd = [select id, quantity__c from Opportunity_Product__c where id = :oli.Opportunity_Product__c];
        System.assertNotEquals(6.0, opptyProd.Quantity__c);
        
        // start test
        test.startTest();
        
        oli.Quantity = 6.0;
        update oli;
        
        test.stopTest();
        
        // verify the shadow record was updated
        opptyProd = [select id, quantity__c from Opportunity_Product__c where id = :oli.Opportunity_Product__c];
        System.assertEquals(6.0, opptyProd.Quantity__c);
    } //testUpdateShadowOpportunityProducts
    
    
    static testMethod void testCreateSTCOLIXref_STC() {
        // create a product
        Product2 product = util_sampleDataGenerator.createProduct('LJ TEST PRODUCT', 'Consulting', false, 'Consulting');
        System.assertNotEquals(null, product.Id);
        
        // create a product
        Product2 product2 = util_sampleDataGenerator.createProduct('LJ TEST PRODUCT2', 'Consulting', false, 'Consulting');
        System.assertNotEquals(null, product2.Id);
        
        // create a pricebookentry
        PricebookEntry pbe = util_sampleDataGenerator.createStandardPriceForProduct(product.id, 100.0);
        System.assertNotEquals(null, pbe.Id);
        
        // create a pricebookentry
        PricebookEntry pbe2 = util_sampleDataGenerator.createStandardPriceForProduct(product2.id, 50.0);
        System.assertNotEquals(null, pbe2.Id);
        
        // create an account
        Account account = util_sampleDataGenerator.createAccount_Client();
        System.assertNotEquals(null, account.Id);
        
        // create internal contact
        Contact internalContact = util_sampleDataGenerator.createContact_Internal(account.Id);
        System.assertNotEquals(null, internalContact.Id);
        
        // create an opportunity
        Opportunity oppty = util_sampleDataGenerator.createOpportunity_US(account.Id);
        System.assertNotEquals(null, oppty.Id);
        
        // create a opportunity line item
        OpportunityLineItem oli = util_sampleDataGenerator.createOpportunityProduct(oppty.Id, pbe.Id, 5, 150.0);
        System.assertNotEquals(null, oli.Id);
        
        // create a opportunity line item
        OpportunityLineItem oli2 = util_sampleDataGenerator.createOpportunityProduct(oppty.Id, pbe2.Id, 3, 100.0);
        System.assertNotEquals(null, oli2.Id);
        
        // start test
        test.startTest();
        
        // create a sales credit
        Sales_Credit__c stc = util_sampleDataGenerator.createSalesCredit(oppty.Id, internalContact.Id);
        
        // stop test
        test.stopTest();
        
        // assert that two xref entries were created
        List <OpportunityProduct_SalesTeamCredit__c> xrefEntries = [select id from OpportunityProduct_SalesTeamCredit__c where SalesTeamCreditID__c = :stc.Id];
        System.assertEquals(2, xrefEntries.size());
    } //testCreateSTCOLIXref_STC
    
    
    static testMethod void testCreateSTCOLIXref_OLI() {
        // create a product
        Product2 product = util_sampleDataGenerator.createProduct('LJ TEST PRODUCT', 'Consulting', false, 'Consulting');
        System.assertNotEquals(null, product.Id);
        
        // create a pricebookentry
        PricebookEntry pbe = util_sampleDataGenerator.createStandardPriceForProduct(product.id, 100.0);
        System.assertNotEquals(null, pbe.Id);
        
        // create an account
        Account account = util_sampleDataGenerator.createAccount_Client();
        System.assertNotEquals(null, account.Id);
        
        // create internal contact
        Contact internalContact = util_sampleDataGenerator.createContact_Internal(account.Id);
        System.assertNotEquals(null, internalContact.Id);
        
        // create internal contact
        Contact internalContact2 = util_sampleDataGenerator.createContact_Internal(account.Id);
        System.assertNotEquals(null, internalContact2.Id);
        
        // create an opportunity
        Opportunity oppty = util_sampleDataGenerator.createOpportunity_US(account.Id);
        System.assertNotEquals(null, oppty.Id);
        
        // create a sales credit
        Sales_Credit__c stc = util_sampleDataGenerator.createSalesCredit(oppty.Id, internalContact.Id);
        System.assertNotEquals(null, stc.Id);
        
        // create a sales credit
        Sales_Credit__c stc2 = util_sampleDataGenerator.createSalesCredit(oppty.Id, internalContact2.Id);
        System.assertNotEquals(null, stc2.Id);
        
        // start test
        test.startTest();
        // create a opportunity line item
        OpportunityLineItem oli = util_sampleDataGenerator.createOpportunityProduct(oppty.Id, pbe.Id, 5, 150.0);
        System.assertNotEquals(null, oli.Id);
        
        // stop test
        test.stopTest();
        
        // get the opportunity product id for the new line item
        oli = [select id, opportunity_product__c from OpportunityLineItem where Id = :oli.Id];
        
        // assert that two xref entries were created
        List <OpportunityProduct_SalesTeamCredit__c> xrefEntries = [select id from OpportunityProduct_SalesTeamCredit__c where Opportunity_Product__c = :oli.Opportunity_Product__c];
        System.assertEquals(2, xrefEntries.size());
    } //testCreateSTCOLIXref_OLI
    
    
    static testMethod void testDeleteSalesCredit() {
        // create an account
        Account account = util_sampleDataGenerator.createAccount_Client();
        System.assertNotEquals(null, account.Id);
        
        // create internal contact
        Contact internalContact = util_sampleDataGenerator.createContact_Internal(account.Id);
        System.assertNotEquals(null, internalContact.Id);
 
        // create test user
        User user = util_sampleDataGenerator.createHewittStandardUser();
        System.assertNotEquals(null, user.Id);
 
        // update the contact
        internalContact.Corresponding_User_Id__c = user.Id; 
        update internalContact;
                
        // update the user
        user.Internal_Contact_Id__c = internalContact.Id;
        update user;
        
        // create an opportunity
        Opportunity oppty = util_sampleDataGenerator.createOpportunity_US(account.Id);
        System.assertNotEquals(null, oppty.Id);
        
        // create a sales credit entry
        Sales_Credit__c stc = util_sampleDataGenerator.createSalesCredit(oppty.Id, internalContact.Id);
        System.assertNotEquals(null, stc.Id);
        
        // verify a team member was created
        OpportunityTeamMember teamMember = [select id from OpportunityTeamMember where OpportunityId = :oppty.Id and UserId = :user.Id];
        System.assertNotEquals(null, teamMember);
        System.assertNotEquals(null, teamMember.Id);
        
        // start the test
        test.startTest();
        
        // delete the sales team member
        delete stc;
        
        // stop the test
        test.stopTest();
        
        List <OpportunityTeamMember> teamMembers = [select id from OpportunityTeamMember where OpportunityId = :oppty.Id and UserId = :user.Id];
        System.assert(teamMembers.IsEmpty());
    } //testDeleteSalesCredit
    
    
    static testMethod void testUndeleteSalesCredit() {
        // create an account
        Account account = util_sampleDataGenerator.createAccount_Client();
        System.assertNotEquals(null, account.Id);
        
        // create internal contact
        Contact internalContact = util_sampleDataGenerator.createContact_Internal(account.Id);
        System.assertNotEquals(null, internalContact.Id);
 
        // create test user
        User user = util_sampleDataGenerator.createHewittStandardUser();
        System.assertNotEquals(null, user.Id);
 
        // update the contact
        internalContact.Corresponding_User_Id__c = user.Id; 
        update internalContact;
                
        // update the user
        user.Internal_Contact_Id__c = internalContact.Id;
        update user;
        
        // create an opportunity
        Opportunity oppty = util_sampleDataGenerator.createOpportunity_US(account.Id);
        System.assertNotEquals(null, oppty.Id);
        
        // create a sales credit entry
        Sales_Credit__c stc = util_sampleDataGenerator.createSalesCredit(oppty.Id, internalContact.Id);
        System.assertNotEquals(null, stc.Id);
        
        // verify a team member was created
        OpportunityTeamMember teamMember = [select id from OpportunityTeamMember where OpportunityId = :oppty.Id and UserId = :user.Id];
        System.assertNotEquals(null, teamMember);
        System.assertNotEquals(null, teamMember.Id);
        
        // delete the sales team member
        delete stc;
        
        List <OpportunityTeamMember> teamMembers = [select id from OpportunityTeamMember where OpportunityId = :oppty.Id and UserId = :user.Id];
        System.assert(teamMembers.IsEmpty());
        
        // start the test
        test.startTest();
        
        undelete stc;
        
        // stop the test
        test.stopTest();
        
        teamMember = [select id from OpportunityTeamMember where OpportunityId = :oppty.Id and UserId = :user.Id];
        System.assertNotEquals(null, teamMember);
        System.assertNotEquals(null, teamMember.Id);
    } //testUndeleteSalesCredit
    
    
    

    
    static testMethod void testCreateSalesCredit() {
        
        // create an account
        Account account = util_sampleDataGenerator.createAccount_Client();
        System.assertNotEquals(null, account.Id);
        
        // create internal contact
        Contact internalContact = util_sampleDataGenerator.createContact_Internal('');
 
        // create test user
        User user = util_sampleDataGenerator.createHewittStandardUser();
        System.assertNotEquals(null, user.Id);
 
        // update the contact
        internalContact.Corresponding_User_Id__c = user.Id; 
        update internalContact;
                
        // update the user
        user.Internal_Contact_Id__c = internalContact.Id;
        update user;
        
        // create an opportunity
        Opportunity oppty = util_sampleDataGenerator.createOpportunity_US(account.Id);
        System.assertNotEquals(null, oppty.Id);
        
        // start test
        test.startTest();
                
        // create a sales credit entry
        Sales_Credit__c stc = util_sampleDataGenerator.createSalesCredit(oppty.Id, internalContact.Id);
        System.assertNotEquals(null, stc.Id);
        
        // stop test
        test.stopTest();
        
        // verify a sales team member entry was created
        OpportunityTeamMember teamMember = [select id from OpportunityTeamMember where OpportunityId = :oppty.Id and UserId = :user.Id];
        System.assertNotEquals(null, teamMember);
        System.assertNotEquals(null, teamMember.Id);
    } //testCreateSalesCredit
    
    
    static testMethod void testMarkActiveDateStamp() {

        // create a test user record
        User user = util_sampleDataGenerator.createHewittStandardUser(false);
        user.IsActive = false;
        insert user;
        System.assertNotEquals(null, user.Id);

        // verify the user starts out as inactive
        user = [select id, IsActive, Activation_Date__c from User where Id = :user.Id];
        System.assertEquals(false, user.IsActive);
        System.assertEquals(null, user.Activation_Date__c);
        
        // start the test
        test.startTest();
        
        // update the user to be active
        user.IsActive = true;
        update user;
        
        // stop the test
        test.stopTest();
        
        // verify the user is active
        user = [select id, IsActive, Activation_Date__c from User where Id = :user.Id];
        System.assertEquals(true, user.IsActive);
        System.assertNotEquals(null, user.Activation_Date__c);
    } //testMarkActiveDateStamp
    
    
    // Author Shimon Rothschild
    // Last Modified July 2011
    static testMethod void testDeleteJunctionShadowOpportuniyProducts_SalesTeamCredit () {
        // create a product
        Product2 product = util_sampleDataGenerator.createProduct('LJ TEST PRODUCT', 'Consulting', false, 'Consulting');
        System.assertNotEquals(null, product.Id);
        
        // create a product
        Product2 product2 = util_sampleDataGenerator.createProduct('LJ TEST PRODUCT2', 'Consulting', false, 'Consulting');
        System.assertNotEquals(null, product2.Id);
        
        // create a pricebookentry
        PricebookEntry pbe = util_sampleDataGenerator.createStandardPriceForProduct(product.id, 100.0);
        System.assertNotEquals(null, pbe.Id);
        
        // create a pricebookentry
        PricebookEntry pbe2 = util_sampleDataGenerator.createStandardPriceForProduct(product2.id, 50.0);
        System.assertNotEquals(null, pbe2.Id);
        
        // create an account
        Account account = util_sampleDataGenerator.createAccount_Client();
        System.assertNotEquals(null, account.Id);
        
        // create internal contact
        Contact internalContact = util_sampleDataGenerator.createContact_Internal(account.Id);
        System.assertNotEquals(null, internalContact.Id);
        
        // create an opportunity
        Opportunity oppty = util_sampleDataGenerator.createOpportunity_US(account.Id);
        System.assertNotEquals(null, oppty.Id);
        
        // create a opportunity line item
        OpportunityLineItem oli = util_sampleDataGenerator.createOpportunityProduct(oppty.Id, pbe.Id, 5, 150.0);
        System.assertNotEquals(null, oli.Id);
        
        // create a opportunity line item
        OpportunityLineItem oli2 = util_sampleDataGenerator.createOpportunityProduct(oppty.Id, pbe2.Id, 3, 100.0);
        System.assertNotEquals(null, oli2.Id);
        
         // create a sales credit
        Sales_Credit__c stc = util_sampleDataGenerator.createSalesCredit(oppty.Id, internalContact.Id); 
        
        // start test
        System.debug('starting the test...');
        test.startTest();
        System.debug('test started');
        
        // assert that two xref entries were created        
        List <OpportunityProduct_SalesTeamCredit__c> xrefEntries = [select id, Opportunity_Product__c, SalesTeamCreditID__c from OpportunityProduct_SalesTeamCredit__c where SalesTeamCreditID__c = :stc.Id];
        System.assertEquals(2, xrefEntries.size());
        System.assertNotEquals(null, xrefEntries[0].Opportunity_Product__c);
        System.assertNotEquals(null, xrefEntries[1].Opportunity_Product__c);
        System.debug(xrefEntries[0]);
        System.debug(xrefEntries[1]);
        
        delete oli; // delete the first one this calls the ListItem trigger, which will cascade to the mirror trigger
        
        // stop test
        System.debug('stopping the test...');
        test.stopTest();
        System.debug('test stopped');
        
        // was it removed from the opportunityProduct_SalesTEamCredit__c?
        List <OpportunityProduct_SalesTeamCredit__c> newXrefEntries = [select id from OpportunityProduct_SalesTeamCredit__c where SalesTeamCreditID__c = :stc.Id];       
        System.assertEquals(1, newXrefEntries.size());
    
    } //testDeleteJunctionShadowOpportuniyProducts_SalesTeamCredit
    
    
    static testMethod void testDeleteSalesTeamCreditXrefEntries() {
        // create a product
        Product2 product = util_sampleDataGenerator.createProduct('LJ TEST PRODUCT', 'Consulting', false, 'Consulting');
        System.assertNotEquals(null, product.Id);
        
        // create a product
        Product2 product2 = util_sampleDataGenerator.createProduct('LJ TEST PRODUCT2', 'Consulting', false, 'Consulting');
        System.assertNotEquals(null, product2.Id);
        
        // create a pricebookentry
        PricebookEntry pbe = util_sampleDataGenerator.createStandardPriceForProduct(product.id, 100.0);
        System.assertNotEquals(null, pbe.Id);
        
        // create a pricebookentry
        PricebookEntry pbe2 = util_sampleDataGenerator.createStandardPriceForProduct(product2.id, 50.0);
        System.assertNotEquals(null, pbe2.Id);
        
        // create an account
        Account account = util_sampleDataGenerator.createAccount_Client();
        System.assertNotEquals(null, account.Id);
        
        // create internal contact
        Contact internalContact = util_sampleDataGenerator.createContact_Internal(account.Id);
        System.assertNotEquals(null, internalContact.Id);
        
        // create an opportunity
        Opportunity oppty = util_sampleDataGenerator.createOpportunity_US(account.Id);
        System.assertNotEquals(null, oppty.Id);
        
        // create a opportunity line item
        OpportunityLineItem oli = util_sampleDataGenerator.createOpportunityProduct(oppty.Id, pbe.Id, 5, 150.0);
        System.assertNotEquals(null, oli.Id);
        
        // create a opportunity line item
        OpportunityLineItem oli2 = util_sampleDataGenerator.createOpportunityProduct(oppty.Id, pbe2.Id, 3, 100.0);
        System.assertNotEquals(null, oli2.Id);
        
         // create a sales credit
        Sales_Credit__c stc = util_sampleDataGenerator.createSalesCredit(oppty.Id, internalContact.Id); 
        // Assumption:  this automatically populates the OpportunityProduct_SalesTeamCredit__c
        // assert that two xref entries were created
        List <OpportunityProduct_SalesTeamCredit__c> xrefEntries = [select id from OpportunityProduct_SalesTeamCredit__c where SalesTeamCreditID__c = :stc.Id];
        System.assertEquals(2, xrefEntries.size());
        
        
        // start test
        test.startTest();
        
        delete oli; // delete the first one this calls the ListItem trigger, which will cascade to the mirror trigger
        
        // stop test
        test.stopTest();
        
        // was it removed from the opportunityProduct_SalesTEamCredit__c?
        List <OpportunityProduct_SalesTeamCredit__c> newXrefEntries = [select id from OpportunityProduct_SalesTeamCredit__c where SalesTeamCreditID__c = :stc.Id];       
        System.assertEquals(1, newXrefEntries.size());
    } //testDeleteSalesTeamCreditXrefEntries
    

    //Test code for verifyDeleteAuthority function
    static testMethod void test_verifyDeleteAuthority()
    {
        Account acc = Null;
        Opportunity opp = Null;
        List <Opportunity> oppsList = new List<Opportunity>();
        Competitor__c comp = Null;
        Integer i;
        String oppRecTypeID = Null;
        
        test.startTest();
        
        oppRecTypeID = util_sampleDataGenerator.getRecordType('Opportunity', 'Oppty Record').Id;
        
        //Creating a Competitor
        comp = new Competitor__c(Name = 'Super Competitor');            
        insert comp;       
                            
        //-------------------Checking As Standard User------------------------------
        
        //Create standard user
        User stdUser = util_sampleDataGenerator.createHewittStandardUser();   //Create Standard User                
      
        System.RunAs(stdUser) 
        {
            acc = util_sampleDataGenerator.createAccount_Client();
            opp = util_sampleDataGenerator.createOpportunity_US(acc.Id);

            //Updating Opps                     
            opp.Current_Provider_Reference__c = comp.Id;            
            opp.Competitor__c = 'Other';    
            opp.StageName = 'Propose Solution'; //Standard user can't delete opp having Propose Solution stage
            Update opp;            

            //Delete the opp  
            try
            {
                Delete opp;
            }     
            catch(DmlException e)       
            {
                System.assert(e.getDmlMessage(0).indexOf(Label.Opportunity_Deletion_Error) > -1);          
            }
            
            //Updating the opp stage            
            opp.StageName = 'Qualify Opportunity'; 
            Update opp;  
            
            Delete opp;
            //Checking to ensure that opp has been deleted, using list to avoid System.QueryException: List has no rows for assignment to SObject
            oppsList = [Select ID from Opportunity where ID=:opp.ID];
            System.assertEquals(oppsList.size(),0);
            
            //Checking for bulk opps 
            //Scenario 1 - All Opps should get deleted   
            for (i=0;i<200;i++)
            {
                opp = new Opportunity(RecordTypeId=oppRecTypeID,accountId=acc.ID,name='Test Opp-'+i,amount=1000.0,StageName='Qualify Opportunity',CloseDate=Date.today().addDays(30),Probability=25,Current_Provider_Reference__c=comp.Id,Competitor__c='Other');    
                oppsList.add(opp);   
            }   
            Insert oppsList;     
            Delete oppsList; 
            oppsList = [Select ID from Opportunity where ID=:oppsList];
            System.assertEquals(oppsList.size(),0);
            
            //Scenario 2 - Opps should not get deleted   
            for (i=0;i<200;i++)
            {
                opp = new Opportunity(RecordTypeId=oppRecTypeID,accountId=acc.ID,name='Test Opp-'+i,amount=1000.0,StageName='Propose Solution',CloseDate=Date.today().addDays(30),Probability=25,Current_Provider_Reference__c=comp.Id,Competitor__c='Other');    
                oppsList.add(opp);   
            }   
            Insert oppsList;  
            try
            {   
                Delete oppsList; 
            }
            catch(DmlException e)       
            {
                for (i=0;i<200;i++)
                {
                    System.assert(e.getDmlMessage(i).indexOf(Label.Opportunity_Deletion_Error) > -1);          
                }
            }
            oppsList = [Select ID from Opportunity where ID=:oppsList];
            System.assertEquals(oppsList.size(),200);
        }
        
        //-------------------Checking As Admin User------------------------------
        //All Opps should get deleted
        oppsList=new List<Opportunity>();
        for (i=0;i<200;i++)
        {
            if (i<50)
                opp = new Opportunity(RecordTypeId=oppRecTypeID,accountId=acc.ID,name='Test Opp-'+i,amount=1000.0,StageName='Closed Lost',CloseDate=Date.today().addDays(30),Probability=0,Current_Provider_Reference__c=comp.Id,Chosen_Provider_Reference__c=comp.ID,Competitor__c='Other',Reason_Won_or_Lost__c='Other');    
            else if(i<100) 
                opp = new Opportunity(RecordTypeId=oppRecTypeID,accountId=acc.ID,name='Test Opp-'+i,amount=1000.0,StageName='Closed Won',CloseDate=Date.today().addDays(30),Probability=100,Current_Provider_Reference__c=comp.Id,Chosen_Provider_Reference__c=comp.ID,Competitor__c='Other',Reason_Won_or_Lost__c='Other');    
            else if(i<120) 
                opp = new Opportunity(RecordTypeId=oppRecTypeID,accountId=acc.ID,name='Test Opp-'+i,amount=1000.0,StageName='Closed Approved',CloseDate=Date.today().addDays(30),Probability=100,Current_Provider_Reference__c=comp.Id,Chosen_Provider_Reference__c=comp.ID,Competitor__c='Other',Reason_Won_or_Lost__c='Other');    
            else if(i<150)
                opp = new Opportunity(RecordTypeId=oppRecTypeID,accountId=acc.ID,name='Test Opp-'+i,amount=1000.0,StageName='Non-Qualified Opportunity',CloseDate=Date.today().addDays(30),Probability=25,Current_Provider_Reference__c=comp.Id,Competitor__c='Other');    
            else
                opp = new Opportunity(RecordTypeId=oppRecTypeID,accountId=acc.ID,name='Test Opp-'+i,amount=1000.0,StageName='Negotiate',CloseDate=Date.today().addDays(30),Probability=25,Current_Provider_Reference__c=comp.Id,Competitor__c='Other');                
            oppsList.add(opp);   
        }
        Insert oppsList;     
        Delete oppsList; 
        oppsList = [Select ID from Opportunity where ID=:oppsList];
        System.assertEquals(oppsList.size(),0);    
        
        test.stopTest();       
    } //test_verifyDeleteAuthority
    
    
   //Tests that dup lead consultants cannot be entered for an Opportunity - Case 5500
    static testmethod void testLead_Consultant_Duplicate_Entry() {
        //create test data
        Account myAccount = util_sampleDataGenerator.createAccount_Client();
        Opportunity myOpp = util_sampleDataGenerator.createOpportunity_US(myAccount.Id);
        Contact myContact = util_sampleDataGenerator.createContact_Internal(myAccount.Id);
        Contact myContact2 = util_sampleDataGenerator.createContact_Internal(myAccount.Id);
        
        Test.startTest();
        
        //Create a Sales Credit Entry
        Sales_Credit__c mySalesCredit1 = util_sampleDataGenerator.createSalesCredit(myOpp.Id, myContact.Id, false);
        mySalesCredit1.Lead_Consultant__c = true;
        insert mySalesCredit1;
        //Verify record inserted
        System.assertNotEquals(null, mySalesCredit1.Id);
        
        //Insert a second one also with Lead Consultant checked true
        Sales_Credit__c mySalesCredit2 = util_sampleDataGenerator.createSalesCredit(myOpp.Id, myContact2.Id, false);
        mySalesCredit2.Lead_Consultant__c = true;
        try { 
            insert mySalesCredit2;
        } catch (DMLException e) {
            for (Integer i = 0; i < e.getNumDml(); i++) {
                System.debug('CHINTAN DML Exception Status Code: ' + e.getDmlStatusCode(i));
                System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION', e.getDmlStatusCode(i) );
            }
        }
        
        //Insert it without the Lead Consultant checkbox
        mySalesCredit2.Lead_Consultant__c = false;
        insert mySalesCredit2;
        //verify insertion
        System.assertNotEquals(null, mySalesCredit2.Id);
        
        //Edit it to set it true again
        mySalesCredit2 = [Select Id, Lead_Consultant__c from Sales_Credit__c where id = :mySalesCredit2.Id];
        mySalesCredit2.Lead_Consultant__c = true;
        try {
            update mySalesCredit2;
        } catch (DMLException e) {
            for (Integer i = 0; i < e.getNumDml(); i++) {
                System.debug('CHINTAN DML Exception Status Code: ' + e.getDmlStatusCode(i));
                System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION', e.getDmlStatusCode(i) );
            }
        }       
        
        Test.stopTest();
    } //testLead_Consultant_Duplicate_Entry
    

    //Tests that dup lead consultants cannot be entered for an Opportunity - Case 5500
    static testmethod void testLead_Consultant_Duplicate_Entry_Bulk() {
        ///create test data
        Account myAccount = util_sampleDataGenerator.createAccount_Client();
        Opportunity myOpp = util_sampleDataGenerator.createOpportunity_US(myAccount.Id);
        Contact myContact = util_sampleDataGenerator.createContact_Internal(myAccount.Id);
        List<Sales_Credit__c> recordsToInsert = new List<Sales_Credit__c> ();
        List<Sales_Credit__c> recordsToInsert2 = new List<Sales_Credit__c> ();
        Set <String> stcIds = new Set<String>();
        final integer count = 10;
        
        Test.startTest();
        
        //Create a Sales Credit Entry
        Sales_Credit__c stc = util_sampleDataGenerator.createSalesCredit(myOpp.Id, myContact.Id, false);
        stc.Lead_Consultant__c = true;
        insert stc;
        //Verify record inserted
        System.assertNotEquals(null, stc.Id);

        //Create count more entries with Lead Consultant true
        List<Contact> myContactsList = new List<Contact>();
        Id recordTypeId = util_sampleDataGenerator.getRecordType('Contact', 'Internal Contact Record Type').Id;
        for (integer i=0; i<count; i++) {
            myContact = new Contact();
            myContact.RecordTypeId = recordTypeId;
            myContact.FirstName = 'Apex';
            myContact.LastName = 'Test ' + i;
            myContact.email = 'apex.test.'+i+'@aonhewitt.com';
            myContact.AccountId = myAccount.Id;
            myContact.SDO_Mailing_Country_Name__c = 'United States';
            myContact.Functional_Role__c = 'Other - Other';
            //myContact.Legacy_Hewitt_Associate_ID__c = 'A00000';
            myContact.Associate_ID__c = 'A00000';
            //myContact.Source_HR_System__c = 'Aon Hewitt';
            myContact.Aon_Hewitt_Employee_Status__c = 'Active';
            myContactsList.add(myContact);
        }
        insert myContactsList;
        
        for (integer i=0; i<count; i++) {
            stc = new Sales_Credit__c();
            stc.Related_Opportunity__c = myOpp.Id;
            stc.Credit_Recipient__c = myContactsList[i].Id;
            stc.Dual_Initiation_Credit__c = 50;
            stc.Sales_Assist_Credit__c = 50;
            stc.Sales_Credit__c = 50;
            stc.Lead_Consultant__c = true;
            
            recordsToInsert.add(stc);
        }
        try { 
            insert recordsToInsert;
        } catch (DMLException e) {
            for (Integer j = 0; j < e.getNumDml(); j++) {
                System.debug('CHINTAN DML Exception Status Code: ' + e.getDmlStatusCode(j));
                System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION', e.getDmlStatusCode(j) );
            }
        }
        
        //Now remove the Lead consultant checkbox
        for (Integer x=0; x < recordsToInsert.size(); x++) {
            recordsToInsert[x].Lead_Consultant__c = false;
        }
        //verify count elements
        System.assertEquals(count, recordsToInsert.size());
        insert recordsToInsert;
        
        //Verify count inserted
        for (Sales_Credit__c myStc : recordsToInsert) {
            stcIds.add(myStc.Id);
        }
        System.assertEquals(count, stcIds.size());
        
        //Edit to set checkbox again
        recordsToInsert = [Select id, Lead_Consultant__c from Sales_Credit__c where Id in :stcIds];
        System.assertEquals(count, recordsToInsert.size());
        for (Integer x=0; x< recordsToInsert.size(); x++) {
            recordsToInsert[x].Lead_Consultant__c = true;
        }
        try { 
            update recordsToInsert;
        } catch (DMLException e) {
            for (Integer j = 0; j < e.getNumDml(); j++) {
                System.debug('CHINTAN DML Exception Status Code: ' + e.getDmlStatusCode(j));
                System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION', e.getDmlStatusCode(j) );
            }
        }
            
        Test.stopTest();
    } //testLead_Consultant_Duplicate_Entry_Bulk
    
    
    //Test Method to verify Opportunity closed Date Stamping logic for Case 5717
    //Chintan Adhyapak, December 19, 2011
    static testMethod void testStampClosedDate() {
        //local vars
        Opportunity myOpp = null;
        
        Test.startTest();
        
        //Create Account
        Account acc1 = util_sampleDataGenerator.createAccount_Client();
        
        //Create a Competitor
        Competitor__c comp = new Competitor__c();
        comp.Name = 'Super Competitor';
        insert comp;
        
        //Create an opp which is in closed state
        myOpp = new Opportunity();
        myOpp.RecordTypeId = util_sampleDataGenerator.getRecordType('Opportunity', 'US Oppty Closed Record').Id;
        myOpp.AccountId = acc1.Id;
        myOpp.Name = 'Chintan Test Closed Opportunity';
        myOpp.Amount = 1000000.0;
        myOpp.StageName = 'Closed Won';
        myOpp.CloseDate = Date.today().addDays(-5);
        myOpp.Probability = 100;
        myOpp.Current_Provider_Reference__c = comp.Id;
        myOpp.Competitor__c = 'Other';
        myOpp.Chosen_Provider_Reference__c = comp.Id;
        myOpp.Reason_Won_or_Lost__c = 'Other';
        
        //insert the opportunity
        insert myOpp;
        
        //Verify that Closed Date got stamped
        myOpp = [Select Id, Opportunity_Closed_Date__c from Opportunity where Id = :myOpp.Id];
        System.debug('CHINTAN inserted Won myOpp Closed Date is ' + myOpp.Opportunity_Closed_Date__c);
        System.assertEquals(Date.today(), myOpp.Opportunity_Closed_Date__c);
        
        //Create another Opp
        myOpp = util_sampleDataGenerator.createOpportunity_US(acc1.Id);
          
        myOpp.put('StageName', 'Closed Won');
        myOpp.Current_Provider_Reference__c = comp.Id;
        myOpp.Competitor__c = 'Other';
        myOpp.Chosen_Provider_Reference__c = comp.Id;
        myOpp.Reason_Won_or_Lost__c = 'Other';
        myOpp.Probability = 100;
        update myOpp;
        
        //Validate Stamp
        myOpp = [Select Id, Opportunity_Closed_Date__c from Opportunity where Id = :myOpp.Id];
        System.debug('CHINTAN myOpp Closed Date is ' + myOpp.Opportunity_Closed_Date__c);
        System.assertEquals(Date.today(), myOpp.Opportunity_Closed_Date__c);
        
        //Reopen it
        myOpp = [Select Id, StageName, Probability from Opportunity where Id = :myOpp.Id];
        myOpp.put('StageName', 'Negotiate');
        myOpp.Probability = 75;
        update myOpp;
        
        Test.stopTest();
        
        //Validate Stamp
        myOpp = [Select Id, Opportunity_Closed_Date__c from Opportunity where Id = :myOpp.Id];
        System.debug('CHINTAN myOpp Closed Date is ' + myOpp.Opportunity_Closed_Date__c);
        System.assertEquals(null, myOpp.Opportunity_Closed_Date__c);
    } //testStampClosedDate
    
    
    /** Tests the methdod updateSalesTeamCreditsOnOpportunity
      * Chintan, December 18, 2012 */
    static testMethod void test_updateSalesTeamCreditsOnOpportunity() {
        // create an account
        String opptyRecTypeID = util_sampleDataGenerator.getRecordType('Opportunity', 'Oppty Record').Id;
        
        Account account = util_sampleDataGenerator.createAccount_Client();
        System.assertNotEquals(null, account.Id);
        
        // create internal contact
        Contact internalContact1 = util_sampleDataGenerator.createContactWithFName_Internal(account.ID,'Test Contact 1');
        Contact internalContact2 = util_sampleDataGenerator.createContactWithFName_Internal(account.ID,'Test Contact 2');
        Contact internalContact3 = util_sampleDataGenerator.createContactWithFName_Internal(account.ID,'Test Contact 3');
        
        System.assertNotEquals(null, internalContact1.Id);
        System.assertNotEquals(null, internalContact2.Id);
        System.assertNotEquals(null, internalContact3.Id);
               
        // create an opportunity
        Opportunity oppty = util_sampleDataGenerator.createOpportunity_US(account.Id);
        System.assertNotEquals(null, oppty.Id);
        
        // start test
        Test.startTest();
                
        // create sales credit entries
        Sales_Credit__c salesCredit1 = util_sampleDataGenerator.createSalesCredit(oppty.Id, internalContact1.Id);
        Sales_Credit__c salesCredit2 = util_sampleDataGenerator.createSalesCredit(oppty.Id, internalContact2.Id);

        System.assertNotEquals(null, salesCredit1.Id);
        System.assertNotEquals(null, salesCredit2.Id);
        oppty=[Select ID,SalesTeamCredits__c from Opportunity where ID=:oppty.ID];
        System.assertEquals(oppty.SalesTeamCredits__c,'Test Contact 1 JOVANOVIC,Test Contact 2 JOVANOVIC');
        
        // test for update
        salesCredit2.Credit_Recipient__c=internalContact3.Id;
        update salesCredit2;
        
        oppty=[Select ID,SalesTeamCredits__c from Opportunity where ID=:oppty.ID];
        System.assertEquals(oppty.SalesTeamCredits__c,'Test Contact 1 JOVANOVIC,Test Contact 3 JOVANOVIC');

        // Test for Delete
        delete salesCredit2;
        oppty=[Select ID,SalesTeamCredits__c from Opportunity where ID=:oppty.ID];
        System.assertEquals(oppty.SalesTeamCredits__c,'Test Contact 1 JOVANOVIC');

        // Test for Undelete
        undelete salesCredit2;
        oppty=[Select ID,SalesTeamCredits__c from Opportunity where ID=:oppty.ID];
        System.assertEquals(oppty.SalesTeamCredits__c,'Test Contact 1 JOVANOVIC,Test Contact 3 JOVANOVIC');
        
        Test.stopTest();
    } //test_updateSalesTeamCreditsOnOpportunity
    
    
    
    /** Bulk test for method updateSalesTeamCreditson Opportunity
      * Chintan, December 18, 2012 */ 
    static testMethod void test_updateSalesTeamCreditsOnOpportunity_bulk() {
        //local vars
        final integer count = 50;
        Set<Id> oppIds = new Set<Id> ();
        
        // create an account
        String opptyRecTypeID = util_sampleDataGenerator.getRecordType('Opportunity', 'Oppty Record').Id;
        
        Account myAccount = util_sampleDataGenerator.createAccount_Client();
        System.assertNotEquals(null, myAccount.Id);
        
        // start test
        test.startTest();
        
        //Create 'count' opportunities
        List <Opportunity> myOppList = new List<Opportunity>();
        for(integer i=0; i<count; i++) {
            Opportunity myOpp = new Opportunity();
            myOpp.RecordTypeId = opptyRecTypeID;        
            myOpp.accountId = myAccount.Id;        
            myOpp.name = 'Test Oppty '+i;        
            myOpp.amount = 1000.0;        
            myOpp.StageName = 'Qualify Opportunity';        
            myOpp.CloseDate = Date.today().addDays(30);        
            myOpp.Probability = 25;
            myOppList.add(myOpp);         
        }
        insert myOppList;
        for (Opportunity myOpp : myOppList) {
            System.assertNotEquals(null, myOpp.Id);
            oppIds.add(myOpp.Id);
        }
        
        //Create 'count' Internal Contacts
        List<Contact> myContactList = util_sampleDataGenerator.createInternalContact_bulk(myAccount.Id, count, true);
        for (Contact myContact : myContactList) {
            System.assertNotEquals(null, myContact.Id);
        }
        
        //Create 'count' Sales Credit Entries
        List<Sales_Credit__c> mySalesCreditList = new List<Sales_Credit__c> ();
        for (integer i=0; i<count; i++) {
            Sales_Credit__c myCredit = new Sales_Credit__c();
            myCredit.Credit__c = 50.0;
            myCredit.Credit_Recipient__c = myContactList[i].Id;
            myCredit.Related_Opportunity__c = myOppList[i].Id;
            mySalesCreditList.add(myCredit);
        }
        insert mySalesCreditList;
        for (Sales_Credit__c myCredit : mySalesCreditList) {
            System.assertNotEquals(null, myCredit.Id);
        }
        
        //Verify
        myOppList = [Select Id, SalesTeamCredits__c from Opportunity where id in :oppIds];
        for (integer i=0; i<count; i++) {
            System.assertEquals('Apex Contact ' + i, myOppList[i].SalesTeamCredits__c);
        }
        
        //Test Updates
        for (integer i=0; i<count; i++) {
            mySalesCreditList[i].Credit_Recipient__c = myContactList[count-1-i].Id;
        }
        update mySalesCreditList;
        
        //Verify
        myOppList = [Select Id, SalesTeamCredits__c from Opportunity where id in :oppIds];
        for (integer i=0; i<count; i++) {
            System.assertEquals('Apex Contact ' + (count-1-i), myOppList[i].SalesTeamCredits__c);
        }
        
        //Test Deletion
        delete mySalesCreditList;
        
        //Verify
        myOppList = [Select Id, SalesTeamCredits__c from Opportunity where id in :oppIds];
        for (integer i=0; i<count; i++) {
            System.assertEquals(null, myOppList[i].SalesTeamCredits__c);
        }
        
        test.stopTest();        
    } //test_updateSalesTeamCreditsOnOpportunity_bulk
    
    
    //Test Method to verify Chosen Provider auto setting for Case 7971
    //Chintan Adhyapak, February 28, 2012
    static testMethod void testAutoSetChosenProvider() {
        //local vars
        Opportunity myOpp = null;
        Competitor__c aonHewitt = [select Id from Competitor__c where  Name = 'Aon Hewitt' limit 1];
        System.debug('CHINTAN Aon Hewitt Competitor Id is ' + aonHewitt.Id);
        Competitor__c other = [select Id from Competitor__c where  Name = 'Other' limit 1];
        System.debug('CHINTAN Other Competitor Id is ' + other.Id);
        
        Test.startTest();
        
        //Create Account
        Account acc1 = util_sampleDataGenerator.createAccount_Client();
        
        //Create a Competitor
        Competitor__c comp = new Competitor__c();
        comp.Name = 'Super Competitor';
        insert comp;
        
        //Create an opp which is in closed state
        myOpp = new Opportunity();
        myOpp.RecordTypeId = util_sampleDataGenerator.getRecordType('Opportunity', 'US Oppty Closed Record').Id;
        myOpp.AccountId = acc1.Id;
        myOpp.Name = 'Chintan Test Closed Opportunity';
        myOpp.Amount = 1000000.0;
        myOpp.StageName = 'Closed Won';
        myOpp.CloseDate = Date.today().addDays(-5);
        myOpp.Probability = 100;
        myOpp.Current_Provider_Reference__c = comp.Id;
        myOpp.Competitor__c = 'Other';
        myOpp.Chosen_Provider_Reference__c = comp.Id;
        myOpp.Reason_Won_or_Lost__c = 'Other';
        
        //insert the opportunity
        insert myOpp;
        
        //Verify that Chosen Provider got auto set
        myOpp = [Select Id, StageName, Chosen_Provider_Reference__c from Opportunity where Id = :myOpp.Id];
        System.debug('CHINTAN inserted Won myOpp Chosen Provider Id is ' + myOpp.Chosen_Provider_Reference__c);
        System.assertEquals(aonHewitt.Id, myOpp.Chosen_Provider_Reference__c);
        
        //Reopen it
        myOpp = [Select Id, StageName, Probability from Opportunity where Id = :myOpp.Id];
        myOpp.put('StageName', 'Negotiate');
        myOpp.Probability = 75;
        update myOpp;
        
        //Verify that Chosen Provider got cleared
        myOpp = [Select Id, StageName, Chosen_Provider_Reference__c from Opportunity where Id = :myOpp.Id];
        System.debug('CHINTAN myOpp Chosen Provider is ' + myOpp.Chosen_Provider_Reference__c);
        System.assertEquals(null, myOpp.Chosen_Provider_Reference__c);
        
        //Close it
        myOpp = [Select Id, StageName, Probability from Opportunity where Id = :myOpp.Id];
        myOpp.put('StageName', 'Closed Won');
        myOpp.Probability = 100;
        update myOpp;
        
        //Verify that Chosen Provider got auto set
        myOpp = [Select Id, StageName, Chosen_Provider_Reference__c from Opportunity where Id = :myOpp.Id];
        System.debug('CHINTAN Closed Won myOpp Chosen Provider Id is ' + myOpp.Chosen_Provider_Reference__c);
        System.assertEquals(aonHewitt.Id, myOpp.Chosen_Provider_Reference__c);
        
        //Move to Closed Lost
        myOpp = [Select Id, StageName, Probability from Opportunity where Id = :myOpp.Id];
        myOpp.put('StageName', 'Closed Lost');
        myOpp.Probability = 0;
        update myOpp;
        
        Test.stopTest();
        
        //Verify that Chosen Provider got auto set
        myOpp = [Select Id, StageName, Chosen_Provider_Reference__c from Opportunity where Id = :myOpp.Id];
        System.debug('CHINTAN Closed Lost myOpp Chosen Provider Id is ' + myOpp.Chosen_Provider_Reference__c);
        System.assertEquals(other.Id, myOpp.Chosen_Provider_Reference__c);
    } //testAutoSetChosenProvider
    
    
    //Test Method to verify Chosen Provider auto setting for Case 7971
    //Chintan Adhyapak, February 28, 2012
    static testMethod void testAutoSetChosenProvider_bulk() {
        //local vars
        List<Opportunity> myOppList = new List<Opportunity> ();
        Set <String> oppIds = new Set<String>();
        Id OppRecordTypeId = util_sampleDataGenerator.getRecordType('Opportunity', 'US Oppty Closed Record').Id;
        Competitor__c aonHewitt = [select Id from Competitor__c where  Name = 'Aon Hewitt' limit 1];
        System.debug('CHINTAN Aon Hewitt Competitor Id is ' + aonHewitt.Id);
        Competitor__c other = [select Id from Competitor__c where  Name = 'Other' limit 1];
        System.debug('CHINTAN Other Competitor Id is ' + other.Id);
        
        Test.startTest();
        
        //Create Account
        Account acc1 = util_sampleDataGenerator.createAccount_Client();
        
        //Create a Competitor
        Competitor__c comp = new Competitor__c();
        comp.Name = 'Super Competitor';
        insert comp;
        
        //Create 100 opps which are in closed state
        for (integer i=0; i<100; i++) {
            Opportunity myOpp = new Opportunity();
            myOpp.RecordTypeId = OppRecordTypeId;
            myOpp.AccountId = acc1.Id;
            myOpp.Name = 'Chintan Test Closed Opportunity';
            myOpp.Amount = 1000000.0;
            myOpp.StageName = 'Closed Won';
            myOpp.CloseDate = Date.today().addDays(-5);
            myOpp.Probability = 100;
            myOpp.Current_Provider_Reference__c = comp.Id;
            myOpp.Competitor__c = 'Other';
            myOpp.Chosen_Provider_Reference__c = comp.Id;
            myOpp.Reason_Won_or_Lost__c = 'Other';
            //add the opportunity into list
            myOppList.add(myOpp);
        }
        //verify 100 elements
        System.assertEquals(100, myOppList.size());
        insert myOppList;
        
        //Verify 100 inserted
        for (Opportunity myOpp : myOppList) {
            oppIds.add(myOpp.Id);
        }
        System.assertEquals(100, oppIds.size());
        
        //Verify that Chosen Provider got auto set
        myOppList = [Select Id, StageName, Chosen_Provider_Reference__c from Opportunity where Id in :oppIds];
        System.assertEquals(100, myOppList.size());
        for (Opportunity myOpp : myOppList) {
            System.assertEquals(aonHewitt.Id, myOpp.Chosen_Provider_Reference__c);
        }
        
        //Reopen them
        for (integer i=0; i<myOppList.size(); i++) {
            myOppList[i].StageName = 'Negotiate';
            myOppList[i].Probability = 75;
        }
        update myOppList;
        
        //Verify that Chosen Provider got cleared
        myOppList = [Select Id, StageName, Chosen_Provider_Reference__c from Opportunity where Id in :oppIds];
        System.assertEquals(100, myOppList.size());
        for (Opportunity myOpp : myOppList) {
            System.assertEquals(null, myOpp.Chosen_Provider_Reference__c);
        }
        
        //Close them again
        for (integer i=0; i<myOppList.size(); i++) {
            myOppList[i].StageName = 'Closed Won';
            myOppList[i].Probability = 100;
        }
        update myOppList;
        
        //Verify that Chosen Provider got auto set
        myOppList = [Select Id, StageName, Chosen_Provider_Reference__c from Opportunity where Id in :oppIds];
        System.assertEquals(100, myOppList.size());
        for (Opportunity myOpp : myOppList) {
            System.assertEquals(aonHewitt.Id, myOpp.Chosen_Provider_Reference__c);
        }
        
        //Move to Close Lost
        for (integer i=0; i<myOppList.size(); i++) {
            myOppList[i].StageName = 'Closed Lost';
            myOppList[i].Probability = 0;
        }
        update myOppList;
        
        Test.stopTest();
        
        //Verify that Chosen Provider got auto set
        myOppList = [Select Id, StageName, Chosen_Provider_Reference__c from Opportunity where Id in :oppIds];
        System.assertEquals(100, myOppList.size());
        for (Opportunity myOpp : myOppList) {
            System.assertEquals(other.Id, myOpp.Chosen_Provider_Reference__c);
        }
    } //testAutoSetChosenProvider_bulk
    
    
    //Ritu Sharma - Case # 00010036 - Test method to validate auto updation of marketing lead if opp has been created through it
    static testMethod void testUpdateMarketingLeadStatus()
    {   
        //Variable Declarations
        Account testAccount = new Account();
        Contact testContact = new Contact();
        Marketing_Lead__c testMarkLead = new Marketing_Lead__c();
        Opportunity testOpp = new Opportunity();
        List <Marketing_Lead__c> testMarkLeads = new List<Marketing_Lead__c>();
        List <String> testMarkLeadIds = new List<String>();
        List <Opportunity > testOpps= new List<Opportunity >();
        String opptyRecTypeID = '';
        Integer i=0;
        Integer countUpdatedLeads=0;
        
        //Getting Oppty Record Type ID
        opptyRecTypeID=util_sampleDataGenerator.getRecordType('Opportunity', 'Oppty Record').Id;
        
        //Create a dummy Account
        testAccount = util_sampleDataGenerator.createAccount_Client();
        System.assertNotEquals(null, testAccount.Id);
        System.debug('testAccount.Id - '+testAccount.Id);
        
        //Create a dummy Contact
        testContact = util_SampleDataGenerator.createContact_External(testAccount.Id); 
        System.assertNotEquals(null, testContact.Id);
        System.debug('testContact.Id - '+testContact.Id);
        
        //Create a dummy Marketing Lead
        testMarkLead = new Marketing_Lead__c();
        testMarkLead.Contact__c=testContact.ID;
        testMarkLead.Status__c='Open';      
        insert testMarkLead;
        System.assertNotEquals(null, testMarkLead.Id); 
        System.debug('testMarkLead.Id - '+testMarkLead.Id);      
        
        //Create a dummy opportunity
        testOpp = util_SampleDataGenerator.createOpportunityFromMarLead(testAccount.Id,testMarkLead.ID,opptyRecTypeID,'Test Opp', 1000.0, 'Qualify Opportunity', Date.today().addDays(30), 25);
        Insert testOpp ;
        System.assertNotEquals(null, testOpp.Id); 
        System.debug('testOpp.Id - '+testOpp.Id);
        
        //Check the status of Marketing Lead to ensure that it's status has been changed to Qualified (Converted) 
        testMarkLead = [select ID,Status__c from Marketing_Lead__c where ID=:testMarkLead.Id];
        System.assertEquals(testMarkLead.Status__c,'Qualified (Converted)'); 
        System.debug('testMarkLead.Status__c - '+testMarkLead.Status__c);
        
        //-----------------Bulk data test------------------
        for (i=0;i<50;i++) //Creating list of marketing leads
        {
            testMarkLead = new Marketing_Lead__c();
            testMarkLead.Contact__c=testContact.ID;
            testMarkLead.Status__c='Open';  
            testMarkLeads.add(testMarkLead);
        }
        Insert testMarkLeads; //Inserting leads
        System.debug('testMarkLeads.size() - '+testMarkLeads.size());
        
        //Creating list of marketing lead IDs that have just been inserted and list of opportunities that needs to be inserted
        for (i=0;i<testMarkLeads.size();i++) 
        {
            testMarkLeadIds.add(testMarkLeads[i].ID);
            testOpp = util_SampleDataGenerator.createOpportunityFromMarLead(testAccount.Id,testMarkLeads[i].ID,opptyRecTypeID,'Test Opp - '+i, 1000.0, 'Qualify Opportunity', Date.today().addDays(30), 25);
            testOpps.add(testOpp);
            //Insert testOpp;
        }
        Insert testOpps; //Inserting Opps
        System.debug('testOpps.size() - '+testOpps.size());
        
        //Checking if status of marketing leads changed to Qualified (Converted)
        testMarkLeads = [select ID,Status__c from Marketing_Lead__c where ID IN:testMarkLeadIds];
        for (i=0;i<testMarkLeads.size();i++) 
        {
            System.assertEquals(testMarkLeads[i].Status__c,'Qualified (Converted)');
            System.debug(i+'. ID='+testMarkLeads[i].ID+' ,Status='+testMarkLeads[i].Status__c);
        }
        System.debug('Printing counts: Opps='+testOpps.size()+', Updated Leads='+testMarkLeads.size());
    } //testUpdateMarketingLeadStatus
    
    
    /** Test that Opp Id is being stamped on the Identified owner field
      * Chintan, December 17, 2012 */
    static testMethod void test_populateIdentifiedOwner() {
        Test.startTest();
        
        //Create Account
        Account myAccount = util_sampleDataGenerator.createAccount_Client();
        System.assertNotEquals(null, myAccount.Id);
        
        //Create an Opportunity
        Opportunity myOpp = util_sampleDataGenerator.createOpportunity_US(myAccount.Id);
        System.assertNotEquals(null, myOpp.Id);
        
        //Verify
        myOpp = [Select Id, OwnerId, Identified_Opportunity_Owner__c from Opportunity Where Id = :myOpp.Id];
        System.assertEquals(UserInfo.getUserId() , myOpp.Identified_Opportunity_Owner__c);
        
        //Create a user
        User myUser = util_sampleDataGenerator.createHewittStandardUser();
        System.assertNotEquals(null, myUser.Id);
        
        //Update Opp's Owner
        myOpp.OwnerId = myUser.Id;
        update myOpp;
        
        //Verify
        myOpp = [Select Id, OwnerId, Identified_Opportunity_Owner__c from Opportunity Where Id = :myOpp.Id];
        System.assertEquals(myUser.Id , myOpp.Identified_Opportunity_Owner__c);
        
        Test.stopTest();
    } //test_populateIdentifiedOwner
    
    
    /** Bulk test that Opp Id is being stamped on the Identified owner field
      * Chintan, December 17, 2012 */
    static testMethod void test_populateIdentifiedOwner_bulk() {
        //local vars
        final integer count = 100;
        Id OppRecordTypeId = util_sampleDataGenerator.getRecordType('Opportunity', 'US Oppty Closed Record').Id;
        List<Opportunity> myOppList = new List<Opportunity> ();
        Set<Id> oppIds = new Set<Id> ();
        
        Test.startTest();
        
        //Create Account
        Account myAccount = util_sampleDataGenerator.createAccount_Client();
        System.assertNotEquals(null, myAccount.Id);
        
        //Create 'count' opps
        for (integer i=0; i<count; i++) {
            Opportunity myOpp = new Opportunity();
            myOpp.RecordTypeId = OppRecordTypeId;
            myOpp.AccountId = myAccount.Id;
            myOpp.Name = 'Chintan Test Apex Opportunity ' + i;
            myOpp.StageName = 'Non-Qualified Opportunity';
            myOpp.CloseDate = Date.today().addDays(55);
            myOpp.Probability = 10;
            //add the opportunity into list
            myOppList.add(myOpp);
        }
        //verify count elements
        System.assertEquals(count, myOppList.size());
        insert myOppList;
        for (Opportunity myOpp : myOppList) {
            oppIds.add(myOpp.Id);
            System.assertNotEquals(null, myOpp.Id);
        }
        
        //Verify
        myOppList = [Select Id, OwnerId, Identified_Opportunity_Owner__c from Opportunity Where Id in :oppIds];
        for (Opportunity myOpp : myOppList) {
            System.assertEquals(UserInfo.getUserId() , myOpp.Identified_Opportunity_Owner__c);
        }
        
        //Create a user
        User myUser = util_sampleDataGenerator.createHewittStandardUser();
        System.assertNotEquals(null, myUser.Id);
        
        //Update Opp's Owner
        for (Opportunity myOpp : myOppList) {
            myOpp.OwnerId = myUser.Id;
        }
        update myOppList;
        
        //Verify
        myOppList = [Select Id, OwnerId, Identified_Opportunity_Owner__c from Opportunity Where Id in :oppIds];
        for (Opportunity myOpp : myOppList) {
            System.assertEquals(myUser.Id , myOpp.Identified_Opportunity_Owner__c);
        }
        
        Test.stopTest();
    } //test_populateIdentifiedOwner_bulk
    
    
    //Test method syncBundledTotals for bundled opp totals
    //Case 69299, Chintan, October 3, 2013
    static testMethod void testBundledOpps_One() {   
        //Create an Account
        Account account = util_sampleDataGenerator.createAccount_Client();
        System.assertNotEquals(null, account.Id);

        //Create opportunities
        Id opptyRecTypeID = util_sampleDataGenerator.getRecordType('Opportunity', 'Oppty Record').Id;
        List<Opportunity> oppList = new List<Opportunity> ();
        
        Opportunity oppty1 = new Opportunity();
        oppty1.RecordTypeId = opptyRecTypeID;
        oppty1.accountId = account.Id;
        oppty1.name = 'Apex Test Opporunity 1';
        oppty1.amount = 1000.00;
        oppty1.StageName = 'Qualify Opportunity';
        oppty1.CloseDate = Date.today().addDays(30);
        oppty1.Probability = 25;
        oppList.add(oppty1);
        
        Opportunity oppty2 = new Opportunity();
        oppty2.RecordTypeId = opptyRecTypeID;
        oppty2.accountId = account.Id;
        oppty2.name = 'Apex Test Opporunity 2';
        oppty2.amount = 1000.00;
        oppty2.StageName = 'Qualify Opportunity';
        oppty2.CloseDate = Date.today().addDays(30);
        oppty2.Probability = 25;
        oppList.add(oppty2);
        
        Opportunity oppty3 = new Opportunity();
        oppty3.RecordTypeId = opptyRecTypeID;
        oppty3.accountId = account.Id;
        oppty3.name = 'Apex Test Opporunity 3';
        oppty3.amount = 1000.00;
        oppty3.StageName = 'Qualify Opportunity';
        oppty3.CloseDate = Date.today().addDays(30);
        oppty3.Probability = 25;
        oppList.add(oppty3);
        
        insert oppList;
        System.assertNotEquals(null, oppty1.Id);
        System.assertNotEquals(null, oppty2.Id);
        System.assertNotEquals(null, oppty3.Id);
          
        //Create products        
        List<Product2> productList = new list<Product2> ();
        
        Product2 product1 = new Product2();
        product1.Name = 'Apex Test Product 1';
        product1.Service_Classification__c = 'Consulting';
        product1.Use_Product_Specific_Field_List__c = false;
        product1.Validation_Process__c = 'Consulting';
        productList.add(product1);
        
        Product2 product2 = new Product2();
        product2.Name = 'Apex Test Product 2';
        product2.Service_Classification__c = 'Consulting';
        product2.Use_Product_Specific_Field_List__c = false;
        product2.Validation_Process__c = 'Consulting';
        productList.add(product2);
        
        Product2 product3 = new Product2();
        product3.Name = 'Apex Test Product 1';
        product3.Service_Classification__c = 'Consulting';
        product3.Use_Product_Specific_Field_List__c = false;
        product3.Validation_Process__c = 'Consulting';
        productList.add(product3);
        
        insert productList;
        System.assertNotEquals(null, product1.Id);
        System.assertNotEquals(null, product2.Id);
        System.assertNotEquals(null, product3.Id);
                  
        //Create pricebookentries    
        //Pricebook2 pb = util_sampleDataGenerator.getStandardPricebook(); 
        Id pbId = util_sampleDataGenerator.getStandardPricebookId();
        List<PricebookEntry> pbeList = new List<PricebookEntry> ();
        
        PricebookEntry pbe1 = new PricebookEntry();
        pbe1.Pricebook2Id = pbId;
        pbe1.Product2Id = product1.Id;
        pbe1.UnitPrice = 100.00;
        pbe1.IsActive = true;
        pbeList.add(pbe1);
        
        PricebookEntry pbe2 = new PricebookEntry();
        pbe2.Pricebook2Id = pbId;
        pbe2.Product2Id = product2.Id;
        pbe2.UnitPrice = 100.00;
        pbe2.IsActive = true;
        pbeList.add(pbe2);
        
        PricebookEntry pbe3 = new PricebookEntry();
        pbe3.Pricebook2Id = pbId;
        pbe3.Product2Id = product3.Id;
        pbe3.UnitPrice = 100.00;
        pbe3.IsActive = true;
        pbeList.add(pbe3);
        
        insert pbeList;
        System.assertNotEquals(null, pbe1.Id);
        System.assertNotEquals(null, pbe2.Id);
        System.assertNotEquals(null, pbe3.Id);
          
        //Tie services to opps
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem> ();
        
		OpportunityLineItem oli1 = new OpportunityLineItem();
        oli1.OpportunityId = oppty1.Id;
        oli1.PricebookEntryId = pbe1.Id;
        oli1.Quantity = 5;
        oli1.UnitPrice = 150.0;
        oli1.Recurring_Non_Recurring__c = 'Recurring';
        oli1.Fee_Commission__c = 'Fee';
        oli1.Type__c = 'New Client Sale - A';
        oli1.First_Year_Value__c = 10;
        oliList.add(oli1);
        
        OpportunityLineItem oli2 = new OpportunityLineItem();
        oli2.OpportunityId = oppty2.Id;
        oli2.PricebookEntryId = pbe2.Id;
        oli2.Quantity = 8;
        oli2.UnitPrice = 275.0;
        oli2.Recurring_Non_Recurring__c = 'Recurring';
        oli2.Fee_Commission__c = 'Fee';
        oli2.Type__c = 'New Client Sale - A';
        oli2.First_Year_Value__c = 10;
        oliList.add(oli2);
        
        OpportunityLineItem oli3 = new OpportunityLineItem();
        oli3.OpportunityId = oppty3.Id;
        oli3.PricebookEntryId = pbe3.Id;
        oli3.Quantity = 2;
        oli3.UnitPrice = 100.0;
        oli3.Recurring_Non_Recurring__c = 'Recurring';
        oli3.Fee_Commission__c = 'Fee';
        oli3.Type__c = 'New Client Sale - A';
        oli3.First_Year_Value__c = 10;
        oliList.add(oli3);
        
        insert oliList;
        System.assertNotEquals(null, oli1.Id);
        System.assertNotEquals(null, oli2.Id);
        System.assertNotEquals(null, oli3.Id);
          
        Test.startTest();
        //Reset flag
        util_globalUtilityMethods.setRunOnceFlag(false);
        
        //Bundle
        oppty2 = [Select Id, Lead_Opportunity_Name__c from Opportunity Where Id = :oppty2.Id];
        oppty2.Lead_Opportunity_Name__c = oppty1.Id;
        update oppty2;
        
        //Verify
        oppty1=[Select Id, Bundled_First_Year_Value__c, Bundled_Total_Opportunity_Value__c From Opportunity Where Id = :oppty1.Id];
        System.debug('CPA oppty1 is: ' + oppty1.Bundled_First_Year_Value__c + ', ' + oppty1.Bundled_Total_Opportunity_Value__c);
        System.assertEquals(oppty1.Bundled_First_Year_Value__c, 20);
        System.assertEquals(oppty1.Bundled_Total_Opportunity_Value__c, 2950);
        
        //Reset flag
        util_globalUtilityMethods.setRunOnceFlag(false);
        
        //Swap Lead Opp
        oppty2.Lead_Opportunity_Name__c = oppty3.Id;
        update oppty2;
        
        //Verify
        oppty1=[Select Id, Bundled_First_Year_Value__c, Bundled_Total_Opportunity_Value__c From Opportunity Where Id = :oppty1.Id];
        oppty3=[Select Id, Bundled_First_Year_Value__c, Bundled_Total_Opportunity_Value__c From Opportunity Where Id = :oppty3.Id];
        System.debug('CPA oppty1 is: ' + oppty1.Bundled_First_Year_Value__c + ', ' + oppty1.Bundled_Total_Opportunity_Value__c);
        System.debug('CPA oppty3 is: ' + oppty3.Bundled_First_Year_Value__c + ', ' + oppty3.Bundled_Total_Opportunity_Value__c);
        System.assertEquals(oppty1.Bundled_First_Year_Value__c, 10);
        System.assertEquals(oppty1.Bundled_Total_Opportunity_Value__c, 750);
        System.assertEquals(oppty3.Bundled_First_Year_Value__c, 20);
        System.assertEquals(oppty3.Bundled_Total_Opportunity_Value__c, 2400);
     
        Test.stopTest();
    } //testBundledOpps_One
    
    
    //Test method syncBundledTotals for bundled opp totals
    //Case 69299, Chintan, October 3, 2013
    static testMethod void testBundledOpps_Two() {   
        //Create an Account
        Account account = util_sampleDataGenerator.createAccount_Client();
        System.assertNotEquals(null, account.Id);
        Id pbId = util_sampleDataGenerator.getStandardPricebookId();
        //Create opportunities
        Id opptyRecTypeID = util_sampleDataGenerator.getRecordType('Opportunity', 'Oppty Record').Id;
        List<Opportunity> oppList = new List<Opportunity> ();
        
        Opportunity oppty1 = new Opportunity();
        oppty1.RecordTypeId = opptyRecTypeID;
        oppty1.accountId = account.Id;
        oppty1.name = 'Apex Test Opporunity 1';
        oppty1.amount = 1000.00;
        oppty1.StageName = 'Qualify Opportunity';
        oppty1.CloseDate = Date.today().addDays(30);
        oppty1.Probability = 25;
        oppList.add(oppty1);
        
        Opportunity oppty2 = new Opportunity();
        oppty2.RecordTypeId = opptyRecTypeID;
        oppty2.accountId = account.Id;
        oppty2.name = 'Apex Test Opporunity 2';
        oppty2.amount = 1000.00;
        oppty2.StageName = 'Qualify Opportunity';
        oppty2.CloseDate = Date.today().addDays(30);
        oppty2.Probability = 25;
        oppList.add(oppty2);
        
        Opportunity oppty3 = new Opportunity();
        oppty3.RecordTypeId = opptyRecTypeID;
        oppty3.accountId = account.Id;
        oppty3.name = 'Apex Test Opporunity 3';
        oppty3.amount = 1000.00;
        oppty3.StageName = 'Qualify Opportunity';
        oppty3.CloseDate = Date.today().addDays(30);
        oppty3.Probability = 25;
        oppList.add(oppty3);
        
        insert oppList;
        System.assertNotEquals(null, oppty1.Id);
        System.assertNotEquals(null, oppty2.Id);
        System.assertNotEquals(null, oppty3.Id);
          
        //Create products        
        List<Product2> productList = new list<Product2> ();
        
        Product2 product1 = new Product2();
        product1.Name = 'Apex Test Product 1';
        product1.Service_Classification__c = 'Consulting';
        product1.Use_Product_Specific_Field_List__c = false;
        product1.Validation_Process__c = 'Consulting';
        productList.add(product1);
        
        Product2 product2 = new Product2();
        product2.Name = 'Apex Test Product 2';
        product2.Service_Classification__c = 'Consulting';
        product2.Use_Product_Specific_Field_List__c = false;
        product2.Validation_Process__c = 'Consulting';
        productList.add(product2);
        
        Product2 product3 = new Product2();
        product3.Name = 'Apex Test Product 1';
        product3.Service_Classification__c = 'Consulting';
        product3.Use_Product_Specific_Field_List__c = false;
        product3.Validation_Process__c = 'Consulting';
        productList.add(product3);
        
        insert productList;
        System.assertNotEquals(null, product1.Id);
        System.assertNotEquals(null, product2.Id);
        System.assertNotEquals(null, product3.Id);
                  
        //Create pricebookentries    
        //Pricebook2 pb = util_sampleDataGenerator.getStandardPricebook(); 
        List<PricebookEntry> pbeList = new List<PricebookEntry> ();
        
        PricebookEntry pbe1 = new PricebookEntry();
        pbe1.Pricebook2Id = pbId;
        pbe1.Product2Id = product1.Id;
        pbe1.UnitPrice = 100.00;
        pbe1.IsActive = true;
        pbeList.add(pbe1);
        
        PricebookEntry pbe2 = new PricebookEntry();
        pbe2.Pricebook2Id = pbId;
        pbe2.Product2Id = product2.Id;
        pbe2.UnitPrice = 100.00;
        pbe2.IsActive = true;
        pbeList.add(pbe2);
        
        PricebookEntry pbe3 = new PricebookEntry();
        pbe3.Pricebook2Id = pbId;
        pbe3.Product2Id = product3.Id;
        pbe3.UnitPrice = 100.00;
        pbe3.IsActive = true;
        pbeList.add(pbe3);
        
        insert pbeList;
        System.assertNotEquals(null, pbe1.Id);
        System.assertNotEquals(null, pbe2.Id);
        System.assertNotEquals(null, pbe3.Id);
          
        //Tie services to opps
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem> ();
        
		OpportunityLineItem oli1 = new OpportunityLineItem();
        oli1.OpportunityId = oppty1.Id;
        oli1.PricebookEntryId = pbe1.Id;
        oli1.Quantity = 5;
        oli1.UnitPrice = 150.0;
        oli1.Recurring_Non_Recurring__c = 'Recurring';
        oli1.Fee_Commission__c = 'Fee';
        oli1.Type__c = 'New Client Sale - A';
        oli1.First_Year_Value__c = 10;
        oliList.add(oli1);
        
        OpportunityLineItem oli2 = new OpportunityLineItem();
        oli2.OpportunityId = oppty2.Id;
        oli2.PricebookEntryId = pbe2.Id;
        oli2.Quantity = 8;
        oli2.UnitPrice = 275.0;
        oli2.Recurring_Non_Recurring__c = 'Recurring';
        oli2.Fee_Commission__c = 'Fee';
        oli2.Type__c = 'New Client Sale - A';
        oli2.First_Year_Value__c = 10;
        oliList.add(oli2);
        
        OpportunityLineItem oli3 = new OpportunityLineItem();
        oli3.OpportunityId = oppty3.Id;
        oli3.PricebookEntryId = pbe3.Id;
        oli3.Quantity = 2;
        oli3.UnitPrice = 100.0;
        oli3.Recurring_Non_Recurring__c = 'Recurring';
        oli3.Fee_Commission__c = 'Fee';
        oli3.Type__c = 'New Client Sale - A';
        oli3.First_Year_Value__c = 10;
        oliList.add(oli3);
        
        insert oliList;
        System.assertNotEquals(null, oli1.Id);
        System.assertNotEquals(null, oli2.Id);
        System.assertNotEquals(null, oli3.Id);
          
        Test.startTest();
        //Reset flag
        util_globalUtilityMethods.setRunOnceFlag(false);
        
        //Bundle
        oppty2 = [Select Id, Lead_Opportunity_Name__c from Opportunity Where Id = :oppty2.Id];
        oppty2.Lead_Opportunity_Name__c = oppty1.Id;
        update oppty2;
        
        //Verify
        oppty1=[Select Id, Bundled_First_Year_Value__c, Bundled_Total_Opportunity_Value__c From Opportunity Where Id = :oppty1.Id];
        System.debug('CPA oppty1 is: ' + oppty1.Bundled_First_Year_Value__c + ', ' + oppty1.Bundled_Total_Opportunity_Value__c);
        System.assertEquals(oppty1.Bundled_First_Year_Value__c, 20);
        System.assertEquals(oppty1.Bundled_Total_Opportunity_Value__c, 2950);
        
        //Reset flag
        util_globalUtilityMethods.setRunOnceFlag(false);
        
        //Unbundle
        oppty2.Lead_Opportunity_Name__c = null;
        update oppty2;
        
        //Verify
        oppty1=[Select Id, Bundled_First_Year_Value__c, Bundled_Total_Opportunity_Value__c From Opportunity Where Id = :oppty1.Id];
        System.debug('CPA oppty1 is: ' + oppty1.Bundled_First_Year_Value__c + ', ' + oppty1.Bundled_Total_Opportunity_Value__c);
        System.assertEquals(oppty1.Bundled_First_Year_Value__c, 10);
        System.assertEquals(oppty1.Bundled_Total_Opportunity_Value__c, 750);
        
        //Reset flag
        util_globalUtilityMethods.setRunOnceFlag(false);
        
        //Rebundle
        oppty2.Lead_Opportunity_Name__c = oppty3.Id;
        update oppty2;
        
        //Verify
        oppty3=[Select Id, Bundled_First_Year_Value__c, Bundled_Total_Opportunity_Value__c From Opportunity Where Id = :oppty3.Id];
        System.debug('CPA oppty3 is: ' + oppty3.Bundled_First_Year_Value__c + ', ' + oppty3.Bundled_Total_Opportunity_Value__c);
        System.assertEquals(oppty3.Bundled_First_Year_Value__c, 20);
        System.assertEquals(oppty3.Bundled_Total_Opportunity_Value__c, 2400);
        
         //Reset flag
        util_globalUtilityMethods.setRunOnceFlag(false);
        
        //delete
        delete oppty2;
        
        //Verify
        oppty3=[Select Id, Bundled_First_Year_Value__c, Bundled_Total_Opportunity_Value__c From Opportunity Where Id = :oppty3.Id];
        System.debug('CPA oppty3 is: ' + oppty3.Bundled_First_Year_Value__c + ', ' + oppty3.Bundled_Total_Opportunity_Value__c);
        System.assertEquals(oppty3.Bundled_First_Year_Value__c, 10);
        System.assertEquals(oppty3.Bundled_Total_Opportunity_Value__c, 200);
      
        Test.stopTest();
    } //testBundledOpps_Two
    
    
    //Test method syncBundledTotals for bundled opp totals
    //Case 69299, Chintan, October 3, 2013
    static testMethod void testBundledServices() {   
        //Create an Account
        Account account = util_sampleDataGenerator.createAccount_Client();
        System.assertNotEquals(null, account.Id);
        Id pbId = util_sampleDataGenerator.getStandardPricebookId();

        //Create opportunities
        Id opptyRecTypeID = util_sampleDataGenerator.getRecordType('Opportunity', 'Oppty Record').Id;
        List<Opportunity> oppList = new List<Opportunity> ();
        
        Opportunity oppty1 = new Opportunity();
        oppty1.RecordTypeId = opptyRecTypeID;
        oppty1.accountId = account.Id;
        oppty1.name = 'Apex Test Opporunity 1';
        oppty1.amount = 1000.00;
        oppty1.StageName = 'Qualify Opportunity';
        oppty1.CloseDate = Date.today().addDays(30);
        oppty1.Probability = 25;
        oppList.add(oppty1);
        
        Opportunity oppty2 = new Opportunity();
        oppty2.RecordTypeId = opptyRecTypeID;
        oppty2.accountId = account.Id;
        oppty2.name = 'Apex Test Opporunity 2';
        oppty2.amount = 1000.00;
        oppty2.StageName = 'Qualify Opportunity';
        oppty2.CloseDate = Date.today().addDays(30);
        oppty2.Probability = 25;
        oppList.add(oppty2);
        
        insert oppList;
        System.assertNotEquals(null, oppty1.Id);
        System.assertNotEquals(null, oppty2.Id);
          
        //Create products        
        List<Product2> productList = new list<Product2> ();
        
        Product2 product1 = new Product2();
        product1.Name = 'Apex Test Product 1';
        product1.Service_Classification__c = 'Consulting';
        product1.Use_Product_Specific_Field_List__c = false;
        product1.Validation_Process__c = 'Consulting';
        productList.add(product1);
        
        Product2 product2 = new Product2();
        product2.Name = 'Apex Test Product 2';
        product2.Service_Classification__c = 'Consulting';
        product2.Use_Product_Specific_Field_List__c = false;
        product2.Validation_Process__c = 'Consulting';
        productList.add(product2);
        
        insert productList;
        System.assertNotEquals(null, product1.Id);
        System.assertNotEquals(null, product2.Id);
                  
        //Create pricebookentries    
        //Pricebook2 pb = util_sampleDataGenerator.getStandardPricebook(); 
        List<PricebookEntry> pbeList = new List<PricebookEntry> ();
        
        PricebookEntry pbe1 = new PricebookEntry();
        pbe1.Pricebook2Id = pbId;
        pbe1.Product2Id = product1.Id;
        pbe1.UnitPrice = 100.00;
        pbe1.IsActive = true;
        pbeList.add(pbe1);
        
        PricebookEntry pbe2 = new PricebookEntry();
        pbe2.Pricebook2Id = pbId;
        pbe2.Product2Id = product2.Id;
        pbe2.UnitPrice = 100.00;
        pbe2.IsActive = true;
        pbeList.add(pbe2);
        
        insert pbeList;
        System.assertNotEquals(null, pbe1.Id);
        System.assertNotEquals(null, pbe2.Id);
          
        //Tie services to opps
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem> ();
        
		OpportunityLineItem oli1 = new OpportunityLineItem();
        oli1.OpportunityId = oppty1.Id;
        oli1.PricebookEntryId = pbe1.Id;
        oli1.Quantity = 2;
        oli1.UnitPrice = 500.0;
        oli1.Recurring_Non_Recurring__c = 'Recurring';
        oli1.Fee_Commission__c = 'Fee';
        oli1.Type__c = 'New Client Sale - A';
        oli1.First_Year_Value__c = 10;
        oliList.add(oli1);
        
        OpportunityLineItem oli2 = new OpportunityLineItem();
        oli2.OpportunityId = oppty2.Id;
        oli2.PricebookEntryId = pbe2.Id;
        oli2.Quantity = 2;
        oli2.UnitPrice = 1000.0;
        oli2.Recurring_Non_Recurring__c = 'Recurring';
        oli2.Fee_Commission__c = 'Fee';
        oli2.Type__c = 'New Client Sale - A';
        oli2.First_Year_Value__c = 10;
        oliList.add(oli2);
        
        insert oliList;
        System.assertNotEquals(null, oli1.Id);
        System.assertNotEquals(null, oli2.Id);
          
        Test.startTest();
        //Reset flag
        util_globalUtilityMethods.setRunOnceFlag(false);
        
        //Bundle
        oppty2 = [Select Id, Lead_Opportunity_Name__c from Opportunity Where Id = :oppty2.Id];
        oppty2.Lead_Opportunity_Name__c = oppty1.Id;
        update oppty2;
        
        //Verify
        oppty1=[Select Id, Bundled_First_Year_Value__c, Bundled_Total_Opportunity_Value__c From Opportunity Where Id = :oppty1.Id];
        System.debug('CPA oppty1 is: ' + oppty1.Bundled_First_Year_Value__c + ', ' + oppty1.Bundled_Total_Opportunity_Value__c);
        System.assertEquals(oppty1.Bundled_First_Year_Value__c, 20);
        System.assertEquals(oppty1.Bundled_Total_Opportunity_Value__c, 3000);
        
        //Reset flag
        util_globalUtilityMethods.setRunOnceFlag(false);
        
        //Add service to lead opp
        OpportunityLineItem oli3 = util_sampleDataGenerator.createOpportunityProduct(oppty1.Id, pbe2.Id, 1, 1000.0);
        System.assertNotEquals(null, oli3.Id);
        
        //Verify
        oppty1=[Select Id, Bundled_First_Year_Value__c, Bundled_Total_Opportunity_Value__c From Opportunity Where Id = :oppty1.Id];
        System.debug('CPA oppty1 is: ' + oppty1.Bundled_First_Year_Value__c + ', ' + oppty1.Bundled_Total_Opportunity_Value__c);
        System.assertEquals(oppty1.Bundled_First_Year_Value__c, 30);
        System.assertEquals(oppty1.Bundled_Total_Opportunity_Value__c, 4000);
        
        //Reset flag
        util_globalUtilityMethods.setRunOnceFlag(false);
        
        //Add service to bundled opp
        OpportunityLineItem oli4 = util_sampleDataGenerator.createOpportunityProduct(oppty1.Id, pbe2.Id, 1, 1000.0);
        System.assertNotEquals(null, oli4.Id);
        
        //Verify
        oppty1=[Select Id, Bundled_First_Year_Value__c, Bundled_Total_Opportunity_Value__c From Opportunity Where Id = :oppty1.Id];
        System.debug('CPA oppty1 is: ' + oppty1.Bundled_First_Year_Value__c + ', ' + oppty1.Bundled_Total_Opportunity_Value__c);
        System.assertEquals(oppty1.Bundled_First_Year_Value__c, 40);
        System.assertEquals(oppty1.Bundled_Total_Opportunity_Value__c, 5000);
        
        //Reset flag
        util_globalUtilityMethods.setRunOnceFlag(false);
        
        //Delete service from lead opp
        delete oli3;
        
        Test.stopTest();
        
        //Verify
        oppty1=[Select Id, Bundled_First_Year_Value__c, Bundled_Total_Opportunity_Value__c From Opportunity Where Id = :oppty1.Id];
        System.debug('CPA oppty1 is: ' + oppty1.Bundled_First_Year_Value__c + ', ' + oppty1.Bundled_Total_Opportunity_Value__c);
        System.assertEquals(oppty1.Bundled_First_Year_Value__c, 30);
        System.assertEquals(oppty1.Bundled_Total_Opportunity_Value__c, 4000);
    } //testBundledServices
    
    
    //Test method syncBundledTotals for bundled opp totals
    //Case 69299, Chintan, October 3, 2013
    static testMethod void testBundledServices2() {   
        //Create an Account
        Account account = util_sampleDataGenerator.createAccount_Client();
        System.assertNotEquals(null, account.Id);

        //Create opportunities
        Opportunity oppty1 = util_sampleDataGenerator.createOpportunity_US(account.Id);
        Opportunity oppty2 = util_sampleDataGenerator.createOpportunity_US(account.Id);
        System.assertNotEquals(null, oppty1.Id);
        System.assertNotEquals(null, oppty2.Id);
          
        //Create products        
        Product2 product1 = util_sampleDataGenerator.createProduct('LJ TEST PRODUCT1', 'Consulting', false, 'Consulting');
        Product2 product2 = util_sampleDataGenerator.createProduct('LJ TEST PRODUCT2', 'Consulting', false, 'Consulting');
        System.assertNotEquals(null, product1.Id);
        System.assertNotEquals(null, product2.Id);
                  
        //Create pricebookentries        
        PricebookEntry pbe1 = util_sampleDataGenerator.createStandardPriceForProduct(product1.id, 100.0);
        PricebookEntry pbe2 = util_sampleDataGenerator.createStandardPriceForProduct(product2.id, 100.0);
        System.assertNotEquals(null, pbe1.Id);
        System.assertNotEquals(null, pbe2.Id);
          
        //Tie services to opps
        OpportunityLineItem oli1 = util_sampleDataGenerator.createOpportunityProduct(oppty1.Id, pbe1.Id, 2, 500.0);
        OpportunityLineItem oli2 = util_sampleDataGenerator.createOpportunityProduct(oppty2.Id, pbe2.Id, 2, 1000.0);
        System.assertNotEquals(null, oli1.Id);
        System.assertNotEquals(null, oli2.Id);
        
        //Reset flag
        util_globalUtilityMethods.setRunOnceFlag(false);
        
        //Bundle
        oppty2 = [Select Id, Lead_Opportunity_Name__c from Opportunity Where Id = :oppty2.Id];
        oppty2.Lead_Opportunity_Name__c = oppty1.Id;
        update oppty2;
        
        //Reset flag
        util_globalUtilityMethods.setRunOnceFlag(false);
        
        Test.startTest();
        
        //Update Service on Lead Opp
        oli1 = [Select Id, First_Year_Value__c, UnitPrice From OpportunityLineItem Where Id = :oli1.Id];
        oli1.UnitPrice = 1000.0;
        update oli1;
        
        //Verify
        oppty1=[Select Id, Bundled_First_Year_Value__c, Bundled_Total_Opportunity_Value__c From Opportunity Where Id = :oppty1.Id];
        System.debug('CPA oppty1 is: ' + oppty1.Bundled_First_Year_Value__c + ', ' + oppty1.Bundled_Total_Opportunity_Value__c);
        System.assertEquals(oppty1.Bundled_First_Year_Value__c, 20);
        System.assertEquals(oppty1.Bundled_Total_Opportunity_Value__c, 4000);
        
        //Update Service on Bundled Opp
        oli2 = [Select Id, First_Year_Value__c, UnitPrice From OpportunityLineItem Where Id = :oli2.Id];
        oli2.UnitPrice = 500.0;
        update oli2;
        
        //Verify
        oppty1=[Select Id, Bundled_First_Year_Value__c, Bundled_Total_Opportunity_Value__c From Opportunity Where Id = :oppty1.Id];
        System.debug('CPA oppty1 is: ' + oppty1.Bundled_First_Year_Value__c + ', ' + oppty1.Bundled_Total_Opportunity_Value__c);
        System.assertEquals(oppty1.Bundled_First_Year_Value__c, 20);
        System.assertEquals(oppty1.Bundled_Total_Opportunity_Value__c, 3000);
        
        Test.stopTest();
    } //testBundledServices2
    
    
    //Test method syncBundledTotals for bundled opp totals
    //Case 69299, Chintan, October 21, 2013
    static testMethod void testBundledServices3() {   
        //Create an Account
        Account account = util_sampleDataGenerator.createAccount_Client();
        System.assertNotEquals(null, account.Id);

        //Create opportunities
        Opportunity oppty1 = util_sampleDataGenerator.createOpportunity_US(account.Id);
        Opportunity oppty2 = util_sampleDataGenerator.createOpportunity_US(account.Id);
        System.assertNotEquals(null, oppty1.Id);
        System.assertNotEquals(null, oppty2.Id);
          
        //Create products        
        Product2 product1 = util_sampleDataGenerator.createProduct('LJ TEST PRODUCT1', 'Consulting', false, 'Consulting');
        Product2 product2 = util_sampleDataGenerator.createProduct('LJ TEST PRODUCT2', 'Consulting', false, 'Consulting');
        System.assertNotEquals(null, product1.Id);
        System.assertNotEquals(null, product2.Id);
                  
        //Create pricebookentries        
        PricebookEntry pbe1 = util_sampleDataGenerator.createStandardPriceForProduct(product1.id, 100.0);
        PricebookEntry pbe2 = util_sampleDataGenerator.createStandardPriceForProduct(product2.id, 100.0);
        System.assertNotEquals(null, pbe1.Id);
        System.assertNotEquals(null, pbe2.Id);
          
        //Tie services to opps
        OpportunityLineItem oli1 = util_sampleDataGenerator.createOpportunityProduct(oppty1.Id, pbe1.Id, 2, 500.0);
        OpportunityLineItem oli2 = util_sampleDataGenerator.createOpportunityProduct(oppty2.Id, pbe2.Id, 2, 1000.0);
        System.assertNotEquals(null, oli1.Id);
        System.assertNotEquals(null, oli2.Id);
        
        //Reset flag
        util_globalUtilityMethods.setRunOnceFlag(false);
        
        //Bundle
        oppty2 = [Select Id, Lead_Opportunity_Name__c, Oportunity_Auto_Number__c from Opportunity Where Id = :oppty2.Id];
        oppty2.Lead_Opportunity_Name__c = oppty1.Id;
        update oppty2;
        
        //Reset flag
        util_globalUtilityMethods.setRunOnceFlag(false);
        
        Test.startTest();
        
        //Verify
        oppty1=[Select Id, Oportunity_Auto_Number__c, Bundled_First_Year_Value__c, Bundled_Total_Opportunity_Value__c, All_Service_Oppty_CRM_ID__c, All_Services__c From Opportunity Where Id = :oppty1.Id];
        System.debug('CPA oppty1 CRM IDs are: ' + oppty1.All_Service_Oppty_CRM_ID__c + ' and services: ' + oppty1.All_Services__c);
        System.assertEquals(oppty1.All_Service_Oppty_CRM_ID__c, oppty1.Oportunity_Auto_Number__c + ';' + oppty2.Oportunity_Auto_Number__c);
        System.assertEquals(oppty1.All_Services__c, 'LJ TEST PRODUCT1;LJ TEST PRODUCT2');
        
        Test.stopTest();
    } //testBundledServices3
    
    
    //Test method syncBundledTotals for bundled opp totals
    //Case 69299, Chintan, October 3, 2013
    static testMethod void testBundledServices4() {   
        //Create an Account
        Id pbId = util_sampleDataGenerator.getStandardPricebookId();
        Account account = util_sampleDataGenerator.createAccount_Client();
        System.assertNotEquals(null, account.Id);

        //Create opportunities
        Id opptyRecTypeID = util_sampleDataGenerator.getRecordType('Opportunity', 'Oppty Record').Id;
        List<Opportunity> oppList = new List<Opportunity> ();
        
        Opportunity oppty1 = new Opportunity();
        oppty1.RecordTypeId = opptyRecTypeID;
        oppty1.accountId = account.Id;
        oppty1.name = 'Apex Test Opporunity 1';
        oppty1.amount = 1000.00;
        oppty1.StageName = 'Qualify Opportunity';
        oppty1.CloseDate = Date.today().addDays(30);
        oppty1.Probability = 25;
        oppList.add(oppty1);
        
        Opportunity oppty2 = new Opportunity();
        oppty2.RecordTypeId = opptyRecTypeID;
        oppty2.accountId = account.Id;
        oppty2.name = 'Apex Test Opporunity 2';
        oppty2.amount = 1000.00;
        oppty2.StageName = 'Qualify Opportunity';
        oppty2.CloseDate = Date.today().addDays(30);
        oppty2.Probability = 25;
        oppList.add(oppty2);
        
        insert oppList;
        System.assertNotEquals(null, oppty1.Id);
        System.assertNotEquals(null, oppty2.Id);
          
        //Create products        
        List<Product2> productList = new list<Product2> ();
        
        Product2 product1 = new Product2();
        product1.Name = 'Apex Test Product 1';
        product1.Service_Classification__c = 'Consulting';
        product1.Use_Product_Specific_Field_List__c = false;
        product1.Validation_Process__c = 'Consulting';
        productList.add(product1);
        
        Product2 product2 = new Product2();
        product2.Name = 'Apex Test Product 2';
        product2.Service_Classification__c = 'Consulting';
        product2.Use_Product_Specific_Field_List__c = false;
        product2.Validation_Process__c = 'Consulting';
        productList.add(product2);
        
        insert productList;
        System.assertNotEquals(null, product1.Id);
        System.assertNotEquals(null, product2.Id);
                  
        //Create pricebookentries    
        //Pricebook2 pb = util_sampleDataGenerator.getStandardPricebook(); 
        List<PricebookEntry> pbeList = new List<PricebookEntry> ();
        
        PricebookEntry pbe1 = new PricebookEntry();
        pbe1.Pricebook2Id = pbId;
        pbe1.Product2Id = product1.Id;
        pbe1.UnitPrice = 100.00;
        pbe1.IsActive = true;
        pbeList.add(pbe1);
        
        PricebookEntry pbe2 = new PricebookEntry();
        pbe2.Pricebook2Id = pbId;
        pbe2.Product2Id = product2.Id;
        pbe2.UnitPrice = 100.00;
        pbe2.IsActive = true;
        pbeList.add(pbe2);
        
        insert pbeList;
        System.assertNotEquals(null, pbe1.Id);
        System.assertNotEquals(null, pbe2.Id);
          
        //Tie services to opps
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem> ();
        
		OpportunityLineItem oli1 = new OpportunityLineItem();
        oli1.OpportunityId = oppty1.Id;
        oli1.PricebookEntryId = pbe1.Id;
        oli1.Quantity = 2;
        oli1.UnitPrice = 500.0;
        oli1.Recurring_Non_Recurring__c = 'Recurring';
        oli1.Fee_Commission__c = 'Fee';
        oli1.Type__c = 'New Client Sale - A';
        oli1.First_Year_Value__c = 10;
        oliList.add(oli1);
        
        OpportunityLineItem oli2 = new OpportunityLineItem();
        oli2.OpportunityId = oppty2.Id;
        oli2.PricebookEntryId = pbe2.Id;
        oli2.Quantity = 2;
        oli2.UnitPrice = 1000.0;
        oli2.Recurring_Non_Recurring__c = 'Recurring';
        oli2.Fee_Commission__c = 'Fee';
        oli2.Type__c = 'New Client Sale - A';
        oli2.First_Year_Value__c = 10;
        oliList.add(oli2);
        
        insert oliList;
        System.assertNotEquals(null, oli1.Id);
        System.assertNotEquals(null, oli2.Id);
          
        Test.startTest();
        //Reset flag
        util_globalUtilityMethods.setRunOnceFlag(false);
        
        //Bundle
        oppty2 = [Select Id, Lead_Opportunity_Name__c from Opportunity Where Id = :oppty2.Id];
        oppty2.Lead_Opportunity_Name__c = oppty1.Id;
        update oppty2;
        
        //Verify
        oppty1=[Select Id, Bundled_First_Year_Value__c, Bundled_Total_Opportunity_Value__c From Opportunity Where Id = :oppty1.Id];
        System.debug('CPA oppty1 is: ' + oppty1.Bundled_First_Year_Value__c + ', ' + oppty1.Bundled_Total_Opportunity_Value__c);
        System.assertEquals(oppty1.Bundled_First_Year_Value__c, 20);
        System.assertEquals(oppty1.Bundled_Total_Opportunity_Value__c, 3000);
        
        //Reset flag
        util_globalUtilityMethods.setRunOnceFlag(false);
        
        //Add service to lead opp
        OpportunityLineItem oli3 = util_sampleDataGenerator.createOpportunityProduct(oppty1.Id, pbe2.Id, 1, 1000.0);
        System.assertNotEquals(null, oli3.Id);
        
        //Verify
        oppty1=[Select Id, Bundled_First_Year_Value__c, Bundled_Total_Opportunity_Value__c From Opportunity Where Id = :oppty1.Id];
        System.debug('CPA oppty1 is: ' + oppty1.Bundled_First_Year_Value__c + ', ' + oppty1.Bundled_Total_Opportunity_Value__c);
        System.assertEquals(oppty1.Bundled_First_Year_Value__c, 30);
        System.assertEquals(oppty1.Bundled_Total_Opportunity_Value__c, 4000);
        
        //Reset flag
        util_globalUtilityMethods.setRunOnceFlag(false);
        
        //Add service to bundled opp
        OpportunityLineItem oli4 = util_sampleDataGenerator.createOpportunityProduct(oppty1.Id, pbe2.Id, 1, 1000.0);
        System.assertNotEquals(null, oli4.Id);
        
        //Verify
        oppty1=[Select Id, Bundled_First_Year_Value__c, Bundled_Total_Opportunity_Value__c From Opportunity Where Id = :oppty1.Id];
        System.debug('CPA oppty1 is: ' + oppty1.Bundled_First_Year_Value__c + ', ' + oppty1.Bundled_Total_Opportunity_Value__c);
        System.assertEquals(oppty1.Bundled_First_Year_Value__c, 40);
        System.assertEquals(oppty1.Bundled_Total_Opportunity_Value__c, 5000);
        
        //Reset flag
        util_globalUtilityMethods.setRunOnceFlag(false);
        
        //Delete service from bundled opp
        delete oli4;
        
        Test.stopTest();
        
        //Verify
        oppty1=[Select Id, Bundled_First_Year_Value__c, Bundled_Total_Opportunity_Value__c From Opportunity Where Id = :oppty1.Id];
        System.debug('CPA oppty1 is: ' + oppty1.Bundled_First_Year_Value__c + ', ' + oppty1.Bundled_Total_Opportunity_Value__c);
        System.assertEquals(oppty1.Bundled_First_Year_Value__c, 30);
        System.assertEquals(oppty1.Bundled_Total_Opportunity_Value__c, 4000);
    } //testBundledServices4
    
    /*
    //00121299-Ritu Sharma-Test code for setFirstYearValue method
    static testMethod void test_setFirstYearValue() {
        Product2 product;
        PricebookEntry pbEntry;
        Account account;
        ID oppRecTypeID;
        List<Opportunity> oppsList;
        Opportunity opp;
        OpportunityLineItem lineItem;
        List<OpportunityLineItem> lineItemsList;
        List<OpportunityLineItem> templineItemsList;
        OpportunityLineItemSchedule schedule; 
        List<OpportunityLineItemSchedule> schedulesList;
        Date scheduleDate;
        Double firstYearAmt;
        
        //Create a product
        product = New Product2(Name='Test Product', Service_Classification__c='Consulting',Use_Product_Specific_Field_List__c=false,Validation_Process__c='Consulting',IsActive=True,CanUseRevenueSchedule=True);                        
        insert product;
        System.assertNotEquals(null, product.Id);
        
        //Create a pricebookentry
        pbEntry = util_sampleDataGenerator.createStandardPriceForProduct(product.id, 100.0);
        System.assertNotEquals(null, pbEntry.Id);        
        
        //Create an account
        account = util_sampleDataGenerator.createAccount_Client();
        System.assertNotEquals(null, account.Id);
        
        //Getting opportunity record type id
        oppRecTypeID = util_sampleDataGenerator.getRecordType('Opportunity', 'Oppty Record').Id;
        
        //Create 250 opportunities
        oppsList = new List<opportunity>();
        for (Integer i=0;i<250;i++) {
            opp = new Opportunity(RecordTypeId=oppRecTypeID,accountId=account.ID,name='Test Opp-'+i,amount=1000.0,StageName='Qualify Opportunity',CloseDate=Date.today().addDays(30),Probability=25);    
            oppsList.add(opp);   
        }   
        Insert oppsList; 
        
        //Creating one line item for each opportunity
        lineItemsList = new List<OpportunityLineItem>();
        for (Integer i=0;i<250;i++) {
            lineItem = new OpportunityLineItem(OpportunityId=oppsList[i].ID,PricebookEntryId=pbEntry.ID,Recurring_Non_Recurring__c='Recurring',Fee_Commission__c='Fee',Type__c='New Client Sale - A',UnitPrice=12000.0,First_Year_Value__c=500,Service_Start_Date__c=Date.today());
            lineItemsList.add(lineItem);
        }
        Insert lineItemsList;
        
        test.startTest();
        //Creating revenue schedule for 200 opps
        schedulesList = New List<OpportunityLineItemSchedule>();   
        for (Integer i=0;i<200;i++) {                  
            scheduleDate = date.newInstance(Date.today().year(), Date.today().month(),1);            
            //Creating monthly schedules
            for (Integer k = 0; k < 12 ; k++)  {                
                schedule = new OpportunityLineItemSchedule(OpportunityLineItemID = lineItemsList[i].ID,ScheduleDate = scheduleDate.addmonths(k), Type = 'Revenue',REVENUE = 1000.0);                
                schedulesList.add(schedule);            
            }        
        }
        insert schedulesList;    
        test.stopTest();
                
        //Since schedule has been created only for the product associated with the 200 opps so remaining opp products should have the initial first year value
        tempLineItemsList=[Select ID, First_Year_Value__c from OpportunityLineItem where ID in:lineItemsList and First_Year_Value__c=500];
        system.assertEquals(50,tempLineItemsList.size());
        
        //The First Year value of product attached to 200 opps should be calculated on the basis of schedule
        firstYearAmt = (12-Date.today().month()+1)*1000;
        System.debug('Test Code - firstYearAmt '+firstYearAmt);
        tempLineItemsList=[Select ID, First_Year_Value__c from OpportunityLineItem where ID in:lineItemsList and First_Year_Value__c=:firstYearAmt];
        system.assertEquals(200,tempLineItemsList.size());
    }
    */
}