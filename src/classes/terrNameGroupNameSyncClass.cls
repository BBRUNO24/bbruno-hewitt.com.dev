/************************************************************************************************************
Author: Shreyas Ringe
Class Name: terrNameGroupNameSyncClass
Trigger using this class: terrNameGroupNameSync
Purpose: 
Keeps the territory name and the corresponding public group in sync.
**************************************************************************************************************/ 

public class terrNameGroupNameSyncClass {

	public static void methodForSync()
	{
		Territory__c[] newTerrList = (Territory__c[])Trigger.new;
		Territory__c[] oldTerrList = (Territory__c[])Trigger.old;
		Map<String,String> territoryNameGroupNameMap = new Map<String,String>();
		List<String> publicGroupIdList = new List<String>();
		List<Group> groupsToBeUpdated = new List<Group>();
		
		for(integer i=0;i<newTerrList.size();i++)
		{
			if(newTerrList[i].Name != oldTerrList[i].Name)
			{
				territoryNameGroupNameMap.put(newTerrList[i].Public_Group_Id__c, newTerrList[i].Public_Group_Name__c);
				publicGroupIdList.add(newTerrList[i].Public_Group_Id__c);
			}
		}
		
			system.debug('territoryNameGroupNameMap: ' + territoryNameGroupNameMap);
			system.debug('publicGroupIdList: ' + publicGroupIdList);
		
		groupsToBeUpdated = [Select g.Name, g.Id From Group g where g.Id IN: publicGroupIdList];
		system.debug('groupsToBeUpdated: ' + groupsToBeUpdated);
		
		for(integer i=0;i<publicGroupIdList.size();i++)
		{
			groupsToBeUpdated[i].Name = territoryNameGroupNameMap.get(groupsToBeUpdated[i].Id);
		}
		
		update groupsToBeUpdated;
	}
}