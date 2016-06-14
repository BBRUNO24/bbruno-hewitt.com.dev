/************************************************************************************************************
Author: Shreyas Ringe
Trigger Name: createNewTerrMembersAsGroupMembers
Purpose: 
All the new territory members for a particular territory will be added to the public group associated that territory.
**************************************************************************************************************/ 

trigger createNewTerrMembersAsGroupMembers on Territory_Member__c (after insert) {
	
	
			createNewTerrMembersAsGroupMembersClass.newGroupMembers();
}