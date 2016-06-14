/* This class is called by the sched_batch_InternalAccountTeamMaintenance class to perform IAT Maintenance tasks
 * Chintan Adhyapak, April 15, 2014
 */
global class batch_InternalAccountTeamMaintenance implements Database.Batchable<sObject> {
	//declare class vars
  	global String query; //soql query for the main scope of the batch process
  	global Set<String> accountTeamMemberSet;
  	global integer count; //Number of AccountTeamMember Records inserted
  	global String notifyOnBatchComplete; //Email Recepient of the final notification email on batch complete 
	
	//Contructor
  	global batch_InternalAccountTeamMaintenance() {
  		//initialize
  		accountTeamMemberSet = new Set<String> ();
  		count = 0;
  		
  		//Read Custom Settings
  		Opportunity_Maintenance_Settings__c orgSettings = Opportunity_Maintenance_Settings__c.getInstance('Notify_On_Batch_Complete');
       	this.notifyOnBatchComplete = orgSettings.Value__c;
       	System.debug('CPA Notify_On_Batch_Complete = ' + notifyOnBatchComplete);
       	
       	orgSettings = Opportunity_Maintenance_Settings__c.getInstance('insertCount');
		orgSettings.Value__c = '0';
		try { update orgSettings; }
		catch (Exception e) { System.debug('CPA Error updating count in orgSetting in Constructor'); }
  		
  		//Read data from Internal Account Team
  		this.query = util_globalUtilityMethods.getSelectStarSOQL(Internal_Account_Team__c.getsObjectType());
		query += ' FROM Internal_Account_Team__c WHERE UserIsActive__c = TRUE';
		if (Test.isRunningTest()) {
    		this.query += ' LIMIT 200';
    	}
    	System.debug('CPA batch_InternalAccountTeamMaintenance instantiated with query: ' + query);
  	} //constructor
  	
  	
  	/** The START method */
	global Database.QueryLocator start(Database.BatchableContext BC){
		System.debug('CPA start BEGIN');
    	//kick off the job by obtaining a handle to a query locator
    	return Database.getQueryLocator(this.query);
  	} //start
  	
  	
  	/** EXECUTE - this method receives the results of the start() method in chunks, and processes the received records */ 
	global void execute(Database.BatchableContext BC, List<sObject> scope){
		System.debug('CPA execute BEGIN on a batch of ' + scope.size() + ' records and count: ' + count);
		
		//local vars
       	List<AccountTeamMember> accountTeamMemberList = new List<AccountTeamMember>();
       	List<AccountShare> existingAccountShareList = new List<AccountShare>();
       	List<Batch_Error__c> errorMessages = new List<Batch_Error__c>();
       	List<Id> accountIdList = new List<Id> ();
        List<Id> userIdList = new List<Id> ();
        List<Id> aList = new List<Id> ();
        List<Id> uList = new List<Id> ();
       	
       	//Main loop for this batch's scope
       	System.debug('CPA start of main loop');
       	//Read incoming account and user ids
       	for (sObject record : scope) {
       		Internal_Account_Team__c iat = (Internal_Account_Team__c)record;
       		aList.add(iat.Account__c);
       		uList.add(iat.User_ID__c);
       	}
       	
       	//Pull AccountTeamMember records for these accounts and users
       	for (AccountTeamMember atm : [Select AccountId, UserId From AccountTeamMember Where AccountId in :aList And UserId in :uList]) {
       		accountTeamMemberSet.add((String.valueOf(atm.AccountId)).subString(0,15) + (String.valueOf(atm.UserId)).subString(0,15));
       	}
       	System.debug('CPA accountTeamMemberSet size is: ' + accountTeamMemberSet.size() + '\n\nSet is: ' + accountTeamMemberSet);
       	
		//Now process
		for (sObject record : scope) {
			Internal_Account_Team__c iat = (Internal_Account_Team__c)record;
			//Does a record exist for this user in the AccountTeamMember table
			System.debug('CPA Looking for key: ' + (String.valueOf(iat.Account__c)).subString(0,15) + (String.valueOf(iat.User_ID__c)).subString(0,15));
			if (!accountTeamMemberSet.contains((String.valueOf(iat.Account__c)).subString(0,15) + (String.valueOf(iat.User_ID__c)).subString(0,15))) {
				//Create an AccountTeamMember record for this active user
				AccountTeamMember accountTeamMember = new AccountTeamMember();
                accountTeamMember.UserId = iat.User_ID__c;
                accountTeamMember.AccountId = iat.Account__c;
                accountTeamMember.TeamMemberRole='Account Team Member';
                
                //Add to List
                accountTeamMemberList.add(accountTeamMember);
                
                //Add Data to Lists
                accountIdList.add(iat.Account__c);
                userIdList.add(iat.User_ID__c);
			}
		} //for
		accountTeamMemberSet.clear();
        System.debug('CPA accountTeamMemberList size is ' + accountTeamMemberList.size() + '\n\nList is: ' + accountTeamMemberList);
        count += accountTeamMemberList.size();
        
        //Add Account Team Member Records
        if (accountTeamMemberList.size() > 0) {
        	try { insert accountTeamMemberList; }
            catch (Exception e) {
            	System.debug('CPA ERROR in inserting accountTeamMemberList - ' + e.getMessage());
            	Batch_Error__c insertError = new Batch_Error__c();
                insertError.Batch_Process__c = 'Internal Account Team Maintenance';
                insertError.Batch_Job_ID__c = BC.getJobId();
                insertError.Error_Date_Time__c = datetime.now();
                insertError.Error_Message__c = e.getMessage();
                insertError.Error_Status_Code__c  = e.getTypeName();
                errorMessages.add(insertError);
            }
		}
		
		//Adding a record to the Account Team automatically adds a record to the AccountShare table. Update those records in AccountShare table to modify access
        for(AccountShare accountShare : [Select Id, AccountId, UserOrGroupId, AccountAccessLevel, ContactAccessLevel, CaseAccessLevel, OpportunityAccessLevel From AccountShare where AccountId in :accountIdList and UserOrGroupId in :userIdList]) {
        	//Leave 'All' for Account Owners
            accountShare.AccountAccessLevel = accountShare.AccountAccessLevel.equalsIgnoreCase('All') ? 'All' : 'Edit';
            accountShare.CaseAccessLevel = 'Edit';
            accountShare.OpportunityAccessLevel = 'Edit';
            accountShare.ContactAccessLevel = 'Edit';
            existingAccountShareList.add(accountShare);
        }
        try { update existingAccountShareList; }
        catch (Exception e) {
        	System.debug('CPA ERROR in updating existingAccountShareList - ' + e.getMessage());
        	Batch_Error__c insertError = new Batch_Error__c();
           	insertError.Batch_Process__c = 'Internal Account Team Maintenance';
           	insertError.Batch_Job_ID__c = BC.getJobId();
           	insertError.Error_Date_Time__c = datetime.now();
           	insertError.Error_Message__c = e.getMessage();
            insertError.Error_Status_Code__c  = e.getTypeName();
            errorMessages.add(insertError);
        }

		//Insert error records
		if (!errorMessages.isEmpty()) {
			System.debug('CPA Inserting ' + errorMessages.size() + ' Error Records...');
			try {
				insert errorMessages;
			} catch (Exception e) {
				System.debug('CPA Caught Error in insert errorMessages ' + e);
			}
		}
       
       	System.debug('CPA execute END with count: ' + count);
		Opportunity_Maintenance_Settings__c orgSettings = Opportunity_Maintenance_Settings__c.getInstance('insertCount');
		integer eCount = Integer.valueOf(orgSettings.Value__c);
		count += eCount;
		orgSettings.Value__c = String.valueOf(count);
		try { update orgSettings; }
		catch (Exception e) { System.debug('CPA Error updating count in orgSetting'); }
	} //execute
	
	
	/** The FINISH method - Clean up routine to perform any final tasks before exiting */
    global void finish(Database.BatchableContext BC){
    	System.debug('CPA finish START');
    	AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,  TotalJobItems, CreatedBy.Email FROM AsyncApexJob where Id =:BC.getJobId()];
		List<Batch_Error__c> myErrors = [SELECT Id from Batch_Error__c where CreatedDate = TODAY];
		Opportunity_Maintenance_Settings__c orgSettings = Opportunity_Maintenance_Settings__c.getInstance('insertCount');
       	    
       	// Send an email notifying of job completion.
       	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
       	List<string> toAddresses = notifyOnBatchComplete.split(',',0);
       	mail.setToAddresses(toAddresses);
       	mail.setSubject('Scheduled Apex | Internal Account Team Maintenance | ' + a.Status);
       	String emailBody = 'The batch Apex job, batch_InternalAccountTeamMaintenance, processed ' + a.TotalJobItems +' batches with '+ a.NumberOfErrors + ' failures.<br>';
       	emailBody += 'Number of AccountTeamMember Records Inserted: ' + orgSettings.Value__c + '<br>';
       	emailBody += 'Number of Batch Error Records Created: ' + myErrors.size() + '<br>';
       	mail.setHtmlBody(emailBody);
       	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	       
       	System.debug('CPA finish END');
    } //finish

}