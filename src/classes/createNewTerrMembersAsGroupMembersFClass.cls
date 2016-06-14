/************************************************************************************************************
Author: Shreyas Ringe
Class Name: createNewTerrMembersAsGroupMembersFClass

Purpose: 
Future Class being called by the following classes:
* createNewPublicGroupForNewTerritoryClass
* createNewTerrMembersAsGroupMembersClass
**************************************************************************************************************/ 

global class createNewTerrMembersAsGroupMembersFClass {
	
	@future
    public static void createGroupMembers(List<Id> terrMemberUserId, List<Id> terrGroupId){
    
    	list<GroupMember> newGroupMemberList = new list<GroupMember>();
   		system.debug('-------terrMemberUserId:' + terrMemberUserId);
		system.debug('-------terrGroupId:' + terrGroupId);
		
		for(integer i=0;i<terrMemberUserId.size();i++)
		{
		GroupMember newGroupMember = new GroupMember(UserOrGroupId = terrMemberUserId[i], GroupId = terrGroupId[i]);
		 
    	newGroupMemberList.add(newGroupMember);
		}
		
		system.debug('-----------newGroupMemberList:' + newGroupMemberList);
		
		try
		{ insert newGroupMemberList;
		}
		catch(exception e){}

	}

}