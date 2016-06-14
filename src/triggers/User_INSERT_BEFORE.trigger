trigger User_INSERT_BEFORE on User (before insert) {

    // mark active timestamps
    blogic_Opportunity.markActiveDateStamp(trigger.new, null);

    // stamp users with any corresponding internal contact ids
    //blogic_UserContactSync.syncUsersWithInternalContacts(trigger.new, null);

}