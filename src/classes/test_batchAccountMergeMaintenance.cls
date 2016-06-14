/**
 * Case 161986. Chintan, January 28, 2015
 */
@isTest (seeAllData = true)
private class test_batchAccountMergeMaintenance {
    static testMethod void unitTest() {
    	Account account1 = util_sampleDataGenerator.createAccount_Client();
    	Account account2 = util_sampleDataGenerator.createAccount_Client();
    	merge account1 account2;
		Test.startTest();
   		batch_AccountMergeMaintenance testBatch = new batch_AccountMergeMaintenance();
      	ID batchprocessid = Database.executeBatch(testBatch);
		Test.stopTest();
    }
}