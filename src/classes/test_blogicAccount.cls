@isTest
private class test_blogicAccount {
    @testSetup static void setupCapstData() {
        final Integer LOW_RANGE_LAST_ID = 99000;
        final Integer LOW_RANGE_UPPER_LIMIT = 99500;
        final Integer HIGH_RANGE_UPPER_LIMIT = 99600;
        /*
            Insert the Organizational_Defaults__c
        */
        Organizational_Defaults__c orgDefaultSettings = new Organizational_Defaults__c();
        orgDefaultSettings.Enable_CAPIS_Id_Assignment__c = true;
        insert orgDefaultSettings;

        /*
            Insert thee CAPIS record
        */
        Last_CAPIS_Id__c lastCapisIdInfo =  new Last_CAPIS_Id__c();
        lastCapisIdInfo.Name = 'Capis_Id';
        lastCapisIdInfo.Low_Range_Last_Id__c = LOW_RANGE_LAST_ID;
        lastCapisIdInfo.Low_Range_Upper_Limit__c = LOW_RANGE_UPPER_LIMIT;
        lastCapisIdInfo.High_Range_Last_Id__c = HIGH_RANGE_UPPER_LIMIT;
        insert lastCapisIdInfo;

        Territory__c il = new Territory__c(Public_Group_Id__c=UserInfo.getUserId(), Name='IL', Country__c='United States');
        Territory__c ny = new Territory__c(Public_Group_Id__c=UserInfo.getUserId(), Name='NY', Country__c='United States');
        Territory__c ca = new Territory__c(Public_Group_Id__c=UserInfo.getUserId(), Name='CA', Country__c='Canada', Areas_included_in_Territory__c='CA;ON');

        Territory__c can = new Territory__c(Public_Group_Id__c=UserInfo.getUserId(), Name='CA', Country__c='United States', Areas_included_in_Territory__c='');
        Territory__c qc = new Territory__c(Public_Group_Id__c=UserInfo.getUserId(), Name='QC', Country__c='Canada', Areas_included_in_Territory__c='QC;c');
        Territory__c sk = new Territory__c(Public_Group_Id__c=UserInfo.getUserId(), Name='SK', Country__c='Canada', Areas_included_in_Territory__c='SK');
        Territory__c yt = new Territory__c(Public_Group_Id__c=UserInfo.getUserId(), Name='YT', Country__c='Canada', Areas_included_in_Territory__c='YT');
        Territory__c onT = new Territory__c(Public_Group_Id__c=UserInfo.getUserId(), Name='ON', Country__c='Canada', Areas_included_in_Territory__c='ON');
        List<Territory__c> ter = new List<Territory__c>();
        ter.add(il);
        ter.add(can);
        ter.add(ny);
        ter.add(qc);
        ter.add(sk);
        ter.add(yt);
        ter.add(onT);
        insert ter;

        SIC_Code_to_Industry_Mapping__c sic = new SIC_Code_to_Industry_Mapping__c();
        sic.Name = '9932';
        sic.Aon_Global_Industry_Level_4__c = 'Museums, Art Galleries, And Botanical And Zoological Gardens Other';
        sic.Aon_Global_Industry_Level_2__c = 'Museums, Art Galleries, And Botanical And Zoological Gardens';
        sic.Industry__c = 'Entertainment and Leisure';
        insert sic;

        SIC_Code_to_Industry_Mapping__c sic1 = new SIC_Code_to_Industry_Mapping__c();
        sic1.Name = '9933';
        sic1.Aon_Global_Industry_Level_4__c = 'Motor Freight Transportation And Warehousing Other';
        sic1.Aon_Global_Industry_Level_2__c = 'Motor Freight Transportation And Warehousing';
        sic1.Industry__c = 'Transportation and Logistics';
        insert sic1;

        Contact con = new Contact();
        con.Corresponding_User_Id__c = UserInfo.getUserId();
        con.FirstName = 'Test';
        con.LastName = 'User';
        insert con;
        System.assertNotEquals(null, con.Id, 'It should have a an ID saved');

        Single_Entry_Roles__c singleRole = new Single_Entry_Roles__c();
        singleRole.Name = 'Test';
        insert singleRole;

        List<Zip_Code_to_Market_Mapping__c> zips = new List<Zip_Code_to_Market_Mapping__c>();
        zips.add(new Zip_Code_to_Market_Mapping__c(Market__c='Chicago', Name='600', City__c='Chicago', State__c='IL', Country__c='United States', Global_Region__c='North America', Market_Lead__c=UserInfo.getUserId(), CCO__c=UserInfo.getUserId(), Market_Lead_Email__c='Aon@test.com', Region__c='Midwest', Region_Director__c=UserInfo.getUserId(), Sales_Analyst__c=UserInfo.getUserId()));
        zips.add(new Zip_Code_to_Market_Mapping__c(Market__c='New Random', Name='988', City__c='Random City', State__c='CA', Country__c='United States', Global_Region__c='North America', Market_Lead__c=UserInfo.getUserId(), CCO__c=UserInfo.getUserId(), Market_Lead_Email__c='Aon@test.com', Region__c='Midwest', Region_Director__c=UserInfo.getUserId(), Sales_Analyst__c=UserInfo.getUserId()));
        zips.add(new Zip_Code_to_Market_Mapping__c(Market__c='London', Name='UK', City__c='London', State__c='ON', Country__c='United Kingdom', Global_Region__c='Europe', Market_Lead__c=UserInfo.getUserId(), CCO__c=UserInfo.getUserId(), Market_Lead_Email__c='Aon@test.com', Region__c='Midwest', Region_Director__c=UserInfo.getUserId(), Sales_Analyst__c=UserInfo.getUserId()));
        zips.add(new Zip_Code_to_Market_Mapping__c(Market__c='London', Name='ON', City__c='London', State__c='ON', Country__c='Canada', Global_Region__c='Europe', Market_Lead__c=UserInfo.getUserId(), CCO__c=UserInfo.getUserId(), Market_Lead_Email__c='Aon@test.com', Region__c='Midwest', Region_Director__c=UserInfo.getUserId(), Sales_Analyst__c=UserInfo.getUserId()));
        zips.add(new Zip_Code_to_Market_Mapping__c(Market__c='London', Name='111', City__c='NYC', State__c='NY', Country__c='United States', Global_Region__c='North America', Market_Lead__c=UserInfo.getUserId(), CCO__c=UserInfo.getUserId(), Market_Lead_Email__c='Aon@test.com', Region__c='Midwest', Region_Director__c=UserInfo.getUserId(), Sales_Analyst__c=UserInfo.getUserId()));
        insert zips;
    }
    /** Validate capis Id generation for single record insertion for low capis */
    static testMethod void TestCapisIdCreation_SingleRecordCreate_LowCAPIS() {
        
        // declare local vars
        Account account = null;
        
        Test.startTest();
        
        // create an account
        account = util_SampleDataGenerator.createPeopleSoftClient('TEST ACCOUNT', util_SampleDataGenerator.getRecordType('Account', 'Client Account Record Type').Id, false);
        account.Additional_CAPIS_Indicator__c = 'Yes';
        account.ACW_Client_Type__c = 'Client';
        account.Account_Status__c = 'Active';
        account.Global_Region__c = 'North America';
        account.Region_Market_Override__c = true;
        insert account;
        System.assertNotEquals(null, account.Id); 
        
        Test.stopTest();
        
        // assert the result        
        account = [select id, CAPIS_ID__c from Account where Id = :account.Id];
        System.assertEquals('99001', account.CAPIS_ID__c);  
    } //TestCapisIdCreation_SingleRecordCreate_LowCAPIS
    
    
    /** Validate capis Id generation for single record insertion for High capis */
    static testMethod void TestCapisIdCreation_SingleRecordCreate_HighCAPIS() {
    
        // declare local vars
        Account account = null;
        
        Test.startTest();
            // create an account
        Account testAccount = util_SampleDataGenerator.createPeopleSoftClient('TEST ACCOUNT', util_SampleDataGenerator.getRecordType('Account', 'Client Account Record Type').Id, false);
        testAccount.Additional_CAPIS_Indicator__c = 'No';
        testAccount.ACW_Client_Type__c = 'Client';
        testAccount.Account_Status__c = 'Active';
        testAccount.Global_Region__c = 'North America';
        testAccount.Region_Market_Override__c = true;
        insert testAccount;
        System.assertNotEquals(null, testAccount.Id); 
        
        Test.stopTest();
        
        // assert the result        
        account = [select id, CAPIS_ID__c from Account where Id = :testAccount.Id];
        System.assertEquals('99601', account.CAPIS_ID__c);  
    } //TestCapisIdCreation_SingleRecordCreate_HighCAPIS
    
    
    /** Validate capis Id generation for single record insertion with capis id collision */
    static testMethod void TestCapisIdCreationWithCollision_SingleRecordCreate_LowCAPIS() {
        
        // create collision 
        Account account = util_SampleDataGenerator.createPeopleSoftClient('TEST ACCOUNT', util_SampleDataGenerator.getRecordType('Account', 'Client Account Record Type').Id, false);
        account.CAPIS_ID__c = '99001';
        insert account;
        System.assertNotEquals(null, account.Id);

        Test.startTest();
            // create an account
            account = util_SampleDataGenerator.createPeopleSoftClient('TEST ACCOUNT2', util_SampleDataGenerator.getRecordType('Account', 'Client Account Record Type').Id, false);
            account.Additional_CAPIS_Indicator__c = 'Yes';
            account.ACW_Client_Type__c = 'Client';
            account.Account_Status__c = 'Active';
            account.Global_Region__c = 'North America';
            account.Region_Market_Override__c = true;
            insert account;
            System.assertNotEquals(null, account.Id); 
        
        Test.stopTest();
        
        // assert the result        
        account = [select id, CAPIS_ID__c from Account where Id = :account.Id];
        System.assertEquals('99002', account.CAPIS_ID__c);  
    } //TestCapisIdCreationWithCollision_SingleRecordCreate_LowCAPIS
    
    
    /** Validate capis Id generation for single record insertion with capis id collision */
    static testMethod void TestCapisIdCreationWithCollision_SingleRecordCreate_HighCAPIS() {
        
        // create collision 
        Account account = util_SampleDataGenerator.createPeopleSoftClient('TEST ACCOUNT2', util_SampleDataGenerator.getRecordType('Account', 'Client Account Record Type').Id, false);
        account.CAPIS_ID__c = '99601';
        insert account;
        System.assertNotEquals(null, account.Id);
        System.assertEquals('99601', [SELECT CAPIS_ID__c FROM Account WHERE Id = :account.Id].CAPIS_ID__c, 'It should have 99601 as CAPIS Id');
        
        Test.startTest();
            Account testAccount = util_SampleDataGenerator.createPeopleSoftClient('TEST ACCOUNT', util_SampleDataGenerator.getRecordType('Account', 'Client Account Record Type').Id, false);
            testAccount.Additional_CAPIS_Indicator__c = 'Yes';
            testAccount.BillingState = 'IL';
            testAccount.SDO_Billing_Country_Name__c = 'United States';
            testAccount.ACW_Client_Type__c = 'Client';
            testAccount.Account_Status__c = 'Active';
            testAccount.Global_Region__c = 'North America';
            testAccount.Region_Market_Override__c = true;
            insert testAccount;
            System.assertNotEquals(null, testAccount.Id); 
        
        Test.stopTest();
        
        // assert the result        
        account = [select id, CAPIS_ID__c from Account where Id = :testAccount.Id];
        System.assertEquals('99001', account.CAPIS_ID__c);  
    } //TestCapisIdCreationWithCollision_SingleRecordCreate_HighCAPIS
    
    
    /** Validate capis Id generation for single record update */
    static testMethod void TestCapisIdCreation_SingleRecordUpdate_LowCAPIS() {
        // declare local vars
        Account account;
        
        Test.startTest();
        
            // create an account
            account = util_SampleDataGenerator.createAccount_Client();
            System.assertNotEquals(null, account.Id);
            
            // verify no capis
            account = [select id, CAPIS_ID__c, ACW_Client_Type__c, Legacy_Hewitt_Financial_System__c from Account where Id = :account.Id];
            System.assertEquals(null, account.CAPIS_ID__c); 
            
            // update to require capis
            account.Legacy_Hewitt_Financial_System__c = 'Peoplesoft';
            account.ACW_Client_Type__c = 'Client';
            account.Additional_CAPIS_Indicator__c = 'Yes';
            account.ACW_Client_Type__c = 'Client';
            account.Account_Status__c = 'Active';
            account.Global_Region__c = 'North America';
            account.Region_Market_Override__c = true;
            
            update account;
        
        Test.stopTest();
        
        // assert the result        
        account = [select id, CAPIS_ID__c from Account where Id = :account.Id];
        System.assertEquals('99001', account.CAPIS_ID__c); 
    } //TestCapisIdCreation_SingleRecordUpdate_LowCAPIS
    
    
    /** Validate capis Id generation for single record update */
    static testMethod void TestCapisIdCreation_SingleRecordUpdate_HighCAPIS() {
        
        // declare local vars
        Account account; 
        
        Test.startTest();
        
            // create an account
            account = util_SampleDataGenerator.createAccount_Client();
            System.assertNotEquals(null, account.Id);
            
            // verify no capis
            account = [select id, CAPIS_ID__c, ACW_Client_Type__c, Legacy_Hewitt_Financial_System__c from Account where Id = :account.Id];
            System.assertEquals(null, account.CAPIS_ID__c); 
            
            // update to require capis
            account.Legacy_Hewitt_Financial_System__c = 'Peoplesoft';
            account.ACW_Client_Type__c = 'Client';
            account.Additional_CAPIS_Indicator__c = 'No';
            
            update account;
        
        Test.stopTest();
        
        // assert the result        
        account = [select id, CAPIS_ID__c from Account where Id = :account.Id];
        System.assertEquals('99601', account.CAPIS_ID__c); 
    } //TestCapisIdCreation_SingleRecordUpdate_HighCAPIS
    
    
    /** Validate capis Id generation for bulk record insertion */
    static testMethod void TestCapisIdCreation_BulkRecordCreate() {
        // declare local vars
        Set <String> accountIds = new Set<String>();
        

        Test.startTest();
            
            // create 100 accounts
            List <Account> accounts = util_SampleDataGenerator.createPeopleSoftClients('TEST', 100, false);
            for (Account account : accounts) {
                account.Additional_CAPIS_Indicator__c = 'Yes';
                account.ACW_Client_Type__c = 'Client';
                account.Account_Status__c = 'Active';
                account.Global_Region__c = 'North America';
                account.Region_Market_Override__c = true;
            }
            insert accounts;
        
        Test.stopTest();

        // collect the distinct set of ids created
        for (Account account : accounts) {
            accountIds.add(account.Id);
        }
        System.assertEquals(100, accountIds.size());
        
        // retrieve the results of the insert
        accounts = [select id, CAPIS_ID__c from Account where Id IN :accountIds order by CAPIS_As_Number__c asc];
        
        for (Integer x = 0; x < accounts.size(); x++) {
            System.assertEquals(String.valueOf(99001 + x), accounts[x].CAPIS_ID__c);
        }
        
        Last_CAPIS_Id__c lastCapisIdInfo = [SELECT Id, Name, Low_Range_Last_Id__c from Last_CAPIS_Id__c limit 1];
        System.assertEquals(99100, lastCapisIdInfo.Low_Range_Last_Id__c);
    } //TestCapisIdCreation_BulkRecordCreate
    
    
    /** Validate capis Id generation for bulk record insertion */
    static testMethod void TestCapisIdCreation_BulkRecordCreate_MixCAPIS() {
        
        // declare local vars
        Set <String> accountIds = new Set<String>();

        Test.startTest();
            
            // create 100 accounts
            List <Account> accounts = util_SampleDataGenerator.createPeopleSoftClients('TEST', 100, false);
            for (Integer x = 0; x < accounts.size(); x++) {
                if (x < 50) {
                    accounts[x].Additional_CAPIS_Indicator__c = 'Yes';
                    accounts[x].ACW_Client_Type__c = 'Client';
                    accounts[x].Account_Status__c = 'Active';
                    accounts[x].Global_Region__c = 'North America';
                    accounts[x].Region_Market_Override__c = true;
                } else {
                    accounts[x].Additional_CAPIS_Indicator__c = 'No';
                    accounts[x].ACW_Client_Type__c = 'Client';
                    accounts[x].Account_Status__c = 'Active';
                    accounts[x].Global_Region__c = 'North America';
                    accounts[x].Region_Market_Override__c = true;   
                }
            }
            insert accounts;
        
        Test.stopTest();

        // collect the distinct set of ids created
        for (Account account : accounts) {
            accountIds.add(account.Id);
        }
        System.assertEquals(100, accountIds.size());
        
        // retrieve the results of the insert
        accounts = [select id, CAPIS_ID__c from Account where Id IN :accountIds order by CAPIS_As_Number__c asc];
        
        for (Integer x = 0; x < accounts.size(); x++) {
            if (x < 50) {
                System.assertEquals(String.valueOf(99001 + x), accounts[x].CAPIS_ID__c);
            } else {
                System.assertEquals(String.valueOf(99601 + (x - 50)), accounts[x].CAPIS_ID__c);
            }
        }
        
        Last_CAPIS_Id__c lastCapisIdInfo = [SELECT Id, Name, Low_Range_Last_Id__c, High_Range_Last_Id__c from Last_CAPIS_Id__c limit 1];
        System.assertEquals(99050, lastCapisIdInfo.Low_Range_Last_Id__c);
        System.assertEquals(99650, lastCapisIdInfo.High_Range_Last_Id__c);
    } //TestCapisIdCreation_BulkRecordCreate_MixCAPIS
    
    
    /** Enable CAPIS assignment by modifying custom setting */
    private static void enableCAPISIdAssignment() {
        Organizational_Defaults__c orgSettings = Organizational_Defaults__c.getInstance();
        System.debug('CHINTAN orgSettings is: ' + orgSettings);
        orgSettings.Enable_CAPIS_Id_Assignment__c = true;
        upsert orgSettings;
    } //enableCAPISIdAssignment
    
    
    /** Validate capis Id generation does not occur for records in regions other than US */
    static testMethod void TestCapisIdNonCreation() {
        //enable capis id assignment
        enableCAPISIdAssignment();
        
        //declare local vars
        Account account = null;
        
        Test.startTest();
        
        //create an account outside US
        account = util_SampleDataGenerator.createPeopleSoftClient('TEST ACCOUNT', util_SampleDataGenerator.getRecordType('Account', 'Client Account Record Type').Id, false);
        account.Additional_CAPIS_Indicator__c = 'Yes';
        account.SDO_Billing_Country_Name__c = 'United Kingdom';
        account.Global_Region__c = 'UKI';
        insert account;
        System.assertNotEquals(null, account.Id); 
        
        Test.stopTest();
        
        //assert the result     
        account = [select id, CAPIS_ID__c from Account where Id = :account.Id];
        System.assertEquals(null, account.CAPIS_ID__c); 
    } //TestCapisIdNonCreation
    
    
    /** Tests the Automatic assignment of Global Region, Region and Market */
    static testmethod void testRegionMarketMappings() {
        Test.startTest();
        
        //create data
        Account myAccount = new Account();
        myAccount.RecordTypeId = util_sampleDataGenerator.getRecordType('Account', 'Client Account Record Type').Id;
        myAccount.Name = 'CHINTAN Test Account';
        myAccount.SDO_Billing_Country_Name__c = 'United States';
        myAccount.BillingCity = 'Chicago';
        myAccount.BillingState = 'IL';
        myAccount.BillingPostalCode = '60051';
        insert myAccount;
        
        //Get matching ZipToMarket record
        Zip_Code_to_Market_Mapping__c[] mapping = [Select Global_Region__c, Region__c, Market__c, Market_Lead_Email__c, Region_Director_Email__c From Zip_Code_to_Market_Mapping__c WHERE Name = '600'];
        
        //validate US settings
        myAccount = [Select Id, Global_Region__c, Region__c, Market__c, Market_Lead_Email__c, Region_Director_Email__c from Account where Id = :myAccount.Id ];
        System.debug('CHINTAN US Settings: ' + myAccount);
        System.assertEquals(myAccount.Global_Region__c, mapping[0].Global_Region__c);
        System.assertEquals(myAccount.Region__c, mapping[0].Region__c);
        System.assertEquals(myAccount.Market__c, mapping[0].Market__c);
        System.assertEquals(myAccount.Market_Lead_Email__c, mapping[0].Market_Lead_Email__c);
        System.assertEquals(myAccount.Region_Director_Email__c, mapping[0].Region_Director_Email__c);
        
        //update account
        myAccount.SDO_Billing_Country_Name__c = 'United States';
        myAccount.BillingPostalCode = '98810';
        update myAccount;
        
        //Get matching ZipToMarket record
        mapping = [Select Global_Region__c, Region__c, Market__c, Market_Lead_Email__c, Region_Director_Email__c From Zip_Code_to_Market_Mapping__c WHERE Name = '988'];
        
        //validate US settings
        myAccount = [Select Id, Global_Region__c, Region__c, Market__c, Market_Lead_Email__c, Region_Director_Email__c from Account where Id = :myAccount.Id ];
        System.debug('CHINTAN US Settings: ' + myAccount);
        System.assertEquals(myAccount.Global_Region__c, mapping[0].Global_Region__c);
        System.assertEquals(myAccount.Region__c, mapping[0].Region__c);
        System.assertEquals(myAccount.Market__c, mapping[0].Market__c);
        System.assertEquals(myAccount.Market_Lead_Email__c, mapping[0].Market_Lead_Email__c);
        System.assertEquals(myAccount.Region_Director_Email__c, mapping[0].Region_Director_Email__c);
        
        //update account
        myAccount.SDO_Billing_Country_Name__c = 'United Kingdom';
        update myAccount;
        
        //Get matching ZipToMarket record
        mapping = [Select Global_Region__c, Region__c, Market__c, Market_Lead_Email__c, Region_Director_Email__c From Zip_Code_to_Market_Mapping__c WHERE Country__c = 'United Kingdom'];
        
        //validate UK settings
        myAccount = [Select Id, Global_Region__c, Region__c, Market__c, Market_Lead_Email__c, Region_Director_Email__c from Account where Id = :myAccount.Id ];
        System.debug('CHINTAN UK Settings: ' + myAccount);
        System.assertEquals(myAccount.Global_Region__c, mapping[0].Global_Region__c);
        System.assertEquals(myAccount.Region__c, mapping[0].Region__c);
        System.assertEquals(myAccount.Market__c, mapping[0].Market__c);
        System.assertEquals(myAccount.Market_Lead_Email__c, mapping[0].Market_Lead_Email__c);
        System.assertEquals(myAccount.Region_Director_Email__c, mapping[0].Region_Director_Email__c);
        
        //update account
        myAccount.SDO_Billing_Country_Name__c = 'Angola';
        update myAccount;
        
        //validate no change
        myAccount = [Select Id, BillingState, Global_Region__c, Region__c, Market__c, Market_Lead_Email__c, Region_Director_Email__c from Account where Id = :myAccount.Id ];
        System.debug('CHINTAN No Change Settings for Angola: ' + myAccount);
        System.assertEquals(myAccount.Global_Region__c, mapping[0].Global_Region__c);
        
        //update account
        myAccount.SDO_Billing_Country_Name__c = 'Canada';
        myAccount.BillingState = 'ON';
        update myAccount;
        
        //Get matching ZipToMarket record
        mapping = [Select Global_Region__c, Region__c, Market__c, Market_Lead_Email__c, Region_Director_Email__c From Zip_Code_to_Market_Mapping__c WHERE Country__c = 'Canada' and State__c = 'ON'];
        
        //validate non-Ottawa Canada settings
        myAccount = [Select Id, BillingState, BillingCity, Global_Region__c, Region__c, Market__c, Market_Lead_Email__c, Region_Director_Email__c from Account where Id = :myAccount.Id ];
        System.assertEquals(myAccount.Global_Region__c, mapping[0].Global_Region__c);
        System.assertEquals(myAccount.Region__c, mapping[0].Region__c);
        System.assertEquals(myAccount.Market__c, mapping[0].Market__c);
        System.assertEquals(myAccount.Market_Lead_Email__c, mapping[0].Market_Lead_Email__c);
        System.assertEquals(myAccount.Region_Director_Email__c, mapping[0].Region_Director_Email__c);
        
        //update account
        myAccount.BillingCity = 'Ottawa';
        update myAccount;
        
        //validate Ottawa Canada settings
        myAccount = [Select Id, BillingState, Global_Region__c, Region__c, Market__c, Market_Lead_Email__c, Region_Director_Email__c from Account where Id = :myAccount.Id ];
        System.debug('CHINTAN Ottawa Settings: ' + myAccount);
        System.assertEquals(myAccount.Global_Region__c, mapping[0].Global_Region__c);
        System.assertEquals(myAccount.Region__c, 'CA - East');
        System.assertEquals(myAccount.Market__c, mapping[0].Market__c);
        System.assertEquals(myAccount.Market_Lead_Email__c, mapping[0].Market_Lead_Email__c);
        System.assertEquals(myAccount.Region_Director_Email__c, mapping[0].Region_Director_Email__c);
        
        Test.stopTest();        
    } //testRegionMarketMappings
    
    
    /** Tests the Automatic assignment of Global Region, Region and Market */
    static testmethod void testRegionMarketMappings_bulk() {
        // declare local vars
        Set <String> accountIds = new Set<String>();
        integer count = 20;
        
        Test.startTest();
        
        // create 'count' accounts
        List <Account> accounts = util_SampleDataGenerator.createPeopleSoftClients('TEST', count, false);
        for (Integer x = 0; x < accounts.size(); x++) {
            accounts[x].Additional_CAPIS_Indicator__c = 'No';
            accounts[x].SDO_Billing_Country_Name__c = 'Canada';
            accounts[x].BillingCity = 'Toronto';
            accounts[x].BillingState = 'ON';    
        }
        insert accounts;
        
        // collect the distinct set of ids created
        for (Account account : accounts) {
            accountIds.add(account.Id);
        }
        System.assertEquals(count, accountIds.size());
        
        // retrieve the results of the insert
        accounts = [Select Id, BillingState, BillingCity, Global_Region__c, Region__c, Market__c, Market_Lead_Email__c, Region_Director_Email__c from Account where Id IN :accountIds];
        System.assertEquals(count, accounts.size());
        
        //Get matching ZipToMarket record
        Zip_Code_to_Market_Mapping__c[] mapping = [Select Global_Region__c, Region__c, Market__c, Market_Lead_Email__c, Region_Director_Email__c From Zip_Code_to_Market_Mapping__c WHERE Country__c = 'Canada' and State__c = 'ON'];
        System.debug('CPA zipToMarket mapping read in test class: ' + mapping);
        
        //Assert
        for (Integer x = 0; x < accounts.size(); x++) {
            System.debug('CPA Account Read: ' + accounts[x]);
            System.assertEquals(accounts[x].Global_Region__c, mapping[0].Global_Region__c);
            System.assertEquals(accounts[x].Region__c, mapping[0].Region__c);
            System.assertEquals(accounts[x].Market__c, mapping[0].Market__c);
            System.assertEquals(accounts[x].Market_Lead_Email__c, mapping[0].Market_Lead_Email__c);
            System.assertEquals(accounts[x].Region_Director_Email__c, mapping[0].Region_Director_Email__c);
        }
        
        //update accounts
        for (Account myAccount : accounts) {
            myAccount.SDO_Billing_Country_Name__c = 'United States';
            myAccount.BillingState = 'WA';
            myAccount.BillingPostalCode = '98810';
        }
        update accounts;
        
        Test.stopTest();
        
        //Get matching ZipToMarket record
        mapping = [Select Global_Region__c, Region__c, Market__c, Market_Lead_Email__c, Region_Director_Email__c From Zip_Code_to_Market_Mapping__c WHERE Name = '988'];
        
        // retrieve the results of the update
        accounts = [Select Id, BillingState, BillingCity, Global_Region__c, Region__c, Market__c, Market_Lead_Email__c, Region_Director_Email__c from Account where Id IN :accountIds];
        System.assertEquals(count, accounts.size());
        
        //validate US settings
        for (Account myAccount : accounts) {
            System.assertEquals(myAccount.Global_Region__c, mapping[0].Global_Region__c);
            System.assertEquals(myAccount.Region__c, mapping[0].Region__c);
            System.assertEquals(myAccount.Market__c, mapping[0].Market__c);
            System.assertEquals(myAccount.Market_Lead_Email__c, mapping[0].Market_Lead_Email__c);
            System.assertEquals(myAccount.Region_Director_Email__c, mapping[0].Region_Director_Email__c);
        }
    } //testRegionMarketMappings_bulk
    
        
    /** Tests that Duplicate Internal Account Team entries are checked on a case sensitive basis - Case 5332 */
    static testmethod void testInternalAccountTeamDuplicateEntry() {
        //create account
        Account myAccount = util_sampleDataGenerator.createAccount_Client();
        
        //create Internal Contact
        List<Contact> myContacts = util_sampleDataGenerator.createInternalContact_bulk(myAccount.Id, 2, true);
        Contact myContact = myContacts[0];
        Contact myContact2 = myContacts[1];
        
        //Read Single Entry Roles
        List<single_Entry_Roles__c> rolesList = [Select Name from Single_Entry_Roles__c];
        System.assertNotEquals(rolesList.size(), 0);
        
        Test.startTest();
        //insert a contact with a single entry role
        Internal_Account_Team__c myIat3 = new Internal_Account_Team__c();
        myIat3.Account__c = myAccount.Id;
        myIat3.Contact__c = myContact.Id;
        myIat3.Contact_Role__c = rolesList[0].Name;
        insert myIat3;
        //Verify record inserted
        System.assertNotEquals(null, myIat3.Id);
        
        //insert another contact in the same role
        Internal_Account_Team__c myIat4 = new Internal_Account_Team__c();
        myIat4.Account__c = myAccount.Id;
        myIat4.Contact__c = myContact2.Id;
        myIat4.Contact_Role__c = rolesList[0].Name;
        try { 
            insert myIat4;
        } catch (DMLException e) {
            for (Integer i = 0; i < e.getNumDml(); i++) {
                System.debug('CHINTAN DML Exception Status: ' + e.getDmlStatusCode(i));
                System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION', e.getDmlStatusCode(i) );
            }
        }
        Test.stopTest();
    } //testInternalAccountTeamDuplicateEntry
    
    
    
