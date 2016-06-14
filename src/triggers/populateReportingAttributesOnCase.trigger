/************************************************************************************************************
Author: Shreyas Ringe
Trigger Name: populateReportingAttributesOnCase
Purpose: 
The reporting attributes of the case are copied from the similar reporting attribute fields
of the contact record selected in the 'Contact Name' field.         
**************************************************************************************************************/
trigger populateReportingAttributesOnCase on Case (before insert, before update) 
{
    populateReportingAttributesOnCaseClass.populateReportingAtt();
}