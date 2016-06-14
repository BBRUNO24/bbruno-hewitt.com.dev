public class RP_MobileOppExtension {

    public Boolean showOpportunity { get; set; }
    public Boolean showProducts { get;  set; }
    public String tabToShow { get; set; }

	public List<SelectOption> pricebookOptions;
	public List<SelectOption> productOptions;
    public List<SelectOption> practiceOptions;
	public String productSelection;
    public String practiceSelection;

    // This should be abstracted from the user eventually - keep for debugging purposes 
	public String pricebookSelection;
    public Pricebook2 usersPricebook;

    // Dummy object to use inputField component to render types
    public OpportunityLineItem currOLI = new OpportunityLineItem();

	// Might want to use a wrapper class instead of these two separate "parallel" lists - 
    // is there ever a case where the indexes can be misaligned?
	public List<Product2> addedProducts = new List<Product2>();   
    public List<OpportunityLineItem> addedOLI = new List<OpportunityLineItem>();

	public Opportunity opp = new Opportunity();

    /*
	public String name {get; set;}
    public Account accountId {get; set;}
    public String stageName {get; set;}
    public Decimal probability {get; set;}
    public Date closeDate {get; set;}
    */

    public RP_MobileOppExtension(ApexPages.StandardController controller) {
        this.pricebookSelection = 'Netherlands Price Book';
        usersPricebook = [SELECT Name, Id FROM Pricebook2 WHERE Name = :pricebookSelection LIMIT 1];
    	pricebookOptions = getPricebookOptions();
    	productOptions = getProductOptions();
    	//this.productsList = new List<String>();

        this.showOpportunity = false;
        this.showProducts = false;
    }

    

    public OpportunityLineItem getCurrOLI() {
        return currOLI;
    }

    public void setCurrOLI(OpportunityLineItem o) {
        this.currOLI = o;
    }
 
    public Opportunity getOpp() {
        return this.opp;
    }

    public void setOpp(Opportunity o) {
        this.opp = o;
    }

    public PageReference dummy() {
        this.productOptions = getProductOptions();
        system.debug('DummyAction');
        return null;
    }


    public List<SelectOption> getPracticeOptions() {
        List<SelectOption> options = new List<SelectOption>();
        Set<String> practiceNames = new Set<String>();
        
        List<PricebookEntry> pbEntries = [select id, Product2.Practice__c from PricebookEntry where IsActive = true and Pricebook2Id = :usersPricebook.id];
        //logMessage('reteived ' + pbEntries.size() + ' price book entries for the designated pricebook: ' + this.opportunity.Pricebook2Id);
        
        
        for (PricebookEntry pbEntry : pbEntries) {
          practiceNames.add(pbEntry.Product2.Practice__c);
        }
        options.add(new SelectOption('Please select a practice','--Please select a practice--'));
        for (String s : practiceNames) {
            options.add(new SelectOption(s, s));
        }

        return options;
    }

    
    public List<SelectOption> getPricebookOptions() {
    	List<SelectOption> options = new List<SelectOption>();
    	List<Pricebook2> pricebookRecords = [SELECT Id, Name FROM Pricebook2];
    	System.debug('pricebookRecords size after query is: ' + pricebookRecords.size());
    	for (Pricebook2 p : pricebookRecords) {
    		options.add(new SelectOption(p.Name, p.Name));
    	}
    	return options;
    }

    public void setPricebookSelection(String s) {
    	this.pricebookSelection = s;
    }

    public String getPricebookSelection() { 
    	return pricebookSelection;
    }

    public void setProductSelection(String s) {
        this.productSelection = s;
    }

    public String getPracticeSelection() {
        return practiceSelection;
    }

    public void setPracticeSelection(String s) {
        this.practiceSelection = s;
    }

    public String getProductSelection() { 
        return productSelection;
    }

    public void addProduct() {
        
        System.debug('product selcetion is: ' + productSelection);
        Product2 prodName = [SELECT Name, Id FROM Product2 WHERE Name = :productSelection LIMIT 1];
    	addedProducts.add(prodName);

        system.debug('Product Selection: ' + productSelection + ' ' + prodName);

        OpportunityLineItem oppProduct = new OpportunityLineItem();

        Product2 p = [SELECT Name, Id FROM Product2 WHERE Name = :productSelection LIMIT 1];
        //usersPricebook = [SELECT id, Name FROM Pricebook2 WHERE Name = :pricebookSelection LIMIT 1];

        List<PricebookEntry> peResults = [SELECT id, Product2id, Pricebook2Id, CurrencyISOCode 
            FROM PricebookEntry 
            WHERE Product2id = :p.id AND Pricebook2id = : usersPricebook.id];

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

        // populate off dummy record
        oppProduct.OpportunityId = opp.id;
        oppProduct.PricebookEntryId = currPE.id;
        oppProduct.Recurring_Non_Recurring__c = currOLI.Recurring_Non_Recurring__c;
        oppProduct.First_Year_Value__c = currOLI.First_Year_Value__c;
        oppProduct.Type__c = currOLI.Type__c;
        oppProduct.Fee_Commission__c = currOLI.Fee_Commission__c;
        oppProduct.UnitPrice = currOLI.UnitPrice;


        addedOLI.add(oppProduct);
    }
    /*
    public List<String> getProductsList() {
    	return productsList;
    }

    public void setProductsList(List<String> s) {
    	this.productsList = s;
    }*/

    public List<SelectOption> getProductOptions() {
    	System.debug('entering getProductOptions');

    	List<SelectOption> options = new List<SelectOption>();
    	
    	//System.debug('currPricebook is: ' + currPricebook);
    	Set<Id> productIds = new Set<Id>();
    	List<PricebookEntry> junctionRecords = [SELECT id, Pricebook2Id, Product2Id FROM PricebookEntry WHERE Pricebook2id =: usersPricebook.id];
    	System.debug('junction records size is: ' + junctionRecords.size());

    	for (PricebookEntry pe : junctionRecords) {
    		productIds.add(pe.Product2id); 
    	}

    	List<Product2> productRecords = [SELECT Id, Name, Practice__c 
            FROM Product2 
            WHERE Id IN :productIds AND Practice__c = :practiceSelection LIMIT 999];
    	System.debug('product records size is: ' + productRecords.size());

        options.add(new SelectOption('Please select a product','--Please select a product--'));
    	for (Product2 p : productRecords) { 
    		options.add(new SelectOption(p.Name, p.Name)); 
    	}

    	return options; 
    }

    public List<Product2> getAddedProducts() {
    	return addedProducts;
    }

    public void setAddedProducts(List<Product2> p) {
    	this.addedProducts = p;
    }

    public List<OpportunityLineItem> getAddedOLI() {
        return addedOLI;
    }

    public void setAddedOLI(List<OpportunityLineItem> o) {
        this.addedOLI = o;
    }

    public PageReference saveWithProducts() {
     	
    	//usersPricebook = [SELECT id, Name FROM Pricebook2 WHERE Name = :pricebookSelection LIMIT 1];

        opp.Pricebook2Id = usersPricebook.id;

        system.debug('Opportunity: ' + opp);

        insert opp;

        /*

        List<OpportunityLineItem> oliToAdd = new List<OpportunityLineItem>();
        for (Product2 p : addedProducts) {
    	    OpportunityLineItem oppProduct = new OpportunityLineItem();

            //System.debug('>>>>' + opp.id);
            //System.debug('>>>>' + this.opp.id);
            //oppProduct.OpportunityId= this.opp.id;
            //System.debug('>>>>' + oppProduct);
            //oppProduct.Product2Id = p.id;

            // can assume small volume of record transactions
            System.debug('productid: ' + p.id);
            System.debug('pricebookid: ' + usersPricebook.id);
            System.debug('currCurrencyCode: ' + UserInfo.getDefaultCurrency());

            List<PricebookEntry> peResults = [SELECT id, Product2id, Pricebook2Id, CurrencyISOCode 
                FROM PricebookEntry 
                WHERE Product2id = :p.id AND Pricebook2id = : usersPricebook.id];

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

            oppProduct.OpportunityId = opp.id;
            oppProduct.PricebookEntryId = currPE.id;


            oppProduct.Recurring_Non_Recurring__c = currOLI.Recurring_Non_Recurring__c;
            oppProduct.First_Year_Value__c = currOLI.First_Year_Value__c;
            oppProduct.Type__c = currOLI.Type__c;
            oppProduct.Fee_Commission__c = currOLI.Fee_Commission__c;
            oppProduct.UnitPrice = currOLI.UnitPrice;

            oliToAdd.add(oppProduct);
        }*/

        for (OpportunityLineItem o : addedOLI) {
            o.OpportunityId = opp.id;
        }

        system.debug('Added Products: ' + addedOLI);

        insert addedOLI;

        //Map<Id, Product2> idToProduct2Map = new Map<Id, Product2>([SELECT id, Name FROM ])

        System.debug(opp);
        
        return new PageReference(URL.getSalesforceBaseUrl().toExternalForm() + '/' + opp.id);


    }

    public void goToProducts(){
        System.debug('Opportunity: ' + this.opp);
        this.showProducts = true;
    }



    
}