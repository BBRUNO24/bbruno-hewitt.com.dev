public class ctlr_MobileOpportunitySalesCredit {

	public Sales_Credit__c salesCredit { get; set; }
	public Opportunity opp { get; set; }
	public List<Sales_Credit__c> addedSalesCredit { get; set; }
	public SLDS_Toast mytoast { get; set; }

	public ctlr_MobileOpportunitySalesCredit() {
		addedSalesCredit = new List<Sales_Credit__c>();
		salesCredit = new Sales_Credit__c();
	}

	public PageReference addSalesCredit(){
        try{
        	System.debug('salesCredit: ' + salesCredit);
        	//SAVE SALES CREDIT
        	salesCredit.Id = null;
            salesCredit.Related_Opportunity__c = opp.Id;
            insert(salesCredit);

            //REQUERY SO WE CAN PULL THE NAME FOR DISPLAY PURPOSES IN THE UI
            salesCredit = [SELECT Id, NAME FROM Sales_Credit__c WHERE ID = :salesCredit.Id];
            addedSalesCredit.add(salesCredit);

            //RESET SALES CREDIT SO WE CAN ADD MULTIPLE CREDITS
            salesCredit = new Sales_Credit__c();

        } catch(Exception ex){
            System.debug('Exception: ' + ex);
            
            mytoast.showToast = true;
            mytoast.toastMsg = ex.getMessage();
            mytoast.toastType = SLDS_ToastEnum.ERROR;
            //displayToast(true, ex.getMessage(), SLDS_ToastEnum.ERROR);
        }

        return null;
    }
}