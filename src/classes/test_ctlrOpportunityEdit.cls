@isTest
private class test_ctlrOpportunityEdit {
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

        OpportunityEditSettings__c oppSettings = new OpportunityEditSettings__c();
        oppSettings.Add_Service_Dialog_Height__c = 500;
        oppSettings.Add_Service_Dialog_Width__c = 400;
        oppSettings.Tabbed_Services_Height__c = 200;
        oppSettings.Default_Oppty_Record_Type_Name__c = 'Oppty Record';
        insert oppSettings;
    }
    static testMethod void myUnitTest2() {
        System.debug('creating test admin user...');
        
        User adminUser = util_sampleDataGenerator.createAdminUser();
        //adminUser.Reporting_Country__c = 'Australia';
        adminUser.Reporting_Country__c = 'United States';
        update(adminUser);
        Test.startTest();

        String rtId = util_SampleDataGenerator.getOpportunityRecordType_USOpptyRecord().Id;
        OpportunityLineItem oli;

        System.runAs(adminUser) {
            System.debug('Amrita Working...');
            Opportunity test1 = new Opportunity();
            test1.name = 'LJ2 TEST OPPTY';
            test1.probability = 25;
            test1.stagename = 'Qualify Opportunity';
            test1.ownerid = adminUser.Id;
            test1.pricebook2id = util_SampleDataGenerator.getStandardPricebookId();
            Account account1 = util_SampleDataGenerator.createAccount_Client();
            test1.Account = account1;
            test1.accountid = [select id from Account limit 1].id;
            test1.recordTypeId = rtId;
            test1.closedate = Date.today().addDays(120);
            //insert test1;
            

             
            ApexPages.StandardController sc1 = new ApexPages.StandardController(test1);
            ctlr_OpportunityEdit ce1 = new ctlr_OpportunityEdit(sc1);
            PageReference pe2 = ce1.onPageLoad();
           
     

        }
 Test.stopTest();

    } 

    static testMethod void myUnitTest() {
        
        // delete existing opportunity edit sections
        System.debug('deleting existing opportunity edit sections...');
        delete [select id from Opportunity_Edit_Section__c];
        System.debug('sections deleted.');
        
        // delete existing practices
        System.debug('deleting existing practices...');
        delete [select id from Product_Practice__c];
        System.debug('practices deleted.');
        
        // delete existing field lists
        //System.debug('deleting existing field lists for edit UI...');
        //delete [select id from Product_Field_List__c where RecordType.Name = 'Edit UI Field'];
        //System.debug('field lists deleted.');
        
        // create an admin 
        System.debug('creating test admin user...');
        User adminUser = util_sampleDataGenerator.createAdminUser();

        //---- CPL Start ------
        adminUser.Reporting_Country__c = 'United States';
        update(adminUser);
        //---- CPL Stop ------

         
                
        System.assertNotEquals(null, adminUser.Id);
        System.debug('created user: ' + adminUser);
        
        // create a custom setting for the application
        System.debug('creating application settings...');
        OpportunityEditSettings__c appSettings = new OpportunityEditSettings__c();
        appSettings.Add_Service_Dialog_Height__c = 220;
        appSettings.Add_Service_Dialog_Width__c = 550;
        appSettings.Tabbed_Services_Height__c = 400;
        appSettings.SetupOwnerId = adminUser.Id;
        appSettings.Default_Oppty_Record_Type_Name__c = 'Oppty Record';
        insert appSettings;
        System.assertNotEquals(null, appSettings.Id);
        System.debug('created app settings: ' + appSettings);
        
        // create a section and field configuration for the app
        System.debug('creating opportunity edit section and field configuration...');
        Opportunity_Edit_Section__c sectionSetup = util_sampleDataGenerator.createOpptyEditSection(new String[]{'Name','Probability','StageName','OwnerId','AccountId','CloseDate'});
        System.assertNotEquals(null, sectionSetup.Id);
        System.assertEquals(6, sectionSetup.Opportunity_Edit_Fields__r.size());
        System.debug('configuration complete: ' + sectionSetup);
        
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
        update account; 
        System.assertNotEquals(null, account.Id);
        System.debug('created account: ' + account);
        
        // start the test context
        System.debug('starting the test context...');
        Test.startTest();
        System.debug('test context started.');
        
        // get the oppty record type
        String rtId = util_SampleDataGenerator.getOpportunityRecordType_USOpptyRecord().Id;
        
        System.runAs(adminUser) {
        
            
            // create a standard controller based off of a new opportunity
            System.debug('creating test controller...');
            Opportunity opp = new Opportunity();
            opp.Pricebook2Id = util_SampleDataGenerator.getStandardPricebookId();
            ApexPages.StandardController sc = new ApexPages.StandardController(opp);
            System.debug('controller created.');
            
            
            
            // create an instance of the controller extenstion
            System.debug('creating test controller extenstion...');
            ctlr_OpportunityEdit ce = new ctlr_OpportunityEdit(sc);
            System.debug('controller extension created.');
            

            // call some additional stuff - NEEDS TO BE REPLACED
            ce.practice = 'LJ TEST PRACTICE';
            ce.getProductsByPractice();
            ce.getHasProductResults();
            
            // populate an oppty with some data
            System.debug('populating the opportunity...');
            ce.opportunity.name = 'LJ TEST OPPTY';
            ce.opportunity.probability = 25;
            ce.opportunity.stagename = 'Qualify Opportunity';
            ce.opportunity.ownerid = adminUser.Id;
            //ce.opportunity.pricebook2id = util_SampleDataGenerator.getStandardPricebook().Id;
            ce.opportunity.pricebook2id = util_SampleDataGenerator.getStandardPricebookId();

            //ce.opportunity.accountid = account.Id; // Amrita CPL
            ce.opportunity.accountid =  [select id from Account where  SDO_Billing_Country_Name__c = 'United States' limit 1].id;
            
            ce.opportunity.recordTypeId = rtId;
            ce.opportunity.closedate = Date.today().addDays(60);
            System.debug('populated opportunity: ' + ce.opportunity);
            
            //---- CPL Start ------
            ce.opportunity.Competitor__c ='ABN AMRO; Accenture';
            ce.LoadCompetitorList();
            List<SelectOption> test = ce.getchosenList();
            List<SelectOption> test2 = ce.getavailableList();
            List<SelectOption> temp3 = ce.sort(null); 
            List<String> lstStr = ce.sortList(null);
            String str = ce.combineOptions(null);
            
            Pagereference pe = ce.getProbabilityDefault();
            //---- CPL Stop ------

            
            // set the json string
            System.debug('contructing sample JSON string...');
            ce.jsonString = '{"Opportunity": {"StageName": "Qualify Opportunity", "Probability": "25", "OwnerId": "' + adminUser.Id + 
                '", "Pricebook2Id": "' + ce.opportunity.pricebook2id + '", "Name": "LJ TEST OPPTY", "AccountId": ' + account.Id + ', "CloseDate": "1/24/2015"' + 
                ', "Products": [ {"Product": {"OpportunityRecordTypeId": "' + ce.opportunity.recordTypeID + '", "OpportunityStageName": "' + ce.opportunity.stagename + 'Qualify Opportunity", "Pricebook2Id": "' +  
                ce.opportunity.pricebook2id + '", "PricebookEntryId": "' + pbe.Id + '", "Product2Id": "' + product.Id + '", "Fields": {"Type__c": "New Practice Sale - B", "First_Year_Value__c": "234234", "Service_Start_Date__c": "3/17/2015", "UnitPrice": "243", "Service_End_Date__c": "4/1/2016", "Implementation_up_Front_Fees__c": "234234", "Implementation_Amortized_Fees__c": "234243", "Recurring_Non_Recurring__c": "Non-Recurring", "Total_Annual_Fee_Per_Participant_Unit__c": "23434", "Fee_Commission__c": "Fee", "Eligible_Participants_Units__c": "0", "Global_Sale__c": "1", "Billing_Manager__c": "003Q000000JMZkj", "Project_Manager__c": "003Q000000JMgg3"}}} ]}}';
           

            System.debug('constructed JSON: ' + ce.jsonString);
            
            Integer num = ce.convertJSONValueIntoInteger(ce.opportunity.pricebook2id);
            Integer num1 = ce.convertJSONValueIntoInteger(ce.opportunity.Competitor__c);
            Integer num2 = ce.convertJSONValueIntoInteger(ce.opportunity.name );
                   
                            
            System.debug('saving the oppty data...');
            
            //Amrita Start-------------
            insert ce.opportunity;
            //OpportunityLineItem oli = util_sampleDataGenerator.createOpportunityProduct(ce.opportunity.id, pbe.id  , 50, 100.00);
            //oli.First_Year_Value__c = 15000;
            //--Amrita Stop
            
            ce.saveAll();

            //---- CPL Start ------
            //-------Code Coverage Case--
            System.debug('Amrita Working...');
            Opportunity test33 = new Opportunity();
            test33.name = 'LJ1 TEST OPPTY';
            test33.probability = 25;
            test33.stagename = 'Qualify Opportunity';
            test33.ownerid = adminUser.Id;
            test33.pricebook2id = util_SampleDataGenerator.getStandardPricebookId();
            //Account account1 = util_SampleDataGenerator.createAccount_Client();
            //test33.accountid = account1.Id;
            //test33.accountid = [select id from Account limit 1].id;
            test33.accountid = [select id from Account where  SDO_Billing_Country_Name__c = 'United States' limit 1].id;

            test33.recordTypeId = rtId;
            test33.closedate = Date.today().addDays(60);
            insert test33;
            
            //ApexPages.StandardController sc1 = new ApexPages.StandardController(test33);
            ctlr_OpportunityEdit ce1 = new ctlr_OpportunityEdit(sc);
            PageReference pe2 = ce1.onPageLoad();
         
           
            //---- CPL Stop ------
            
            
        }
            
        // stop the test context
        System.debug('stopping the test context...');
        Test.stopTest();
        System.debug('test context stopped.');
    }
    
    static testMethod void myUnitTest3() {
        System.debug('creating test admin user...');
        
        User adminUser = util_sampleDataGenerator.createAdminUser();
        adminUser.Reporting_Country__c = 'Canada';
        update(adminUser);
Test.startTest();

        String rtId = util_SampleDataGenerator.getOpportunityRecordType_USOpptyRecord().Id;
        OpportunityLineItem oli;

        System.runAs(adminUser) {
            System.debug('Amrita Working...');
            Opportunity test1 = new Opportunity();
            test1.name = 'LJ2 TEST OPPTY';
            test1.probability = 25;
            test1.stagename = 'Qualify Opportunity';
            test1.ownerid = adminUser.Id;
            test1.pricebook2id = util_SampleDataGenerator.getStandardPricebookId();
            Account account1 = util_SampleDataGenerator.createAccount_Client();
            test1.Account = account1;
            test1.accountid =  [select id from Account where  SDO_Billing_Country_Name__c = 'United States' limit 1].id;
            test1.recordTypeId = rtId;
            test1.closedate = Date.today().addDays(120);
            //insert test1;
            

             
            ApexPages.StandardController sc1 = new ApexPages.StandardController(test1);
            ctlr_OpportunityEdit ce1 = new ctlr_OpportunityEdit(sc1);
            PageReference pe2 = ce1.onPageLoad();
           pe2.getParameters().put('RecordType', rtId );
     
             ce1.chosenList = null;
            List<SelectOption> test = ce1.getchosenList();

        }
 Test.stopTest();

    } 
    
    
     static testMethod void myUnitTest4() {
        System.debug('creating test admin user...');
        
        User adminUser = util_sampleDataGenerator.createAdminUser();
        adminUser.Reporting_Country__c = 'Canada';
        update(adminUser);
        Test.startTest();

        String rtId = util_SampleDataGenerator.getOpportunityRecordType_USOpptyRecord().Id;
        OpportunityLineItem oli;

        System.runAs(adminUser) {
            System.debug('Amrita Working...');
            Opportunity test1 = new Opportunity();
            test1.name = 'LJ2 TEST OPPTY';
            test1.probability = 25;
            test1.stagename = 'Qualify Opportunity';
            test1.ownerid = adminUser.Id;
            test1.pricebook2id = util_SampleDataGenerator.getStandardPricebookId();
            Account account1 = util_SampleDataGenerator.createAccount_Client();
            test1.Account = account1;
            test1.accountid =  [select id from Account where  SDO_Billing_Country_Name__c = 'United States' limit 1].id;
            test1.recordTypeId = rtId;
            test1.closedate = Date.today().addDays(120);
            //insert test1;
            

             
            ApexPages.StandardController sc1 = new ApexPages.StandardController(test1);
            ctlr_OpportunityEdit ce1 = new ctlr_OpportunityEdit(sc1);
            PageReference pe2 = ce1.onPageLoad();
           pe2.getParameters().put('RecordType', rtId );
     

        }
         Test.stopTest();

    } 

}