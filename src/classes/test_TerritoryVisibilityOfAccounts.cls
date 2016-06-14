/****************************************************************************
 * This test class has the coverage for the following classes:
 
 * createNewPublicGroupForNewTerritoryClass
 * createNewTerrMembersAsGroupMembersClass
 * createNewTerrMembersAsGroupMembersFClass 
 * deleteGroupMembForTerrMembDeleteClass
 * deletePublicGroupforTerritoryDeleteClass
 * deleteGroupforTerritoryDeleteFClass
 * deleteGroupMembForTerrMembDeleteFClass   
 * shareAccountsOnBasisOfStateClass 
 
 ****************************************************************************/
 
 
@isTest
private class test_TerritoryVisibilityOfAccounts {

    static testMethod void territoryVisiblityCoverage() 
    {                
        Territory__c T1 = new Territory__c(Name = 'test1');
        Insert T1;
        
        Territory__c T2 = new Territory__c(Name = 'test2');
        Insert T2;
        
        //Case No. 39290 - Ritu Sharma - Removed hardcoded user id, now using id of the current user
        //Territory_Member__c TM1 = new Territory_Member__c (User__c = '00530000004Rb9M', Territory__c = T1.ID);
        Territory_Member__c TM1 = new Territory_Member__c (User__c = UserInfo.getUserID(), Territory__c = T1.ID);

        try {Insert TM1;} catch(Exception e) {}

        
        Territory__c T1withParent_1 = new Territory__c(Name = 'test_withParent1', Parent_territory__c = T1.ID);
        try {Insert T1withParent_1;} catch(Exception e) {}
        
        Territory__c T1withParent_2 = new Territory__c(Name = 'test_withParent2', Parent_territory__c = T2.ID);
        Insert T1withParent_2;
        
        //Case No. 39290 - Ritu Sharma - Removed hardcoded user id, now using id of the current user
        //Territory_Member__c TM2 = new Territory_Member__c (User__c = '00530000004Rb9R', Territory__c = T1.ID);
        Territory_Member__c TM2 = new Territory_Member__c (User__c = UserInfo.getUserID(), Territory__c = T1.ID);
        try {Insert TM2; } catch(Exception e) {}
        
        //Case No. 39290 - Ritu Sharma - Removed hardcoded user id, now using id of the current user
        //Territory_Member__c TM3 = new Territory_Member__c (User__c = '00530000004Rb9R');
        Territory_Member__c TM3 = new Territory_Member__c (User__c = UserInfo.getUserID());
        try {Insert TM3;} catch(Exception e) {}

        try{delete T2;} catch(Exception e) {}
        delete T1withParent_1;                
        delete TM1;
        delete TM2;
        delete T1;
        
        Account A1 = util_sampleDataGenerator.createAccount_Client();        
        A1.BillingState = 'CA';
        update A1;
    }
}