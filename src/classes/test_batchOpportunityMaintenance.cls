@isTest
private class test_batchOpportunityMaintenance {
    static testMethod void unitTest() {
		Test.startTest();
   			batch_OpportunityMaintenance testBatch = new batch_OpportunityMaintenance();
      		ID batchprocessid = Database.executeBatch(testBatch);
		Test.stopTest();
		
    }
}