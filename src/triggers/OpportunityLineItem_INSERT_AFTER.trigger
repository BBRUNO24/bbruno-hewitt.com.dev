trigger OpportunityLineItem_INSERT_AFTER on OpportunityLineItem (after insert) {
	// complete update of corresponding opportunity product record
	blogic_Opportunity.updateShadowOpportunityProducts(trigger.new);
	
	// create junction records where necessary
	blogic_Opportunity.createSalesTeamCreditXrefEntries(trigger.new);
	
	//Synchronize associated services in RFP tied to lead Opp. Case 78812, August 22, 2013. Chintan
	blogic_ProposalRequest.syncAssociatedServices(trigger.new);
	
	//Update Bundled Totals. Case 69299, October 03, 2013. Chintan
	blogic_Opportunity.syncBundledTotals(trigger.new, null);
}