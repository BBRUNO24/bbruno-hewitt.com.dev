trigger Account_UPDATE_BEFORE on Account (before update) {
    //Perform CAPIS ID maintenance as required - Chintan Adhyapak 06/10/2011
    blogic_Account.assignCapisId(trigger.new);
    
    //Perform Automatic Market and Region Mapping
    blogic_Account.updateAccountRegionMarket(trigger.old, trigger.new);
    
    //Tie the Account to its matching territory and public group
	blogic_Account.updateAccountTerritory(trigger.old, trigger.new);
	
	//Autofill Data
	blogic_Account.autofillData(trigger.old, trigger.new);
}