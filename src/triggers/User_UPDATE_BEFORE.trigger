trigger User_UPDATE_BEFORE on User (before update) {

    // mark active timestamps
    blogic_Opportunity.markActiveDateStamp(trigger.new, trigger.old);  
 
    // stamp users with any corresponding internal contact ids
    //blogic_UserContactSync.syncUsersWithInternalContacts(trigger.new, trigger.old); 

}