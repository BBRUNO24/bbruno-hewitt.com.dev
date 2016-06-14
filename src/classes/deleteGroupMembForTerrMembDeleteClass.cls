/************************************************************************************************************
Author: Shreyas Ringe
Class Name: deleteGroupMembForTerrMembDeleteClass
Trigger using this class: deleteGroupMembForTerrMembDelete
Purpose: 
Whenever any territory member is deleted from a territory, that user will be deleted from the corresponding 
public group. 
**************************************************************************************************************/ 

public class deleteGroupMembForTerrMembDeleteClass {
	
	public static void checkListBeforeTerritoryMemberDelete()
	{
		Territory_Member__c[] oldTerrMemberList = (Territory_Member__c[])Trigger.old;
		list<String> parentTerritoryGroupIdList = new list<String>();
		list<String> territoryMemberUserIdList = new list<String>();
		list<GroupMember> groupMembersSelect = new list<GroupMember>();
		list<String> IdsOfGroupMembersToBeDeleted = new list<String>();
		
		for(integer i=0;i<oldTerrMemberList.size();i++)
        {   
             parentTerritoryGroupIdList.add(oldTerrMemberList[i].Parent_Territory_Group_Id__c);
             territoryMemberUserIdList.add(oldTerrMemberList[i].User__c);              
        }

        
        groupMembersSelect = [Select g.UserOrGroupId, g.Id, g.GroupId From GroupMember g where g.GroupId IN: parentTerritoryGroupIdList];        
        system.debug('groupMembersSelect: ' + groupMembersSelect);
        system.debug('sizeofgroupMembersSelect: ' + groupMembersSelect.size());
        
        for(integer i=0;i<parentTerritoryGroupIdList.size();i++)
        {
        	for(integer j=0;j<groupMembersSelect.size();j++)
        	{

        	if( (parentTerritoryGroupIdList[i] == groupMembersSelect[j].GroupId) && (territoryMemberUserIdList[i] == groupMembersSelect[j].UserOrGroupId) )
        	{
        		system.debug('Match found');
        		IdsOfGroupMembersToBeDeleted.add(groupMembersSelect[j].Id);
        	}
        	        		
        	}
        }
        
        system.debug('IdsOfGroupMembersToBeDeleted: ' + IdsOfGroupMembersToBeDeleted);
         
        deleteGroupMembForTerrMembDeleteFClass.publicGroupMemberDelete(IdsOfGroupMembersToBeDeleted);
	}

}