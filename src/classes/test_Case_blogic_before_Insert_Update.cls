/**
 * Test Class for test for the Cases
 */
@isTest(seeAllData=True)
private class test_Case_blogic_before_Insert_Update {
    //00020385 - Ritu Sharma - Commented the function as reporting fields will now be formula fields
/* 
    static testMethod void populateCaseReportingAtt() 
    { 
      //Create Internal Contact
      Contact con = util_sampleDataGenerator.createContact_Internal('');
                 
      //Create a case            
      Case testCase = new Case();
      testCase.RecordTypeId = util_sampleDataGenerator.getRecordType('Case','Enhancement Request').ID;
      testCase.Type = 'Report Request';
      testCase.Status = 'Submitted';
      testCase.ContactId = con.ID;
      testCase.Reporting_Office__c = 'N/A-Admin';
      testCase.Reporting_Region__c = 'N/A-Admin';
      testCase.Reporting_Country__c = 'N/A-Admin';
      testCase.Reporting_Business_Unit_Region__c = 'N/A-Admin';
      insert testCase;
      
      Case testCase2 = [Select a.ContactId, a.Id From Case a where a.Id =: testCase.Id];
      testCase2.ContactId = con.ID;
      update testCase2;     
    }
 */ 

    static testMethod void validateAllReviewSections()
    {
        //Initializations of variables that will be used accross this method
        String enhCaseRecTypeID = util_sampleDataGenerator.getRecordType('Case','Enhancement Request').ID;
        String intContactRecordTypeID = util_sampleDataGenerator.getRecordType('Contact','Internal Contact Record Type').ID;
        Date tDay = System.Today();
        Date tomorrow = tDay.addDays(1);
        
        //Create an admin user
        User testUser = util_sampleDataGenerator.createAdminUser();
        
        //Create Internal Contact
        Contact con = util_sampleDataGenerator.createContact_Internal('');
                
        //Create an Enhancement Case        
        Case testCase = new Case(); 
        testCase.Status='Submitted';
        testCase.Type='Enhancement Request';
        testCase.Enhancement_Request_Type__c='Production Error';
        testCase.contact=con;
        testCase.RecordTypeId = enhCaseRecTypeID ;
        //00020385 - Ritu Sharma - Commented the code as reporting fields are now formula fields
        //testCase.Reporting_Business_Unit_Region__c='Consulting';
        //testCase.Reporting_Region__c='Central';
        //testCase.Reporting_Country__c='United States';
        //testCase.Reporting_Office__c='Atlanta';
        testCase.Function_Area__c='Leads';
        testCase.Subject='Test Case - 1';
        insert testCase;
        System.debug('Case Inserted - ' + testCase.ID);
        
        // User trying to complete Requirement section without entering all fields for requirement section
        testCase.Req_Review_Complete__c = 'Yes';
        testCase.Req_Analysis_Impact__c = NULL; 
        try {update testCase;}
        catch(DMLException e)
        {
            System.assert(e.getDmlMessage(0).indexOf(Label.Case_Requirement_Complete) > -1);
            System.debug('Error Message 1 - ' + e.getDmlMessage(0));
        }     
        
        // User trying to save values in Design section without completing requirements section
        testCase.Req_Review_Complete__c = 'No';
        testCase.Design_Development_Changes__c = 'Testing Design Phase';
        try {update testCase;}
        catch(DMLException e)
        {
            System.assert(e.getDmlMessage(0).indexOf(Label.Complete_Requirement_Section) > -1);
            System.debug('Error Message 2 - ' + e.getDmlMessage(0));
        } 
        
        //Updating case to populate requirement section details so that we could test for next steps
        testCase.Req_Review_Complete__c = 'Yes';
        testCase.Req_Analysis_Impact__c = 'Test Impact';
        testCase.Rq_Reviewer__c = testUser.ID;
        testCase.Req_Reviewer_s_Comments__c = 'Yes';
        Update testCase; 
        System.debug('Regquirement details updated - '+testCase.Rq_Reviewer__c);

        //User trying to complete Design section without completing all fields of Design section        
        testCase.Design_Changes_Complete__c = 'Yes';
        testCase.Design_Reviewer_s_Comments__c = '';     
        try {update testCase;}
        catch(DMLException e)
        {
            System.assert(e.getDmlMessage(0).indexOf(Label.Case_Design_Complete) > -1);
            System.debug('Error Message 3 - ' + e.getDmlMessage(0));
        }  
        
        //User trying to add values for Development Review and QA Testing without completing Design section
        testCase.Design_Changes_Complete__c = 'No';
        testCase.Dev_Test_Results__c ='In Progress';
        try {update testCase;}
        catch(DMLException e)
        {
            System.assert(e.getDmlMessage(0).indexOf(Label.Design_and_Development_section_complete) > -1);
            System.debug('Error Message 4 - ' + e.getDmlMessage(0));
        }          
   
        //Updating case to populate design section details so that we could test for next steps       
        testCase.Design_Changes_Complete__c = 'Yes';
        testCase.Design_Reviewer_s_Comments__c = 'Test Comments';
        testCase.Design_Reviewer__c = testUser.ID;
        testCase.Design_Development_Changes__c = 'Test Changes';
        Update testCase;
        System.debug('Design Details updated - '+testCase.Design_Reviewer__c);
        
        //User trying to complete Development and QA Testing without completing Design section
        testCase.Design_Review_Complete__c = 'Yes';
        testCase.QA_Test_Results__c = Null; 
                        
        try {update testCase;}
        catch(DMLException e)
        {
            System.assert(e.getDmlMessage(0).indexOf(Label.Case_Devlopment_and_QA_Complte) > -1);
            System.debug('Error Message 5 - ' + e.getDmlMessage(0));
        }        
        
        //User trying to enter values in UAT section without completing Design section
        testCase.Design_Review_Complete__c = 'No';
        testCase.UAT_Testing_Complete__c='In Progress';
        try {update testCase;}
        catch(DMLException e)
        {
            System.assert(e.getDmlMessage(0).indexOf(Label.Dev_Review_and_QA) > -1);          
            System.debug('Error Message 6 - ' + e.getDmlMessage(0));
        }                 
        
        //Updating the fields of Dev Review and QA testing section so that we could test for next steps 
        testCase.Design_Review_Complete__c='Yes';
        testCase.QA_Test_Results__c = 'Passed';
        testCase.QA_Testing_Comments__c = 'QA Testing';
        testCase.Dev_Testing_Complete__c = 'Passed';
        testCase.Dev_Test_Results__c = 'Dev testing';
        update testCase;
        System.debug('Dev Review & QA results updated - '+testCase.Design_Review_Complete__c);
        
        //User trying to pass UAT Tests without entering fields in UAT section
        testCase.UAT_Testing_Complete__c = 'Passed';
        try {update testCase;}
        catch(DMLException e)
        {
            System.assert(e.getDmlMessage(0).indexOf(Label.Case_UAT_Complete) > -1);          
            System.debug('Error Message 7 - ' + e.getDmlMessage(0));
        }        
        
        //User trying to mark case ready for migration without completing UAT section
        testCase.UAT_Testing_Complete__c='In Progress';
        testCase.Ready_for_Migration__c = 'Yes';
        try {update testCase;}
        catch(DMLException e)
        {
            System.assert(e.getDmlMessage(0).indexOf(Label.UAT_Complete) > -1);          
            System.debug('Error Message 8 - ' + e.getDmlMessage(0));
        } 
        
        //Updating the fields of UAT section so that we could test for next steps 
        testCase.UAT_Testing_Complete__c='Passed';
        testCase.UAT_Test_Cases__c = 'UAT Testing';
        update testCase;

        //Validation for Planned Migration date
        testCase.Migration_Complete__c = 'Yes';
        try {update testCase;}
        catch(DMLException e)
        {
            System.assert(e.getDmlMessage(0).indexOf(Label.Planned_Migration_for_Case) > -1);          
            System.debug('Error Message 9 - ' + e.getDmlMessage(0));
        } 
        
        //Validated by IT and by user cannot be clicked if migration not complete
        testCase.Migration_Complete__c = 'No';
        testCase.Validated_by_IT__c = True;
        try {update testCase;}
        catch(DMLException e)
        {
            System.assert(e.getDmlMessage(0).indexOf(Label.Migration_Complete) > -1);          
            System.debug('Error Message 10 - ' + e.getDmlMessage(0));
        } 
        
        //Updating the fields of migration section so that we could test for next steps
        testCase.Migration_Complete__c = 'Yes';
        testCase.Due_Date__c = tDay.addDays(2);        
        testCase.Ready_for_Migration__c = 'Yes';
        update testCase;
        System.debug('Updated Migration Section '+testCase.Migration_Complete__c);
        
        //User tried to validate though it has not been validated by IT
        testCase.Validated_by_User__c = True;
        testCase.Validated_by_IT__c = False;
        try {update testCase;}
        catch(DMLException e)
        {
            System.assert(e.getDmlMessage(0).indexOf(Label.Case_Validate_by_User) > -1);          
            System.debug('Error Message 11 - ' + e.getDmlMessage(0));
        }
        
        //Updating the validation fields so that we could test for next steps
        testCase.Validated_by_User__c = True;
        testCase.Validated_by_IT__c = True;
        update testCase;
        System.debug('Updated validation fields '+testCase.Validated_by_IT__c );
        
        //Due date cannot be less than current date
        testCase.Due_Date__c = tDay.addDays(-1);
        try {update testCase;}
        catch(DMLException e)
        {
            System.assert(e.getDmlMessage(0).indexOf(Label.Planned_Migration_Date_for_Cases) > -1);          
            System.debug('Error Message 12 - ' + e.getDmlMessage(0));
        }
        
        //Bulk Testing
        List <Case> cases = new List<Case>();
        Case testCase2 = Null;
        for (Integer I=0;I<200;I++)
        {
            //Create an Enhancement Case        
            testCase2 = new Case(); 
            testCase2.Status='Submitted';
            testCase2.Type='Enhancement Request';
            testCase2.Enhancement_Request_Type__c='Production Error';
            testCase2.contact=con;
            testCase2.RecordTypeId = enhCaseRecTypeID ;
            //00020385 - Ritu Sharma - Commented the code as reporting fields are now formula fields
            //testCase2.Reporting_Business_Unit_Region__c='Consulting';
            //testCase2.Reporting_Region__c='Central';
            //testCase2.Reporting_Country__c='United States';
            //testCase2.Reporting_Office__c='Atlanta';
            testCase2.Function_Area__c='Leads';
            testCase2.Subject='Bulk Teting - '+I;
            testCase2.Req_Review_Complete__c = 'Yes';
            testCase2.Req_Analysis_Impact__c = 'Test Impact';
            testCase2.Rq_Reviewer__c = testUser.ID;
            testCase2.Req_Reviewer_s_Comments__c = 'Yes';
            testCase2.Design_Changes_Complete__c = 'Yes';
            testCase2.Design_Reviewer_s_Comments__c = 'Test Comments';
            testCase2.Design_Reviewer__c = testUser.ID;
            testCase2.Design_Development_Changes__c = 'Test Changes';
            testCase2.Design_Review_Complete__c='Yes';
            testCase2.QA_Test_Results__c = 'Passed';
            testCase2.QA_Testing_Comments__c = 'QA Testing';
            testCase2.Dev_Testing_Complete__c = 'Passed';
            testCase2.Dev_Test_Results__c = 'Dev testing';
            testCase2.UAT_Testing_Complete__c='Passed';
            testCase2.UAT_Test_Cases__c = 'UAT Testing';
            testCase2.Migration_Complete__c = 'Yes';
            testCase2.Due_Date__c = tDay.addDays(10);
            testCase2.Ready_for_Migration__c = 'Yes';
            
            cases.add(testCase2); //Adding to the list
            System.debug('Case has been added to the list - '+testCase2.Subject);
        }
        Insert cases;
    }       
    
