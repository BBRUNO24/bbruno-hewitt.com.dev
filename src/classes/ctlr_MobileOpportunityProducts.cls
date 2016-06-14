public with sharing class ctlr_MobileOpportunityProducts {

	public Opportunity newOpp { get; set; }
	public List<SelectOption> productOptions { get; set; }
    public String productSelection { get; set; }
	public String practiceSelection { get; set; }
	public OpportunityLineItem currOLI { get; set; }
	public List<OpportunityLineItem> addedOLI { get; set; }
	public List<PricebookEntry> pbEntryList { get; set; }
	public Boolean showSalesCredit { get; set; }
	public String tab { get; set; }
	public SLDS_Toast myToast { get; set; }

    public List<SelectOption> testPracticeOptions;
    public List<SelectOption> practiceOptions{ 
        get{
            if(testPracticeOptions == null){
                testPracticeOptions = LightningMobileOppUtil.getPracticeOptions(newOpp.Pricebook2Id);
            }
                return testPracticeOptions;
            }
            set{ this.testPracticeOptions = value; }
        }

	public ctlr_MobileOpportunityProducts() {
        
		this.currOLI = new OpportunityLineItem();
		this.addedOLI = new List<OpportunityLineItem>();
		this.pbEntryList = new List<PricebookEntry>();
	}

    public PageReference refreshPracticeOptions(){
        this.practiceOptions = LightningMobileOppUtil.getPracticeOptions(newOpp.Pricebook2id);
        return null;
    }

    public PageReference refreshProductOptions() {
        this.productOptions = LightningMobileOppUtil.getProductOptions(newOpp.Pricebook2id, practiceSelection);
        return null;
    }	

	public PageReference addProduct() {
       
        try{
                System.debug('practice selection is: ' + practiceSelection);
                System.debug('product selection is: ' + productSelection);

                if(practiceSelection == 'Please select a practice' || productSelection == 'Please select a product'){
                	displayToast(true, 'Please select a Practice and Product.', SLDS_ToastEnum.ERROR);
                    
                } else{
                    OpportunityLineItem oppProduct = new OpportunityLineItem();

                    List<PricebookEntry> peResults = [SELECT id, Name, Product2id, Pricebook2Id, CurrencyISOCode 
                        FROM PricebookEntry 
                        WHERE Product2id = :productSelection AND Pricebook2id = : newOpp.Pricebook2id];

                    System.debug('peResults: ' + peResults);

                    PricebookEntry currPE;
                    if (peResults.size() > 1) {
                        for (PricebookEntry pe : peResults) {
                            if (pe.CurrencyISOCode == UserInfo.getDefaultCurrency())
                                currPE = pe;
                        }
                    }
                    else {
                        currPE = peResults[0];
                    }

                    //ADD CURRENT PRICEBOOK ENTRY TO LIST  - THIS WILL BE USED FOR DISPLAY PURPOSES ON THE UI
                    pbEntryList.add(currPE);
                    System.debug('currPE: ' + currPE);

                    // populate off dummy record
                    oppProduct.OpportunityId = newOpp.id;
                    oppProduct.PricebookEntryId = currPE.id;
                    oppProduct.Recurring_Non_Recurring__c = currOLI.Recurring_Non_Recurring__c;
                    oppProduct.First_Year_Value__c = currOLI.First_Year_Value__c;
                    oppProduct.Type__c = currOLI.Type__c;
                    oppProduct.Fee_Commission__c = currOLI.Fee_Commission__c;
                    oppProduct.UnitPrice = currOLI.UnitPrice;

                    addedOLI.add(oppProduct);

                    System.debug('addedOLI:' + addedOLI);
                    myToast.showToast = false;
                }

               
        } catch(Exception ex){

            System.debug('Exception: ' + ex);
            displayToast(true, ex.getMessage(), SLDS_ToastEnum.ERROR);

        }

        return null;
    }    

	public PageReference saveWithProducts() {

        //CREATE A SAVEPOINT, IF THERE IS AN ERROR WE WANT TO ROLLBACK. WE DON'T WANT TO CREATE OPPORTUNITIES WITHOUT PRODUCTS
        Savepoint sp = Database.setSavepoint();

        try{
            insert newOpp;

            for (OpportunityLineItem o : addedOLI) {
                o.OpportunityId = newOpp.id;
            }

            insert addedOLI;

            system.debug('Added Products: ' + addedOLI);



        } catch(Exception ex){
            //ROLLBACK IF THERE ARE ANY ACCEPTIONS
            Database.Rollback(sp);
            System.debug('Exception: ' + ex);
            displayToast(true, ex.getMessage(), SLDS_ToastEnum.ERROR);
            return goToOpportunity();
        }
        

        if(showSalesCredit){
            return goToSalesCredit();
        } else {
            return navigateToOpportunity();
        }
         
    }    

    public PageReference goToOpportunity(){
        this.tab = 'Opportunity';
        return null;
    }

    public PageReference goToSalesCredit(){
        this.tab = 'SalesCredit';
        return null;
    }

    public PageReference navigateToOpportunity(){
        return new PageReference(URL.getSalesforceBaseUrl().toExternalForm() + '/' + newOpp.id);
    }    

    public void displayToast(Boolean show, String msg, SLDS_ToastEnum type){
        this.myToast.showToast  = show;
        this.myToast.toastMsg = msg;
        this.myToast.toastType = type;
    }    
}