    /** Validate that Territory and public group is getting assigned properly */ 
    static testMethod void testUSAccountTerritorySetting() {
        Test.startTest();
        
        //create a US account
        Account myUSaccount = util_sampleDataGenerator.createAccount_Client();
        System.assertNotEquals(myUSaccount.Id, null);
        System.debug('CHINTAN Created Account with Id ' + myUSaccount.Id);
 
        //Verify Territory 
        myUSaccount = [Select id, Territory__c from Account where id = :myUSaccount.Id];
        System.debug('CHINTAN Account Territory is ' + myUSaccount.Territory__c);
        Territory__c ILTerritory = [Select id, Public_Group_Id__c from Territory__c where Name = 'IL' Limit 1];
        System.debug('CHINTAN IL Territory Id is ' + ILTerritory.Id);
        System.assertEquals(myUSaccount.Territory__c, ILTerritory.Id);
        
        //Verify AccountShare record
        System.debug('CHINTAN IL Public Group Id is ' + ILTerritory.Public_Group_Id__c);
        AccountShare myAccountShare = [Select Id from AccountShare Where AccountId = :myUSaccount.Id And UserOrGroupId = :ILTerritory.Public_Group_Id__c];
        System.assertNotEquals(null, myAccountShare.Id);
        
        //Update State
        myUSaccount = [Select id, BillingState from Account where id = :myUSaccount.Id];
        myUSaccount.BillingState = 'CA';
        update myUSaccount;
        
        //Verify Territory
        myUSaccount = [Select id, Territory__c from Account where id = :myUSaccount.Id];
        System.debug('CHINTAN Account Territory is ' + myUSaccount.Territory__c);
        Territory__c CATerritory = [Select id, Public_Group_Id__c from Territory__c where Name = 'CA' Limit 1];
        System.debug('CHINTAN CA Territory Id is ' + CATerritory.Id);
        System.assertEquals(myUSaccount.Territory__c, CATerritory.Id);
        
        //Verify Old AccountShare record deleted
        try { 
            myAccountShare = [Select Id from AccountShare Where AccountId = :myUSaccount.Id And UserOrGroupId = :ILTerritory.Public_Group_Id__c];
        } catch (Exception e) {
            System.debug('CHINTAN Caught Exception');
            System.assertEquals(e.getMessage(), 'List has no rows for assignment to SObject');
        }
        
        //Verify New AccountShare record added
        myAccountShare = [Select Id from AccountShare Where AccountId = :myUSaccount.Id And UserOrGroupId = :CATerritory.Public_Group_Id__c];
        System.assertNotEquals(null, myAccountShare.Id);
        
        //Change Country from US to non US
        myUSaccount = [Select id, BillingState, SDO_Billing_Country_Name__c from Account where id = :myUSaccount.Id];
        myUSaccount.SDO_Billing_Country_Name__c = 'Ghana';
        update myUSaccount;
        
        //Verify Territory Deleted
        myUSaccount = [Select id, Territory__c from Account where id = :myUSaccount.Id];
        System.assertEquals(null, myUSaccount.Territory__c);
        
        //Verify old AccountShare record deleted
        try { 
            myAccountShare = [Select Id from AccountShare Where AccountId = :myUSaccount.Id And UserOrGroupId = :CATerritory.Public_Group_Id__c];
        } catch (Exception e) {
            System.debug('CHINTAN Caught Exception');
            System.assertEquals(e.getMessage(), 'List has no rows for assignment to SObject');
        }
        
        //Change Country from non-US to US
        myUSaccount = [Select id, BillingState, SDO_Billing_Country_Name__c from Account where id = :myUSaccount.Id];
        myUSaccount.SDO_Billing_Country_Name__c = 'United States';
        myUSaccount.BillingState = 'IL';
        update myUSaccount;
        
        //Verify Territory 
        myUSaccount = [Select id, Territory__c from Account where id = :myUSaccount.Id];
        ILTerritory = [Select id, Public_Group_Id__c from Territory__c where Name = 'IL' Limit 1];
        System.assertEquals(myUSaccount.Territory__c, ILTerritory.Id);
        
        //Verify AccountShare record added
        myAccountShare = [Select Id from AccountShare Where AccountId = :myUSaccount.Id And UserOrGroupId = :ILTerritory.Public_Group_Id__c];
        System.assertNotEquals(null, myAccountShare.Id);
        
        //Change Country from US to Canada
        myUSaccount = [Select id, BillingState, SDO_Billing_Country_Name__c from Account where id = :myUSaccount.Id];
        myUSaccount.SDO_Billing_Country_Name__c = 'Canada';
        myUSaccount.BillingState = 'SK';
        update myUSaccount;
        
        //Verify Territory
        myUSaccount = [Select id, Territory__c, BillingState from Account where id = :myUSaccount.Id];
        System.debug('CHINTAN Account Territory is ' + myUSaccount.Territory__c);
        CATerritory = [Select id, Public_Group_Id__c from Territory__c where Areas_Included_in_Territory__c includes (:myUSaccount.BillingState)];
        System.debug('CHINTAN CA Territory Id is ' + CATerritory.Id);
        System.assertEquals(myUSaccount.Territory__c, CATerritory.Id);
        
        //Verify old AccountShare record deleted
        try { 
            myAccountShare = [Select Id from AccountShare Where AccountId = :myUSaccount.Id And UserOrGroupId = :CATerritory.Public_Group_Id__c];
        } catch (Exception e) {
            System.debug('CHINTAN Caught Exception');
            System.assertEquals(e.getMessage(), 'List has no rows for assignment to SObject');
        }
        
        //Verify AccountShare record added
        myAccountShare = [Select Id from AccountShare Where AccountId = :myUSaccount.Id And UserOrGroupId = :CATerritory.Public_Group_Id__c];
        System.assertNotEquals(null, myAccountShare.Id);
        
        //Change Country from Canada to US
        myUSaccount = [Select id, BillingState, SDO_Billing_Country_Name__c from Account where id = :myUSaccount.Id];
        myUSaccount.SDO_Billing_Country_Name__c = 'United States';
        myUSaccount.BillingState = 'IL';
        update myUSaccount;
        
        //Verify Territory 
        myUSaccount = [Select id, Territory__c from Account where id = :myUSaccount.Id];
        ILTerritory = [Select id, Public_Group_Id__c from Territory__c where Name = 'IL' Limit 1];
        System.assertEquals(myUSaccount.Territory__c, ILTerritory.Id);
        
        //Verify Old AccountShare record deleted
        try { 
            myAccountShare = [Select Id from AccountShare Where AccountId = :myUSaccount.Id And UserOrGroupId = :CATerritory.Public_Group_Id__c];
        } catch (Exception e) {
            System.debug('CHINTAN Caught Exception');
            System.assertEquals(e.getMessage(), 'List has no rows for assignment to SObject');
        }
        
        //Verify AccountShare record added
        myAccountShare = [Select Id from AccountShare Where AccountId = :myUSaccount.Id And UserOrGroupId = :ILTerritory.Public_Group_Id__c];
        System.assertNotEquals(null, myAccountShare.Id);
        
        Test.stopTest();
    } //testUSAccountTerritorySetting
    
    
    /** Validate that Territory and public group is getting assigned properly */ 
    static testMethod void testCanadianAccountTerritorySetting() {
        //local vars
        Map<String, Id> territoryMap = new Map<String, Id> ();
        Map<Id, Id> publicGroupMap = new Map<Id, Id> ();
        
        //Read all Territories
        for (Territory__c territory : [SELECT Public_Group_Id__c, Name, Areas_included_in_Territory__c, Country__c, Id from Territory__c Where Country__c = 'United States' Or Country__c = 'Canada']) {
            if (territory.Country__c.equalsIgnoreCase('United States')) {
                territoryMap.put(territory.Name.toUpperCase(), territory.Id);
                publicGroupMap.put(territory.Id, territory.Public_group_Id__c);
            } else {
                String[] provinces = territory.Areas_included_in_Territory__c.split(';', 0);
                for (String province : provinces) {
                    territoryMap.put(province.toUpperCase(), territory.Id);
                }
                publicGroupMap.put(territory.Id, territory.Public_group_Id__c);
            }
        }
        
        Test.startTest();
        
        //Create a Canadian Account
        Account myCAaccount = new Account();
        Id recordTypeId = util_sampleDataGenerator.getRecordType('Account', 'Client Account Record Type').Id;
        myCAaccount.RecordTypeId = recordTypeId;
        myCAaccount.Name = 'Chintan Canadian Account';
        myCAaccount.SDO_Billing_Country_Name__c = 'Canada';
        myCAaccount.BillingPostalCode = 'L3N 3Q1';
        myCAaccount.BillingState = 'ON';
        insert myCAaccount;
        System.assertNotEquals(null, myCAaccount.Id);
        
        //Verify Territory 
        myCAaccount = [Select id, Territory__c, BillingState from Account where id = :myCAaccount.Id];
        System.debug('CHINTAN Account Territory is ' + myCAaccount.Territory__c);
        Id myTerritoryId = territoryMap.get(myCAaccount.BillingState);
        System.debug('CHINTAN Territory Id is ' + myTerritoryId);
        System.assertEquals(myCAaccount.Territory__c, myTerritoryId);
        
        //Verify AccountShare record
        System.debug('CHINTAN myCAterritory Public Group Id is ' + publicGroupMap.get(myTerritoryId));
        AccountShare myAccountShare = [Select Id from AccountShare Where AccountId = :myCAaccount.Id And UserOrGroupId = :publicGroupMap.get(myTerritoryId)];
        System.assertNotEquals(null, myAccountShare.Id);
        Id oldAccountShareId = myAccountShare.Id;
        
        //Create an Account in Ottawa
        Account ottawaAccount = new Account();
        ottawaAccount.RecordTypeId = recordTypeId;
        ottawaAccount.Name = 'Chintan Ottawa Account';
        ottawaAccount.SDO_Billing_Country_Name__c = 'Canada';
        ottawaAccount.BillingPostalCode = 'L3N 3Q1';
        ottawaAccount.BillingState = 'ON';
        ottawaAccount.BillingCity ='Ottawa';
        insert ottawaAccount;
        System.assertNotEquals(null, ottawaAccount.Id);
        
        //Verify Territory 
        ottawaAccount = [Select id, Territory__c, BillingState from Account where id = :ottawaAccount.Id];
        System.debug('CHINTAN Account Territory is ' + ottawaAccount.Territory__c);
        myTerritoryId = territoryMap.get('QC');
        System.debug('CHINTAN Territory Id is ' + myTerritoryId);
        System.assertEquals(ottawaAccount.Territory__c, myTerritoryId);
        
        //Verify AccountShare record
        System.debug('CHINTAN myCAterritory Public Group Id is ' + publicGroupMap.get(myTerritoryId));
        myAccountShare = [Select Id from AccountShare Where AccountId = :ottawaAccount.Id And UserOrGroupId = :publicGroupMap.get(myTerritoryId)];
        System.assertNotEquals(null, myAccountShare.Id);
 
        //Update State on Canadian Account
        myCAaccount = [Select id, BillingState from Account where id = :myCAaccount.Id];
        myCAaccount.BillingState = 'SK';
        update myCAaccount;
        
        //Verify Territory 
        myCAaccount = [Select id, Territory__c, BillingState from Account where id = :myCAaccount.Id];
        System.debug('CHINTAN Account Territory is ' + myCAaccount.Territory__c);
        myTerritoryId = territoryMap.get(myCAaccount.BillingState);
        System.debug('CHINTAN Territory Id is ' + myTerritoryId);
        System.assertEquals(myCAaccount.Territory__c, myTerritoryId);
        
        //Verify Old AccountShare record deleted
        try { 
            myAccountShare = [Select Id from AccountShare Where Id = :oldAccountShareId];
        } catch (Exception e) {
            System.debug('CHINTAN Caught Exception');
            System.assertEquals(e.getMessage(), 'List has no rows for assignment to SObject');
        }
        //Verify New AccountShare record added
        myAccountShare = [Select Id from AccountShare Where AccountId = :myCAaccount.Id And UserOrGroupId = :publicGroupMap.get(myTerritoryId)];
        System.assertNotEquals(null, myAccountShare.Id);
        
        //Change Country from Canada to non Canada
        myCAaccount = [Select id, BillingState, SDO_Billing_Country_Name__c from Account where id = :myCAaccount.Id];
        myCAaccount.SDO_Billing_Country_Name__c = 'Ghana';
        update myCAaccount;
        
        //Verify Territory Deleted
        myCAaccount = [Select id, Territory__c from Account where id = :myCAaccount.Id];
        System.assertEquals(null, myCAaccount.Territory__c);
        
        //Verify old AccountShare record deleted
        try { 
            myAccountShare = [Select Id from AccountShare Where AccountId = :myCAaccount.Id And UserOrGroupId = :publicGroupMap.get(myTerritoryId)];
        } catch (Exception e) {
            System.debug('CHINTAN Caught Exception');
            System.assertEquals(e.getMessage(), 'List has no rows for assignment to SObject');
        }
        
        //Change Country from non-Canada to Canada
        myCAaccount = [Select id, BillingState, SDO_Billing_Country_Name__c from Account where id = :myCAaccount.Id];
        myCAaccount.SDO_Billing_Country_Name__c = 'Canada';
        myCAaccount.BillingState = 'YT';
        update myCAaccount;
        
        //Verify Territory 
        myCAaccount = [Select id, Territory__c, BillingState from Account where id = :myCAaccount.Id];
        System.debug('CHINTAN Account Territory is ' + myCAaccount.Territory__c);
        myTerritoryId = territoryMap.get(myCAaccount.BillingState);
        System.debug('CHINTAN Territory Id is ' + myTerritoryId);
        System.assertEquals(myCAaccount.Territory__c, myTerritoryId);
        
        //Verify AccountShare record added
        myAccountShare = [Select Id from AccountShare Where AccountId = :myCAaccount.Id And UserOrGroupId = :publicGroupMap.get(myTerritoryId)];
        System.assertNotEquals(null, myAccountShare.Id);
/*        
        //Change Country from Canada to US
        myCAaccount = [Select id, BillingState, SDO_Billing_Country_Name__c from Account where id = :myCAaccount.Id];
        myCAaccount.SDO_Billing_Country_Name__c = 'United States';
        myCAaccount.BillingState = 'NY';
        update myCAaccount;
        
        //Verify Territory 
        myCAaccount = [Select id, Territory__c, BillingState from Account where id = :myCAaccount.Id];
        System.debug('CHINTAN Account Territory is ' + myCAaccount.Territory__c);
        myTerritoryId = territoryMap.get(myCAaccount.BillingState);
        System.debug('CHINTAN Territory Id is ' + myTerritoryId);
        System.assertEquals(myCAaccount.Territory__c, myTerritoryId);
        
        //Verify Old AccountShare record deleted
        try { 
            myAccountShare = [Select Id from AccountShare Where Id = :myAccountShare.Id];
        } catch (Exception e) {
            System.debug('CHINTAN Caught Exception');
            System.assertEquals(e.getMessage(), 'List has no rows for assignment to SObject');
        }
        //Verify New AccountShare record added
        myAccountShare = [Select Id from AccountShare Where AccountId = :myCAaccount.Id And UserOrGroupId = :publicGroupMap.get(myTerritoryId)];
        System.assertNotEquals(null, myAccountShare.Id);
*/        
        
        Test.stopTest();
    } //testCanadianAccountTerritorySetting
    
    
    /** Validate that Territory and public group is getting assigned properly */ 
    static testMethod void testCanadianAccountTerritorySetting2() {
        //local vars
        Map<String, Id> territoryMap = new Map<String, Id> ();
        Map<Id, Id> publicGroupMap = new Map<Id, Id> ();
        
        //Read all Territories
        for (Territory__c territory : [SELECT Public_Group_Id__c, Name, Areas_included_in_Territory__c, Country__c, Id from Territory__c Where Country__c = 'United States' Or Country__c = 'Canada']) {
            if (territory.Country__c.equalsIgnoreCase('United States')) {
                territoryMap.put(territory.Name.toUpperCase(), territory.Id);
                publicGroupMap.put(territory.Id, territory.Public_group_Id__c);
            } else {
                String[] provinces = territory.Areas_included_in_Territory__c.split(';', 0);
                for (String province : provinces) {
                    territoryMap.put(province.toUpperCase(), territory.Id);
                }
                publicGroupMap.put(territory.Id, territory.Public_group_Id__c);
            }
        }
        
        Test.startTest();
        
        //Create a Canadian Account
        Account myCAaccount = new Account();
        Id recordTypeId = util_sampleDataGenerator.getRecordType('Account', 'Client Account Record Type').Id;
        myCAaccount.RecordTypeId = recordTypeId;
        myCAaccount.Name = 'Chintan Canadian Account';
        myCAaccount.SDO_Billing_Country_Name__c = 'Canada';
        myCAaccount.BillingPostalCode = 'L3N 3Q1';
        myCAaccount.BillingState = 'ON';
        insert myCAaccount;
        System.assertNotEquals(null, myCAaccount.Id);
        
        //Verify Territory 
        myCAaccount = [Select id, Territory__c, BillingState from Account where id = :myCAaccount.Id];
        System.debug('CHINTAN Account Territory is ' + myCAaccount.Territory__c);
        Id myTerritoryId = territoryMap.get(myCAaccount.BillingState);
        System.debug('CHINTAN Territory Id is ' + myTerritoryId);
        System.assertEquals(myCAaccount.Territory__c, myTerritoryId);
        
        //Verify AccountShare record
        System.debug('CHINTAN myCAterritory Public Group Id is ' + publicGroupMap.get(myTerritoryId));
        AccountShare myAccountShare = [Select Id from AccountShare Where AccountId = :myCAaccount.Id And UserOrGroupId = :publicGroupMap.get(myTerritoryId)];
        System.assertNotEquals(null, myAccountShare.Id);
        Id oldAccountShareId = myAccountShare.Id;
        
        //Change Country from Canada to US
        myCAaccount = [Select id, BillingState, SDO_Billing_Country_Name__c from Account where id = :myCAaccount.Id];
        myCAaccount.SDO_Billing_Country_Name__c = 'United States';
        myCAaccount.BillingState = 'NY';
        update myCAaccount;
        
        //Verify Territory 
        myCAaccount = [Select id, Territory__c, BillingState from Account where id = :myCAaccount.Id];
        System.debug('CHINTAN Account Territory is ' + myCAaccount.Territory__c);
        myTerritoryId = territoryMap.get(myCAaccount.BillingState);
        System.debug('CHINTAN Territory Id is ' + myTerritoryId);
        System.assertEquals(myCAaccount.Territory__c, myTerritoryId);
        
        //Verify Old AccountShare record deleted
        try { 
            myAccountShare = [Select Id from AccountShare Where Id = :myAccountShare.Id];
        } catch (Exception e) {
            System.debug('CHINTAN Caught Exception');
            System.assertEquals(e.getMessage(), 'List has no rows for assignment to SObject');
        }
        //Verify New AccountShare record added
        myAccountShare = [Select Id from AccountShare Where AccountId = :myCAaccount.Id And UserOrGroupId = :publicGroupMap.get(myTerritoryId)];
        System.assertNotEquals(null, myAccountShare.Id);
        
        Test.stopTest();
    } //testCanadianAccountTerritorySetting2
    
    
    /** Validate that Territory and public group is getting assigned properly */ 
    static testMethod void testAccountDefunctSetting() {
        Test.startTest();
        
        //create a US account
        Account myUSaccount = util_sampleDataGenerator.createAccount_Client();
        System.assertNotEquals(myUSaccount.Id, null);
        System.debug('CHINTAN Created Account with Id ' + myUSaccount.Id);
 
        //Verify Territory 
        myUSaccount = [Select id, Territory__c from Account where id = :myUSaccount.Id];
        System.debug('CHINTAN Account Territory is ' + myUSaccount.Territory__c);
        Territory__c ILTerritory = [Select id, Public_Group_Id__c from Territory__c where Name = 'IL' Limit 1];
        System.debug('CHINTAN IL Territory Id is ' + ILTerritory.Id);
        System.assertEquals(myUSaccount.Territory__c, ILTerritory.Id);
        
        //Verify AccountShare record
        System.debug('CHINTAN IL Public Group Id is ' + ILTerritory.Public_Group_Id__c);
        AccountShare myAccountShare = [Select Id from AccountShare Where AccountId = :myUSaccount.Id And UserOrGroupId = :ILTerritory.Public_Group_Id__c];
        System.assertNotEquals(null, myAccountShare.Id);
        
        //Set Defunct
        myUSaccount = [Select id, Account_Status__c from Account where id = :myUSaccount.Id];
        myUSaccount.Account_Status__c = 'Defunct';
        update myUSaccount;
        
        //Verify Territory
        myUSaccount = [Select id, Territory__c from Account where id = :myUSaccount.Id];
        System.assertEquals(myUSaccount.Territory__c, null);
        
        //Verify Old AccountShare record deleted
        try { 
            myAccountShare = [Select Id from AccountShare Where Id = :myAccountShare.Id];
        } catch (Exception e) {
            System.debug('CHINTAN Caught Exception');
            System.assertEquals(e.getMessage(), 'List has no rows for assignment to SObject');
        }
        
        //Change back to Active
        myUSaccount = [Select id, Account_Status__c from Account where id = :myUSaccount.Id];
        myUSaccount.Account_Status__c = 'Active';
        update myUSaccount;
        
        //Verify Territory 
        myUSaccount = [Select id, Territory__c from Account where id = :myUSaccount.Id];
        ILTerritory = [Select id, Public_Group_Id__c from Territory__c where Name = 'IL' Limit 1];
        System.assertEquals(myUSaccount.Territory__c, ILTerritory.Id);
        
        //Verify AccountShare record
        System.debug('CHINTAN IL Public Group Id is ' + ILTerritory.Public_Group_Id__c);
        myAccountShare = [Select Id from AccountShare Where AccountId = :myUSaccount.Id And UserOrGroupId = :ILTerritory.Public_Group_Id__c];
        System.assertNotEquals(null, myAccountShare.Id);
        
        //Create a Canadian Account
        Account myCAaccount = new Account();
        Id recordTypeId = util_sampleDataGenerator.getRecordType('Account', 'Client Account Record Type').Id;
        myCAaccount.RecordTypeId = recordTypeId;
        myCAaccount.Name = 'Chintan Canadian Account';
        myCAaccount.SDO_Billing_Country_Name__c = 'Canada';
        myCAaccount.BillingPostalCode = 'L3N 3Q1';
        myCAaccount.BillingState = 'ON';
        insert myCAaccount;
        System.assertNotEquals(null, myCAaccount.Id);
        
        //local vars
        Map<String, Id> territoryMap = new Map<String, Id> ();
        Map<Id, Id> publicGroupMap = new Map<Id, Id> ();
        
        //Read all Territories
        for (Territory__c territory : [SELECT Public_Group_Id__c, Name, Areas_included_in_Territory__c, Country__c, Id from Territory__c Where Country__c = 'United States' Or Country__c = 'Canada']) {
            if (territory.Country__c.equalsIgnoreCase('United States')) {
                territoryMap.put(territory.Name.toUpperCase(), territory.Id);
                publicGroupMap.put(territory.Id, territory.Public_group_Id__c);
            } else {
                String[] provinces = territory.Areas_included_in_Territory__c.split(';', 0);
                for (String province : provinces) {
                    territoryMap.put(province.toUpperCase(), territory.Id);
                }
                publicGroupMap.put(territory.Id, territory.Public_group_Id__c);
            }
        }
        
        //Verify Territory 
        myCAaccount = [Select id, Territory__c, BillingState from Account where id = :myCAaccount.Id];
        System.debug('CHINTAN Account Territory is ' + myCAaccount.Territory__c);
        Id myTerritoryId = territoryMap.get(myCAaccount.BillingState);
        System.debug('CHINTAN Territory Id is ' + myTerritoryId);
        System.assertEquals(myCAaccount.Territory__c, myTerritoryId);
        
        //Verify AccountShare record
        System.debug('CHINTAN myCAterritory Public Group Id is ' + publicGroupMap.get(myTerritoryId));
        myAccountShare = [Select Id from AccountShare Where AccountId = :myCAaccount.Id And UserOrGroupId = :publicGroupMap.get(myTerritoryId)];
        System.assertNotEquals(null, myAccountShare.Id);
        Id oldAccountShareId = myAccountShare.Id;
        
        //Set Defunct
        myCAaccount = [Select id, Account_Status__c from Account where id = :myCAaccount.Id];
        myCAaccount.Account_Status__c = 'Defunct';
        update myCAaccount;
        
        //Verify Territory
        myCAaccount = [Select id, Territory__c from Account where id = :myCAaccount.Id];
        System.assertEquals(myCAaccount.Territory__c, null);
        
        //Verify Old AccountShare record deleted
        try { 
            myAccountShare = [Select Id from AccountShare Where Id = :myAccountShare.Id];
        } catch (Exception e) {
            System.debug('CHINTAN Caught Exception');
            System.assertEquals(e.getMessage(), 'List has no rows for assignment to SObject');
        }
        
        //Change back to Active
        myCAaccount = [Select id, Account_Status__c from Account where id = :myCAaccount.Id];
        myCAaccount.Account_Status__c = 'Active';
        update myCAaccount;
        
        //Verify Territory 
        myCAaccount = [Select id, Territory__c, BillingState from Account where id = :myCAaccount.Id];
        System.debug('CHINTAN Account Territory is ' + myCAaccount.Territory__c);
        myTerritoryId = territoryMap.get(myCAaccount.BillingState);
        System.debug('CHINTAN Territory Id is ' + myTerritoryId);
        System.assertEquals(myCAaccount.Territory__c, myTerritoryId);
        
        //Verify AccountShare record
        System.debug('CHINTAN myCAterritory Public Group Id is ' + publicGroupMap.get(myTerritoryId));
        myAccountShare = [Select Id from AccountShare Where AccountId = :myCAaccount.Id And UserOrGroupId = :publicGroupMap.get(myTerritoryId)];
        System.assertNotEquals(null, myAccountShare.Id);
        
        Test.stopTest();
    } //testAccountDefunctSetting
    

