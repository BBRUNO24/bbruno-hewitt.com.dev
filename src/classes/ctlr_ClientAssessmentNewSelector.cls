/** Controller for a new Client Assessment Survey Form Selector
  * Case 98847. Chintan Adhyapak. October 10, 2013 */
public without sharing class ctlr_ClientAssessmentNewSelector {
	/* class attributes */
    public String accountId {get; set;}
    
    /* constructor */
    public ctlr_ClientAssessmentNewSelector(ApexPages.StandardController controller) {
		accountId = ApexPages.currentPage().getParameters().get('retURL');
		accountId = accountId.substring(1, accountId.length());
       	System.debug('CHINTAN accountId is:' + accountId);
    } //constructor
    
    
    /* action method */
    public PageReference init() {
        //Local vars
        PageReference redirect = null;
        
        //Read Data
        Account myAccount = [Select Id, Name, Global_Region__c from Account Where Id = :accountId];
        
        //Read Record Type
        Client_Assessment_Settings__c appSettings = Client_Assessment_Settings__c.getInstance(myAccount.Global_Region__c);
        
        //Return if no record found for Global Region
        if (appSettings == null) { return redirect; }
        
        //Create the URL String
        String formName = null;
        if (myAccount.Global_Region__c.equalsIgnoreCase('North America')) {
        	formName = 'ClientAssessmentNew';
        } else if (myAccount.Global_Region__c.equalsIgnoreCase('Asia Pacific')) {
        	formName = 'ClientAssessmentNew_APAC';
        }
        
        String retUrl = '/apex/' + formName + '?CF' + appSettings.Account_Field_Id__c + '=' + EncodingUtil.urlEncode(myAccount.Name, 'UTF-8');
       	retUrl += '&CF' + appSettings.Account_Field_Id__c + '_lkid=' + myAccount.Id + '&RecordType=' + appSettings.Record_Type_Id__c;
        retUrl += '&sfdc.override=1&retURL=%2F' + myAccount.Id;
        System.debug('CHINTAN returning URL: ' + retUrl);

        //Create PageReference
        redirect = new PageReference(retUrl);
        redirect.setRedirect(true);
        
        return redirect;
    } //init
    
    
    /** Return to Opportunity */
    public PageReference returnBack() {
        PageReference redirect = new PageReference('/' + accountId);
        redirect.setRedirect(true);
        
        return redirect;
    } //returnBack
}