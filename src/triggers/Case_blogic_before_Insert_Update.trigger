/************************************************************************************************************
Author: Sunny Mohla
Trigger Name: ValidateDataforEnhancement
Purpose: This trigger will call a method in a class which will validate that date entered is properly entered
         in a sequentiall manner.
**************************************************************************************************************/
trigger Case_blogic_before_Insert_Update on Case (before insert, before update) 
{
    blogic_Case.ValidateDataSection();    
    blogic_Case.populateReportingAtt();
    
    //00109262-Ritu Sharma-This function will populate address fields and Industry field on case from the selected gateway account(s) 
    blogic_Case.populateAddressfields(trigger.New,trigger.old);

    CaseWorkflow.updateStatus(trigger.new);
}