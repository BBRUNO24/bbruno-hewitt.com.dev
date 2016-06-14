trigger Opportunity_INSERT_BEFORE on Opportunity (before insert) {
    //Stamp Opportunity Closed Date if opp is being inserted as Closed
    blogic_Opportunity.stampOpportunityClosedDate(null, trigger.new);
    
    //Set Chosen Provider to Aon Hewitt if Stage = Closed Won
    blogic_Opportunity.updateChosenProvider(trigger.new, null);    
    
    //Populate the Identified Owner field
    blogic_Opportunity.stampOwnerId(trigger.new);
}