trigger Sales_Credit_UPDATE_BEFORE on Sales_Credit__c (before update) {
	// derive unique identifiers for all of the records based on the field values
	blogic_Opportunity.verifyUniqueLeadConsultant(trigger.new);
}