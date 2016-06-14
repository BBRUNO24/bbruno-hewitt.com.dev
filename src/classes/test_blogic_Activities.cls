@isTest(seeAllData=True)
private class test_blogic_Activities{

// Added by SunnyM for Case# 00110071
static testMethod void test_UpdateCampaign(){

    List<Campaign> myCampaigns = new List<Campaign>();
    list<Task> myTaskslist1 = new List<Task>();
    list<Task> myTasksList2 = new List<Task>();
    List<Task> deleteTasklist = new List<Task>();
    User testUser = new User();
    Account account = null;
    Campaign campaign1 = new Campaign();
    Campaign campaign2 = new Campaign();
        
    Test.startTest();
        
    //Insert User
    testUser = util_SampleDataGenerator.createUser([select id from Profile where Name = 'Standard User Profile']);      
    System.assertNotEquals(null, testUser.id);
            
    // create an account
    account = util_SampleDataGenerator.createAccount_Client();
    System.assertNotEquals(null, account.Id);

    //Insert New Campaign
    campaign1 = new Campaign();
    campaign1.Name = 'New Campaign1';
    Insert campaign1;
            
    system.assertnotequals(campaign1.id,null);
            
    //Insert New Campaign
    campaign2 = new Campaign();
    campaign2.Name = 'New Campaign2';
    Insert campaign2;

    system.assertnotequals(campaign2.id,null);        

    // Insert & build list of Tasks to perform checks 
    for(integer i=0; i<=400 ; i++)
    {
        Task myTask = new Task();
        myTask.OwnerID = testUser.id;
        myTask.Priority = 'Normal';
        myTask.Subject = 'Call';
        
        if(i>0 && i < 100)
        {
            myTask.WhatID = campaign1.ID;
            //For first 50 records insert them as Open for Campaign1
            if(i<50)
            {
                myTask.Status = 'Not Started';
            }
            //Next 49 records to be inserted as completed for Campaign1
            else if(i > 50)
            {
                myTask.Status = 'Completed';
            }
        }
        else if( i >=100 && i < 300)
        {
            myTask.WhatID = campaign2.ID;
            //For first 50 records insert them as Open for Campaign2
            if(i<150)
            {
                myTask.Status = 'Not Started';
            }
            //For first 149 records insert them as completed for Campaign2
            else if(i > 150)
            {
                myTask.Status = 'Completed';   
            }
        }
        //For last 100 task, associate them to account for later updates
        else if (i > 300)
        {
            if(i < 325)
            {
                myTask.WhatID = null;
                myTask.Status = 'Completed';
            }
            else
            {
                myTask.WhatID = account.Id;
                myTask.Status = 'Completed';
            }
        }
        myTaskslist1.add(myTask);
    }
    
    Insert myTaskslist1;
    
    campaign1 = [select id,Total_Num_of_Open_Activities__c,Num_of_Completed_Acticities__c from campaign where id = : campaign1.id];
    campaign2 = [select id,Total_Num_of_Open_Activities__c,Num_of_Completed_Acticities__c from campaign where id = : campaign2.id];
    System.assertequals(50,campaign1.Total_Num_of_Open_Activities__c);
    system.assertequals(49, campaign1.Num_of_Completed_Acticities__c);
    System.assertequals(51, campaign2.Total_Num_of_Open_Activities__c);
    system.assertequals(149, campaign2.Num_of_Completed_Acticities__c);

    //Check for Update scenario Update       
    for(integer j=0; j< 400 ; j++)
    {
        //Update all completed task for Campaign1 as Open
        if(j>50 && j < 100)
        {
            myTaskslist1[j].status = 'In Progress';
        }
        //Update Task associated to accounts to be associated to campaign
        else if(j > 300)
        {
            if(j > 350)
            {
                myTaskslist1[j].WhatID = null;
            }
            else
            {
            	myTaskslist1[j].WhatID = campaign1.id;
            }
        }
    }
    update myTaskslist1;
    campaign1 = [select id,Total_Num_of_Open_Activities__c,Num_of_Completed_Acticities__c from campaign where id = : campaign1.id];       
    System.assertequals(99,campaign1.Total_Num_of_Open_Activities__c);
    system.debug('Check Open campaign again' + campaign1.Total_Num_of_Open_Activities__c);
    system.debug('Check completed campaign again' + campaign1.Num_of_Completed_Acticities__c);
    system.assertequals(50, campaign1.Num_of_Completed_Acticities__c);
    
    //Check for delete scenario
    deleteTasklist = [select id,whatid from task where whatid = : campaign2.ID and Status = : 'Completed'];
    delete deleteTasklist;
    campaign2 = [select id,Total_Num_of_Open_Activities__c,Num_of_Completed_Acticities__c from campaign where id = : campaign2.id];
    System.assertequals(51,campaign2.Total_Num_of_Open_Activities__c);
    system.assertequals(null, campaign2.Num_of_Completed_Acticities__c);
    
    //Check for Undelete scenario
    undelete deleteTasklist;
    campaign2 = [select id,Total_Num_of_Open_Activities__c,Num_of_Completed_Acticities__c from campaign where id = : campaign2.id];
    System.assertequals(51,campaign2.Total_Num_of_Open_Activities__c);
    system.assertequals(149, campaign2.Num_of_Completed_Acticities__c);

    Test.stopTest();
    }
}