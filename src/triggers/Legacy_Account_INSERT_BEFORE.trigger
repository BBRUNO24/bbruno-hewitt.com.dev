trigger Legacy_Account_INSERT_BEFORE on Legacy_Account__c (before insert) {

	// relate to accounts when possible
	//blogic_PSFT.relateToExistingAccounts(trigger.new, LoggingLevel.INFO);

}