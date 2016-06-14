/** Controller for displaying and editing Opportunity Strategy data
  * Case 67074. Chintan Adhyapak. April 09, 2013 */
public without sharing class ctlr_ViewOpportunityStrategy {
    //class variables
    public Opportunity_Strategy__c strategy                     {get; set;}
    public Opportunity myOpp                                    {get; set;}
    public String score                                         {get; set;}
    public String exchangeScore									{get; set;}
    public List<Opportunity_Competitive_Analysis__c> compList   {get; set;}
    public integer compListSize                                 {get; set;}
    public List<Opportunity_Contact_Role__c> ocrList            {get; set;}
    public String selectedOcrId                                 {get; set;}
    public double total											{get; set;}
    
    /* constructor */
    public ctlr_ViewOpportunityStrategy(ApexPages.StandardController controller) {
        myOpp = (Opportunity)controller.getRecord();
        //read all fieldNames for Opportunity
        Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Opportunity.fields.getMap();
        String fieldNames = '';
        for(String fieldName : schemaFieldMap.keySet()) {
            fieldNames += ',' + fieldName;
        }
        fieldNames = fieldNames.substring(1);
        String soql = 'Select ' + fieldNames + ' From Opportunity Where Id = \'' + myOpp.Id + '\'';
        myOpp = Database.query(soql);
    } //constructor
    
    
    //Autosave the data
    public void autosave() {
        update strategy;
        update compList;
        upsert ocrList; 
    } //autosave
    
    
    //Create Records if they dont exist
    public void init() {
        //read all fieldNames for Opportunity Strategy object
        Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Opportunity_Strategy__c.fields.getMap();
        
        //Create a SOQL string with all fields
        String fieldNames = '';
        for(String fieldName : schemaFieldMap.keySet()) {
            fieldNames += ',' + fieldName;
        }
        fieldNames = fieldNames.substring(1);
        String soql = 'Select ' + fieldNames + ' From Opportunity_Strategy__c Where Related_Opportunity__c = \'' + myOpp.Id + '\'';
        
        //Read Plan data
        List<Opportunity_Strategy__c> strategyList = Database.query(soql);
        
        if (strategyList.isEmpty()) {
            strategy = new Opportunity_Strategy__c();
            strategy.Related_Opportunity__c = myOpp.Id;
            insert strategy;
            //Requery
            strategyList = Database.query(soql);
        }
        strategy = strategyList[0];
        
        //Set Scores
        score = 'Red';
        System.debug('CPA strategy is: ' + strategy);
        //this.total = strategy.Total__c + strategy.Total_2__c;
        if (strategy.Total__c <= 5) {
            score = 'Red';
        } else if (strategy.Total__c <= 8) {
            score = 'Yellow';
        } else if (strategy.Total__c > 8){
            score = 'Green';
        }
        
        exchangeScore = 'Red';
        //this.total = strategy.Total__c + strategy.Total_2__c;
        if (strategy.Total_2__c <= 3) {
            exchangeScore = 'Red';
        } else if (strategy.Total_2__c <= 6) {
            exchangeScore = 'Yellow';
        } else if (strategy.Total_2__c > 6){
            exchangeScore = 'Green';
        }
        
        //Synchronize Opportunity Competitor records
        syncCompetitors();
        
        //Set compList
        compList = [Select Competitor__c, Strength__c, Weakness__c, Client_View__c, Estimated_Fees__c from Opportunity_Competitive_Analysis__c 
            Where Opportunity__c = :myOpp.Id Order By Competitor__c];
        compListSize = compList.size();
        
        //Set Contact List
        ocrList = [Select Id, Account__c, Comments__c, Contact__c, Opportunity__c, Role__c From Opportunity_Contact_Role__c Where Opportunity__c = :myOpp.Id 
            Order By Contact__r.Name];
    } //init
    
    
    //Save Form Data and Refresh
    public PageReference saveData() {
        //local var
        PageReference redirect = null;
        
        //Save form data
        try {
            update strategy;
        } catch (Exception e1) {
            Apexpages.addMessages(e1);
            return null;
        }
        try {
            update compList;
        } catch (Exception e2) {
            Apexpages.addMessages(e2);
            return null;
        }
        try {
            upsert ocrList;
        } catch (Exception e3) {
            Apexpages.addMessages(e3);
            return null;
        }
        
        //Reload page
        redirect = new PageReference('/apex/ViewOpportunityStrategy?id=' + myOpp.Id);
        redirect.setRedirect(true);
        return redirect;
    } //saveData
    
    
    //Load the PDF Opp Plan
    public PageReference createPlan() {
        //local var
        PageReference redirect = null;
        
        //Check that at least one Contact Role record exists
        if (this.ocrList.isEmpty()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'You must have at least one Contact Role defined to proceed. Please contact your local Sales Operations Team for assistance.'));
            return redirect;
        }
        redirect = new PageReference('/apex/OpportunityPlanDoc?id=' + myOpp.Id);
        redirect.setRedirect(true);
        return redirect;
    } //createPlan
    
    //00094366-Ritu-Load the PDF Opp Exec Summary Plan
    public PageReference createSummaryPlan() {
        //local var
        PageReference redirect = null;
        
        //Check that at least one Contact Role record exists
        if (this.ocrList.isEmpty()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'You must have at least one Contact Role defined to proceed. Please contact your local Sales Operations Team for assistance.'));
            return redirect;
        }
        redirect = new PageReference('/apex/OpportunitySummaryPlanDoc?id=' + myOpp.Id);
        redirect.setRedirect(true);
        return redirect;
    } //createSummaryPlan
        
    //Add a new Opportunity Contact Role Record
    public void addOcr(){
        ocrList.add(new Opportunity_Contact_Role__c(Account__c = myOpp.AccountId, Opportunity__c = myOpp.Id));
    } //addOcr
    
    
    //Delete Selected Opportunity Contact Role record
    public void deleteOCR() {
        System.debug('CPA selectedOcrId: ' + selectedOcrId);
        // if for any reason we are missing the reference 
        if (selectedOcrId == null) {
            return;
        }
     
        // find the OCR record within the collection
        Opportunity_Contact_Role__c toBeDeleted = null;
        for(Opportunity_Contact_Role__c ocr : ocrList) {
            System.debug('CPA ocr.Id is: ' + ocr.Id);
            if (ocr.Id == selectedOcrId) {
                toBeDeleted = ocr;
                System.debug('CPA Found matching OCR record');
                break;
            }
        }
        
        //if OCR record found, delete it
        if (toBeDeleted != null) {
            System.debug('CPA deleting ocr id: ' + toBeDeleted.Id);
            delete toBeDeleted;
        }
     
        //refresh the data
        ocrList = [Select Id, Account__c, Comments__c, Contact__c, Opportunity__c, Role__c From Opportunity_Contact_Role__c Where Opportunity__c = :myOpp.Id 
            Order By Contact__r.Name];
    } //deleteOCR
    
    
    /** This method synchronizes Competitors chosen on the Opportunity with 
      * the custom object Opportunity Competitive Analysis. 
      * Chintan Adhyapak, April 16, 2012 */
    private void syncCompetitors() {
        //local vars
        Map<String, Opportunity_Competitive_Analysis__c> ocaMap = new Map<String, Opportunity_Competitive_Analysis__c> ();
        List<Opportunity_Competitive_Analysis__c> recordsToDelete = new List<Opportunity_Competitive_Analysis__c> ();
        List<Opportunity_Competitive_Analysis__c> recordsToInsert = new List<Opportunity_Competitive_Analysis__c> ();
        Set<String> compSet = new Set<String> ();
        Set<String> ocaSet = new Set<String> ();
        
        //Read Competitors from Opp
        for (String comp : (myOpp.Competitor__c != null ? myOpp.Competitor__c.split(';', 0) : new List<String> ())) {
            compSet.add(comp);
        }
        
        //Read existing Opportunity Competitive Analysis records for Opp
        for (Opportunity_Competitive_Analysis__c oca : [Select Id, Opportunity__c, Competitor__c from Opportunity_Competitive_Analysis__c Where Opportunity__c = :myOpp.Id]) {
            ocaSet.add(oca.Competitor__c);
            ocaMap.put(oca.Competitor__c, oca);
        }
        
        //Identify records to add
        for (String comp : compSet) {
            if (!ocaSet.contains(comp)) {
                Opportunity_Competitive_Analysis__c oca = new Opportunity_Competitive_Analysis__c();
                oca.Competitor__c = comp;
                oca.Opportunity__c = myOpp.Id;
                recordsToInsert.add(oca);
            }
        }
        
        //Identify records to delete
        for (String comp : ocaSet) {
            if (!compSet.contains(comp)) {
                recordsToDelete.add(ocaMap.get(comp));
            }
        }
        
        //Insert
        if (!recordsToInsert.isEmpty()) {
            insert recordsToInsert;
        }
        
        //Delete
        if (!recordsToDelete.isEmpty()) {
            delete recordsToDelete;
        }
    } //syncCompetitors
}