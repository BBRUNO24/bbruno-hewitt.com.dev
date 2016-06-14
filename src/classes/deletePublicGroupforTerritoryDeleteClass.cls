/************************************************************************************************************
Author: Shreyas Ringe
Class Name: deletePublicGroupforTerritoryDeleteClass
Trigger using this class: deletePublicGroupforTerritoryDelete
Purpose: 
Whenever any territory is deleted, that corresponding public group will also be deleted. If the territory being 
deleted is already a parent of 1 or more territories then it should not be deleted 
**************************************************************************************************************/ 

public class deletePublicGroupforTerritoryDeleteClass {

	public static void checkListBeforeTerritoryDelete()
	{
		Territory__c[] oldTerrList = (Territory__c[])Trigger.old;
		List<Territory__c> terrSelect = new List<Territory__c>();
		List<String> parentTerritoryIds = new List<String>();
		List<String> listOfPublicGroupIdsToBeDeleted = new List<String>();

		
		for(integer i=0;i<oldTerrList.size();i++)
        {   
             parentTerritoryIds.add(oldTerrList[i].Id); 
        }
        
        system.debug('parentTerritoryIds: ' + parentTerritoryIds);
        
       	terrSelect = [Select t.Parent_Territory__c, t.Name, t.Id From Territory__c t where t.Parent_Territory__c IN: parentTerritoryIds];
       	system.debug('terrSelect: ' + terrSelect);
		
		for(integer i=0;i<oldTerrList.size();i++)
        {   
        	for(integer j=0;j<terrSelect.size();j++) 
        	{
        		if(oldTerrList[i].Id == terrSelect[j].Parent_Territory__c)
        		{
        			system.debug('Match Found');
        			oldTerrList[i].adderror('This Territory is a parent of the one or more Territories. Please see the related list "Related Territories" and delete all the child Territories prior to deleting this record.');
        			break;      	
        		}        		
        	}
        		
        }

       
       for(integer i=0;i<oldTerrList.size();i++)
        {   
             listOfPublicGroupIdsToBeDeleted.add(oldTerrList[i].Public_Group_Id__c); 
        }
        system.debug('listOfPublicGroupIdsToBeDeleted: ' + listOfPublicGroupIdsToBeDeleted);
        
        // future class being called
        deleteGroupforTerritoryDeleteFClass.publicGroupDelete(listOfPublicGroupIdsToBeDeleted);
               
	}
}