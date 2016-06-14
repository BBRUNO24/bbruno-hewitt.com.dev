public class blogic_OpportunityUIConfiguration {

	public static void validateFieldNames(List <Product_Field_List__c> fields) {
		
		// debug
		logMessage('validateFieldNames START');
		
		// declare local vars
		Map <String, String> sourceObjects = new Map <String, String>();
		List <String> fieldNames = new List <String>();
		Map <String, Schema.SObjectField> opportunityDescribeResults = new Map<String, Schema.SObjectField>();
		Map <String, Schema.SObjectField> opportunityLineItemDescribeResults = new Map<String, Schema.SObjectField>();
		Map <String, Schema.SObjectField> pricebookEntryDescribeResults = new Map<String, Schema.SObjectField>();
		Map <String, Schema.SObjectField> productDescribeResults = new Map<String, Schema.SObjectField>(); 
		Schema.SObjectField fieldDescribe = null;
		Map <String, Map <String, Schema.SObjectField>> describeResultsByObject = new Map <String, Map <String, Schema.SObjectField>>();
		
		// group the inbound fields by object
		logMessage('collecting distinct set of source objects...');
		for (Product_Field_List__c field : fields) {
			sourceObjects.put(field.Source_Object__c.toLowerCase(), field.Source_Object__c.toLowerCase());
		}
		logMessage('collection complete.  identified ' + String.valueOf(sourceObjects.keySet().size()) + ' distinct objects: ' + sourceObjects.keySet());

		// perform describes as necessary
		logMessage('determining what objects needs to be described...');
		if (sourceObjects.containsKey('opportunity')) { 
			logMessage('describing opportunity...');
			describeResultsByObject.put('opportunity', Schema.SObjectType.Opportunity.fields.getMap());
		}
		if (sourceObjects.containsKey('opportunitylineitem')) {
			logMessage('describing opportunity line item...');
			describeResultsByObject.put('opportunitylineitem', Schema.SObjectType.OpportunityLineItem.fields.getMap());
		}
		if (sourceObjects.containsKey('pricebookentry')) {
			logMessage('describing price book entry...');
			describeResultsByObject.put('pricebookentry', Schema.SObjectType.PricebookEntry.fields.getMap());
		}
		if (sourceObjects.containsKey('product')) {
			logMessage('describing product...');
			describeResultsByObject.put('product', Schema.SObjectType.Product2.fields.getMap());
		}
		
		// re-iterate over the lists and scrub the received field values against actuals from the describe
		logMessage('scrubbing inbound fields against describe info...');
		for (Product_Field_List__c field : fields) {
			
			Map <String, Schema.SObjectField> describeInfo  = null;
			
			logMessage('processing field: ' + field.Source_Object__c.toLowerCase() + '.' + field.Field_Name__c.toLowerCase());
			
			if (describeResultsByObject.containsKey(field.Source_Object__c.toLowerCase())) {
				// get a handle on the describe info
				describeInfo = describeResultsByObject.get(field.Source_Object__c.toLowerCase());
				
				if (!describeInfo.containsKey(field.Field_Name__c.toLowerCase())) {
					logMessage('field does not exist!');
					field.addError('The field specified [' + field.Source_Object__c.toLowerCase() + '.' + field.Field_Name__c.toLowerCase() + '] does not exist.');
				} else {
					logMessage('field exists, scrubbing case sensitivity...');
					fieldDescribe = describeInfo.get(field.Field_Name__c.toLowerCase());
					field.Field_Name__c = fieldDescribe.getDescribe().getName();
				}
			} else {
				logMessage('object does not exist!');
				field.addError('The source object specified [' + field.Source_Object__c.toLowerCase() + '] does not exist.');
			}
		}
		
		// debug
		logMessage('validateFieldNames END');
	} 
	
	public static void deriveUniqueIdentifiers(List <Product_Field_List__c> fields) {

		// debug
		logMessage('deriveUniqueIdentifiers START');
		
		for (Product_Field_List__c field : fields) {
			field.UniqueId__c = field.Opportunity_Record_Type__c + field.Opportunity_Stage__c + field.Product_Service_Classification__c + field.Product_Id__c + field.RecordTypeId + field.Source_Object__c + field.Field_Name__c;
		}
		
		// debug
		logMessage('deriveUniqueIdentifiers END');
	}
	
	private static void logMessage(String msg) {
		System.debug(LoggingLevel.INFO, msg);
	}
}