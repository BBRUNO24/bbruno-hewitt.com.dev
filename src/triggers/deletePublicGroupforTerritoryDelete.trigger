/************************************************************************************************************
Author: Shreyas Ringe
Trigger Name: deletePublicGroupforTerritoryDelete
Purpose: 
Whenever any territory is deleted, that corresponding public group will also be deleted. If the territory being 
deleted is already a parent of 1 or more territories then it should not be deleted 
**************************************************************************************************************/ 

trigger deletePublicGroupforTerritoryDelete on Territory__c (before delete) {

	deletePublicGroupforTerritoryDeleteClass.checkListBeforeTerritoryDelete();
}