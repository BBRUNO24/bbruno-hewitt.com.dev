public class ctlr_AccountPlanGatekeeper {
	/* class attributes */
	private Account currAccount		{get;set;}

	/* constructor */
	public ctlr_AccountPlanGatekeeper(ApexPages.StandardController controller) {
		currAccount = (Account)controller.getRecord();
		currAccount = [SELECT Id, Name, Market__c FROM Account WHERE Id = :currAccount.Id];
	}
	
	/* action method */
	public PageReference checkAccess() {
		//local vars
		String accountId = currAccount.Id;
		String market = currAccount.Market__c;
		String userId = UserInfo.getUserId();
		Account_Data_View__c appSettings = Account_Data_View__c.getInstance();
		
		//debug
		System.debug('checkAccess BEGIN. AccountId: ' + accountId + 'UserId: ' + userId + 'Market: ' + market);
		
		//declare local vars
		PageReference redirect = null;
		Boolean found = false;
		
		//ensure we have the necessary info to proceed
		if ((accountId != null) && (accountId != '') && (userId != null) && (userId != '')) {
			//Is user profile set to bypass check 
			if (appSettings.Revenue_Visibility_Override__c) { found = true; }
			System.debug('CPA App Settings found: ' + found);
			//Is user part of the Internal Account Team
			if (!found) {
				List <Internal_Account_Team__c> teamMembers = [select id from Internal_Account_Team__c where (Account__c = :accountId or Account__c = :accountId.substring(0,15)) and (User_ID__c = :userId or User_ID__c = :userId.substring(0, 15))];
				System.debug('Internal Account Team retrieved: ' + teamMembers);
				if (!teamMembers.isEmpty()) { found = true; }
				System.debug('CPA Internal Account Team found: ' + found);
			}
			if (!found) {
				//Is the current user tied to the market
				List<Zip_Code_to_Market_Mapping__c> zipList = [Select Market__c, Market_Lead__c, Region_Director__c from Zip_Code_to_Market_Mapping__c 
						Where Market__c = :market and (Market_Lead__c = :userId or Region_Director__c = :userId)];
				if (!zipList.isEmpty()) {
					System.debug('CPA Found Zip Record: ' + zipList[0].Market__c);
					found = true;
				}
				if (!found) {
					List<Revenue_Access_List_Member__c> accessList = [Select User__c, Zip_to_Market__r.Market__c from Revenue_Access_List_Member__c 
							Where Zip_to_Market__r.Market__c = :market and User__c = :userId];
					if (!accessList.isEmpty()) {
						System.debug('CPA Found Access List Record: ' + accessList);
						found = true;
					}
				}
			}
			if (found) {
				//pass them on to the Revenue Page
				redirect = new PageReference('/apex/AccountPlan?id=' + accountId);
				redirect.setRedirect(true);
			}
		}
		//return the redirect
		System.debug('CPA Returning: ' + redirect);
		return redirect;
	}
}