@isTest
private class test_schedBatchOppOrgAcctIdProcessor {
 	static testMethod void unitTest() {
		Test.startTest();
		// Schedule the test job
		String jobId = System.schedule('batch_OppositeOrgAccountIdProcessor', '0 0 13 * * ?', new sched_batchOppOrgAcctIdProcessor());
		Test.stopTest();
    }
}