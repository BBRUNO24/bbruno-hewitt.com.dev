public with sharing class LightningMobileOppExtension {

    public LightningMobileOppExtension() {
        //this.pricebookSelection = 'Netherlands Price Book';
        //usersPricebook = [SELECT Name, Id FROM Pricebook2 WHERE Name = :pricebookSelection LIMIT 1];
        currentUser = [SELECT Id, Reporting_Country__c FROM User where Id=:UserInfo.getUserId() ];

        //INITIALIZE PROPERTIES
        this.opp = new Opportunity();       
        this.currOLI = new OpportunityLineItem();
        this.currOLI.Fee_Commission__c = 'Fee';
        this.salesCredit  = new Sales_Credit__c();
        this.addedOLI = new List<OpportunityLineItem>();
        this.addedSalesCredit = new List<Sales_Credit__c>();
        this.pbEntryList = new List<PricebookEntry>();
        this.toast = new SLDS_Toast();
        this.toast.showToast = false;
        this.toast.toastMsg = '';
        this.toast.toastType = SLDS_ToastEnum.BASE;
        this.disableSubmitButton = false;

        this.competitorOptions = LightningMobileOppUtil.getPickValues(opp, 'Competitor__c', null);
    }
    
    private user currentUser;
    
    public SLDS_Toast toast { get; set; }
    public Opportunity opp { get; set; }
    public Sales_Credit__c salesCredit { get; set; }
    public List<PricebookEntry> pbEntryList { get; set; }    
    public List<OpportunityLineItem> addedOLI { get; set; }
    public List<Sales_Credit__c> addedSalesCredit { get; set; }
    public OpportunityLineItem currOLI { get; set; }
    public Boolean disableSubmitButton { get; set; }

    private String currentTab;
    public String tabToShow { 
        get {
            if(String.isBlank(currentTab)){
                currentTab = 'Opportunity';
            }
            return currentTab;
        } 
        set { currentTab = value; }
    }

    public String activeTab { 
        get {
            return 'slds-tabs__item slds-tabs--default__item slds-text-heading--label slds-active';
        }
    }

    public String inactiveTab {
        get{
            return 'slds-tabs__item slds-tabs--default__item slds-text-heading--label';
        }
    }

    public String activePanel{
        get{
            return 'slds-tabs__content slds-tabs--default__content slds-show';
        }
    }

    public String inactivePanel{
        get{
            return 'slds-tabs__content slds-tabs--default__content slds-hide';
        }
    }    


    public Boolean showSalesCredit{
        get{
            if(currentUser.Reporting_Country__c == 'United States'){
                return true;
            }else{
                return false;
            }
        }
    }

    public List<OpportunityContactRole> contactRoles { get; set; }
    public void populateOpportunityContacts(){
        System.debug('contactRoles: ' + contactRoles);
        if(contactRoles == null && opp.AccountId != null){
            System.debug('Inside if Statement');
            List<Contact> contactsList = [SELECT Id FROM Contact WHERE AccountId = :opp.AccountId AND Contact_Status__c != 'Inactive'];

            contactRoles = new List<OpportunityContactRole>();

            for(Contact c : contactsList){
                contactRoles.add(new OpportunityContactRole(ContactId = c.Id,Role=null,IsPrimary=false));
            }

            if(contactRoles.size() < 1){
                contactRoles.add(new OpportunityContactRole());
            }

            System.debug('contactRoles: ' + contactRoles);
        }
    }


    public String productSelection { get; set; }

    public String practiceSelection { get; set; }

    //public String pricebookSelection { get; set; }

    //public List<SelectOption> pricebookOptions { get; set; }

    public List<SelectOption> productOptions { get; set; }

    public List<SelectOption> practiceOptions { get; set;  }

    public List<SelectOption> competitorOptions { get; set; }

    public PageReference addProduct() {

       
        try{
                System.debug('practice selection is: ' + practiceSelection);
                System.debug('product selection is: ' + productSelection);

                if(practiceSelection == 'Please select a practice' || productSelection == 'Please select a product'){
                    displayToast(true, 'Please select a Practice and Product.', SLDS_ToastEnum.ERROR);

                } else if (currOLI.Service_Start_Date__c == null || currOLI.Service_End_Date__c == null){
                    displayToast(true, 'Please enter Service Start Date and Service End Date.', SLDS_ToastEnum.ERROR);
                }else{
                    OpportunityLineItem oppProduct = new OpportunityLineItem();

                    List<PricebookEntry> peResults = [SELECT id, Name, Product2id, Pricebook2Id, CurrencyISOCode 
                        FROM PricebookEntry 
                        WHERE Product2id = :productSelection AND Pricebook2id = : opp.Pricebook2id];

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

                    if(currPE != null){
                         // populate off dummy record
                        oppProduct.OpportunityId = opp.id;
                        oppProduct.PricebookEntryId = currPE.id;
                        oppProduct.Recurring_Non_Recurring__c = currOLI.Recurring_Non_Recurring__c;
                        oppProduct.First_Year_Value__c = currOLI.First_Year_Value__c;
                        oppProduct.Type__c = currOLI.Type__c;
                        oppProduct.Fee_Commission__c = currOLI.Fee_Commission__c;
                        oppProduct.UnitPrice = currOLI.UnitPrice;
                        oppProduct.Service_Start_Date__c = currOLI.Service_Start_Date__c;
                        oppProduct.Service_End_Date__c = currOLI.Service_End_Date__c;

                        addedOLI.add(oppProduct);

                        System.debug('addedOLI:' + addedOLI);
                        toast.showToast = false;
                    } else {
                         displayToast(true, 'Please verify there is a Pricebook Entry for this product that matches the current user\'s Default Currency.', SLDS_ToastEnum.ERROR);
                    }
                   

                  
                }

               
        } catch(Exception ex){

            System.debug('Exception: ' + ex);
            displayToast(true, ex.getMessage(), SLDS_ToastEnum.ERROR);

        }

        return null;
    }

    public void checkProducts(){
        if(addedOLI.size() > 0){
            disableSubmitButton = true;
        }
    } 

    public PageReference saveWithProducts() {
        displayToast(false, '', SLDS_ToastEnum.ERROR);
        System.debug('contactRoles: ' + JSON.serialize(this.contactRoles));
       
        List<OpportunityContactRole> ocrToSave = new List<OpportunityContactRole>();
        for(OpportunityContactRole ocr:this.contactRoles){
            System.debug('OCR: ' + JSON.serialize(ocr));
            if(ocr.Role != null){
                ocrToSave.add(ocr);
            }
        }
        System.debug('ocrToSave: ' + ocrToSave);

        //CREATE A SAVEPOINT, IF THERE IS AN ERROR WE WANT TO ROLLBACK. WE DON'T WANT TO CREATE OPPORTUNITIES WITHOUT PRODUCTS
        Savepoint sp = Database.setSavepoint();

        if(ocrToSave.size() > 0){
            try{
                disableSubmitButton = true;

                // CREATE OPPORTUNITY
                System.debug('opp: ' + JSON.serialize(opp));
                insert opp;

                System.debug('addedOLI: ' + JSON.serialize(addedOLI));
                for (OpportunityLineItem o : addedOLI) {
                    o.OpportunityId = opp.Id;
                }

                // ADD OPPORTUNITY LINE ITEMS
                upsert addedOLI;
                system.debug('Added Products: ' + addedOLI);

                for(OpportunityContactRole ocr:ocrToSave){
                    ocr.OpportunityId = opp.Id;
                }

                // ADD OPPORTUNITY CONTACT ROLES
                upsert ocrToSave;
                system.debug('Added Opportunity Contact Roles: ' + ocrToSave);

            } catch(Exception ex){
                //ROLLBACK IF THERE ARE ANY ACCEPTIONS
                Database.Rollback(sp);
                System.debug('Exception: ' + ex);
                System.debug('StackTrace: ' + ex.getStackTraceString());
                displayToast(true, ex.getMessage(), SLDS_ToastEnum.ERROR);
                disableSubmitButton = false;
                return goToOpportunity();
            }
            
            //NAVIGATE TO SALES CREDIT IF CURREN USER REPORTING COUNTRY = 'US'
            if(showSalesCredit){
                return goToSalesCredit();
            } else {
                return navigateToOpportunity();
            }
        }else{
            displayToast(true, 'Please add a Contact to the Opportunity.', SLDS_ToastEnum.Error);
        }
        return null;
    }

    //public PageReference addSalesCredit(){
    //    try{
    //        salesCredit.Related_Opportunity__c = opp.Id;
    //        insert(salesCredit);
    //        addedSalesCredit.add(salesCredit);
    //    } catch(Exception ex){
    //        System.debug('Exception: ' + ex);
    //        displayToast(true, ex.getMessage(), SLDS_ToastEnum.ERROR);
    //    }
    //    return null;
    //}


    public PageReference goToProducts(){

        try{

            if(opp.AccountId == null){
                System.debug('1st if statement.');
                displayToast(true, 'Please select an account before you continue.', SLDS_ToastEnum.ERROR);
                this.tabToShow = 'Opportunity';
            }else if(opp.StageName == 'Closed Won' && (opp.Current_Provider_Reference__c == null || opp.Chosen_Provider_Reference__c == null || opp.Executed_Contract_Date__c == null)){
                System.debug('2nd if statement.');
                displayToast(true, 'Please select a current and chosen provider.', SLDS_ToastEnum.ERROR);
                this.tabToShow = 'Opportunity';
            }else if((opp.StageName == 'Closed Won' || opp.StageName == 'Propose Solution') && opp.Competitor__c == null){
                System.debug('3rd if statement.');
                displayToast(true, 'Please select a competitor.', SLDS_ToastEnum.ERROR);
                this.tabToShow = 'Opportunity';
            }else if(opp.CloseDate == null){
                system.debug('4th if statement.');
                displayToast(true, 'Please enter a Close Date.', SLDS_ToastEnum.ERROR);
                this.tabToShow = 'Opportunity';
            }else{
                System.debug('5th if statement.');
                System.debug('Opportunity: ' + opp);

                //SET PRICEBOOK FOR OPPORTUNITY
                LightningMobileOppUtil.setPricebook(opp);
                this.tabToShow = 'Products';

                this.toast.showToast = false;

                this.practiceOptions = LightningMobileOppUtil.getPracticeOptions(opp.Pricebook2Id);
                System.debug('practiceOptions: ' + practiceOptions);
                }

           
        } catch(Exception ex) {
            displayToast(true, ex.getMessage(), SLDS_ToastEnum.ERROR);
        }

        return null;
    }

    public PageReference goToOpportunity(){
        this.tabToShow = 'Opportunity';
        return null;
    }

    public PageReference goToContact(){
        populateOpportunityContacts();

        if(addedOLI.size() > 0){
            this.tabToShow = 'Contact'; 
        }else{
            tabToShow = 'Products';
            displayToast(true, 'Please add a product to the Opportunity.', SLDS_ToastEnum.Error);
        }

        return null;
    }

    public PageReference goToSalesCredit(){
        this.tabToShow = 'SalesCredit';
        return null;
    }

    public PageReference navigateToOpportunity(){
        return new PageReference(URL.getSalesforceBaseUrl().toExternalForm() + '/' + opp.id);
    }

    public PageReference refreshPracticeOptions(){
        this.practiceOptions = LightningMobileOppUtil.getPracticeOptions(opp.Pricebook2id);
        return null;
    }

    public PageReference refreshProductOptions() {
        this.productOptions = LightningMobileOppUtil.getProductOptions(opp.Pricebook2id, practiceSelection);
        return null;
    }

    public void displayToast(Boolean show, String msg, SLDS_ToastEnum type){
        this.toast.showToast  = show;
        this.toast.toastMsg = msg;
        this.toast.toastType = type;
    }

    public String selectedOpportunityStage {get;set;}

    public PageReference rerenderStageFields(){
        this.toast.showToast = true;

        //SET OPPORTUNITY STAGE
        opp.StageName = selectedOpportunityStage;
        system.debug('Opportunity: ' + JSON.serialize(opp));

        //SET DEFAULT PROBABILITY
        setDefaultProbability();

        return null;
    }

    private void setDefaultProbability(){
        if(this.opp.StageName == 'Non-Qualified Opportunity'){
            opp.Probability = 10;
        }else if(this.opp.StageName == 'Qualify Opportunity'){
            opp.Probability = 25;
        }else if(this.opp.StageName == 'Propose Solution'){
            opp.Probability = 50;
        }else if(this.opp.StageName == 'Negotiate'){
            opp.Probability = 75;
        }else if(this.opp.StageName == 'Closed Won'){
            opp.Probability = 100;
        }
    }


    public String productId { get; set; }

    public PageReference removeProduct(){
        try{
            for(integer i = 0; i < pbEntryList.size(); i++){
                if(pbEntryList[i].Id == productId){
                    pbEntryList.remove(i);

                    System.debug('addedOLI.size(): ' + addedOLI.size());
                    for(integer j = 0; j < addedOLI.size(); j++){
                        if(addedOLI[j].PricebookEntryId == productId){
                            addedOLI.remove(j);
                        }
                    }
                }
            }
         } catch(Exception ex){

            System.debug('Exception: ' + ex);
            displayToast(true, ex.getMessage(), SLDS_ToastEnum.ERROR);

        }

        return null;
    }
}