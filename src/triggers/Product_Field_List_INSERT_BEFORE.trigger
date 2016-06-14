trigger Product_Field_List_INSERT_BEFORE on Product_Field_List__c (before insert) {
	// scrub the list to ensure fields are correct and case sensitive
	blogic_OpportunityUIConfiguration.validateFieldNames(trigger.new);
	
	// derive unique identifiers for all of the records based on the field values
	blogic_OpportunityUIConfiguration.deriveUniqueIdentifiers(trigger.new);
}