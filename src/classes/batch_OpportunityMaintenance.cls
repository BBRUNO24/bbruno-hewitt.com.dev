/* This class is called by the sched_batch_OpportunityMaintenance class to perform Opportunity
 * Maintenance tasks
 * Chintan Adhyapak, March 23, 2012
 * v2 - Modifications for Case 11387 - CPA, May 21, 2012
 */
global class batch_OpportunityMaintenance implements Database.Batchable<sObject> {
	//declare class vars
  	global String query; //soql query for the main scope of the batch process
  	global LoggingLevel logLevel; //log level for all system.debug statements
  	global integer daysAhead; //the number of days ahead for CloseDate that WF1 Notification 1 should fire
  	global integer daysBehind; //the number of days behind for LastModifiedDate that WF3 Notification 1 should fire
  	global integer task1Notify2; //the Number of days opp is overdue to trigger Task 1 Notification 2
  	global integer task1Notify3; //the Number of days opp is overdue to trigger Task 1 Notification 3 
  	global integer task1Notify4; //the Number of days opp is overdue to trigger Task 1 Notification 4 
  	global integer task2Notify1; //the Number of days opp is overdue to trigger Task 2 Notification 1  
  	global integer task2Notify2; //the Number of days opp is overdue to trigger Task 2 Notification 2
  	global integer task2Notify3; //the Number of days opp is overdue to trigger Task 2 Notification 3
  	global integer task3Notify1; //the Number of days opp is untouched to trigger Task 3 Notification 1
  	global integer task3Notify2; //the Number of days opp is untouched to trigger Task 3 Notification 2
  	global integer closedOppCount; //the number of opportunities closed on each run
  	global String emailRecepient; //Determines if notification emails should go to Opp Owners or someone else defined in the custom setting
  	global String notifyOnBatchComplete; //Email Recepient of the final notification email on batch complete 
  	global static String taskOne = 'Open Pipeline Maintenance';
    global static String taskTwo = 'Closed Won Maintenance';
    global static String taskThree = 'Last Modified Date Maintenance';
    global boolean runQuery1; //Should the first part of the query be run or not
    global boolean runQuery2; //Should the second part of the query be run or not
    global boolean runQuery3; //Should the third part of the query be run or not
  
  	//Contructor
  	global batch_OpportunityMaintenance() {
  		//Read Custom Settings
       	Opportunity_Maintenance_Settings__c orgSettings = Opportunity_Maintenance_Settings__c.getInstance('Days_Ahead');
       	daysAhead = Integer.valueOf(orgSettings.Value__c);
       	System.debug('CPA Days_Ahead = ' + daysAhead);
  		DateTime targetDateAhead = DateTime.now().addDays(daysAhead);
  		String strTargetDateAhead = targetDateAhead.format('yyyy-MM-dd');
  		
  		orgSettings = Opportunity_Maintenance_Settings__c.getInstance('Days_Behind');
  		daysBehind = Integer.valueOf(orgSettings.Value__c);
       	System.debug('CPA Days_Behind = ' + daysBehind);
  		//DateTime targetDateBehind = DateTime.now().addDays(daysBehind);
  		//String strTargetDateBehind = targetDateBehind.format('yyyy-MM-dd');
  		
  		orgSettings = Opportunity_Maintenance_Settings__c.getInstance('Query_1');
  		String query1 = orgSettings.Value__c;
  		System.debug('CPA Query_1 = ' + query1);
  		
  		orgSettings = Opportunity_Maintenance_Settings__c.getInstance('Query_2');
  		String query2 = orgSettings.Value__c;
  		System.debug('CPA Query_2 = ' + query2);
  		
  		orgSettings = Opportunity_Maintenance_Settings__c.getInstance('Query_3');
  		String query3 = orgSettings.Value__c;
  		System.debug('CPA Query_3 = ' + query3);
  		
  		orgSettings = Opportunity_Maintenance_Settings__c.getInstance('Run_Query1');
       	this.runQuery1 = (orgSettings.Value__c.equalsIgnoreCase('TRUE') ? true : false);
       	System.debug('CPA Run_Query1 = ' + runQuery1);
  		
  		orgSettings = Opportunity_Maintenance_Settings__c.getInstance('Run_Query2');
       	this.runQuery2 = (orgSettings.Value__c.equalsIgnoreCase('TRUE') ? true : false);
       	System.debug('CPA Run_Query2 = ' + runQuery2);
       	
       	orgSettings = Opportunity_Maintenance_Settings__c.getInstance('Run_Query3');
       	this.runQuery3 = (orgSettings.Value__c.equalsIgnoreCase('TRUE') ? true : false);
       	System.debug('CPA Run_Query3 = ' + runQuery3);
  		
    	this.query = util_globalUtilityMethods.getSelectStarSOQL(Opportunity.getsObjectType()) +
			',LastModifiedDate,Owner.Name,Owner.Email,Owner.IsActive,Account.Name,Account.SDO_Billing_Country_Name__c FROM Opportunity '+
			'WHERE ';
		if (this.runQuery1) {
			query += '(' + query1 + ' ' + strTargetDateAhead + ') ';
		}
		if (runQuery1 && runQuery2) {
			query += 'Or (' + query2 + ') ';
		} else if (runQuery2) {
			query += '(' + query2 + ')';
		}
		if ((runQuery1 || runQuery2) && runQuery3) {
			query += 'Or (' + query3 + ' LAST_N_DAYS:' + daysBehind + ') ';
		} else if (runQuery3) {
			query += '(' + query3 + ' LAST_N_DAYS:' + daysBehind + ') ';
		}
		//query += 'ORDER BY CloseDate, LastModifiedDate';
		query += 'ORDER BY LastModifiedDate Desc';
    	System.debug('CPA Final Query = ' + query);
    	
    	orgSettings = Opportunity_Maintenance_Settings__c.getInstance('Task1_Notify2');
       	this.task1Notify2 = Integer.valueOf(orgSettings.Value__c);
       	System.debug('CPA Task1_Notify2 = ' + task1Notify2);
       	
       	orgSettings = Opportunity_Maintenance_Settings__c.getInstance('Task1_Notify3');
       	this.task1Notify3 = Integer.valueOf(orgSettings.Value__c);
       	System.debug('CPA Task1_Notify3 = ' + task1Notify3);
       	
       	orgSettings = Opportunity_Maintenance_Settings__c.getInstance('Task1_Notify4');
       	this.task1Notify4 = Integer.valueOf(orgSettings.Value__c);
       	System.debug('CPA Task1_Notify4 = ' + task1Notify4);
       	
       	orgSettings = Opportunity_Maintenance_Settings__c.getInstance('Task2_Notify1');
       	this.task2Notify1 = Integer.valueOf(orgSettings.Value__c);
       	System.debug('CPA Task2_Notify1 = ' + task2Notify1);
       	
       	orgSettings = Opportunity_Maintenance_Settings__c.getInstance('Task2_Notify2');
       	this.task2Notify2 = Integer.valueOf(orgSettings.Value__c);
       	System.debug('CPA Task2_Notify2 = ' + task2Notify2);
       	
       	orgSettings = Opportunity_Maintenance_Settings__c.getInstance('Task2_Notify3');
       	this.task2Notify3 = Integer.valueOf(orgSettings.Value__c);
       	System.debug('CPA Task2_Notify3 = ' + task2Notify3);
       	
       	orgSettings = Opportunity_Maintenance_Settings__c.getInstance('Task3_Notify1');
       	this.task3Notify1 = Integer.valueOf(orgSettings.Value__c);
       	System.debug('CPA Task3_Notify1 = ' + task3Notify1);
       	
       	orgSettings = Opportunity_Maintenance_Settings__c.getInstance('Task3_Notify2');
       	this.task3Notify2 = Integer.valueOf(orgSettings.Value__c);
       	System.debug('CPA Task3_Notify2 = ' + task3Notify2);
       	
       	orgSettings = Opportunity_Maintenance_Settings__c.getInstance('Email_Recepient');
       	this.emailRecepient = orgSettings.Value__c;
       	System.debug('CPA Email_Recepient = ' + emailRecepient);
       	
       	orgSettings = Opportunity_Maintenance_Settings__c.getInstance('Notify_On_Batch_Complete');
       	this.notifyOnBatchComplete = orgSettings.Value__c;
       	System.debug('CPA Notify_On_Batch_Complete = ' + notifyOnBatchComplete);
       	
    	if (Test.isRunningTest()) {
    		this.query += ' LIMIT 200';
    	}
    	this.logLevel = LoggingLevel.DEBUG;
    	this.closedOppCount = 0;
    	System.debug(this.logLevel, 'CPA batch_OpportunityMaintenance instantiated');
	} //constructor


  	/** The START method */
	global Database.QueryLocator start(Database.BatchableContext BC){
		System.debug(this.logLevel, 'CPA start BEGIN');
       	System.debug(this.logLevel, 'CPA Executing query: ' + this.query); 
    
    	//kick off the job by obtaining a handle to a query locator
    	return Database.getQueryLocator(this.query);
  	} //start


  	/** execute - this method receives the results of the start() method in chunks, and processes the received records */ 
	global void execute(Database.BatchableContext BC, List<sObject> scope){
		//local vars
       	System.debug(this.logLevel, 'CPA execute BEGIN');
       	System.debug(this.logLevel, 'CPA executing on a batch of ' + scope.size() + ' records...');
       	List<Messaging.SingleEmailMessage> messagesToSend = new List<Messaging.SingleEmailMessage>();
       	List<Opportunity_Maintenance_Task__c> tasksToCreate = new List<Opportunity_Maintenance_Task__c>();
       	List<Opportunity> oppsToUpdate = new List<Opportunity>();
       	List<Batch_Error__c> errorMessages = new List<Batch_Error__c>();
       	boolean sent = false;
       	Competitor__c comp = null;
       	
       	//get all related child Opportunity_Maintenance_Task records in scope
       	String soqlChildQuery = util_globalUtilityMethods.getSelectStarSOQL(Opportunity_Maintenance_Task__c.getsObjectType()) +
        	' FROM Opportunity_Maintenance_Task__c WHERE Opportunity__c IN :scope';
       	List<Opportunity_Maintenance_Task__c> listAllTasks = Database.query(soqlChildQuery);
       
       	//place all related child Opportunity_Maintenance_Task records into a Map by Foreign Key
       	Map<Id, List<Opportunity_Maintenance_Task__c>> mapTasksByFK = new Map<Id, List<Opportunity_Maintenance_Task__c>>();
       	for (Opportunity_Maintenance_Task__c task : listAllTasks) {
         	if (mapTasksByFK.get(task.Opportunity__c) == null) {
         	 	mapTasksByFK.put(task.Opportunity__c, new List<Opportunity_Maintenance_Task__c>());
         	}
         	mapTasksByFK.get(task.Opportunity__c).add(task);
       	}	

       	//Main loop for this batch's scope
       	System.debug('CPA start of main loop');
		for (sObject record : scope) {
        	//cast the sObject to an Opportunity
        	Opportunity myOpp = (Opportunity)record;
        	System.debug('CPA Processing Opp ID: ' + myOpp.Opportunity_ID_18_digit_Reference__c + ' Expected Close Date: ' + myOpp.CloseDate + ' LastModifiedDate: ' + myOpp.LastModifiedDate);
        	
			//Task 1, Notification 1
        	if (runQuery1 && !myOpp.IsClosed && myOpp.CloseDate > Date.today() && myOpp.CloseDate < Date.today().addDays(daysAhead)) {
        		//Check if Notification 1 has already been sent for existing expected close date
        		sent = hasTaskNotificationBeenSent(taskOne, '1', myOpp.CloseDate, mapTasksByFK.get(myOpp.Id));
        		if (!sent) {
        			//Create Email
        			System.debug('CPA Generating Type 1 Email Notification 1 for: ' + myOpp.Opportunity_ID_18_digit_Reference__c + ' Expected Close Date: ' + myOpp.CloseDate + ' Opp Owner Email: ' + myOpp.Owner.Email);
            		Messaging.SingleEmailMessage mail = getMail(myOpp, 'One');
            		messagesToSend.add(mail);
            	
            		//Create Opportunity Maintenance Task
            		System.debug('CPA Creating Type 1 Opportunity Maintenance Task record for Notification 1: ' + myOpp.Opportunity_ID_18_digit_Reference__c);
            		Opportunity_Maintenance_Task__c myTask = getTask(myOpp, taskOne, '1');
            		tasksToCreate.add(myTask);
        		}
        	} else if (runQuery1 && !myOpp.IsClosed && myOpp.CloseDate > Date.today().addDays(task1Notify2) &&
        			myOpp.CloseDate < Date.today()) {
        		//Check if Notification 2 has already been sent for existing expected close date
        		sent = hasTaskNotificationBeenSent(taskOne, '2', myOpp.CloseDate, mapTasksByFK.get(myOpp.Id));
        		if (!sent) {
        			//Create Email
        			System.debug('CPA Generating Type 1 Email Notification 2 for: ' + myOpp.Opportunity_ID_18_digit_Reference__c + ' Expected Close Date: ' + myOpp.CloseDate + ' Opp Owner Email: ' + myOpp.Owner.Email);
        			Messaging.SingleEmailMessage mail = getMail(myOpp, 'One');
            		messagesToSend.add(mail);
            	
            		//Create Opportunity Maintenance Task
            		System.debug('CPA Creating Type 1 Opportunity Maintenance Task record for Notification 2: ' + myOpp.Opportunity_ID_18_digit_Reference__c);
            		Opportunity_Maintenance_Task__c myTask = getTask(myOpp, taskOne, '2');
            		tasksToCreate.add(myTask);
        		}
        	} else if (runQuery1 && !myOpp.IsClosed && myOpp.CloseDate > Date.today().addDays(task1Notify3) 
        		&& myOpp.CloseDate <= Date.today().addDays(task1Notify2)) {
        		//Check if Notification 3 has already been sent for existing expected close date
        		sent = hasTaskNotificationBeenSent(taskOne, '3', myOpp.CloseDate, mapTasksByFK.get(myOpp.Id));
        		if (!sent) {
        			//Create Email
        			System.debug('CPA Generating Type 1 Email Notification 3 for: ' + myOpp.Opportunity_ID_18_digit_Reference__c + ' Expected Close Date: ' + myOpp.CloseDate + ' Opp Owner Email: ' + myOpp.Owner.Email);
        			Messaging.SingleEmailMessage mail = getMail(myOpp, 'One');
            		messagesToSend.add(mail);
            	
            		//Create Opportunity Maintenance Task
            		System.debug('CPA Creating Type 1 Opportunity Maintenance Task record for Notification 3: ' + myOpp.Opportunity_ID_18_digit_Reference__c);
            		Opportunity_Maintenance_Task__c myTask = getTask(myOpp, taskOne, '3');
            		tasksToCreate.add(myTask);
        		}
        	} else if (runQuery1 && !myOpp.IsClosed && myOpp.CloseDate > Date.today().addDays(task1Notify4) &&
        			myOpp.CloseDate <= Date.today().addDays(task1Notify3)) {
        		//Check if Notification 4 has already been sent for existing expected close date
        		sent = hasTaskNotificationBeenSent(taskOne, '4', myOpp.CloseDate, mapTasksByFK.get(myOpp.Id));
        		if (!sent) {
        			//Create Email
        			System.debug('CPA Generating Type 1 Email Notification 4 for: ' + myOpp.Opportunity_ID_18_digit_Reference__c + ' Expected Close Date: ' + myOpp.CloseDate + ' Opp Owner Email: ' + myOpp.Owner.Email);
        			Messaging.SingleEmailMessage mail = getMail(myOpp, 'One');
            		messagesToSend.add(mail);
            	
            		//Create Opportunity Maintenance Task
            		System.debug('CPA Creating Type 1 Opportunity Maintenance Task record for Notification 4: ' + myOpp.Opportunity_ID_18_digit_Reference__c);
            		Opportunity_Maintenance_Task__c myTask = getTask(myOpp, taskOne, '4');
            		tasksToCreate.add(myTask);
        		}
        	} else if(runQuery1 && !myOpp.IsClosed && myOpp.CloseDate <= Date.today().addDays(task1Notify4)){
        		//Create Opportunity Maintenance Task
            	System.debug('CPA Creating Type 1 Opportunity Maintenance Task record for Closing Opp: ' + myOpp.Opportunity_ID_18_digit_Reference__c);
            	Opportunity_Maintenance_Task__c myTask = getTask(myOpp, taskOne, 'action');
            	tasksToCreate.add(myTask);
            	
            	//Update Opp
            	System.debug('CPA Closing Opportunity: ' + myOpp.Opportunity_ID_18_digit_Reference__c + ' Expected Close Date: ' + myOpp.CloseDate);
        		if (comp == null) { comp = [Select Id from Competitor__c where  Name = 'Competitor Not Specified' Limit 1]; }
        		if (myOpp.Competitor__c == null) { myOpp.Competitor__c = 'Competitor Not Specified'; }
        		if (myOpp.Chosen_Provider_Reference__c == null) { myOpp.Chosen_Provider_Reference__c = comp.Id; }
        		if (myOpp.Current_Provider_Reference__c == null) { myOpp.Current_Provider_reference__c = comp.Id; }
        		if (myOpp.Reason_Won_or_Lost__c == null) { myOpp.Reason_Won_or_Lost__c = 'Aon Hewitt declined to pursue project'; }
        		myOpp.Probability = 0;
        		myOpp.StageName = 'Closed Lost';
				oppsToUpdate.add(myOpp);
				this.closedOppCount++;
        	} else if(runQuery2 && myOpp.IsClosed && myOpp.CloseDate > Date.today().addDays(task2Notify1)) {
				//Check if Notification 1 has already been sent for existing expected close date
        		sent = hasTaskNotificationBeenSent(taskTwo, '1', myOpp.CloseDate, mapTasksByFK.get(myOpp.Id));
        		if (!sent) {
        			//Create Email
        			System.debug('CPA Generating Type 2 Email Notification 1 for: ' + myOpp.Opportunity_ID_18_digit_Reference__c + ' Expected Close Date: ' + myOpp.CloseDate + ' Opp Owner Email: ' + myOpp.Owner.Email);
            		Messaging.SingleEmailMessage mail = getMail(myOpp, 'Two');
            		messagesToSend.add(mail);
            	
            		//Create Opportunity Maintenance Task
            		System.debug('CPA Creating Type 2 Opportunity Maintenance Task record for Notification 1: ' + myOpp.Opportunity_ID_18_digit_Reference__c);
            		Opportunity_Maintenance_Task__c myTask = getTask(myOpp, taskTwo, '1');
            		tasksToCreate.add(myTask);
        		}
        	} else if(runQuery2 && myOpp.IsClosed && myOpp.CloseDate > Date.today().addDays(task2Notify2)) {
				//Check if Notification 2 has already been sent for existing expected close date
        		sent = hasTaskNotificationBeenSent(taskTwo, '2', myOpp.CloseDate, mapTasksByFK.get(myOpp.Id));
        		if (!sent) {
        			//Create Email
        			System.debug('CPA Generating Type 2 Email Notification 1 for: ' + myOpp.Opportunity_ID_18_digit_Reference__c + ' Expected Close Date: ' + myOpp.CloseDate + ' Opp Owner Email: ' + myOpp.Owner.Email);
            		Messaging.SingleEmailMessage mail = getMail(myOpp, 'Two');
            		messagesToSend.add(mail);
            	
            		//Create Opportunity Maintenance Task
            		System.debug('CPA Creating Type 2 Opportunity Maintenance Task record for Notification 2: ' + myOpp.Opportunity_ID_18_digit_Reference__c);
            		Opportunity_Maintenance_Task__c myTask = getTask(myOpp, taskTwo, '2');
            		tasksToCreate.add(myTask);
        		}
        	} else if(runQuery2 && myOpp.IsClosed && myOpp.CloseDate > Date.today().addDays(task2Notify3)) {
				//Check if Notification 3 has already been sent for existing expected close date
        		sent = hasTaskNotificationBeenSent(taskTwo, '3', myOpp.CloseDate, mapTasksByFK.get(myOpp.Id));
        		if (!sent) {
        			//Create Email
        			System.debug('CPA Generating Type 2 Email Notification 3 for: ' + myOpp.Opportunity_ID_18_digit_Reference__c + ' Expected Close Date: ' + myOpp.CloseDate + ' Opp Owner Email: ' + myOpp.Owner.Email);
            		Messaging.SingleEmailMessage mail = getMail(myOpp, 'Two');
            		messagesToSend.add(mail);
            	
            		//Create Opportunity Maintenance Task
            		System.debug('CPA Creating Type 2 Opportunity Maintenance Task record for Notification 3: ' + myOpp.Opportunity_ID_18_digit_Reference__c);
            		Opportunity_Maintenance_Task__c myTask = getTask(myOpp, taskTwo, '3');
            		tasksToCreate.add(myTask);
        		}
        	} else if (runQuery2 && myOpp.IsClosed){
				//Create Opportunity Maintenance Task
            	System.debug('CPA Creating Type 2 Opportunity Maintenance Task record for Reopening Opp: ' + myOpp.Opportunity_ID_18_digit_Reference__c);
            	Opportunity_Maintenance_Task__c myTask = getTask(myOpp, taskTwo, 'action');
            	tasksToCreate.add(myTask);
            	
            	//Update Opp
            	System.debug('CPA Reopening Opportunity: ' + myOpp.Opportunity_ID_18_digit_Reference__c + ' Expected Close Date: ' + myOpp.CloseDate);
        		myOpp.Probability = 75;
        		myOpp.StageName = 'Negotiate';
				oppsToUpdate.add(myOpp);
				this.closedOppCount++;
        	} else if(runQuery3 && !myOpp.IsClosed && myOpp.LastModifiedDate > Datetime.now().addDays(task3Notify1) &&
        			myOpp.LastActivityDate < Datetime.now().addDays(daysBehind)) {
				//Check if Notification 1 has already been sent for existing Last Modified Date
				Date modifiedDate = Date.newInstance(myOpp.LastModifiedDate.year(), myOpp.LastModifiedDate.month(), myOpp.LastModifiedDate.day());
        		sent = hasTaskNotificationBeenSent(taskThree, '1', modifiedDate, mapTasksByFK.get(myOpp.Id));
        		if (!sent) {
        			//Create Email
        			System.debug('CPA Generating Type 3 Email Notification 1 for: ' + myOpp.Opportunity_ID_18_digit_Reference__c + ' Last Modified Date: ' + myOpp.LastModifiedDate + ' Opp Owner Email: ' + myOpp.Owner.Email);
            		Messaging.SingleEmailMessage mail = getMail(myOpp, 'Three');
            		messagesToSend.add(mail);
            	
            		//Create Opportunity Maintenance Task
            		System.debug('CPA Creating Type 3 Opportunity Maintenance Task record for Notification 1: ' + myOpp.Opportunity_ID_18_digit_Reference__c);
            		Opportunity_Maintenance_Task__c myTask = getTask(myOpp, taskThree, '1');
            		tasksToCreate.add(myTask);
        		}
        	} else if(runQuery3 && !myOpp.IsClosed && myOpp.LastModifiedDate > Datetime.now().addDays(task3Notify2) && 
        			myOpp.LastModifiedDate <= Datetime.now().addDays(task3Notify1)) {
				//Check if Notification 2 has already been sent for existing Last Modified Date
				Date modifiedDate = Date.newInstance(myOpp.LastModifiedDate.year(), myOpp.LastModifiedDate.month(), myOpp.LastModifiedDate.day());
        		sent = hasTaskNotificationBeenSent(taskThree, '2', modifiedDate, mapTasksByFK.get(myOpp.Id));
        		if (!sent) {
        			//Create Email
        			System.debug('CPA Generating Type 3 Email Notification 2 for: ' + myOpp.Opportunity_ID_18_digit_Reference__c + ' Last Modified Date: ' + myOpp.LastModifiedDate + ' Opp Owner Email: ' + myOpp.Owner.Email);
            		Messaging.SingleEmailMessage mail = getMail(myOpp, 'Three');
            		messagesToSend.add(mail);
            	
            		//Create Opportunity Maintenance Task
            		System.debug('CPA Creating Type 3 Opportunity Maintenance Task record for Notification 2: ' + myOpp.Opportunity_ID_18_digit_Reference__c);
            		Opportunity_Maintenance_Task__c myTask = getTask(myOpp, taskThree, '2');
            		tasksToCreate.add(myTask);
        		}
        	} else if(runQuery3 && !myOpp.IsClosed && myOpp.LastModifiedDate <= Datetime.now().addDays(task3Notify2)){
        		//Create Opportunity Maintenance Task
            	System.debug('CPA Creating Type 3 Opportunity Maintenance Task record for Closing Opp: ' + myOpp.Opportunity_ID_18_digit_Reference__c);
            	Opportunity_Maintenance_Task__c myTask = getTask(myOpp, taskThree, 'action');
            	tasksToCreate.add(myTask);
            	
            	//Update Opp
            	System.debug('CPA Closing Opportunity: ' + myOpp.Opportunity_ID_18_digit_Reference__c + ' LastModifiedDate: ' + myOpp.LastModifiedDate);
        		if (comp == null) { comp = [Select Id from Competitor__c where  Name = 'Competitor Not Specified' Limit 1]; }
        		if (myOpp.Competitor__c == null) { myOpp.Competitor__c = 'Competitor Not Specified'; }
        		if (myOpp.Chosen_Provider_Reference__c == null) { myOpp.Chosen_Provider_Reference__c = comp.Id; }
        		if (myOpp.Current_Provider_Reference__c == null) { myOpp.Current_Provider_reference__c = comp.Id; }
        		if (myOpp.Reason_Won_or_Lost__c == null) { myOpp.Reason_Won_or_Lost__c = 'Aon Hewitt declined to pursue project'; }
        		myOpp.Probability = 0;
        		myOpp.StageName = 'Closed Lost';
        		myopp.ForecastCategoryName = 'Omitted';
				oppsToUpdate.add(myOpp);
				this.closedOppCount++;
        	}
		} //end main for loop
      
		//insert Maintenance Tasks
      	if (!tasksToCreate.isEmpty()) {
      		try {
	      		System.debug('CPA Inserting ' + tasksToCreate.size() + ' Opportunity Maintenance Tasks...');
      			insert tasksToCreate;
      		} catch (Exception e) {
		      	System.debug('CPA Caught Error in insert tasksToCreate ' + e);
		      	Batch_Error__c insertError = new Batch_Error__c();
                insertError.Batch_Process__c = 'Opportunity Close Date Maintenance Notification Task';
                insertError.Batch_Job_ID__c = BC.getJobId();
                insertError.Error_Date_Time__c = datetime.now();
                insertError.Error_Message__c = e.getMessage();
                insertError.Error_Status_Code__c  = e.getTypeName();
                //insertError.Error_Target_Record_ID__c = myOpp.Opportunity_ID_18_digit_Reference__c;
                errorMessages.add(insertError);
      		}
      	}
     
		//send Email Notifications
		if (!messagesToSend.isEmpty()) {
        	System.debug('CPA Sending ' + messagesToSend.size() + ' Emails...');
        	List<Messaging.SendEmailResult> emailResults = Messaging.SendEmail(messagesToSend, false);
        
        	//write errors
        	System.debug('CPA Checking for and writing Email Errors...');
        	for (Messaging.SendEmailResult emailResult: emailResults) {
	            if (!emailResult.isSuccess()) {
               		List<Messaging.SendEmailError> emailErrors = emailResult.getErrors();
               		for (Messaging.SendEmailError emailError : emailErrors){
                   		Batch_Error__c sendError = new Batch_Error__c();
                   		sendError.Batch_Process__c = 'Opportunity Close Date Maintenance Notification Email';
                   		sendError.Batch_Job_ID__c = BC.getJobId();
                   		sendError.Error_Date_Time__c = datetime.now();
                   		sendError.Error_Message__c = emailError.getMessage();
                   		sendError.Error_Status_Code__c  = string.valueof(emailError.getStatusCode()) ;
                   		sendError.Error_Target_Record_ID__c = emailError.getTargetObjectId();
                   		System.debug('CPA Target Object ID is: ' + emailError.getTargetObjectId());
                   		errorMessages.add(sendError);
               		}
            	}
        	}
		}
		
		//update Opps
		if (!oppsToUpdate.isEmpty()) {
			System.debug('CPA Updating ' + oppsToUpdate.size() + ' Opportunities...');
			try {
				update oppsToUpdate;
			} catch (Exception e) {
				System.debug('CPA Caught Error in update oppsToUpdate ' + e);
				Batch_Error__c insertError = new Batch_Error__c();
                insertError.Batch_Process__c = 'Opportunity Close Date Maintenance Update Opportunity';
                insertError.Batch_Job_ID__c = BC.getJobId();
                insertError.Error_Date_Time__c = datetime.now();
                insertError.Error_Message__c = e.getMessage();
                insertError.Error_Status_Code__c  = e.getTypeName();
                errorMessages.add(insertError);
			}
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
       
       // debug
       System.debug(this.logLevel, 'CPA batch execution complete.');
       System.debug(this.logLevel, 'CPA execute END');
	} //execute
     
     
    /** The FINISH method - Clean up routine to perform any final tasks before exiting */
    global void finish(Database.BatchableContext BC){
		AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,  TotalJobItems, CreatedBy.Email FROM AsyncApexJob where Id =:BC.getJobId()];
		List <Opportunity_Maintenance_Task__c> myEmails = [SELECT Id from Opportunity_Maintenance_Task__c where CreatedDate = TODAY and Task__c <> 'Moved to Closed Lost'];
		List<Batch_Error__c> myErrors = [SELECT Id from Batch_Error__c where CreatedDate = TODAY];
		List <Opportunity_Maintenance_Task__c> myOpps = [SELECT Id from Opportunity_Maintenance_Task__c where CreatedDate = TODAY and Task__c = 'Moved to Closed Lost'];
       	    
       	// Send an email notifying of job completion.
       	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
       	List<string> toAddresses = notifyOnBatchComplete.split(',',0);
       	mail.setToAddresses(toAddresses);
       	mail.setSubject('Scheduled Apex | Opportunity Maintenance Tasks | ' + a.Status);
       	String emailBody = 'The batch Apex job, batch_OpportunityMaintenance, processed ' + a.TotalJobItems +' batches with '+ a.NumberOfErrors + ' failures.<br>';
       	emailBody += 'Number of Emails Sent: ' + myEmails.size() + '<br>';
       	emailBody += 'Number of Opportunities Updated: ' + myOpps.size() + '<br>';
       	emailBody += 'Number of Batch Error Records Created: ' + myErrors.size() + '<br>';
       	mail.setHtmlBody(emailBody);
       	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	       
       	System.debug(this.logLevel, 'CPA finish END');
	} //finish      
     

	/** Checks to see if Notification Email has already been sent for Maintenance Task and returns the result */
	private boolean hasTaskNotificationBeenSent(String taskType, String notificationNumber, Date targetDate, List<Opportunity_Maintenance_Task__c> myTaskList) {
		boolean sent = false;
		if (myTaskList != null) {
			for (Opportunity_Maintenance_Task__c myTask : myTaskList) {
        		if ((myTask.Type__c == taskType) && (myTask.Task__c == 'Notification Email ' + notificationNumber) && 
        				(myTask.Expected_Close_Date__c == targetDate)) {
        			sent = true;
        			System.debug('CPA Notification ' + notificationNumber + ' has already been sent');
        		}
			}
		}
		return sent;
	} //hasTaskNotificationBeenSent
	
	
    /** Returns a mail object to send out */
    private Messaging.SingleEmailMessage getMail(Opportunity myOpp, String taskType) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String emailBody = '***** THIS IS A SYSTEM GENERATED EMAIL. PLEASE DO NOT REPLY. *****<br>' + myOpp.Owner.Name + ',<br>';
        String emailSubject = 'System Emailer Notification';
        if (taskType.equalsIgnoreCase('One')) {
        	emailBody += 'All open opportunities not updated within 45 days of the <b>Expected Close Date</b> will automatically be marked ';
        	emailBody += 'as <font color="red"><b>Closed Lost</b></font> in SFDC. The record will then be locked for editing and you, as the ';
        	emailBody += 'opportunity owner, will need to create a case to reopen the locked opportunity. ';
        	emailBody += '<ul><li>If this is an active opportunity, please update the <b>Expected Close Date</b> to a more accurate date'; 
        	emailBody += '<li>If this is not an active opportunity, please change the <b>Status</b> to <b>Closed Lost</b> with the appropriate ';
        	emailBody += 'reason</ul>';
        	emailBody += 'All questions should be directed to your local Sales Operations Team.<hr />';
        	emailBody += '<table><tr><td>Account Name:</td><td>&nbsp;&nbsp;&nbsp;<b>' + myOpp.Account.Name + '</b></td></tr>';
        	emailBody += '<tr><td>Opportunity Name:</td><td>&nbsp;&nbsp;&nbsp;<b>' + myOpp.Name + '</b></td></tr>';
        	Datetime closeDate = datetime.newInstance(myOpp.CloseDate.year(), myOpp.CloseDate.month(),myOpp.CloseDate.day());
			emailBody += '<tr><td>Expected Close Date:</td><td>&nbsp;&nbsp;&nbsp;<b>' + closeDate.format('MMM dd, yyyy') + '</b></td></tr>';
			emailBody += '<tr><td>Link to Opportunity:</td><td>&nbsp;&nbsp;&nbsp;<a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + myOpp.Opportunity_ID_18_digit_Reference__c + '">Click here to access the Opportunity</a></td></tr>';
			emailBody += '</table>';
			
			emailSubject = 'Action Needed: Open opportunities over 45 days past due will be closed';
        } else if (taskType.equalsIgnoreCase('Two')) {
        	emailBody = 'All <b>Closed Won</b> opportunities not submitted for approval within 60 days of the <b>Expected Close Date</b ';
        	emailBody += 'will automatically be moved to the <font color="red"><b>Negotiate</b></font> stage in SFDC. Please either <ol>';
        	emailBody += '<li>Take the necessary steps to move this opportunity to the <b>Closed Approved</b> stage or <li>Move the opportunity to ';
        	emailBody += 'an open stage and update the <b>Expected Close Date</b> to a date in the future</ol>';
        	emailBody += 'All questions related to the Closed Approved process in your region should be directed to your local Sales Operations Team.<hr />';
        	emailBody += '<table><tr><td>Account Name:</td><td>&nbsp;&nbsp;&nbsp;<b>' + myOpp.Account.Name + '</b></td></tr>';
        	emailBody += '<tr><td>Opportunity Name:</td><td>&nbsp;&nbsp;&nbsp;<b>' + myOpp.Name + '</b></td></tr>';
        	Datetime closeDate = datetime.newInstance(myOpp.CloseDate.year(), myOpp.CloseDate.month(), myOpp.CloseDate.day());
			emailBody += '<tr><td>Expected Close Date:</td><td>&nbsp;&nbsp;&nbsp;<b>' + closeDate.format('MMM dd, yyyy') + '</b></td></tr>';
			emailBody += '<tr><td>Link to Opportunity:</td><td>&nbsp;&nbsp;&nbsp;<a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + myOpp.Opportunity_ID_18_digit_Reference__c + '">Click here to access the Opportunity</a></td></tr>';
			emailBody += '</table>';
			
			emailSubject = 'Action Needed: Please submit Closed Won opportunity for approval';
        } else if (taskType.equalsIgnoreCase('Three')) {
        	emailBody += 'All open opportunities not updated within the past 90 days will automatically be marked ';
        	emailBody += 'as <font color="red"><b>Closed Lost</b></font> in SFDC. The record will then be locked for editing and you, as the ';
        	emailBody += 'opportunity owner, will need to create a case to reopen the locked opportunity. ';
        	emailBody += '<ul><li>If this is not an active opportunity, please change the <b>Status</b> to <b>Closed Lost</b> with the appropriate reason'; 
        	emailBody += '<li>If this is an active opportunity, please take a moment to make updates you may already know about this deal as it has ';
        	emailBody += 'progressed (i.e. Sales credits, stage change, expected close date, value, known provider/competitors, etc) </ul>';
        	emailBody += 'All questions should be directed to your local Sales Operations Team.<hr />';
        	emailBody += '<table><tr><td>Account Name:</td><td>&nbsp;&nbsp;&nbsp;<b>' + myOpp.Account.Name + '</b></td></tr>';
        	emailBody += '<tr><td>Opportunity Name:</td><td>&nbsp;&nbsp;&nbsp;<b>' + myOpp.Name + '</b></td></tr>';
        	Datetime lastModifiedDate = datetime.newInstance(myOpp.LastModifiedDate.year(), myOpp.LastModifiedDate.month(),myOpp.LastModifiedDate.day());
			emailBody += '<tr><td>Last Modified Date:</td><td>&nbsp;&nbsp;&nbsp;<b>' + lastModifiedDate.format('MMM dd, yyyy') + '</b></td></tr>';
			emailBody += '<tr><td>Link to Opportunity:</td><td>&nbsp;&nbsp;&nbsp;<a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + myOpp.Opportunity_ID_18_digit_Reference__c + '">Click here to access the Opportunity</a></td></tr>';
			emailBody += '</table>';
			
			emailSubject = 'Action Needed: Open opportunities not updated in 90 days will be closed';
        } else {
        	emailBody = 'Cannot determine what task this email is for. Please contact your IT System Administrator';
        }
        mail.setHtmlBody(emailBody);
        mail.setSubject(emailSubject);
        mail.setReplyTo('no-reply@aon.com');
        mail.setSenderDisplayName('Salesforce.com');
        if (this.emailRecepient.contains('OWNER')) {
        	mail.setToAddresses(new List<String> {myOpp.Owner.Email});
        } else {
        	List<string> toAddresses = emailRecepient.split(',',0);
        	mail.setToAddresses(toAddresses);
        }
        mail.setUseSignature(false);
        return mail;
    } //getMail
    
    
    /** Returns an Opportunity Maintenance Task object to add */
    private Opportunity_Maintenance_Task__c getTask(Opportunity myOpp, String taskType, String flag) {
    	Opportunity_Maintenance_Task__c myTask = new Opportunity_Maintenance_Task__c();
    	Date modifiedDate = Date.newInstance(myOpp.LastModifiedDate.year(), myOpp.LastModifiedDate.month(), myOpp.LastModifiedDate.day());
    	myTask.Expected_Close_Date__c = taskType.equalsIgnoreCase(taskThree) ? modifiedDate : myOpp.CloseDate;
    	//myTask.Expected_Close_Date__c = myOpp.CloseDate;
		myTask.Opportunity__c = myOpp.opportunity_id_18_digit_reference__c;
        myTask.Opportunity_Owner__c = myOpp.OwnerId;
        myTask.Stage__c = myOpp.StageName;
        String taskDetail = '';
        if (flag.equalsIgnoreCase('action') && taskType.equalsIgnoreCase(taskTwo)) {
        	taskDetail = 'Moved to Negotiate';
        } else if (flag.equalsIgnoreCase('action')) {
			taskDetail = 'Moved to Closed Lost';
        } else {
        	taskDetail = 'Notification Email ' + flag;
        }
        myTask.Task__c = taskDetail;
        myTask.Type__c = taskType;
        return myTask;
    } //getTask
}