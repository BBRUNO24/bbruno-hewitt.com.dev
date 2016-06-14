trigger SalesCredit_INSERT_AFTER on Sales_Credit__c (after insert) {
	// create junction records where necessary
	blogic_Opportunity.createSalesTeamCreditXrefEntries(trigger.new);
	// create sales team members where necessary
	blogic_Opportunity.createSalesTeamMember(trigger.new);
}