@isTest
private class test_batchOppositeOrgAccountIdProcessor {

    static testMethod void testAccountIdProcessor() {
    
    	// declare local vars
    	batch_OppositeOrgAccountIdProcessor batchjob = null;
    
    	// create test accounts
    	Account account = util_SampleDataGenerator.createAccount_Client();
    	System.assertNotEquals(null, account.id);
    	
    	Account account2 = util_SampleDataGenerator.createAccount_Client();
    	System.assertNotEquals(null, account2.id);
    	
    	// create a test user
    	User admin = util_SampleDataGenerator.createUser([select id from Profile where Name = 'System Administrator']);
    	System.assertNotEquals(null, admin.id);
    	
    	System.runAs(admin) {
    	
	    	// create entries on the correlation table
	    	Org_Integration_Record_Correlation__c correlation = new Org_Integration_Record_Correlation__c(local_record_id__c = account.Id, remote_record_id__c = account.Id);
	    	insert correlation;
	    	System.assertNotEquals(null, correlation.Id); 
	    	Org_Integration_Record_Correlation__c correlation2 = new Org_Integration_Record_Correlation__c(local_record_id__c = account2.Id, remote_record_id__c = account2.Id);
	    	insert correlation2;
	    	System.assertNotEquals(null, correlation2.Id);
	    	
    	}
    	
    	// delete account2
    	delete account2;
    	
    	// start the test
    	Test.startTest();
    	
    	// create a new batchjob instance
    	batchjob = new batch_OppositeOrgAccountIdProcessor();
    	batchjob.query = 'select id, local_record_id__c, remote_record_id__c from Org_Integration_Record_Correlation__c where CreatedById = \'' + admin.Id + '\'';
    	batchjob.testId = account.Id;
     
     	// start the batch job
     	System.debug('queueing up batch job...');
     	Database.executeBatch(batchjob);
     	System.debug('batch job queued');
     
     	// stop the test
     	System.debug('stopping the test context...');
     	Test.stopTest();
     	System.debug('test stopped');
     	
     	// verify both records were deleted from the correlation table
     	List <Org_Integration_Record_Correlation__c> correlations = [select id from Org_Integration_Record_Correlation__c where CreatedById = :admin.Id];
     	System.assert(correlations.isEmpty());
    }
}