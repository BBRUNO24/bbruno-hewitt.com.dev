trigger Client_Plan_INSERT_BEFORE on Annual_Account_Plan__c (before insert) {
	//Set the Client Satisfaction Survey Completed Checkbox
	blogic_ClientPlan.updateSurveyCompletedCheckbox(trigger.new);
}