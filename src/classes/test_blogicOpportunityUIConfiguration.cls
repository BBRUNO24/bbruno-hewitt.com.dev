@isTest
private class test_blogicOpportunityUIConfiguration {

    static testMethod void testAffirmativeCase() {
        
        // declare local vars
        Integer recordCount = 0;
        String fieldListRtId = '';
        String opptyRtId = '';
        List <Product_Field_List__c> recordsToCreate = new List <Product_Field_List__c>();
        List <Database.Saveresult> results = null;
        
        // delete all previously existing field list configuraitons...
        delete [select id from Product_Field_List__c];
        
        // verify no records exist
        recordCount = [select count() from Product_Field_List__c];
        System.assertEquals(0, recordCount);
        
        // get a handle on a record type id
        fieldListRtId = [select id from RecordType where IsActive = true and sObjectType = 'Product_Field_List__c' and Name != 'Edit UI Field' LIMIT 1].Id;
        
        // get a handle on an opportunity record type id
        opptyRtId = [select id from RecordType where IsActive = true and sObjectType = 'Opportunity' LIMIT 1].Id;
        
        // now add a field for each of the available objects
        recordsToCreate.add(new Product_Field_List__c(
        	RecordTypeId = fieldListRtId, Source_Object__c = 'Opportunity', Field_Name__c = 'StageName', 
        	Sort_Order__c = 1, Product_Service_Classification__c = 'Test', Product_Id__c = null, 
        	Opportunity_Stage__c = 'Negotiate', Opportunity_Record_Type__c = opptyRtId));
		recordsToCreate.add(new Product_Field_List__c(
        	RecordTypeId = fieldListRtId, Source_Object__c = 'OpportunityLineItem', Field_Name__c = 'Quantity', 
        	Sort_Order__c = 1, Product_Service_Classification__c = 'Test', Product_Id__c = null, 
        	Opportunity_Stage__c = 'Negotiate', Opportunity_Record_Type__c = opptyRtId));
        recordsToCreate.add(new Product_Field_List__c(
        	RecordTypeId = fieldListRtId, Source_Object__c = 'PricebookEntry', Field_Name__c = 'UnitPrice', 
        	Sort_Order__c = 1, Product_Service_Classification__c = 'Test', Product_Id__c = null, 
        	Opportunity_Stage__c = 'Negotiate', Opportunity_Record_Type__c = opptyRtId));
        recordsToCreate.add(new Product_Field_List__c(
        	RecordTypeId = fieldListRtId, Source_Object__c = 'Product', Field_Name__c = 'Name', 
        	Sort_Order__c = 1, Product_Service_Classification__c = 'Test', Product_Id__c = null, 
        	Opportunity_Stage__c = 'Negotiate', Opportunity_Record_Type__c = opptyRtId));
        
        // insert the records
        results = Database.insert(recordsToCreate, false);
        
        // assert all were created
        System.assertEquals(true, results[0].isSuccess());
        System.assertEquals(true, results[1].isSuccess());
        System.assertEquals(true, results[2].isSuccess());
        System.assertEquals(true, results[3].isSuccess());
		
		// verify records exist
        recordCount = [select count() from Product_Field_List__c];
        System.assertEquals(4, recordCount);
        
        // try an update
        results = Database.update(recordsToCreate, false);
    }
    
    static testMethod void testCaseSensitivityScrub() {
        
        // declare local vars
        Integer recordCount = 0;
        String fieldListRtId = '';
        String opptyRtId = '';
        List <Product_Field_List__c> recordsToCreate = new List <Product_Field_List__c>();
        List <Database.Saveresult> results = null;
        Product_Field_List__c pf = null;
        
        // delete all previously existing field list configuraitons...
        delete [select id from Product_Field_List__c];
        
        // verify no records exist
        recordCount = [select count() from Product_Field_List__c];
        System.assertEquals(0, recordCount);
        System.debug('record count: ' + recordCount);
        
        // get a handle on a record type id
        fieldListRtId = [select id from RecordType where IsActive = true and sObjectType = 'Product_Field_List__c' and Name != 'Edit UI Field' LIMIT 1].Id;
        
        // get a handle on an opportunity record type id
        opptyRtId = [select id from RecordType where IsActive = true and sObjectType = 'Opportunity' LIMIT 1].Id;
        
        // now add a field for each of the available objects
        recordsToCreate.add(new Product_Field_List__c(
        	RecordTypeId = fieldListRtId, Source_Object__c = 'Opportunity', Field_Name__c = 'sTaGeNaMe', 
        	Sort_Order__c = 1, Product_Service_Classification__c = 'Test', Product_Id__c = null, 
        	Opportunity_Stage__c = 'Negotiate', Opportunity_Record_Type__c = opptyRtId));
        
        // insert the records
        System.debug('creating records...');
        results = Database.insert(recordsToCreate, false);
        System.debug('record created: ' + results);
        
        // assert all were created
        System.assertEquals(true, results[0].isSuccess());
        
        // retrieve the record to assert the case sensitive scrub
        System.debug('asserting the result...');
        pf = [select field_name__c from Product_Field_List__c where id = :results[0].getId()];
        System.assertEquals('StageName', pf.Field_Name__c);
        System.debug('rerieved record: ' + pf);
        
        // try an update
        results = Database.update(recordsToCreate, false);
    }
    
