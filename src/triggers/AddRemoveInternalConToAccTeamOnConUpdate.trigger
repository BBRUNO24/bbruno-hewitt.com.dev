/* Purpose of the trigger: When the Contact record is updated with the User ID, this Trigger fires to query for all accounts where the Contact is a 
   member of the Internal Account Team and updates the Standard Account Team by adding the user to the Account Team. 

   Also when a Contact is set from "Active" to "Inactive" this Trigger fires to query all Internal Account Team records for the contact and delete all
   records in the Internal Account Team object for the identified contact. 
*/

trigger AddRemoveInternalConToAccTeamOnConUpdate on Contact (after update) 
{  
    AddInternalConToAccTeamOnConUpdateClass.addInternalContact();
}