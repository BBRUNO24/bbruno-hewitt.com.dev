public without sharing class ctrl_AccountPreview {

	/*
	to preview the selected account detail information
	*/
	private String accountIdToPreview						{get;set;}
	public Account previewAccount 							{get;set;}
	public Set<ID> oppIdSet 								{get;set;}
	public List<OpportunityLineItem> accntOpptnityItemList 	{get;set;}
	
	public ctrl_AccountPreview(ApexPages.StandardController stdController) {
		this.previewAccount = (Account)stdController.getRecord();
		this.accountIdToPreview = '';
	}
	
	public PageReference init() {
		//get selected account id
		this.accountIdToPreview = ApexPages.currentPage().getParameters().get('acctid');
		PageReference redirect = null;
		
		if(this.accountIdToPreview  == null || this.accountIdToPreview.length() < 14){
			redirect  = Page.FileNotFound;
		}else{
			//get all account, contact, opportunity and product detail information 
			this.previewAccount = [Select id, (Select LastName, FirstName, Phone, Email, Title, Owner_Full_Name__c, Owner_Email__c From Contacts), (Select Id, Name, Amount, ExpectedRevenue, CloseDate, IsClosed, CurrencyIsoCode, Status__c, StageName, Owner.Name, Owner.Email, Owner.Phone From Opportunities), name, acw_client_type__c, DunsNumber, BillingStreet, BillingState, BillingPostalCode, BillingCountry, BillingCity, Owner.Name, Owner.Email from Account Where Id = : this.accountIdToPreview];
		    System.debug('ctrl_AccountPreview:this.accountIdToPreview '+this.accountIdToPreview);
		 
		  	//get opportunity item list for selected account
			this.accntOpptnityItemList = [Select TotalPrice, PricebookEntry.Name, Practice__c, ServiceDate  From OpportunityLineItem Where Opportunity.AccountId = : this.accountIdToPreview And CreatedDate > LAST_N_YEARS:2 LIMIT 1000];
		}
    	
		return redirect;
	}
}