    //00109262-Ritu Sharma-Test method for updateGatewayAccounts function of blogic_Case class
    static testMethod void test_updateGatewayAccounts()
    {        
        Gateway_Account__c gtwAccount;
        List<Gateway_Account__c> gtwAccountList = new List<Gateway_Account__c>();
        Case gtwCase;
        List<Case> gtwCaseList = new List<Case>();
        ID gtwCaseRecTypeID;
        Contact contact;
        
        //Getting id of 'Convert Gateway Account (APAC)' record type
        gtwCaseRecTypeID = util_sampleDataGenerator.getRecordType('Case','Convert Gateway Account (APAC)').ID;
        
        //Creating 200 gateway accounts
        for(integer i = 0; i <200 ; i++)
        {
            gtwAccount = new Gateway_Account__c();
            gtwAccount.Name = 'Test Account-'+i;
            gtwAccount.Client_ID__c ='1234'+i;
            gtwAccount.Country__c = 'Australia';
            gtwAccount.City_Name__c = 'Test City';
            gtwAccount.Postal_Address__c = '110091';
            gtwAccount.State_Name__c = 'Test State';
            gtwAccount.Main_Address__c = 'Test Address';
            gtwAccount.Industry_Name__c = 'Energy';                
            gtwAccountList.add(gtwAccount);
        }
        insert gtwAccountList;
        
        //Creating an Internal Contact
        contact = util_sampleDataGenerator.createContact_Internal('');
        
        //Creating Convert Gateway Case request for each account        
        for(integer i = 0; i < 200 ; i++)
        {
            gtwCase = new Case();
            gtwCase.Status='Submitted';
            gtwCase.contact=contact;
            gtwCase.RecordTypeId = gtwCaseRecTypeID;
            gtwCase.Gateway_Account__c = gtwAccountList[i].ID;
            gtwCase.New_Account_Type__c = 'Prospect';
            gtwCaseList.add(gtwCase);
        }
        insert gtwCaseList;
        
        //Closing all the cases
        for(integer i = 0; i<200; i++)
        {
            gtwCaseList[i].Status = 'Closed - Implemented';
        }
        update gtwCaseList;
        
        //Verify Gateway Account IsConverted flag - It should be true for all
        gtwAccountList = [select ID,Is_Converted__c from Gateway_Account__c where Is_Converted__c = true And ID IN: gtwAccountList];
        System.assertEquals(200,gtwAccountList.size());
    }  
    
