global class sched_batchOppOrgAcctIdProcessor implements Schedulable {
	global void execute(SchedulableContext sc) {
		batch_OppositeOrgAccountIdProcessor job = new batch_OppositeOrgAccountIdProcessor();
		database.executebatch(job);
	}
}