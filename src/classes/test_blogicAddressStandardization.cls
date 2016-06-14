@isTest
private class test_blogicAddressStandardization {

    static testMethod void testContactBillingCountryStandardization() {
        
        // create an account
        Account account = util_sampleDataGenerator.createAccount_Client();
        System.assertNotEquals(null, account.Id);
        
        // create a contact
        Contact contact = util_sampleDataGenerator.createContact_External(account.Id);
        System.assertNotEquals(null, contact.Id);
        
        // update the contact
        contact.OtherState = 'IL';
        contact.SDO_Billing_Country_Name__c = 'United States';
        update contact;
        
        // test the sync
        contact = [select id, OtherCountry, SDO_Billing_Country_Name__c from Contact where id = :contact.Id];
        System.assertEquals(contact.OtherCountry, contact.SDO_Billing_Country_Name__c);
        
    }
}