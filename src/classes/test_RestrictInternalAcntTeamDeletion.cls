@isTest

//Chintan Adhyapak, August 30, 2011
private class test_RestrictInternalAcntTeamDeletion {

    static testMethod void testInternalAccountTeamDeletionRights() {
        //local vars
        boolean didTestSucceed = false;
        Internal_Account_Team__c iat2 = null;
        
        Test.startTest();
        
        //Create a user with the Financial Approver Users role
        Profile finApprove = [SELECT Id FROM Profile Where Name = 'Financial Approver Users'];
        User finUser = util_sampleDataGenerator.createUser(finApprove);
        
        //Create a user with the Sales Operations Users role
        Profile salesOps = [SELECT Id FROM Profile Where Name = 'Sales Operations'];
        User opsUser = util_sampleDataGenerator.createUser(salesOps);
        
        //Run as fin approver user
        System.runAs(finUser) {
            // create an Account
            Account myAccount = util_sampleDataGenerator.createAccount_Client();
            
            //Create an Internal Contact
            Contact myIntContact = util_sampleDataGenerator.createContact_Internal('');
            
            //Add the internal contact to the account in a financial role
            Internal_Account_Team__c iat1 = util_sampleDataGenerator.createInternalAccountTeam(myAccount.Id, myIntContact.Id, 'AR Analyst');
            System.debug('CHINTAN Inserted AR Analyst with ID ' + iat1.Id);
            
            //Add an exec sponsor as a sales ops user
            System.runAs(opsUser) {
                //insert another account
                Account myAccount2 = util_sampleDataGenerator.createAccount_Client();
                
                //Add the internal contact as an exec sponsor
                iat2 = util_sampleDataGenerator.createInternalAccountTeam(myAccount2.Id, myIntContact.Id, 'Executive Sponsor');
                System.debug('CHINTAN Inserted Executive Sponsor with ID ' + iat2.Id);
            } //System.runAs(opsUser)
        
            //validate that finApprove user can delete financial role
            Internal_Account_Team__c doomedIat = [SELECT Id from Internal_Account_Team__c where Id = :iat1.Id];
            System.debug('CHINTAN Deleting Record with ID ' + iat1.Id);
            Database.Deleteresult DR = Database.delete(doomedIat);
                System.assert(DR.isSuccess());
                System.debug('CHINTAN Success deleting financial role AR Analyst');
            
            //Validate that internal account team actually is gone
            try {
                iat1 = [select id from Internal_Account_Team__c where Id = :iat1.Id];
            } catch (Exception e) {
                System.assertEquals(e.getMessage(), 'List has no rows for assignment to SObject');
                System.assertEquals(e.getTypeName(), 'System.QueryException');
            }
            
            //validate that fin approver user cannot delete the Exec Sponsor
            doomedIat = [SELECT Id from Internal_Account_Team__c where Id = :iat2.Id];
            try {
                delete doomedIat;
            } catch (Exception e) {
                didTestSucceed = true;
                System.debug('CHINTAN Success Cannot Delete Exec Sponsor as fin user');
            }
            System.assertEquals(didTestSucceed, true);
            
            //validate that opp is actually not deleted
            iat2 = [SELECT Id from Internal_Account_Team__c where Id = :iat2.Id];
            System.assertNotEquals(null, iat2.Id);
            
            //validate that sales ops user can delete exec sponsor
            System.runAs(opsUser) {
                doomedIat = [SELECT Id from Internal_Account_Team__c where Id = :iat2.Id];
                DR = Database.delete(doomedIat);
                    System.assert(DR.isSuccess());
                    System.debug('CHINTAN Success deleting exec sponsor as sales ops user');
                
                //Validate that internal account team record is actually deleted
                try {
                    iat2 = [SELECT Id from Internal_Account_Team__c where Id = :iat2.Id];
                } catch (Exception e) {
                    System.assertEquals(e.getMessage(), 'List has no rows for assignment to SObject');
                    System.assertEquals(e.getTypeName(), 'System.QueryException');
                }
            } //System.runAs(opsUser)
        } //System.runAs(finUser)
        
        Test.stopTest();
    }
}