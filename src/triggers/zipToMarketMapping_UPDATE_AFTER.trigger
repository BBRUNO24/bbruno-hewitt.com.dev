trigger zipToMarketMapping_UPDATE_AFTER on Zip_Code_to_Market_Mapping__c (after update) {
	//Update all Accounts if Market Lead or Region Director is updated
	blogic_Account.updateMarketLeadRegionDirector(trigger.old, trigger.new);
}