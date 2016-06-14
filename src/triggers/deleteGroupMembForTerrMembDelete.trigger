/************************************************************************************************************
Author: Shreyas Ringe
Trigger Name: deleteGroupMembForTerrMembDelete
Purpose: 
Whenever any territory member is deleted from a territory, that user will be deleted from the corresponding 
public group. 
**************************************************************************************************************/ 

trigger deleteGroupMembForTerrMembDelete on Territory_Member__c (before delete) {

	deleteGroupMembForTerrMembDeleteClass.checkListBeforeTerritoryMemberDelete();
}