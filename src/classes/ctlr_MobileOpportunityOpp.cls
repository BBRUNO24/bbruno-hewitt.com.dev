public with sharing class ctlr_MobileOpportunityOpp {

	public Opportunity opp { get; set; }
	public List<SelectOption> competitorOptions { get; set; }
	public String tabToShow { get; set; }
	public SLDS_Toast myToast { get; set; }

	public ctlr_MobileOpportunityOpp() {
        this.competitorOptions = LightningMobileOppUtil.getPickValues(new Opportunity(), 'Competitor__c', '--None--');
	}

	public PageReference goToProducts(){
        System.debug('opp: ' + opp);
        try{
            if(opp.AccountId != null){
                System.debug('opportunity: ' + opp);

                //SET PRICEBOOK FOR OPPORTUNITY
                LightningMobileOppUtil.setPricebook(opp);
                this.tabToShow = 'Products';
                System.debug(this.tabToShow);
                this.myToast.showToast = false;
            }else{
                displayToast(true, 'Please select an account before you continue.', SLDS_ToastEnum.ERROR);
                this.tabToShow = 'Opportunity';
                System.debug(this.tabToShow);
            }
        } catch(Exception ex) {
        	displayToast(true, ex.getMessage(), SLDS_ToastEnum.ERROR);
        }

        return null;
    }

    public void displayToast(Boolean show, String msg, SLDS_ToastEnum type){
        this.myToast.showToast  = show;
        this.myToast.toastMsg = msg;
        this.myToast.toastType = type;
    }

    public String selectedOpportunityStage {get;set;}
    public PageReference rerenderStageFields(){
        opp.StageName = selectedOpportunityStage;
        system.debug('Opportunity: ' + JSON.serialize(opp));
        return null;
    }    
}