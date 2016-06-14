trigger SalesCredit_Insert_Update_After on Sales_Credit__c (after insert,after update) 
{
    //00018625-Ritu Sharma-This function will populate the value of SalesTeamCredits field on Opportunity
    blogic_Opportunity.updateSalesTeamCreditsOnOpportunity(trigger.new,trigger.old);
}