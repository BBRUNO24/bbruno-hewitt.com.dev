trigger Contact_INSERT_AFTER on Contact (after insert) {
    // sync user ids on contact if the associate ids changed 
    //blogic_UserContactSync.syncUsersWithInternalContactsRecords(trigger.new, null);  
    
    // Code added by SunnyM for Case 00010091
    blogic_Contact.syncUsersWithInternalContactsRecords(trigger.new, null);
}