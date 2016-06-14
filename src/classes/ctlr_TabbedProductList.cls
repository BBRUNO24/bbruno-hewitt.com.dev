public with sharing class ctlr_TabbedProductList {
    private String opportunityId                        {get; set;}
    public List<dto_lineItemProduct> lineItemProducts   {get; private set;}
    
    //Ritu Sharma - Case No. 00091993 - Added isRevSchUser variable and commented ISAusUser as now auto revenue schedule feature will work if Can Revenue Schedule flag is checked for the user
    //public Boolean IsAusUser                            {get; set;}  // Revenue Schedule:Added by: Amrita on “02/16/12”
    public Boolean isRevSchUser {get;set;}
    private String RevenueSchedulePage;      // Revenue Schedule:Added by: Amrita on “02/16/12”
    public Map<Id, Product2> products = new Map<Id, Product2>(); //00091993-Ritu-Moved it out of init() function

    /* constructor */
    public ctlr_TabbedProductList(ApexPages.StandardController controller) {
         // initialize class vars
        System.debug(System.LoggingLevel.INFO, 'CONSTRUCTOR START');
        this.lineItemProducts = new List<dto_lineItemProduct>();
        this.opportunityId = controller.getId();

        // Revenue Schedule : Begin ----- 
        //Added by : Amrita on “02/16/12”
        //Ritu Sharma - Case No. 00091993 - Changed query to pull Can_Revenue_Schedule__c instead of Reporting_Country__c
        User curUser = [SELECT Can_Revenue_Schedule__c FROM User WHERE id = :UserInfo.getUserId() LIMIT 1];
        //Ritu Sharma - Case No. 00091993 - Changed if condition as now auto revenue schedule feature will work if Can Revenue Schedule flag is checked for the user
        this.isRevSchUser = true;
        if(curUser.Can_Revenue_Schedule__c)
            this.isRevSchUser = true;
            //this.isRevSchUser = true;
        else
            this.isRevSchUser = true;
            
        RevenueSchedulePage = '';
        // Revenue Schedule : End -----
        System.debug(System.LoggingLevel.INFO, 'presenting ui for oppty id: ' + this.opportunityId + '...');
        System.debug(System.LoggingLevel.INFO, 'CONSTRUCTOR END'); 
    }

    /* init */
    public PageReference init() {
        // debug
        System.debug(System.LoggingLevel.INFO, 'INIT START');
        
        // declare local vars
        List<Product_Field_List__c> fieldList = null;
        Opportunity opportunity = null;
        Map<String, Set<String>> fieldListByObject = new Map <String, Set<String>>();
        Map<Id, OpportunityLineItem> lineItems = new Map<Id, OpportunityLineItem>();
        Map<Id, PricebookEntry> pbEntries = new Map<Id, PricebookEntry>();
                
        // perform an initial retrieval of opportuntiy data
        System.debug(System.LoggingLevel.INFO, 'retrieving core info about the opportunity to facilitate some decision making...');
        opportunity = [select id, recordtype.id, recordtypeid, stagename from Opportunity where id = :this.opportunityId];
        System.debug(System.LoggingLevel.INFO, 'retrieved opportunity: ' + opportunity);
        
        // get the initial set of product fields based on the opportunity core data
        System.debug(System.LoggingLevel.INFO, 'retrieving configured product field list...');
        fieldList = [Select Source_Object__c, Field_Name__c, Product_Service_Classification__c, Product_Id__c From Product_Field_List__c 
            Where RecordType.Name = 'Read Only UI Field' and ((Opportunity_Record_Type__c = :opportunity.RecordTypeId and Opportunity_Stage__c = :opportunity.StageName) or (Product_Id__c != null)) Order By Sort_Order__c];
        System.debug(System.LoggingLevel.INFO, 'retrieved ' + fieldList.size() + ' fields: ' + fieldList);

        // load the field list into a map based on object names
        System.debug(System.LoggingLevel.INFO, 'organizing the retrieved field lists...');
        for (Product_Field_List__c productField : fieldList) {
            if (!fieldListByObject.containsKey(productField.Source_Object__c.toLowerCase())) {
                System.debug(System.LoggingLevel.INFO, 'New Source Object Detected: ' + productField.Source_Object__c.toLowerCase());
                fieldListByObject.put(productField.Source_Object__c.toLowerCase(), new Set<String>());
            }
            Set <String> objectFieldList = fieldListByObject.get(productField.Source_Object__c.toLowerCase());
            objectFieldList.add(productField.Field_Name__c);
            fieldListByObject.put(productField.Source_Object__c.toLowerCase(), objectFieldList);
            System.debug(System.LoggingLevel.INFO, 'field list for ' + productField.Source_Object__c.toLowerCase() + ': ' + objectFieldList);
        }
        
        // Revenue Schedule : Begin ----- 
        // Added by : Amrita on “02/16/12”
        // Adds Revenue scheduling related fields to lineitme field list
        // This is required as we don't have this field's entry in Product_Field_List__c 
        Set<String> setRevSchd = fieldListByObject.get('opportunitylineitem'); // Gets the field list for "opportunitylineitem" key
        setRevSchd.add('HasRevenueSchedule');  // Add field to existing list
        setRevSchd.add('CreatedDate');  // Add field to existing list for Sorted Tab as per created date
        // Revenue Schedule : End -----        

        System.debug(System.LoggingLevel.INFO, 'organization complete.');
        
        // populate the opportunity record with configured fields
        if (fieldListByObject.containsKey('opportunity')) {
            System.debug(System.LoggingLevel.INFO, 'retrieving data for the configured opportunity fields...');
            opportunity = getConfiguredOpportunityData(fieldListByObject.get('opportunity'), this.opportunityId);
            System.debug(System.LoggingLevel.INFO, 'opportunity retrieval complete.');
        }
        
        // populate the opportunity line item records with configured fields
        if (fieldListByObject.containsKey('opportunitylineitem')) {
            System.debug(System.LoggingLevel.INFO, 'retrieving data for the configured opportunity line item fields...');
            lineitems = getConfiguredOpportunityLineItemData(fieldListByObject.get('opportunitylineitem'), this.opportunityId);
            System.debug(System.LoggingLevel.INFO, 'opportunity line item retrieval complete.');
        }
        // populate the pricebook entry records with configured fields
        System.debug(System.LoggingLevel.INFO, 'retrieving data for the configured pricebook entry fields...');
        pbEntries = getConfiguredPricebookEntryData(fieldListByObject.get('pricebookentry'), lineItems);
        System.debug(System.LoggingLevel.INFO, 'opportunity line item retrieval complete.');
        
        // populate the product records with configured fields
        System.debug(System.LoggingLevel.INFO, 'retrieving data for the configured product fields...');
        products = getConfiguredProductData(fieldListByObject.get('product'), pbEntries);
        System.debug(System.LoggingLevel.INFO, 'product retrieval complete.');
        
        // load all of the retrieved data into the dtos for delivery to the page
        System.debug(System.LoggingLevel.INFO, 'loading all data retreived into dtos...');
        
        // Sort the list of "OpportunityLineItem", so that the Tab should come in order of createdDate
        List<OpportunityLineItem> lstOpportunityLineItemDB = lineItems.values();
        lstOpportunityLineItemDB = SortOppLineItem(lstOpportunityLineItemDB);
        //for (OpportunityLineItem item : lineItems.values()) { // Commented By Amrita : 02/23/2012
        for (OpportunityLineItem item : lstOpportunityLineItemDB) {
            PricebookEntry entry = pbEntries.get(item.PricebookEntryId);
            Product2 product = products.get(entry.Product2Id);
            lineItemProducts.add(new dto_lineItemProduct(opportunity, item, entry, product, fieldList));
        }

        // debug
        System.debug(System.LoggingLevel.INFO, 'load complete.');
        System.debug(System.LoggingLevel.INFO, 'INIT END');
        return null;
    }
    
    // Revenue Schedule : Begin ----- 
    // Created By : Amrita on 02/23/2012
    // A method to sort list of "OpportunityLineItem"
    private List<OpportunityLineItem> SortOppLineItem(List<OpportunityLineItem> lstOppLitem) {
        List<OpportunityLineItem> retLstOppLitem = new List<OpportunityLineItem>();
        Map<ID,OpportunityLineItem> mapOppLi = new Map<ID,OpportunityLineItem>();
        List<ID> lstIDs = new List<ID>();
        if(lstOppLitem != null && lstOppLitem.Size() > 0) {
            for(OpportunityLineItem oppLi : lstOppLitem) {
                lstIDs.Add(oppLi.ID);
                mapOppLi.put(oppLi.ID, oppLi);
            }
            lstIDs.Sort();
            for(ID opLiId : lstIDs) {
                retLstOppLitem.Add(mapOppLi.get(opLiId));
            }
        }
        return retLstOppLitem;
    }
    // Revenue Schedule : End -----

    
    // Revenue Schedule : Begin ----- 
    // Added by : Amrita on “02/16/12”
    // This method will be called on Opportunity Page Load through JS Code
    //00091993-Ritu Sharma-Modified to check rev schedule flag on user record and revenue schedule enabled flag of product
    public String getRevenueSchedulePage() {
        String strReturnVal = '';
        List<ID> prodIds = new List<ID>();
        //Ritu Sharma - Case No. 00091993 - Changed query to pull Can_Revenue_Schedule__c instead of Reporting_Country__c
        User curUser = [SELECT Id, Can_Revenue_Schedule__c FROM User WHERE id = :UserInfo.getUserId() LIMIT 1];
        // Get Current Opportunity Owner ID
        Opportunity CurOpp = [SELECT OwnerId FROM Opportunity WHERE Opportunity.Id = :opportunityId];        
        //Ritu Sharma - Case No. 00091993 - Changed the if condition as now auto revenue schedule feature will work if Can Revenue Schedule flag is checked for the user
        if((curUser.Can_Revenue_Schedule__c) && (curUser.Id == CurOpp.OwnerId)) {
            // Check Revenue Schedule status for current product, if false, redirect to revenue Schedule page
            List<OpportunityLineItem> lstRevSchdStatus = [SELECT Id,PricebookEntry.Product2Id,HasRevenueSchedule, TotalPrice FROM OpportunityLineItem WHERE Opportunity.Id = :opportunityId];
            lstRevSchdStatus = SortOppLineItem(lstRevSchdStatus); // Sorting list based on ID
            
            //Getting handle of all products
            for (OpportunityLineItem lineItem: lstRevSchdStatus)
            {
                prodIds.add(lineItem.PricebookEntry.Product2Id);
            }            
            products = new Map<ID,Product2>([Select ID,CanUseRevenueSchedule from Product2 where ID IN: prodIds]);
            for(OpportunityLineItem oppLineItem : lstRevSchdStatus) {
                //oppLineItem = [Select Id,PricebookEntry.Product2Id,HasRevenueSchedule, TotalPrice from OpportunityLineItem where ID=:oppLineItem.ID];
                Product2 product = products.get(oppLineItem.PricebookEntry.Product2Id); //00091993-Ritu-Getting handle of the product
                // If Revenue Schedule is not complete and product's "Total Service Value" is not "0", redirect to revenue schedule page
                //68345-Ritu-Added condition to see if Revenue schedule is enabled at the product level
                if((product.CanUseRevenueSchedule == True && oppLineItem.HasRevenueSchedule == false && (oppLineItem.TotalPrice != null && oppLineItem.TotalPrice != 0)) ) { 
                    String SfBaseURL = System.URL.getSalesforceBaseUrl().toExternalForm();
                    String URL = SfBaseURL +'/oppitm/establishschedule.jsp?id=' + oppLineItem.Id + '&retURL=%2F' + opportunityId;
                    strReturnVal = URL;
                    break;
                }                
            }
        }
        System.debug('ReturnURL'+strReturnVal);
        return strReturnVal;
    }
    // Revenue Schedule : End -----
    
    
    
    private Opportunity getConfiguredOpportunityData(Set<String> fieldsToRetrieve, String opptyId) {
        // declare local vars
        List<sObject> records = null;
        
        // add any required fields to ensure they are part of the collection retrieved
        fieldsToRetrieve.add('id');
        fieldsToRetrieve.add('recordtypeid');
        fieldsToRetrieve.add('stagename');
        
        // perform the retrieval
        System.debug(System.LoggingLevel.INFO, 'querying data...');
        records = Database.query('Select ' + util_globalUtilityMethods.joinStringSet(fieldsToRetrieve, false) + ' From Opportunity Where Id = \'' + opptyId + '\'');
        System.debug(System.LoggingLevel.INFO, 'retrieved: ' + records[0]);

        // return the data
        return (Opportunity)records[0];
    }
    
    private Map<Id, OpportunityLineItem> getConfiguredOpportunityLineItemData(Set<String> fieldsToRetrieve, String opptyId) {
        // declare local vars
        List<sObject> records = null;
        Map<Id, OpportunityLineItem> lineItems = new Map<Id, OpportunityLineItem>();
        Set <String> temp = new Set<String>();
        
        // add any required fields to ensure they are part of the collection retrieved
        if (fieldsToRetrieve != null) {
            temp = fieldsToRetrieve;
        }
        temp.add('id');
        temp.add('PricebookEntryId');
        
        System.debug(System.LoggingLevel.INFO, 'retrieving the set of configured fields for related opportunity line items : ' + temp);
        
        // perform the retrieval
        System.debug(System.LoggingLevel.INFO, 'querying data...');
        records = Database.query('Select ' + util_globalUtilityMethods.joinStringSet(temp, false) + ' From OpportunityLineItem Where OpportunityId = \'' + opptyId + '\'' + 'ORDER BY CreatedDate ASC');
        System.debug(System.LoggingLevel.INFO, 'retrieved ' + records.size() + ' records: ' + records);
        
        // load returned records into the return structure
        for (sObject record : records) {
            lineItems.put(((OpportunityLineItem)record).Id,(OpportunityLineItem)record);
        }

        // return the data
        return lineItems;
    }
    
    private Map<Id, PricebookEntry> getConfiguredPricebookEntryData(Set<String> fieldsToRetrieve, Map <Id, OpportunityLineItem> lineItems) {
        // declare local vars
        Set <String> pbEntryIds = new Set<String>();
        Set <String> temp = new Set<String>();
        List<sObject> records = null;
        Map <Id, PricebookEntry> pbEntries = new Map<Id, PricebookEntry>();
        
        // collect the distinct set of pricebook entry ids based on the returned products
        System.debug(System.LoggingLevel.INFO, 'collect the distinct set of pricebook entry ids based on the returned line items...');
        for (OpportunityLineItem lineItem : lineItems.values()) {
            pbEntryIds.add(lineItem.PricebookEntryId);
        }
        System.debug(System.LoggingLevel.INFO, 'collected ' + pbEntryIds.size() + ' distinct ids: ' + pbEntryIds);
        
        if (pbEntryIds.size() > 0) {

            // add any required fields to ensure they are part of the collection retrieved
            if (fieldsToRetrieve != null) {
                temp = fieldsToRetrieve;
            }
            temp.add('Product2Id');
            System.debug(System.LoggingLevel.INFO, 'retrieving the set of configured fields for related pricebook entries : ' + temp);
            
            // retrieve the records
            System.debug(System.LoggingLevel.INFO, 'querying data...');
            records = Database.query('Select ' + util_globalUtilityMethods.joinStringSet(temp, false) + ' From PricebookEntry Where Id IN (' + util_globalUtilityMethods.joinStringSet(pbEntryIds, true) + ')'); 
            System.debug(System.LoggingLevel.INFO, 'retrieved ' + records.size() + ' records: ' + records);
                
            // load returned records into the return structure
            for (sObject record : records) {
                pbEntries.put(((PricebookEntry)record).Id,(PricebookEntry)record);
            }
        }

        // return the data
        return pbEntries;
    }
    
    private Map<Id, Product2> getConfiguredProductData(Set <String> fieldsToRetrieve, Map <Id, PricebookEntry> pbEntries) {
        // declare local vars
        Set <String> productIds = new Set <String>();
        Set <String> temp = new Set<String>();
        List<sObject> records = null;
        Map <Id, Product2> products = new Map <Id, Product2>();
        
        // collect the distinct set of product ids based on the returned pricebook entries
        System.debug(System.LoggingLevel.INFO, 'collect the distinct set of product ids based on the returned pricebook entries');
        for (PricebookEntry entry : pbEntries.values()) {
            productIds.add(entry.Product2Id);
        }
        System.debug(System.LoggingLevel.INFO, 'collected ' + productIds.size() + ' distinct ids: ' + productIds);
        
        if (productIds.size() > 0) {
            
            // add any required fields to ensure they are part of the collection retrieved
            if (fieldsToRetrieve != null) {
                temp = fieldsToRetrieve;
            }
            temp.add('Use_Product_Specific_Field_List__c');
            temp.add('Service_Classification__c');
            temp.add('CanUseRevenueSchedule'); //Ritu Sharma - Case No. 68345 - Used in VF page to see if revenue schedule is enabled for the product
            System.debug(System.LoggingLevel.INFO, 'retrieving the set of configured fields for related pricebook entries : ' + temp);
            
            // retrieve the records
            System.debug(System.LoggingLevel.INFO, 'querying data...');
            records = Database.query('Select ' + util_globalUtilityMethods.joinStringSet(temp, false) + ' From Product2 Where Id IN (' + util_globalUtilityMethods.joinStringSet(productIds, true) + ')'); 
            System.debug(System.LoggingLevel.INFO, 'retrieved ' + records.size() + ' records: ' + records);
                
            // load returned records into the return structure
            for (sObject record : records) {
                products.put(((Product2)record).Id,(Product2)record);
            }
                
        }

        // return the data
        return products;
    }     
}