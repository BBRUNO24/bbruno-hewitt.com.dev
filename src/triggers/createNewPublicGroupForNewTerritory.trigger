/************************************************************************************************************
Author: Shreyas Ringe
Trigger Name: createNewPublicGroupForNewTerritory
Purpose: 
Create a new public groups for new territories. If a territory has a parent territory, then also copy the 
group members of parent territory public group to child territory public group.          
**************************************************************************************************************/ 

trigger createNewPublicGroupForNewTerritory on Territory__c (after insert) {
	
	createNewPublicGroupForNewTerritoryClass.createPublicGroup();

}