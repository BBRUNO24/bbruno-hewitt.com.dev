trigger SalesCredit_Delete_Undelete_After on Sales_Credit__c (after delete, after undelete)
{
    //00018625-Ritu Sharma-This function will populate the value of SalesTeamCredits field on Opportunity    
    blogic_Opportunity.updateSalesTeamCreditsOnOpportunity(trigger.new,trigger.old);
}