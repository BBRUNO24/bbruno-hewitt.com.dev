//Implemented for Case 52501. Chintan Adhyapak. February 15, 2013
public without sharing class ctlr_ClientTrackerCAS {
	//local vars
	public Client_Assessment_Survey__c cas	{get; set;}
	public Annual_Account_Plan__c plan		{get; set;}
	public Boolean planExists				{get; set;}

	/** constructor */
    public ctlr_ClientTrackerCAS(ApexPages.StandardController controller) {
        cas = (Client_Assessment_Survey__c)controller.getRecord();
        
        //read all fieldNames for Client_Assessment_Survey__c object
        Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Client_Assessment_Survey__c.fields.getMap();
        
        //Create a SOQL string with all fields
        String fieldNames = '';
        for(String fieldName : schemaFieldMap.keySet()) {
        	fieldNames += fieldName + ',' ;
        }
        //fieldNames = fieldNames.substring(1);
        fieldNames += 'Account__r.Name';
        String soql = 'Select ' + fieldNames + ' From Client_Assessment_Survey__c Where Id = \'' + cas.Id + '\'';
        
        //Read CAS data
        cas = Database.query(soql);
        
        //Look for a Client Plan record for the same Year
        List<Annual_Account_Plan__c> planList = [Select Discover_Meeting_Completed__c, Discover_Meeting_Types_And_Dates__c, Deliver_Meetings_Completed__c, 
        		Deliver_Meeting_Types_And_Dates__c, Executive_Sponsor_Meetings_Completed__c, Exec_Sponsor_Meeting_Types_And_Dates__c, 
        		Client_Satisfaction_Survey_Completed__c, Client_Promise_Completion_Date__c, Client_Promise_Score__c, Client_Plan_Completed__c 
        		From Annual_Account_Plan__c Where Account_Plan_Year__c = :cas.Year__c And Account__c = :cas.Account__c Limit 1];
        planExists = false;
        if (planList.size() > 0) {
        	planExists = true;
        	plan = planList[0];
        }
    } //constructor
}