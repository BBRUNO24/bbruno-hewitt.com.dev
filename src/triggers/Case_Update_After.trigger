trigger Case_Update_After on Case (After Update) 
{
    //00109262-Ritu Sharma-Update IsConverted flag in Gateway Account
    blogic_case.updateGatewayAccounts(Trigger.New,Trigger.Old);
}