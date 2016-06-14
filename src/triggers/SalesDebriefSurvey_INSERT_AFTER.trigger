trigger SalesDebriefSurvey_INSERT_AFTER on Sales_Debrief_Survey__c (after insert) {
    //Create Associated Services
    blogic_SalesDebriefSurvey.createAssociatedServices(trigger.new);
    
    //CSModBegin/End SunnyM 00070499 2July2013
    blogic_SalesDebriefSurvey.createTaskRelatedtoDebriefSurvey(trigger.new);
}