    //00109262-Ritu Sharma-Test method for test_populateAddressfields function of blogic_Case class
    static testMethod void test_populateAddressfields()
    {
        Gateway_Account__c gtwAccount;
        List<Gateway_Account__c> gtwAccountList = new List<Gateway_Account__c>();
        Map<ID,Gateway_Account__c> gtwAccountMap = new Map<ID,Gateway_Account__c>();
        Case gtwCase;
        List<Case> gtwCaseList = new List<Case>();
        ID gtwCaseRecTypeID;
        Contact contact;
        
        //Getting id of 'Convert Gateway Account (APAC)' record type
        gtwCaseRecTypeID = util_sampleDataGenerator.getRecordType('Case','Convert Gateway Account (APAC)').ID;
        
        //Creating 400 gateway accounts
        for(integer i = 0; i <400 ; i++)
        {
            gtwAccount = new Gateway_Account__c();
            gtwAccount.Name = 'Test Account-'+i;
            gtwAccount.Client_ID__c ='1234-' + i;
            gtwAccount.Country__c = 'Australia-'+i;
            gtwAccount.City_Name__c = 'Test City-'+i;
            gtwAccount.Postal_Address__c = '111111-'+i;
            gtwAccount.State_Name__c = 'Test State-'+i;
            gtwAccount.Main_Address__c = 'Test Address-'+i;
            gtwAccount.Industry_Name__c = 'Energy-'+i;                
            gtwAccountList.add(gtwAccount);
        }
        insert gtwAccountList;
        
        //Preparing the map of accounts - will be used later on for finding the accounts
        for(integer i=0; i<400;i++)
        {
            gtwAccountMap.put(gtwAccountList[i].id,gtwAccountList[i]);
        }
            
        //Creating an Internal Contact
        contact = util_sampleDataGenerator.createContact_Internal('');
        
        //Creating Convert Gateway Case request for first 200 accounts        
        for(integer i = 0; i < 200 ; i++)
        {
            gtwCase = new Case();
            gtwCase.Status='Submitted';
            gtwCase.contact=contact;
            gtwCase.RecordTypeId = gtwCaseRecTypeID;
            gtwCase.Gateway_Account__c = gtwAccountList[i].ID;
            gtwCase.New_Account_Type__c = 'Prospect';
            gtwCaseList.add(gtwCase);
        }
        insert gtwCaseList;
        
        //Checking that address and industry fields have been correctly populated on the cases
        gtwCaseList = [Select ID, Gateway_Account__c, New_Account_Billing_Country__c, Industry__c, New_Account_Billing_City__c, New_Account_Billing_State_Province__c, New_Account_Billing_Street__c, New_Account_Billing_Zip_Postal_Code__c from Case where ID IN: gtwCaseList];
        for(integer i = 0; i < 200 ; i++)
        {
            gtwAccount = gtwAccountMap.get(gtwCaseList[i].Gateway_Account__c);
            System.assertEquals(gtwAccount.Country__c,gtwCaseList[i].New_Account_Billing_Country__c);
            System.assertEquals(gtwAccount.Industry_Name__c,gtwCaseList[i].Industry__c);
            System.assertEquals(gtwAccount.City_Name__c,gtwCaseList[i].New_Account_Billing_City__c);
            System.assertEquals(gtwAccount.State_Name__c,gtwCaseList[i].New_Account_Billing_State_Province__c);
            System.assertEquals(gtwAccount.Main_Address__c,gtwCaseList[i].New_Account_Billing_Street__c);
            System.assertEquals(gtwAccount.Postal_Address__c,gtwCaseList[i].New_Account_Billing_Zip_Postal_Code__c);
        }
        
        //Updating cases to change the gateway account        
        for(integer i = 0; i < 200 ; i++)
        {
            gtwCaseList[i].Gateway_Account__c = gtwAccountList[200+i].ID;
        }
        update gtwCaseList;
        
        //Checking that address and industry fields have been correctly updated on the cases
        gtwCaseList = [Select ID, Gateway_Account__c, New_Account_Billing_Country__c, Industry__c, New_Account_Billing_City__c, New_Account_Billing_State_Province__c, New_Account_Billing_Street__c, New_Account_Billing_Zip_Postal_Code__c from Case where ID IN: gtwCaseList];
        for(integer i = 0; i < 200 ; i++)
        {
            gtwAccount = gtwAccountMap.get(gtwCaseList[i].Gateway_Account__c);
            System.assertEquals(gtwAccount.Country__c,gtwCaseList[i].New_Account_Billing_Country__c);
            System.assertEquals(gtwAccount.Industry_Name__c,gtwCaseList[i].Industry__c);
            System.assertEquals(gtwAccount.City_Name__c,gtwCaseList[i].New_Account_Billing_City__c);
            System.assertEquals(gtwAccount.State_Name__c,gtwCaseList[i].New_Account_Billing_State_Province__c);
            System.assertEquals(gtwAccount.Main_Address__c,gtwCaseList[i].New_Account_Billing_Street__c);
            System.assertEquals(gtwAccount.Postal_Address__c,gtwCaseList[i].New_Account_Billing_Zip_Postal_Code__c);
        }
    }  
}