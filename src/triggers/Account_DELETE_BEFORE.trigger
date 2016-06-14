trigger Account_DELETE_BEFORE on Account (before Delete) 
{    
    //00084624-Ritu Sharma-Add account owner as IAT member in all accounts of that hierarchy
    //blogic_Account.addOwnersAsTeamMembers(trigger.old,Null);
}