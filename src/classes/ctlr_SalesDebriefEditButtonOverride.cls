/** Controller That Traps the Edit button on an existing Sales Debrief Survey Record
  * Case 110034. Chintan Adhyapak. March 11, 2014 */
public without sharing class ctlr_SalesDebriefEditButtonOverride {
    /* class attributes */
    private String oppId;
    private Sales_Debrief_Survey__c survey;
    
    /* constructor */
    public ctlr_SalesDebriefEditButtonOverride(ApexPages.StandardController controller) {        
        this.survey = ((Sales_Debrief_Survey__c)controller.getRecord());
        System.debug('CPA survey.Id is: ' + survey.Id);
    } //constructor
    
    
    /* action method */
    public PageReference init() {
        //Local vars
        PageReference redirect = null;
        String retUrl = '';
        
        //read all fieldNames for Survey object
        Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Sales_Debrief_Survey__c.fields.getMap();
        
        //Create a SOQL string with all fields
        String fieldNames = '';
        for(String fieldName : schemaFieldMap.keySet()) {
            fieldNames += ',' + fieldName;
        }
        fieldNames = fieldNames.substring(1);
        String soql = 'Select ' + fieldNames + ' From Sales_Debrief_Survey__c Where Id = \'' + survey.Id + '\'';
        
        //Read Survey Data
        survey = Database.query(soql);
        System.debug('CPA read survey: ' + survey);
        
        //Set Opp Id
        this.oppId = survey.Opportunity_ID__c;
        System.debug('CPA opp Id is: ' + oppId);
        
        //Read Custom Setting
        Sales_Debrief_Survey_Settings__c appSettings = Sales_Debrief_Survey_Settings__c.getInstance('North America Sales Debrief');
        if (appSettings == null) {
        	return null;
        }
        
        //If this is a North America Sales Debrief Survey, redirect user to VF page else standard edit page
        if (this.survey.RecordTypeId == appSettings.Record_Type__c) {
        	retUrl = '/apex/SalesDebriefSurveyUS?oppId=' + oppId + '&RecordType=' + appSettings.Record_Type__c;
        	retUrl += '&retURL=%2F' + oppId;        	
        } else {
        	//the nooverride ensures that the overriden page is not called and we are not caught in an infinite loop
        	retUrl = '/' + survey.Id + '/e?nooverride=1&retURL=%2F' + oppId;
        }
        
        //Create PageReference
        System.debug('CHINTAN returning URL: ' + retUrl);
        redirect = new PageReference(retUrl);
        redirect.setRedirect(true);
        
        //Return
        return redirect;
    } //createSurveyRecord    
}