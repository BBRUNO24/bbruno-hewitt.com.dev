/* This class is called by the sched_batch_AccountMergeMaintenance class to clean up multiple Account Owners and other auxiliary data in merged accounts 
 * Chintan Adhyapak, January 28, 2015
 */
global class batch_AccountMergeMaintenance implements Database.Batchable<sObject> {
	//Wrapper class implements Comparable interface to allow for sorting of a list of Core_Service_Providers__c objects
    private class OutsourcingWrapper implements Comparable {
    	public Core_Service_Providers__c myRec {get; set;}
    	
    	//constructor
    	public OutsourcingWrapper(Core_Service_Providers__c spRecord) {
    		myRec = spRecord;
    	}
    	
    	//Sort the list in descending order by LastModifiedDate
    	public Integer compareTo(Object compareToObject) {
        	OutsourcingWrapper wrapperObject = (OutsourcingWrapper) compareToObject;
        	if (myRec.LastModifiedDate == wrapperObject.myRec.LastModifiedDate) return 0;
        	if (myRec.LastModifiedDate < wrapperObject.myRec.LastModifiedDate) return 1;
        	return -1;
    	}
    } //OutsourcingWrapper
    
    //Wrapper class implements Comparable interface to allow for sorting of a list of Consulting_Service_Provider__c objects
    private class ConsultingWrapper implements Comparable {
    	public Consulting_Service_Provider__c myRec {get; set;}
    	
    	//constructor
    	public ConsultingWrapper(Consulting_Service_Provider__c spRecord) {
    		myRec = spRecord;
    	}
    	
    	//Sort the list in descending order by LastModifiedDate
    	public Integer compareTo(Object compareToObject) {
        	ConsultingWrapper wrapperObject = (ConsultingWrapper) compareToObject;
        	if (myRec.LastModifiedDate == wrapperObject.myRec.LastModifiedDate) return 0;
        	if (myRec.LastModifiedDate < wrapperObject.myRec.LastModifiedDate) return 1;
        	return -1;
    	}
    } //ConsultingWrapper
    
    //Wrapper class implements Comparable interface to allow for sorting of a list of Point_Solution_Providers__c objects
    private class PointSolutionsWrapper implements Comparable {
    	public Point_Solution_Providers__c myRec {get; set;}
    	
    	//constructor
    	public PointSolutionsWrapper(Point_Solution_Providers__c spRecord) {
    		myRec = spRecord;
    	}
    	
    	//Sort the list in descending order by LastModifiedDate
    	public Integer compareTo(Object compareToObject) {
        	PointSolutionsWrapper wrapperObject = (PointSolutionsWrapper) compareToObject;
        	if (myRec.LastModifiedDate == wrapperObject.myRec.LastModifiedDate) return 0;
        	if (myRec.LastModifiedDate < wrapperObject.myRec.LastModifiedDate) return 1;
        	return -1;
    	}
    } //PointSolutionsWrapper
    
    
	//declare class vars
  	global String query; //soql query for the main scope of the batch process
  	global integer count; //Number of records processed
  	global String notifyOnBatchComplete; //Email Recepient of the final notification email on batch complete
  	Boolean opt_preserve_id = false;
    Boolean opt_IsDeepClone = true;
    Boolean opt_preserve_readonly_timestamps = false;
    Boolean opt_preserve_autonumber = false;
  	
  	//Contructor
  	global batch_AccountMergeMaintenance() {
  		//initialize
  		count = 0;
  		
  		//Read Custom Settings
  		Opportunity_Maintenance_Settings__c orgSettings = Opportunity_Maintenance_Settings__c.getInstance('Notify_On_Batch_Complete');
       	this.notifyOnBatchComplete = orgSettings.Value__c;
       	System.debug('CPA Notify_On_Batch_Complete = ' + notifyOnBatchComplete);
       	
       	//Reset count before starting
       	orgSettings = Opportunity_Maintenance_Settings__c.getInstance('processedCount');
		orgSettings.Value__c = '0';
		try { update orgSettings; }
		catch (Exception e) { System.debug('CPA Error updating processedCount in orgSetting in Constructor'); }
       	
  		//Read data from Merge Audit table
  		this.query = 'SELECT Id, MasterRecordId__c, Processed__c FROM Merge_Audit__c WHERE Processed__c = false'; 
		if (Test.isRunningTest()) {
    		this.query += ' LIMIT 200';
    	}
    	System.debug('CPA batch_AccountMergeMaintenance instantiated with query: ' + query);
  	} //constructor
  	
  	
  	/** The START method */
	global Database.QueryLocator start(Database.BatchableContext BC){
		System.debug('CPA start BEGIN');
    	//kick off the job by obtaining a handle to a query locator
    	return Database.getQueryLocator(this.query);
  	} //start
  	
  	
  	/** EXECUTE - this method receives the results of the start() method in chunks, and processes the received records */ 
	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		System.debug('CPA execute BEGIN on a batch of ' + scope.size() + ' records and count: ' + count);
		count = scope.size();
		
		//local vars
        List<Merge_Audit__c> auditList = new List<Merge_Audit__c> ();
        List<Id> accountIdList = new List<Id> ();
        List<Internal_Account_Team__c> iatToDeleteList = new List<Internal_Account_Team__c> ();
        Map<Id, Id> ownerIdMap = new Map<Id, Id> ();
        Map<Id, Id> userContactMap = new Map<Id, Id> ();
        List<Batch_Error__c> errorMessages = new List<Batch_Error__c>();
        List<Internal_Account_Team__c> iatToAddList = new List<Internal_Account_Team__c> ();
        String fieldNames = '';
        Map<String, Schema.SObjectField> schemaFieldMap = new Map<String, Schema.SObjectField> ();
        List<Core_Service_Providers__c> outsourcingProviderList = new List<Core_Service_Providers__c> ();
        List<Consulting_Service_Provider__c> consultingProviderList = new List<Consulting_Service_Provider__c> ();
        List<Point_Solution_Providers__c> pointSolutionsProviderList = new List<Point_Solution_Providers__c> ();
        List<Core_Service_Providers__c> outsourcingToAddList = new List<Core_Service_Providers__c> ();
        List<Consulting_Service_Provider__c> consultingToAddList = new List<Consulting_Service_Provider__c> ();
        List<Point_Solution_Providers__c> pointSolutionsToAddList = new List<Point_Solution_Providers__c> ();
       	
       	//Main loop for this batch's scope
       	System.debug('CPA start of main loop');
       	//Read incoming account ids from IAT records
       	for (sObject record : scope) {
       		Merge_Audit__c audit = (Merge_Audit__c)record;
       		auditList.add(audit);
       		accountIdList.add(audit.MasterRecordId__c);
       	}
       	
       	//Pull Internal Account Team records for the Account Owners of these accounts
       	iatToDeleteList =  [Select Id from Internal_Account_Team__c Where Account__c in :accountIdList And Contact_Role__c = 'Account Owner'];
       	System.debug('CPA iatToDeleteList size is: ' + iatToDeleteList.size());
       	
       	//Pull Account Owner from accounts
       	for (Account account : [Select Id, OwnerId from Account Where Id in :accountIdList]) {
       		ownerIdMap.put(account.Id, account.OwnerId);
       	}
       	
       	//Get the Corresponding Contact Id for the Account Owners
        for (Contact contact : [Select Id, Corresponding_User_Id__c from Contact where Corresponding_User_Id__c in :ownerIdMap.values()]) {
        	System.debug('CPA Adding User Id ' + contact.Corresponding_User_Id__c + ' and Contact Id ' + contact.Id + ' to userContactMap');
            userContactMap.put(contact.Corresponding_User_Id__c, contact.Id);
		}
		
		//Read all fieldnames for the Outsourcing Service Provider object
        schemaFieldMap = Schema.SObjectType.Core_Service_Providers__c.fields.getMap();
        for(String fieldName : schemaFieldMap.keySet()) {
            fieldNames += ',' + fieldName;
        }
        fieldNames = fieldNames.substring(1);
        String soql = 'Select ' + fieldNames + ' From Core_Service_Providers__c Where Account__c in :accountIdList Order By LastModifiedDate Desc';
        
        //Pull all existing Outsourcing Service Provider records for these accounts
        outsourcingProviderList = Database.query(soql);
        
		//Read all fieldnames for the Consulting Service Provider object
        schemaFieldMap = Schema.SObjectType.Consulting_Service_Provider__c.fields.getMap();
        fieldNames = '';
        for(String fieldName : schemaFieldMap.keySet()) {
            fieldNames += ',' + fieldName;
        }
        fieldNames = fieldNames.substring(1);
        soql = 'Select ' + fieldNames + ' From Consulting_Service_Provider__c Where Account__c in :accountIdList Order By LastModifiedDate Desc';
        
        //Pull all existing Consulting Service Provider records for these accounts
        consultingProviderList = Database.query(soql);
        
        //Read all fieldnames for the Point Solutions Service Provider object
        schemaFieldMap = Schema.SObjectType.Point_Solution_Providers__c.fields.getMap();
        fieldNames = '';
        for(String fieldName : schemaFieldMap.keySet()) {
            fieldNames += ',' + fieldName;
        }
        fieldNames = fieldNames.substring(1);
        soql = 'Select ' + fieldNames + ' From Point_Solution_Providers__c Where Account__c in :accountIdList Order By LastModifiedDate Desc';
        
        //Pull all existing Point Solutions Service Provider records for these accounts
        pointSolutionsProviderList = Database.query(soql);
       	
		//Delete Existing Account Owner records in the IAT
        try { delete iatToDeleteList; }
        catch (Exception e) {
        	System.debug('CPA ERROR in deleting iatToDeleteList - ' + e.getMessage());
        	Batch_Error__c insertError = new Batch_Error__c();
           	insertError.Batch_Process__c = 'Account Merge Maintenance';
           	insertError.Batch_Job_ID__c = BC.getJobId();
           	insertError.Error_Date_Time__c = datetime.now();
           	insertError.Error_Message__c = e.getMessage();
            insertError.Error_Status_Code__c  = e.getTypeName();
            errorMessages.add(insertError);
        }
        
        //Add IAT records for Account Owners
        for (Id accountId : ownerIdMap.keySet()) {
        	Internal_Account_Team__c iat = new Internal_Account_Team__c();
        	iat.Account__c = accountId;
        	iat.Contact_Role__c = 'Account Owner';
        	if (userContactMap.get(ownerIdMap.get(accountId)) != null) {
        		iat.Contact__c = userContactMap.get(ownerIdMap.get(accountId));
            	iatToAddList.add(iat);
			}
        }
        if (iatToAddList.size() > 0) {
        	try {
            	insert iatToAddList;
            } catch(Exception e) {
            	System.debug('CPA ERROR in inserting iatToAddList - ' + e.getMessage());
        		Batch_Error__c insertError = new Batch_Error__c();
           		insertError.Batch_Process__c = 'Account Merge Maintenance';
           		insertError.Batch_Job_ID__c = BC.getJobId();
           		insertError.Error_Date_Time__c = datetime.now();
           		insertError.Error_Message__c = e.getMessage();
            	insertError.Error_Status_Code__c  = e.getTypeName();
            	errorMessages.add(insertError);
            }
		}
		
		//Process Existing Outsourcing Service Provider Records
		for (Id accountId : accountIdList) {
			outsourcingToAddList.add(getOutsourcingRecord(outsourcingProviderList, accountId));
		}
		
		//Process Existing Consulting Service Provider Records
		for (Id accountId : accountIdList) {
			consultingToAddList.add(getConsultingRecord(consultingProviderList, accountId));
		}
		
		//Process Existing Point Solutions Service Provider Records
		for (Id accountId : accountIdList) {
			pointSolutionsToAddList.add(getPointSolutionsRecord(pointSolutionsProviderList, accountId));
		}
		
		//Delete Existing Service Provider records
        try { 
        	delete outsourcingProviderList;
        	delete consultingProviderList;
        	delete pointSolutionsProviderList; 
        } catch (Exception e) {
        	System.debug('CPA ERROR in deleting existing Service Provider Lists - ' + e.getMessage());
        	Batch_Error__c insertError = new Batch_Error__c();
           	insertError.Batch_Process__c = 'Account Merge Maintenance';
           	insertError.Batch_Job_ID__c = BC.getJobId();
           	insertError.Error_Date_Time__c = datetime.now();
           	insertError.Error_Message__c = e.getMessage();
            insertError.Error_Status_Code__c  = e.getTypeName();
            errorMessages.add(insertError);
        }
        
        //Insert new Service provider Records with concatenated data
        if (outsourcingToAddList.size() > 0) {
        	try { insert outsourcingToAddList; }
        	catch (Exception e) {
				System.debug('CPA ERROR in inserting Outsourcing Service Provider record - ' + e.getMessage());
        		Batch_Error__c insertError = new Batch_Error__c();
           		insertError.Batch_Process__c = 'Account Merge Maintenance';
           		insertError.Batch_Job_ID__c = BC.getJobId();
           		insertError.Error_Date_Time__c = datetime.now();
           		insertError.Error_Message__c = e.getMessage();
            	insertError.Error_Status_Code__c  = e.getTypeName();
            	errorMessages.add(insertError);
			}
        }
        if (consultingToAddList.size() > 0) {
        	try { insert consultingToAddList; }
        	catch (Exception e) {
				System.debug('CPA ERROR in inserting Consulting Service Provider record - ' + e.getMessage());
        		Batch_Error__c insertError = new Batch_Error__c();
           		insertError.Batch_Process__c = 'Account Merge Maintenance';
           		insertError.Batch_Job_ID__c = BC.getJobId();
           		insertError.Error_Date_Time__c = datetime.now();
           		insertError.Error_Message__c = e.getMessage();
            	insertError.Error_Status_Code__c  = e.getTypeName();
            	errorMessages.add(insertError);
			}
        }
        if (pointSolutionsToAddList.size() > 0) {
        	try { insert pointSolutionsToAddList; }
        	catch (Exception e) {
				System.debug('CPA ERROR in inserting Point Solutions Service Provider record - ' + e.getMessage());
        		Batch_Error__c insertError = new Batch_Error__c();
           		insertError.Batch_Process__c = 'Account Merge Maintenance';
           		insertError.Batch_Job_ID__c = BC.getJobId();
           		insertError.Error_Date_Time__c = datetime.now();
           		insertError.Error_Message__c = e.getMessage();
            	insertError.Error_Status_Code__c  = e.getTypeName();
            	errorMessages.add(insertError);
			}
        }
        
		//Update Merge Audit records
		for (Merge_Audit__c audit : auditList) {
			audit.Processed__c = true;
		}
		try { update auditList; }
		catch (Exception e) {
			System.debug('CPA ERROR in updating auditList - ' + e.getMessage());
        	Batch_Error__c insertError = new Batch_Error__c();
           	insertError.Batch_Process__c = 'Account Merge Maintenance';
           	insertError.Batch_Job_ID__c = BC.getJobId();
           	insertError.Error_Date_Time__c = datetime.now();
           	insertError.Error_Message__c = e.getMessage();
            insertError.Error_Status_Code__c  = e.getTypeName();
            errorMessages.add(insertError);
		}
		
		//Process error records
		if (!errorMessages.isEmpty()) {
			System.debug('CPA Inserting ' + errorMessages.size() + ' Error Records...');
			try {
				insert errorMessages;
			} catch (Exception e) {
				System.debug('CPA Caught Error in insert errorMessages ' + e);
			}
		}
       	System.debug('CPA execute END with count: ' + count);
		Opportunity_Maintenance_Settings__c orgSettings = Opportunity_Maintenance_Settings__c.getInstance('processedCount');
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
		List<Batch_Error__c> myErrors = [SELECT Id, Error_Message__c, Error_Date_Time__c FROM Batch_Error__c WHERE CreatedDate = TODAY and Batch_Process__c = 'Account Merge Maintenance' and Batch_Job_ID__c = :a.Id];
		Opportunity_Maintenance_Settings__c orgSettings = Opportunity_Maintenance_Settings__c.getInstance('processedCount');
       	    
       	// Send an email notifying of job completion.
       	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
       	List<string> toAddresses = notifyOnBatchComplete.split(',',0);
       	mail.setToAddresses(toAddresses);
       	mail.setSubject('Scheduled Apex | Account Merge Maintenance | ' + a.Status);
       	String emailBody = 'The batch Apex job, batch_AccountMergeMaintenance, processed ' + a.TotalJobItems +' batches with '+ a.NumberOfErrors + ' failures.<br>';
       	emailBody += 'Number of Merge Audit Records Processed: ' + orgSettings.Value__c + '<br>';
       	emailBody += 'Number of Batch Error Records Created: ' + myErrors.size() + '<br>';
       	for (Batch_Error__c myError : myErrors) {
       		emailBody += 'Error DateTime: ' + myError.Error_Date_Time__c + '<br>';
       		emailBody += 'Error Message: ' + myError.Error_Message__c + '<br>';
       	}
       	mail.setHtmlBody(emailBody);
       	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	       
       	System.debug('CPA finish END');
    } //finish
    
    
    /** Private utility method to return a Outsourcing Service Provide record by picking up the value with the last edit date from all exiting records */
    private Core_Service_Providers__c getOutsourcingRecord(List<Core_Service_Providers__c> incomingList, Id accountId) {
    	List<OutsourcingWrapper> wrapperList = new List<OutsourcingWrapper> ();
    	Core_Service_Providers__c returnRec;
    	
    	//Find all SP records for this account
    	for (Core_Service_Providers__c spRecord : incomingList) {
    		if (spRecord.Account__c == accountId) {
    			wrapperList.add(new OutsourcingWrapper(spRecord));
    		}
    	}
    	
    	//Sort this list by LastModifiedDate in descending order
    	wrapperList.sort();
    	
    	//Cycle through and pick data as necessary
    	for (OutsourcingWrapper wrapperRecord : wrapperList) {
    		if (returnRec == null) {
    			returnRec = wrapperRecord.myRec.clone(opt_preserve_id, opt_IsDeepClone, opt_preserve_readonly_timestamps, opt_preserve_autonumber);
    			returnRec.put('OwnerId', System.Userinfo.getUserId());
    		} else {
    			Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Core_Service_Providers__c.fields.getMap();
    			for(String fieldName : schemaFieldMap.keySet()) {
    				if ((returnRec.get(fieldName) == null) && (wrapperRecord.myRec.get(fieldName) != null) && !fieldName.equalsIgnoreCase('OwnerId')) {
    					Schema.DescribeFieldResult dfr = (schemaFieldMap.get(fieldName)).getDescribe(); 
    					if (dfr.isUpdateable()) {
    						System.debug('CPA putting fieldName: ' + fieldName);
    						returnRec.put(fieldName, wrapperRecord.myRec.get(fieldName));
    					}
    				}
    			}
    		}
    	}
    	System.debug('CPA Returning Outsourcing SP Record: ' + returnRec);
    	return returnRec;
    } //getOutsourcingRecord
    
    
    /** Private utility method to return a Consulting Service Provide record by picking up the value with the last edit date from all exiting records */
    private Consulting_Service_Provider__c getConsultingRecord(List<Consulting_Service_Provider__c> incomingList, Id accountId) {
    	List<ConsultingWrapper> wrapperList = new List<ConsultingWrapper> ();
    	Consulting_Service_Provider__c returnRec;
    	
    	//Find all SP records for this account
    	for (Consulting_Service_Provider__c spRecord : incomingList) {
    		if (spRecord.Account__c == accountId) {
    			wrapperList.add(new ConsultingWrapper(spRecord));
    		}
    	}
    	
    	//Sort this list by LastModifiedDate in descending order
    	wrapperList.sort();
    	
    	//Cycle through and pick data as necessary
    	for (ConsultingWrapper wrapperRecord : wrapperList) {
    		if (returnRec == null) {
    			returnRec = wrapperRecord.myRec.clone(opt_preserve_id, opt_IsDeepClone, opt_preserve_readonly_timestamps, opt_preserve_autonumber);
    			returnRec.put('OwnerId', System.Userinfo.getUserId());
    		} else {
    			Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Consulting_Service_Provider__c.fields.getMap();
    			for(String fieldName : schemaFieldMap.keySet()) {
    				if ((returnRec.get(fieldName) == null) && (wrapperRecord.myRec.get(fieldName) != null) && !fieldName.equalsIgnoreCase('OwnerId')) {
    					Schema.DescribeFieldResult dfr = (schemaFieldMap.get(fieldName)).getDescribe(); 
    					if (dfr.isUpdateable()) {
    						System.debug('CPA putting fieldName: ' + fieldName);
    						returnRec.put(fieldName, wrapperRecord.myRec.get(fieldName));
    					}
    				}
    			}
    		}
    	}
    	System.debug('CPA Returning Consulting SP Record: ' + returnRec);
    	return returnRec;
    } //getConsultingRecord
    
    
    /** Private utility method to return a Point Solutions Service Provide record by picking up the value with the last edit date 
        from all exiting records for all null values in all fields */
    private Point_Solution_Providers__c getPointSolutionsRecord(List<Point_Solution_Providers__c> incomingList, Id accountId) {
    	List<PointSolutionsWrapper> wrapperList = new List<PointSolutionsWrapper> ();
    	Point_Solution_Providers__c returnRec;
    	
    	//Find all SP records for this account
    	for (Point_Solution_Providers__c spRecord : incomingList) {
    		if (spRecord.Account__c == accountId) {
    			wrapperList.add(new PointSolutionsWrapper(spRecord));
    		}
    	}
    	
    	//Sort this list by LastModifiedDate in descending order
    	wrapperList.sort();
    	
    	//Cycle through and pick data as necessary
    	for (PointSolutionsWrapper wrapperRecord : wrapperList) {
    		if (returnRec == null) {
    			returnRec = wrapperRecord.myRec.clone(opt_preserve_id, opt_IsDeepClone, opt_preserve_readonly_timestamps, opt_preserve_autonumber);
    			returnRec.put('OwnerId', System.Userinfo.getUserId());
    		} else {
    			Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Point_Solution_Providers__c.fields.getMap();
    			for(String fieldName : schemaFieldMap.keySet()) {
    				if ((returnRec.get(fieldName) == null) && (wrapperRecord.myRec.get(fieldName) != null) && !fieldName.equalsIgnoreCase('OwnerId')) {
    					Schema.DescribeFieldResult dfr = (schemaFieldMap.get(fieldName)).getDescribe(); 
    					if (dfr.isUpdateable()) {
    						System.debug('CPA putting fieldName: ' + fieldName);
    						returnRec.put(fieldName, wrapperRecord.myRec.get(fieldName));
    					}
    				}
    			}
    		}
    	}
    	System.debug('CPA Returning Point Solutions SP Record: ' + returnRec);
    	return returnRec;
    } //getPointSolutionsRecord
}