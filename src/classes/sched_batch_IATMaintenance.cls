/* This class will be scheduled to run to perform daily Internal Account Team Maintenance 
 * Chintan Adhyapak, April 15, 2014
 */
global class sched_batch_IATMaintenance implements Schedulable{
	//Execute method
	global void execute(SchedulableContext sc) {
        batch_InternalAccountTeamMaintenance job = new batch_InternalAccountTeamMaintenance();
        database.executebatch(job);
    }
}