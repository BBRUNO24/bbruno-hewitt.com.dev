/************************************************************************************************************
Author: Shreyas Ringe
Trigger Name: populateCompetitorOnAccount
Purpose: 
Populate the field Competetor (hidden from the page) which is a Lookup to the 'Core_Service_Providers__c' object (Parent) on the account  
with the Id of the newly created 'Core_Service_Providers__c' record (child of the account object) via the related list so as to
populate the following fields on account record.           
**************************************************************************************************************/ 

trigger populateCompetitorOnAccount on Core_Service_Providers__c (before delete, after insert, after update) {

	populateCompetitorOnAccountClass.populateCompetitor(); 
}