@isTest
private class test_ctlrCreateCaseCommentChatter {

    static testMethod void myUnitTest() {
        System.debug('creating test admin user...');
        
        User adminUser = util_sampleDataGenerator.createAdminUser();
        //adminUser.Reporting_Country__c = 'Australia';
        adminUser.Reporting_Country__c = 'United States';
        update(adminUser);
        Id caseRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Enhancement Request').getRecordTypeId();


        Test.startTest();

        System.runAs(adminUser) {
            System.debug('Case Creation...');
            Case test1 = new Case();
            test1.recordTypeId = caseRTId;
            test1.status = 'Submitted';
            test1.Type = 'Enhancement Request';
            test1.Enhancement_Request_Type__c = 'Add a Field';
            test1.Function_Area__c = 'Cases';
            test1.Subject = 'Test Case';
            Account account1 = util_SampleDataGenerator.createAccount_Client();
            Contact contact1 = util_SampleDataGenerator.createContact_Internal(account1.id);            
            test1.contact = contact1;
            insert test1;
          
            ApexPages.StandardController sc1 = new ApexPages.StandardController(test1);
            ctlr_CreateCaseCommentChatter ce1 = new ctlr_CreateCaseCommentChatter(sc1);

            ce1.theComment.commentbody = 'TestTestTest';
            
            PageReference pe2 = ce1.createComment();
        }
        Test.stopTest();
    } 
}