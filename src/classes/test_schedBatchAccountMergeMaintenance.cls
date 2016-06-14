/* Chintan, March 02, 2015 */
@isTest (seeAllData = true)
private class test_schedBatchAccountMergeMaintenance {

   	static testMethod void myUnitTest() {
   		Test.startTest();    
        // Schedule the batch job    
        String jobId = System.schedule('batch_AccountMergeMaintenance', '0 0 13 * * ?', new sched_batch_AccountMergeMaintenance());    
        Test.stopTest();
    }
}