trigger SalesCredit_DELETE_AFTER on Sales_Credit__c (before delete) {
	// delete corresponding sales team members
	blogic_Opportunity.deleteSalesTeamMember(trigger.old);
	
	// delete the corresponding xref entries
	blogic_Opportunity.deleteXrefEntries(trigger.old);
}