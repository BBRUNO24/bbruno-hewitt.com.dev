public without sharing class blogic_MarketingLead {    
    //00189943-Added logic to establish lookup relationship between lead and account
    public static void populateAccountLkp(List<Marketing_Lead__c> leads) {
        for(Marketing_Lead__c lead: leads) {
            lead.AccountLkp__c=lead.Account_ID__c;
        }
    }
}