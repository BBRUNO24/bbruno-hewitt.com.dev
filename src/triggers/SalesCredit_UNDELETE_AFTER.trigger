trigger SalesCredit_UNDELETE_AFTER on Sales_Credit__c (after undelete) {
	// create sales team entries for undeleted records
	blogic_Opportunity.createSalesTeamMember(trigger.new);
	
	// create xref entries
	blogic_Opportunity.createSalesTeamCreditXrefEntries(trigger.new);
}