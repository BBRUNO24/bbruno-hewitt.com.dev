/**
test Class for trigger: zipCodeToMarketMapping 
 */
@isTest
private class test_zipCodeToMarketMapping {

    static testMethod void testZipCodeMappingMethod() {
        
        //Non-Canada countries
        //Account A1 = new Account(name='testaccount', ARSaccountleader_lookup__c = '00530000004Rb9M', ACWaccountLeader_lookup__c = '00530000004Rb9M', SDO_Billing_Country_Name__c = 'INDIA', Sic = '0111', BillingPostalCode = '521888', BillingState = 'IL');
        //Insert A1;
        
        //Account A1_1 = [Select a.Sic, a.Name, a.Id From Account a where a.Id =: A1.Id];
        //A1_1.BillingPostalCode = '123456';
        //update A1_1;
        
        //Account A1_2 = [Select a.Sic, a.Name, a.Id From Account a where a.Id =: A1.Id];
        //A1_2.BillingPostalCode = '11111';
        //update A1_2;
        
        //Account B1 = new Account(name='testaccount', BillingPostalCode = '11111', ARSaccountleader_lookup__c = '00530000004Rb9M', ACWaccountLeader_lookup__c = '00530000004Rb9M', SDO_Billing_Country_Name__c = 'INDIA', Sic = null, BillingState = 'IL');
        //Insert B1;
        
        
        //Canada              
        //Account A2 = new Account(name='testaccount', ARSaccountleader_lookup__c = '00530000004Rb9M', ACWaccountLeader_lookup__c = '00530000004Rb9M', SDO_Billing_Country_Name__c = 'CANADA', Sic = '0111', BillingState = 'ON', BillingCity = 'Ottawa',BillingPostalCode = '521888');
        //Insert A2;
        
        // commented out by Larry Jovanovic on 5/3/2011 as these lines conflict with the validation rule that 
        // requires a valid province value for all candian accounts
        //Account A2_1 = [Select a.Sic, a.Name, a.Id From Account a where a.Id =: A2.Id];
        //A2_1.BillingState = 'PE';
        //update A2_1;
        
        //Account A2_2 = [Select a.Sic, a.Name, a.Id From Account a where a.Id =: A2.Id];
        //A2_2.BillingState = null;
        //update A2_2;
        
        //Account B2 = new Account(name='testaccount', ARSaccountleader_lookup__c = '00530000004Rb9M', ACWaccountLeader_lookup__c = '00530000004Rb9M', SDO_Billing_Country_Name__c = 'CANADA', BillingState = null,BillingPostalCode = '521888');
        //Insert B2;
        

    }
}