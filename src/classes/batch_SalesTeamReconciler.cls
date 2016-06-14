global class batch_SalesTeamReconciler implements Database.Batchable<sObject> {
// modified Shimon Rothschild 12 July 16:05

    //declare class vars
    global String query             {get;set;}
    global LoggingLevel logLevel    {get;set;}
    
    //class contructor
    global batch_SalesTeamReconciler() {

        // default the logging level        
        this.logLevel = LoggingLevel.DEBUG;

        // debug
        System.debug(this.logLevel, '--------------------------- constructor BEGIN');

        // retrieve the last run date
        System.debug(this.logLevel, 'retrieving last run date...');
        Organizational_Defaults__c orgSettings = Organizational_Defaults__c.getInstance();
        System.debug(this.logLevel, 'retrieved: ' + orgSettings);
        
        // derive the appropriate query
        if (orgSettings.Sales_Team_Reconciler_Last_Run_Date__c == null) {
            this.query = 'select id, (select id, Credit_Recipient__c, Credit_Recipient__r.Corresponding_User_Id__c From Sales_Credits__r where Credit_Recipient__r.Corresponding_User_Id__c != null and Credit_Recipient__r.Corresponding_User_Id__r.IsActive = true), (Select Id, UserId From OpportunityTeamMembers) from Opportunity';
        } else {
        	String dateString = datetime.newInstance(orgSettings.Sales_Team_Reconciler_Last_Run_Date__c.year(), orgSettings.Sales_Team_Reconciler_Last_Run_Date__c.month(), orgSettings.Sales_Team_Reconciler_Last_Run_Date__c.day()).format('yyyy-MM-dd') + 'T00:00:00Z';
			System.debug(this.logLevel, 'Last run date: ' + dateString );
            this.query = 'select id, (select id, Credit_Recipient__c, Credit_Recipient__r.Corresponding_User_Id__c From Sales_Credits__r where Credit_Recipient__r.Corresponding_User_Id__c != null and Credit_Recipient__r.Corresponding_User_Id__r.IsActive = true and Credit_Recipient__r.Corresponding_User_Id__r.Activation_Date__c >= ' + dateString  + '), (Select Id, UserId From OpportunityTeamMembers) from Opportunity';
            System.debug(this.logLevel, 'Shimon Will execute this query: ' + this.query); 
        }
        System.debug(this.logLevel, 'derived query: ' + this.query);
        
        // debug        
        System.debug(this.logLevel, '--------------------------- constructor END');
    }
    
    // start
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        // debug    
        System.debug(this.logLevel, '--------------------------- start BEGIN');
        System.debug(this.logLevel, 'Executing query: ' + this.query); 
        
        // debug
        System.debug(this.logLevel, '--------------------------- start END');
        
        // kick off the job by obtaining a handle to a query locator
        return Database.getQueryLocator(this.query);
    }
    
    // this method receives the results of the start() method in chunks, and processed the received records 
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        //debug
        System.debug(this.logLevel, '--------------------------- execute BEGIN');
        System.debug(this.logLevel, 'executing on a batch of ' + scope.size() + ' records...');

        // declare local vars
        List <OpportunityTeamMember> recordsToCreate = new List <OpportunityTeamMember>(); 

        // iterate over each record and create corresponding sales team member entries
        System.debug(this.logLevel, 'iterate over each record and creating corresponding sales team member entries...');
        for (sObject record : scope) {
            
            // declare local vars
            Set <String> userIdsAlreadyOnTeam = new Set <String>();
            
            // cast the sObject to an account object
            Opportunity oppty = (Opportunity)record;
            System.debug('processing record: ' + oppty);
            
            // collect the distinct set of users already on the team
            System.debug('collecting already existing team members...');
            for (OpportunityTeamMember teamMember : oppty.OpportunityTeamMembers) {
                userIdsAlreadyOnTeam.add(teamMember.UserId);
            }
            System.debug('collected ' + userIdsAlreadyOnTeam.size() + ' members: ' + userIdsAlreadyOnTeam);
            
            // iterate over the collected sales credits for active users, looking for any that aren't already on the team
            System.debug('looking for sales credits that need a sales team entry...');
            for (Sales_Credit__c salesCredit : oppty.Sales_Credits__r) {
                if (!userIdsAlreadyOnTeam.contains(salesCredit.Credit_Recipient__r.Corresponding_User_Id__c)) {
                    System.debug('located user not already on team: ' + salesCredit);
                    
                    // if we have already collected 1000 records to create, send them off for insertion
                    if (recordsToCreate.size() >= 1000) {
                        System.debug('batch size reached, inserting collected team members...');
                        createTeamMembers(recordsToCreate);
                        recordsToCreate = new List <OpportunityTeamMember>(); 
                    }
                    
                    // add the new record to the collection
                    recordsToCreate.add(new OpportunityTeamMember(
                        OpportunityId = oppty.Id, 
                        UserId = salesCredit.Credit_Recipient__r.Corresponding_User_Id__c, 
                        TeamMemberRole = 'Sales Credit Recipient')
                    );                  
                }
            }
            System.debug('sales credit / sales team analysis complete');
        }
        
        // insert any remaining records
        System.debug('inserting collected team members...');
        createTeamMembers(recordsToCreate);
        recordsToCreate = new List <OpportunityTeamMember>(); 
        
        // debug
        System.debug(this.logLevel, '--------------------------- execute END');
    }
    
    // private helper method to wrap the insertion of new sales team members
    private void createTeamMembers(List <OpportunityTeamMember> teamMembersToCreate) {
        
        // debug
        System.debug(this.logLevel, '--------------------------- teamMembersToCreate BEGIN');
        System.debug(this.logLevel, 'received batch of ' + teamMembersToCreate.size() + ' records to insert...');
        
        // insert records
        if (!teamMembersToCreate.isEmpty()) {
            System.debug(this.logLevel, 'inserting records...');
            List <Database.Saveresult> results = Database.insert(teamMembersToCreate);
            System.debug(this.logLevel, 'inserting complete, checking results...');
            
            for (Database.saveresult sr : results) {
                if (!sr.isSuccess()) {
                    System.debug(LoggingLevel.ERROR, 'an error occurred while attempt to create a sales team member entry: ' + sr.getErrors()[0].getMessage());
                }
            }
            System.debug('result check complete');
        }
        
        // debug
        System.debug(this.logLevel, '--------------------------- teamMembersToCreate END');
    }

    // clean up routine to perform any final tasks before exiting
    global void finish(Database.BatchableContext BC){
        System.debug(this.logLevel, '--------------------------- finish BEGIN');
        
        // retrieve the last run date
        System.debug(this.logLevel, 'retrieving last run date...');
        Organizational_Defaults__c orgSettings = Organizational_Defaults__c.getInstance();
        System.debug(this.logLevel, 'retrieved: ' + orgSettings);
        
        // set the last run date to the current date
        System.debug(this.logLevel, 'updating last run date to current date: ' + Date.today());
        orgSettings.Sales_Team_Reconciler_Last_Run_Date__c = Date.today();
        Database.Saveresult sr = Database.update(orgSettings);
        System.debug(this.logLevel, 'update complete: ' + sr);
        
        // debug
        System.debug(this.logLevel, '--------------------------- finish END');
    }       

}