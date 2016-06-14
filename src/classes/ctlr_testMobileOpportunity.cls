public with sharing class ctlr_testMobileOpportunity {
	public Opportunity opp { get; set; }
	public SLDS_Toast toast { get; set; }
	public String activeTab { get { return 'slds-tabs__item slds-tabs--default__item slds-text-heading--label slds-active'; } }
    public String inactiveTab { get { return 'slds-tabs__item slds-tabs--default__item slds-text-heading--label'; } }
	private user currentUser;

    public Boolean showSalesCredit{
        get{
            if(this.currentUser.Reporting_Country__c == 'United States'){
                return true;
            }else{
                return false;
            }
        }
    }

    private String currentTab;
    public String tabToShow { get; set; }

	public ctlr_testMobileOpportunity() {
        System.debug('ctlr_testMobileOpportunity controller...');
		this.opp = new Opportunity();
        System.debug('Opportunity: ' + this.opp);
		this.toast = new SLDS_Toast();
		this.currentUser = [SELECT Id, Reporting_Country__c FROM User where Id=:UserInfo.getUserId()];
        this.tabToShow = 'Opportunity';
	}
}