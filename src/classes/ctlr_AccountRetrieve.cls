public without sharing class ctlr_AccountRetrieve {

    //Hewitt org
	private String accountIdToRetrieve	{get;set;}
	public String responseXmlString		{get;set;}
	
	public ctlr_AccountRetrieve() {
		this.responseXmlString = '';
		this.accountIdToRetrieve = ApexPages.currentPage().getParameters().get('acctid');
	}
	
	public PageReference init() {
/*		
		// declare local vars
		String xmlResponse = '';
		
		if ((this.accountIdToRetrieve == null) || (this.accountIdToRetrieve == '')) {
			xmlResponse = generateError('ERROR: No account id was received');
		} else {
			// retrieve the s2s connection
			xmlResponse = startPartnerNetworkAccountCopyNow( this.accountIdToRetrieve );
		}
		
		// assign the xml response
		this.responseXmlString = xmlResponse;
*/		
		// return
		return null;
	}
	
	private String generateError(String errMsg) {
		String xmlError = '';
		xmlError = '<response><error>' + errMsg + '</error><retrieveresult></retrieveresult></response>';
		return xmlError;
	}
	
	/*****************************************************************
    DESCRIPTION: 
    private method initiate startPartnerNetowrkAccountCopyNow, start the account copy process

    PARAMETERS:
    Account ID 

    RETURNS:
    String
    ******************************************************************/
/*	private String startPartnerNetworkAccountCopyNow(ID accid){		
		// declare local vars
		String locaXMLString = '';
		AccountCreateProcess__c appSettings = null;
		PartnerNetworkRecordConnection newrecord = null;
        
        // get an instance to the public settings
        appSettings = AccountCreateProcess__c.getInstance();
			
		// retrieve the connection
		System.debug('retrieving details on the aon connection...' + accountIdToRetrieve + ' - ' + appSettings.Connection_Name__c);		
		PartnerNetworkConnection conn = [select Id, ConnectionStatus, ConnectionName from PartnerNetworkConnection where ConnectionStatus = 'Accepted' and ConnectionName = :appSettings.Connection_Name__c][0];
		System.debug('retrieved details: ' + conn);
			
		// create the record share
		System.debug('ctlr_AccountRetrieve connection id: ' + conn.Id);
		newrecord = new PartnerNetworkRecordConnection();
    	newrecord.ConnectionId = conn.Id;
    	newrecord.LocalRecordId = accid;  
    	newrecord.SendClosedTasks = false;
    	newrecord.SendOpenTasks = false;
    	newrecord.SendEmails = false;   
    	System.debug('inserting record share: ' + newRecord);
    	
    	// commit the share
    	Database.Saveresult sr = Database.insert(new PartnerNetworkRecordConnection[]{newRecord})[0];
    	System.debug('insert success?: ' + sr.isSuccess() + ', errors: ' + sr.getErrors());
    	if (sr.isSuccess()) {
    		locaXMLString = '<response><error></error><retrieveresult>' + accid + '</retrieveresult></response>';
    	} else {
    		locaXMLString = '<response><error>' + sr.getErrors()[0].getMessage() + '</error><retrieveresult></retrieveresult></response>';
    	}
		
		return locaXMLString;
	}
*/	
}