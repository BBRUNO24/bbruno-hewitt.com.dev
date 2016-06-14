/**
 * This class contains unit tests for validating the behavior of blogic_DeleteAudit Apex classes
 * and triggers.
 */
@isTest
private class test_blogicDeleteAudit {
    @testSetup 
    static void setupTestData() {

        /*
            Insert the Organizational_Defaults__c
        */
        Organizational_Defaults__c orgDefaultSettings = new Organizational_Defaults__c();
        orgDefaultSettings.Enable_CAPIS_Id_Assignment__c = false;
        orgDefaultSettings.Sales_Team_Reconciler_Last_Run_Date__c = null;
        insert orgDefaultSettings;

        /*
            Setup the Delete custom settings
        */
        OpportunityDeletionSettings__c oppDelAccess = new OpportunityDeletionSettings__c();
        oppDelAccess.Name = UserInfo.getProfileId();
        oppDelAccess.Closed_Lost__c = true;
        oppDelAccess.Closed_Won__c = true;
        oppDelAccess.Non_Qualified_Opportunity__c = true;
        oppDelAccess.Propose_Solution__c = true;
        oppDelAccess.Qualify_Opportunity__c = true;
        oppDelAccess.Negotiate__c = true;
        oppDelAccess.Closed_Approved__c = true;
        insert oppDelAccess;
        /*                                                                                                                                                                                                                                    
            Insert the Competitor__c Accounts
        */
        List<Competitor__c> competitors = new List<Competitor__c>();
        Competitor__c aon = new Competitor__c(name='Aon Hewitt');
        Competitor__c other = new Competitor__c(name='Other');
        competitors.add(aon);
        competitors.add(other);
        insert competitors;
    }

