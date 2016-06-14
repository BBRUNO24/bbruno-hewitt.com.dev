@isTest(SeeAllData=True)
public class test_blogicMarketingLead {
    //00189943-Added logic to test populateAccountLkp function
    public void test_populateAccountLkp() {
        // Create test accounts
        Account acc1 = util_sampleDataGenerator.createAccount_Client();
        Account acc2 = util_sampleDataGenerator.createAccount_Client();
        
        //Create test contacts
        Contact con1 = util_sampleDataGenerator.createContact_External(acc1.ID);      
        Contact con2 = util_sampleDataGenerator.createContact_External(acc2.ID);      
        
        Test.startTest();        
        
        //Create a marketing lead record
        Marketing_Lead__c lead = new Marketing_Lead__c();
        lead.Contact__c=con1.ID;
        lead.Status__c='Open';
        lead.Type__c='Sales Lead';
        insert lead;
        
        //Checking if account lookup has been populated
        lead=[Select ID,AccountLkp__c from Marketing_Lead__c where ID=:lead.ID];
        System.assertEquals(lead.AccountLkp__c,acc1.ID);
        
        //Changing lead contact
        lead.Contact__c=con2.ID;
        update lead;
        
        //Checking if account lookup has been updated
        lead=[Select ID,AccountLkp__c from Marketing_Lead__c where ID=:lead.ID];
        System.assertEquals(lead.AccountLkp__c,acc2.ID);
        
        Test.stopTest(); 
    }        
}