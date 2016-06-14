trigger MarketingLead_Insert_Update_Before on Marketing_Lead__c (before insert, before update) {
    //00189943-Added logic to establish lookup relationship between lead and account
    blogic_MarketingLead.populateAccountLkp(trigger.new);
}