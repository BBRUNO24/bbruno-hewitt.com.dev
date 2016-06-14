trigger Opportunity_INSERT_AFTER on Opportunity (after insert) {
	 //Ritu Sharma - Case # 00010036 - Update status of marketing lead if opp has been created from marketing lead page
    blogic_Opportunity.updateMarketingLeadStatus(trigger.new);
    
	//Synchronize associated services in RFP tied to lead Opp. Case 78812, August 22, 2013. Chintan
	blogic_ProposalRequest.syncAssociatedServices(trigger.new, null);

	AccountTeam.updateAccountTeamMembers(null, Trigger.newMap);
}