/**
 *Test Coverage for the class: blogic_Contact
 **/
@isTest
private class test_blogicContact {
    
    //Case No. 00006090 - START - Added to test the logic added in blogic_Contact class for avoiding duplicate external contacts
    static testMethod void test_restrictDupExternalContacts() {
      String extRecordTypeID = util_sampleDataGenerator.getRecordType('Contact','External Contact Record Type').ID;
      String intRecordTypeID = util_sampleDataGenerator.getRecordType('Contact','Internal Contact Record Type').ID;
      
      // Create a dummy account
      Account acc = util_sampleDataGenerator.createAccount_Client();
      acc.ACW_Client_Type__c='Client'; //Setting it as client because billing contact can be created only for Client/Internal Contacts
      Update acc;
      Test.startTest();
      
      //-----------------Internal Contacts----------------------------
      //Create 2 Internal Contacts
      List<Contact> myContacts = util_sampleDataGenerator.createInternalContact_bulk(acc.Id, 2, true);
      for (Contact myContact : myContacts) {
        System.assertNotEquals(null, myContact.Id);
      }
        
      //Insert a contact with duplicate email id
      Contact intCon3 = new Contact(Account=acc,FirstName='Test',LastName='Internal 3',RecordTypeID=intRecordTypeID,Email=myContacts[0].Email);
      Insert intCon3; //Contact should get inserted
      
      System.assertNotEquals(null,intCon3.Id);
      System.debug('Internal Contact 3 Created - '+intCon3.Id);

      //Update a contact and put duplicate email id
      myContacts[1].Email=myContacts[0].Email;
      update myContacts[1]; //Contact should get updated
      
      System.assertEquals(myContacts[1].Email,myContacts[0].Email);
      System.debug('Internal Contact 2 Updated - ' +  myContacts[1].Email);
            
      //-----------------External Contacts - Billing Contacts----------------------------
      Contact extBilCon1 = util_sampleDataGenerator.createContact_External('Test','External 1',extRecordTypeID,'extBilCon1@test.com',acc.ID,True);      
      Contact extBilCon2 = util_sampleDataGenerator.createContact_External('Test','External 2',extRecordTypeID,'extBilCon2@test.com',acc.ID,True);
      insert extBilCon1;
      insert extBilCon2;
      
      System.assertNotEquals(null,extBilCon1.Id);
      System.debug('External Billing Contact 1 Created - '+extBilCon1.Id);
      
      System.assertNotEquals(null,extBilCon2.Id);
      System.debug('External Billing Contact 2 Created - '+extBilCon2.Id);
      
      //Inserting a duplicate external billing contact
      Contact extBilCon3 = util_sampleDataGenerator.createContact_External('Test','External 3',extRecordTypeID,'extBilCon2@test.com',acc.ID,True);
      insert extBilCon3; //Contact should get inserted
      
      System.assertNotEquals(null,extBilCon3.Id);
      System.debug('External Billing Contact 3 Created - '+extBilCon3.Id);
      
      // Now update a contact and try to put a duplicate email id
      extBilCon2.Email = 'extBilCon1@test.com';
      update extBilCon2; //Contact should get updated
      
      System.assertEquals(extBilCon2.Email,'extBilCon1@test.com');
      System.debug('External Billing Contact 2 Updated - ' +  extBilCon2.Email);
          
      //-----------------External Contacts - Non Billing Contacts----------------------------      
      Contact extNonBilCon1 = util_sampleDataGenerator.createContact_External('Test','External Non Billing 1',extRecordTypeID,'extNonBilCon1@test.com',acc.ID,False);
      Contact extNonBilCon2 = util_sampleDataGenerator.createContact_External('Test','External Non Billing 2',extRecordTypeID,'extNonBilCon2@test.com',acc.ID,False);
      Contact extNonBilCon4 = util_sampleDataGenerator.createContact_External('Test','External Non Billing 4',extRecordTypeID,'extNonBilCon4@test.com',acc.ID,False);
      Contact extNonBilCon5 = util_sampleDataGenerator.createContact_External('Test','External Non Billing 5',extRecordTypeID,'extNonBilCon5@test.com',acc.ID,False);
      Contact extNonBilCon6 = util_sampleDataGenerator.createContact_External('Test','External Non Billing 6',extRecordTypeID,'extNonBilCon6@test.com',acc.ID,False);
      Contact extNonBilCon7 = util_sampleDataGenerator.createContact_External('Test','External Non Billing 7',extRecordTypeID,'extNonBilCon7@test.com',acc.ID,False);
      
      Contact[] extNonBilContacts = new Contact[] {extNonBilCon1,extNonBilCon2,extNonBilCon4,extNonBilCon5,extNonBilCon6,extNonBilCon7};
      insert extNonBilContacts ; 
      
      System.assertNotEquals(null,extNonBilCon1.Id);
      System.debug('External Non Billing Contact 1 Created - '+extNonBilCon1.Id);
      
      System.assertNotEquals(null,extNonBilCon2.Id);
      System.debug('External Non Billing Contact 2 Created - '+extNonBilCon2.Id);
      
      System.assertNotEquals(null,extNonBilCon4.Id);
      System.debug('External Non Billing Contact 4 Created - '+extNonBilCon4.Id);
      
      System.assertNotEquals(null,extNonBilCon5.Id);
      System.debug('External Non Billing Contact 5 Created - '+extNonBilCon5.Id);
      
      System.assertNotEquals(null,extNonBilCon6.Id);
      System.debug('External Non Billing Contact 6 Created - '+extNonBilCon6.Id);
      
      System.assertNotEquals(null,extNonBilCon7.Id);
      System.debug('External Non Billing Contact 7 Created - '+extNonBilCon7.Id);
      
      //Now insert a duplicate external non billing contact
      Contact extNonBilCon3 = util_sampleDataGenerator.createContact_External('Test','External Non Billing 3',extRecordTypeID,'extNonBilCon1@test.com',acc.ID,False);
      try {
          insert extNonBilCon3; //Contact should not get inserted
      } catch(DmlException e) {    
          System.assert(e.getDmlMessage(0).indexOf(Label.Duplicate_Contact_Error_Message) > -1);
          System.debug('External Non Billing Contact 2 Creating(Error Occured)');
      }
      
      //Now update a external non billing contact and try to put a duplicate email id
      extNonBilCon2.Email = 'extNonBilCon1@test.com';
      try {
          update extNonBilCon2; //Contact should not get updated
      } catch(DmlException e) {    
          System.assert(e.getDmlMessage(0).indexOf(Label.Duplicate_Contact_Error_Message) > -1);
          System.debug('External Non Billing Contact 2 Updating(Error Occured)');
      }
      
      //Now insert bulk records with one duplicate record
      Contact extNonBilCon8 = util_sampleDataGenerator.createContact_External('Test','External Non Billing 8',extRecordTypeID,'extNonBilCon1@test.com',acc.ID,False);
      Contact extNonBilCon10 = util_sampleDataGenerator.createContact_External('Test','External Non Billing 10',extRecordTypeID,'extNonBilCon10@test.com',acc.ID,False);
      Contact extNonBilCon11 = util_sampleDataGenerator.createContact_External('Test','External Non Billing 11',extRecordTypeID,'extNonBilCon11@test.com',acc.ID,False);
      Contact extNonBilCon12 = util_sampleDataGenerator.createContact_External('Test','External Non Billing 12',extRecordTypeID,'extNonBilCon12@test.com',acc.ID,False);
            
      extNonBilContacts = new Contact[] {extNonBilCon8,extNonBilCon10,extNonBilCon11,extNonBilCon12};
      try {
          insert extNonBilContacts ; 
      } catch(DmlException e) {   
          System.assert(e.getDmlMessage(0).indexOf(Label.Duplicate_Contact_Error_Message) > -1);
      }
      
      //Now update bulk records with some duplicate records
      System.debug('extNonBilCon1 ' + extNonBilCon1.ID);
      System.debug('extNonBilCon2 ' + extNonBilCon2.ID);
      System.debug('extNonBilCon3 ' + extNonBilCon4.ID);
      System.debug('extNonBilCon4 ' + extNonBilCon5.ID);
      System.debug('extNonBilCon5 ' + extNonBilCon6.ID);
      
      extNonBilCon1.Email = 'dummy.email@dummy.com';
      extNonBilCon2.Email = 'dummy.email@dummy.com';
      extNonBilCon4.Email = 'extNonBilCon16@test.com';
      extNonBilCon5.Email = 'extNonBilCon1@test.com';
      extNonBilCon6.Email = 'extNonBilCon2@test.com';
            
      extNonBilContacts = new Contact[]{extNonBilCon1,extNonBilCon2,extNonBilCon4,extNonBilCon5,extNonBilCon6};
      try {
          update extNonBilContacts; //Only first 3 should be updated
      } catch(DmlException e) {  
          System.assert(e.getDmlMessage(0).indexOf(Label.Duplicate_Contact_Error_Message) > -1);
          System.assert(e.getDmlMessage(1).indexOf(Label.Duplicate_Contact_Error_Message) > -1);
      }
      
      //Changing the contact type from billing to non-billing without changing the email id to see if check works fine in this case
      extBilCon1.Email='extNonBilCon1@test.com'; //Changing the email id to prepare the test data
      update extBilCon1;
      
      extBilCon1.Billing_Contact__c = False; //Made the contact as non billing contact
      try {
        update extBilCon1;
      } catch(DMLException e) {
        System.assert(e.getDmlMessage(0).indexOf(Label.Duplicate_Contact_Error_Message) > -1);
      }
      
      //Changing the record type internal to external
      myContacts[0].Email = 'extNonBilCon1@test.com'; //Changing the email to prepare the test data
      update myContacts[0];
      
      myContacts[0].RecordTypeId = extRecordTypeID;
      try {
        update myContacts[0];
      } catch(DMLException e) {
        System.assert(e.getDmlMessage(0).indexOf(Label.Duplicate_Contact_Error_Message) > -1);
      }
      
      //Testing for Bulk Records
      Contact[] bulkExtContacts = new Contact[]{};
      //extNonBilContacts = Null; //Setting null to clear the contact list
      String lastName = 'External Non Billing-';
      String emailID = 'extNonBilCon-';
      for (integer i=0;i<200;i++) {      
          //extNonBilCon = util_sampleDataGenerator.createContact_External('Test',lastName+i,extRecordTypeID,emailID+i+'@test.com',acc.ID,False);
          Contact extNonBilCon = util_sampleDataGenerator.createContact_External('Test',lastName,extRecordTypeID,emailID+'@test.com',acc.ID,False);
          bulkExtContacts.add(extNonBilCon);
      }
      try {
          insert bulkExtContacts ;
      } catch(DMLException e) { 
          for (integer i=0;i<200;i++) {
              System.assert(e.getDmlMessage(i).indexOf(Label.Duplicate_Contact_Error_Message) > -1);
          }
      }
      Test.stopTest();
    } //test_restrictDupExternalContacts
    
    
    
