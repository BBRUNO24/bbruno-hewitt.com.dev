public without sharing class ctlr_RecordCorrelation {

	// class attributes
	public String xmlResponse			{get;set;}

	// constructor
	public ctlr_RecordCorrelation() {
		this.xmlResponse = '';
	}

	// init
	public PageReference init() {
		
		// debug
		System.debug('processing inbound correlation request...');
		
		System.debug('dumping headers...');
		for (String key : ApexPages.currentPage().getHeaders().keySet()) {
			System.debug(key + ': ' + ApexPages.currentPage().getHeaders().get(key));
		}
		
		System.debug('dumping ' + ApexPages.currentPage().getParameters().keySet().size() + ' parameters:' + ApexPages.currentPage().getParameters().keySet());
		for (String key : ApexPages.currentPage().getParameters().keySet()) {
			System.debug('key: ' + key);
			System.debug('value: ' + ApexPages.currentPage().getParameters().get(key));
		}
		
		// declare local vars
		Dom.Document doc = new Dom.Document();
		List <Account> recordsToUpdate = new List <Account>();
		List <Database.Saveresult> saveResults = null;
		
		// get a handle to the request body
		System.debug('loding request body into xml document...');
		doc.load(ApexPages.currentPage().getParameters().get('req'));
		System.debug('loaded doc: ' + doc.toXmlString());

		// process the received records
		System.debug('processing received records...');
		for (Dom.XMLNode record : doc.getRootElement().getChildElement('RecordsToCorrelate',null).getChildElements()) {
			System.debug('processing record node: ' + record);
			
			// get handles to the various ids
			String localRecordId = record.getChildElement('LocalRecordId', null).getText();
			String remoteRecordId = record.getChildElement('RemoteRecordId', null).getText();
			Account account = new Account(id = localRecordId, Opposite_Org_Account_Id__c = remoteRecordId);
			System.debug('processing account: ' + account);
			
			// add the account to the list of records to be updated			
			recordsToUpdate.add(account);
		}
		System.debug('received ' + recordsToUpdate.size() + ' records to update: ' + recordsToUpdate);

		// perform the update
		System.debug('updating records...');
		saveResults = Database.update(recordsToUpdate);
		System.debug('update complete');
		
		// iterate over the response and build the response
		System.debug('processing save results and building response...');
		
		// refresh the xml doc
		doc = new Dom.Document();
		
   		// create a root node on the document
   		dom.XmlNode payload = doc.createRootElement('CorrelationResponse', null, null);
   		
   		// create a record container
   		dom.XmlNode recordsProcessed = payload.addChildElement('ProcessedRecords', null, null); 
   		
   		for (Integer x = 0; x < saveResults.size(); x++) {
   			
   			// get handles on the key records
   			Database.Saveresult sr = saveResults[x];
   			Account acct = recordsToUpdate[x];
   			
   			if (sr.isSuccess()) {
   				System.debug('Record id [' + sr.getId() + '] was successfully updated');
				recordsProcessed.addChildElement('RecordId', null, null).addTextNode(acct.Opposite_Org_Account_Id__c);
   			} else {
   				System.debug('An error occurred while attempting to update record id [' + sr.getId() + ']: ' + sr.getErrors()[0]);
   			}
   		}
   		
   		// store the response
   		this.xmlResponse = doc.toXmlString();
   		System.debug('returning response: ' + this.xmlResponse);
		
		// return
		return null;
	}
}