trigger Opportunity_Product_DELETE_AFTER on Opportunity_Product__c (after delete) {

	// delete corresponding entries in the sales credit xref table
	blogic_Opportunity.deleteXrefEntries(trigger.old); 

}