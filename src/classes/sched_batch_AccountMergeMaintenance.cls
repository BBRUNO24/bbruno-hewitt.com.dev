/* This class will be scheduled to run to perform daily Account Merge Maintenance 
 * Chintan Adhyapak, January 28, 2015
 */
global class sched_batch_AccountMergeMaintenance implements Schedulable {
	//Execute method
	global void execute(SchedulableContext sc) {
        batch_AccountMergeMaintenance job = new batch_AccountMergeMaintenance();
        database.executebatch(job);
    }
}