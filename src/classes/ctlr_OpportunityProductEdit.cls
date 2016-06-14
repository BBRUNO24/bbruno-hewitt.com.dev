public with sharing class ctlr_OpportunityProductEdit {
	public final OpportunityLineItem oli				{get; set;}
	public final Opportunity opportunity 				{get; set;}
	public dto_editLineItemProduct product 				{get; set;}
	public string getJSONScript							{get; set;}
	public string jsonMessagesString					{get; set;}
	
	public ctlr_OpportunityProductEdit(ApexPages.StandardController controller) {
    	
    	// debug
    	System.debug(System.LoggingLevel.INFO, 'ctlr_OpportunityProductEdit START');
    	
    	// declare local vars 
		String recordTypeId = ApexPages.currentPage().getParameters().get('RecordType');
		String stageName = ApexPages.currentPage().getParameters().get('stage');
		String pricebookId = ApexPages.currentPage().getParameters().get('pbId');
		String pricebookEntryId = ApexPages.currentPage().getParameters().get('peId');
		//String opportunityId = ApexPages.currentPage().getParameters().get('oId');
    	
    	// debug
		System.debug(System.LoggingLevel.INFO, 'received record type id: ' + recordTypeId);
		System.debug(System.LoggingLevel.INFO, 'received stage name: ' + stageName);
		System.debug(System.LoggingLevel.INFO, 'received pricebook id: ' + pricebookId);
		System.debug(System.LoggingLevel.INFO, 'received pricebook entry id: ' + pricebookEntryId);

		if (((OpportunityLineItem)controller.getRecord()).Id != null) {
			this.oli = Database.query('select ' + util_globalUtilityMethods.joinStringSet(util_globalUtilityMethods.getFieldsForObject('OpportunityLineItem'), false) + ' from OpportunityLineItem where id = \'' + ((OpportunityLineItem)controller.getRecord()).Id + '\'');
		} else {
			this.oli = new OpportunityLineItem();
		} 
    	
    	// declare local vars
    	//OpportunityLineItem tempOli = null;
    	Integer counter = 0;
    	
    	// get more info on the opportunity line item
    	
    	if (oli.id != null) {
    		//tempOli = [select id, opportunityid from OpportunityLineItem where id = :this.oli.id];
    		this.opportunity = Database.query('Select ' + util_globalUtilityMethods.joinStringSet(util_globalUtilityMethods.getFieldsForObject('Opportunity'), false) + ' From Opportunity Where Id = \'' + this.oli.OpportunityId + '\' Limit 1');
    	} else {
    		this.opportunity = new Opportunity();
    	} 
		
		// determine if some opportunity info needs to be backfilled
		if (recordTypeId != null && this.opportunity.RecordTypeId == null) {
			System.debug(System.LoggingLevel.INFO, 'setting opportunity record type...');
			this.opportunity.RecordTypeId = recordTypeId;
		}
		if (stageName != null && this.opportunity.stagename == null) {
			System.debug(System.LoggingLevel.INFO, 'setting opportunity stage name...');
			this.opportunity.stagename = stageName;
		}
		
		// retrieve pricebook entry information
		System.debug(System.LoggingLevel.INFO, 'retrieving pricebook entry data...');
		PricebookEntry pbe = [select id, Product2Id, Product2.Use_Product_Specific_Field_List__c, Product2.Service_Classification__c from PricebookEntry where id = :pricebookEntryId];
		System.debug(System.LoggingLevel.INFO, 'retrieved: ' + pbe);
		
		// fill in some opportunity line item data
		if (oli.PricebookEntryId == null) oli.PricebookEntryId = pricebookEntryId;
		
		// create a new line item dto
		System.debug(System.LoggingLevel.INFO, 'creating a new line item dto...');
		this.product = new dto_editLineItemProduct(opportunity, oli, pbe);
		System.debug(System.LoggingLevel.INFO, 'creation complete');
		
		// construct the JSON representation
		System.debug(System.LoggingLevel.INFO, 'constructing the JSON representation...');
		this.getJSONScript = 'window.getJSON = function() {\r\n';
		this.getJSONScript += '\tvar json = "{\\"Product\\": {";\r\n';
		if (oli.Id != null) {
			this.getJSONScript += '\tjson += "\\"Id\\": \\"' + oli.Id + '\\", ";\r\n';
		}
		this.getJSONScript += '\tjson += "\\"OpportunityRecordTypeId\\": \\"' + this.opportunity.RecordTypeId + '\\", ";\r\n';
		this.getJSONScript += '\tjson += "\\"OpportunityStageName\\": \\"' + this.opportunity.StageName + '\\", ";\r\n';
		this.getJSONScript += '\tjson += "\\"Pricebook2Id\\": \\"' + pricebookId + '\\", ";\r\n';
		this.getJSONScript += '\tjson += "\\"PricebookEntryId\\": \\"' + pricebookEntryId + '\\", ";\r\n';
		this.getJSONScript += '\tjson += "\\"Product2Id\\": \\"' + pbe.Product2Id + '\\", ";\r\n';
		this.getJSONScript += '\tjson += "\\"Fields\\": {";\r\n';
		for (Product_Field_List__c f : this.product.FieldList) {
			if (counter++ > 0) {
				this.getJSONScript += '\tjson += ", ";\r\n';
			}
			this.getJSONScript += '\tjson += "\\"' + f.Field_Name__c + '\\": \\"" + getFieldValue(' + f.Field_Name__c + ') + "\\"";\r\n';
		}
		this.getJSONScript += '\tjson += "}}}";\r\n\treturn json;\r\n}';
		System.debug(System.LoggingLevel.INFO, 'constructed JSON: ' + this.getJSONScript);
    	
    	
    	/*
		if (controller.getId() != null) {
			System.debug(System.LoggingLevel.INFO, 'adding fields to controller...');
			controller.addFields(util_globalUtilityMethods.getFieldsForObject('OpportunityLineItem'));
			System.debug(System.LoggingLevel.INFO, 'added fields: ' + util_globalUtilityMethods.getFieldsForObject('OpportunityLineItem'));
		}
		
		System.debug(System.LoggingLevel.INFO, 'obtaining handle to record...');
		System.debug('0');
		try {
			System.debug('0.5'); 
			oli = (OpportunityLineItem)controller.getRecord();
			//oli = new OpportunityLineItem();
			//oli = [select id from OpportunityLineItem Limit 1];
			System.debug('0.6');
		} catch (Exception ex) {
			System.debug('0.7');
			System.debug('An error occurred: ' + ex);
			return;
		}
		System.debug('1');
		if (oli.OpportunityId == null && opportunityId != null) oli.OpportunityId = opportunityId;
		System.debug('2');
		Integer counter = 0;
		System.debug(System.LoggingLevel.INFO, 'obtained handle to: ' + oli);
		
		// debug
		System.debug(System.LoggingLevel.INFO, 'received record type id: ' + recordTypeId);
		System.debug(System.LoggingLevel.INFO, 'received stage name: ' + stageName);
		System.debug(System.LoggingLevel.INFO, 'received pricebook id: ' + pricebookId);
		System.debug(System.LoggingLevel.INFO, 'received procebook entry id: ' + pricebookEntryId);
		System.debug(System.LoggingLevel.INFO, 'received opportunity id: ' + oli.OpportunityId);
		
		// get a handle on the received opportunity
		//System.debug(System.LoggingLevel.INFO, 'querying ' + util_globalUtilityMethods.getFieldsForObject('Opportunity').size() + ' fields on the associated opportunity: ' + util_globalUtilityMethods.getFieldsForObject('Opportunity')	);
		if (oli.OpportunityId != null)
			this.opportunity = Database.query('Select ' + util_globalUtilityMethods.joinStringSet(util_globalUtilityMethods.getFieldsForObject('Opportunity'), false) + ' From Opportunity Where Id = \'' + oli.OpportunityId + '\' Limit 1');
		else
			this.opportunity = new Opportunity();
		System.debug(System.LoggingLevel.INFO, 'retrieved: ' + this.opportunity);
		
		// determine if some opportunity info needs to be backfilled
		if (recordTypeId != null && this.opportunity.RecordTypeId == null) {
			System.debug(System.LoggingLevel.INFO, 'setting opportunity record type...');
			this.opportunity.RecordTypeId = recordTypeId;
		}
		if (stageName != null && this.opportunity.stagename == null) {
			System.debug(System.LoggingLevel.INFO, 'setting opportunity stage name...');
			this.opportunity.stagename = stageName;
		}
		
		// retrieve pricebook entry information
		System.debug(System.LoggingLevel.INFO, 'retrieving pricebook entry data...');
		PricebookEntry pbe = [select id, Product2Id, Product2.Use_Product_Specific_Field_List__c, Product2.Service_Classification__c from PricebookEntry where id = :pricebookEntryId];
		System.debug(System.LoggingLevel.INFO, 'retrieved: ' + pbe);
		
		// fill in some opportunity line item data
		//oli.PricebookEntryId = pricebookId;
		if (oli.PricebookEntryId == null) oli.PricebookEntryId = pricebookEntryId;
		
		// create a new line item dto
		System.debug(System.LoggingLevel.INFO, 'creating a new line item dto...');
		this.product = new dto_editLineItemProduct(opportunity, oli, pbe);
		System.debug(System.LoggingLevel.INFO, 'creation complete');
		
		// construct the JSON representation
		System.debug(System.LoggingLevel.INFO, 'constructing the JSON representation...');
		this.getJSONScript = 'window.getJSON = function() {\r\n';
		this.getJSONScript += '\tvar json = "{\\"Product\\": {";\r\n';
		if (oli.Id != null) {
			this.getJSONScript += '\tjson += "\\"Id\\": \\"' + oli.Id + '\\", ";\r\n';
		}
		this.getJSONScript += '\tjson += "\\"OpportunityRecordTypeId\\": \\"' + this.opportunity.RecordTypeId + '\\", ";\r\n';
		this.getJSONScript += '\tjson += "\\"OpportunityStageName\\": \\"' + this.opportunity.StageName + '\\", ";\r\n';
		this.getJSONScript += '\tjson += "\\"Pricebook2Id\\": \\"' + pricebookId + '\\", ";\r\n';
		this.getJSONScript += '\tjson += "\\"PricebookEntryId\\": \\"' + pricebookEntryId + '\\", ";\r\n';
		this.getJSONScript += '\tjson += "\\"Product2Id\\": \\"' + pbe.Product2Id + '\\", ";\r\n';
		this.getJSONScript += '\tjson += "\\"Fields\\": {";\r\n';
		for (Product_Field_List__c f : this.product.FieldList) {
			if (counter++ > 0) {
				this.getJSONScript += '\tjson += ", ";\r\n';
			}
			this.getJSONScript += '\tjson += "\\"' + f.Field_Name__c + '\\": \\"" + getFieldValue(' + f.Field_Name__c + ') + "\\"";\r\n';
		}
		this.getJSONScript += '\tjson += "}}}";\r\n\treturn json;\r\n}';
		System.debug(System.LoggingLevel.INFO, 'constructed JSON: ' + this.getJSONScript);
		
	*/
	}
	
	public Pagereference refreshMessages() {
		System.debug(System.LoggingLevel.INFO, '######### Being refreshMessages');
		
		System.debug(System.LoggingLevel.INFO, 'jsonMessagesString: ' + jsonMessagesString);
		
		if (jsonMessagesString == null || jsonMessagesString == '') {
			System.debug(System.LoggingLevel.INFO, 'jsonMessagesString was null, means we\'re simply clearing all messages.');
			return null;
		}
		
		JSONObject json = new JSONObject(new  JSONObject.JsonTokener(jsonMessagesString));
		
		JSONObject.value jsonErrors = json.getValue('Errors');
		System.debug(System.LoggingLevel.INFO, 'jsonErrors: ' + jsonErrors);
		
		for (JSONObject.value error : jsonErrors.values) {
			System.debug(System.LoggingLevel.INFO, 'error.obj: ' + error.obj);
			System.debug(System.LoggingLevel.INFO, 'error.obj(as string): ' + error.obj.valueToString());
			
			JSONObject theError = error.obj.getValue('Error').obj;
			
			String message = theError.getString('Message');
			System.debug(System.LoggingLevel.INFO, 'message: ' + message);
			
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, message));
		}
		
		System.debug(System.LoggingLevel.INFO, '######### End refreshMessages');
		
		return null;
	}
}