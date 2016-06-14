trigger Opportunity_UPDATE_AFTER on Opportunity (after update) {
	//Flag to ensure only a single execution of the trigger code 
	System.debug('CPA Opp UPDATE AFTER Trigger - flag is: ' + util_globalUtilityMethods.getRunOnceFlag());
	if (!util_globalUtilityMethods.getRunOnceFlag()) {
		//Synchronize associated services in RFP tied to lead Opp. Case 78812, August 22, 2013. Chintan
		blogic_ProposalRequest.syncAssociatedServices(Trigger.new, Trigger.old);
		
		//Calculate Totals for all bundled opps on the lead opp. Case 69299, September 30, 2013. Chintan
		blogic_Opportunity.syncBundledTotals(Trigger.old, Trigger.new);

		AccountTeam.updateAccountTeamMembers(Trigger.oldMap, Trigger.newMap);
		//
	}
}