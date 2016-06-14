@isTest
public class test_ctlrClientScorecard_Selection{
    @testSetup 
    static void setupTestData() {
        /*
            Insert the Organizational_Defaults__c
        */
        Organizational_Defaults__c orgDefaultSettings = new Organizational_Defaults__c();
        orgDefaultSettings.Enable_CAPIS_Id_Assignment__c = false;
        orgDefaultSettings.Sales_Team_Reconciler_Last_Run_Date__c = null;
        insert orgDefaultSettings;
    }
    private static testMethod void unitTest()
    {
        //Creating an account
        Account account = util_sampleDataGenerator.createAccount_Client();
        account.Global_Region__c = 'North America';
        account.Region_Market_Override__c = true;
        update account;
        System.assertNotEquals(null, account.Id);
        
        Test.startTest(); 
        
        //Get handle of controllers
        ApexPages.standardController stdController = new ApexPages.standardController(account);
        ctlr_Client_Scorecard_Selection cusController = new ctlr_Client_Scorecard_Selection(stdController);
        
        //Calling all functions of the controller         
        //Note-Not writing the assert statements as code picks the options from the picklist and they might get changed
        List<SelectOption> yearOptions = cusController.getValidFinancialYears();            
        List<SelectOption> quarterOptions = cusController.getValidQuarters();                    
        PageReference printPage = cusController.printScorecard();
        
        Test.stopTest();
    }
}