    static testMethod void testInvalidField() {
        
        // declare local vars
        Integer recordCount = 0;
        String fieldListRtId = '';
        String opptyRtId = '';
        List <Product_Field_List__c> recordsToCreate = new List <Product_Field_List__c>();
        List <Database.Saveresult> results = null;
        Product_Field_List__c pf = null;
        
        // delete all previously existing field list configuraitons...
        delete [select id from Product_Field_List__c];
        
        // verify no records exist
        recordCount = [select count() from Product_Field_List__c];
        System.assertEquals(0, recordCount);
        
        // get a handle on a record type id
        fieldListRtId = [select id from RecordType where IsActive = true and sObjectType = 'Product_Field_List__c' and Name != 'Edit UI Field' LIMIT 1].Id;
        
        // get a handle on an opportunity record type id
        opptyRtId = [select id from RecordType where IsActive = true and sObjectType = 'Opportunity' LIMIT 1].Id;
        
        // now add a field for each of the available objects
        recordsToCreate.add(new Product_Field_List__c(
        	RecordTypeId = fieldListRtId, Source_Object__c = 'Opportunity', Field_Name__c = 'asdoiuasldnasdjuhkfcuyhas', 
        	Sort_Order__c = 1, Product_Service_Classification__c = 'Test', Product_Id__c = null, 
        	Opportunity_Stage__c = 'Negotiate', Opportunity_Record_Type__c = opptyRtId));
        
        // insert the records
        results = Database.insert(recordsToCreate, false);
        
        // assert all were created
        System.assertEquals(false, results[0].isSuccess());
        
        // try an update
        results = Database.update(recordsToCreate, false);
    }
    
 	static testMethod void testInvalidObject() {
        
        // declare local vars
        Integer recordCount = 0;
        String fieldListRtId = '';
        String opptyRtId = '';
        List <Product_Field_List__c> recordsToCreate = new List <Product_Field_List__c>();
        List <Database.Saveresult> results = null;
        Product_Field_List__c pf = null;
        
        // delete all previously existing field list configuraitons...
        delete [select id from Product_Field_List__c];
        
        // verify no records exist
        recordCount = [select count() from Product_Field_List__c];
        System.assertEquals(0, recordCount);
        
        // get a handle on a record type id
        fieldListRtId = [select id from RecordType where IsActive = true and sObjectType = 'Product_Field_List__c' and Name != 'Edit UI Field' LIMIT 1].Id;
        
        // get a handle on an opportunity record type id
        opptyRtId = [select id from RecordType where IsActive = true and sObjectType = 'Opportunity' LIMIT 1].Id;
        
        // now add a field for each of the available objects
        recordsToCreate.add(new Product_Field_List__c(
        	RecordTypeId = fieldListRtId, Source_Object__c = 'askdljhlkjhkjh', Field_Name__c = 'asdoiuasldnasdjuhkfcuyhas', 
        	Sort_Order__c = 1, Product_Service_Classification__c = 'Test', Product_Id__c = null, 
        	Opportunity_Stage__c = 'Negotiate', Opportunity_Record_Type__c = opptyRtId));
        
        // insert the records
        results = Database.insert(recordsToCreate, false);
        
        // assert all were created
        System.assertEquals(false, results[0].isSuccess());
        
        // try an update
        results = Database.update(recordsToCreate, false);
    }    
    
 	static testMethod void testDuplicateField() {
        
        // declare local vars
        Integer recordCount = 0;
        String fieldListRtId = '';
        String opptyRtId = '';
        List <Product_Field_List__c> recordsToCreate = new List <Product_Field_List__c>();
        List <Database.Saveresult> results = null;
        
        // delete all previously existing field list configuraitons...
        delete [select id from Product_Field_List__c];
        
        // verify no records exist
        recordCount = [select count() from Product_Field_List__c];
        System.assertEquals(0, recordCount);
        
        // get a handle on a record type id
        fieldListRtId = [select id from RecordType where IsActive = true and sObjectType = 'Product_Field_List__c' and Name != 'Edit UI Field' LIMIT 1].Id;
        
        // get a handle on an opportunity record type id
        opptyRtId = [select id from RecordType where IsActive = true and sObjectType = 'Opportunity' LIMIT 1].Id;
        
        // now add a field for each of the available objects
        recordsToCreate.add(new Product_Field_List__c(
        	RecordTypeId = fieldListRtId, Source_Object__c = 'Opportunity', Field_Name__c = 'StageName', 
        	Sort_Order__c = 1, Product_Service_Classification__c = 'Test', Product_Id__c = null, 
        	Opportunity_Stage__c = 'Negotiate', Opportunity_Record_Type__c = opptyRtId));
        recordsToCreate.add(new Product_Field_List__c(
        	RecordTypeId = fieldListRtId, Source_Object__c = 'Opportunity', Field_Name__c = 'StageName', 
        	Sort_Order__c = 1, Product_Service_Classification__c = 'Test', Product_Id__c = null, 
        	Opportunity_Stage__c = 'Negotiate', Opportunity_Record_Type__c = opptyRtId));
        
        // insert the records
        System.debug('creating records...');
        results = Database.insert(recordsToCreate, false);
        
        // assert all were created
        System.assertEquals(true, results[0].isSuccess());
        System.assertEquals(false, results[1].isSuccess());
		
		// verify records exist
		System.debug('asserting the results...');
        recordCount = [select count() from Product_Field_List__c];
        System.debug('there are ' + recordCount + ' product field lists.');
        System.assertEquals(1, recordCount);
        
        // try an update
        results = Database.update(recordsToCreate, false);
    }   
}