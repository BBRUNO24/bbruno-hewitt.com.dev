@isTest
private class test_terrNameGroupNameSyncClass 
{
    static testMethod void myUnitTest() 
    {
        test.startTest(); //Test Start
        
        List<Territory__c> terrList = New List<Territory__c>();
        List<ID> groupIDList = new List<ID>();
        Map<ID,Group> groupMap = Null;
        Territory__c terr = Null;              
        Group pubGroup = Null;
                
        //Creating territories
        for (Integer i=0;i<200;i++)
        {
            terr = new Territory__c(name='Test Territory-'+i, Country__c='Austria');
            terrList.add(terr);
        }
        insert terrList;
        
        //Checking if territories have been successfully created
        for (Integer i=0;i<200;i++)
            System.assertNotEquals(terrList[i].ID, Null);

        //Updating territories
        globalUtility.territoryInsertOnlyCheck = true;
        for (Integer i=0;i<200;i++)
            terrList[i].Name='New Test Territory-'+i;
        update terrList;
        
        //Searching to refresh terrList     
        terrList = new List<Territory__c>([Select ID, Public_Group_Id__c, Public_Group_Name__c from Territory__c where ID IN: terrList]);
        //Preparing list of group ids
        for (Integer i=0;i<200;i++)
            groupIDList.add(terrList[i].Public_Group_Id__c);
        
        //Map of Groups
        groupMap = new Map<ID, Group>([Select ID, Name from Group where ID IN:groupIDList]);
        
        //Checking if new group name is reflecting in the group record
        for (Integer i=0;i<200;i++)
        {
            pubGroup = groupMap.get(terrList[i].Public_Group_Id__c);
            System.assertEquals(pubGroup.Name, terrList[i].Public_Group_Name__c);
        }
        test.stopTest(); //Test End
    }
}