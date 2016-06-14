/**
 * Case 118546. Chintan, April 15, 2014
 */
@isTest (seeAllData = true)
private class test_batchIATMaintenance {

    static testMethod void unitTest() {
		Test.startTest();
   		batch_InternalAccountTeamMaintenance testBatch = new batch_InternalAccountTeamMaintenance();
      	ID batchprocessid = Database.executeBatch(testBatch);
		Test.stopTest();
    }
}