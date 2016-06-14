/* This class will be scheduled to run to perform daily Opportunity Maintenance 
 * Chintan Adhyapak, March 23, 2012
 */
global class sched_batch_OpportunityMaintenance implements Schedulable {
    global void execute(SchedulableContext sc) {
        batch_OpportunityMaintenance job = new batch_OpportunityMaintenance();
        database.executebatch(job);
    }
}