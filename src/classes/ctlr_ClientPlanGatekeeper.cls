public with sharing class ctlr_ClientPlanGatekeeper {
	/* class attributes */
    private Annual_Account_Plan__c currPlan		{get; set;}

    /* constructor */
    public ctlr_ClientPlanGatekeeper(ApexPages.StandardController controller) {
        this.currPlan = (Annual_Account_Plan__c)controller.getRecord();
        currPlan = [SELECT Id, Account__c, Account__r.Market__c FROM Annual_Account_Plan__c WHERE ID = :currPlan.Id];
    }
    
    /* action method */
    public PageReference checkAccess() {
    	//local vars
    	String accountId = currPlan.Account__c;
    	String userId = UserInfo.getUserId();
    	String market = currPlan.Account__r.Market__c;
    	Account_Data_View__c appSettings = Account_Data_View__c.getInstance();
    	
		//debug
		System.debug('checkAccess BEGIN');
		System.debug('AccountId: ' + accountId);
		System.debug('UserId: ' + userId);
		System.debug('Market: ' + market);
		System.debug('Custom Setting: ' + appSettings);
		
		//declare local vars
		PageReference redirect = null;
		Boolean found = false;
        
        //ensure we have the necessary info to proceed
        if ((accountId != null) && (accountId != '') && (userId != null) && (userId != '')) {
			if (appSettings.Revenue_Visibility_Override__c) { found = true; }
			System.debug('CPA App Settings found: ' + found);
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
	            // pass them on to the Client Promise Plan Page
                redirect = new PageReference('/apex/ClientPromisePlanDocPdf?id=' + currPlan.Id);
                redirect.setRedirect(true);
        	}
		}
        // return the redirect
        System.debug('CPA Returning: ' + redirect);
        return redirect;
    }
}