@isTest
private class test_schedBatchSalesTeamReconciler {

    static testMethod void myUnitTest() {
         Test.startTest();    
         
         // Schedule the test job    
         String jobId = System.schedule('batch_SalesTeamReconciler', '0 0 13 * * ?', new sched_batchSalesTeamReconciler());    
         	
         Test.stopTest();
    }
}