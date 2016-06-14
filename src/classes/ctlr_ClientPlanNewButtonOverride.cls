/** Controller That Prepopulates Data on a new Client Plan Form
  * Case 48061. Chintan Adhyapak. January 25, 2012 */
public without sharing class ctlr_ClientPlanNewButtonOverride {
	/* class attributes */
    public String accountId {get; set;}
    
    /* constructor */
    public ctlr_ClientPlanNewButtonOverride(ApexPages.StandardController controller) {
    	String currURL = ApexPages.currentPage().getUrl();
    	String myAccountId = '';
       	if (currURL.contains('visual.force.com')) {
       		System.debug('CHINTAN retURL: ' + ApexPages.currentPage().getParameters().get('retURL'));
       		integer index = ApexPages.currentPage().getParameters().get('retURL').indexOf('id=');
       		System.debug('CHINTAN index of id=: ' + index);
       		myAccountId = ApexPages.currentPage().getParameters().get('retURL').substring(index+3, index+21);
       	} else {
       		myAccountId = ApexPages.currentPage().getParameters().get('retURL');
       		myAccountId = myAccountId != null ? myAccountId.substring(1, myAccountId.length()) : '';
       	}
       	System.debug('CHINTAN myAccountId is:' + myAccountId);
        this.accountId = myAccountId;
    } //constructor
    
    
    /* action method */
    public PageReference init() {
        //Local vars
        PageReference redirect = null;
        List<Account_Segmentation__c> segmentList = new List<Account_Segmentation__c> ();
        boolean includeQ = true;
        
        //Read Data
        Account myAccount = [Select Id, Name, Global_Region__c from Account Where Id = :accountId];
        
        //Read Record Type
        Client_Plan_Settings__c appSettings = Client_Plan_Settings__c.getInstance(myAccount.Global_Region__c);
        
        //Return if no record found for Global Region
        if (appSettings == null) { return redirect; }
        
        //Read Data for APAC. Case 198294. Chintan Adhyapak, May 26, 2015.
        if (myAccount.Global_Region__c.equalsIgnoreCase('Asia Pacific')) {
        	segmentList = [SELECT Country__c, Segment__c FROM Account_Segmentation__c WHERE Associated_Account__c = :accountId];
        	if (segmentList.size() > 0) {
        		for (Account_Segmentation__c segment : segmentList) {
	        		if (segment.Country__c.equalsIgnoreCase('GLOBAL') && segment.Segment__c.equalsIgnoreCase('Client Promise')) {
        				includeQ = false;
        			}
        		}
        	}
		}
 
        
        //Create the URL String
        String objPrepend = Schema.getGlobalDescribe().get('Annual_Account_Plan__c').getDescribe().getKeyPrefix();
        String retUrl = '/' + objPrePend + '/e?CF' + appSettings.Account_Field_Id__c + '=' + EncodingUtil.urlEncode(myAccount.Name, 'UTF-8');
        retUrl += '&CF' + appSettings.Account_Field_Id__c + '_lkid=' + myAccount.Id + '&RecordType=' + appSettings.Record_Type_Id__c;
        //Case 198294. May 26, 2015. Chintan Adhyapak
        if (myAccount.Global_Region__c.equalsIgnoreCase('Asia Pacific') && includeQ) {
        	retUrl += '&' + appSettings.Quality_Indicator_Id__c + '=1';
        }
        retUrl += '&nooverride=1&retURL=%2F' + myAccount.Id;
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