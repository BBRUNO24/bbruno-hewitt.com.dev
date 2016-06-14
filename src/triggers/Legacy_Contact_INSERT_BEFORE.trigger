trigger Legacy_Contact_INSERT_BEFORE on Legacy_Contact__c (before insert) {

	// relate to accounts when possible
	//blogic_PSFT.relateToExistingContacts(trigger.new, LoggingLevel.INFO);
}