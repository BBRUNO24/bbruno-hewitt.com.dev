/************************************************************************************************************
Author: Sunny Mohla
Class Name: blogic_Case
Purpose: This class will only work for cases where recordtype is Enhancement Request. This class contains
         code which will validate that the data enetered will be entered sequentially.
**************************************************************************************************************/ 
public without sharing class blogic_Case
{
     public static void ValidateDataSection()
     {
        Case[] newCases = (Case[])Trigger.new;
        Case[] oldCases = (Case[])Trigger.old;
        list<String> contactIdList = new list<String>();
        list<Contact> contactSelect = new list<Contact>();
        Id EnhancementRecordType = util_sampleDataGenerator.getRecordType('Case','Enhancement Request').Id;
        System.debug(EnhancementRecordType);
        for(integer i=0;i<newCases.size();i++)
        {
             Boolean bDirty = False;               

            if(newCases[i].RecordTypeId == EnhancementRecordType && newCases[i].Override_Enhancement_check__c == false)
            {                    
                //Case 1 - User trying to complete Requirement section without entering all fields for requirement section
                if(newCases[i].Req_Review_Complete__c == 'Yes' && bDirty == False && (newCases[i].Req_Analysis_Impact__c == NULL || newCases[i].Rq_Reviewer__c == NULL || newCases[i].Req_Reviewer_s_Comments__c == NULL))
                {
                    System.debug('Error for Case 1');
                    newCases[i].addError(Label.Case_Requirement_Complete);
                    bdirty = True;                    
                }
                 
                //Case 2 - User trying to save values in Design section without completing requirements section   
                else if(newCases[i].Req_Review_Complete__c != 'Yes' && bDirty == False && (newCases[i].Design_Development_Changes__c != NULL || newCases[i].Design_Reviewer__c != NULL || newCases[i].Design_Reviewer_s_Comments__c != NULL || newCases[i].Design_Review_Complete__c != NULL || newCases[i].Dev_Test_Results__c != NULL || newCases[i].Dev_Testing_Complete__c != NULL || newCases[i].QA_Testing_Comments__c !=NULL || newCases[i].QA_Test_Results__c != NULL || newCases[i].Design_Review_Complete__c != NULL || newCases[i].Other_Interested_Parties__c != NULL || newCases[i].UAT_Test_Cases__c != NULL || newCases[i].UAT_Testing_Complete__c != NULL || newCases[i].User_Guide_Update__c == True || newCases[i].User_Communication__c == True || newCases[i].Ready_for_Migration__c != NULL || newCases[i].Due_Date__c != NULL || newCases[i].Migration_Complete__c != NULL || newCases[i].Migration_Complete__c != NULL || newCases[i].Migrated_On__c !=NULL  || newCases[i].Validated_by_IT__c == True || newCases[i].Validated_by_User__c == True))
                {
                    System.debug('Error for Case 2');
                    newCases[i].addError(Label.Complete_Requirement_Section);
                    bdirty = True;                    
                }
                
                //Case 3 - User trying to complete Design section without completing all fields of Design section
                else if(newCases[i].Design_Changes_Complete__c == 'Yes' && bDirty == False && (newCases[i].Design_Reviewer_s_Comments__c == NULL || newCases[i].Design_Reviewer__c == NULL || newCases[i].Design_Development_Changes__c == NULL || newCases[i].Req_Review_Complete__c != 'Yes'))
                {
                    System.debug('Error for Case 3');
                    newCases[i].addError(Label.Case_Design_Complete);
                    bdirty = True;
                }
                
                //Case 4 - User trying to add values for Development Review and QA Testing without completing Design section
                else if(newCases[i].Design_Changes_Complete__c != 'Yes' && bDirty == False && (newCases[i].Dev_Test_Results__c != NULL || newCases[i].Dev_Testing_Complete__c != NULL || newCases[i].QA_Testing_Comments__c !=NULL || newCases[i].QA_Test_Results__c != NULL || newCases[i].Design_Review_Complete__c != NULL || newCases[i].Other_Interested_Parties__c != NULL || newCases[i].UAT_Test_Cases__c != NULL || newCases[i].UAT_Testing_Complete__c == 'Passed' || newCases[i].User_Guide_Update__c == True || newCases[i].User_Communication__c == True || newCases[i].Ready_for_Migration__c == 'Yes' || newCases[i].Due_Date__c != NULL || newCases[i].Migration_Complete__c != NULL || newCases[i].Migration_Complete__c == 'Yes' || newCases[i].Migrated_On__c !=NULL  || newCases[i].Validated_by_IT__c == True || newCases[i].Validated_by_User__c == True))
                {
                    System.debug('Error for Case 4');
                    newCases[i].addError(Label.Design_and_Development_section_complete);
                    bdirty = True;                    
                }
                
                //Case 5 - User trying to complete Development and QA Testing without completing Design section
                else if(newCases[i].Design_Review_Complete__c == 'Yes' && bDirty == False && (newCases[i].QA_Test_Results__c == NULL || newCases[i].QA_Testing_Comments__c == NULL || newCases[i].Dev_Testing_Complete__c == NULL || newCases[i].Dev_Test_Results__c == NULL || newCases[i].Design_Changes_Complete__c != 'Yes'))
                {
                    System.debug('Error for Case 5');
                    newCases[i].addError(Label.Case_Devlopment_and_QA_Complte);
                    bdirty = True;                    
                }
                
                //Case 6 - User trying to enter values in UAT section without completing Design section
                else if(newCases[i].Design_Review_Complete__c != 'Yes' && bDirty == False && (newCases[i].Other_Interested_Parties__c != NULL || newCases[i].UAT_Test_Cases__c != NULL || newCases[i].UAT_Testing_Complete__c != NULL || newCases[i].User_Guide_Update__c == True || newCases[i].User_Communication__c == True || newCases[i].Ready_for_Migration__c != NULL || newCases[i].Due_Date__c != NULL || newCases[i].Migration_Complete__c != NULL || newCases[i].Migration_Complete__c != NULL || newCases[i].Migrated_On__c !=NULL  || newCases[i].Validated_by_IT__c == True || newCases[i].Validated_by_User__c == True))
                {
                    System.debug('Error for Case 6');
                    newCases[i].addError(Label.Dev_Review_and_QA);
                    bdirty = True;                    
                }
                
                //Case 7 - User trying to pass UAT Tests without entering fields in UAT section
                else if(newCases[i].UAT_Testing_Complete__c == 'Passed' && bDirty == False && (newCases[i].UAT_Test_Cases__c == NULL || newCases[i].Design_Review_Complete__c != 'Yes'))
                {
                    System.debug('Error for Case 7');
                    newCases[i].addError(Label.Case_UAT_Complete);
                    bdirty = True;
                }
                
                //Case 8 - User trying to mark case ready for migration without completing UAT section
                else if(newCases[i].UAT_Testing_Complete__c != 'Passed' && bDirty == False && (newCases[i].Ready_for_Migration__c != NULL || newCases[i].Due_Date__c != NULL || newCases[i].Migration_Complete__c != NULL || newCases[i].Migration_Complete__c != NULL || newCases[i].Migrated_On__c !=NULL  || newCases[i].Validated_by_IT__c == True || newCases[i].Validated_by_User__c == True))
                {
                    System.debug('Error for Case 8');
                    newCases[i].addError(Label.UAT_Complete);
                    bdirty = True;
                }
                
                //Case 9 - Validation for Planned Migration date
                else if(newCases[i].Migration_Complete__c == 'Yes' && bDirty == False && (newCases[i].Due_Date__c == NULL || newCases[i].Ready_for_Migration__c != 'Yes'))
                {
                    System.debug('Error for Case 9');
                    newCases[i].addError(Label.Planned_Migration_for_Case);
                    bdirty = True;
                }
                
                //Case 10 - Validated by IT and by user cannot be clicked if migration not complete
                else if(newCases[i].Migration_Complete__c != 'Yes' && bDirty == False && (newCases[i].Validated_by_IT__c == True || newCases[i].Validated_by_User__c == True))
                {
                    System.debug('Error for Case 10');
                    newCases[i].addError(Label.Migration_Complete);
                    bdirty = True;
                }
               
                //Case 11 - User tried to validate though it has not been validated by IT
                else if(newCases[i].Validated_by_User__c == True && bDirty == False && newCases[i].Validated_by_IT__c == False)
                {
                    System.debug('Error for Case 11');
                    newCases[i].addError(Label.Case_Validate_by_User);
                    bdirty = True;
                }
                //Case 12 - Due date cannot be less than current date
                
                /*else if(newCases[i].Due_Date__c <= System.Now() && bDirty == False)
                {
                    System.debug('Error for Case 12');
                    newCases[i].addError(Label.Planned_Migration_Date_for_Cases);
                    bdirty = True;
                } */
                
                //Reset all the fields when Requirements Complete is set to 'No' or 'In Progress'
                if(newCases[i].Req_Review_Complete__c == 'No' || newCases[i].Req_Review_Complete__c == 'In Progress')
                {
                    newCases[i].Design_Development_Changes__c = '';
                    //newCases[i].Design_Reviewer__c = '';
                    newCases[i].Design_Reviewer_s_Comments__c = '';
                    newCases[i].Design_Changes_Complete__c = '';
                    newCases[i].Dev_Test_Results__c = '';
                    newCases[i].Dev_Testing_Complete__c = '';
                    newCases[i].QA_Testing_Comments__c = '';
                    newCases[i].QA_Test_Results__c = '';
                    newCases[i].Design_Review_Complete__c = '';
                    newCases[i].UAT_Test_Cases__c = '';
                    newCases[i].UAT_Testing_Complete__c = '';
                    newCases[i].User_Communication__c = False;
                    newCases[i].User_Guide_Update__c = False;
                    newCases[i].Ready_for_Migration__c = '';
                    //newCases[i].Due_Date__c = '';
                    newCases[i].Migration_Complete__c = '';
                    newCases[i].Validated_by_IT__c = False;
                    newCases[i].Validated_by_User__c = False;
                    bDirty = True;
                } 
            }
        }       
     }
     
     //00020385 - Populating old region & country fiels as they are used in criteria based sharing rules, since criteria based sharing rules can't refer formula fields hence we have to keep old fields
     public static void populateReportingAtt()
     {
        Case[] newCases = (Case[])Trigger.new;
        for(integer i=0;i<newCases.size();i++)
        {
            newCases[i].Reporting_Region__c=newCases[i].Reporting_Region_New__c;
            newCases[i].Reporting_Country__c=newCases[i].Reporting_Country_New__c;            
        }
     }     
    
    //00109262-Ritu Sharma-Update IsConverted flag in Gateway Account
    public static void updateGatewayAccounts(List<Case> newCaseList,List<Case> oldCaseList)
    {
        //Declaring Variables
        List<ID> gtwAccIDList = new List<ID>();
        List<Gateway_Account__c> gtwAccList; //List of gateway accounts
        List<Gateway_Account__c> gtwAccUpdateList; //List of gateway accounts that need to be updated
        
        //Looping through all accounts to get a list of gateway account ids
        for(integer i = 0; i< newCaseList.size();i++)
        {
            //Checking is this is the gateway account conversion case and has just been implemented and closed
            if(newCaseList[i].Gateway_Account__c!=Null && newCaseList[i].Status!=oldCaseList[i].Status && newCaseList[i].Status == 'Closed - Implemented')
                gtwAccIDList.add(newCaseList[i].Gateway_Account__c);
        }
        
        if(gtwAccIDList.size()>0)
        {        
            //Getting hanlde of gateway accounts
            gtwAccList = [select id, Is_Converted__c from Gateway_Account__c where ID in : gtwAccIDList];
            
            //Looping through gateway accounts to prepare a list of accounts that need to be updated
            gtwAccUpdateList = new List<Gateway_Account__c>();
            for(integer j = 0; j <gtwAccList.size(); j++)
            {
                if (!gtwAccList[j].Is_Converted__c) //Checking to avoid unnecessary updates
                {
                    gtwAccList[j].Is_Converted__c=True;
                    gtwAccUpdateList.add(gtwAccList[j]);
                }
            }
            
            //Updating gateway accounts
            Update gtwAccUpdateList;  
         }     
     } 
     
    //00109262-Ritu Sharma-This function will populate address fields on case from the selected gateway account(s) 
    public static void populateAddressfields(List<Case> newCaseList, List<Case> oldCaseList)
    {
        //Declaring and initializing variables
        List<ID> gtwAccIDList = new List<ID>(); //List of gateway account ids
        Map<ID,Gateway_Account__c> gtwAccMap;
        Gateway_Account__c gtwAccount;        
       
        //Looping through all cases to prepare a list of gateway account ids
        for(integer i = 0; i < newCaseList.size(); i++)
        {
            if (newCaseList[i].Gateway_Account__c!=Null) //It's a gateway account coversion request case
                gtwAccIDList.add(newCaseList[i].Gateway_Account__c);
        }
        
        if(gtwAccIDList.size()>0)
        {
            //Getting handle of corresponding gateway accounts       
            gtwAccMap = new Map<ID, Gateway_Account__c>([select ID,City_Name__c,State_Name__c,Postal_Address__c,Main_Address__c,Industry_Name__c,Country__c from Gateway_Account__c where ID in : gtwAccIDList]);
    
            //Looping through all cases to refresh the address fields
            for(integer i = 0; i < newCaseList.size(); i++)
            {
                if (newCaseList[i].Gateway_Account__c!=Null) //It's a gateway account coversion request case
                {
                    gtwAccount = gtwAccMap.get(newCaseList[i].Gateway_Account__c);
                    if(trigger.isUpdate && newCaseList[i].Gateway_Account__c!=oldCaseList[i].Gateway_Account__c) //Update and account changed
                    {
                        //Refresh the case fields if information is available in gateway account
                        if(gtwAccount.Industry_Name__c!=Null) 
                            newCaseList[i].Industry__c = gtwAccount.Industry_Name__c;                        
                        if(gtwAccount.Country__c!=Null)                     
                            newCaseList[i].New_Account_Billing_Country__c = gtwAccount.Country__c;                    
                        if(gtwAccount.City_Name__c!=Null)                     
                            newCaseList[i].New_Account_Billing_City__c = gtwAccount.City_Name__c;
                        if(gtwAccount.Main_Address__c!=Null)                                         
                            newCaseList[i].New_Account_Billing_Street__c=gtwAccount.Main_Address__c;                    
                        if(gtwAccount.Postal_Address__c!=Null)                     
                            newCaseList[i].New_Account_Billing_Zip_Postal_Code__c=gtwAccount.Postal_Address__c;                    
                        if(gtwAccount.State_Name__c!=Null)                     
                            newCaseList[i].New_Account_Billing_State_Province__c=gtwAccount.State_Name__c;
                    }                
                    else //insert or Update but account not changed
                    {
                        //Set address fields if user has not explicitly specified any value
                        if (newCaseList[i].Industry__c==Null)
                            newCaseList[i].Industry__c = gtwAccount.Industry_Name__c;                    
                        if(newCaseList[i].New_Account_Billing_Country__c==Null)
                            newCaseList[i].New_Account_Billing_Country__c = gtwAccount.Country__c;                    
                        if(newCaseList[i].New_Account_Billing_City__c==Null)   
                            newCaseList[i].New_Account_Billing_City__c=gtwAccount.City_Name__c;
                        if(newCaseList[i].New_Account_Billing_Street__c==Null)
                            newCaseList[i].New_Account_Billing_Street__c=gtwAccount.Main_Address__c;
                        if(newCaseList[i].New_Account_Billing_Zip_Postal_Code__c==Null)
                            newCaseList[i].New_Account_Billing_Zip_Postal_Code__c=gtwAccount.Postal_Address__c;
                        if(newCaseList[i].New_Account_Billing_State_Province__c==Null)
                            newCaseList[i].New_Account_Billing_State_Province__c=gtwAccount.State_Name__c;
                    }
                }
            }    
        } 
    }       
}