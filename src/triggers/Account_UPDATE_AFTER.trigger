trigger Account_UPDATE_AFTER on Account (after update) {
    //Add Account Owner to Internal Account Team
    blogic_Account.updateInternalAccountTeam(trigger.old, trigger.new);
}