public with sharing class ctlr_OpposingOrgViewGateKeeper {

	/* class attributes */
	private String accountId					{get;set;}
	private String userId						{get;set;}
	private AccountCreateProcess__c appSettings {get;set;}

	/* constructor */
	public ctlr_OpposingOrgViewGateKeeper() {
		this.accountId = ApexPages.currentPage().getParameters().get('accountid');		
		this.userId = UserInfo.getUserId(); 
		this.appSettings = AccountCreateProcess__c.getInstance();
	}
	
	/* action method */
	public PageReference checkAccountTeamMembership() {
		
		// debug
		System.debug('checkAccountTeamMembership BEGIN');
		System.debug('accountId: ' + this.accountId);
		System.debug('userId: ' + this.userId);
		
		// declare local vars
		PageReference redirect = null;
		
		// ensure we have the necessary info to proceed
		if ((this.accountId != null) && (this.accountId != '') && (this.userId != null) && (this.userId != '')) {
		
			// retrieve account details
			System.debug('retreiving account details...');
			List <Account> accountDetails = [select id, Opposite_Org_Account_ID__c from Account where id = :this.accountId];
			System.debug('retrieved: ' + accountDetails);
			
			// ensure a record was retruned and an opposing account id was located
			if ((!accountDetails.isEmpty()) && (accountDetails[0].Opposite_Org_Account_ID__c != null)) {
				redirect = new PageReference(this.appSettings.PreviewAccount__c + 'acctid=' + accountDetails[0].Opposite_Org_Account_ID__c);
				
				//Commenting for Case 7826. Chintan, January 24, 2012
/*
				// check to see if the current user has a corresponding contact record
				System.debug('retreiving user details...');
				List <User> userDetails = [select id, Internal_Contact_Id__c from User where Id =:this.userId];
				System.debug('retrieved: ' + userDetails);
				
				if (!userDetails.isEmpty()) {
					if (userDetails[0].Internal_Contact_Id__c != null || this.appSettings.Account_Team_Scrub_Override__c) {
						
						// declare vars
						List <Internal_Account_Team__c> teamMembers  = new List <Internal_Account_Team__c>();
						
						// look to see if the internal contact exists on the account team for the received account
						if (userDetails[0].Internal_Contact_Id__c != null) {
							System.debug('retrieving internal account team member info...');
							teamMembers = [select id from Internal_Account_Team__c where Account__c = :this.accountId and Contact__c = :userDetails[0].Internal_Contact_Id__c];
							System.debug('retrieved: ' + teamMembers);
						}
						if (!teamMembers.isEmpty() || this.appSettings.Account_Team_Scrub_Override__c) {
							// pass them on to the ARS View
							redirect = new PageReference(this.appSettings.PreviewAccount__c + 'acctid=' + accountDetails[0].Opposite_Org_Account_ID__c);
						}
					}
				}
*/				
			}
		}
		
		// return the redirect
		return redirect;
	}
}