    /** Test the method that populates Contact Publications
      * Chintan, December 12, 2012 */
    static testMethod void test_populateContactPublication() {
        Test.startTest();
        
        //Create Account
        Account myAccount = util_sampleDataGenerator.createAccount_Client();
        System.assertNotEquals(null, myAccount.Id);
        Id myAccountId = myAccount.Id;
        
        //Create Contact
        Contact myContact = util_sampleDataGenerator.createContact_External(myAccount.Id);
        System.assertNotEquals(null, myContact.Id);
        
        //Create a Publication
        Contact_Publication__c myPublication = new Contact_Publication__c();
        myPublication.Associated_Contacts__c = myContact.Id;
        myPublication.Country__c = 'Country';
        myPublication.Publications__c = 'Publication';
        insert myPublication;
        System.assertNotEquals(null, myPublication.Id);
        
        //Verify
        myContact = [Select Contact_Publication__c from Contact Where Id = :myContact.Id];
        System.debug('CHINTAN CONTACT PUB IS: ' + myContact.Contact_Publication__c);
        System.assertEquals(myContact.Contact_Publication__c, 'Country,Publication');
        
        //Create another Publication
        Contact_Publication__c myPublication2 = new Contact_Publication__c();
        myPublication2.Associated_Contacts__c = myContact.Id;
        myPublication2.Country__c = 'Country2';
        myPublication2.Publications__c = 'Publication2';
        insert myPublication2;
        System.assertNotEquals(null, myPublication2.Id);
        
        //Verify
        myContact = [Select Contact_Publication__c from Contact Where Id = :myContact.Id];
        System.debug('CHINTAN CONTACT PUB IS: ' + myContact.Contact_Publication__c);
        System.assertEquals(myContact.Contact_Publication__c, 'Country,Publication;Country2,Publication2');
        
        //Delete a Publication
        delete myPublication2;
        
        //Verify
        myContact = [Select Contact_Publication__c from Contact Where Id = :myContact.Id];
        System.debug('CHINTAN CONTACT PUB IS: ' + myContact.Contact_Publication__c);
        System.assertEquals(myContact.Contact_Publication__c, 'Country,Publication');
        
        //Undelete a Publication
        undelete myPublication2;
        
        //Verify
        myContact = [Select Contact_Publication__c from Contact Where Id = :myContact.Id];
        System.debug('CHINTAN CONTACT PUB IS: ' + myContact.Contact_Publication__c);
        System.assertEquals(myContact.Contact_Publication__c, 'Country,Publication;Country2,Publication2');
        
        //Update Publication
        myPublication2.Country__c = 'Country3';
        myPublication2.Publications__c = 'Publication3';
        update myPublication2;
        
        //Verify
        myContact = [Select Contact_Publication__c from Contact Where Id = :myContact.Id];
        System.debug('CHINTAN CONTACT PUB IS: ' + myContact.Contact_Publication__c);
        System.assertEquals(myContact.Contact_Publication__c, 'Country,Publication;Country3,Publication3');
        
        Test.stopTest();
    } //test_populateContactPublication
    
    
    /** Bulk Test the method that populates Contact Publications
      * Chintan, December 13, 2012 */
    static testMethod void test_populateContactPublication_bulk() {
        //The number of records to create
        final integer count = 100;
        
        Test.startTest();
        
        //Create Account
        Account myAccount = util_sampleDataGenerator.createAccount_Client();
        System.assertNotEquals(null, myAccount.Id);
        Id myAccountId = myAccount.Id;
        
        //Create Contact
        Contact myContact = util_sampleDataGenerator.createContact_External(myAccount.Id);
        System.assertNotEquals(null, myContact.Id);
        
        //Create bulk Publications
        List<Contact_Publication__c> publications = new List<Contact_Publication__c> ();
        for (integer i=0; i<count; i++) {
            Contact_Publication__c myPublication = new Contact_Publication__c();
            myPublication.Associated_Contacts__c = myContact.Id;
            myPublication.Country__c = 'Country' + i;
            myPublication.Publications__c = 'Publication' + i;  
            publications.add(myPublication);
        }
        
        insert publications;
        for (Contact_Publication__c myPublication : publications) {
            System.assertNotEquals(null, myPublication.Id);
        }
        System.assertEquals(count, publications.size());
        
        //Verify
        myContact = [Select Contact_Publication__c from Contact Where Id = :myContact.Id];
        System.debug('CHINTAN CONTACT PUB IS: ' + myContact.Contact_Publication__c);
        String verifyStr = '';
        for (integer i=0; i<count; i++) {
            verifyStr += 'Country' + i + ',Publication' + i + ';';
        }
        verifyStr = verifyStr.substring(0, verifyStr.length() - 1);
        System.assertEquals(verifyStr, myContact.Contact_Publication__c);
        
        //Delete Publications
        delete publications;
        
        //Verify
        myContact = [Select Contact_Publication__c from Contact Where Id = :myContact.Id];
        System.debug('CHINTAN CONTACT PUB IS: ' + myContact.Contact_Publication__c);
        System.assertEquals(null, myContact.Contact_Publication__c);
        
        //Undelete Publications
        undelete publications;
        
        //Verify
        myContact = [Select Contact_Publication__c from Contact Where Id = :myContact.Id];
        System.debug('CHINTAN CONTACT PUB IS: ' + myContact.Contact_Publication__c);
        verifyStr = '';
        for (integer i=0; i<count; i++) {
            verifyStr += 'Country' + i + ',Publication' + i + ';';
        }
        verifyStr = verifyStr.substring(0, verifyStr.length() - 1);
        System.assertEquals(verifyStr, myContact.Contact_Publication__c);
        
        //Update Publications
        for (integer i=0; i<count; i++) {
            Contact_Publication__c myPublication = publications[i];
            myPublication.Country__c = 'Desh' + i;
            myPublication.Publications__c = 'Prakashan' + i;
        }
        update publications;
        
        //Verify
        myContact = [Select Contact_Publication__c from Contact Where Id = :myContact.Id];
        System.debug('CHINTAN CONTACT PUB IS: ' + myContact.Contact_Publication__c);
        verifyStr = '';
        for (integer i=0; i<count; i++) {
            verifyStr += 'Desh' + i + ',Prakashan' + i + ';';
        }
        verifyStr = verifyStr.substring(0, verifyStr.length() - 1);
        System.assertEquals(verifyStr, myContact.Contact_Publication__c);
        
        Test.stopTest();
    } //test_populateContactPublication_bulk
    
    
    /** Test the method that populates Contact Segmentation
      * Chintan, December 13, 2012 */
    static testMethod void test_populateContactSegmentation() {
        Test.startTest();
        
        //Create Account
        Account myAccount = util_sampleDataGenerator.createAccount_Client();
        System.assertNotEquals(null, myAccount.Id);
        Id myAccountId = myAccount.Id;
        
        //Create Contact
        Contact myContact = util_sampleDataGenerator.createContact_External(myAccount.Id);
        System.assertNotEquals(null, myContact.Id);
        
        //Create a Contact Segmentation
        Contact_Segmentation__c mySegmentation = new Contact_Segmentation__c();
        mySegmentation.Associated_Contact__c = myContact.Id;
        mySegmentation.Country__c = 'Country';
        mySegmentation.Segment__c = 'Segment';
        mySegmentation.Sub_Segment__c = 'Subsegment';
        insert mySegmentation;
        System.assertNotEquals(null, mySegmentation.Id);
        
        //Verify
        myContact = [Select Contact_Segmentation__c from Contact Where Id = :myContact.Id];
        System.debug('CHINTAN CONTACT SEG IS: ' + myContact.Contact_Segmentation__c);
        System.assertEquals(myContact.Contact_Segmentation__c, 'Country,Segment,Subsegment');
        
        //Create another Contact Segmentation
        Contact_Segmentation__c mySegmentation2 = new Contact_Segmentation__c();
        mySegmentation2.Associated_Contact__c = myContact.Id;
        mySegmentation2.Country__c = 'Country2';
        mySegmentation2.Segment__c = 'Segment2';
        mySegmentation2.Sub_Segment__c = 'Subsegment2';
        insert mySegmentation2;
        System.assertNotEquals(null, mySegmentation2.Id);
        
        //Verify
        myContact = [Select Contact_Segmentation__c from Contact Where Id = :myContact.Id];
        System.debug('CHINTAN CONTACT SEG IS: ' + myContact.Contact_Segmentation__c);
        System.assertEquals(myContact.Contact_Segmentation__c, 'Country,Segment,Subsegment;Country2,Segment2,Subsegment2');
                
        //Delete a Segment
        delete mySegmentation2;
        
        //Verify
        myContact = [Select Contact_Segmentation__c from Contact Where Id = :myContact.Id];
        System.debug('CHINTAN CONTACT SEG IS: ' + myContact.Contact_Segmentation__c);
        System.assertEquals(myContact.Contact_Segmentation__c, 'Country,Segment,Subsegment');
        
        //Undelete a Segment
        undelete mySegmentation2;
        
        //Verify
        myContact = [Select Contact_Segmentation__c from Contact Where Id = :myContact.Id];
        System.debug('CHINTAN CONTACT SEG IS: ' + myContact.Contact_Segmentation__c);
        System.assertEquals(myContact.Contact_Segmentation__c, 'Country,Segment,Subsegment;Country2,Segment2,Subsegment2');
        
        //Update Segment
        mySegmentation2.Country__c = 'Country3';
        mySegmentation2.Segment__c = 'Segment3';
        mySegmentation2.Sub_Segment__c = 'Subsegment3';
        update mySegmentation2;
        
        //Verify
        myContact = [Select Contact_Segmentation__c from Contact Where Id = :myContact.Id];
        System.debug('CHINTAN CONTACT SEG IS: ' + myContact.Contact_Segmentation__c);
        System.assertEquals(myContact.Contact_Segmentation__c, 'Country,Segment,Subsegment;Country3,Segment3,Subsegment3');
        
        Test.stopTest();
    } //test_populateContactSegmentation
    
    
    /** Bulk Test the method that populates Contact Segmentations
      * Chintan, December 13, 2012 */
    static testMethod void test_populateContactSegmentation_bulk() {
        //The number of records to create
        final integer count = 100;
        
        Test.startTest();
        
        //Create Account
        Account myAccount = util_sampleDataGenerator.createAccount_Client();
        System.assertNotEquals(null, myAccount.Id);
        Id myAccountId = myAccount.Id;
        
        //Create Contact
        Contact myContact = util_sampleDataGenerator.createContact_External(myAccount.Id);
        System.assertNotEquals(null, myContact.Id);
        
        //Create bulk Segmentations
        List<Contact_Segmentation__c> segmentations = new List<Contact_Segmentation__c> ();
        for (integer i=0; i<count; i++) {
            Contact_Segmentation__c mySegment = new Contact_Segmentation__c();
            mySegment.Associated_Contact__c = myContact.Id;
            mySegment.Country__c = 'Country' + i;
            mySegment.Segment__c = 'Segment' + i;
            mySegment.Sub_Segment__c = 'Subsegment' + i;
            segmentations.add(mySegment);
        }
        insert segmentations;
        for (Contact_Segmentation__c mySegment : segmentations) {
            System.assertNotEquals(null, mySegment.Id);
        }
        System.assertEquals(count, segmentations.size());
        
        //Verify
        myContact = [Select Contact_Segmentation__c from Contact Where Id = :myContact.Id];
        System.debug('CHINTAN CONTACT SEG IS: ' + myContact.Contact_Segmentation__c);
        String verifyStr = '';
        for (integer i=0; i<count; i++) {
            verifyStr += 'Country' + i + ',Segment' + i + ',Subsegment' + i + ';';
        }
        verifyStr = verifyStr.substring(0, verifyStr.length() - 1);
        System.assertEquals(verifyStr, myContact.Contact_Segmentation__c);
        
        //Delete Segmentations
        delete segmentations;
        
        //Verify
        myContact = [Select Contact_Segmentation__c from Contact Where Id = :myContact.Id];
        System.debug('CHINTAN CONTACT SEG IS: ' + myContact.Contact_Segmentation__c);
        System.assertEquals(null, myContact.Contact_Segmentation__c);
        
        //Undelete Segmentations
        undelete segmentations;
        
        //Verify
        myContact = [Select Contact_Segmentation__c from Contact Where Id = :myContact.Id];
        System.debug('CHINTAN CONTACT SEG IS: ' + myContact.Contact_Segmentation__c);
        verifyStr = '';
        for (integer i=0; i<count; i++) {
            verifyStr += 'Country' + i + ',Segment' + i + ',Subsegment' + i +';';
        }
        verifyStr = verifyStr.substring(0, verifyStr.length() - 1);
        System.assertEquals(verifyStr, myContact.Contact_Segmentation__c);
        
        //Update Segmentations
        for (integer i=0; i<count; i++) {
            Contact_Segmentation__c mySegment = segmentations[i];
            mySegment.Country__c = 'Desh' + i;
            mySegment.Segment__c = 'Tukda' + i;
            mySegment.Sub_Segment__c = 'Khand' + i;
        }
        update segmentations;
        
        //Verify
        myContact = [Select Contact_Segmentation__c from Contact Where Id = :myContact.Id];
        System.debug('CHINTAN CONTACT SEG IS: ' + myContact.Contact_Segmentation__c);
        verifyStr = '';
        for (integer i=0; i<count; i++) {
            verifyStr += 'Desh' + i + ',Tukda' + i + ',Khand' + i + ';';
        }
        verifyStr = verifyStr.substring(0, verifyStr.length() - 1);
        System.assertEquals(verifyStr, myContact.Contact_Segmentation__c);
        
        Test.stopTest();
    } //test_populateContactSegmentation_bulk
    
    
    /** Test the method that populates Contact Relationship
      * Chintan, December 12, 2012 */
    static testMethod void test_populateContactRelationship() {
        Test.startTest();
        
        //Create Account
        Account myAccount = util_sampleDataGenerator.createAccount_Client();
        System.assertNotEquals(null, myAccount.Id);
        Id myAccountId = myAccount.Id;
        
        //Create 3 Contacts
        Id recordId = util_sampleDataGenerator.getRecordType('Contact', 'Internal Contact Record Type').Id;
        List<Contact> contactsToAdd = new List<Contact> ();
        
        Contact myContact = new Contact();
        myContact.RecordTypeId = util_sampleDataGenerator.getRecordType('Contact', 'External Contact Record Type').Id;
        myContact.AccountId = myAccount.Id;
        myContact.Email = 'randomstring@aonhewitt.com';
        myContact.SDO_Billing_Country_Name__c = 'Country';
        myContact.Functional_Role__c = 'Other - Other';
        myContact.FirstName = 'FName';
        myContact.Middle_Name__c = 'MName';
        myContact.LastName = 'LName';
        contactsToAdd.add(myContact);
        
        Contact myContact2 = new Contact();
        myContact2.RecordTypeId = recordId;
        myContact2.AccountId = myAccount.Id;
        myContact2.Email = 'randomstring2@aonhewitt.com';
        myContact2.FirstName = 'FName2';
        myContact2.Middle_Name__c = 'MName2';
        myContact2.LastName = 'LName2';
        //myContact2.Source_HR_System__c = 'Aon Hewitt';
        //myContact2.Legacy_Hewitt_Associate_ID__c = 'A98765';
        myContact2.Associate_ID__c = 'A98765';
        myContact2.Aon_Hewitt_Employee_Status__c = 'Active';
        contactsToAdd.add(myContact2);
        
        Contact myContact3 = new Contact();
        myContact3.RecordTypeId = recordId;
        myContact3.AccountId = myAccount.Id;
        myContact3.Email = 'randomstring3@aonhewitt.com';
        myContact3.FirstName = 'FName3';
        myContact3.Middle_Name__c = 'MName3';
        myContact3.LastName = 'LName3';
        //myContact3.Source_HR_System__c = 'Aon Hewitt';
        //myContact3.Legacy_Hewitt_Associate_ID__c = 'A99765';
        myContact3.Associate_ID__c = 'A99765';
        myContact3.Aon_Hewitt_Employee_Status__c = 'Active';
        contactsToAdd.add(myContact3);
        
        insert contactsToAdd;
        System.assertNotEquals(null, myContact.Id);
        System.assertNotEquals(null, myContact2.Id);
        System.assertNotEquals(null, myContact3.Id);
        
        //Create a Contact Relationship
        Contact_Relationship__c myRelationship = new Contact_Relationship__c();
        myRelationship.Contact__c = myContact.Id;
        myRelationship.Also_Known_To__c = myContact2.Id;
        myRelationship.Relationship_Type__c = 'Type1';
        insert myRelationship;
        System.assertNotEquals(null, myRelationship.Id);
        
        //Verify
        myContact = [Select Contact_Relationship__c from Contact Where Id = :myContact.Id];
        System.debug('CHINTAN CONTACT REL IS: ' + myContact.Contact_Relationship__c);
        System.assertEquals(myContact.Contact_Relationship__c, 'FName2 MName2 LName2,Type1');
        
        //Create a second Contact Relationship
        Contact_Relationship__c myRelationship2 = new Contact_Relationship__c();
        myRelationship2.Contact__c = myContact.Id;
        myRelationship2.Also_Known_To__c = myContact3.Id;
        myRelationship2.Relationship_Type__c = 'Type2';
        insert myRelationship2;
        System.assertNotEquals(null, myRelationship2.Id);
        
        //Verify
        myContact = [Select Contact_Relationship__c from Contact Where Id = :myContact.Id];
        System.debug('CHINTAN CONTACT REL IS: ' + myContact.Contact_Relationship__c);
        System.assertEquals(myContact.Contact_Relationship__c, 'FName2 MName2 LName2,Type1;FName3 MName3 LName3,Type2');
        
        //Delete a Relationship
        delete myRelationship2;
        
        //Verify
        myContact = [Select Contact_Relationship__c from Contact Where Id = :myContact.Id];
        System.debug('CHINTAN CONTACT REL IS: ' + myContact.Contact_Relationship__c);
        System.assertEquals(myContact.Contact_Relationship__c, 'FName2 MName2 LName2,Type1');
        
        //Undelete
        undelete myRelationship2;
        
        //Verify
        myContact = [Select Contact_Relationship__c from Contact Where Id = :myContact.Id];
        System.debug('CHINTAN CONTACT REL IS: ' + myContact.Contact_Relationship__c);
        System.assertEquals(myContact.Contact_Relationship__c, 'FName2 MName2 LName2,Type1;FName3 MName3 LName3,Type2');
        
        //Update a Relationship
        delete myRelationship2;
        myRelationship.Also_Known_To__c = myContact3.Id;
        myRelationship.Relationship_Type__c = 'Type3';
        update myRelationship;
        
        //Verify
        myContact = [Select Contact_Relationship__c from Contact Where Id = :myContact.Id];
        System.debug('CHINTAN CONTACT REL IS: ' + myContact.Contact_Relationship__c);
        System.assertEquals(myContact.Contact_Relationship__c, 'FName3 MName3 LName3,Type3');

        Test.stopTest();
    } //test_populateContactSegmentation
    
    
    /** Bulk Test the method that populates Contact Relationships
      * Chintan, December 13, 2012 */
    static testMethod void test_populateContactRelationship_bulk() {
        //The number of records to create
        final integer count = 100;
        
        Test.startTest();
        
        //Create Account
        Account myAccount = util_sampleDataGenerator.createAccount_Client();
        System.assertNotEquals(null, myAccount.Id);
        Id myAccountId = myAccount.Id;
        
        //Create External Contact
        Contact myContact = util_sampleDataGenerator.createContact_External(myAccount.Id);
        System.assertNotEquals(null, myContact.Id);
        
        //Create bulk Internal Contact
        List<Contact> internalContacts = new List<Contact> ();
        Id recordId = util_sampleDataGenerator.getRecordType('Contact', 'Internal Contact Record Type').Id;
        integer id = 12345;
        for (integer i=0; i<count * 2; i++) {
            integer empId = id + i;
            Contact myInternalContact = new Contact();
            myInternalContact.RecordTypeId = recordId;
            myInternalContact.AccountId = myAccount.Id;
            myInternalContact.Email = 'randomstring' + i + '@aonhewitt.com';
            myInternalContact.FirstName = 'FName' + i;
            myInternalContact.Middle_Name__c = 'MName' + i;
            myInternalContact.LastName = 'LName' + i;
            //myInternalContact.Source_HR_System__c = 'Aon Hewitt';
            //myInternalContact.Legacy_Hewitt_Associate_ID__c = 'A' + id + i;
            myInternalContact.Associate_ID__c = 'A' + empid;
            myInternalContact.Aon_Hewitt_Employee_Status__c = 'Active';
            internalContacts.add(myInternalContact);
        }
        insert internalContacts;
        System.assertEquals(count * 2, internalContacts.size());
        for (Contact myInternalContact : internalContacts) {
            System.assertNotEquals(null, myInternalContact.Id);
        }
        
        //Create Bulk Relationships
        List<Contact_Relationship__c> relationships = new List<Contact_Relationship__c> ();
        for (integer i=0; i<count; i++) {
            Contact_Relationship__c myRelationship = new Contact_Relationship__c();
            myRelationship.Contact__c = myContact.Id;
            myRelationship.Also_Known_To__c = internalContacts[i].Id;
            myRelationship.Relationship_Type__c = 'Type1';
            relationships.add(myRelationship);
        }
        insert relationships;
        for (Contact_Relationship__c myRelationship : relationships) {
            System.assertNotEquals(null, myRelationship.Id);
        }
        System.assertEquals(count, relationships.size());
        
        //Verify
        myContact = [Select Contact_Relationship__c from Contact Where Id = :myContact.Id];
        System.debug('CHINTAN CONTACT REL IS: ' + myContact.Contact_Relationship__c);
        String verifyStr = '';
        for (integer i=0; i<count; i++) {
            verifyStr += 'FName' + i + ' MName' + i + ' LName' + i + ',Type1;';
        }
        verifyStr = verifyStr.substring(0, verifyStr.length() - 1);
        System.assertEquals(verifyStr, myContact.Contact_Relationship__c);
        
        //Delete Relationships
        delete relationships;
        
        //Verify
        myContact = [Select Contact_Relationship__c from Contact Where Id = :myContact.Id];
        System.debug('CHINTAN CONTACT REL IS: ' + myContact.Contact_Relationship__c);
        System.assertEquals(null, myContact.Contact_Relationship__c);
        
        //Undelete Relationships
        undelete relationships;
        
        //Verify
        myContact = [Select Contact_Relationship__c from Contact Where Id = :myContact.Id];
        System.debug('CHINTAN CONTACT REL IS: ' + myContact.Contact_Relationship__c);
        verifyStr = '';
        for (integer i=0; i<count; i++) {
            verifyStr += 'FName' + i + ' MName' + i + ' LName' + i + ',Type1;';
        }
        verifyStr = verifyStr.substring(0, verifyStr.length() - 1);
        System.assertEquals(verifyStr, myContact.Contact_Relationship__c);
        
        //Update Relationships
        for (integer i=0; i<count; i++) {
            Contact_Relationship__c myRelationship = relationships[i];
            myRelationship.Also_Known_To__c = internalContacts[count + i].Id;
            myRelationship.Relationship_Type__c = 'Type2';
        }
        update relationships;
        
        //Verify
        myContact = [Select Contact_Relationship__c from Contact Where Id = :myContact.Id];
        System.debug('CHINTAN CONTACT REL IS: ' + myContact.Contact_Relationship__c);
        verifyStr = '';
        for (integer i=0; i<count; i++) {
            verifyStr += 'FName' + (count + i) + ' MName' + (count + i) + ' LName' + (count + i) + ',Type2;';
        }
        verifyStr = verifyStr.substring(0, verifyStr.length() - 1);
        System.assertEquals(verifyStr, myContact.Contact_Relationship__c);
        
        Test.stopTest();
    } //test_populateContactRelationship_bulk

    
    /** Tests That quarterly targets are synchronized between contact and user records*/
    static testMethod void testSyncContactUser() {
        //Create user
        User newUser = util_sampleDataGenerator.createHewittStandardUser();
        System.assertNotEquals(null, newUser.Id);
        
        //create account
        Account account = util_sampleDataGenerator.createAccount('APEX TEST ACCOUNT', util_sampleDataGenerator.getRecordType('Account', 'Client Account Record Type').Id, 'United States', 'IL');  
        System.assertNotEquals(null,account.id);
        
        //Add a new contact
        Contact contact = new Contact();
        contact.RecordTypeId = util_sampleDataGenerator.getRecordType('Contact', 'Internal Contact Record Type').Id;
        contact.FirstName = 'Apex';
        contact.LastName = 'Test';
        contact.email = 'abcde@aonhewitt.com';
        contact.AccountId = account.Id;
        contact.SDO_Mailing_Country_Name__c = 'United States';
        contact.Functional_Role__c = 'Other - Other';
        //contact.Legacy_Hewitt_Associate_ID__c = 'A12345';
        contact.Associate_ID__c = 'A12345';
        //contact.Source_HR_System__c = 'Aon Hewitt';
        contact.Aon_Hewitt_Employee_Status__c = 'Active';
        contact.Reporting_Practice__c = 'Key';
        contact.Q1_Target__c = 1;
        contact.Q2_Target__c = 2;
        contact.Q3_Target__c = 3;
        contact.Q4_Target__c = 4;
        contact.corresponding_user_id__c = newUser.Id;
        insert contact;
        System.assertNotEquals(null, contact.Id);
        
        //verify insert trigger      //verify insert trigger
        newUser = [SELECT Id, Q1_Target__c, Q2_Target__c, Q3_Target__c, Q4_Target__c,Associate_ID__c,ARS_Function__c,Reporting_Practice__c,Internal_Contact_Id__c FROM User WHERE Id = :newUser.id];
        System.assertEquals(1, newUser.Q1_Target__c);
        System.assertEquals(2, newUser.Q2_Target__c);
        System.assertEquals(3, newUser.Q3_Target__c);
        System.assertEquals(4, newUser.Q4_Target__c);
        System.assertEquals('A12345', newUser.Associate_ID__c);
        System.assertEquals('Other - Other', newUser.ARS_Function__c);
        System.assertEquals('Key', newUser.Reporting_Practice__c);
        System.assertEquals(contact.Id, newUser.Internal_Contact_Id__c);
        
        //update contact with targets
        contact.Q1_Target__c = 9;
        contact.Q2_Target__c = 8;
        contact.Q3_Target__c = 7;
        contact.Q4_Target__c = 6;
        contact.Functional_Role__c = 'Finance - Other';
        contact.Reporting_Practice__c = 'Leadership';
        update contact;
        
        //verify update trigger
        contact = [select id, corresponding_user_id__c,contact.Q1_Target__c,contact.Q2_Target__c,contact.Q3_Target__c,contact.Q4_Target__c from Contact where id = :contact.Id];         
        newUser = [SELECT Id,Q1_Target__c,Q2_Target__c,Q3_Target__c,Q4_Target__c,Associate_ID__c,ARS_Function__c,Reporting_Practice__c,Internal_Contact_Id__c FROM User WHERE Id = :newUser.id];
        System.assertEquals(9, newUser.Q1_Target__c);
        System.assertEquals(8, newUser.Q2_Target__c);
        System.assertEquals(7, newUser.Q3_Target__c);
        System.assertEquals(6, newUser.Q4_Target__c);   
        System.assertEquals('Finance - Other',newUser.ARS_Function__c);   
        System.assertEquals('Leadership',newUser.Reporting_Practice__c);        
    } //testSyncContactUser
    

