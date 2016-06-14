/************************************************************************************************************
Author: Shreyas Ringe
Class Name: deleteGroupMembForTerrMembDeleteFClass
Purpose: 
Future Class being called by the following classes:
* deleteGroupMembForTerrMembDeleteClass
**************************************************************************************************************/ 

public class deleteGroupMembForTerrMembDeleteFClass {
	
	@future
	public static void publicGroupMemberDelete(List<Id> idsOfGroupMembersToBeDeleted)
	{
		system.debug('idsOfGroupMembersToBeDeleted: ' + idsOfGroupMembersToBeDeleted);
		List<GroupMember> listOfPublicGroupMembersToBeDeleted = new List<GroupMember>();		
		listOfPublicGroupMembersToBeDeleted = [Select g.Id From GroupMember g where g.Id IN: idsOfGroupMembersToBeDeleted];
        system.debug('listOfPublicGroupMembersToBeDeleted: ' + listOfPublicGroupMembersToBeDeleted);
        
        delete listOfPublicGroupMembersToBeDeleted;

	}

}