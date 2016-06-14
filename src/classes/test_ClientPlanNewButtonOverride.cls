@isTest
private class test_ClientPlanNewButtonOverride {
    @testSetup static void setupClientData() {
       final String REGION = 'Asia Pacific';
       
       /*
            Insert the Organizational_Defaults__c
       */
        Organizational_Defaults__c orgDefaultSettings = new Organizational_Defaults__c();
        orgDefaultSettings.Enable_CAPIS_Id_Assignment__c = false;
        insert orgDefaultSettings;

        /*
            Inser the Client_Plan_Settings__c
        */
        Client_Plan_Settings__c clientPlanSettings = new Client_Plan_Settings__c();
        clientPlanSettings.Global_Region__c = REGION;
        clientPlanSettings.Account_Field_Id__c = '12345';
        clientPlanSettings.Name = REGION;
        insert clientPlanSettings;

        /*
            Insert the Account
        */
        Account account = util_SampleDataGenerator.createAccount_Client();
        account.Global_Region__c = REGION;
        account.SDO_Billing_Country_Name__c = 'China';
        update account;
        System.assertEquals('Asia Pacific', account.Global_Region__c, 'It should return an global region of Asia');

    }

    static testMethod void testAsiaRegion() {
    	//Query the account we created in the testSetup
        List<Account> accounts = [SELECT Id, Global_Region__c FROM Account];
        System.assertEquals(1, accounts.size(), 'It should return one account');
        Account acc = accounts[0];
        System.assertEquals('Asia Pacific', acc.Global_Region__c, 'It should return an global region of Asia');
        
        Test.startTest();
        
            //Handle to the Apex page          
            PageReference pageRef = Page.ClientPlanNewButtonOverride;
            pageRef.getParameters().put('retURL', '/' + acc.Id);
            
            Test.setCurrentPage(pageRef);
            
            //Client Plan
            Annual_Account_Plan__c plan = new Annual_Account_Plan__c();
            plan.Account__c = acc.Id;
            insert plan;

            System.assertNotEquals(null, plan.Id, 'It should insert the plan');
            
            //Get controller handles
            ApexPages.standardController stdController = new ApexPages.standardController(plan);
            ctlr_ClientPlanNewButtonOverride cusController = new ctlr_ClientPlanNewButtonOverride(stdController);
            pageref = cusController.init();
        
        Test.stopTest();
    }

    static testMethod void testBackButton() {
        //Query the account we created in the testSetup
        List<Account> accounts = [SELECT Id, Global_Region__c FROM Account];
        System.assertEquals(1, accounts.size(), 'It should return one account');
        Account acc = accounts[0];
        System.assertEquals('Asia Pacific', acc.Global_Region__c, 'It should return an global region of Asia');
        
        Test.startTest();
        
            //Handle to the Apex page          
            PageReference pageRef = Page.ClientPlanNewButtonOverride;
            pageRef.getParameters().put('retURL', '/' + acc.Id);
            
            Test.setCurrentPage(pageRef);
            
            //Client Plan
            Annual_Account_Plan__c plan = new Annual_Account_Plan__c();
            plan.Account__c = acc.Id;
            insert plan;

            System.assertNotEquals(null, plan.Id, 'It should insert the plan');
            
            //Get controller handles
            ApexPages.standardController stdController = new ApexPages.standardController(plan);
            ctlr_ClientPlanNewButtonOverride cusController = new ctlr_ClientPlanNewButtonOverride(stdController);
            pageref = cusController.returnBack();
 
        
        Test.stopTest();
    }
}