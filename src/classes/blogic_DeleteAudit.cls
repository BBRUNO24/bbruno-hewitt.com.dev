public with sharing class blogic_DeleteAudit {
    
    //Create Records in the Delete_Audit object
    public static void createDeleteAuditRecords(List<sObject> records) {
        //local vars
        List<Delete_Audit__c> auditRecordsToProcess = new List<Delete_Audit__c> ();
        
        if (trigger.isDelete) {
            //local vars
            String recordType = null;
            Account myAccount = null;
            Contact myContact = null;
            Opportunity myOpportunity = null;
            Id externalContactId = null;
            
            //Spin through the records
            for (sObject record : records) {
                if (record.getSObjectType() == Account.sObjectType) { 
                    recordType = 'Account';
                    myAccount = (Account)record;
                } else if (record.getSObjectType() == Contact.sObjectType) {                    
                    if (externalContactId == null) {
                        externalContactId = util_sampleDatagenerator.getRecordType('Contact', 'External Contact Record Type').Id;
                    }
                    myContact = (Contact)record;
                    recordType = (myContact.RecordTypeId == externalContactId) ? 'External Contact' : 'Internal Contact';
                } else if (record.getSObjectType() == Opportunity.sObjectType) {
                    recordType = 'Opportunity';
                    myOpportunity = (Opportunity)record;
                } else {
                    System.debug('ERROR - Method createDeleteAuditRecords called from unsupported object');
                    record.addError('Method blogic_AuditDelete.createDeleteAuditRecords called from an unsupported object. Please contact your System Administrator.');
                    continue;
                }
                System.debug('CHINTAN Delete Audit Record Type is: ' + recordType);
                
                //Create Delete Audit record
                Delete_Audit__c auditRecord = new Delete_Audit__c();
                auditRecord.Deleted_By__c = System.Userinfo.getUserId();
                auditRecord.Deletion_Date__c = Datetime.now();
                auditRecord.Record_ID__c = record.Id;
                auditRecord.Record_Type__c = recordType;
                if (recordType.equalsIgnoreCase('Account')) {
                    auditRecord.Record_Name__c = myAccount.Name;
                    //auditRecord.CRM_ID__c = myAccount.CRM_ID__c;
                    auditRecord.CRM_ID__c = (String) myAccount.get('CRM_ID__c'); // 00153585 - This will escape the compiler and hence let us change the field type
                    auditRecord.Record_Country__c=myAccount.SDO_Billing_Country_Name__c; //00125813-Account country
                } else if (recordType.contains('Contact')) {
                    auditRecord.Record_Name__c = myContact.FirstName + ' ' + myContact.LastName;
                    //auditRecord.CRM_ID__c = myContact.CRM_ID__c;
                    auditRecord.CRM_ID__c = (String) myContact.get('CRM_ID__c');
                    auditRecord.Record_Country__c=myContact.SDO_Mailing_Country_Name__c; //00125813-Contact country
                } else if (recordType.equalsIgnoreCase('Opportunity')) {
                    auditRecord.Record_Name__c = myOpportunity.Name;
                    //auditRecord.CRM_ID__c = myOpportunity.Oportunity_Auto_Number__c;
                    auditRecord.CRM_ID__c = (String) myOpportunity.get('Oportunity_Auto_Number__c');
                    auditRecord.Record_Country__c=myOpportunity.AccountCountry__c; //00125813-Account country
                }
                System.debug('CHINTAN Audit Record is: ' + auditRecord);
                //Add to list
                auditRecordsToProcess.add(auditRecord);
            } //for
            
            //Create Audit Records
            System.debug('CHINTAN Number of Audit Delete Records to Process: ' + auditRecordsToProcess.size());
            try {
                insert auditRecordsToProcess;
            } catch (Exception e) {
                System.debug('CHINTAN Error in inserting Audit Delete records: ' + e.getMessage());
            }
        } else if (trigger.isUndelete) {
            //local vars
            List<Id> recordIds = new List<Id> ();
            
            //Spin through the records
            for (sObject record : records) {
                recordIds.add(record.Id);
            }
            
            //Get Audit Records
            auditRecordsToProcess = [Select Id from Delete_Audit__c Where Record_ID__c in :recordIds];
            System.debug('CHINTAN Number of Audit Records to Delete is: ' + auditRecordsToProcess.size());
            
            //Delete them
            if (!auditRecordsToProcess.isEmpty()) {
                try {
                    delete auditRecordsToProcess;
                } catch (Exception e) {
                    System.debug('CHINTAN ERROR in deleting Delete_Audit records: ' + e.getMessage());
                }
            }
        }
        
    } //createDeleteAuditRecords

}