@isTest
public class test_ctlr_AccountPlanGatekeeper { 
    @testSetup 
    static void setupClientData() {
        /*
            Insert the Organizational_Defaults__c
        */
        Organizational_Defaults__c orgDefaultSettings = new Organizational_Defaults__c();
        orgDefaultSettings.Enable_CAPIS_Id_Assignment__c = false;
        insert orgDefaultSettings;

        Zip_Code_to_Market_Mapping__c zip = new Zip_Code_to_Market_Mapping__c(Market__c='New York');
        insert zip;
    }     
    static testMethod void test_checkAccess() {
        Account_Data_View__c dataViewSettings = new Account_Data_View__c();
        dataViewSettings.Revenue_Visibility_Override__c = true;
        insert dataViewSettings;
    	//local vars
    	Account account2 = null;
        Test.startTest();  
        
        //CASE 1 - Checking for admin user access based on profile
        //Create an account
        Account account1 = util_SampleDataGenerator.createAccount_Client();        
        System.assertNotEquals(null, account1.Id);  
            
        //Get controller handles
        ApexPages.standardController stdController = new ApexPages.standardController(account1);
        ctlr_AccountPlanGatekeeper cusController = new ctlr_AccountPlanGatekeeper(stdController);
        
        //Handle to the Apex page          
        PageReference pageRef = Page.AccountPlanGatekeeper;
                
        //Check access
        PageReference newPageRef = cusController.checkAccess(); 
        
        //Verify by checking the URL of the redirected page
        System.debug('Original URL: '+(String)pageRef.getURL()+' Redirected URL: '+(String)newPageRef.getURL());
        System.assertEquals(true, ((String)newPageRef.getURL()).contains('AccountPlan')); 

        //CASE 2 - Checking for standard user
        //Create a test user
        User testUser = util_SampleDataGenerator.createUser([select id from Profile where Name = 'Standard User Profile']);      
        System.assertNotEquals(null, testUser.id);
        
        //Create an internal Contact
        Contact testContact = util_sampleDataGenerator.createContact_Internal(account1.Id);
        System.assertNotEquals(null, testContact.Id);
        
        //Link the two
        testContact.Corresponding_User_Id__c = testUser.Id;
        update testContact;
        
        account2 = util_SampleDataGenerator.createAccount_Client();
        account2.Market__c = 'New York';
        account2.Region_Market_Override__c = true;
        update account2;

        dataViewSettings.Revenue_Visibility_Override__c = false;
        update dataViewSettings;

        //Run as this user
        System.runAs(testUser) {
            //Create another account as test user doesn't have access to account1
            
            System.assertNotEquals(null, account2.Id);  
            System.debug('CPA account2 Market: ' + account2.Market__c);

            //Reset
            stdController = new ApexPages.standardController(account2);
            cusController = new ctlr_AccountPlanGatekeeper(stdController);          
            pageRef = Page.AccountPlanGatekeeper;

            //Check access
            newPageRef = cusController.checkAccess();
            
            //Verify
            System.assertEquals(null, newPageRef);
        }
        
        //Now add the user to the Internal Account Team
        Internal_Account_Team__c iat = new Internal_Account_Team__c ();
        iat.Account__c = account2.Id;
        iat.Contact__c = testContact.Id;
        iat.Contact_Role__c = 'General Support';
        insert iat;
        System.assertNotEquals(null, iat.Id);
        iat = [Select id, Account__c, Contact__c, Contact_Role__c, User_Id__c from Internal_Account_Team__c Where id = :iat.Id];
        System.debug('CPA iat is: ' + iat);
        
        //Try again
        System.runAs(testUser) {
            //Reset
            stdController = new ApexPages.standardController(account2);
            cusController = new ctlr_AccountPlanGatekeeper(stdController);          
            pageRef = Page.AccountPlanGatekeeper;

            //Check access
            newPageRef = cusController.checkAccess();
            
            //Verify
            System.assertEquals(true, ((String)newPageRef.getURL()).contains('AccountPlan'));
        }
        
        //Delete the Internal Account Team Record
        delete iat;
        
        //Verify No access
        System.runAs(testUser) {
            //Reset
            stdController = new ApexPages.standardController(account2);
            cusController = new ctlr_AccountPlanGatekeeper(stdController);          
            pageRef = Page.AccountPlanGatekeeper;

            //Check access
            newPageRef = cusController.checkAccess();
            
            //Verify
            System.assertEquals(null, newPageRef);
        }
        
        //Now add the user to the Revenue Access List
        Zip_Code_to_Market_Mapping__c zip = [Select Id, Market_Lead__c, Region_Director__c from Zip_Code_to_Market_Mapping__c Where Market__c = 'New York' Limit 1];
        System.assertNotEquals(null, zip.Id); 
        Revenue_Access_List_Member__c ram = new Revenue_Access_List_Member__c ();
        ram.Zip_to_Market__c = zip.Id;
        ram.User__c = testUser.Id;
        insert ram;
        System.assertNotEquals(null, ram.Id);
        
        //Verify access
        System.runAs(testUser) {
            //Reset
            stdController = new ApexPages.standardController(account2);
            cusController = new ctlr_AccountPlanGatekeeper(stdController);          
            pageRef = Page.AccountPlanGatekeeper;

            //Check access
            newPageRef = cusController.checkAccess();
            
            //Verify
            System.assertEquals(true, ((String)newPageRef.getURL()).contains('AccountPlan'));
        }
/*        
        //Delete the RAM record
        delete ram;
        
        //Verify No access
        System.runAs(testUser) {
            //Reset
            stdController = new ApexPages.standardController(account2);
            cusController = new ctlr_AccountPlanGatekeeper(stdController);          
            pageRef = Page.AccountPlanGatekeeper;

            //Check access
            newPageRef = cusController.checkAccess();
            
            //Verify
            System.assertEquals(null, newPageRef);
        }
        
        //Add test users as the Market Lead to the Market
        zip.Market_Lead__c = testUser.Id;
        update zip;
        
        //Verify Access for Market Lead
        System.runAs(testUser) {
            //Reset
            stdController = new ApexPages.standardController(account2);
            cusController = new ctlr_AccountPlanGatekeeper(stdController);          
            pageRef = Page.AccountPlanGatekeeper;

            //Check access
            newPageRef = cusController.checkAccess();
            
            //Verify
            System.assertEquals(true, ((String)newPageRef.getURL()).contains('AccountPlan'));
        }
*/       
        Test.stopTest();
    } //test_checkAccess
}