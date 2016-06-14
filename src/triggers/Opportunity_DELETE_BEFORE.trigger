trigger Opportunity_DELETE_BEFORE on Opportunity (before delete) {
	// Verify that User has perission to delete as per Case 2715
	blogic_Opportunity.verifyDeleteAuthority(trigger.old);
}