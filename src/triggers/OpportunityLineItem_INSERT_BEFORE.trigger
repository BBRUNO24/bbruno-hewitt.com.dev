trigger OpportunityLineItem_INSERT_BEFORE on OpportunityLineItem (before insert) {
	// create the necessary shadow opportunity line item records
	blogic_Opportunity.createShadowOpportunityProducts(trigger.new);
}