    /** 00008792-Ritu Sharma-Testing code of populateAccSegmentationInfo function of blogic_Account class */
    static testMethod void test_populateAccSegmentationInfo() {
        //Initializing record type ids
        String extAccRecTypeID = util_sampleDataGenerator.getRecordType('Account','Client Account Record Type').ID;
        
        test.startTest();
        
        //Create test accounts
        Account testAcc1 = util_sampleDataGenerator.createAccount('TestAccount1',extAccRecTypeID,'India','Delhi');
        Account testAcc2 = util_sampleDataGenerator.createAccount('TestAccount2',extAccRecTypeID,'India','Delhi');
        System.assertNotEquals(null, testAcc1.Id);
        System.assertNotEquals(null, testAcc2.Id);
        
        //Creating segmentations
        Account_Segmentation__c testSeg1=new Account_Segmentation__c(Associated_Account__c=testAcc1.ID,Country__c='UNITED STATES',Segment__c='CNS Mid-Market Accounts',Sub_Segment__c='Secondary');
        Account_Segmentation__c testSeg2=new Account_Segmentation__c(Associated_Account__c=testAcc1.ID,Country__c='UNITED KINGDOM',Segment__c='UK - FY10 Practice Prospects',Sub_Segment__c='Retirement Prospects');    
        insert testSeg1;
        insert testSeg2;                
        System.assertNotEquals(null, testSeg1.Id);
        System.assertNotEquals(null, testSeg2.Id);
        testAcc1 = [Select Id, Account_Segmentation__c from Account where Id = :testAcc1.Id];
        system.assertequals(testAcc1.Account_Segmentation__c,'UNITED STATES,CNS Mid-Market Accounts,Secondary;UNITED KINGDOM,UK - FY10 Practice Prospects,Retirement Prospects');
        
        //Updating sengmentations
        testSeg1.Associated_Account__c=testAcc2.ID;
        testSeg2.Sub_Segment__c='HRO Prospects';
        update testSeg1;
        update testSeg2;
        testAcc1 = [Select Id, Account_Segmentation__c from Account where Id = :testAcc1.Id];
        testAcc2= [Select Id, Account_Segmentation__c from Account where Id = :testAcc2.Id];
        system.assertequals(testAcc1.Account_Segmentation__c,'UNITED KINGDOM,UK - FY10 Practice Prospects,HRO Prospects');
        system.assertequals(testAcc2.Account_Segmentation__c,'UNITED STATES,CNS Mid-Market Accounts,Secondary');
        
        //Deleting a segmentation
        delete testSeg2;
        testAcc1 = [Select Id, Account_Segmentation__c from Account where Id = :testAcc1.Id];
        system.assertequals(testAcc1.Account_Segmentation__c,null);
        
        //Undeleting a segmentation
        undelete testSeg2;
        testAcc1 = [Select Id, Account_Segmentation__c from Account where Id = :testAcc1.Id];
        system.assertequals(testAcc1.Account_Segmentation__c,'UNITED KINGDOM,UK - FY10 Practice Prospects,HRO Prospects');
        
        //BULK Testing - Inserting 200 account segments
        List <Account_Segmentation__c> testSegments = new List<Account_Segmentation__c>();
        for(Integer i=0;i<100;i++)
        {
            testSeg1=new Account_Segmentation__c(Associated_Account__c=testAcc1.ID,Country__c='UNITED STATES',Segment__c='CNS Mid-Market Accounts',Sub_Segment__c='Secondary' + i);
            testSeg2=new Account_Segmentation__c(Associated_Account__c=testAcc2.ID,Country__c='UNITED KINGDOM',Segment__c='UK - FY10 Practice Prospects',Sub_Segment__c='Retirement Prospects' + i);    
            
            testSegments.add(testSeg1);
            testSegments.add(testSeg2);            
        }        
        insert testSegments;
        
        //BULK Testing - Updating 200 account segments
        for(Integer i=0;i<testSegments.size();i++)
        {
            if (testSegments[i].Associated_Account__c==testAcc1.ID)
                testSegments[i].Associated_Account__c=testAcc2.ID;                
            else
                testSegments[i].Sub_Segment__c='HRO Prospects' + i;
        }
        update testSegments; 
        test.stopTest();    
    } //test_populateAccSegmentationInfo
    
    
    /** Validate that the Internal Account Team table is kept in synch with Account Owner maintenance
      * Chintan, July 30, 2012 */
    static testMethod void testAccountOwnerMaint() {
        //create an account
        Account myAccount = util_sampleDataGenerator.createAccount_Client();
        System.assertNotEquals(myAccount.Id, null);
        System.debug('CHINTAN Created Account with Id ' + myAccount.Id);
        
        //Create internal contact
        Contact internalContact = util_sampleDataGenerator.createContact_Internal(myAccount.Id);
        System.assertNotEquals(null, internalContact.Id);
        System.debug('CHINTAN Created Internal Contact with Id ' + internalContact.Id);
 
        //Create test user
        User user = util_sampleDataGenerator.createHewittStandardUser(false);
        user.Internal_Contact_Id__c = internalContact.Id;
        insert user;
        System.assertNotEquals(null, user.Id);
        System.debug('CHINTAN Created User with Id ' + user.Id);
 
        //Update internal contact
        internalContact.Corresponding_User_Id__c = user.Id; 
        update internalContact;

        //Create another account
        Account account = new Account();
        account.RecordTypeId = util_sampleDataGenerator.getRecordType('Account', 'Client Account Record Type').Id;
        account.Name = 'Test Apex Chintan Account';
        account.SDO_Billing_Country_Name__c = 'United States';
        account.BillingPostalCode = '60051';
        account.BillingState = 'IL';
        account.ownerId = user.Id;
        
        Test.startTest();
            insert account;
            System.assertNotEquals(null, account.Id);
        Test.stopTest();
        
        //Pull Internal Account Team record
        Internal_Account_Team__c[] iatList = [Select Contact__c From Internal_Account_Team__c Where Account__c = :account.Id And Contact_Role__c = 'Account Owner'];
        if (iatList.size() == 1) {
            System.debug('CHINTAN Found Internal Account Team AE Record with Contact ID ' + iatList[0].Contact__c);
            //Assert that matching contact record got inserted into the Internal Account Team
            System.assertEquals(iatList[0].Contact__c, internalContact.Id);
        } else {
            System.debug('CHINTAN ERROR! No AE Record found in the Internal Account Team');
        }
        
        //Get the contact ID for current user
        Contact myContact = [Select Id, Corresponding_User_Id__c from Contact where Corresponding_User_Id__c = :UserInfo.getUserId()];
        
        //update the account owner
        account = [Select OwnerId from Account where Id = :account.Id];
        account.OwnerId = UserInfo.getUserId();
        update account;
        
        //Assert the update
        System.assertEquals(account.OwnerId, UserInfo.getUserId());
        
        //Pull Internal Account Team record
        iatList = [Select Contact__c From Internal_Account_Team__c Where Account__c = :account.Id And Contact_Role__c = 'Account Owner'];
        if (iatList.size() == 1) {
            System.debug('CHINTAN Found Internal Account Team AE Record with Contact ID ' + iatList[0].Contact__c);
            //Assert that matching contact record got inserted into the Internal Account Team
            System.assertEquals(iatList[0].Contact__c, myContact.Id);
        } else {
            System.debug('CHINTAN ERROR! No AE Record found in the Internal Account Team');
        }
    } //testAccountOwnerMaint
    
    
    /** Validate that the Internal Account Team table is kept in synch with bulk Account Owner maintenance
      * Chintan, July 30, 2012 */
    static testMethod void testAccountOwnerMaint_Bulk() {
        //Declare local vars
        Set <Id> accountIds = new Set<Id>();
        
        //Create an account to hold the test user
        Account myAccount = util_sampleDataGenerator.createAccount_Client();
        System.assertNotEquals(myAccount.Id, null);
        System.debug('CHINTAN Created Account with Id ' + myAccount.Id);
        
        //Create internal contact
        Contact internalContact = util_sampleDataGenerator.createContact_Internal(myAccount.Id);
        System.assertNotEquals(null, internalContact.Id);
        System.debug('CHINTAN Created Internal Contact with Id ' + internalContact.Id);
 
        //Create test user
        User user = util_sampleDataGenerator.createHewittStandardUser(false);
        user.Internal_Contact_Id__c = internalContact.Id;
        insert user;
        System.assertNotEquals(null, user.Id);
        System.debug('CHINTAN Created User with Id ' + user.Id);
 
        //Update internal contact
        internalContact.Corresponding_User_Id__c = user.Id; 
        update internalContact;

        Test.startTest();
        
        //Create 25 accounts
        List <Account> accounts = util_SampleDataGenerator.createPeopleSoftClients('TEST', 25, false);
        for (Account account : accounts) {
            account.ownerId = user.Id;
        }
        insert accounts;
        
        //Collect the distinct set of ids created
        for (Account account : accounts) {
            accountIds.add(account.Id);
        }
        System.assertEquals(25, accountIds.size());
        
        //Retrieve the results of the insert
        Internal_Account_Team__c[] iatList = [Select Contact__c From Internal_Account_Team__c Where Account__c in :accountIds And Contact_Role__c = 'Account Owner'];
        for (Internal_Account_Team__c iat : iatList) {
            //Assert that matching contact record got inserted into the Internal Account Team
            System.assertEquals(iat.Contact__c, internalContact.Id);
        }
        
        //Get the contact ID for current user
        Contact myContact = [Select Id, Corresponding_User_Id__c from Contact where Corresponding_User_Id__c = :UserInfo.getUserId() LIMIT 1];
        
        //update the account owner
        List<Account> accountsToUpdate = new List<Account> ();
        accounts = [Select OwnerId from Account where Id in :accountIds];
        for (Account account : accounts) {
            account.OwnerId = UserInfo.getUserId();
            accountsToUpdate.add(account);
        }
        update accountsToUpdate;
        
        Test.stopTest();
        
        //Assert the update
        accounts = [Select OwnerId from Account where Id in :accountIds];
        for (Account account : accounts) {
            System.assertEquals(account.OwnerId, UserInfo.getUserId());
        }
        
        //Pull Internal Account Team record
        iatList = [Select Contact__c From Internal_Account_Team__c Where Account__c in :accountIds And Contact_Role__c = 'Account Owner'];
        for (Internal_Account_Team__c iat : iatList) {
            //Assert that matching contact record got inserted into the Internal Account Team
            System.assertEquals(iat.Contact__c, myContact.Id);
        }
    } //testAccountOwnerMaint_Bulk
    
    
    /** Validate that AccountTeamMember and AccountShare tables are kept in synch with Internal Account Team adds
      * Chintan, August 02, 2012 */
    static testMethod void testInternalAccountTeamMaint() {
        //create an account
        Account myAccount = util_sampleDataGenerator.createAccount_Client();
        System.assertNotEquals(myAccount.Id, null);
        System.debug('CPA Created Account with Id ' + myAccount.Id);
        
        //Create internal contact
        Contact internalContact = util_sampleDataGenerator.createContact_Internal(myAccount.Id);
        System.assertNotEquals(null, internalContact.Id);
        System.debug('CPA Created Internal Contact with Id ' + internalContact.Id);
 
        //Create test user
        User user = util_sampleDataGenerator.createHewittStandardUser(false);
        user.Internal_Contact_Id__c = internalContact.Id;
        insert user;
        System.assertNotEquals(null, user.Id);
        System.debug('CPA Created User with Id ' + user.Id);
 
        //Update internal contact
        internalContact.Corresponding_User_Id__c = user.Id; 
        update internalContact;
                
         Test.startTest();
        
        //Create Internal Account Team Record
        Internal_Account_Team__c iat = util_sampleDataGenerator.createInternalAccountTeam(myAccount.Id, internalContact.Id, 'General Support');
        
        Test.stopTest();
        
        //Verify AccountTeamMember record
        AccountTeamMember[] atmList = [Select AccountId, UserId, TeamMemberRole From AccountTeamMember Where AccountId = :myAccount.Id and UserId = :user.Id];
        System.assertEquals(atmList.size(), 1);
        System.assertEquals(atmList[0].TeamMemberRole, 'Account Team Member');
        
        //Verify AccountShare Record
        AccountShare[] accountShareList = [Select AccountAccessLevel, ContactAccessLevel, CaseAccessLevel, OpportunityAccessLevel From AccountShare where AccountId = :myAccount.Id and UserOrGroupId = :user.Id];
        System.assertEquals(accountShareList.size(), 1);
        System.assertEquals(accountShareList[0].ContactAccessLevel, 'Edit');
        System.assertEquals(accountShareList[0].CaseAccessLevel, 'Edit');
        System.assertEquals(accountShareList[0].OpportunityAccessLevel, 'Edit');
        System.assertEquals(accountShareList[0].AccountAccessLevel, 'Edit');
    } //testInternalAccountTeamMaint
    
    
    /** Validate that AccountTeamMember and AccountShare tables are kept in synch with Internal Account Team adds
      * Chintan, August 02, 2012 */
    static testMethod void testInternalAccountTeamMaint_bulk() {
        //Number of Records to Create
        integer numToCreate = 50;
        List<String> contactIds = new List<String> ();
        List<String> userIds = new List<String> ();
        
        //create an account
        Account myAccount = util_sampleDataGenerator.createAccount_Client();
        System.assertNotEquals(myAccount.Id, null);
        System.debug('CPA Created Account with Id ' + myAccount.Id);
        
        //Create internal contacts
        List<Contact> internalContacts = util_sampleDataGenerator.createInternalContact_bulk(myAccount.Id, numToCreate, true);
        System.assertEquals(numToCreate, internalContacts.size());
        System.debug('CPA Created ' + numToCreate + ' Internal Contacts');
        
        // collect the distinct set of ids created
        for (Contact contact : internalContacts) {
            contactIds.add(contact.Id);
        }
        System.assertEquals(numToCreate, contactIds.size());

        //Create users
        List<User> users = util_sampleDataGenerator.createHewittStandardUser_bulk(numToCreate, false);
        //Pull internal contacts again
        internalContacts = [Select Corresponding_User_Id__c from Contact where Id in :contactIds];
        System.assertEquals(numToCreate, internalContacts.size());
        for (integer i=0; i<numToCreate; i++) {
            users[i].Internal_Contact_Id__c = internalContacts[i].Id;
        }
        insert users;
        System.assertEquals(numToCreate, users.size());
        System.debug('CPA Created ' + numToCreate + ' Users');
        
        // collect the distinct set of ids created
        for (User user : users) {
            userIds.add(user.Id);
        }
        System.assertEquals(numToCreate, userIds.size());

        //Pull user records again
        users = [Select Id from User where Id in :userIds];
        System.assertEquals(numToCreate, users.size());
        
        //Update internal contacts
        for (integer i=0; i<internalContacts.size(); i++) {
            internalContacts[i].Corresponding_User_Id__c = users[i].Id;
        } 
        update internalContacts;
        
        //Create Internal Account Team Records
        List<Internal_Account_Team__c> iatList = util_sampleDataGenerator.createInternalAccountTeam_bulk(myAccount.Id, contactIds, 'General Support', numToCreate, true);
        
        //Verify AccountTeamMember record
        AccountTeamMember[] atmList = [Select AccountId, UserId, TeamMemberRole From AccountTeamMember Where AccountId = :myAccount.Id and UserId in :userIds];
        System.assertEquals(atmList.size(), numToCreate);
        for (integer i=0; i<numToCreate; i++) {
            System.assertEquals(atmList[i].TeamMemberRole, 'Account Team Member');
        }
        
        //Verify AccountShare Record
        AccountShare[] accountShareList = [Select AccountAccessLevel, ContactAccessLevel, CaseAccessLevel, OpportunityAccessLevel From AccountShare where AccountId = :myAccount.Id and UserOrGroupId in :userIds];
        System.assertEquals(accountShareList.size(), numToCreate);
        for (integer i=0; i<numToCreate; i++) {
            System.assertEquals(accountShareList[i].ContactAccessLevel, 'Edit');
            System.assertEquals(accountShareList[i].CaseAccessLevel, 'Edit');
            System.assertEquals(accountShareList[i].OpportunityAccessLevel, 'Edit');
            System.assertEquals(accountShareList[i].AccountAccessLevel, 'Edit');
        }
    } //testInternalAccountTeamMaint_bulk
    
    
    /** Validate that AccountTeamMember and AccountShare tables are kept in synch with Internal Account Team deletes
      * Chintan, August 06, 2012 */
    static testMethod void testInternalAccountTeamDelete() {
        //create an account
        Account myAccount = util_sampleDataGenerator.createAccount_Client();
        System.assertNotEquals(myAccount.Id, null);
        System.debug('CPA Created Account with Id ' + myAccount.Id);
        
        //Create internal contact
        Contact internalContact = util_sampleDataGenerator.createContact_Internal(myAccount.Id);
        System.assertNotEquals(null, internalContact.Id);
        System.debug('CPA Created Internal Contact with Id ' + internalContact.Id);
 
        //Create test user
        User user = util_sampleDataGenerator.createHewittStandardUser(false);
        user.Internal_Contact_Id__c = internalContact.Id;
        insert user;
        System.assertNotEquals(null, user.Id);
        System.debug('CPA Created User with Id ' + user.Id);
 
        //Update internal contact
        internalContact.Corresponding_User_Id__c = user.Id; 
        update internalContact;
        
        //Create Internal Account Team Record
        Internal_Account_Team__c iat1 = util_sampleDataGenerator.createInternalAccountTeam(myAccount.Id, internalContact.Id, 'General Support');
        System.assertNotEquals(null, iat1.Id);
        
        //Verify AccountTeamMember record
        AccountTeamMember[] atmList = [Select AccountId, UserId, TeamMemberRole From AccountTeamMember Where AccountId = :myAccount.Id and UserId = :user.Id];
        System.assertEquals(atmList.size(), 1);
        System.assertEquals(atmList[0].TeamMemberRole, 'Account Team Member');
        
        //Verify AccountShare Record
        AccountShare[] accountShareList = [Select AccountAccessLevel, ContactAccessLevel, CaseAccessLevel, OpportunityAccessLevel From AccountShare where AccountId = :myAccount.Id and UserOrGroupId = :user.Id];
        System.assertEquals(accountShareList.size(), 1);
        System.assertEquals(accountShareList[0].ContactAccessLevel, 'Edit');
        System.assertEquals(accountShareList[0].CaseAccessLevel, 'Edit');
        System.assertEquals(accountShareList[0].OpportunityAccessLevel, 'Edit');
        
        //Now delete Internal Account Team record
        iat1 = [Select Id from Internal_Account_Team__c where id = :iat1.Id];
        delete iat1;
        
        //Verify Account Team Member Record Deletion
        atmList = [Select Id from AccountTeamMember where AccountId = :myAccount.Id and UserId = :user.Id];
        System.assertEquals(atmList.isEmpty(), true);
        
        //Readd
        iat1 = util_sampleDataGenerator.createInternalAccountTeam(myAccount.Id, internalContact.Id, 'General Support');
        System.assertNotEquals(null, iat1.Id);
        
        //Verify AccountTeamMember record
        atmList = [Select AccountId, UserId, TeamMemberRole From AccountTeamMember Where AccountId = :myAccount.Id and UserId = :user.Id];
        System.assertEquals(atmList.size(), 1);
        System.assertEquals(atmList[0].TeamMemberRole, 'Account Team Member');
        
        //Verify AccountShare Record
        accountShareList = [Select AccountAccessLevel, ContactAccessLevel, CaseAccessLevel, OpportunityAccessLevel From AccountShare where AccountId = :myAccount.Id and UserOrGroupId = :user.Id];
        System.assertEquals(accountShareList.size(), 1);
        System.assertEquals(accountShareList[0].ContactAccessLevel, 'Edit');
        System.assertEquals(accountShareList[0].CaseAccessLevel, 'Edit');
        System.assertEquals(accountShareList[0].OpportunityAccessLevel, 'Edit');
        
        //Add Another Internal Account Team record for same user in a different role
        Internal_Account_Team__c iat2 = util_sampleDataGenerator.createInternalAccountTeam(myAccount.Id, internalContact.Id, 'Consultant');
        System.assertNotEquals(null, iat2.Id);
        
        //Verify Single AccountTeamMember record
        atmList = [Select AccountId, UserId, TeamMemberRole From AccountTeamMember Where AccountId = :myAccount.Id and UserId = :user.Id];
        System.assertEquals(atmList.size(), 1);
        System.assertEquals(atmList[0].TeamMemberRole, 'Account Team Member');
        
        //Verify Single AccountShare Record
        accountShareList = [Select AccountAccessLevel, ContactAccessLevel, CaseAccessLevel, OpportunityAccessLevel From AccountShare where AccountId = :myAccount.Id and UserOrGroupId = :user.Id];
        System.assertEquals(accountShareList.size(), 1);
        System.assertEquals(accountShareList[0].ContactAccessLevel, 'Edit');
        System.assertEquals(accountShareList[0].CaseAccessLevel, 'Edit');
        System.assertEquals(accountShareList[0].OpportunityAccessLevel, 'Edit');
        
        //Now delete one
        iat1 = [Select Id from Internal_Account_Team__c where id = :iat1.Id];
        delete iat1;
        
        //Verify that AccountTeamMember record still exists due to the second IAT record
        atmList = [Select AccountId, UserId, TeamMemberRole From AccountTeamMember Where AccountId = :myAccount.Id and UserId = :user.Id];
        System.assertEquals(atmList.size(), 1);
        System.assertEquals(atmList[0].TeamMemberRole, 'Account Team Member');
        
        //Verify AccountShare Record still exists
        accountShareList = [Select AccountAccessLevel, ContactAccessLevel, CaseAccessLevel, OpportunityAccessLevel From AccountShare where AccountId = :myAccount.Id and UserOrGroupId = :user.Id];
        System.assertEquals(accountShareList.size(), 1);
        System.assertEquals(accountShareList[0].ContactAccessLevel, 'Edit');
        System.assertEquals(accountShareList[0].CaseAccessLevel, 'Edit');
        System.assertEquals(accountShareList[0].OpportunityAccessLevel, 'Edit');
    } //testInternalAccountTeamDelete
    
    
    /** Validate that AccountTeamMember and AccountShare tables are kept in synch with Internal Account Team deletes
      * Chintan, August 06, 2012 */
    static testMethod void testInternalAccountTeamDelete_bulk() {
        //Number of Records to Create
        integer numToCreate = 50;
        List<String> contactIds = new List<String> ();
        List<String> userIds = new List<String> ();
        List<String> iatIds = new List<String> ();
        
        //create an account
        Account myAccount = util_sampleDataGenerator.createAccount_Client();
        System.assertNotEquals(myAccount.Id, null);
        System.debug('CPA Created Account with Id ' + myAccount.Id);
        
        //Create internal contacts
        List<Contact> internalContacts = util_sampleDataGenerator.createInternalContact_bulk(myAccount.Id, numToCreate, true);
        System.assertEquals(numToCreate, internalContacts.size());
        System.debug('CPA Created ' + numToCreate + ' Internal Contacts');
        
        //collect the distinct set of ids created
        for (Contact contact : internalContacts) {
            contactIds.add(contact.Id);
        }
        System.assertEquals(numToCreate, contactIds.size());

        //Create users
        List<User> users = util_sampleDataGenerator.createHewittStandardUser_bulk(numToCreate, false);
        //Pull Records again
        internalContacts = [Select Corresponding_User_Id__c from Contact where Id in :contactIds];
        System.assertEquals(numToCreate, internalContacts.size());
        for (integer i=0; i<numToCreate; i++) {
            users[i].Internal_Contact_Id__c = internalContacts[i].Id;
        }
        insert users;
        System.assertEquals(numToCreate, users.size());
        System.debug('CPA Created ' + numToCreate + ' Users');
        
        //collect the distinct set of ids created
        for (User user : users) {
            userIds.add(user.Id);
        }
        System.assertEquals(numToCreate, userIds.size());

        //Pull user records again
        users = [Select Id from User where Id in :userIds];
        System.assertEquals(numToCreate, users.size());
        
        //Update internal contacts
        for (integer i=0; i<internalContacts.size(); i++) {
            internalContacts[i].Corresponding_User_Id__c = users[i].Id;
        } 
        update internalContacts;
        
        //Create Internal Account Team Records
        List<Internal_Account_Team__c> iatList = util_sampleDataGenerator.createInternalAccountTeam_bulk(myAccount.Id, contactIds, 'General Support', numToCreate, true);
        System.assertEquals(numToCreate, iatList.size());
        
        //Collect distinct IDs
        for (Internal_Account_Team__c iat : iatList) {
            iatIds.add(iat.Id);
        }
        System.assertEquals(numToCreate, iatIds.size());
        
        //Verify AccountTeamMember record
        AccountTeamMember[] atmList = [Select AccountId, UserId, TeamMemberRole From AccountTeamMember Where AccountId = :myAccount.Id and UserId in :userIds];
        System.assertEquals(atmList.size(), numToCreate);
        for (integer i=0; i<numToCreate; i++) {
            System.assertEquals(atmList[i].TeamMemberRole, 'Account Team Member');
        }
        
        //Verify AccountShare Record
        AccountShare[] accountShareList = [Select AccountAccessLevel, ContactAccessLevel, CaseAccessLevel, OpportunityAccessLevel From AccountShare where AccountId = :myAccount.Id and UserOrGroupId in :userIds];
        System.assertEquals(accountShareList.size(), numToCreate);
        for (integer i=0; i<numToCreate; i++) {
            System.assertEquals(accountShareList[i].ContactAccessLevel, 'Edit');
            System.assertEquals(accountShareList[i].CaseAccessLevel, 'Edit');
            System.assertEquals(accountShareList[i].OpportunityAccessLevel, 'Edit');
            System.assertEquals(accountShareList[i].AccountAccessLevel, 'Edit');
        }
        
        //Delete IAT Records now
        iatList = [Select Id from Internal_Account_Team__c where id in :iatIds];
        System.assertEquals(numToCreate, iatList.size());
        delete iatList;
        
        //Verify AccountTeamMember record
        atmList = [Select AccountId, UserId, TeamMemberRole From AccountTeamMember Where AccountId = :myAccount.Id and UserId in :userIds];
        System.assertEquals(atmList.isEmpty(), true);
    } //testInternalAccountTeamDelete_bulk
    
    
    /** Test Billing Country copy to the out of the box field
      * Chintan, September 4, 2012 */
    static testMethod void testCountryCopy() {
        //create data
        Account myAccount = util_sampleDataGenerator.createAccount_Client();
        System.assertNotEquals(null, myAccount.Id);
        
        //Retrieve
        myAccount = [Select BillingCountry, SDO_Billing_Country_Name__c from Account where Id = :myAccount.Id];
        
        //Assert
        System.assertEquals(myAccount.BillingCountry, myAccount.SDO_Billing_Country_Name__c);
    } //testCountryCopy
    
    
    /** Test bulk country copy
      * Chintan. September 04, 2012 */
    static testMethod void testCountryCopy_bulk() {
        final integer count = 20;
        List<Id> accountIds = new List<Id> ();
        
        //Create
        List<Account> myAccounts = util_sampleDataGenerator.createPeopleSoftClients('Chintan Test Account', count, true);
        System.assertEquals(myAccounts.size(), count);
        
        //Store IDs
        for (Account myAccount : myAccounts) {
            accountIds.add(myAccount.Id);
        }
        System.assertEquals(accountIds.size(), count);
        
        //Retrieve
        myAccounts = [Select BillingCountry, SDO_Billing_Country_Name__c from Account where Id in :accountIds];
        System.assertEquals(myAccounts.size(), count);
        
        //Assert
        for (Account myAccount : myAccounts) {
            System.assertEquals(myAccount.BillingCountry, myAccount.SDO_Billing_Country_Name__c);
        }
    } //testCountryCopy_bulk
    
    
    /** Test that inserting or deleting Executive Sponsor in the Internal Account Team updates Account
      * Chintan, September 4, 2012 */
    static testMethod void testExecutiveSponsorUpdate() {
        //Create Data
        Account myAccount = util_sampleDataGenerator.createAccount_Client();
        System.assertNotEquals(myAccount.Id, null);
        
        Contact myContact = util_sampleDataGenerator.createContact_Internal(myAccount.Id);
        System.assertNotEquals(myContact.Id, null);
        
        Internal_Account_Team__c myTeam = util_sampleDataGenerator.createInternalAccountTeam(myAccount.Id, myContact.Id, 'Executive Sponsor');
        System.assertNotEquals(myTeam.Id, null);
        
        //Retrieve Account
        myAccount = [Select Id, Aon_Hewitt_Executive_Sponsor__c from Account where Id = :myAccount.Id];
        
        //Assert
        System.assertEquals(myAccount.Aon_Hewitt_Executive_Sponsor__c, myContact.Id);
        
        //Delete Exec Sponsor
        delete myTeam;
        
        //Retrieve Account
        myAccount = [Select Id, Aon_Hewitt_Executive_Sponsor__c from Account where Id = :myAccount.Id];
        
        //Assert
        System.assertEquals(myAccount.Aon_Hewitt_Executive_Sponsor__c, null);
    } //testExecutiveSponsorUpdate
    
    
    /** Test that Account industry is updated when SIC is filled in
      * Chintan, September 4, 2012 */
    static testMethod void test_SICUpdate() {
        //Pull Some SIC data
        //00078331-Ritu Sharma-Updated SOQL query to pull Aon_Global_Industry_Level_2__c & Aon_Global_Industry_Level_4__c
        List<SIC_Code_to_Industry_Mapping__c> sicList = [Select Industry__c, Aon_Global_Industry_Level_2__c, Aon_Global_Industry_Level_4__c, Name from SIC_Code_to_Industry_Mapping__c where Name!='' Limit 2];
        System.debug('CHINTAN Pulled SIC Data: ' + sicList);
        
        //Create Account
        Account myAccount = util_sampleDataGenerator.createPeopleSoftClient('CHINTAN Apex Account', util_sampleDataGenerator.getRecordType('Account', 'Client Account Record Type').Id, false);
        myAccount.Sic = sicList[1].Name;
        System.debug('SIC Name '+sicList[1].Name);
        insert myAccount;
        System.assertNotEquals(myAccount.Id, null);
        
        //Retrieve Account
        //00078331-Ritu Sharma-Updated SOQL query to pull SIC_Code_Description__c & Aon_Global_Industry_Level_2__c
        myAccount = [Select Id, Industry, Sic,SIC_Code_Description__c,Aon_Global_Industry_Level_2__c from Account Where Id = :myAccount.Id];
        System.debug('CHINTAN Retrieved Account: ' + myAccount);
        
        //Assert
        System.assertEquals(myAccount.Industry, sicList[1].Industry__c);
        //00078331-Ritu Sharma-Checking  SIC Code Description and Aon Global Industry level 2 fields
        System.assertEquals(myAccount.SIC_Code_Description__c, sicList[1].Aon_Global_Industry_Level_4__c);
        System.assertEquals(myAccount.Aon_Global_Industry_Level_2__c, sicList[1].Aon_Global_Industry_Level_2__c);
        
        //Update SIC
        myAccount.Sic = sicList[0].Name;
        update myAccount;
        
        //Retrieve Account
        //00078331-Ritu Sharma-Updated SOQL query to pull SIC_Code_Description__c & Aon_Global_Industry_Level_2__c
        myAccount = [Select Id, Industry, Sic,SIC_Code_Description__c,Aon_Global_Industry_Level_2__c from Account Where Id = :myAccount.Id];
        
        //Assert
        System.assertEquals(myAccount.Industry, sicList[0].Industry__c);
        //00078331-Ritu Sharma-Checking  SIC Code Description and Aon Global Industry level 2 fields
        System.assertEquals(myAccount.SIC_Code_Description__c, sicList[0].Aon_Global_Industry_Level_4__c);
        System.assertEquals(myAccount.Aon_Global_Industry_Level_2__c, sicList[0].Aon_Global_Industry_Level_2__c);

    } //test_SICUpdate
    
    
    /** Test that Accounts are updated when a zipToMarket record is updated with Market Lead or Region Director
      * Chintan, September 20, 2012 */
    static testMethod void test_updateMarketLeadRegionDirector() {
        //Pull ziptoMarket record for '111' zip
        Zip_Code_to_Market_Mapping__c myZip = [Select Id, Market__c, Market_Lead__c, Market_Lead_Email__c, Region_Director__c, Region_Director_Email__c from Zip_Code_to_Market_Mapping__c Where Name = '111'];
        System.assertNotEquals(myZip.Id, null);
        
        //Create Account in '111' zip code
        Account myAccount = util_sampleDataGenerator.createAccount_Client();
        System.assertNotEquals(myAccount.Id, null);
        
        //Assert
        myAccount = [Select Id, Market_Lead_Email__c, Region_Director_Email__c from Account Where Id = :myAccount.Id];
        System.assertEquals(myAccount.Market_Lead_Email__c, myZip.Market_Lead_Email__c);
        System.assertEquals(myAccount.Region_Director_Email__c, myZip.Region_Director_Email__c);
        
        //Create two users
        User myMarketLead = util_sampleDataGenerator.createHewittStandardUser();
        System.assertNotEquals(myMarketLead.Id, null);
        User myRegionDirector = util_sampleDataGenerator.createHewittStandardUser();
        System.assertNotEquals(myRegionDirector.Id, null);
        
        Test.startTest();
        
        //Update the zipToMarket record
        myZip.Market_Lead__c = myMarketLead.Id;
        update myZip;
        
        //Assert
        myZip = [Select Id, Market__c, Market_Lead__c, Market_Lead_Email__c, Region_Director__c, Region_Director_Email__c from Zip_Code_to_Market_Mapping__c Where Id = :myZip.Id];
        System.assertEquals(myZip.Market_Lead__c, myMarketLead.Id);
        myAccount = [Select Id, Market_Lead_Email__c from Account Where Id = :myAccount.Id];
        System.assertEquals(myZip.Market_Lead_Email__c, myAccount.Market_Lead_Email__c);
                
         //Update the zipToMarket record
        myZip.Region_Director__c = myRegionDirector.Id;
        update myZip;
        
        Test.stopTest();
        
        //Assert
        myZip = [Select Id, Market__c, Market_Lead__c, Market_Lead_Email__c, Region_Director__c, Region_Director_Email__c from Zip_Code_to_Market_Mapping__c Where Id = :myZip.Id];
        System.assertEquals(myZip.Region_Director__c , myRegionDirector.Id);
        myAccount = [Select Id, Region_Director_Email__c from Account Where Id = :myAccount.Id];
        System.assertEquals(myZip.Region_Director_Email__c, myAccount.Region_Director_Email__c);
    } //test_updateMarketLeadRegionDirector
    
    
    /** Test Account and Service Provider data update on Client Assessment Survey creation
      * Chintan, October 3, 2012 */
    static testMethod void test_CasCreate() {
        Test.startTest();
        
        //Create Account
        Account myAccount = util_sampleDataGenerator.createAccount_Client();
        System.assertNotEquals(null, myAccount.Id);
        Id myAccountId = myAccount.Id;
        System.debug('CHINTAN test_CasCreate Account Created With Id: ' + myAccountId);
        
        //Create Competitor
        Competitor__c myCompetitor = new Competitor__c();
        myCompetitor.Name = 'My Apex Competitor';
        myCompetitor.Company_Status__c = 'Active';
        insert myCompetitor;
        System.assertNotEquals(null, myCompetitor.Id);
        
        //Create Client Assessment Survey tied to this Account
        Client_Assessment_Survey__c mySurvey = new Client_Assessment_Survey__c();
        mySurvey.Active_DB_Ret_PPTS__c = 5555;
        mySurvey.Active_DC_Ret_PPTS__c = 6666;
        mySurvey.Active_Health_Care_PPTS__c = 7777;
        mySurvey.DB_Administrator__c = myCompetitor.Id;
        mySurvey.DC_Administrator__c = myCompetitor.Id;
        mySurvey.HW_Administrator__c = myCompetitor.Id;
        mySurvey.DB_Contract_End_Date__c = Date.today();
        mySurvey.DC_Contract_End_Date__c = Date.today();
        mySurvey.HW_Contract_End_Date__c = Date.today();
        //mySurvey.Overall_Relationship_Status__c = 'Green';   //Removed for case 135733
        mySurvey.Year__c = '2013';
        mySurvey.Quarter__c = 'Q1';
        mySurvey.Account__c = myAccountId;
        insert mySurvey;
        System.debug('CHINTAN test_CasCreate mySurvey created: ' + mySurvey);
        System.assertNotEquals(null, mySurvey.Id);
        
        Test.stopTest();
        
        //Verify
        myAccount = [Select Id, Active_DB_Ret_PPTS__c, Active_DC_Ret_PPTS__c, Active_Health_Care_PPTS__c, Overall_Relationship_Status__c from Account Where Id = :myAccountId];
        System.assertEquals(myAccount.Active_DB_Ret_PPTS__c, 5555);
        System.assertEquals(myAccount.Active_DC_Ret_PPTS__c, 6666);
        System.assertEquals(myAccount.Active_Health_Care_PPTS__c, 7777);
        //System.assertEquals(myAccount.Overall_Relationship_Status__c, 'Green');  // Removed for case 135733
        
        Core_Service_Providers__c myProvider = [Select Defined_Benefit_Administrator__c, Defined_Contribution_Administrator__c, Health_Welfare_Administrator__c, Defined_Benefit_End_Date__c, 
            Defined_Contribution_End_Date__c, Health_Welfare_End_Date__c from Core_Service_Providers__c Where Account__c = :myAccountId];
            System.debug('TEST provider pulled: ' + myProvider);
            System.assertEquals(myProvider.Defined_Benefit_Administrator__c, myCompetitor.Id);
            System.assertEquals(myProvider.Defined_Contribution_Administrator__c, myCompetitor.Id);
            System.assertEquals(myProvider.Health_Welfare_Administrator__c, myCompetitor.Id);
            System.assertEquals(myProvider.Defined_Benefit_End_Date__c, Date.today());
            System.assertEquals(myProvider.Defined_Contribution_End_Date__c, Date.today());
            System.assertEquals(myProvider.Health_Welfare_End_Date__c, Date.today());       
       
    } //test_CasCreate
    
    
    /** Test Account and Service Provider data update on bulk Client Assessment Survey creation
      * Chintan, October 3, 2012*/
    static testMethod void test_CasCreate_bulk() {
        final integer count = 20;
        List<Id> accountIds = new List<Id> ();
        
        //Create 'count' accounts
        List<Account> myAccounts = util_sampleDataGenerator.createPeopleSoftClients('Chintan Test Account', count, true);
        System.assertEquals(myAccounts.size(), count);
        
        //Store IDs
        for (Account myAccount : myAccounts) {
            accountIds.add(myAccount.Id);
        }
        System.assertEquals(accountIds.size(), count);
        
        //Create Competitor
        Competitor__c myCompetitor = new Competitor__c();
        myCompetitor.Name = 'My Apex Competitor';
        myCompetitor.Company_Status__c = 'Active';
        insert myCompetitor;
        System.assertNotEquals(null, myCompetitor.Id);
        
        Test.startTest();
        
        //Create Client Assessment Survey tied to this Account
        List<Client_Assessment_Survey__c> mySurveys = new List<Client_Assessment_Survey__c> ();
        for (integer i=0; i<count; i++) {
            Client_Assessment_Survey__c mySurvey = new Client_Assessment_Survey__c();
            mySurvey.Active_DB_Ret_PPTS__c = 5555;
            mySurvey.Active_DC_Ret_PPTS__c = 6666;
            mySurvey.Active_Health_Care_PPTS__c = 7777;
            mySurvey.DB_Administrator__c = myCompetitor.Id;
            mySurvey.DC_Administrator__c = myCompetitor.Id;
            mySurvey.HW_Administrator__c = myCompetitor.Id;
            mySurvey.DB_Contract_End_Date__c = Date.today();
            mySurvey.DC_Contract_End_Date__c = Date.today();
            mySurvey.HW_Contract_End_Date__c = Date.today();
            //mySurvey.Overall_Relationship_Status__c = 'Yellow';  // Removed for case 135733
            mySurvey.Year__c = '2013';
            mySurvey.Quarter__c = 'Q1';
            mySurvey.Account__c = accountIds[i];
            
            mySurveys.add(mySurvey);
        }
        insert mySurveys;
        System.assertEquals(count, mySurveys.size());
        
        Test.stopTest();
        
        //Verify
        myAccounts = [Select Id, Active_DB_Ret_PPTS__c, Active_DC_Ret_PPTS__c, Active_Health_Care_PPTS__c, Overall_Relationship_Status__c from Account Where Id in :accountIds];
        System.assertEquals(myAccounts.size(), count);
        for (Account myAccount : myAccounts) {
            System.assertEquals(myAccount.Active_DB_Ret_PPTS__c, 5555);
            System.assertEquals(myAccount.Active_DC_Ret_PPTS__c, 6666);
            System.assertEquals(myAccount.Active_Health_Care_PPTS__c, 7777);
            //System.assertEquals(myAccount.Overall_Relationship_Status__c, 'Yellow'); //Removed for case 135733
        }
        
        List<Core_Service_Providers__c> myProviders = [Select Defined_Benefit_Administrator__c, Defined_Contribution_Administrator__c, Health_Welfare_Administrator__c, Defined_Benefit_End_Date__c, 
            Defined_Contribution_End_Date__c, Health_Welfare_End_Date__c from Core_Service_Providers__c Where Account__c in :accountIds];
        System.assertEquals(count, myProviders.size());
        for (Core_Service_Providers__c myProvider : myProviders) {
            System.assertEquals(myProvider.Defined_Benefit_Administrator__c, myCompetitor.Id);
            System.assertEquals(myProvider.Defined_Contribution_Administrator__c, myCompetitor.Id);
            System.assertEquals(myProvider.Health_Welfare_Administrator__c, myCompetitor.Id);
            System.assertEquals(myProvider.Defined_Benefit_End_Date__c, Date.today());
            System.assertEquals(myProvider.Defined_Contribution_End_Date__c, Date.today());
            System.assertEquals(myProvider.Health_Welfare_End_Date__c, Date.today());
        }       
    } //test_CasCreate_bulk
    
    
    