    //Bulk test for contact and user synch for quarterly targets
    static testMethod void testSynchContactUser_bulk() {
        //local vars
        Set<Id> contactIds = new Set<Id> ();
        List<Contact> myContacts = new List<Contact>();
        final integer count = 20;
      
        //Create account
        Account myAccount = util_SampleDataGenerator.createAccount_Client();
        System.assertNotEquals(null, myAccount.Id);
      
        //Create 'count' Users
        List<User> myUsers = util_SampleDataGenerator.createHewittStandardUser_bulk(count,true);
        System.debug('Users size: ' + myUsers.size());
      
        //String internalContactRecordTypeId = util_sampleDataGenerator.getRecordType('Contact', 'Internal Contact Record Type').Id;
        //System.assertNotEquals(null, internalContactRecordTypeId);
      
        //Create 'count' Contacts
        myContacts = util_sampleDataGenerator.createInternalContact_bulk(myAccount.Id, count, false);
        for (integer x=0; x<count; x++) {
            myContacts[x].Q1_Target__c = 1;
            myContacts[x].Q2_Target__c = 2;
            myContacts[x].Q3_Target__c = 3;
            myContacts[x].Q4_Target__c = 4;
            myContacts[x].Corresponding_User_Id__c = myUsers[x].Id;
            myContacts[x].Functional_Role__c = 'Other - Other';
            myContacts[x].Reporting_Practice__c = 'Key';
        }
        insert myContacts;
        System.assertEquals(count, myContacts.size());
              
        //Verify insert trigger
        System.debug('Size of Contacts Inserted: ' + myContacts.size());
        for (Contact myContact : myContacts) {
            contactIds.add(myContact.Id);
            User myUser = [SELECT Id, Q1_Target__c, Q2_Target__c, Q3_Target__c, Q4_Target__c,Reporting_Practice__c,ARS_Function__c FROM User WHERE Id = :myContact.Corresponding_User_Id__c];
            System.assertEquals(1, myUser.Q1_Target__c);
            System.assertEquals(2, myUser.Q2_Target__c);
            System.assertEquals(3, myUser.Q3_Target__c);
            System.assertEquals(4, myUser.Q4_Target__c);
            System.assertEquals('Key', myUser.Reporting_Practice__c);
            System.assertEquals('Other - Other', myUser.ARS_Function__c);
        }
        
        //Update Contacts
        myContacts = [Select Id, Q1_Target__c, Q2_Target__c, Q3_Target__c, Q4_Target__c,Reporting_Practice__c,Functional_Role__c from Contact Where Id in :contactIds];
        for (Contact myContact : myContacts) {
            myContact.Q1_Target__c = 9;
            myContact.Q2_Target__c = 8;
            myContact.Q3_Target__c = 7;
            myContact.Q4_Target__c = 6;
            myContact.Functional_Role__c = 'Finance - Other';
            myContact.Reporting_Practice__c = 'Leadership';
        }
        update myContacts;
        
        //Verify update trigger
        myContacts = [Select Id, Corresponding_User_Id__c from Contact Where Id in :contactIds];
        for (Contact myContact : myContacts) {
            User myUser = [SELECT Id, Q1_Target__c, Q2_Target__c, Q3_Target__c, Q4_Target__c,Reporting_Practice__c,ARS_Function__c FROM User WHERE Id = :myContact.Corresponding_User_Id__c];
            System.assertEquals(9, myUser.Q1_Target__c);
            System.assertEquals(8, myUser.Q2_Target__c);
            System.assertEquals(7, myUser.Q3_Target__c);
            System.assertEquals(6, myUser.Q4_Target__c);
            System.assertEquals('Leadership', myUser.Reporting_Practice__c);
            System.assertEquals('Finance - Other', myUser.ARS_Function__c);
        } 
    } //testSynchContactUser_bulk
}