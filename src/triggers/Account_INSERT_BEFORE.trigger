trigger Account_INSERT_BEFORE on Account (before insert) {
	//Perform Automatic Market and Region Mapping
	blogic_Account.setAccountRegionMarket(trigger.new);
	
	//Tie the Account to its matching territory
	blogic_Account.tieAccountToTerritory(trigger.new);
	
	//Autofill Data
	blogic_Account.autofillData(trigger.old, trigger.new);
	
	//Perform CAPIS ID maintenance as required - Chintan Adhyapak 06/10/2011
	blogic_Account.assignCapisId(trigger.new);
}