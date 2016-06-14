@isTest
private class test_blogicServiceProviders {

    static testMethod void testServiceProviderDefault() {
        
        // create an account
        Account account = util_sampleDataGenerator.createAccount_Client();
        System.assertNotEquals(null, account.Id);
        
        // retreive service provider info
        account = [select id, 
        	(select id, name from Core_Service_Providers__r), 
        	(select id, name from Other_Service_Providers__r), 
        	(select id, name from HRO_Point_Solution_Providers__r) from Account where id = :account.Id];
        System.assertEquals(1, account.Core_Service_Providers__r.size());
        System.assertEquals(1, account.Other_Service_Providers__r.size());
        System.assertEquals(1, account.HRO_Point_Solution_Providers__r.size());
		        
        
    }
}