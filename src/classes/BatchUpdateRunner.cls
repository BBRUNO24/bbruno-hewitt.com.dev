global class BatchUpdateRunner implements Database.Batchable<sObject> {
	
	String query;
	String fieldApiName;
	String changeToValue;

	global BatchUpdateRunner(String query, String fieldApiName, String changeToValue) {
		this.query = query;
		this.fieldApiName = fieldApiName;
		this.changeToValue = changeToValue;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

  global void execute(Database.BatchableContext BC, List<SObject> scope) {
		for(SObject sobj : scope){
      sobj.put(fieldApiName, changeToValue);
    }
    List<Database.SaveResult> srs = Database.update(scope);
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}