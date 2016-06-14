trigger ClientAssessmentSurvey_AFTER_INSERT on Client_Assessment_Survey__c (after insert) {
	//update Account and Service Provider data
	blogic_Account.updateAccountWithSurveyData(trigger.new);
}