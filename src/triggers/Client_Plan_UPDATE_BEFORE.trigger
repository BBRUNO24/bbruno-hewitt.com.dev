trigger Client_Plan_UPDATE_BEFORE on Annual_Account_Plan__c (before update) {
	//Set the Client Promise Completion Date
	blogic_ClientPlan.setClientPromiseCompletionDate(trigger.new);
}