    //Test Record Deletion of all target Object types
    static testMethod void testRecordDelete() {
        //Create Account
        Account myAccount = util_sampleDataGenerator.createAccount_Client();
        System.assertNotEquals(null, myAccount.Id);
        Id myAccountId = myAccount.Id;
        
        //Now delete it
        delete myAccount;

        //Verify Delete Audit record
        Delete_Audit__c myAuditRec = [Select Id, CRM_ID__c, Deleted_By__c, Deletion_Date__c, Record_ID__c, Record_Name__c, Record_Type__c from Delete_Audit__c Where Record_ID__c = :myAccountId];
        System.debug('CHINTAN Delete Audit Record Retrieved: ' + myAuditRec);
        System.assertNotEquals(null, myAuditRec.Id);
        
        //Now undelete it
        undelete myAccount;
        
        //Verify
        myAccount = [Select Id from Account Where Id = :myAccountId];
        System.assertNotEquals(null, myAccount.Id);
        integer recordCount = [Select Count() from Delete_Audit__c Where Record_ID__c = :myAccountId];
        System.assertEquals(recordCount, 0);
        
        //Create External Contact
        Contact myContact = util_sampleDataGenerator.createContact_External(myAccountId);
        System.assertNotEquals(null, myContact.Id);
        Id myContactId = myContact.Id;
        
        //Now delete it
        delete myContact;
        
        //Verify Delete Audit Record
        myAuditRec = [Select Id, CRM_ID__c, Deleted_By__c, Deletion_Date__c, Record_ID__c, Record_Name__c, Record_Type__c from Delete_Audit__c Where Record_ID__c = :myContactId];
        System.debug('CHINTAN Delete Audit Record Retrieved: ' + myAuditRec);
        System.assertNotEquals(null, myAuditRec.Id);
        
        //Now undelete it
        undelete myContact;
        
        //Verify
        myContact = [Select Id from Contact Where Id = :myContactId];
        System.assertNotEquals(null, myContact.Id);
        recordCount = [Select Count() from Delete_Audit__c Where Record_ID__c = :myContactId];
        System.assertEquals(recordCount, 0);
        
        //Create Internal Contact
        myContact = util_sampleDataGenerator.createContact_Internal(myAccountId);
        System.assertNotEquals(null, myContact.Id);
        myContactId = myContact.Id;
        
        //Now delete it
        delete myContact;
        
        //Verify Delete Audit Record
        myAuditRec = [Select Id, CRM_ID__c, Deleted_By__c, Deletion_Date__c, Record_ID__c, Record_Name__c, Record_Type__c from Delete_Audit__c Where Record_ID__c = :myContactId];
        System.debug('CHINTAN Delete Audit Record Retrieved: ' + myAuditRec);
        System.assertNotEquals(null, myAuditRec.Id);
        
        //Now undelete it
        undelete myContact;
        
        //Verify
        myContact = [Select Id from Contact Where Id = :myContactId];
        System.assertNotEquals(null, myContact.Id);
        recordCount = [Select Count() from Delete_Audit__c Where Record_ID__c = :myContactId];
        System.assertEquals(recordCount, 0);
        
        //Create an Opportunity
        Opportunity myOpportunity = util_sampleDataGenerator.createOpportunity_US(myAccountId);
        System.assertNotEquals(null, myOpportunity.Id);
        Id myOpportunityId = myOpportunity.Id;
        
        //Now delete it
        delete myOpportunity;
        
        //Verify Delete Audit Record
        myAuditRec = [Select Id, CRM_ID__c, Deleted_By__c, Deletion_Date__c, Record_ID__c, Record_Name__c, Record_Type__c from Delete_Audit__c Where Record_ID__c = :myOpportunityId];
        System.debug('CHINTAN Delete Audit Record Retrieved: ' + myAuditRec);
        System.assertNotEquals(null, myAuditRec.Id);
        
        //Now undelete it
        undelete myOpportunity;
        
        //Verify
        myOpportunity = [Select Id from Opportunity Where Id = :myOpportunityId];
        System.assertNotEquals(null, myOpportunity.Id);
        recordCount = [Select Count() from Delete_Audit__c Where Record_ID__c = :myOpportunityId];
        System.assertEquals(recordCount, 0);

    } //testRecordDelete
    
    
   //Test Bulk Record Deletion of all target Object types
    static testMethod void testRecordDelete_bulk() {
        //local vars
        List<Id> myAccountIds = new List<Id> ();
        List<Id> myContactIds = new List<Id> ();
        List<Id> myOpportunityIds = new List<Id> ();
        List<Contact> myContacts = new List<Contact> ();
        List<Opportunity> myOpportunities = new List<Opportunity> ();
        final integer count = 20;
        
        //Create 'count' accounts
        List <Account> myAccounts = util_SampleDataGenerator.createPeopleSoftClients('TEST', count, true);
        
        //Collect the distinct set of ids created
        for (Account account : myAccounts) {
            myAccountIds.add(account.Id);
        }
        System.assertEquals(count, myAccountIds.size());
        //Now delete them
        delete myAccounts;

        //Verify Delete Audit record
        List<Delete_Audit__c> myAuditRecs = [Select Id, CRM_ID__c, Deleted_By__c, Deletion_Date__c, Record_ID__c, Record_Name__c, Record_Type__c From Delete_Audit__c Where Record_ID__c In :myAccountIds];
        System.debug('CHINTAN Number of Account Delete Audit Record Retrieved: ' + myAuditRecs.size());
        System.assertEquals(count, myAuditRecs.size());
        
        //Now undelete them
        undelete myAccounts;
        
        //Verify
        myAccounts = [Select Id from Account Where Id In :myAccountIds];
        System.assertEquals(count, myAccounts.size());
        integer myAuditRecCount = [Select Count() from Delete_Audit__c Where Record_ID__c In :myAccountIds];
        System.assertEquals(0, myAuditRecCount);

        
        //Create 'count' External Contacts
        Id extContactRecordTypeId = util_sampleDataGenerator.getRecordType('Contact', 'External Contact Record Type').Id;
        for (integer x=0; x < count; x++) {
            Contact myContact = new Contact();
            myContact.RecordTypeId = extContactRecordTypeId;
            myContact.FirstName = 'Apex';
            myContact.LastName = 'Contact ' + x;
            myContact.email = 'apex.contact'+x+'@email.com';
            myContact.AccountId = myAccounts[x].Id;
            myContact.SDO_Mailing_Country_Name__c = 'United States';
            myContact.Functional_Role__c = 'Other - Other';
                
            myContacts.add(myContact);
        }
        insert myContacts;
        
        //Collect the distinct set of ids created
        for (Contact myContact : myContacts) {
            myContactIds.add(myContact.Id);
        }
        System.assertEquals(count, myContactIds.size());
        
        //Now delete them
        delete myContacts;
        
        //Verify Delete Audit record
        myAuditRecs = [Select Id, CRM_ID__c, Deleted_By__c, Deletion_Date__c, Record_ID__c, Record_Name__c, Record_Type__c From Delete_Audit__c Where Record_ID__c In :myContactIds];
        System.debug('CHINTAN Number of Contact Delete Audit Record Retrieved: ' + myAuditRecs.size());
        System.assertEquals(count, myAuditRecs.size());
        
        //Now undelete them
        undelete myContacts;
        
        //Verify
        myContacts = [Select Id from Contact Where Id In :myContactIds];
        System.assertEquals(count, myContacts.size());
        myAuditRecCount = [Select Count() from Delete_Audit__c Where Record_ID__c In :myContactIds];
        System.assertEquals(0, myAuditRecCount);
        
        //Create 'count' Opportunities
        String opportunityRecordTypeId = util_sampleDataGenerator.getRecordType('Opportunity', 'Oppty Record').Id;
        for(Integer i=0; i < count; i++) {
            Opportunity myOpp = new Opportunity();
            myOpp.RecordTypeId = opportunityRecordTypeId;        
            myOpp.accountId = myAccounts[i].Id;        
            myOpp.name = 'Apex Test Opportunity '+ i;        
            myOpp.amount = 1000.0;        
            myOpp.StageName = 'Qualify Opportunity';        
            myOpp.CloseDate = Date.today().addDays(30);        
            myOpp.Probability = 10;
            
            myOpportunities.add(myOpp);         
        }
        insert myOpportunities;
        
        //Collect the distinct set of ids created
        for (Opportunity myOpp : myOpportunities) {
            myOpportunityIds.add(myOpp.Id);
        }
        System.assertEquals(count, myOpportunityIds.size());
        
        //Now delete them
        delete myOpportunities;
        
        //Verify Delete Audit record
        myAuditRecs = [Select Id, CRM_ID__c, Deleted_By__c, Deletion_Date__c, Record_ID__c, Record_Name__c, Record_Type__c From Delete_Audit__c Where Record_ID__c In :myOpportunityIds];
        System.debug('CHINTAN Number of Opportunity Delete Audit Record Retrieved: ' + myAuditRecs.size());
        System.assertEquals(count, myAuditRecs.size());
        
        //Now undelete them
        undelete myOpportunities;
        
        //Verify
        myOpportunities = [Select Id from Opportunity Where Id In :myOpportunityIds];
        System.assertEquals(count, myOpportunities.size());
        myAuditRecCount = [Select Count() from Delete_Audit__c Where Record_ID__c In :myOpportunityIds];
        System.assertEquals(0, myAuditRecCount);
        
    } //testRecordDelete_bulk
    
 
}