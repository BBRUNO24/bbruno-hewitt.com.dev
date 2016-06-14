/************************************************************************************************************
Author: Shreyas Ringe
Class Name: createNewPublicGroupForNewTerritoryClass
Trigger using this class: createNewPublicGroupForNewTerritory
Purpose: 
Create a new public groups for new territories. If a territory has a parent territory, then also copy the 
group members of parent territory public group to child territory public group.
**************************************************************************************************************/ 

public class createNewPublicGroupForNewTerritoryClass {
		
	public static void createPublicGroup(){
			
		Territory__c[] newTerrList = (Territory__c[])Trigger.new;
		list<Group> groupInsert = new list<Group>();
		list<String> territoryNameList = new list<String>();
		list<String> newTerrIdList = new list<String>();
 		list<String> parentTerritoryMemberUserIdList = new list<String>();
 		list<String> childGroupIdList = new list<String>();
    	list<String> parentTerritoryIdList = new list<String>();
    	list<Territory_Member__c> parentTerritoryMemberList = new list<Territory_Member__c>();
       
        for(integer i=0;i<newTerrList.size();i++)
        {   
             	 territoryNameList.add(newTerrList[i].Public_Group_Name__c);
             	 newTerrIdList.add(newTerrList[i].Id);
                 Group newGroup = new Group (Name = newTerrList[i].Public_Group_Name__c);
                 groupInsert.add(newGroup);
                 
                 //if parent exists  *********************
                 if(newTerrList[i].Parent_Territory__c != null)
                 {
                 	parentTerritoryIdList.add(newTerrList[i].Parent_Territory__c);
                 }                
                 //***************************************
        }
        
        try {
                insert groupInsert;
            }
            	catch(exception e1){}
            	
		
		//if parent exists  *********************
		if(parentTerritoryIdList.size()>0)
		{
		parentTerritoryMemberList = [Select t.User__c, t.Territory__c, t.Id From Territory_Member__c t where t.Territory__c IN: parentTerritoryIdList];
		
		system.debug('parentTerritoryIdList: ' + parentTerritoryIdList);
    	system.debug('parentTerritoryMemberList: ' + parentTerritoryMemberList);
		}
		//***************************************

		
		list<Group> groupSelect = [Select g.Name, g.Id From Group g where g.Name in: territoryNameList]; 
		system.debug('capturing newly created public groups: ' + groupSelect);
		system.debug('capturing the number of newly created public groups: ' + groupSelect.size());
		

		list<Territory__c> newTerr = [Select t.Public_Group_Name__c, t.Name, t.Id, t.Public_Group_Id__c, t.Parent_Territory__c From Territory__c t where t.id IN: newTerrIdList];
		system.debug('capturing newly created terr.: ' + newTerr);
		system.debug('capturing the size of newly created terr.: ' + newTerr.size());
		
		for(integer i=0;i<newTerr.size();i++)
		{
			for(integer j=0;j<groupSelect.size();j++)
			{
				if(newTerr[i].Public_Group_Name__c == groupSelect[j].Name)										
				{
					newTerr[i].Public_Group_Id__c = groupSelect[j].Id;
				}

			}			
		}
		
		try { 
		globalUtility.territoryInsertOnlyCheck = false;
		update newTerr;
		}
		catch(exception e3){}
		
		
		//if parent exists  *********************
		
		if(parentTerritoryIdList.size()>0)
		{
			system.debug('parent exists ');
			for(integer i=0;i<newTerr.size();i++)
			{
				for(integer j=0;j<parentTerritoryMemberList.size();j++)
				{
					if(newTerr[i].Parent_Territory__c == parentTerritoryMemberList[j].Territory__c)
					{
						system.debug('match found');
						parentTerritoryMemberUserIdList.add(parentTerritoryMemberList[j].User__c);
						childGroupIdList.add(newTerr[i].Public_Group_Id__c);												
					}
				}
			}

			system.debug('parentTerritoryMemberUserIdList: ' + parentTerritoryMemberUserIdList);
			system.debug('childGroupIdList: ' + childGroupIdList);
			
		// future class being called
    	createNewTerrMembersAsGroupMembersFClass.createGroupMembers(parentTerritoryMemberUserIdList, childGroupIdList);
		}
		//***************************************
        		
		}
}