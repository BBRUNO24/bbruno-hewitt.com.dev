public with sharing class OpportunityProductsController {
	public OpportunityProductsController(OpportunityEditController controller) {
		this.controller = controller;
    this.edit = false;
	}

  public OpportunityEditController controller {get; set;}
  PriceBook2 currentPricebook;
  List<PricebookEntry> priceBookEntries;
  List<OpportunityLineItem> lineItems;
  Set<String> practices;
  Boolean edit;

  private String getOpportunityId(){
    return this.controller.opportunity.Id;
  }

  public List<OpportunityLineItem> getLineItems(){
    if(this.lineItems == null){
      setupLineItems();
    }
    return this.lineItems;
  }

  public void setupLineItems(){
    String oppId = getOpportunityId();
    if(oppId != null){
      this.lineItems = [SELECT Id,PricebookEntry.Product2Id,HasRevenueSchedule, TotalPrice FROM OpportunityLineItem WHERE Opportunity.Id = :oppId];
    }else{
      this.lineItems = new List<OpportunityLineItem>();
    }
  }

  public Boolean isEditing(){
    return this.edit;
  }

  public void newProduct(){
    this.setEdit(true);
  }

  public void setEdit(Boolean isEdit){
    this.edit = isEdit;
  }

  public Boolean isPriceBookSet(){
    return currentPricebook != null;
  }

  public Pricebook2 getStandardPriceBook(){
    Pricebook2 pb2 =  [Select Name, Id From Pricebook2 WHERE isActive = true and IsStandard = true limit 1];
    return pb2;    
  }

  public List<SelectOption> getPractices(){
    List<SelectOption> options = new List<SelectOption>();

    return options;
  }

  public List<SelectOption> getServices(){
    List<SelectOption> options = new List<SelectOption>();

    return options;
  }

  public void setOpportunityPriceBook(){
    Pricebook2 pb2 = getStandardPriceBook();
    setOpportunityPriceBook(pb2.Id);
  }

  public void setOpportunityPriceBook(String priceBookId){
    if(!this.isPriceBookSet() || this.currentPricebook.Id != priceBookId){
      Pricebook2 pb2 = [SELECT Name, Id FROM Pricebook2 WHERE isActive = true AND Id = :priceBookId LIMIT 1];
      if(pb2 != null){
        this.currentPriceBook = pb2;
      }
    }
  }


}