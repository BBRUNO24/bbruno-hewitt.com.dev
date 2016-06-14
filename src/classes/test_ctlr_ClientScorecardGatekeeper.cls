@isTest
public class test_ctlr_ClientScorecardGatekeeper {
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
            ctlr_ClientScorecardGatekeeper cusController = new ctlr_ClientScorecardGatekeeper(stdController);
            
            //Handle to the Apex page          
            PageReference pageRef = Page.Client_Scorecard_Gatekeeper;
            
            //Check access
            PageReference newPageRef = cusController.checkAccess(); 
            
            //Verify by checking the URL of the redirected page
            System.debug('Original URL: '+(String)pageRef.getURL()+' Redirected URL: '+(String)newPageRef.getURL());
            System.assertEquals(true, ((String)newPageRef.getURL()).contains('Client_Scorecard_Selection')); 

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
            

            dataViewSettings.Revenue_Visibility_Override__c = false;
            upsert dataViewSettings;

            account2 = util_SampleDataGenerator.createAccount_Client();
            account2.Market__c = 'New York';
            account2.Region_Market_Override__c = true;
            update account2;
            //Run as this user
            System.runAs(testUser) {
                
                System.assertNotEquals(null, account2.Id);  
                System.debug('CPA account2 Market: ' + account2.Market__c);

                //Reset
                stdController = new ApexPages.standardController(account2);
            	cusController = new ctlr_ClientScorecardGatekeeper(stdController);
                pageRef = Page.Client_Scorecard_Gatekeeper;

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
            	cusController = new ctlr_ClientScorecardGatekeeper(stdController);
                pageRef = Page.Client_Scorecard_Gatekeeper;

                //Check access
                newPageRef = cusController.checkAccess();
                
                //Verify
                System.assertEquals(true, ((String)newPageRef.getURL()).contains('Client_Scorecard_Selection'));
            }
            
            //Delete the Internal Account Team Record
            delete iat;
            
            //Verify No access
            System.runAs(testUser) {
                //Reset
                stdController = new ApexPages.standardController(account2);
            	cusController = new ctlr_ClientScorecardGatekeeper(stdController);
                pageRef = Page.Client_Scorecard_Gatekeeper;

                //Check access
                newPageRef = cusController.checkAccess();
                
                //Verify
                System.assertEquals(null, newPageRef);
            }
            
            //Now add the user to the Revenue Access List
            Zip_Code_to_Market_Mapping__c zip = [Select Id from Zip_Code_to_Market_Mapping__c Where Market__c = 'New York' Limit 1];
            System.assertNotEquals(null, zip.Id); 
            
            Revenue_Access_List_Member__c ram = new Revenue_Access_List_Member__c ();
            ram.Zip_to_Market__c = zip.Id;
            ram.User__c = testUser.Id;
            insert ram;

            System.assertNotEquals(null, ram.Id);
            
            Account acc = [SELECT Id, Market__c FROM Account where Id = :account2.Id LIMIT 1];
            acc.Market__c = 'New York';
            update acc;
            acc = [SELECT Id, Market__c FROM Account where Id = :account2.Id LIMIT 1];
            System.assertEquals('New York', acc.Market__c, 'It should have a value of New York in the Market');

            //Verify access
            System.runAs(testUser) {
                //Reset
                stdController = new ApexPages.standardController(acc);
            	cusController = new ctlr_ClientScorecardGatekeeper(stdController);
                pageRef = Page.Client_Scorecard_Gatekeeper;

                //Check access
                newPageRef = cusController.checkAccess();
                
                //Verify
                System.assertEquals(true, ((String)newPageRef.getURL()).contains('Client_Scorecard_Selection'));
            }

        Test.stopTest();
    } //test_checkAccess
}