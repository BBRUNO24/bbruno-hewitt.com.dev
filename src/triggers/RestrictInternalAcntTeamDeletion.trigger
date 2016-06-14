trigger RestrictInternalAcntTeamDeletion on Internal_Account_Team__c (before delete) 
{
    RestrictInternalAcntTeamDeletionClass.restrictIntAcntTeam(Trigger.old);
}