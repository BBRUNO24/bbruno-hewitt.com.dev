/** Controller for a Client Assessment Survey Form Edit Selector
  * Case 98847. Chintan Adhyapak. October 24, 2013 */
public without sharing class ctlr_ClientAssessmentEditSelector {
	//local var
	Client_Assessment_Survey__c cas {get; set;}
	
	/* constructor */
    public ctlr_ClientAssessmentEditSelector(ApexPages.StandardController controller) {
		cas = (Client_Assessment_Survey__c)controller.getRecord();
		System.debug('CHINTAN recordType ID is: ' + cas.RecordTypeId);
    } //constructor
    
    
    /* action method */
    public PageReference init() {
    	//Local vars
        PageReference redirect = null;
        String retUrl = '';
        
        //Read record types
        List<RecordType> recordTypeList = [SELECT Id,Name FROM RecordType WHERE SobjectType='Client_Assessment_Survey__c'];
        System.debug('CPA rtList is: ' + recordTypeList);
        System.debug('CPA cas is: ' + cas);
        
        //Identify APAC or US
        for (RecordType rt : recordTypeList) {
        	if (rt.Id == cas.RecordTypeId) {
        		if (rt.Name.contains('APAC')) {
        			retUrl = '/apex/ClientAssessmentEdit_APAC?id=' + cas.Id + '&sfdc.override=1&retURL=%2F' + cas.Id;
        			System.debug('CHINTAN returning URL: ' + retUrl);
        		} else if (rt.Name.contains('US')) {
        			retUrl = '/apex/ClientAssessmentEdit?id=' + cas.Id + '&sfdc.override=1&retURL=%2F' + cas.Id;
        			System.debug('CHINTAN returning URL: ' + retUrl);
        		} else {
        			return redirect;
        		}
        	}
        }
        
        //Create PageReference
        redirect = new PageReference(retUrl);
        redirect.setRedirect(true);
        
        return redirect;
    } //init
    
    
    /** Return to CAS Record */
    public PageReference returnBack() {
        PageReference redirect = new PageReference('/' + cas.Id);
        redirect.setRedirect(true);
        
        return redirect;
    } //returnBack
}