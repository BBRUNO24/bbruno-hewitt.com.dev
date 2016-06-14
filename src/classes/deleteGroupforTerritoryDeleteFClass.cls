/************************************************************************************************************
Author: Shreyas Ringe
Class Name: deleteGroupforTerritoryDeleteFClass

Purpose: 
Future Class being called by the following classes:
* deletePublicGroupforTerritoryDeleteClass
**************************************************************************************************************/ 

public class deleteGroupforTerritoryDeleteFClass {

	@future
	public static void publicGroupDelete(List<Id> idsOfGroupsToBeDeleted)
	{
		system.debug('idsOfGroupsToBeDeleted: ' + idsOfGroupsToBeDeleted);
		List<Group> listOfPublicGroupsToBeDeleted = new List<Group>();		
		listOfPublicGroupsToBeDeleted = [Select g.Name, g.Id From Group g where g.Id IN: idsOfGroupsToBeDeleted];
        system.debug('listOfPublicGroupsToBeDeleted: ' + listOfPublicGroupsToBeDeleted);
        
        // Case 00103100 Fix Test Classes - it causes MIXED_DML_OPERATION exception in test code 
        // Jean Hsiung, Dec. 05, 2013
        //delete listOfPublicGroupsToBeDeleted;
        if (Test.isRunningTest()) {
        	// start new context via system.runAs() for the same user for test code only
           	System.runAs(new User(Id = Userinfo.getUserId())) {
        		delete listOfPublicGroupsToBeDeleted;
           	}
        } else {
        	// in non-test code delete normally
        	delete listOfPublicGroupsToBeDeleted;
        }
		// End of Case 00103100 Fix Test Classes

	}
}