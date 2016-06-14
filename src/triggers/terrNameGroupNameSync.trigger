/************************************************************************************************************
Author: Shreyas Ringe
Trigger Name: terrNameGroupNameSync
Purpose: 
Keeps the territory name and the corresponding public group in sync.
**************************************************************************************************************/ 

trigger terrNameGroupNameSync on Territory__c (after update) {
     
	if(globalUtility.territoryInsertOnlyCheck == false) return;
	globalUtility.territoryInsertOnlyCheck = true;
	
	terrNameGroupNameSyncClass.methodForSync();
}