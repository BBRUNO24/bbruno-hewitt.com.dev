/* Chintan, April 15, 2014 */
@isTest (seeAllData = true)
private class test_schedBatchIATMaintenance {
	static testMethod void myUnitTest() {
         Test.startTest();    
         // Schedule the test job    
         String jobId = System.schedule('batch_InternalAccountTeamMaintenance', '0 0 13 * * ?', new sched_batch_IATMaintenance());    
         Test.stopTest();
    }
}