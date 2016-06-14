global class sched_batchSalesTeamReconciler implements Schedulable {
	global void execute(SchedulableContext sc) {    
		batch_SalesTeamReconciler batchJob = new batch_SalesTeamReconciler();    
		Database.ExecuteBatch(batchJob);  
	}
}