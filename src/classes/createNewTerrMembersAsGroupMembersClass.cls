/************************************************************************************************************
Author: Shreyas Ringe
Class Name: createNewTerrMembersAsGroupMembersClass
Trigger using this class: createNewTerrMembersAsGroupMembers
Purpose: 
All the new territory members for a particular territory will be added to the public group associated that territory.
**************************************************************************************************************/ 

public class createNewTerrMembersAsGroupMembersClass {
	
	public static void newGroupMembers() 
	{
		Territory_Member__c[] newTerrMemberList = (Territory_Member__c[])Trigger.new;
		list<String> territoryMemberUserIdList = new list<String>();
		list<String> territoryGroupIdList = new list<String>();
		list<String> territoryIdList = new list<String>();
		list<String> childTerritoryGroupIdList = new list<String>();
		list<Territory__c> territorySelect = new list<Territory__c>();
		list<Group> groupSelect = new list<Group>();
    	
    	for(integer i=0;i<newTerrMemberList.size();i++)
    	{
    			territoryMemberUserIdList.add(newTerrMemberList[i].User__c);
    			territoryGroupIdList.add(newTerrMemberList[i].Parent_Territory_Group_Id__c);
    			territoryIdList.add(newTerrMemberList[i].Territory_Id__c);		  		   		
    	} 
    	 
    	territorySelect = [Select t.Name, t.Id, t.Parent_Territory__c, t.Public_Group_Id__c From Territory__c t where t.Parent_Territory__c IN: territoryIdList];
    	system.debug('territorySelect: ' + territorySelect);
    	system.debug('sizeofterritorySelect: ' + territorySelect.size());
    	
    	
    	if(territorySelect.size()>0)
    	{
    	for(integer i=0;i<territorySelect.size();i++)
    	{
    			childTerritoryGroupIdList.add(territorySelect[i].Public_Group_Id__c);		  		   		
    	} 
    	system.debug('childTerritoryGroupIdList: ' + childTerritoryGroupIdList);

    		
    	for(integer i=0;i<newTerrMemberList.size();i++)
    	{
    		for(integer j=0;j<territorySelect.size();j++)
    		{
    			if(newTerrMemberList[i].Territory_Id__c == territorySelect[j].Parent_Territory__c)
    			{
    				system.debug('match found');
    				territoryMemberUserIdList.add(newTerrMemberList[i].User__c);
    				territoryGroupIdList.add(territorySelect[j].Public_Group_Id__c);
    			}
    		}
    	}
    		
    	}
    	
   	   	
    	// future class being called
    	createNewTerrMembersAsGroupMembersFClass.createGroupMembers(territoryMemberUserIdList, territoryGroupIdList);
    	    				
	}
	
}