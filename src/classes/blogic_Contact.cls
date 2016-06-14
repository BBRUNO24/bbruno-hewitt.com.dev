public without sharing class blogic_Contact {
    //00018911 - Ritu Sharma - Added variables instead of hardcoding in functions
    private static string valueSep = ',';
    private static string recordSep = ';';
    
    //Case No. 00010091 - Intialize variables to 0 if no value added
    //Sunny Mohla, Nov 27, 2012
    public static void initializeCurrencyVariables(List<Contact> newContacts) {
        for(Contact myContact : newContacts) {
            myContact.Q1_Target__c = myContact.Q1_Target__c == null ? 0.0 : myContact.Q1_Target__c;
            myContact.Q2_Target__c = myContact.Q2_Target__c == null ? 0.0 : myContact.Q2_Target__c;
            myContact.Q3_Target__c = myContact.Q3_Target__c == null ? 0.0 : myContact.Q3_Target__c;
            myContact.Q4_Target__c = myContact.Q4_Target__c == null ? 0.0 : myContact.Q4_Target__c; 
        }
    } //initializeCurrencyVariables
    

    //Case No. 00006090 - START - Added to avoid duplicate external contacts i.e. contacts having same email id  
    public static void restrictDupExternalContacts(Map<ID,Contact> oldContactsMap, List<Contact> newContacts) {  
        Map<String, Contact> conMap = new Map<String, Contact>();  
        String extRecordTypeID = util_sampleDataGenerator.getRecordType('Contact','External Contact Record Type').ID;
        
        for (Contact con : newContacts) {
            if ((con.RecordTypeId == extRecordTypeID) && !(con.Billing_Contact__c) && (con.Email != null) && (con.Email != '') 
                    && (con.Email != 'dummy.email@dummy.com')) {
                if (System.trigger.isInsert) { 
                    conMap.put(con.Email, con);
                } else {
                    //Need to add to the map if email id, billing contact or contact record type has been chnaged
                    //intent is to check the external contact if email id changed or it has turned from a billing to a non-billing 
                    //or from internal to external
                    if ((con.Email != oldContactsMap.get(con.Id).Email) || (con.Billing_Contact__c != oldContactsMap.get(con.Id).Billing_Contact__c) 
                            || (con.RecordTypeID != oldContactsMap.get(con.Id).RecordTypeID)) { 
                        conMap.put(con.Email, con);
                    }
                }
            }
        }
        System.Debug('Map to be processed: ' + conMap);
        
        //Map contains atleast one contact
        if (!conMap.isEmpty()) {
            // Using a single database query, find all the External Contacts in the database that have the same email address as 
            //any of the leads being inserted or updated. 
            List <Contact> contacts = [SELECT Email,CRM_ID__c FROM Contact WHERE RecordTypeID = :extRecordTypeID and Email IN :conMap.KeySet()];
            for (Contact con : contacts) {     
                Contact newCon = conMap.get(con.Email); 
                System.Debug('Existing found is  con : ' + con );
                System.Debug('Existing found is  newCon: ' + newCon );
                
                 //Contact exists in the map
                if (newCon != null && con.ID != newCon.ID) {
                    newCon.Email.addError(Label.Duplicate_Contact_Error_Message + ' ' + con.CRM_ID__c); 
                }
            }
            util_globalUtilityMethods.CheckrestrictDupExternalContacts = TRUE; //Setting value so that trigger does not call this method again and again
        }
    } //restrictDupExternalContacts
    
    
    //00008792 - Ritu Sharma - This function will populate contact publication field of the contact object
    //200219 - Chintan Adhyapak, August 25, 2015. Rewritten
    public static void populateContactPublicationInfo(List<Contact_Publication__c> newRecords, List<Contact_Publication__c> oldRecords) {
        //Variable Declaration
        List <String> contactIdList = new List<String>();
        Map <Id, Contact> contactMap = null;
        List<Contact_Publication__c> contactPublicationList = new List<Contact_Publication__c> ();
        integer totalRecords  = (newRecords == null) ? oldRecords.size() : newRecords.size();
        
        //Loop through incoming records
        for(integer i=0; i<totalRecords; i++) {
            if (trigger.isUpdate) { 
                System.debug('CPA In Update populateContactPublicationInfo');                   
                //Checking if user has changed the contact
                if (newRecords[i].Associated_Contacts__c != oldRecords[i].Associated_Contacts__c) {
                    //Both old and new contactMap will need to be updated
                    contactIdList.add(newRecords[i].Associated_Contacts__c);
                    contactIdList.add(oldRecords[i].Associated_Contacts__c);
                }
                
                //Checking if user has actually updated the publication record
                if (newRecords[i].Country__c != oldRecords[i].Country__c || newRecords[i].Publications__c != oldRecords[i].Publications__c) { 
                    contactIdList.add(newRecords[i].Associated_Contacts__c);
                }
            } else if(trigger.isDelete) {
                contactIdList.add(oldRecords[i].Associated_Contacts__c);
            } else //Record is created or undeleted
            {
                System.debug('CPA In Else Condition populateContactPublicationInfo');
                contactIdList.add(newRecords[i].Associated_Contacts__c);
            }
        }
        
        //anything to process
        if (contactIdList.size() == 0) return;
        
        //Get handle on contacts that are not Inactive due to validation rule that prevents update to Inactive contacts
        contactMap = new Map <Id, Contact>([Select Id, Contact_Publication__c, Contact_Status__c from Contact where Contact_Status__c <> 'Inactive' and Id in :contactIdList]);
            
        //If no active contacts in this list, you are done
        if (contactMap.size() == 0) return;
            
        //Get all contact publication records tied to these active contacts
        contactPublicationList = [Select Id, Associated_Contacts__c, Country__c, Publications__c from Contact_Publication__c where Associated_Contacts__c in :contactMap.values()];
        
        //Remove the existing value of Contact Publication field
        for (Contact myContact : contactMap.values()) {
        	myContact.Contact_Publication__c = '';
		}

        //Loop to populate Contact Publication field
        for (Contact_Publication__c myPublication : contactPublicationList) {
        	Contact myContact = contactMap.get(myPublication.Associated_Contacts__c);
            if (myContact.Contact_Publication__c == '' || myContact.Contact_Publication__c == null)
            	myContact.Contact_Publication__c = myPublication.Country__c + valueSep + myPublication.Publications__c;
			else
            	myContact.Contact_Publication__c += recordSep + myPublication.Country__c + valueSep + myPublication.Publications__c;
		}
        //Update
        try{
            update contactMap.values();
        }catch(Exception ex){
            System.debug(ex);
        }
        
    } //populateContactPublicationInfo
    
    
    
    //00008792 - Ritu Sharma - This function will populate contact segmentation field of the contact object
    //200219 - Chintan Adhyapak, August 25, 2015. Rewritten
    public static void populateContactSegmentationInfo(List<Contact_Segmentation__c> newSegments, List<Contact_Segmentation__c> oldSegments) {
        //Variables Declaration
        List<Id> contactIdList = new List<Id> ();
        List<Contact_Segmentation__c> segmentList = new List<Contact_Segmentation__c> ();
        integer totalRecords  = (newSegments == null) ? oldSegments.size() : newSegments.size();
        
        //Loop through all records
        for(integer i=0; i<totalRecords; i++) {
            if (trigger.isUpdate) { 
                System.debug('In Update');                   
                //Check if user has changed the contact
                if (newSegments[i].Associated_Contact__c != oldSegments[i].Associated_Contact__c) {
                    //Both old and new contactsMap will need to be updated
                    contactIdList.add(newSegments[i].Associated_Contact__c);
                    contactIdList.add(oldSegments[i].Associated_Contact__c);
                }
                
                //Check if user has actually updated the segmentation record
                if (newSegments[i].Country__c != oldSegments[i].Country__c || newSegments[i].Segment__c != oldSegments[i].Segment__c || 
                        newSegments[i].Sub_Segment__c != oldSegments[i].Sub_Segment__c) { 
                    contactIdList.add(newSegments[i].Associated_Contact__c);
                }
            } else if(trigger.isDelete) {
                contactIdList.add(oldSegments[i].Associated_Contact__c);
            } else //Record is inserted or undeleted
            {
                System.debug('In Else Condition');
                contactIdList.add(newSegments[i].Associated_Contact__c);
            }
        }
        
        //Anything to update
        if (contactIdList.isEmpty()) return; 
        
        //Pull only those contacts that are not Inactive due to validation rule that prevents update to Inactive contacts
        Map<Id, Contact> contactMap = new Map <Id, Contact>([Select Id, Contact_Segmentation__c from Contact where Contact_Status__c <> 'Inactive' and Id in :contactIdList]);
        
        //If no active contacts in this list, you are done
        if (contactMap.size() == 0) return;
                    
        //pull all contact segment records for these active contacts
        segmentList = [Select Id, Associated_Contact__c, Country__c, Segment__c, Sub_Segment__c from Contact_Segmentation__c where Associated_Contact__c in :contactIdList];
        
        //Clear existing value in contact segmentation field
        for (Contact myContact : contactMap.values()) {
        	myContact.Contact_Segmentation__c = '';
		}
        
        //Loop through the contact segment list
        for(Contact_Segmentation__c mySegment : segmentList) {
        	//Pull the contact tied to this segment            
            Contact myContact = contactMap.get(mySegment.Associated_Contact__c);
            if (myContact.Contact_Segmentation__c == '' || myContact.Contact_Segmentation__c == null)
            	myContact.contact_Segmentation__c = mySegment.Country__c + valueSep + mySegment.Segment__c + valueSep + mySegment.Sub_Segment__c;
            else
            	myContact.Contact_Segmentation__c += recordSep + mySegment.Country__c + valueSep + mySegment.Segment__c + valueSep + mySegment.Sub_Segment__c;
		}
        //Update
        update contactMap.values();          
    } //populateContactSegmentationInfo
    
    
    
    //00008792 - Ritu Sharma - This function will populate contact relationship field of the contact object
    //200219 - Chintan Adhyapak, August 25, 2015. Rewritten
    public static void populateContactRelationshipInfo(List<Contact_Relationship__c> newRecords,List<Contact_Relationship__c> oldRecords) {
        //Variables Declaration
        List <String> contactIds = new List<String>();
        List <Contact_Relationship__c> relationshipList = new List<Contact_Relationship__c> ();        
        integer totalRecords  = (newRecords == null) ? oldRecords.size() : newRecords.size();
        
        //Loop through all records
        for(integer i=0; i<totalRecords; i++) {
            if (trigger.isUpdate) { 
                if (newRecords[i].Also_Known_To__c != oldRecords[i].Also_Known_To__c || newRecords[i].Relationship_Type__c != oldRecords[i].Relationship_Type__c) { 
                    contactIds.add(newRecords[i].Contact__c);
                }
            } else if(trigger.isDelete) {
                contactIds.add(oldRecords[i].Contact__c);
            } else //Record is created or undeleted 
            {
                contactIds.add(newRecords[i].Contact__c);
            }
        }
        
        //Anything to process
        if (contactIds.size() == 0) return; 
            
		//Pull only those contacts that are not Inactive due to validation rule that prevents update to Inactive contacts
        Map<Id,Contact> contactMap = new Map<Id,Contact> ([Select Id, Contact_Relationship__c from Contact where Contact_Status__c <> 'Inactive' and Id in :contactIds]);
        
        //If no active contacts in this list, you are done
        if (contactMap.size() == 0) return;
        
        //Pull Contact Relationships for these contacts
        relationshipList = [Select Id, Contact__c, Relationship_Type__c, Also_Known_To__c, Also_Known_To_Name__c from Contact_Relationship__c where Contact__c in :contactIds];
        
		//Clear out the existing value in Contact Relationship field
        for(Contact myContact : contactMap.values()) {
        	myContact.Contact_Relationship__c = '';
		}
                    
        //Loop through Contact Relationship list
        for(Contact_Relationship__c myRelationship : relationshipList) {
        	//Pull contact tied to this segment
            Contact myContact = contactMap.get(myRelationship.Contact__c);
            if (myContact.Contact_Relationship__c == '' || myContact.Contact_Relationship__c == null)
            	myContact.Contact_Relationship__c = myRelationship.Also_Known_To_Name__c + valueSep + myRelationship.Relationship_Type__c;
            else
            	myContact.Contact_Relationship__c += recordSep + myRelationship.Also_Known_To_Name__c + valueSep + myRelationship.Relationship_Type__c;
		}
            
        //Update Contacts
        update contactMap.values();
    } //populateContactRelationshipInfo
    
    
    
    /** Method to synchronize the quarterly target amounts between contact and user records
      * SunnyM, November 28, 2012. Case 00010091 */
    public static void syncUsersWithInternalContactsRecords(List <Contact> newContacts, List <Contact> oldContacts) {
        //Declare local vars
        List<User> usersToUpdate = new List<User> ();
        Id internalContactRecordId = util_sampleDataGenerator.getRecordType('Contact', 'Internal Contact Record Type').Id;

        //Loop through and process records
        for (integer x = 0; x < newContacts.size(); x++) {
            Contact newContact = newContacts[x];

            //Is there a need to do anything
            if (newContact.RecordTypeId == internalContactRecordId && newContact.Corresponding_User_Id__c != null) {
            
                if(trigger.isUpdate) {
                    Contact oldContact = oldContacts[x];
                    //00046913 Begin - Sunny Mohla - This code will synchronize fields from Contact onto Corresponding User Record
                        System.debug('Found Update Associate ID' + newContact.Associate_ID__c);
                        User myUser = new User(Id = newContact.Corresponding_User_Id__c);
                        myUser.Associate_ID__c = newContact.Associate_ID__c;
                        myUser.Reporting_Practice__c = newContact.Reporting_Practice__c;
                        myUser.ARS_Function__c = newContact.Functional_Role__c;
                        //Commenting out below. Chintan, Sep 12, 2014
                        //myUser.Internal_Contact_Id__c = newContact.ID;
                    //00046913 End - Sunny Mohla - This code will synchronize fields from Contact onto Corresponding User Record
                    if((newContact.Q1_Target__c != oldContact.Q1_Target__c) || (newContact.Q2_Target__c != oldContact.Q2_Target__c) || 
                            (newContact.Q3_Target__c != oldContact.Q3_Target__c) || (newContact.Q4_Target__c != oldContact.Q4_Target__c)) {
                        myUser.Q1_Target__c = newContact.Q1_Target__c;
                        myUser.Q2_Target__c = newContact.Q2_Target__c;
                        myUser.Q3_Target__c = newContact.Q3_Target__c;
                        myUser.Q4_Target__c = newContact.Q4_Target__c;
                                           }
                      usersToUpdate.add(myUser);

                } else if(trigger.isInsert) {
                 //00046913 Begin - Sunny Mohla - This code will synchronize fields from Contact onto Corresponding User Record
                   System.debug('Found Insert Associate ID' + newContact.Associate_ID__c);
                   User myUser = new User(Id = newContact.Corresponding_User_Id__c);
                   myUser.Associate_ID__c = newContact.Associate_ID__c;
                   myUser.Reporting_Practice__c = newContact.Reporting_Practice__c;
                   myUser.ARS_Function__c = newContact.Functional_Role__c;
                   myUser.Internal_Contact_Id__c = newContact.ID;
                   myUser.Q1_Target__c = newContact.Q1_Target__c;
                   myUser.Q2_Target__c = newContact.Q2_Target__c;
                   myUser.Q3_Target__c = newContact.Q3_Target__c;
                   myUser.Q4_Target__c = newContact.Q4_Target__c;
                 //00046913 End - Sunny Mohla - This code will synchronize fields from Contact onto Corresponding User Record
                   usersToUpdate.add(myUser);
                }
            }
        }
        
        //Update users
        if (usersToUpdate.size() > 0) {
            // Case 00103100 Fix Test Classes - it causes MIXED_DML_OPERATION exception in test code 
            // Jean Hsiung, Dec. 05, 2013
            //update usersToUpdate;
            if (Test.isRunningTest()) {
                System.runAs(new User(Id = Userinfo.getUserId())) {
                    update usersToUpdate;
                }
            } else {
                update usersToUpdate;
            }
            // End of Case 00103100 Fix Test Classes
        }
    } //syncUsersWithInternalContactsRecords
}