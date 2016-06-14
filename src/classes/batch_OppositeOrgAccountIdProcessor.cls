global virtual class batch_OppositeOrgAccountIdProcessor implements Database.Batchable<sObject>, Database.AllowsCallouts {

	//declare class vars
    global String query {get;set;}
    global LoggingLevel logLevel {get;set;}
    global String testId {get;set;}		// only used for the test class
    
    //class contructor
    global batch_OppositeOrgAccountIdProcessor() {
        this.query = 'select id, local_record_id__c, remote_record_id__c from Org_Integration_Record_Correlation__c';
        this.logLevel = LoggingLevel.DEBUG;
    }
	
	// start
	global Database.QueryLocator start(Database.BatchableContext BC){
		// debug
     	System.debug(this.logLevel, '--------------------------- start BEGIN');
     	System.debug(this.logLevel, 'Executing query: ' + this.query); 
		
		// kick off the job by obtaining a handle to a query locator
		return Database.getQueryLocator(this.query);
	}
	
	// this method receives the results of the start() method in chunks, and processed the 
	// received records 
   	global void execute(Database.BatchableContext BC, List<sObject> scope){
   		
   		//debug
   		System.debug(this.logLevel, 'execute START');
   		System.debug(this.logLevel, 'executing on a batch of ' + scope.size() + ' records...');
   		
   		// declare local vars
   		HttpRequest req = null;
   		HTTPResponse res = null;
   		Set <String> processedRecordIds = new Set <String>();
   		List <Org_Integration_Record_Correlation__c> recordsToDelete = new List<Org_Integration_Record_Correlation__c>();
   		Set <String> localRecordIds = new Set <String>();
   		Map <Id, Account> localRecords = null;
   		
   		// get an instance of application settings
   		AccountCreateProcess__c appSettings = AccountCreateProcess__c.getInstance();
   		
   		// first we scrub the inboud records to ensure that the local account records still exist, and if not delete those records
   		System.debug('collecting local records ids...');
   		for (sObject record : scope) {
   			
   			// cast the sObject to a correlation object
			Org_Integration_Record_Correlation__c correlation = (Org_Integration_Record_Correlation__c)record;
   			
   			localRecordIds.add(correlation.local_record_id__c);
   		}
   		System.debug('collected ' + localRecordIds.size() + ' record ids: ' + localRecordIds);
   		
   		// retrieve the corresponding account ids
   		System.debug('retrieving local records...');
   		localRecords = new Map <Id, Account>([select id from Account where id IN :localRecordIds]);
   		System.debug('retrieved ' + localRecords.size() + ' records: ' + localRecords);
   		
   		// create an xml document
   		DOM.Document doc = new DOM.Document();
   		
   		// create a root node on the document
   		dom.XmlNode envelope = doc.createRootElement('CorrelationRequest', null, null);
   		
   		// add a container for records
   		dom.XmlNode payload = envelope.addChildElement('RecordsToCorrelate', null, null);
   		
   		// iterate over the records inbound and create an XML document to send over the wire
   		// stamp the account with the appropriate legacy ids
		System.debug(this.logLevel, 'building the xml payload to be sent over the wire...');
		for (sObject record : scope) {
   		
   			// cast the sObject to a correlation object
			Org_Integration_Record_Correlation__c correlation = (Org_Integration_Record_Correlation__c)record;
			System.debug('processing record: ' + correlation);
			
			// verify the corresponding account still exists
			System.debug('verifying the local records still exists...');
			if (localRecords.containsKey(correlation.local_record_id__c)) {
				System.debug('record located');
				
				// build a wrapper for the record
	   			dom.XmlNode recordToCorrelate = payload.addChildElement('Record', null, null);
	   			
	   			// add the record ids in there
	   			recordToCorrelate.addChildElement('LocalRecordId', null, null).addTextNode(correlation.Remote_Record_Id__c);
	   			recordToCorrelate.addChildElement('RemoteRecordId', null, null).addTextNode(correlation.Local_Record_Id__c);				
			} else {
				// record no longer exists, add to list to be deleted				
				System.debug('corresponding local record no longer exists, adding to delete list...');
				recordsToDelete.add(correlation);
			}
		}
		System.debug('constructed XML document: ' + doc.toXmlString());
		
		// send the payload over the wire and get back a response
		// build the request
        req = createRequest(appSettings.Record_Correlation_Url__c, doc);
       	System.debug('created request: ' + req);
       	
       	// send the request
      	System.debug('sending the request...');
       	res = execute(req);
       	System.debug('response: ' + res);
       	
       	// get a handle on the xml doc
       	doc = getResponseDoc(res, req);
       	System.debug('XML Doc: ' + doc.toXmlString());
       	
       	// delete any orphaned records before proceeding
		System.debug('deleting ' + recordsToDelete.size() + ' orphan records: ' + recordsToDelete);
		delete recordsToDelete;
       	
       	// unpackage the response, and delete records from the local table that were successfully processed
       	System.debug('unpackaging processed records...');
       	for (Dom.XMLNode processedRecord : doc.getRootElement().getChildElement('ProcessedRecords',null).getChildElements()) {
       		processedRecordIds.add(processedRecord.getText());       		
       	}
       	System.debug('received ' + processedRecordIds.size() + ' records: ' + processedRecordIds);
       	
       	// now delete the records from the correlation table
       	System.debug('retreiving the received records from the correlation table for deletion...');
       	recordsToDelete = [select id, local_record_id__c, remote_record_id__c from Org_Integration_Record_Correlation__c where local_record_id__c in :processedRecordIds];
       	System.debug('retrieved ' + recordsToDelete.size() + ' records: ' + recordsToDelete);
       	
       	// delete the records
       	System.debug('deleting the records...');
       	delete recordsToDelete;
       	System.debug('records deleted');
       	
       	// debug
       	System.debug(this.logLevel, 'execute END');
   	}

   	// clean up routine to perform any final tasks before exiting
   	global void finish(Database.BatchableContext BC){
   		System.debug(this.logLevel, 'finish END');
   	}   


	/*************************************************************
                PROTECTED METHODS
    *************************************************************/
    // method to pull out the response xml doc from an HTTP response 
    protected virtual Dom.Document getResponseDoc(HttpResponse r, HttpRequest req) {
    	if (!Test.isRunningTest()) {
    		System.debug('response body: ' + r.getBody());
    		return r.getBodyDocument();
    	} else {
    		String responseBody = '<?xml version="1.0" encoding="UTF-8"?><CorrelationResponse><ProcessedRecords><RecordId>' + this.testId + '</RecordId></ProcessedRecords></CorrelationResponse>';
			Dom.Document xmlDoc = new Dom.Document();
			// load the test xml doc
			xmlDoc.load(responseBody);
           	return xmlDoc;
    	}
    }
    
    // method to create an HTTP request
    protected virtual HttpRequest createRequest(String url, Dom.Document content) {
    	System.debug('Packaging up the request');
       	HttpRequest req = new HttpRequest();
       
       	req.setEndpoint( url );
    	req.setMethod('POST');
    	req.setBody('req ' + content.toXmlString());
		        
       	return req;
    }
     
    // method to execute an HTTP request and receive back an HTTP response
  	protected virtual HttpResponse execute(HttpRequest req) {
    	if (!Test.isRunningTest()) {
    		return new http().send(req);
    	} else {
    		return new HttpResponse();
    	}
    }

}