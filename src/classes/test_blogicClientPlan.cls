@isTest(SeeAllData=true)
private class test_blogicClientPlan {
	//Test auto check of Client Satisfaction Survey Completed checkbox When a Client Plan is created
    static testMethod void test_CSScheckbox() {
        //Create Account
        Account account1 = util_SampleDataGenerator.createAccount_Client();        
        System.assertNotEquals(null, account1.Id);
        
        Test.startTest();
        
        //Create Client Satisfaction Survey record
        Client_Satisfaction_Survey__c survey = new Client_Satisfaction_Survey__c ();
        survey.Account__c = account1.Id;
        survey.Survey_Year__c = '2013';
        insert survey;
        System.assertNotEquals(null, survey.Id);
        System.debug('CPA Test Account ID is:' + account1.Id);
        
        //Create a Client Plan
        Annual_Account_Plan__c plan = new Annual_Account_Plan__c ();
        plan.Account__c = account1.Id;
        plan.Account_Plan_Year__c = '2013';
        insert plan;
        System.assertNotEquals(null, plan.Id);
        
        //Verify
        plan = [Select Id, Client_Satisfaction_Survey_Completed__c from Annual_Account_Plan__c Where Id = :plan.Id];
        System.assertEquals(true, plan.Client_Satisfaction_Survey_Completed__c);
        
        //Delete CSS Record and plan
        delete survey;
        delete plan;
        
        //Create another plan
        plan = new Annual_Account_Plan__c ();
        plan.Account__c = account1.Id;
        plan.Account_Plan_Year__c = '2013';
        insert plan;
        System.assertNotEquals(null, plan.Id);
        
        Test.stopTest();
        
        //Verify
        plan = [Select Id, Client_Satisfaction_Survey_Completed__c from Annual_Account_Plan__c Where Id = :plan.Id];
        System.debug('plan: ' + plan);
        System.assertEquals(false, plan.Client_Satisfaction_Survey_Completed__c);
    } //test_CSScheckbox
    
    
    //Test auto check of Client Satisfaction Survey Completed checkbox When a Client Sat Survey is created
    static testMethod void test_planUpdate() {
        //Create Account
        Account account1 = util_SampleDataGenerator.createAccount_Client();        
        System.assertNotEquals(null, account1.Id);
        
        Test.startTest();
        
        //Create a Client Plan
        Annual_Account_Plan__c plan = new Annual_Account_Plan__c ();
        plan.Account__c = account1.Id;
        plan.Account_Plan_Year__c = '2013';
        insert plan;
        System.assertNotEquals(null, plan.Id);
        
        //Verify
        plan = [Select Id, Client_Satisfaction_Survey_Completed__c from Annual_Account_Plan__c Where Id = :plan.Id];
        System.debug('plan: ' + plan);
        System.assertEquals(false, plan.Client_Satisfaction_Survey_Completed__c);
        
        //Create Client Satisfaction Survey record
        Client_Satisfaction_Survey__c survey = new Client_Satisfaction_Survey__c ();
        survey.Account__c = account1.Id;
        survey.Survey_Year__c = '2013';
        insert survey;
        System.assertNotEquals(null, survey.Id);
        System.debug('CPA Test Account ID is:' + account1.Id);
        
        //Verify
        plan = [Select Id, Client_Satisfaction_Survey_Completed__c from Annual_Account_Plan__c Where Id = :plan.Id];
        System.assertEquals(true, plan.Client_Satisfaction_Survey_Completed__c);
        
        Test.stopTest();
    } //test_planUpdate
    
    
    //Test that Client Promise Completion Date is autoset
    static testMethod void test_completionDate() {
    	//Create Account
        Account account = util_SampleDataGenerator.createAccount_Client();        
        System.assertNotEquals(null, account.Id);
        
        
    	Test.startTest();
        
        //Create a Client Plan
        Annual_Account_Plan__c plan = new Annual_Account_Plan__c ();
        plan.Account__c = account.Id;
        plan.Account_Plan_Year__c = '2014';
        plan.Discover_Meeting_Completed__c = true;
        plan.Deliver_Meetings_Completed__c = true;
        plan.Executive_Sponsor_Meetings_Completed__c = true;
        insert plan;
        System.assertNotEquals(null, plan.Id);
        
        //Verify
        plan = [Select Id, Client_Promise_Completion_Date__c from Annual_Account_Plan__c Where Id = :plan.Id];
        System.debug('plan: ' + plan);
        System.assertEquals(null, plan.Client_Promise_Completion_Date__c);
        
        //Update plan
        plan.Client_Satisfaction_Survey_Completed__c = true;
        update plan;
        
        //Verify
        plan = [Select Id, Client_Promise_Completion_Date__c from Annual_Account_Plan__c Where Id = :plan.Id];
        System.debug('plan: ' + plan);
        System.assertNotEquals(null, plan.Client_Promise_Completion_Date__c);
        
        //update
        plan.Client_Satisfaction_Survey_Completed__c = false;
        update plan;
        
        //Verify
        plan = [Select Id, Client_Promise_Completion_Date__c from Annual_Account_Plan__c Where Id = :plan.Id];
        System.debug('plan: ' + plan);
        System.assertEquals(null, plan.Client_Promise_Completion_Date__c);
        
        Test.stopTest();
    } //test_completionDate
}