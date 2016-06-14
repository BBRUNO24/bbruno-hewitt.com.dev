//This class handles business logic tied to the Annual_Account_Plan__c Object
//Chintan Adhyapak, February 19, 2013 
public without sharing class blogic_ClientPlan {
	/** Update Client Satisfaction Survey Completed checkbox when a Client Plan is created
      * Chintan, February 19, 2013 */
    public static void updateSurveyCompletedCheckbox(List<Annual_Account_Plan__c> plans) {
    	//local vars
    	Set<Id> accountIds = new Set<Id> ();
    	Set<String> years = new Set<String> ();
    	Map<String, Annual_Account_Plan__c> planMap = new Map<String, Annual_Account_Plan__c> ();
    	
    	//Spin through plans
    	for (Annual_Account_Plan__c plan : plans) {
    		accountIds.add(plan.Account__c);
    		years.add(plan.Account_Plan_Year__c);
    		
    		//Create a map with the Account Id + Year as the key
    		String key = plan.Account__c + plan.Account_Plan_Year__c;
    		System.debug('CPA Putting in Key: ' + key); 
    		planMap.put(key, plan);
    	}
    	System.debug('CPA accoundIds: ' + accountIds);
    	System.debug('CPA years: ' + years);
    	
    	//Check for Client Satisfaction Survey records for the same year
    	List<Client_Satisfaction_Survey__c> surveyList = [Select Id, Account__c, Survey_Year__c From Client_Satisfaction_Survey__c Where Account__c in :accountIds And Survey_Year__c in :years];
    	
    	for (Client_Satisfaction_Survey__c survey : surveyList) {
    		//Verify that a survey record exists for the same combination of Account + Year as the plan since the query does not guarantee that
    		String key = survey.Account__c + survey.Survey_Year__c;
    		System.debug('CPA Searching for Key: ' + key);
    		if (planMap.containsKey(key)) {
    			Annual_Account_Plan__c myPlan = planMap.get(key);
    			myPlan.Client_Satisfaction_Survey_Completed__c = true;
    		}
    	}
    } //updateSurveyCompletedCheckbox
    
    
    /** Update Client Satisfaction Survey Completed checkbox when a Client Satisfaction Survey is created
      * Chintan, February 19, 2013 */
    public static void updateSurveyCompletedCheckbox(List<Client_Satisfaction_Survey__c> surveys) {
    	//local vars
    	Set<Id> accountIds = new Set<Id> ();
    	Set<String> years = new Set<String> ();
    	Map<String, Client_Satisfaction_Survey__c> surveyMap = new Map<String, Client_Satisfaction_Survey__c> ();
    	List<Annual_Account_Plan__c> plansToUpdate = new List<Annual_Account_Plan__c> ();
    	
    	//Spin through surveys
    	for (Client_Satisfaction_Survey__c survey : surveys) {
    		accountIds.add(survey.Account__c);
    		years.add(survey.Survey_Year__c);
    		
    		//Create a map with the Account Id + Year as the key
    		String key = survey.Account__c + survey.Survey_Year__c;
    		System.debug('CPA Putting in Key: ' + key); 
    		surveyMap.put(key, survey);
    	}
    	System.debug('CPA accoundIds: ' + accountIds);
    	System.debug('CPA years: ' + years);
    	
    	//Check for Client Plan records for the same year
    	List<Annual_Account_Plan__c> planList = [Select Id, Account__c, Account_Plan_Year__c From Annual_Account_Plan__c Where Account__c in :accountIds And Account_Plan_Year__c in :years];
    	
    	for (Annual_Account_Plan__c plan : planList) {
    		//Verify that a survey record is being created for the same combination of Account + Year as the plan since the query does not guarantee that 
   			String key = plan.Account__c + plan.Account_Plan_Year__c;
    		System.debug('CPA Searching for Key: ' + key);
    		if (surveyMap.containsKey(key)) {
    			plan.Client_Satisfaction_Survey_Completed__c = true;
    			plansToUpdate.add(plan);
    		}
    	}
    	
    	//update plans
    	if (!plansToUpdate.isEmpty()) {
    		update plansToUpdate;
    	}
    } //updateSurveyCompletedCheckbox
    
    
    
    /** Set the Client Promise Completion Date if appropriate
      * Chintan, February 20, 2013 */
    public static void setClientPromiseCompletionDate(List<Annual_Account_Plan__c> plans) {
    	//Spin through plans
    	for (Annual_Account_Plan__c plan : plans) {
    		if (plan.Discover_Meeting_Completed__c && plan.Deliver_Meetings_Completed__c && plan.Executive_Sponsor_Meetings_Completed__c && plan.Client_Satisfaction_Survey_Completed__c) {
    			plan.Client_Promise_Completion_Date__c = Datetime.now();
    		} else {
    			plan.Client_Promise_Completion_Date__c = null;
    		}
    	}
    } //setClientPromiseCompletionDate
}