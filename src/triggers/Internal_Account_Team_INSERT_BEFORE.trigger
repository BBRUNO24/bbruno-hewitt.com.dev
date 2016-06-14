trigger Internal_Account_Team_INSERT_BEFORE on Internal_Account_Team__c (before insert) {
	//Restrict Duplicates
	blogic_Account.checkDuplicateInternalAccountTeamEntry(Trigger.new);
}