    //Test for Case 103298. Chintan
    static testMethod void testSetParentBasedOnDuns() {   
        Test.startTest();
        
        //Create Parent Account
        Account myParentAccount = new Account();
        myParentAccount.RecordTypeId = util_sampleDataGenerator.getRecordType('Account', 'Client Account Record Type').Id;
        myParentAccount.Name = 'CHINTAN Test Parent Account';
        myParentAccount.SDO_Billing_Country_Name__c = 'United States';
        myParentAccount.BillingCity = 'Chicago';
        myParentAccount.BillingState = 'IL';
        myParentAccount.BillingPostalCode = '60051';
        myParentAccount.DunsNumber = '555444333';
        insert myParentAccount;
        System.assertNotEquals(null, myParentAccount.Id);

        //Create Child Account
        Account myChildAccount = new Account();
        myChildAccount.RecordTypeId = util_sampleDataGenerator.getRecordType('Account', 'Client Account Record Type').Id;
        myChildAccount.Name = 'CHINTAN Test Child Account';
        myChildAccount.SDO_Billing_Country_Name__c = 'United States';
        myChildAccount.BillingCity = 'Chicago';
        myChildAccount.BillingState = 'IL';
        myChildAccount.BillingPostalCode = '60051';
        myChildAccount.Glb_Ult_Duns__c = '555444333';
        insert myChildAccount;
        System.assertNotEquals(null, myChildAccount.Id);
        
        //Verify
        myChildAccount = [Select Id, ParentId, Glb_Ult_Duns__c from Account Where Id = :myChildAccount.Id];
        System.debug('CPA myChildAccount is: ' + myChildAccount);
        System.assertEquals(myChildAccount.ParentId, myParentAccount.Id);
        
        //Wipe it out
        myChildAccount.Glb_Ult_Duns__c = '';
        update myChildAccount;
        
        //Verify
        myChildAccount = [Select Id, ParentId, Glb_Ult_Duns__c from Account Where Id = :myChildAccount.Id];
        System.debug('CPA myChildAccount is: ' + myChildAccount);
        System.assertEquals(myChildAccount.ParentId, null);
        
        //Reestablish
        myChildAccount.Glb_Ult_Duns__c = '555444333';
        update myChildAccount;

        Test.stopTest();
        
        //Verify
        myChildAccount = [Select Id, ParentId, Glb_Ult_Duns__c from Account Where Id = :myChildAccount.Id];
        System.debug('CPA myChildAccount is: ' + myChildAccount);
        System.assertEquals(myChildAccount.ParentId, myParentAccount.Id);
    } //testSetParentBasedOnDuns
}