trigger OpportunityLineItem_DELETE_AFTER on OpportunityLineItem (after delete) {
	// delete corresponding opportunity product records
	blogic_Opportunity.deleteShadowOpportunityProducts(trigger.old);
	
	//Synchronize associated services in RFP tied to lead Opp. Case 78812, August 22, 2013. Chintan
	blogic_ProposalRequest.syncAssociatedServices(trigger.old);
	
	//Update Bundled Totals. Case 69299, October 03, 2013. Chintan
	blogic_Opportunity.syncBundledTotals(null, trigger.old);
}