trigger Opportunity_DELETE_AFTER on Opportunity (after delete) {
	//Synchronize associated services in RFP tied to lead Opp. Case 78812, August 27, 2013. Chintan
	blogic_ProposalRequest.syncAssociatedServices(null, trigger.old);
	
	//Calculate Totals for all bundled opps on the lead opp. Case 69299, September 30, 2013. Chintan
	blogic_Opportunity.syncBundledTotals(trigger.old, null);
}