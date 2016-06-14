public without sharing class blogic_Opportunity{

    public static void createShadowOpportunityProducts(List <OpportunityLineItem> opptyProducts) {
        
        // declare local vars
        Set <String> distinctPricebookEntryIds = new Set <String>();
        List <Opportunity_Product__c> shadowOpptyProductsToCreate = new List <Opportunity_Product__c>();
        Map <Id, PricebookEntry> pbeById = null;
        
        // collect the distinct pricebook entry ids
        for (OpportunityLineItem oli : opptyProducts) {
            distinctPricebookEntryIds.add(oli.PricebookEntryId);
        }
        
        // get pricebook entry info
        pbeById = new Map <Id, PricebookEntry>([select id, Name, Product2Id from PricebookEntry where Id in :distinctPricebookEntryIds]);
        
        // iterate over the new oppty products and create corresponding entries
        for (Integer x = 0; x < opptyProducts.size(); x++) {
            // get a handle on the oppty prod
            OpportunityLineItem oli = opptyProducts[x];
            
            // populate all referential fields on a new opportunity pproduct            
            Opportunity_Product__c tempOli = new Opportunity_Product__c(
                                                name = pbeById.get(oli.PricebookEntryId).Name,
                                                opportunity__c = oli.OpportunityId,
                                                product2__c = pbeById.get(oli.PricebookEntryId).Product2Id,
                                                currencyisocode = oli.CurrencyIsoCode
                                            );
                                            
            // add the new shadow record to the collection to be created 
            shadowOpptyProductsToCreate.add(tempOli);
        }
        
        // insert the shadow products
        insert shadowOpptyProductsToCreate;
        
        // populate the ids on the inbound oppty products
        for (Integer x = 0; x < opptyProducts.size(); x++) {
            opptyProducts[x].Opportunity_Product__c = shadowOpptyProductsToCreate[x].Id;
        }
    }
    
    public static void updateShadowOpportunityProducts(List <OpportunityLineItem> opptyProducts) {
        
        // declare local vars
        Map <String, Schema.SObjectField> opportunityLineItemFields = null;
        Map <String, Schema.SObjectField> opportunityProductFields = null;
        Map <String, String> opptyProd2OliFieldsToUpdate = null;
        Set <String> opptyLineItemIds = new Set <String>();
        List <SObject> opptyLineItemsAsSObjects = null;
        List <SObject> opptyProductsAsSObjectsToUpdate = new List <SObject>();
        
        // need to perform a describe on opportuity line item
        opportunityLineItemFields = Schema.SObjectType.OpportunityLineItem.fields.getMap();
        opportunityProductFields = Schema.SObjectType.Opportunity_Product__c.fields.getMap();
        opptyProd2OliFieldsToUpdate = new Map <String, String>();
        
        // iterate over the opportunity line item fields and determine the overlap fields
        for (String oliFieldName : opportunityLineItemFields.keySet()) {
            String fieldName = oliFieldName.endsWith('__c') ? oliFieldName : oliFieldName + '__c'; 
            
            if (opportunityProductFields.keySet().contains(fieldName)) {
                opptyProd2OliFieldsToUpdate.put(fieldName, oliFieldName);
            }
        }
        
        // collect the distinct set of inbound opportunity line items ids
        for (OpportunityLineItem oli : opptyProducts) {
            opptyLineItemIds.add(oli.Id);
        }
        
        // re-query the records leveraging dynamic SOQL so that we can utilize dynamic apex
        opptyLineItemsAsSObjects = Database.query('select opportunity_product__c, id, ' + util_globalUtilityMethods.joinStringSet(opptyProd2OliFieldsToUpdate.values(), false) + ' from OpportunityLineItem Where Id IN :opptyLineItemIds');

        // iterate over the retrieved records
        for (Integer x = 0; x < opptyProducts.size(); x++) {
            // get handles on items
            OpportunityLineItem oli = opptyProducts[x];
            SObject oliAsSObject = opptyLineItemsAsSObjects[x];
            
            // get a handle on the sobject equivalent so we can leverage dynamic apex
            SObject opptyProductAsSObject = new Opportunity_Product__c().getSObjectType().newSObject(oli.Opportunity_Product__c);
            
            //Copy the currency from the OpportunityLineItem for Case 10695. Chintan Adhyapak, April 17, 2012
            opptyProductAsSObject.put('CurrencyIsoCode', oli.CurrencyIsoCode);
            System.debug('Copying CurrencyIsoCode from oli as: ' + oli.CurrencyIsoCode);
            
            // iterate over the collected fields and update the record as necessary 
            for (String opptyProductFieldName : opptyProd2OliFieldsToUpdate.keySet()) {
                System.debug('processing oppty product field: ' + opptyProductFieldName);
                System.debug('processing oppty line item field: ' + opptyProd2OliFieldsToUpdate.get(opptyProductFieldName));
                System.debug('oppty line item value: ' + oliAsSObject.get(opptyProd2OliFieldsToUpdate.get(opptyProductFieldName)));
                
                if (oliAsSObject.get(opptyProd2OliFieldsToUpdate.get(opptyProductFieldName)) != null) {
                    opptyProductAsSObject.put(opptyProductFieldName, oliAsSObject.get(opptyProd2OliFieldsToUpdate.get(opptyProductFieldName))); 
                } else {
                    opptyProductAsSObject.put(opptyProductFieldName, null);
                }
            }
            
            // add the populated record into the collection to be updated
            opptyProductsAsSObjectsToUpdate.add(opptyProductAsSObject);
        }
        
        // update the opportunity products
        update opptyProductsAsSObjectsToUpdate;     
    }
    
    
    
    public static void deleteShadowOpportunityProducts(List <OpportunityLineItem> opptyProducts) {
        
        // declare local vars
        List <Opportunity_Product__c> opptyProdsToDelete = new List <Opportunity_Product__c>();
        
        for (OpportunityLineItem oli : opptyProducts) {
            if (oli.Opportunity_Product__c != null) {
                opptyProdsToDelete.add(new Opportunity_Product__c(id = oli.opportunity_product__c));
            }
        }
        
        delete opptyProdsToDelete;
    }
    
    public static void createSalesTeamCreditXrefEntries(List <OpportunityLineItem> opptyProducts) {
        
        // declare local vars
        Set <String> distinctOpptyIds = new Set <String>();
        Map <Id, Opportunity> opptys = null;
        List <OpportunityProduct_SalesTeamCredit__c> recordsToCreate = new List <OpportunityProduct_SalesTeamCredit__c>();
        
        // collect distinct opportunity ids
        for (OpportunityLineItem oli : opptyProducts) {
            distinctOpptyIds.add(oli.OpportunityId);
        }
        
        // retrieve sales team credits that are associated to the opportunity ids
        opptys = new Map <Id, Opportunity>([select id, (Select Id From Sales_Credits__r) from Opportunity where Id IN :distinctOpptyIds]);
        
        // iterate over the ids and create records as necessary
        for (OpportunityLineItem oli : opptyProducts) {
            // get a handle on the opportunity
            Opportunity oppty = opptys.get(oli.OpportunityId);
            
            // create junction records as necessary 
            if (!oppty.Sales_Credits__r.IsEmpty()) {
                if (recordsToCreate.size() + oppty.Sales_Credits__r.size() > 200) {
                    insert recordsToCreate;
                    recordsToCreate = new List <OpportunityProduct_SalesTeamCredit__c>();
                }
                for (Sales_Credit__c stc : oppty.Sales_Credits__r) {
                    recordsToCreate.add(new OpportunityProduct_SalesTeamCredit__c(Opportunity__c = oppty.Id, Opportunity_Product__c = oli.opportunity_product__c,   SalesTeamCreditID__c = stc.Id));
                }
            }
        }
        insert recordsToCreate;
    }
    
    public static void createSalesTeamCreditXrefEntries(List <Sales_Credit__c> salesCredits) {
        
        // declare local vars
        Set <String> distinctOpptyIds = new Set <String>();
        Map <Id, Opportunity> opptys = null;
        List <OpportunityProduct_SalesTeamCredit__c> recordsToCreate = new List <OpportunityProduct_SalesTeamCredit__c>();
        
        // collect distinct opportunity ids
        for (Sales_Credit__c stc : salesCredits) {
            distinctOpptyIds.add(stc.Related_Opportunity__c);
        }
        
        // retrieve sales team credits that are associated to the opportunity ids
        opptys = new Map <Id, Opportunity>([select id, (Select Id, Opportunity_Product__c From OpportunityLineItems) from Opportunity where Id IN :distinctOpptyIds]);
        
        // iterate over the ids and create records as necessary
        for (Sales_Credit__c stc : salesCredits) {
            // get a handle on the opportunity
            Opportunity oppty = opptys.get(stc.Related_Opportunity__c);
            
            // create junction records as necessary 
            if (!oppty.OpportunityLineItems.IsEmpty()) {
                if (recordsToCreate.size() + oppty.OpportunityLineItems.size() > 200) {
                    insert recordsToCreate;
                    recordsToCreate = new List <OpportunityProduct_SalesTeamCredit__c>();
                }
                for (OpportunityLineItem oli : oppty.OpportunityLineItems) {
                    recordsToCreate.add(new OpportunityProduct_SalesTeamCredit__c(Opportunity__c = oppty.Id, Opportunity_Product__c = oli.opportunity_product__c,   SalesTeamCreditID__c = stc.Id));
                }
            }
        }
        insert recordsToCreate;
    }
    
    /** This method creates Sales Team records for Sales Credit recepients */
    public static void createSalesTeamMember(List <Sales_Credit__c> newCredits) {
        // declare local vars
        Set <String> contactIds = new Set <String>();
        Map <Id, Contact> contactInfo = null;
        List <OpportunityTeamMember> recordsToCreate = new List <OpportunityTeamMember>();
        List<Id> oppIds = new List<Id> ();
        
        // collect the distinct contacts that were added for a credit
        for (Sales_Credit__c stc : newCredits) {
            contactIds.add(stc.Credit_Recipient__c);
        }
        
        // query contact info
        contactInfo = new Map <Id, Contact>([select id, Corresponding_User_Id__c, Corresponding_User_Id__r.IsActive from Contact where id IN :contactIds]);
        
        for (Sales_Credit__c stc : newCredits) {
            System.debug(contactInfo.get(stc.Credit_Recipient__c));
            if ((contactInfo.get(stc.Credit_Recipient__c).Corresponding_User_Id__c != null) && (contactInfo.get(stc.Credit_Recipient__c).Corresponding_User_Id__r.IsActive)) {
                OpportunityTeamMember otm = new OpportunityTeamMember();
                otm.UserId = contactInfo.get(stc.Credit_Recipient__c).Corresponding_User_Id__c;
                
                otm.OpportunityId = stc.related_opportunity__c;
                otm.TeamMemberRole = 'Sales Credit Recipient';
                recordsToCreate.add(otm);
                oppIds.add(stc.Related_Opportunity__c);
            }
        }
        
        // insert any collected team members
        if (!recordsToCreate.IsEmpty()) {
            insert recordsToCreate;
            
            //Now pull the OpportunityShare records to give them edit access. Chintan Adhyapak, Case 154407. April 01, 2015
            List<OpportunityShare> shares = [select Id, OpportunityAccessLevel, RowCause from OpportunityShare where OpportunityId IN :oppIds and RowCause = 'Team'];
            
            // set all team members access to read/write
			for (OpportunityShare share : shares) { 
				share.OpportunityAccessLevel = 'Edit';
			}
			update shares;
        }
    } //createSalesTeamMember
    
    
    /** This method deletes Sales Team records when sales credit recepients are deleted */
    public static void deleteSalesTeamMember(List <Sales_Credit__c> oldCredits) {
        // declare local vars
        Set <String> contactIds = new Set <String>();
        Set <String> opptyIds = new Set <String>();
        Map <Id, Contact> contactInfo = null;
        Set <String> userIds = new Set <String>();
        Map <Id, Set <String>> userIdsByOpptyId = new Map <Id, Set <String>>();
        List <OpportunityTeamMember> potentialTeamMembersToDelete = null;
        List <OpportunityTeamMember> recordsToDelete = new List <OpportunityTeamMember>();
        
        // collect the distinct contacts that were added for a credit
        for (Sales_Credit__c stc : oldCredits) {
            contactIds.add(stc.Credit_Recipient__c);
            opptyIds.add(stc.Related_Opportunity__c);
        }
        
        // query contact info
        contactInfo = new Map <Id, Contact> ([select id, Corresponding_User_Id__c from Contact where id IN :contactIds]);
        
        // distill the list down to potential user ids
        for (Id contactId : contactInfo.keySet()) {
            if (contactInfo.get(contactId).Corresponding_User_Id__c != null) {
                userIds.add(contactInfo.get(contactId).Corresponding_User_Id__c);
            }
        }
        
        // populate a data structure to allow us to do comparisons to identify deletes
        for (Sales_Credit__c stc : oldCredits) {
            Set <String> collectedUserIds = null;
            
            if (contactInfo.get(stc.Credit_Recipient__c).Corresponding_User_Id__c != null) {
                if (!userIdsByOpptyId.containsKey(stc.Related_Opportunity__c)) {
                    collectedUserIds = new Set<String>();
                } else {
                    collectedUserIds = userIdsByOpptyId.get(stc.Related_Opportunity__c); 
                }
                collectedUserIds.add(contactInfo.get(stc.Credit_Recipient__c).Corresponding_User_Id__c);
                userIdsByOpptyId.put(stc.Related_Opportunity__c, collectedUserIds);
            }
        }
        
        // query for potential matches
        potentialTeamMembersToDelete = [select id, UserId, TeamMemberRole, OpportunityId From OpportunityTeamMember 
            Where TeamMemberRole = 'Sales Credit Recipient' and UserId IN :userIds and OpportunityId IN :opptyIds];

        // iterate over the results, deleting any matches that are located
        for (OpportunityTeamMember teamMember : potentialTeamMembersToDelete) {
            // get a handle on the users already ties to the oppty
            Set <String> usersAlreadyOnOppty = userIdsByOpptyId.get(teamMember.OpportunityId);
            
            if (usersAlreadyOnOppty.contains(teamMember.UserId)) {
                recordsToDelete.add(teamMember);                
            } 
        }
        
        // delete any collected records
        delete recordsToDelete;
    } //deleteSalesTeamMember
    
    
    public static void markActiveDateStamp(List <User> newUsers, List <User> oldUsers) {
    	for (Integer x = 0; x < newUsers.size(); x++) { 
            // get handles on the records
            User newUser = newUsers[x];
            User oldUser = oldUsers == null ? new User() : oldUsers[x];
            
            // check to see if the user becamse active
            if ((newUser.IsActive) && (!oldUser.IsActive)) {
                newUser.Activation_Date__c = datetime.now();
            }
            // check to see if the user became inactive
            if ((!newUser.IsActive) && (oldUser.IsActive)) {
                newUser.Activation_Date__c = null;
            }
        }
    }
    
    public static void deleteXrefEntries(List <Opportunity_Product__c> opptyProducts) {
        
        system.debug('******************* Starting deleteXrefEntries ');
        
        // declare local vars
        Set <Id> opptyIds = new Set <Id>();
        
        system.debug('received ' + opptyProducts.size() + ' opportunity products that were deleted: ' + opptyProducts);

        for (Opportunity_Product__c opptyProduct : opptyProducts) {
            opptyIds.add(opptyProduct.Opportunity__c);
        }
        
        List <OpportunityProduct_SalesTeamCredit__c> opptyProdsSalesTeamCreditToDelete = 
            [select id from OpportunityProduct_SalesTeamCredit__c where Opportunity_Product__c = null and Opportunity__c IN :opptyIds]; 
        system.debug('******************* opptyProdsSalesTeamCreditToDelete,size:  '+ opptyProdsSalesTeamCreditToDelete.size());
        
        delete opptyProdsSalesTeamCreditToDelete;
        system.debug('******************* End deleteXrefEntries ');
    }
    
    public static void deleteXrefEntries(List<Sales_Credit__c> salesTeamCredits) {
        
        system.debug('******************* Starting deleteXrefEntries ');
        
        // declare local vars
        Set <Id> salesTeamCreditIds = new Set <Id>();
        
        for (Sales_Credit__c salesCredit : salesTeamCredits) {
            salesTeamCreditIds.add(salesCredit.Id);
        }
        
        List <OpportunityProduct_SalesTeamCredit__c> xRefEntriesToDelete = 
            [select id from OpportunityProduct_SalesTeamCredit__c where SalesTeamCreditID__c in :salesTeamCreditIds];   
        system.debug('******************* xRefEntriesToDelete,size:  '+ xRefEntriesToDelete.size());
        
        Delete xRefEntriesToDelete;
        system.debug('******************* End deleteXrefEntries ');
     }

    
     public static void verifyDeleteAuthority(Opportunity[] opportunityList) 
     {
        //00004316-Ritu Sharma-User Profile and Opp stage will drive the deletion access
        OpportunityDeletionSettings__c oppDelAccess = OpportunityDeletionSettings__c.getInstance(userinfo.getProfileId());
        Boolean canDelete;
        
        for(Opportunity opp : opportunityList)
        {
            canDelete = False;
            if(opp.StageName == 'Closed Lost')
                canDelete = oppDelAccess.Closed_Lost__c;
            else if (opp.StageName == 'Closed Won')
                canDelete = oppDelAccess.Closed_Won__c;
            else if (opp.StageName == 'Non-Qualified Opportunity')   
                canDelete = oppDelAccess.Non_Qualified_Opportunity__c;
            else if (opp.StageName == 'Propose Solution')
                canDelete = oppDelAccess.Propose_Solution__c;
            else if (opp.StageName == 'Qualify Opportunity')
                canDelete = oppDelAccess.Qualify_Opportunity__c;
            else if (opp.StageName == 'Negotiate')
                canDelete = oppDelAccess.Negotiate__c;
            else if (opp.StageName == 'Closed Approved')
                canDelete = oppDelAccess.Closed_Approved__c;

            System.debug('verifyDeleteAuthority -> Stage- '+opp.StageName+'- CanDelete '+canDelete);
            if (!(canDelete)) //User's profile is not allowed to delete this opp
                opp.AddError(Label.Opportunity_Deletion_Error);            
        }     
    } //verifyDeleteAuthority
     
     
     /** This method is called to ensure that the Lead Consultant checkbox on the sales 
       * credit entries annot be checked more than once for the same Opportunity. Chintan Adhyapak */       
    public static void verifyUniqueLeadConsultant(List <Sales_Credit__c> salesTeamCredits) {
        //local vars
        Set<Id> distinctOppIds = new Set<Id> ();
        Set<Id> oppIdsWithLeadConsultant = new Set<Id> ();
        List<id> stcIds = new List<Id>();
        
        //collect distinct incoming Opp Ids and Sales Credit Ids
        for (Sales_Credit__c stc : salesTeamCredits) {
            distinctOppIds.add(stc.Related_Opportunity__c);
            stcIds.add(stc.Id);
        }
        
        //From this incoming Opp Ids identify the ones that already contain a Lead Consultant
        List<Sales_Credit__c> salesCreditsWithLeadConsultants = [select Id, Related_Opportunity__c from Sales_Credit__c where Lead_Consultant__c = true and Related_Opportunity__c in :distinctOppIds and Id not in :stcIds];
        
        //Save it in a Set
        for (Sales_Credit__c stc : salesCreditsWithLeadConsultants) {
            oppIdsWithLeadConsultant.add(stc.Related_Opportunity__c);
        }
        
        //Verify
        for (Sales_Credit__c mySalesCredit : salesTeamCredits) {
            if (mySalesCredit.Lead_Consultant__c && oppIdsWithLeadConsultant.contains(mySalesCredit.Related_Opportunity__c)) {
                mySalesCredit.addError('Only one Lead Consultant per Opportunity is allowed.');
            }
        }
    } //verifyUniqueLeadConsultant
    
    
    /** Method that stamps the Opportunity Closed Date according to Case 5717
     * Chintan Adhyapak, December 19, 2011 */ 
     public static void stampOpportunityClosedDate(Opportunity[] opportunityListOld, Opportunity[] opportunityListNew) {
        if (Trigger.isUpdate) {
            //Local vars
            boolean oldOppIsClosed = false;
            boolean newOppIsClosed = false;
        
            //Pull a list of Opps whose stage changed to Closed Won or Closed Lost
            System.debug('CHINTAN Looking for opps that have been closed or reopened ...');
            for (integer x = 0; x < opportunityListNew.size(); x++) {
                //Get handles on the new and old opps
                Opportunity oldOpp = opportunityListOld[x];
                Opportunity newOpp = opportunityListNew[x];
            
                If (oldOpp.StageName == 'Closed Won' || oldOpp.StageName == 'Closed Lost' || oldOpp.StageName == 'Closed Approved') {
                    oldOppIsClosed = true;
                }
                If (newOpp.StageName == 'Closed Won' || newOpp.StageName == 'Closed Lost' || newOpp.StageName == 'Closed Approved') {
                    newOppIsClosed = true;
                }
                System.debug('CHINTAN Old Opp Stage: ' + oldOpp.StageName + '; Is Closed: ' + (oldOppIsClosed ? 'TRUE' : 'FALSE'));
                System.debug('CHINTAN New Opp Stage: ' + newOpp.StageName + '; Is Closed: ' + (newOppIsClosed ? 'TRUE' : 'FALSE'));
            
                //Determine if Opp was closed or reopened
                if (newOppIsClosed && !oldOppIsClosed) {
                    System.debug('CHINTAN Located an opp that has closed');
                    newOpp.Opportunity_Closed_Date__c = Date.today();
                } else if (oldOpp.StageName == 'Closed Lost' && newOpp.StageName == 'Closed Won') {
                    System.debug('CHINTAN Located an opp that has moved from Closed Lost to Closed Won');
                    newOpp.Opportunity_Closed_Date__c = Date.today();
                } else if (oldOpp.StageName == 'Closed Won' && newOpp.StageName == 'Closed Lost') {
                    System.debug('CHINTAN Located an opp that has moved from Closed Won to Closed Lost');
                    newOpp.Opportunity_Closed_Date__c = Date.today();
                } else if (!newOppIsClosed && oldOppIsClosed) {
                    System.debug('CHINTAN Located an opp that was reopened');
                    newOpp.Opportunity_Closed_Date__c = null;
                }
            }
        } else if (Trigger.isInsert) {
            for (Opportunity myOpp : opportunityListNew) {
                if (myOpp.StageName == 'Closed Won' || myOpp.StageName == 'Closed Lost' || myOpp.StageName == 'Closed Approved') {
                    myOpp.Opportunity_Closed_Date__c = Date.today();
                }
            }
        }
    } //stampOpportunityClosedDate
    
    
    
    /*00018625-Ritu Sharma-This function will populate the value of SalesTeamCredits field on Opportunity         
    Revamped the code. Refer case no. 00006749 for details around initial requirements.*/   
    public static void updateSalesTeamCreditsOnOpportunity(List<Sales_Credit__c> newRecords, List<Sales_Credit__c> oldRecords) {
        //Variables Declaration
        List <String> parentIdsList = new List<String>();
        Opportunity opp = null;
        integer totalRecords  = (newRecords == null) ? oldRecords.size() : newRecords.size();
        
        //Looping through all records
        for(integer i=0; i<totalRecords; i++) {
            if (trigger.isUpdate && (newRecords[i].Credit_Recipient__c != oldRecords[i].Credit_Recipient__c)) { 
                parentIdsList.add(newRecords[i].Related_Opportunity__c);
            } else if(trigger.isDelete) { 
                parentIdsList.add(oldRecords[i].Related_Opportunity__c);
            } else {
                parentIdsList.add(newRecords[i].Related_Opportunity__c);
            }
        }
        
        //Anything to ptocess
        if (parentIdsList.size()>0) {
            Map <Id, Opportunity>oppsMap = new Map <ID,Opportunity>([Select ID,SalesTeamCredits__c from Opportunity where ID in :parentIdsList]);
        
            //Pull all sales credit records for these opps
            List<Sales_Credit__c> allSalesCreditsList = [Select ID,Related_Opportunity__c,Credit_Recipient__r.Name from Sales_Credit__c where Related_Opportunity__c in :parentIdsList];
        
            //Wipe out the current value on opps
            for(integer i=0; i<parentIdsList.size(); i++) {
                oppsMap.get(parentIdsList[i]).SalesTeamCredits__c = '';
            }
        
            //Loop through all sales credit records
            for(integer i=0; i<allSalesCreditsList.size(); i++) {            
                opp = oppsMap.get(allSalesCreditsList[i].Related_Opportunity__c);
                if (opp.SalesTeamCredits__c == '' || opp.SalesTeamCredits__c == null)
                    opp.SalesTeamCredits__c = allSalesCreditsList[i].Credit_Recipient__r.Name;
                else
                    opp.SalesTeamCredits__c += ',' + allSalesCreditsList[i].Credit_Recipient__r.Name;
                System.debug('opp.SalesTeamCredits__c '+ opp.SalesTeamCredits__c);
            }
        
            //update
            update oppsMap.values();                     
        }
    } //UpdateSalesTeamCreditsOnOpportunity
    
    
    /** Sets the Chosen Provider to be 'Aon Hewitt' when Opportunity stage is Closed Won
      * Chintan. 02/22/2012. Case 7971
      */
    public static void updateChosenProvider (List<Opportunity> newOpps, List<Opportunity> oldOpps) {  
        Competitor__c aonHewitt = [select Id from Competitor__c where  Name = 'Aon Hewitt' limit 1];
        Competitor__c other = [select Id from Competitor__c where Name = 'Other' limit 1];      
        
        if ((aonHewitt != null) && (trigger.isInsert)) {
            for (Opportunity myOpportunity : newOpps) {
                if (myOpportunity.StageName == 'Closed Won') {
                    myOpportunity.Chosen_Provider_Reference__c = aonHewitt.Id;
                }
            }
        } else if (trigger.isUpdate) {
            //Spin through and process
            for (integer i=0; i<newOpps.size(); i++) {
                Opportunity oldOpportunity = oldOpps[i];
                Opportunity newOpportunity = newOpps[i];
                if ((oldOpportunity.StageName != 'Closed Won') && (newOpportunity.StageName == 'Closed Won') && (aonHewitt != null)) {
                    System.debug('CHINTAN Setting Chosen Provider for Non Closed to Closed');
                    newOpportunity.Chosen_Provider_Reference__c = aonHewitt.Id;
                } else if ((oldOpportunity.StageName == 'Closed Won') && (newOpportunity.StageName != 'Closed Won') 
                        && (newOpportunity.StageName != 'Closed Approved') && (newOpportunity.StageName != 'Closed Lost')) {
                    System.debug('CHINTAN Wiping Out Chosen Provider for Closed to Non-Closed');
                    newOpportunity.Chosen_Provider_Reference__c = null;
                } else if ((oldOpportunity.StageName == 'Closed Won') && (newOpportunity.StageName == 'Closed Lost') && (other != null)) {
                    System.debug('CHINTAN Setting Chosen Provider for Non Closed to Closed');
                    newOpportunity.Chosen_Provider_Reference__c = other.Id;
                }
            }
        }
    } //updateChosenProvider
    
    
    // A method to support the trigger "OpportunityLineItem_UPDATE_BEFORE" 
    // This is to update the custom field "Invalid_Revenue_Schedule__c" on "OpportunityLineItem", which will be
    // evaluated on opportunity page load to check whether the Revenue Schedule data needs to be updated
    // Developed by : Amrita on 02/17/12
    public static void UpdateRevenueScheduleStatus(Map <Id, OpportunityLineItem> oldOpportunityLineItem, Map <Id, OpportunityLineItem> newOpportunityLineItem) {
        try {
            /*
            // Get all opp Line Item Schdule in the new map 
            List<ID> lstOppLiIDs = new List<ID>();
            for (OpportunityLineItem oppLi : newOpportunityLineItem.values()) {
                lstOppLiIDs.Add(oppLi.ID);
            }

            // A map with Line Item ID and Its schedules
            Map<ID, List<OpportunityLineItemSchedule>> mapLiSchd = new Map<ID, List<OpportunityLineItemSchedule>>();

            // Get all opp line item Schedules in the map
            List<OpportunityLineItemSchedule> lstOppLineItemSchd = [SELECT id, OPPORTUNITYLINEITEMID FROM OpportunityLineItemSchedule WHERE OPPORTUNITYLINEITEMID IN : lstOppLiIDs];

            List<OpportunityLineItemSchedule> temp;
            if(lstOppLineItemSchd!=null & lstOppLineItemSchd.Size()>0) {
                for(OpportunityLineItemSchedule oppLi : lstOppLineItemSchd) {
                    temp = mapLiSchd.get(oppLi.OPPORTUNITYLINEITEMID);
                    if(temp == null) {
                        temp = new List<OpportunityLineItemSchedule>();
                        mapLiSchd.put(oppLi.OPPORTUNITYLINEITEMID, temp);
                    }
                    temp.Add(oppLi);
                }
            }
                        

            for (OpportunityLineItem oppLi : newOpportunityLineItem.values()) {
                // If Opportunity Amount changed,                 
                // Delete its Line Item Schedules and allow users to redirect to Revenue Schedule page to reschedule
                // make flag â€œInvalid Revenue Scheduleâ€ = TRUE
                if(oppLi.TotalPrice != (oldOpportunityLineItem.get(oppLi.Id)).TotalPrice) {
                    //oppLi.Invalid_Revenue_Schedule__c = True;
                    // Delte the Line Item Schedules records
                    List<OpportunityLineItemSchedule> lstSchd = mapLiSchd.get(oppLi.ID);
                    Delete lstSchd;
                    //update oppLi;
                }
                // If Revenue Schedule updated, so flag â€œInvalid Revenue Scheduleâ€ = FALSE
                if(oppLi.HasRevenueSchedule != (oldOpportunityLineItem.get(oppLi.Id)).HasRevenueSchedule) {
                    oppLi.Invalid_Revenue_Schedule__c = False;
                    update oppLi;
                }
            }
            */
        }
        catch(Exception exp) {
            System.Debug(exp.getMessage());
        }
    } //UpdateRevenueScheduleStatus      
    
    //Ritu Sharma - Case # 00010036 - This function will update status of marketing lead to Qualified (Converted) if opportunity has been created from marketing lead page
    public static void updateMarketingLeadStatus(List<Opportunity> newOpps) {
        List<String> marketingLeadIDs = new List <String>(); //ID of marketing lead records from which opps have been created
        List<Marketing_Lead__c> marketingLeads = new List <Marketing_Lead__c>(); //List of marketing leads that will need to be updated
        Integer i=0;
        String leadID='';
        
        for (i=0;i<newOpps.size();i++)   
        {
            leadID=newOpps[i].Marketing_Lead_ID__c;
            System.debug('Marketing Lead ID 1 - '+leadID);           
            if(leadID!=Null) //Opp has been created through marketing record
            {
                System.debug('Opp ID - '+newOpps[i].ID);                
                marketingLeadIDs .add(leadID);
            }
        }
        System.debug('marketingLeadIDs .size -'+marketingLeadIDs .size());
        
        marketingLeads = [select id from Marketing_Lead__c where ID IN:marketingLeadIDs ]; //Searching for all marketing leads that need to be updated
        System.debug('marketingLeads.size -'+marketingLeads.size());
        for (i=0;i<marketingLeads.size();i++)   
        {
            marketingLeads[i].Status__c='Qualified (Converted)';
        }
        Update marketingLeads; //Bulk update of leads
    } //updateMarketingLeadStatus
    
    
    /** Creates a Survey object for an opportunity if it meets certain criteria. Case 13356.
      * Chintan Adhyapak, October 11, 2012
      */
/*      
    public static void createSurvey(List<Opportunity> opps) {
        //local vars
        List<Id> oppIds = new List<Id> ();
        Id recordTypeId = null;
        List<Sales_Debrief_Survey__c> surveysToAdd = new List<Sales_Debrief_Survey__c> ();
        
        //Spin through and collect opp Ids
        for (Opportunity myOpp : opps) {
            oppIds.add(myOpp.Id);
        }
        
        //Read data that is needed to evaluate criteria and create survey
        List<Opportunity> oppList = [Select Id, StageName, Consulting_Products_Associated__c, Outsourcing_Products_Associated__c, Total_First_Year_Value__c,  Lead_Opportunity__c, Last_Non_Closed_Stage__c, AccountId,
            OwnerId, Opportunity.Current_Provider_Reference__c, Sourcing_Provider__c, Chosen_Provider_Reference__c, Account.SDO_Billing_Country_Name__c, (Select Id, Practice__c, Type__c from OpportunityLineItems) from Opportunity Where Id in :oppIds];
        
        //Evaluate and create survey records
        for (Opportunity myOpp : oppList) {
            OpportunityLineItem myService = myOpp.OpportunityLineItems[0];
            if ((myOpp.StageName == 'Closed Won') && (myOpp.Consulting_Products_Associated__c > 0) && (myOpp.Account.SDO_Billing_Country_Name__c == 'United States')) {
                System.debug('CHINTAN Adding Sales Debrief Survey for Closed Won Consulting');
                surveysToAdd.add(getSurvey(myOpp, (recordTypeId == null) ?  util_sampleDataGenerator.getRecordType('Sales_Debrief_Survey__c', 'US Sales Debrief Survey 2012').Id : recordTypeId));
            } else if ((myOpp.StageName == 'Closed Lost') && (myOpp.Consulting_Products_Associated__c > 0) && (myOpp.Total_First_Year_Value__c >= 100000) && 
                    (myOpp.Last_Non_Closed_Stage__c != 'Qualify Opportunity') && (myOpp.Last_Non_Closed_Stage__c != 'Non-Qualified Opportunity') && (myOpp.Account.SDO_Billing_Country_Name__c == 'United States')) {
                System.debug('CHINTAN Adding Sales Debrief Survey for Closed Lost Consulting');
                surveysToAdd.add(getSurvey(myOpp, (recordTypeId == null) ?  util_sampleDataGenerator.getRecordType('Sales_Debrief_Survey__c', 'US Sales Debrief Survey 2012').Id : recordTypeId));
            } else if ((myOpp.StageName == 'Closed Won') && (myOpp.Outsourcing_Products_Associated__c > 0) && (myOpp.Account.SDO_Billing_Country_Name__c == 'United States') && (myOpp.Lead_Opportunity__c) && 
                    (myService.Practice__c != 'Outsourcing - Point Solutions')) {
                System.debug('CHINTAN Adding Sales Debrief Survey for Closed Won Outsourcing Non Point Solutions');
                surveysToAdd.add(getSurvey(myOpp, (recordTypeId == null) ?  util_sampleDataGenerator.getRecordType('Sales_Debrief_Survey__c', 'US Sales Debrief Survey 2012').Id : recordTypeId));
            } else if ((myOpp.StageName == 'Closed Lost') && (myOpp.Outsourcing_Products_Associated__c > 0) && (myOpp.Total_First_Year_Value__c >= 100000) && 
                    (myOpp.Last_Non_Closed_Stage__c != 'Qualify Opportunity') && (myOpp.Last_Non_Closed_Stage__c != 'Non-Qualified Opportunity') && (myOpp.Account.SDO_Billing_Country_Name__c == 'United States') &&
                    (myOpp.Lead_Opportunity__c) && (myService.Practice__c != 'Outsourcing - Point Solutions')) {
                System.debug('CHINTAN Adding Sales Debrief Survey for Closed Lost Outsourcing Non Point Solutions');
                surveysToAdd.add(getSurvey(myOpp, (recordTypeId == null) ?  util_sampleDataGenerator.getRecordType('Sales_Debrief_Survey__c', 'US Sales Debrief Survey 2012').Id : recordTypeId));
            } else if ((myOpp.StageName == 'Closed Won') && (myOpp.Outsourcing_Products_Associated__c > 0) && (myOpp.Account.SDO_Billing_Country_Name__c == 'United States') && (myOpp.Lead_Opportunity__c) && 
                    (myService.Practice__c == 'Outsourcing - Point Solutions') && (myService.Type__c != 'Renewal - C')) {
                System.debug('CHINTAN Adding Sales Debrief Survey for Closed Won Outsourcing Point Solutions');
                surveysToAdd.add(getSurvey(myOpp, (recordTypeId == null) ?  util_sampleDataGenerator.getRecordType('Sales_Debrief_Survey__c', 'US Sales Debrief Survey 2012').Id : recordTypeId));
            } else if ((myOpp.StageName == 'Closed Lost') && (myOpp.Outsourcing_Products_Associated__c > 0) && (myOpp.Total_First_Year_Value__c >= 100000) && 
                    (myOpp.Last_Non_Closed_Stage__c != 'Qualify Opportunity') && (myOpp.Last_Non_Closed_Stage__c != 'Non-Qualified Opportunity') && (myOpp.Account.SDO_Billing_Country_Name__c == 'United States') &&
                    (myOpp.Lead_Opportunity__c) && (myService.Practice__c == 'Outsourcing - Point Solutions') && (myService.Type__c != 'Renewal - C')) {
                System.debug('CHINTAN Adding Sales Debrief Survey for Closed Lost Outsourcing Point Solutions');
                surveysToAdd.add(getSurvey(myOpp, (recordTypeId == null) ?  util_sampleDataGenerator.getRecordType('Sales_Debrief_Survey__c', 'US Sales Debrief Survey 2012').Id : recordTypeId));
            }
        }
        
        //Create Surveys
        if (!surveysToAdd.isEmpty()) {
            System.debug('CHINTAN Number of Survey records to insert is: ' + surveysToAdd.size());
            try {
                insert surveysToAdd;
            } catch (Exception e) {
                System.debug('CHINTAN ERROR inserting sales debrief surveys. Error Message: ' + e.getMessage());
            }
        }
        
    } //createSurvey
 */   
    
     /** private utility function */
/*    
    private static Sales_Debrief_Survey__c getSurvey(Opportunity myOpp, Id recordTypeId) {
        Sales_Debrief_Survey__c mySurvey = new Sales_Debrief_Survey__c();
        mySurvey.Opportunity_ID__c = myOpp.Id;
        mySurvey.Account__c = myOpp.AccountId;
        mySurvey.Opportunity_Owner__c = myOpp.OwnerId;
        mySurvey.Outcome__c = 'Closed Won';
        mySurvey.Current_Service_Provider__c = myOpp.Current_Provider_Reference__c;
        mySurvey.Sourcing_Advisor__c = myOpp.Sourcing_Provider__c;
        mySurvey.Chosen_Provider__c = myOpp.Chosen_Provider_Reference__c;
        mySurvey.Due_Date__c = Date.today().addDays(10);
        mySurvey.RecordTypeId = recordTypeId;
        
        return mySurvey;
    } //getSurvey
*/    
    
    /** This method stamps the User Id of the Opportunity Owner
      * on to a custom field on the Opportunity object. This will aid in reporting. 
      * Chintan Adhyapak, December 17, 2012. */
    public static void stampOwnerId(List<Opportunity> newOpps) {
        for (Opportunity myOpp : newOpps) {
            myOpp.Identified_Opportunity_Owner__c = myOpp.OwnerId;
        }
    } //stampOwnerId
    
    
    
    /** This method keeps track of first year and total service values on the lead opp
      * for all bundled services. Case 69299, September 20, 2013, Chintan */
    public static void syncBundledTotals(List<Opportunity> oldOppList, List<Opportunity> newOppList) {
        //local vars
        Set<Id> leadOppsSet = new Set<Id> ();
        List<Opportunity> leadOppList;
        
        if (trigger.isInsert) {
            for (Opportunity myOpp : newOppList) {
                System.debug('CPA Reading Opp: ' + myOpp.Name);
                if (myOpp.Lead_Opportunity_Name__c != null) {
                    leadOppsSet.add(myOpp.Lead_Opportunity_Name__c);
                }
            }
            System.debug('CPA Opp Insert Method syncBundledTotals leadOppsSet is: ' + leadOppsSet);
        } else if (trigger.isUpdate) {
            for (Integer i=0; i<newOppList.size(); i++) {
                Opportunity oldOpp = oldOppList[i];
                Opportunity newOpp = newOppList[i];
                //Bundled
                if (oldOpp.Lead_Opportunity_Name__c == null && newOpp.Lead_Opportunity_Name__c != null) { 
                    leadOppsSet.add(newOpp.Lead_Opportunity_Name__c); 
                } 
                //Unbundled
                else if (oldOpp.Lead_Opportunity_Name__c != null && newOpp.Lead_Opportunity_Name__c == null) {
                    leadOppsSet.add(oldOpp.Lead_Opportunity_Name__c);
                }
                //Change in Lead Opp
                else if (oldOpp.Lead_Opportunity_Name__c != null && newOpp.Lead_Opportunity_Name__c != null && oldOpp.Lead_Opportunity_Name__c != newOpp.Lead_Opportunity_Name__c) {
                    leadOppsSet.add(oldOpp.Lead_Opportunity_Name__c);
                    leadOppsSet.add(newOpp.Lead_Opportunity_Name__c);
                }
            }
            System.debug('CPA Opp Update Method syncBundledTotals leadOppsSet is: ' + leadOppsSet);
            System.debug('CPA Opp Update Method syncBundledTotals leadOppsSet isEmpty is: ' + leadOppsSet.isEmpty());
            
            //Finally set global flag to indicate that this processing has already been done so that this function is not called again within this transaction
            System.debug('CPA Setting runOnceFlag to true');
            util_globalUtilityMethods.setRunOnceFlag(true);
        } else if (trigger.isDelete) {
            for (Opportunity myOpp : oldOppList) {
                if (myOpp.Lead_Opportunity_Name__c != null) { 
                    leadOppsSet.add(myOpp.Lead_Opportunity_Name__c);
                }
            }
            System.debug('CPA Opp Delete Method syncBundledTotals leadOppsSet is: ' + leadOppsSet);
            System.debug('CPA Opp Delete Method syncBundledTotals leadOppsSet isEmpty is: ' + leadOppsSet.isEmpty());
        }
        
        //Now recalculate the totals on the lead Opps
        if (!leadOppsSet.isEmpty()) {
            calculateBundledTotals(leadOppsSet);
        }
    } //syncBundledTotals
    
    
    
    /** This method keeps track of first year and total service values on the lead opp
      * for all bundled services. Case 69299, October 03, 2013, Chintan */
    public static void syncBundledTotals(List<OpportunityLineItem> newOliList, List<OpportunityLineItem> oldOliList) {
        //local vars
        Set<Id> leadOppsSet = new Set<Id> ();
        List<Opportunity> leadOppList;
        List<Id> oppIdList = new List<Id> ();

        //Cycle through and collect opp IDs     
        if (trigger.isInsert || trigger.isUpdate) {
            for (OpportunityLineItem oli : newOliList) {
                oppIdList.add(oli.OpportunityId);
            } 
        } else if (trigger.isDelete) {
            for (OpportunityLineItem oli : oldOliList) {
                oppIdList.add(oli.OpportunityId);
            }
        }
        
        //Pull Opp Data
        List<Opportunity> oppList = [Select Id, Lead_Opportunity_Name__c, (Select Id from Opportunities__r) From Opportunity Where Id in :oppIdList];
            
        //Identify Lead Opps in bundles
        for (Opportunity myOpp : oppList) {
            System.debug('CPA Reading Opp: ' + myOpp.Id);
            //Service is being added to a bundled opp
            if (myOpp.Lead_Opportunity_Name__c != null) {
                leadOppsSet.add(myOpp.Lead_Opportunity_Name__c);
            } 
            //Service is being added to a lead opp that is part of a bundle
            else if (myOpp.Opportunities__r.size() > 0) {
                leadOppsSet.add(myOpp.Id);
            }
        }
        System.debug('CPA Opp Line Item Method syncBundledTotals leadOppsSet is: ' + leadOppsSet);
        
        //Now recalculate the totals on the lead Opps
        if (leadOppsSet.size() > 0) {
            calculateBundledTotals(leadOppsSet);
        }
    } //syncBundledTotals
    
    
    
    /** Private utility method to calculate bundled totals for lead opps in a bundle
      * Chintan Adhyapak, Case 69299, September 24, 2013 */
    private static void calculateBundledTotals(Set<Id> leadOppSet) {
        //local vars
        Map<Id, Decimal> oppFirstYearValueMap = new Map<Id, Decimal> ();
        Map<Id, Decimal> oppTotalValueMap = new Map<Id, Decimal> ();
        Map<Id, String> crmIdMap = new Map<Id, String> ();
        Map <Id, String> serviceMap = new Map<Id, String> ();
        Map<Id, Id> bundledOppMap = new Map<Id, Id> ();
        
        //Query Lead Opportunities for services and bundled opps
        List<Opportunity> leadOppList = [Select Id, Bundled_First_Year_Value__c, Bundled_Total_Opportunity_Value__c, All_Service_Oppty_CRM_ID__c, All_Services__c, Oportunity_Auto_Number__c,
            (Select Id, First_Year_Value__c, TotalPrice, Opportunity_Product__r.Name from OpportunityLineItems), (Select Id from Opportunities__r) 
            From Opportunity Where Id In :leadOppSet];
        
        //Cycle through and process totals for services tied to the lead Opp
        for (Opportunity myOpp : leadOppList) {
            System.debug('CHINTAN Working on Lead Opportunity Id: ' + myOpp.Id);
            
            //Store CRM ID in a map
            crmIdMap.put(myOpp.Id, myOpp.Oportunity_Auto_Number__c);
            
            //Read Services Tied to the Opp
            for (OpportunityLineItem lineItem : myOpp.OpportunityLineItems) {
                System.debug('CHINTAN Read Lead Service Totals: ' + lineItem.First_Year_Value__c + ', ' + lineItem.TotalPrice);
                oppFirstYearValueMap.put(myOpp.Id, (oppFirstYearValueMap.get(myOpp.Id) != null ? oppFirstYearValueMap.get(myOpp.Id) + lineItem.First_Year_Value__c : lineItem.First_Year_Value__c));
                oppTotalValueMap.put(myOpp.Id, (oppTotalValueMap.get(myOpp.Id) != null ? oppTotalValueMap.get(myOpp.Id) + lineItem.TotalPrice : lineItem.TotalPrice));
                serviceMap.put(myOpp.Id, serviceMap.get(myOpp.Id) != null ? serviceMap.get(myOpp.Id) + ';' + lineItem.Opportunity_Product__r.Name : lineItem.Opportunity_Product__r.Name);
            }
            
            //Get Bundled Opps tied to this opp and store in a map
            for (Opportunity bundledOpp : myOpp.Opportunities__r) {
                System.debug('CHINTAN Read Bundled Opportunity Id: ' + bundledOpp.Id);
                bundledOppMap.put(bundledOpp.Id, myOpp.Id);
            }
        }
        
        //Now query Bundled Opportunities for services
        List<Opportunity> bundledOppList = [Select Id, Oportunity_Auto_Number__c, (Select Id, First_Year_Value__c, TotalPrice, Opportunity_Product__r.Name from OpportunityLineItems) from Opportunity Where Id = :bundledOppMap.keySet()];
        
        //Cycle through and process totals for services tied to the bundled Opps
        for (Opportunity myBundledOpp : bundledOppList) {
            //Get lead Opp ID
            Id leadOppId = bundledOppMap.get(myBundledOpp.Id);
            //Append the Bundled Opp CRM ID to the map value
            crmIdMap.put(leadOppId, crmIdMap.get(leadOppId) + ';' + myBundledOpp.Oportunity_Auto_Number__c);
            
            System.debug('CHINTAN Working on Bundled Opportunity Id: ' + myBundledOpp.Id);
            //Read Services tied to the Bundled Opp
            for (OpportunityLineItem lineItem : myBundledOpp.OpportunityLineItems) {
                System.debug('CHINTAN Read Bundled Service Totals: ' + lineItem.First_Year_Value__c + ', ' + lineItem.TotalPrice);
                oppFirstYearValueMap.put(leadOppId, (oppFirstYearValueMap.get(leadOppId) != null ? oppFirstYearValueMap.get(leadOppId) + lineItem.First_Year_Value__c : lineItem.First_Year_Value__c));
                oppTotalValueMap.put(leadOppId, (oppTotalValueMap.get(leadOppId) != null ? oppTotalValueMap.get(leadOppId) + lineItem.TotalPrice : lineItem.TotalPrice));
                //Append the Service Name to the map value
                serviceMap.put(leadOppId, serviceMap.get(leadOppId) + ';' + lineItem.Opportunity_Product__r.Name);
            }
        }
        System.debug('CPA FY map is: ' + oppFirstYearValueMap);
        System.debug('CPA Total map is: ' + oppTotalValueMap);
        System.debug('CPA CRM ID map is: ' + crmIdMap);
        System.debug('CPA Service Map is: ' + serviceMap);
        
        //Finally update totals on lead opps
        for (Opportunity myOpp : leadOppList) {
            myOpp.Bundled_First_Year_Value__c = oppFirstYearValueMap.get(myOpp.Id);
            myOpp.Bundled_Total_Opportunity_Value__c = oppTotalValueMap.get(myOpp.Id);
            myOpp.All_Service_Oppty_CRM_ID__c = crmIdMap.get(myOpp.Id);
            myOpp.All_Services__c = serviceMap.get(myOpp.Id);
            System.debug('CPA updated opp is: ' + myOpp);
        }
        update leadOppList;       
    } //calculateBundledTotals
    
    /*00121299-Ritu Sharma-This function will auto calculate First Year total of each opportunity product if 
    schedule(s) exist for them. If schedules does not exist then manual value entered by user will remain intact*/
    public static void setFirstYearValue(List<OpportunityLineItem> oppLineItemList){
        Double firstYearAmt;
        List<OpportunityLineItemSchedule> scheduleList;
        List<OpportunityLineItemSchedule> tempScheduleList;
        Map<ID,List<OpportunityLineItemSchedule>> scheduleMap;
        
        //Getting handle of all schedules
        scheduleList=[Select ID,OpportunityLineItemID,ScheduleDate,Revenue from OpportunityLineItemSchedule where OpportunityLineItemID IN:oppLineItemList];     
        
        if(scheduleList.size()>0){
            //Preparing map for line item id and revenue schedule list  
            scheduleMap = new Map<ID,List<OpportunityLineItemSchedule>>();          
            for (Integer i=0;i<scheduleList.size();i++){                
                tempscheduleList = scheduleMap.get(scheduleList[i].OpportunityLineItemId);                
                if(tempScheduleList != null)                
                    tempScheduleList.add(scheduleList[i]);                
                else{                    
                    tempScheduleList = new List<OpportunityLineItemSchedule>();                    
                    tempScheduleList.add(scheduleList[i]);                
                }                
                scheduleMap.put(scheduleList[i].OpportunityLineItemId, tempScheduleList);              
            }

            //Looping through all line items
            for(OpportunityLineItem lineItem: oppLineItemList){
                scheduleList = scheduleMap.get(lineItem.id);
                firstYearAmt = 0.00;
                if (scheduleList.size()>0){ //Schedules exist for the opportunity product
                    if (lineItem.Service_Start_Date__c!=Null){
                        for (OpportunityLineItemSchedule schedule: scheduleList) {
                            if (lineItem.Service_Start_Date__c.year()==schedule.ScheduleDate.year()) 
                                firstYearAmt=firstYearAmt+schedule.Revenue;
                        }
                    }    
                    System.debug('Opp Product ID:'+lineItem.ID+' - firstYearAmt:'+firstYearAmt);       
                    lineItem.First_Year_Value__c=firstYearAmt;                    
                }
            }
        }
   }
}