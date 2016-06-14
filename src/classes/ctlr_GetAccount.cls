public virtual class ctlr_GetAccount {

    public String accountIdToGet	{get;set;}
	
	public ctlr_GetAccount() {
		this.accountIdToGet = '';
	}
	
	public PageReference init() {
		
		// declare local vars
		PageReference redirect = null;
		
		// grab the account id to retreive from the query string
		this.accountIdToGet = ApexPages.currentPage().getParameters().get('acctid');
		
		if ((!processRequest()) || (this.accountIdToGet == null)) {
			redirect = null;
		} else {
			redirect = Page.AccountNowCopyRedirect;
        	redirect.getParameters().put('acctid', this.accountIdToGet);
        }
		
		return redirect;
	}
	
	private Boolean processRequest(){
		
		// declare local vars
		HttpRequest req = null;
    	HTTPResponse res = null;
    	Dom.Document doc = null;
    	Dom.XMLNode rootNode = null;
    	AccountCreateProcess__c appSettings = AccountCreateProcess__c.getInstance();
    	Boolean isSuccess = true;
    	
    	
    	// build the request
        System.debug('ctlr_GetAccount: ' + appSettings.getAccount__c + 'acctid=' + this.accountIdToGet);
        req = createRequest(appSettings.getAccount__c + 'acctid=' + this.accountIdToGet);
     	System.debug('created request: ' + req);
    	
     	// send the request
  		System.debug('sending the request...');
	   	res = execute(req);
	   	System.debug('response: ' + res);
     
     	// get a handle on the xml doc
     	doc = getResponseDoc(res, req);
     	System.debug('XML Doc: ' + doc.toXmlString());
     	
     	try{
     		//Retrieve the root element for this document.  
			rootNode = doc.getRootElement();
        
        	if ((rootNode.getChildElement('error',null).getText() != null) && (rootNode.getChildElement('error',null).getText() != '')) {
				isSuccess = false;
        	}
     	} catch(Exception e){
     		isSuccess = false;
     		System.debug('ctlr_GetAccount problems while sending the request: ' + e); 
     	}
     	
        return isSuccess;
	}
	
	/*************************************************************
    						PROTECTED METHODS
    *************************************************************/
   	// method to pull out the response xml doc from an HTTP response 
   	protected virtual Dom.Document getResponseDoc(HttpResponse r, HttpRequest req) {
     	return r.getBodyDocument();
  	}
    
    // method to create an HTTP request
    protected virtual HttpRequest createRequest(String url) {
   		System.debug('Packaging up the request');
   		HttpRequest req = new HttpRequest();
   		
   		req.setEndpoint( url );
		req.setMethod('GET');
   	 	
     	return req;
   	}
   	
   	// method to execute an HTTP request and receive back an HTTP response
	protected virtual HttpResponse execute(HttpRequest req) {
   		return new http().send(req);
   	}

}