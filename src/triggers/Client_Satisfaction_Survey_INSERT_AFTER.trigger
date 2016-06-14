trigger Client_Satisfaction_Survey_INSERT_AFTER on Client_Satisfaction_Survey__c (after insert) {
	//Set the Client Satisfaction Survey Completed Checkbox
	blogic_ClientPlan.updateSurveyCompletedCheckbox(trigger.new);
}