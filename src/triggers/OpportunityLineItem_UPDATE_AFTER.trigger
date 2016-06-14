trigger OpportunityLineItem_UPDATE_AFTER on OpportunityLineItem (after update) {
	// complete update of corresponding opportunity product record
	blogic_Opportunity.updateShadowOpportunityProducts(trigger.new);
	
	//Update Bundled Totals. Case 69299, October 03, 2013. Chintan
	blogic_Opportunity.syncBundledTotals(trigger.new, trigger.old);
}