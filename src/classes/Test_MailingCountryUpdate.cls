/**
 * test class for trigger: mailingCountryUpdate 
 */
@isTest
private class Test_MailingCountryUpdate 
{
    static testMethod void mailingCountryUpdate() 
    {
        Account A1 = new Account(name='testaccount', SDO_Billing_Country_Name__c = 'INDIA', Sic = '0111', BillingPostalCode = '521888');
        Insert A1;
        
        Contact con = new Contact();
        //con.RecordTypeId = rt.Id;
        con.LastName = 'testLast';
        con.FirstName = 'testFirst';
        con.AccountId = A1.Id; 
        con.SDO_Mailing_Country_Name__c = 'India';
        insert con;
    }
}