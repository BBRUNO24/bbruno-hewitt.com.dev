public without sharing class blogic_ProposalRequest {
    /** Creates Associated Service records for the Proposal Request
      * Case 10167. Chintan Adhyapak. September 06, 2012 
      * 8/19/2013 - flag opps that a RFP has been created against them. Case 78812. Chintan */
    public static void createAssociatedServices(List<Proposal_Request__c> newProposals) {
        Map<Id, Id> opportunityProposalMap = new Map<Id, Id> ();
        Map<Id, Id> bundledOppProposalMap = new Map<Id, Id> ();
        List<Associated_Service__c> associatedServicesToCreate = new List<Associated_Service__c> ();
        List<Opportunity> oppsToUpdate = new List<Opportunity> ();
        
        //Cycle through and save data into a map
        for (Proposal_Request__c myProposal : newProposals) {
            opportunityProposalMap.put(myProposal.Opportunity__c, myProposal.Id);
        }
        
        //Pull Opportunity Data
        List<Opportunity> opportunities = [Select Id, RFP_Created__c, (Select Id, Opportunity_Product__c from OpportunityLineItems), (Select Id from Opportunities__r) from Opportunity Where Id In :opportunityProposalMap.keySet()];
        for (Opportunity myOpp : opportunities) {
            System.debug('CHINTAN Working on Opportunity Id: ' + myOpp.Id);
            //Flag Opp for RFP
            myOpp.RFP_Created__c = true;
            oppsToUpdate.add(myOpp);
            
            //Read Services Tied to the Opp
            for (OpportunityLineItem lineItem : myOpp.OpportunityLineItems) {
                System.debug('CHINTAN Read Service Id: ' + lineItem.Opportunity_Product__c);
                associatedServicesToCreate.add(getAssociatedService(opportunityProposalMap.get(myOpp.Id), lineItem.Opportunity_Product__c));
            }
            //Get Bundled Opps tied to this opp and store in a map
            for (Opportunity bundledOpp : myOpp.Opportunities__r) {
                System.debug('CHINTAN Read Bundled Opportunity Id: ' + bundledOpp.Id);
                bundledOppProposalMap.put(bundledOpp.Id, opportunityProposalMap.get(myOpp.Id));
            }
        }
        
        //Pull Bundled Opps Data
        opportunities = [Select Id, RFP_Created__c, (Select Id, Opportunity_Product__c from OpportunityLineItems) from Opportunity Where Id = :bundledOppProposalMap.keySet()];
        for (Opportunity myOpp : opportunities) {
        	//Flag opp
        	myOpp.RFP_Created__c = true;
        	oppsToUpdate.add(myOpp);
        	
            //Read Services tied to the Bundled Opp
            for (OpportunityLineItem lineItem : myOpp.OpportunityLineItems) {
                System.debug('CHINTAN Read Bundled Service Id: ' + lineItem.Opportunity_Product__c);
                associatedServicesToCreate.add(getAssociatedService(bundledOppProposalMap.get(myOpp.Id), lineItem.Opportunity_Product__c));
            }
        }
        
        //Finally, insert Proposal Services
        if (!associatedServicesToCreate.isEmpty()) {
        	System.debug('CPA In method createAssociatedServices, list associatedServicesToCreate is: ' + associatedServicesToCreate);
            try {
                insert associatedServicesToCreate;
            } catch (Exception e) {
                System.debug('CHINTAN ERROR in Creating Proposal Associated Services: ' + e.getMessage());
            }
        }
        
        //Update Opportunity Flag
        System.debug('CPA In method createAssociatedServices, list oppsToUpdate is: ' + oppsToUpdate);
        update oppsToUpdate;
    } //createAssociatedServices
    
    
    
    //00077996-Ritu Sharma-Update Sourcing Provider field of opportunity
    public static void updateOpportunity(List<Proposal_Request__c> newProposals)
    {
        List<String> oppsIDList = new List <String>(); //List of IDs of opps
        Map<ID,Opportunity> oppsMap= new Map<ID,Opportunity>(); //Map of opportunities
        List<Opportunity> oppsUpdateList=new List<Opportunity>();//List of opps that need to be updated
        Integer i=0;
        Opportunity opp=Null;
        
        //Preparing list of opportunities
        for (i=0; i<newProposals.size(); i++)   
                oppsIDList.add(newProposals[i].Opportunity__c);
        
        if (oppsIDList.size()>0)
        {
            oppsMap = new Map<ID,Opportunity>([select id,Sourcing_Provider__c from Opportunity where ID IN:oppsIDList]); //Searching opportunities
            for (i=0; i<newProposals.size(); i++)   
            {
                opp = oppsMap.get(newProposals[i].Opportunity__c);
                if (opp != null && opp.Sourcing_Provider__c != newProposals[i].Third_Party_Advisors_Involved__c) //User has changed the service provider
                {
                    opp.Sourcing_Provider__c=newProposals[i].Third_Party_Advisors_Involved__c;
                    oppsUpdateList.Add(opp); 
                }
            }
            Update oppsUpdateList; //Bulk update of opps
        }
    } //updateOpportunity
    
    
    
    /** Synchronizes Opportunity Line Items with the Associated Services on an RFP, every time one is added or deleted 
      * Case 78812. Chintan Adhyapak. August 22, 2013 */
    public static void syncAssociatedServices (List<OpportunityLineItem> productList) {
    	//Local vars
    	Set<Id> oppIdSet = new Set<Id> ();
    	Set<Id> leadOppsWithRFPSet = new Set<Id> ();
    	Map<Id, Proposal_Request__c> proposalMap;
    	
    	//Cycle through the incoming list of products and save unique Opp Ids
    	for (OpportunityLineItem product : productList) {
    		oppIdSet.add(product.OpportunityId);
    	}
    	System.debug('CPA syncAssociatedServices for OLI oppIdSet is: ' + oppIdSet);
    	
    	//From this list identify Lead opps with a RFP
    	for (Opportunity opp : [Select Id, RFP_Created__c, Lead_Opportunity_Name__c From Opportunity Where Id in :oppIdSet]) {
    		if (opp.RFP_Created__c) {
    			leadOppsWithRFPSet.add(opp.Lead_Opportunity_Name__c != null ? opp.Lead_Opportunity_Name__c : opp.Id);
    		}
    	}
    	System.debug('CPA syncAssociatedServices for OLI leadOppsWithRFPSet is: ' + leadOppsWithRFPSet);
    	
    	//Get a list of RFP IDs tied to these Lead Opps
    	proposalMap = new Map<Id, Proposal_Request__c> ([Select Id, Opportunity__c from Proposal_Request__c Where Opportunity__c in :leadOppsWithRFPSet]);
    	System.debug('CPA syncAssociatedServices for OLI proposalMap is: ' + proposalMap);
    	
    	//Blow all existing Associated Services tied to these RFPs
    	delete [Select Id from Associated_Service__c Where Proposal_Request__c in :proposalMap.keySet()];
    	
    	//Now recreate associate services
    	createAssociatedServices(proposalMap.values());
    } //syncAssociatedServices
    
    
    
    /** Synchronizes Opportunity Line Items with the Associated Services on an RFP
      * Case 78812. Chintan Adhyapak. August 26, 2013 */
    public static void syncAssociatedServices (List<Opportunity> newOppList, List<Opportunity> oldOppList) {
    	//Local vars
    	Set<Id> leadOppsSet = new Set<Id> ();
    	Map<Id, Proposal_Request__c> proposalMap;
    	
    	//Cycle through and store all Lead Opp IDs
    	if (trigger.isInsert) {
    		for (Opportunity myOpp : newOppList) {
    			leadOppsSet.add(myOpp.Lead_Opportunity_Name__c);
    		}
    		System.debug('CPA Method syncAssociatedServices leadOppsSet is: ' + leadOppsSet);
    	} else if (trigger.isUpdate) {
    		for (Integer i=0; i<newOppList.size(); i++) {
    			if (oldOppList[i].Lead_Opportunity_Name__c != newOppList[i].Lead_Opportunity_Name__c) { leadOppsSet.add(newOppList[i].Lead_Opportunity_Name__c); }
    		}
    		System.debug('CPA Method syncAssociatedServices leadOppsSet is: ' + leadOppsSet);
    	} else if (trigger.isDelete) {
    		for (Opportunity myOpp : oldOppList) {
    			leadOppsSet.add(myOpp.Lead_Opportunity_Name__c);
    		}
    		System.debug('CPA Method syncAssociatedServices leadOppsSet is: ' + leadOppsSet);
    	}
    	
    	//Find all RFPs tied to these Lead Opps
    	proposalMap = new Map<Id, Proposal_Request__c> ([Select Id, Opportunity__c from Proposal_Request__c Where Opportunity__c in :leadOppsSet]);
    	System.debug('CPA Method syncAssociatedServices proposalMap Values are: ' + proposalMap.values());
    	
    	//Blow all existing Associated Services tied to these RFPs
    	delete [Select Id from Associated_Service__c Where Proposal_Request__c in :proposalMap.keySet()];
    	
    	//Now recreate associate services
    	createAssociatedServices(proposalMap.values());
    	
    	//Finally set global flag to indicate that this processing has already been done so that this function is not called again within this transaction
    	System.debug('CPA Setting runOnceFlag to true');
    	util_globalUtilityMethods.setRunOnceFlag(true);
    } //syncAssociatedServices
    
    
    
    /** Private utility method to create and return a Proposal Service record
      * Chintan Adhyapak. September 7, 2012 */
    private static Associated_Service__c getAssociatedService(Id proposalId, Id serviceId) {
        Associated_Service__c myRecord = new Associated_Service__c();
        myRecord.Proposal_Request__c = proposalId;
        myRecord.Opportunity_Service__c = serviceId;
        return myRecord;
    } //getProposalService
}