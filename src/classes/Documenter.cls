global class Documenter implements Database.Batchable<sObject> {
	
	String query = 'SELECT Id, API__c, Name FROM Documentation_Object__c';
	
	global Documenter() {
		
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

  global void execute(Database.BatchableContext BC, List<Documentation_Object__c> scope) {
		for(Documentation_Object__c doc : scope){
			Documentation.documentFields(doc);
		}
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}