trigger ProposalRequest_INSERT_AFTER on Proposal_Request__c (after insert) {
    //Create Associated Services
    blogic_ProposalRequest.createAssociatedServices(trigger.new);
    
    // 00077996-Ritu Sharma-Update Sourcing Provider field of opportunity
    blogic_ProposalRequest.updateOpportunity(trigger.new);
}