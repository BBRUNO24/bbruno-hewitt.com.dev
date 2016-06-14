//Created for Case #137492 by Dave McChristie
trigger Client_Reference_UPDATE_AFTER on Client_Reference__c(after update) 
{
        blogic_ClientReference.SendClientRefRequestEmails(Trigger.New, Trigger.Old);
}