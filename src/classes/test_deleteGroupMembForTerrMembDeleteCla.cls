@isTest(SeeAllData=true)
public with sharing class test_deleteGroupMembForTerrMembDeleteCla {

        static testMethod void territoryMemberandGroupSync() {
            
      /*  List<Territory_Member__c> listTerritoryMember = new List<Territory_Member__c>();
        List<GroupMember> listGroupMember = new List<GroupMember>();
        list<GroupMember> groupMembersSelect = new list<GroupMember>();
            
        //Create a user with the Financial Approver Users role
        Profile stduserProfile = [SELECT Id FROM Profile Where Name = 'Standard User'];
        User stdUser1 = util_sampleDataGenerator.createUser(stduserProfile);
        User stdUser2 = util_sampleDataGenerator.createUser(stduserProfile);
        User stdUser3 = util_sampleDataGenerator.createUser(stduserProfile);
        User stdUser4 = util_sampleDataGenerator.createUser(stduserProfile);
        
        User admin = util_SampleDataGenerator.createUser([select id from Profile where Name = 'System Administrator']);
        System.assertNotEquals(null, admin.id);
        
        Group newGroup = new Group(Name='Test Group',DEVELOPERNAME = 'TestGroup');
        insert newGroup;*/
        
       // system.debug('Group ID is: ' + newGroup.Id);
       // GroupMember GM1 = new GroupMember(GroupID = newGroup.Id, USERORGROUPID = stdUser1.Id);
       // insert GM1;
       // GroupMember GM2 = new GroupMember(GroupID = newGroup.Id, USERORGROUPID = stdUser2.Id);
       // insert GM2;
       // GroupMember GM3 = new GroupMember(GroupID = newGroup.Id, USERORGROUPID = stdUser3.Id);
       // insert GM3;
       // GroupMember GM4 = new GroupMember(GroupID = newGroup.Id, USERORGROUPID = stdUser4.Id);
       // insert GM4;
        
      //  groupMembersSelect = [Select g.UserOrGroupId, g.Id, g.GroupId From GroupMember g where g.GroupId =: newGroup.Id];
      //  system.debug('groupMembersSelect' + groupMembersSelect.size());
        
      /*  System.runAs(admin) {
        Territory__c T1 = new Territory__c(Name = 'test1',Public_Group_Id__c = newGroup.Id);
        Insert T1;
        system.debug('Territory 1 '+ T1.ID);
        
        Territory_Member__c TM1 = new Territory_Member__c (User__c = stdUser1.Id, Territory__c = T1.ID);
        try {Insert TM1; } catch(Exception e) {}
        TM1 = [select id,Parent_Territory_Group_Id__c,Territory_Id__c from Territory_Member__c where id = : TM1.ID];
        system.debug('First ID' + TM1.ID);
        system.debug('Parent or Group ID of TM1' + TM1.Parent_Territory_Group_Id__c);
        system.debug('Territory ID 1' + TM1.Territory_Id__c);
        Territory_Member__c TM2 = new Territory_Member__c (User__c = stdUser2.Id, Territory__c = T1.ID);
        try {Insert TM2; } catch(Exception e) {}
        TM2 = [select id,Parent_Territory_Group_Id__c,Territory_Id__c from Territory_Member__c where id = : TM2.ID];
        system.debug('Second ID' + TM2.ID);
        system.debug('Parent or Group ID of TM2' + TM2.Parent_Territory_Group_Id__c);
        Territory_Member__c TM3 = new Territory_Member__c (User__c = stdUser3.Id, Territory__c = T1.ID);
        try {Insert TM3; } catch(Exception e) {}
        TM3 = [select id,Parent_Territory_Group_Id__c,Territory_Id__c from Territory_Member__c where id = : TM3.ID];
        system.debug('Third ID' + TM3.ID);
        system.debug('Parent or Group ID of TM3' + TM3.Parent_Territory_Group_Id__c);
        Territory_Member__c TM4 = new Territory_Member__c (User__c = stdUser4.Id, Territory__c = T1.ID);
        try {Insert TM4; } catch(Exception e) {}
        TM4 = [select id,Parent_Territory_Group_Id__c,Territory_Id__c from Territory_Member__c where id = : TM4.ID];
        system.debug('Fourth ID' + TM4.ID);
        system.debug('Parent or Group ID of TM4' + TM4.Parent_Territory_Group_Id__c);
        
        listTerritoryMember = [select id, Name from Territory_Member__c where Territory__c = : T1.ID];
        listGroupMember = [select id, GroupID from GroupMember where GroupID = : newGroup.Id];
        
        System.AssertEquals(listTerritoryMember.size(),listGroupMember.size());
        
      //  delete TM1;
        
      //  listTerritoryMember = [select id, Name from Territory_Member__c where Territory__c = : T1.ID];
      //  listGroupMember = [select id, GroupID from GroupMember where GroupID = : newGroup.Id];
        
      //  System.AssertEquals(listTerritoryMember.size(),listGroupMember.size());
      
        }*/
        }


}