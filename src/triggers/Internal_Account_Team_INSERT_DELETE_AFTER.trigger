trigger Internal_Account_Team_INSERT_DELETE_AFTER on Internal_Account_Team__c (after delete, after insert) {
	//Maintain Account Team
	blogic_Account.updateAccountTeam(trigger.old, trigger.new);
	
	//Copy Executive Sponsor to Account
	blogic_Account.copyExecutiveSponsor(trigger.old, trigger.new);
}