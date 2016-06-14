/** Controller That Prepopulates Data on a new Sales Debrief Survey Form
  * Case 43640. Chintan Adhyapak. December 03, 2012 */
public without sharing class ctlr_SalesDebriefSurveyNewButtonOverride {
    /* class attributes */
    public String oppId             {get;set;}
    public boolean error            {get; set;}
    public String errorMessage      {get; set;}
    public String selectedSurvey    {get; set;}
    
    /* constructor */
    public ctlr_SalesDebriefSurveyNewButtonOverride(ApexPages.StandardController controller) {
        this.oppId = ((Sales_Debrief_Survey__c)controller.getRecord()).Opportunity_ID__c;
        System.debug('CPA myOppId is: ' + oppId);
        this.error = false;
        this.errorMessage = '';
    } //constructor
    
    
    /* action method */
    public PageReference createSurveyRecord() {
        //Local vars
        PageReference redirect = null;
        String index = '';
        String objPrepend = '';
        String retUrl = '';
        
        //Check Required fields
        if (selectedSurvey == null) {
            this.error = true;
            this.errorMessage = 'You must select a Survey Type to continue.';
            return null;
        }
        
        //Read Data
        System.debug('CPA in createSurveyRecord oppId is: ' + oppId);
        Opportunity myOpp = [Select Id, Name, Opportunity.Account.Id, Opportunity.Account.Name, Opportunity.Account.Global_Region__c, isClosed from Opportunity Where Id = :oppId];
        
        //Read Custom Setting
        index = myOpp.Account.Global_Region__c + ' ' + this.selectedSurvey;
        Sales_Debrief_Survey_Settings__c appSettings = Sales_Debrief_Survey_Settings__c.getInstance(index);
        
        //Return if no record found for Global Region
        if (appSettings == null) { 
            error = true;
            this.errorMessage = 'No ' + this.selectedSurvey + ' Survey Exists for the Global Region, ' +  myOpp.Account.Global_Region__c + ', that is tied to this Account. Contact your local Sales Operations team for further assistance.';
            return null; 
        }
        
        //Create the URL String
        if (appSettings.Name.equalsIgnoreCase('North America Sales Debrief')){
        	if (!myOpp.IsClosed) {
        		error = true;
        		this.errorMessage = 'The Opportunity Must be in a Closed Stage in Order to Create a Sales Debrief Survey';
        		return null;
        	}
        	retUrl = '/apex/SalesDebriefSurveyUS?oppId=' + myOpp.Id + '&RecordType=' + appSettings.Record_Type__c;
        } else {
        	objPrepend = Schema.getGlobalDescribe().get('Sales_Debrief_Survey__c').getDescribe().getKeyPrefix();
        	retUrl = '/' + objPrePend + '/e?CF' + appSettings.Account_Field_Id__c + '=' + EncodingUtil.urlEncode(myOpp.Account.Name, 'UTF-8');
        	retUrl += '&CF' + appSettings.Account_Field_Id__c + '_lkid=' + myOpp.Account.Id + '&RecordType=' + appSettings.Record_Type__c;
        	retUrl += '&CF' + appSettings.Opportunity_Field_Id__c + '=' + EncodingUtil.urlEncode(myOpp.Name, 'UTF-8');
        	retUrl += '&CF' + appSettings.Opportunity_Field_Id__c + '_lkid=' + myOpp.Id;
        	retUrl += '&nooverride=1&retURL=%2F' + myOpp.Id;
        }
        //Create PageReference
        System.debug('CHINTAN returning URL: ' + retUrl);
        redirect = new PageReference(retUrl);
        redirect.setRedirect(true);
        
        return redirect;
    } //createSurveyRecord
    
    
    /** Return to Opportunity */
    public PageReference returnBack() {
        PageReference redirect = new PageReference('/' + oppId);
        redirect.setRedirect(true);
        
        return redirect;
    } //returnBack
}