trigger Contact_UPDATE_AFTER on Contact (after update) {
    // sync user ids on contact if the associate ids changed
    //blogic_UserContactSync.syncUsersWithInternalContactsRecords(trigger.new, trigger.old);

    // Code added by SunnyM for Case 00010091
    blogic_Contact.syncUsersWithInternalContactsRecords(trigger.new, trigger.old);
}