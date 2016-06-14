public with sharing class ctlr_OpportunityEdit {
    
    public Opportunity opportunity;
    public List<Opportunity_Edit_Section__c> editSections   {get; set;}
    public List<Pricebook2> pricebooks             {get; set;}
    public List <String> practices               {get;set;}
    public List<PricebookEntry> availableProducts       {get; set;}
    public String practice                   {get; set;}
    public String currencyIsoCode               {get;set;}
    public Integer addServiceDialogHeight           {get;set;}
    public Integer addServiceDialogWidth            {get;set;}
    public Integer serviceTabsHeight                {get;set;}
    
    public String getJSONScript   {get;set;}
    public String jsonString      {get;set;}
    public String removedProducts   {get;set;}
    
    private Set<String> opportunityFields;
    public String jsonProductResults             {get; set;}
    public String productIFrameURL               {get; set;}
    private ApexPages.StandardController standardController  {get;set;}
    
    public String gpStageName         {get;set;}
    public Integer defaultProbability     {get;set;}
    public Boolean hasProbabilityDefault   {get;set;}
    
    public List<SelectOption> chosenList = null;
    public List<SelectOption> AvailableList = null;
    private static String MULTIPICKLIST_SEPERATOR = ';'; // A constant to store the seperator for option list values
        
    public ctlr_OpportunityEdit(ApexPages.StandardController controller) {
        hasProbabilityDefault = false;
        
        // debug
        logMessage('ctlr_OpportunityEdit START');
        
        // retrieve application settings
        logMessage('retrieving app settings...');
        OpportunityEditSettings__c appSettings = OpportunityEditSettings__c.getInstance();
        addServiceDialogHeight = appSettings.Add_Service_Dialog_Height__c.intvalue();
        addServiceDialogWidth = appSettings.Add_Service_Dialog_Width__c.intvalue();
        serviceTabsHeight = appSettings.Tabbed_Services_Height__c.intvalue();
        String defaultRtName = appSettings.Default_Oppty_Record_Type_Name__c;
        logMessage('retrieved: ' + String.valueOf(appSettings));
        
        // retrieve supporting information to drive the form
        init();

        // add fields to the controller context if necessary
        logMessage('Controller id is : ' + controller.getId());

        if (controller.getId() != null) { 
            logMessage('adding opportunity fields to the current context...');
            List <String> temp = new List<String>();
            temp.addAll(opportunityFields);
            controller.addFields(temp);
            logMessage('added ' + String.valueOf(temp.size()) + ' fields: ' + temp);
        } 
        
        // retrieve record from controller
        logMessage('retrieving record instance from controller...');
        opportunity = (Opportunity)controller.getRecord();
        logMessage('`: ' + String.valueOf(opportunity));
        logMessage('Amrita retreived: ' + opportunity.Competitor__c );
   
        //--- CPL -----------------------------------------------------
            LoadCompetitorList();
        //----CPL-------------------------------------------------

        // grab the record type from the querystring
        logMessage('retreiving the oppty record type...');
        String recordTypeId = '';
        if (ApexPages.currentPage().getParameters().containsKey('RecordType')) {
            logMessage('located a record type value within the inbound parameters...');
            recordTypeId = ApexPages.currentPage().getParameters().get('RecordType');
        } else {
            logMessage('no record type located within the inbound parameters, querying the system...');
            list <recordtype> recordtypes = [select id from recordtype where sObjectType = 'Opportunity' and IsActive = true and Name = :defaultRtName];
            logMessage('query returned ' + String.valueOf(recordtypes.size()) + ' record types: ' + recordTypes);
            recordTypeId = recordtypes[0].Id;
        }
        logMessage('retreived: ' + recordTypeId);
        System.debug('In Edit Controller - RecordTypeId '+opportunity.RecordTypeId+'---'+recordTypeId);
        if (recordTypeId != null && opportunity.RecordTypeId == null) {
            logMessage('no previous record type located, setting to retreived value');
                        System.debug('In Edit Controller - Condition if');
            opportunity.RecordTypeId = recordTypeId;
        }
        //else if (recordTypeId != null && !((String)opportunity.RecordTypeId).contains(recordTypeId)) {
        //    System.debug('In Edit Controller - Condition else');
        //    opportunity.RecordTypeId = recordTypeId;
        //}
        
        //Ritu Sharma - 00010036 - Added to populate lead id & source from the query string
        if (ApexPages.currentPage().getParameters().containsKey('leadid')) 
            opportunity.Marketing_Lead_ID__c = ApexPages.currentPage().getParameters().get('leadid');
        if (ApexPages.currentPage().getParameters().containsKey('src_orig')) 
            opportunity.LeadSource = ApexPages.currentPage().getParameters().get('src_orig');
        
        // set the opportunity pricebook if necessary. Modified for UKI deployment. Chintan Sep 10, 2011
        //Check if this is a US or Canadian Account first
        system.debug('Ritu - '+opportunity.Pricebook2Id);
        system.debug('Ritu - '+this.opportunity.accountId);
        if ((opportunity.Pricebook2Id == null) && (this.opportunity.accountId != null)) {
            logMessage('checking for account country of US or CAN...');
            Account accountInfo = [select id, SDO_Billing_Country_Name__c from Account where id = :this.opportunity.accountId];
            logMessage('retrieved account: ' + accountInfo);
            if ((accountInfo.SDO_Billing_Country_Name__c != null) && (accountInfo.SDO_Billing_Country_Name__c.equalsIgnoreCase('United States')
                    || (accountInfo.SDO_Billing_Country_Name__c.equalsIgnoreCase('Canada')))){
                logMessage('looking up pricebook mapping for US or CAN...');  
                List <Office_Country_Pricebook_Mapping__c> mappings = [select id, Pricebook_Id__c, ISO_Currency__c from Office_Country_Pricebook_Mapping__c where Country_Name__c = :accountInfo.SDO_Billing_Country_Name__c.toLowerCase()];
                if (!mappings.isEmpty()) {
                    logMessage('retrieved mapping: ' + mappings[0]);
                    this.opportunity.pricebook2id = mappings[0].Pricebook_Id__c;
                    this.opportunity.currencyIsoCode = mappings[0].ISO_Currency__c;
                    Pricebook2 pbTemp = new Pricebook2(id = mappings[0].Pricebook_Id__c);
                    this.pricebooks = new Pricebook2[]{pbTemp};
                }
            }
        }           
        logMessage('Amrita11:' + this.opportunity.accountId);
        if (opportunity.Pricebook2Id == null) {
            //read the logged in users reporting country
            logMessage('no pricebook designation found, looking up the logged in users reporting country...');
            String userid = UserInfo.getUserId();
            User currentUser = [select Id, Name, Reporting_Country__c from User where Id = :userid];
            logMessage('retrieved user info: ' + currentUser);
            logMessage('Amrita2:' + this.opportunity.accountId);
            
            if (currentUser.Reporting_Country__c != null) {
                //read the pricebook selection mode for that country
                List<Country_Pricebook_Selection_Mode_Mapping__c> modeMappings = [select id, Mode__c from Country_Pricebook_Selection_Mode_Mapping__c where Country_Name__c = :currentUser.Reporting_Country__c.toLowerCase()];
                if (!modeMappings.isEmpty()) {
                    logMessage('retrieved country to pricebook selection mode mapping: ' + modeMappings[0]);
                    //account based processing
                    if (modeMappings[0].Mode__c.equalsIgnoreCase('Account Based')) {
                        logMessage('Amrita3' + this.opportunity.accountId);
                        if (this.opportunity.accountId != null) {
                            logMessage('account found, retrieving designated office country...');
                            Account accountInfo = [select id, SDO_Billing_Country_Name__c from Account where id = :this.opportunity.accountId];
                            logMessage('retrieved account: ' + accountInfo);
                            if (accountInfo.SDO_Billing_Country_Name__c != null) {
                                logMessage('looking up pricebook mapping for country...');  
                                List <Office_Country_Pricebook_Mapping__c> mappings = [select id, Pricebook_Id__c, ISO_Currency__c from Office_Country_Pricebook_Mapping__c where Country_Name__c = :accountInfo.SDO_Billing_Country_Name__c.toLowerCase()];
                                if (!mappings.isEmpty()) {
                                    logMessage('retrieved mapping: ' + mappings[0]);
                                    this.opportunity.pricebook2id = mappings[0].Pricebook_Id__c;
                                    this.opportunity.currencyIsoCode = mappings[0].ISO_Currency__c;
                                    Pricebook2 pbTemp = new Pricebook2(id = mappings[0].Pricebook_Id__c);
                                    this.pricebooks = new Pricebook2[]{pbTemp};
                                } else {
                                    logMessage('no country to pricebook mapping located. defaulting to standard pricebook...');
                                }
                            } else {
                                logMessage('no office country found on the associated account. defaulting to standard pricebook...');
                            }
                        } else {
                            logMessage('no account found tied to the opportunity. defaulting to standard pricebook...');
                        }
                    } else if (modeMappings[0].Mode__c.equalsIgnoreCase('User Based')) {
                        logMessage('looking up pricebook mapping for users reporting country...');  
                        List <Office_Country_Pricebook_Mapping__c> mappings = [select id, Pricebook_Id__c, ISO_Currency__c from Office_Country_Pricebook_Mapping__c where Country_Name__c = :currentUser.Reporting_Country__c.toLowerCase()];
                        if (!mappings.isEmpty()) {
                            logMessage('retrieved mapping: ' + mappings[0]);
                            this.opportunity.pricebook2id = mappings[0].Pricebook_Id__c;
                            //this.opportunity.currencyIsoCode = mappings[0].ISO_Currency__c;
                            Pricebook2 pbTemp = new Pricebook2(id = mappings[0].Pricebook_Id__c);
                            this.pricebooks = new Pricebook2[]{pbTemp};
                        } else {
                            logMessage('no country to pricebook mapping located. defaulting to standard pricebook...');
                        }
                    }
                } else {
                    logMessage('no country to pricebook selection mode mapping located for current users reporting country ' + currentUser.Reporting_Country__c + '.  defaulting to standard pricebook ...');
                }
            } else {
                logMessage('no Reporting Country value found on current users User record. defaulting to standard pricebook ...');
            }
            if (this.opportunity.Pricebook2Id == null) {
                logMessage('no pricebook designation found, defaulting to the standard');
                logMessage('retreiving information on the standard pricebook...');
                this.pricebooks = [Select p.Name, p.Id From Pricebook2 p where isActive = true and IsStandard = true Order By p.Name limit 1];
                logMessage('retrieved: ' + this.pricebooks);            
                opportunity.Pricebook2Id = this.pricebooks[0].Id;        
            }
        }
        //End Modifications for UKI - Chintan, Sep 10, 2011
        
        // declare local vars
        Set <String> practiceNames = new Set <String>();
        //List <String> practiceNamesAsList = new List <String>();
        
        // retreive the available practices
        this.practices = new List <String>();
        logMessage('reteiving practice info from pricebook id: ' + this.Opportunity.Pricebook2Id);
        List <PricebookEntry> pbEntries = [select id, Product2.Practice__c from PricebookEntry where IsActive = true and Pricebook2Id = :this.Opportunity.Pricebook2Id];
        logMessage('reteived ' + pbEntries.size() + ' price book entries for the designated pricebook: ' + this.opportunity.Pricebook2Id);
        
        logMessage('distilling retrieved entries into distinct practice names...');
        for (PricebookEntry pbEntry : pbEntries) {
          practiceNames.add(pbEntry.Product2.Practice__c);
        }
        logMessage('distilled list: ' + practiceNames);
        this.practices.addAll(practiceNames);
        this.practices.sort();
        logMessage('retreived ' + String.valueOf(this.practices.size()) + ' practices: ' + this.practices);

        // set the owner id if necessary
        if (opportunity.OwnerId == null) {
            logMessage('no opportunity owner located, defaulting to current user: ' + UserInfo.getUserId());
            opportunity.OwnerId = UserInfo.getUserId();
        }       

        // build the JSON script to pass to the page
        logMessage('building JSON retrieval script...');
        getJSONScript = 'function getJSON() {\r\n';
        getJSONScript += '\tvar json = "{\\"Opportunity\\": {";\r\n';
        Integer fCounter = 0;
        for (String fieldName : opportunityFields) {
            if (fieldName.toUpperCase() != 'ID') {
                if (fCounter++ > 0) {
                    getJSONScript += '\tjson += ", ";\r\n';
                }
                getJSONScript += '\tjson += "\\"' + fieldName + '\\": \\"" + getFieldValue(' + fieldName + ') + "\\"";\r\n';
            }           
        }
        getJSONScript += '\tjson += getProductsJSON();';
        getJSONScript += '\tjson += "}}";\r\n\treturn json;\r\n}\r\n';
        
        // if this was an existing opportunity, attempt to load any pre-existing line items
        if (opportunity.Id != null) {
            logMessage('looking for any pre-existing line items...');
            List<OpportunityLineItem> lineItems = [Select Id, PricebookEntryId, PricebookEntry.Name From OpportunityLineItem Where OpportunityId = :opportunity.Id];
            logMessage('located ' + String.valueOf(lineItems.size()) + ' line items: ' + lineItems);
            
            // build the product JSON script
            logMessage('building product JSON script...');
            getJSONScript += '\r\n\r\nvar jsonLoadProducts = { "Products": [ ';
            Integer itemCounter = 0;
            for (OpportunityLineItem item : lineItems) {
                if (itemCounter++ > 0) {
                    getJSONScript += ', ';
                }
                getJSONScript += '{ "Product": { "Id": "' + item.Id + '", "PricebookEntryId": "' + item.PricebookEntryId + '", "PricebookEntryName": "' + item.PricebookEntry.Name + '", "PricebookId": "' + opportunity.Pricebook2Id + '", "RecordTypeId": "' + opportunity.RecordTypeId + '", "Stage": "' + opportunity.StageName + '"} }';
            }
            getJSONScript += '] };'; 
        }
        else {
            getJSONScript += '\r\n\r\nvar jsonLoadProducts = null; \r\n';
        }
        logMessage('built script: ' + getJSONScript);

        // set the product iframe url as necessary
        if (opportunity != null && opportunity.id != null) {
            productIFrameURL = '&oId=' + opportunity.Id;
        } else {
            productIFrameURL = '';
        }
    } //ctlr_OpportunityEdit
    
    
    public PageReference onPageLoad() {
        // debug
        logMessage('onPageLoad START');
      
        // declare local vars
        PageReference redirect = null;
      
        // verify an account id can be located on the querystring
        logMessage('verifying an account id was retreived...');
        if ((this.opportunity.id == null) && (!ApexPages.currentPage().getParameters().containsKey('accid'))) {
            logMessage('no account id found, redirecting...');
            redirect = Page.ErrorPage;
            if (ApexPages.currentPage().getParameters().containsKey('retURL')) {
                redirect.getParameters().put('retURL',ApexPages.currentPage().getParameters().get('retURL'));
            }
        }

        // debug
        logMessage('onPageLoad END');
      
        // return the redirect
        return redirect;
    } //onPageLoad
    
    
    public void init() {
        // debug
        logMessage('init START');
        
        // retrieve information to facilitate the form
        logMessage('retrieving configured edit sections...');
        this.editSections = [Select Name, Collapsible__c, Columns__c, (Select Field_Name__c From Opportunity_Edit_Fields__r Order By Sort_Order__c) From Opportunity_Edit_Section__c Order By Sort_Order__c];
        logMessage('retrieved ' + String.valueOf(editSections.size()) + ' sections: ' + editSections);
        
        // Reload the opportunity with all of the fields we need
        logMessage('reloading the available opportunity fields based on those configured...');
        opportunityFields = new Set<String>();
        for (Opportunity_Edit_Section__c oes : editSections) {
            for (Opportunity_Edit_Field__c oef : oes.Opportunity_Edit_Fields__r) {
                if (oef.Field_Name__c != 'RecordType') {
                    opportunityFields.add(oef.Field_Name__c);
                    logMessage('oppty field set: ' + opportunityFields);
                }
            }
        }
        logMessage('reload complete.');
        logMessage('init END');
    } //init
    
    
    public Pagereference saveAll() {    
        // debug
        System.debug(System.LoggingLevel.INFO, 'saveAll START');
        // re-initialize things
        init();
        
        // set the save point       
        System.debug(System.LoggingLevel.INFO, 'create new savepoint...');
        Savepoint sp = Database.setSavepoint();

        logMessage('opportunity.RecordTypeId: ' + opportunity.RecordTypeId);
        // Remove products
        if (removedProducts != null) {
            List<String> productsToRemove = removedProducts.split(';');
            System.debug(System.LoggingLevel.INFO, 'Deleting these products: ' + productsToRemove);
            if (productsToRemove.size() > 0)
                Database.delete([Select Id From OpportunityLineItem Where Id in :productsToRemove]);
        }

        System.debug(System.LoggingLevel.INFO, 'Opportunity: ' + opportunity);
        System.debug(System.LoggingLevel.INFO, 'JSON String: ' + jsonString);
        System.debug(System.LoggingLevel.INFO, 'create new JSON object...');
        //Case 66693. Chintan, April 02, 2013
        //JSONObject json = new JSONObject(new JSONObject.JSONTokener(jsonString)) ;
        JSONObject json = new JSONObject(new JSONObject.JSONTokener(jsonString.replaceAll('\r\n', '_NEWLINE_')));
        
        Database.UpsertResult ur = null;
        System.debug('Ritu 1 - '+opportunity.Consulting_Referrer__c);
        /* Save Opportunity */
        Boolean allSuccess = true;
        
        logMessage('determining if products exist...');
        if (json.getValue('Opportunity').obj.getValue('Products') != null) {
            logMessage('Products were detected, proceeding with attempting to save the opportunity...');
            try {
                //JSONObject
                System.debug(System.LoggingLevel.INFO, 'populating opportunity fields...');
                System.debug(json.getValue('Opportunity').obj);
                PopulateOpportunityFields(json.getValue('Opportunity').obj);
                if (opportunity.pricebook2id == null) {
                    System.debug('collected pricebooks: ' + this.pricebooks);
                    System.debug('attempting to set the pricebook id to value: ' + this.pricebooks[0].id);
                    opportunity.pricebook2id = this.pricebooks[0].id;
                }
                System.debug(System.LoggingLevel.INFO, 'Opportunity: ' + opportunity);      
                System.debug(System.LoggingLevel.INFO, 'upserting opportunity...');
                System.debug('Ritu 2 - '+opportunity.Consulting_Referrer__c);
                String savedRtId = opportunity.RecordTypeId;
                //----------- CPL - Start Save Opportunity Competitor--------------
                if(chosenList!= null && chosenList.size() > 0) {
                    // System.debug(System.LoggingLevel.INFO, 'CPL Added comps are : ' + combineOptions(chosenList));  
                    String strChosenCompetitor = combineOptions(chosenList);
                    System.debug('Amrita Added comps are :' + strChosenCompetitor);
                    if((strChosenCompetitor == null) || (strChosenCompetitor.EqualsIgnoreCase(''))) {
                        opportunity.Competitor__c = '';
                    } else {
                        opportunity.Competitor__c = combineOptions(chosenList);
                    }                   
                }
                else {
                    opportunity.Competitor__c = '';
                }
                System.debug('Ritu 3 - ' + opportunity.Consulting_Referrer__c);
                //----------- CPL - End Save Opportunity Competitor---------------
                logMessage('opportunity.RecordTypeId (before upsert): ' + opportunity.RecordTypeId);
                ur = Database.upsert(opportunity, false);

                logMessage('opportunity.RecordTypeId (after upsert): ' + opportunity.RecordTypeId);
                opportunity.RecordTypeId = savedRtId;
                logMessage('opportunity.RecordTypeId (after upsert): ' + opportunity.RecordTypeId);
                
                System.debug(System.LoggingLevel.INFO, 'received upsert response: ' + ur);
                System.debug(System.LoggingLevel.INFO, 'processing upsert response...');
                ProcessURForOpportunity(ur);
                allSuccess = ur.isSuccess();
                System.debug('Ritu 4 - '+opportunity.Consulting_Referrer__c);
                System.debug(System.LoggingLevel.INFO, 'Opportunity: ' + opportunity);  
            }
            catch (Exception e) {
                // An exception occurred while saving the opportunity.  If it is a new opportunity then just break out.
                //if (opportunity.Id == null) throw e;
                System.debug(System.LoggingLevel.INFO, 'an exception occurred while attempting to save the opportunity data: ' + e.getMessage());
                ProcessURForOpportunity(ur);
                
                if (opportunity.Id == null) {
                    Database.rollback(sp);
                    return null;
                }           
            }

            // only save products if we passed on the opportunity
            if (allSuccess) {
                logMessage('opportunity.RecordTypeId: ' + opportunity.RecordTypeId);
                System.debug(System.LoggingLevel.INFO, 'attempting to save the opportunity products...');
                List<OpportunityLineItem> olis = new List<OpportunityLineItem>();
                List<Database.Upsertresult> urs = new List<Database.Upsertresult>();
                Map<String, Schema.SObjectField> describeOliFields = null;
                try {           
                    if (opportunity.Id != null) {
                        List<dto_editLineItemProduct> products = new List<dto_editLineItemProduct>();
                    
                        // processing products
                        logMessage('performing line item describe...');
                        describeOliFields = Schema.SObjectType.OpportunityLineItem.fields.getMap();
                        logMessage('line item describe complete');
                        
                        // iterate over the json items and convert 
                        for (JSONObject.value jsonProduct : json.getValue('Opportunity').obj.getValue('Products').values) {
                            logMessage('converting product JSON into edit line item DTO: ' + jsonProduct.obj.getValue('Product'));
                            String oliId = '';
                            try {
                                oliId = jsonProduct.obj.getValue('Product').obj.getString('Id');
                            } catch (Exception ex) {
                                oliId = null;
                            }
                            logMessage('json product id: ' + oliId);
                            products.add(PopulateProductFields(jsonProduct.obj.getValue('Product').obj, jsonProduct.obj.getValue('Product').obj.getString('PricebookEntryId'), oliId, describeOliFields));
                        }
                        System.debug(System.LoggingLevel.INFO, 'There are ' + products.size() + ' products to be upserted.');
                        for (dto_editLineItemProduct dto : products) {
                            System.debug(System.LoggingLevel.INFO, dto);
                            olis.add(dto.LineItem);
                        }
                         
                        System.debug(System.LoggingLevel.INFO, '########### Saving ' + olis.size() + ' products');
                                            
                        urs = Database.upsert(olis, false);

                        if (!ProcessURForProducts(olis, urs)) {
                            AddOpportunityFieldError(null,'One or more errors occurred while attempting to save the Product information.  Please review the details below and re-attempt to save');
                            allSuccess = false;
                        }

                        for (Database.Upsertresult ur2 : urs) {
                            if (!ur2.isSuccess()) {
                                allSuccess = false;
                                break;
                            }
                        }
                    }
                } catch (Exception e) {
                    ProcessURForProducts(olis, urs);
                    allSuccess = false;
                    System.debug(System.LoggingLevel.INFO, 'saveALL END - Exception in Save Products: ' + + e.getMessage());
                }
            }
        } else {
            System.debug(System.LoggingLevel.INFO, 'no products exist.');
            AddOpportunityFieldError(null,'Please ensure you have added at least one Product before saving');
            allSuccess = false;
        }
        
        if (!allSuccess) {
            logMessage('AN ERROR OCCURRED AT SOME POINT, ROLLING BACK...');
            Database.rollback(sp);
            System.debug(System.LoggingLevel.INFO, 'saveALL END - allSuccess = False');
            return null;
        }
        System.debug(System.LoggingLevel.INFO, 'saveAll END');
        
        /*
        //Remove Newlines. A convoluted way of going about it because everything else I tried breaks something else.
        //Simply replacing _NEWLINE_ with a \r\n prevents error messages from Product missing fields to be displayed for some reason
        //Case 66693, Chintan. April 2, 2013
        Opportunity myOpp = [Select Description from Opportunity Where Id = :opportunity.Id];
        if (myOpp.Description != null && (myOpp.Description.contains('_NEWLINE_') || myOpp.Description.contains('_QUOTE_'))) {
            myOpp.Description = myOpp.Description != null ? myOpp.Description.replaceAll('_NEWLINE_', '\r\n').replaceAll('_QUOTE_', '"') : null;
            update myOpp;
        }
        */
        
        List<OpportunityLineItem> olisToUpdate = new List<OpportunityLineItem> ();
        List<OpportunityLineItem> myOlis = [Select Milestones_and_Amounts__c From OpportunityLineItem Where OpportunityId = :opportunity.Id];
        for (OpportunityLineItem myOli : myOlis) {
            if (myOli.Milestones_and_Amounts__c != null && (myOli.Milestones_and_Amounts__c.contains('_NEWLINE_') || myOli.Milestones_and_Amounts__c.contains('_QUOTE_'))) {
                myOli.Milestones_and_Amounts__c = myOli.Milestones_and_Amounts__c != null ? myOli.Milestones_and_Amounts__c.replaceAll('_NEWLINE_', '\r\n').replaceAll('_QUOTE_', '"') : null;
                olisToUpdate.add(myOli);
            }
        }
        if (!olisToUpdate.isEmpty()) {
            update olisToUpdate;
        }
        //End Changes Case 66693
        return new PageReference('/' + opportunity.Id);
    } //saveAll
    
    
    public Boolean getHasProductResults() {
        return jsonProductResults != null && jsonProductResults != '';
    } //getHasProductResults
    
    
    private Boolean ProcessURForProducts(List<OpportunityLineItem> olis, List<Database.UpsertResult> urs) {
        System.debug(System.LoggingLevel.INFO, '################## ProcessURForProducts BEGIN');
        
        Boolean result = true;
        Integer counter = 0;
        String json = '{ "Products": [ ';
        
        System.debug(System.LoggingLevel.INFO, 'There are ' + urs.size() + ' UpsertResults to process');
                    
        for (Database.UpsertResult ur : urs) {
            if (counter > 0) json += ', ';
            
            OpportunityLineItem oli = olis[counter];
            
            System.debug(System.LoggingLevel.INFO, 'Matched UR to ' + oli);
            
            json += ' { "Product": { ';

            json += '"Id": "' + oli.Id + '", ';
            json += '"OpportunityId": "' + oli.OpportunityId + '", ';
            json += '"PricebookEntryId": "' + oli.PricebookEntryId + '", ';
            json += '"isSuccess": "' + ur.isSuccess() + '", ';
            
            json += '"Errors": [ ';

            Integer errorCounter = 0;
            
            List<Database.Error> errors = ur.getErrors();
            
            System.debug(System.LoggingLevel.INFO, 'There are ' + errors.size() + ' errors to process.');
        
            for (Database.Error err : errors) {
                result = false;
                if (errorCounter++ > 0) json += ', ';
                
                System.debug(System.LoggingLevel.INFO, 'Message: ' + err.getMessage());
                System.debug(System.LoggingLevel.INFO, 'StatusCode: ' + err.getStatusCode());
                
                json += ' { "Error": { ';
                json += '"Message": "' + err.getMessage() + '", ';
                json += '"StatusCode": "' + err.getStatusCode() + '", ';
                json += '"Fields": [ ';
                
                Integer fieldsCounter = 0;
                List<String> fields = err.getFields();
                
                System.debug(System.LoggingLevel.INFO, 'There are ' + fields.size() + ' to process.');
                
                for (String fieldName : err.getFields()) {
                    System.debug(System.LoggingLevel.INFO, 'Field: ' + fieldName);
                    if (fieldsCounter++ > 0) json += ', ';
                    json += ' { "Field": { ';
                    json += '"Name": "' + fieldName + '"';
                    json += ' }}';
                }
                
                json += ' ] }}';
            }
            
            json += ' ]';
                        
            json += ' } } ';
            
            counter++;      
        }
        
        json += ']}';
        
        System.debug(System.LoggingLevel.INFO, 'PRODUCT RESULT JSON: ' + json);
        
        System.debug(System.LoggingLevel.INFO, '################## ProcessURForProducts END');
        
        jsonProductResults = json;
        
        return result;
    } //ProcessURForProducts
    
        
    private dto_editLineItemProduct PopulateProductFields(JSONObject json, String pricebookEntryId, String opptyLineItemId, Map<String, Schema.SObjectField> describeOliFields) {
        System.debug(System.LoggingLevel.INFO, '######### PopulateProductFields START');
    
        // debug 
        logMessage('PopulateProductFields START');
        logMessage('json to convert: ' + json);
        logMessage('pricebook entry id: ' + pricebookEntryId);
        logMessage('opportunity line item id: ' + opptyLineItemId);
        
        // declare local vars
        OpportunityLineItem oli = null;
        
        // get handles to key attributes
        String pricebook2Id = opportunity.Pricebook2Id;
        logMessage('pricebook id: ' + pricebook2Id);
        JSONObject jsonFields = json.getValue('Fields').obj;
        
        // get information about the received price book entry
        logMessage('retrieving price book entry data...');
        PricebookEntry pe = [select id, Product2Id, Product2.Use_Product_Specific_Field_List__c, Product2.Service_Classification__c from PricebookEntry where id = :pricebookEntryId];
        logMessage('retrieved: ' + pe);
        
        // look to see if this line item has an id
        if (opptyLineItemId != null) {
            logMessage('received opportunity line item id: ' + opptyLineItemId);
            logMessage('loading existing opportunity line item instance...');
            oli = Database.query('Select ' + util_globalUtilityMethods.joinStringSet(util_globalUtilityMethods.getFieldsForObject('OpportunityLineItem'), false) + ' From OpportunityLineItem Where Id = \'' + opptyLineItemId + '\'');
            logMessage('retreived line item: ' + oli);
        } else {
            logMessage('creating opportunity line item instance...');
            oli = new OpportunityLineItem(PricebookEntryId = pe.Id, OpportunityId = opportunity.Id);
            logMessage('created a new opportunity line item instance: ' + oli);
        } 
        
        logMessage('creating a new dto to represent product...');
        dto_editLineItemProduct dto = new dto_editLineItemProduct(opportunity, oli, pe);
        logMessage('dto created: ' + dto);
        
        logMessage('iterating over the configured field list...');
        for (Product_Field_List__c field : dto.FieldList) {
            
            // declare local vars
            String fieldNameValue = null;
            String fieldName = field.Field_Name__c.toUpperCase();
            Schema.Displaytype dt = null;
            
            // debug
            logMessage('field name: ' + field.Field_Name__c);
            logMessage('source object: ' + field.Source_Object__c);
            
            // get a handle on the field name value
            try {
                fieldNameValue = scrubNullValues(jsonFields.getString(field.Field_Name__c));
            }
            catch (Exception e) {
                System.debug(System.LoggingLevel.INFO, 'Exception getting field name value; fieldName: ' + field.Field_Name__c + ';  Exception Message: ' + e.getMessage());
            } 
            logMessage('field name value: ' + fieldNameValue);
            
            logMessage('attempt to retrieve display type for opportunity line item field [' + field.Field_Name__c + ']');
            dt = describeOliFields.get(field.Field_Name__c).getDescribe().getType();
            logMessage('data type: ' + dt);

            // if we encounter an opportunity line item field, attempt to get a handle on the specific value
            if (field.Source_Object__c == 'OpportunityLineItem') {
                if (dt == Schema.Displaytype.PERCENT) {
                    //Chintan, April 04, 2012 Case 9953 
                    //logMessage('percent value located: ' + jsonFields.getDouble(field.Field_Name__c));
                    //oli.put(field.Field_Name__c, jsonFields.getDouble(field.Field_Name__c));
                    logMessage('percent value located: ' + jsonFields.getString(field.Field_Name__c));
                    oli.put(field.Field_Name__c, convertJSONValueIntoDecimal(jsonFields.getString(field.Field_Name__c)));
                } else if (dt == Schema.Displaytype.DATE) {
                    logMessage('date value located: ' + jsonFields.getDate(field.Field_Name__c));
                    oli.put(field.Field_Name__c, jsonFields.getDate(field.Field_Name__c));
                } else if (dt == Schema.Displaytype.MULTIPICKLIST) {
                    logMessage('multi picklist value located: ' + jsonFields.getString(field.Field_Name__c));
                    oli.put(field.Field_Name__c, jsonFields.getString(field.Field_Name__c));
                } else if (dt == Schema.Displaytype.CURRENCY) {
                    logMessage('currency field located: ' + field.Field_Name__c);
                    logMessage('currency value located: ' + jsonFields.getString(field.Field_Name__c));
                    //oli.put(field.Field_Name__c, decimal.valueOf((jsonFields.getString(field.Field_Name__c)).replace(',','')));
                    //Chintan, March 05, 2012. Case 8901. Next 2 lines
                    //oli.put(field.Field_Name__c, convertJSONValueIntoDecimal(jsonFields.getString(field.Field_Name__c)));
                    oli.put(field.Field_Name__c, convertJSONCurrencyIntoDecimal(field.Field_Name__c, jsonFields.getString(field.Field_Name__c)));
                } else if (dt == Schema.Displaytype.DOUBLE) {
                    //logMessage('located double value: ' + jsonFields.getDouble(field.Field_Name__c));
                    oli.put(field.Field_Name__c, convertJSONValueIntoDecimal(jsonFields.getString(field.Field_Name__c)));
                } else if(dt == Schema.Displaytype.INTEGER) {
                    //logMessage('located integer value: ' + jsonFields.getDouble(field.Field_Name__c));
                    oli.put(field.Field_Name__c, convertJSONValueIntoInteger(jsonFields.getString(field.Field_Name__c)));
                } else if (dt == Schema.Displaytype.BOOLEAN) {
                    logMessage('located boolean value: ' + jsonFields.getString(field.Field_Name__c));
                    if (jsonFields.getString(field.Field_Name__c).equalsIgnoreCase('1')) {
                        oli.put(field.Field_Name__c, true); 
                    } else {
                        oli.put(field.Field_Name__c, false);
                    }
                } else if (dt == Schema.Displaytype.REFERENCE) {
                    System.debug(System.LoggingLevel.INFO, '############### REFERENCE: ' + scrubNullValues(jsonFields.getString(field.Field_Name__c)));
                    if (scrubNullValues(jsonFields.getString(field.Field_Name__c)) == null) {
                        //opportunity.put(field, '');
                    } else {
                        oli.put(field.Field_Name__c, scrubNullValues(jsonFields.getString(field.Field_Name__c)));
                    }
                } 
                else {
                    oli.put(field.Field_Name__c, fieldNameValue);
                    //oli.put(field.Field_Name__c, fieldNameValue.replaceAll('_NEWLINE_', '\r\n'));
                }
            } else {
                System.debug(System.LoggingLevel.INFO, 'defined field is not for opportunity line item or product, skipping it...');                
            }       
        }
        
        System.debug(System.LoggingLevel.INFO, 'built oli: ' + dto.LineItem);       
        System.debug(System.LoggingLevel.INFO, '######### PopulateProductFields END');

        return dto;
    } //PopulateProductFields
    
    
    private Decimal convertJSONValueIntoDecimal(String jsonValue) {
        
        // debug
        logMessage('convertJSONValueIntoDecimal START');
        logMessage('attempting to convert value [' + jsonValue + '] into a decimal...');
        
        // declare local vars
        Decimal returnVal = null;
        
        if ((jsonValue != null) && (jsonValue != '') & (jsonValue != 'null')) {
            logMessage('value located.  stripping thousand seperators...');
            String valueWithoutThousandSeperators = jsonValue.replace(',','');
            logMessage('after strip, value: ' + valueWithoutThousandSeperators + '  attempting to convert to a decimal...');
            try {
                Decimal convertedValue = Decimal.valueOf(valueWithoutThousandSeperators);
                logMessage('converted value: ' + convertedValue);
                returnVal = convertedValue;
            } catch (Exception ex) {
                logMessage('an error occurred, returning the default');
            }
        } else {
            logMessage('no value located.  returning default...');
        }
        
        // debug
        logMessage('returning ' + returnVal);
        logMessage('convertJSONValueIntoDecimal END');
        return returnVal;
    } //convertJSONValueIntoDecimal
    

    public Integer convertJSONValueIntoInteger(String jsonValue) {
        // debug
        logMessage('convertJSONValueIntoInteger START');
        logMessage('attempting to convert value [' + jsonValue + '] into an integer...');
        
        // declare local vars
        Integer returnVal = null;
        
        if ((jsonValue != null) && (jsonValue != '') & (jsonValue != 'null')) {
            logMessage('value located.  stripping thousand seperators...');
            String valueWithoutThousandSeperators = jsonValue.replace(',','');
            logMessage('after strip, value: ' + valueWithoutThousandSeperators + '  attempting to convert to an integer...');
            try {
                Integer convertedValue = Integer.valueOf(valueWithoutThousandSeperators);
                logMessage('converted value: ' + convertedValue);
                returnVal = convertedValue;
            } catch (Exception ex) {
                logMessage('an error occurred, returning the default');
            }
        } else {
            logMessage('no value located.  returning default...');
        }
        
        // debug
        logMessage('returning ' + returnVal);
        logMessage('convertJSONValueIntoInteger END');
        return returnVal;
    } //convertJSONValueIntoInteger
    
/* Comenting out as part of Case 15598. Rewritten method below. Retaining this method for future reference & learning. 
    //Method to handle currency conversions to deal with locale issues. Case 8901. Chintan Adhyapak. March 01, 2012
    //Added the second else block for case 15598 - Swiss locale using ' as the separator
    private Decimal convertJSONCurrencyIntoDecimal(String fieldName, String jsonValue) {
        logMessage('convertJSONCurrencyIntoDecimal START');
        System.debug('CHINTAN convertJSONCurrencyIntoDecimal invoked for field name ' + fieldName + ' and Value ' + jsonValue);
        
        //local vars
        Decimal returnVal = null;

        if ((jsonValue != null) && (jsonValue != '') && (jsonValue != 'null')) {
            logMessage('CHINTAN lastindexof comma is ' + jsonValue.lastIndexOf(','));
            if ((jsonValue.length() > 2) && (jsonValue.lastIndexOf(',') == jsonValue.length() - 3)) {
                String valueWithoutSeperators = jsonValue.substring(0, jsonValue.length() - 3);
                valueWithoutSeperators = valueWithoutSeperators.replaceAll('\\D', '');
                System.debug('CHINTAN valueWithoutSeparators is ' + valueWithoutSeperators);
                returnVal = convertJSONValueIntoDecimal(valueWithoutSeperators);
            } else if ((jsonValue.length() > 2) && (jsonValue.lastIndexOf('.') == jsonValue.length() - 3)) {
                String valueWithoutSeperators = jsonValue.substring(0, jsonValue.length() - 3);
                valueWithoutSeperators = valueWithoutSeperators.replaceAll('\\D', '');
                System.debug('CHINTAN valueWithoutSeparators is ' + valueWithoutSeperators);
                returnVal = convertJSONValueIntoDecimal(valueWithoutSeperators);
            } else {
                returnVal = convertJSONValueIntoDecimal(jsonValue);
            }       
            System.debug('CHINTAN returning ' + returnVal);
            System.debug('convertJSONCurrencyIntoDecimal END');
        }
        return returnVal;
    } //convertJSONCurrencyIntoDecimal
*/    
    
    
    /*  Rewritten for currency handling formats for case 15598 - Chintan Adhyapak, June 25, 2012
        Remove the 'cents' part of amount if any; then remove all non numeric chars; finally convert to decimal
        July 09, 2012. Chintan - Modified for Case 19125. Retained dollars and cents both
    */
    private Decimal convertJSONCurrencyIntoDecimal(String fieldName, String jsonValue) {
        logMessage('convertJSONCurrencyIntoDecimal START');
        System.debug('CHINTAN convertJSONCurrencyIntoDecimal invoked for field name ' + fieldName + ' and Value ' + jsonValue);
        
        //local vars
        Decimal returnVal = null;
        String dollars = null; //The 'Dollars' part of all amounts
        String cents = '00'; //The 'Cents' part of all amounts

        if ((jsonValue != null) && (jsonValue != '') && (jsonValue != 'null')) {
            //Handle Comma Or Dot Separator for 'cents' value
            if ((jsonValue.length() > 2) && ((jsonValue.lastIndexOf(',') == jsonValue.length() - 3) || (jsonValue.lastIndexOf('.') == jsonValue.length() - 3))) {
                dollars = jsonValue.substring(0, jsonValue.length() - 3);
                cents = jsonValue.substring(jsonValue.length() - 2);
                System.debug('CHINTAN Dollars value is ' + dollars);
                System.debug('CHINTAN Cents value is ' + cents);
                //Remove all non-numeric characters from the 'Dollars' part of amount
                dollars = dollars.replaceAll('\\D', '');
                jsonValue = dollars + '.' + cents;
            } else {
                //Remove all non-numeric characters
                jsonValue = jsonValue.replaceAll('\\D', '');
            }
            System.debug('CHINTAN After non-numeric char removal, value is ' + jsonValue);
            try {
                Decimal convertedValue = Decimal.valueOf(jsonValue);
                logMessage('converted value: ' + convertedValue);
                returnVal = convertedValue;
            } catch (Exception ex) {
                logMessage('an error occurred, returning the default');
            }
        } else {
            logMessage('no value located.  returning default...');
        }
        // debug
        logMessage('returning ' + returnVal);
        logMessage('convertJSONCurrencyIntoDecimal END');
        
        return returnVal;
    } //convertJSONCurrencyIntoDecimal
    
    
    private void PopulateOpportunityFields(JSONObject json) {
        System.debug(System.LoggingLevel.INFO, 'PopulateOpportunityFields START');
        System.debug(System.LoggingLevel.INFO, 'json: ' + json);
        System.debug(System.LoggingLevel.INFO, 'there are ' + opportunityFields.size() + ' opportunity fields we need to process: ' + opportunityFields);
        
        System.debug(System.LoggingLevel.INFO, 'performing a describe on opportunity...');
        Map<String, Schema.SObjectField> describeFields = Schema.SObjectType.Opportunity.fields.getMap();

        
        // attempt to retrieve the opportunity from the db
        String rtId = opportunity.RecordTypeId;
        if (opportunity.id != null) {
            logMessage('verifying an opportunity exist with an id of: ' + opportunity.Id);
            Integer recordCt = [select count() from Opportunity where Id = :opportunity.Id];
            logMessage('returned record count: ' + recordCt);
            if (recordCt == 0) {
                opportunity = new Opportunity();
                opportunity.RecordTypeId = rtId;
            }
        }       
        
        System.debug(System.LoggingLevel.INFO, 'iterating over the fields...');
        for (String field : opportunityFields) {
            String fieldName = field.toUpperCase();
            System.debug(System.LoggingLevel.INFO, 'processing field: ' + fieldName);
            
            //if (fieldName == 'ID' || fieldName == 'RECORDTYPEID' || fieldName == 'PRICEBOOK2ID') {
            //  System.debug(System.LoggingLevel.INFO, 'field is a special field (id, recordtypeid, pricebook2id)');
            //  continue;
            //}
            if (fieldName.equalsIgnoreCase('id') || fieldName.equalsIgnoreCase('PRICEBOOK2ID')) {
                System.debug(System.LoggingLevel.INFO, 'field is a special field (' + fieldName + ')');
                continue;
            }
            
            System.debug(System.LoggingLevel.INFO, 'retrieving the display type for the field...');
            Schema.Displaytype dt = describeFields.get(field).getDescribe().getType();
            System.debug(System.LoggingLevel.INFO, 'display type: ' + dt);
            System.debug(System.LoggingLevel.INFO, 'JSON value: ' + json.getString(field));
            
            if (dt == Schema.Displaytype.PERCENT) {
                System.debug(System.LoggingLevel.INFO, '############### PERCENT: ' + json.getDouble(field));
                opportunity.put(field, json.getDouble(field));
            } else if (dt == Schema.Displaytype.DATE) {
                System.debug(System.LoggingLevel.INFO, '############### DATE: ' + json.getDate(field));
                opportunity.put(field, json.getDate(field));
            } else if (dt == Schema.Displaytype.MULTIPICKLIST) {
                System.debug(System.LoggingLevel.INFO, '############### MULTIPICKLIST: ' + json.getString(field));
                opportunity.put(field, json.getString(field));
            } else if (dt == Schema.Displaytype.CURRENCY) {
                logMessage('############### CHINTAN CURRENCY field Name: ' + field);
                opportunity.put(field, convertJSONValueIntoDecimal(json.getString(field)));
            } else if (dt == Schema.Displaytype.DOUBLE) {
                //System.debug(System.LoggingLevel.INFO, '############### DOUBLE: ' + json.getDouble(field));
                opportunity.put(field, convertJSONValueIntoDecimal(json.getString(field)));
            } else if (dt == Schema.Displaytype.INTEGER) {
                //System.debug(System.LoggingLevel.INFO, '############### DOUBLE: ' + json.getDouble(field));
                opportunity.put(field, convertJSONValueIntoInteger(json.getString(field)));
            } else if (dt == Schema.Displaytype.Boolean) {
                System.debug(System.LoggingLevel.INFO, '############### BOOLEAN: ' + json.getString(field));
                if (json.getString(field).equalsIgnoreCase('1')) {
                    opportunity.put(field, true);
                } else {
                    opportunity.put(field, false);
                }
            } else if (dt == Schema.Displaytype.REFERENCE) {
                System.debug(System.LoggingLevel.INFO, '############### REFERENCE: ' + scrubNullValues(json.getString(field)));
                if (scrubNullValues(json.getString(field)) == null) {
                    //opportunity.put(field, '');
                } else {
                    opportunity.put(field, scrubNullValues(json.getString(field)));
                }
            } else if (fieldName.equals('DESCRIPTION') || fieldName.equals('NEXTSTEP')) {
                /* Fix for Description newlines and quotes, Chintan, July 18, 2014. Case 121233 */
                opportunity.put(field, scrubNullValues(json.getString(field)) != null ? json.getString(field).replaceAll('_NEWLINE_', '\r\n').replaceAll('_QUOTE_', '"') : null);
            } else {
                 opportunity.put(field, scrubNullValues(json.getString(field)));
            }
        }
        
        
        // debug
        System.debug(System.LoggingLevel.INFO, 'PopulateOpportunityFields END');
    } //PopulateOpportunityFields
    
    
    // json will pass a string of 'null' when no value has been received.  So to transfer this to an actual null we must do some extra work
    private String scrubNullValues(String jsonValue) {
        logMessage('scrubbing nulls on inbound value: ' + jsonValue);
        if ((jsonValue != null) && (jsonValue.equalsIgnoreCase('null')) || jsonValue == 'undefined') {
            logMessage('null detected, returning null...');
            return null;
        }
        return jsonValue;
    } //scrubNullValues
    
     
    private void ProcessURForOpportunity(Database.UpsertResult ur) {
        System.debug(System.LoggingLevel.INFO, 'ProcessURForOpportunity START');
        System.debug(System.LoggingLevel.INFO, '################ ProcessURForOpportunity: ' + ur);
        if (ur == null) {
            System.debug(System.LoggingLevel.INFO, 'received response was null, returning...');
            return;
        }
        
        System.debug(System.LoggingLevel.INFO, 'within the upsert result there were ' + ur.getErrors().size() + ' errors: ' + ur.getErrors());
        for (Database.Error err : ur.getErrors()) {
            System.debug(System.LoggingLevel.INFO, '############## DB Error: ' + err);
            AddOpportunityFieldError(null, err.getMessage());
        }
        System.debug(System.LoggingLevel.INFO, 'ProcessURForOpportunity END');
    } //ProcessURForOpportunity
    
    
    private void AddOpportunityFieldError(String fieldName, String message) {
        
        System.debug(System.LoggingLevel.INFO, 'Adding an error message to the current page: ' + message);
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, message));
    } //AddOpportunityFieldError
    

    public Pagereference getProbabilityDefault() {
        logMessage('######## loadProbabilityDefault START');
        logMessage('stageName: ' + gpStageName);
        
        List<OpportunityStage> defaults = [Select DefaultProbability From OpportunityStage Where MasterLabel = :gpStageName LIMIT 1];
        logMessage('Returned ' + defaults.size() + ' defaults');
        if (defaults.size() > 0) 
        {
            logMessage('Setting defaultProbability: ' + defaults[0].DefaultProbability);
            defaultProbability = defaults[0].DefaultProbability.intValue();
        }
        else
            defaultProbability = 0;
            
        logMessage('defaultProbability: ' + defaultProbability);
        hasProbabilityDefault = true;
        logMessage('######## loadProbabilityDefault END');
        return null;
    } //getProbabilityDefault
    
    
    public Pagereference getProductsByPractice() {
        // debug
        System.debug(System.LoggingLevel.INFO, 'getProductsByPractice START');
        System.debug(System.LoggingLevel.INFO, 'selected practice: ' + this.practice);
        
        System.debug(System.LoggingLevel.INFO, 'retrieving pricebook entries...');
        this.availableProducts = [select id, Name, Product2.Id, Product2.Name From PricebookEntry Where Product2.Practice__c = :this.practice and 
            Pricebook2Id = :opportunity.Pricebook2Id And IsDeleted = false And IsActive = true and Product2.IsActive = true and CurrencyIsoCode = :this.currencyIsoCode Order By Name];
        System.debug(System.LoggingLevel.INFO, 'retrieved ' + this.availableProducts.size() + ' pricebook entries: ' + this.availableProducts);
        
        // debug
        System.debug(System.LoggingLevel.INFO, 'getProductsByPractice END');
        return null;
    } //getProductsByPractice
       
    
    private void logMessage(String msg) {
        System.debug(LoggingLevel.DEBUG, msg);
    } //logMessage
    
    
    // CPL ------------------------------------------------------
    public List<SelectOption> getchosenList() 
    { 
        try
        {
            chosenList = Sort(chosenList);
        }
        catch(Exception exp)
        {
            chosenList = new List<SelectOption>();
            //logMessage('Error in getchosenList()');
        }
        return chosenList;
    } //getchosenList

   
    public List<SelectOption> getavailableList()
    {
        try
        { 
            AvailableList = Sort(AvailableList);
        }
        catch(Exception exp)
        {
            AvailableList = new List<SelectOption>();
           // logMessage('Error in getavailableList()');
        }
        return AvailableList;
        
    } //getavailableList
    
    
    
    // A method to combine chosen option seperated by ";", this is used to save the opportunity competitor
    public String combineOptions(List<SelectOption> values) 
    {
        String result = '';
        try
        {
            for(SelectOption selOpt: values) 
            {
                result = result == '' ? selOpt.getValue() : result + MULTIPICKLIST_SEPERATOR + selOpt.getValue();
            }
            return result.length()  > 0 ? result.substring(0, result.length()): result;
        }
        catch(Exception exp)
        {
            //result = '';
            //logMessage('Error in combining chosen list options: combineOptions');    
            return '';
        }
         
    } //combineOptions
    
    
    // A method to load available competitor list and chosen conpetitor list
    public void LoadCompetitorList()
    {
        //logMessage('Start LoadCompetitorList ');
        try
        {
            //logMessage('current opportunity is:' +     opportunity );    
            // A map to store all competitors 
            // Added where clause to fetch Active Competitors, Case # 00133435 
            Map<Id,Competitor__c> mapCompetitor = new Map<Id,Competitor__c>([SELECT Name FROM Competitor__c Where Company_Status__c = 'Active' ORDER BY Name]);
    
            // A list to store the items for Available List
            List<SelectOption> optionsAvailable = new List<SelectOption>();   
    
            // A list to store the items for Chosen List
            List<SelectOption> optionsChosen = new List<SelectOption>();  
    
            // A list to store all competitors selected for the current opportunity, if any
            List<String> compsSaved = new List<String>();
            
            // A flag to keep track of competitor to be chosen
            Boolean setChosen = false;
            
            if(opportunity != null)       
            {
                try
                {        
                    // Get the name of all competitors saved with current opportunity
                    if(opportunity.Competitor__c != '' && opportunity.Competitor__c != null)
                    {
                        compsSaved = (opportunity.Competitor__c).split(';');
                       // logMessage('Current Competitor : ' + opportunity.Competitor__c);
                        for(Competitor__c comp : mapCompetitor.values())
                        {
                            String strCompName = comp.Name;
                            for(String oppComp: compsSaved) 
                            {
                                if(oppComp.EqualsIgnoreCase(strCompName))  // If the competitor is chosen for current opportunity                     
                                {
                                    setChosen = true;
                                    break;
                                }
                            }
                            if(setChosen ) // If competitor is chosen for current opportunity, add to chosen list
                            {
                                optionsChosen.add(new SelectOption(strCompName,strCompName)); 
                            }
                            else // else add to available list
                            {
                                optionsAvailable.add(new SelectOption(strCompName,strCompName)); 
                            }
                            setChosen = false;
                        }
                    }
                    else
                    {
                        for(Competitor__c comp : mapCompetitor.values())
                        {
                            String strCompName = comp.Name;
                            optionsAvailable.add(new SelectOption(strCompName,strCompName));                            
                        }
                        
                    }                
                } 
                catch(Exception ex) {
                    //logMessage('Error in loading competitor : ' + ex.getMessage());
                }
                optionsAvailable = Sort(optionsAvailable);
                AvailableList = optionsAvailable;   
                
                optionsChosen = Sort(optionsChosen);
                chosenList = optionsChosen;   
                         
            }
        }
        catch(Exception exp)         {
           // logMessage('Error in LoadCompetitorList : ' + exp.getMessage());
        }
    } //LoadCompetitorList
    
    
   // A method to sort the list of options
    public List<String> sortList(List<String> competitors) 
    {
        try
        {
            // Initialize a map and a list that will aide with sorting
            Map<String, String> interimMap = new Map<String, String>();
            List<String> interimList = new List<String>();
            
            // Move content of the Competitors list to the interim Map & List. 
            //Use Competitors Name in CAPS as the Key and original value in the value set. Add the Competitors in List in CAPS for sorting
            for(String competitor : Competitors){
                interimMap.put(competitor.toUpperCase(), competitor);
                interimList.add(competitor.toUpperCase());
            }
                        
            // Sort the interimList. Since all values are CAPS they will be appropriately sequenced
            interimList.sort();
        
            // purge the initial competitors list
            competitors.clear();
                        
            // Populate the Competitors list with the original value from the Map. Use the Sorted interimList to pull data in sequence.
            for(String competitor : interimList){
                competitors.add(interimMap.get(competitor));
            }
        }
        catch(Exception exp)  {
            competitors = new List<String>();
            //logMessage('Error in sortList : ' + exp.getMessage());    
        }
        return competitors;
    } //sortList
    

    // A method to sort list of SelectOptions
    public List<SelectOption> Sort(List<SelectOption> lstToSort)
    {
        List<SelectOption> returnList = new List<SelectOption>();
        try
        {
            //logMessage('Original List: ' + lstToSort);
    
            // Convert SelectOption list To String List
            List<String> convertedList = new List<String>();
            for(SelectOption opt: lstToSort)
            {
                convertedList.add(opt.getLabel()); 
            }
            convertedList = sortList(convertedList);
           // logMessage('Convert and Sorted List: ' + convertedList);
    
            // Convert String List to SelectOption list
            for(String strOpt: convertedList)
            {
                returnList.add(new SelectOption(strOpt,strOpt)); 
            }
            //logMessage('Returning: ' + returnList);
        }
        catch(Exception exp)
        {
            returnList = new List<SelectOption>();
           // logMessage('Error in Sort(List<SelectOption>) : ' + exp.getMessage());
        }
        return returnList;
    } //Sort
    //-----CPL------------------------------------------------------------------------ 
}