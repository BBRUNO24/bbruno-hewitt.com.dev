trigger Opportunity_UPDATE_BEFORE on Opportunity (before update) {
    //Stamp the Opportunity Closed Date
    blogic_Opportunity.stampOpportunityClosedDate(trigger.old, trigger.new);
    
    //Update Chosen Provider
    blogic_Opportunity.updateChosenProvider(trigger.new, trigger.old);
    
    //Populate the Identified Owner field
    blogic_Opportunity.stampOwnerId(trigger.new);
    
    //Copy the opportunity line item schedule data over to the custom revenue scheduling object if an opportunity has been updated.
    OppLineItemScheduleRevenueController.OppsToUpdate(trigger.new);
}