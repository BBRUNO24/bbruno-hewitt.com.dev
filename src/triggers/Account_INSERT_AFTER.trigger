trigger Account_INSERT_AFTER on Account (after insert) {
    // create default entries for service providers
    blogic_ServiceProviders.createDefaultProviderEntries(trigger.new);
    
    // cut ties with any ARS-sourced records
    //blogic_OrgIntegration.severSharedAccountRelationshipsWithSourceOrg(trigger.new);
    
    //Tie Account to Public Group
    blogic_Account.tieAccountToPublicGroup(trigger.new);
    
    //Add Account Owner to Internal Account Team
    blogic_Account.updateInternalAccountTeam(null, trigger.new);
    
    //00084624-Ritu Sharma-Add account owner as IAT member in all accounts of that hierarchy
    //blogic_Account.addOwnersAsTeamMembers(null,trigger.new);
}