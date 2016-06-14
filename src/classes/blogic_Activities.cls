//Created by SunnyM for Case# 00110071 This class will only work for task which are related to Campaign. This Code will update 2 fields
//Num_of_Completed_Acticities__c & Total_Num_of_Open_Activities__c on Campaign
//00128126-Ritu Sharma-Updated code to fix the reported issue
Public class blogic_Activities
{
    public static void updateCampaign(List<Task> newTasklist, List<Task> oldTasklist)
    {
        List<string> listcampaigns = new List<string>();
        Map<ID,Integer> mapOpenCount = new Map<ID,Integer>();
        Map<ID,Integer> mapCompleteCount = new Map<ID,Integer>();
        List<AggregateResult> listcompletedAggregate = new List<AggregateResult>();
        List<AggregateResult> listnotCompletedAggregate = new List<AggregateResult>();
        List<Campaign> listCampaigntoUpdate = new List<Campaign>();

        //Loop through all activities to create a list of associated campaign ids
        if(Trigger.isDelete)
        {
            for(integer i=0; i < oldTasklist.size();i++)
            {
                //Add only those records which are not null and are campaign
                if(oldTasklist[i].WhatID != null && String.valueOf(oldTasklist[i].WhatID).startswith('701'))
                    listcampaigns.add(oldTasklist[i].WhatID);
            }
        }
        else if(Trigger.isInsert || Trigger.isUndelete)
        {
            for(integer i=0; i < newTasklist.size();i++)
            {
                //Add only those records which are not null and are campaign
                if(newTasklist[i].WhatID != null && String.valueOf(newTasklist[i].WhatID).startswith('701'))
                    listcampaigns.add(newTasklist[i].WhatID);
            }
        }
        else //Update
        {
            //Create a list of campaigns for which we need to update fields    
            for(integer i=0; i < newTasklist.size();i++)
            {
                // Incase of update only check for change in campaign ID since trigger.new is taking care of new list in above If statement
                if(Trigger.isUpdate)
                {
                    //Checking if either WhatID or Activity status has changed 
                    If(newTasklist[i].WhatID != oldTasklist[i].WhatID || newTasklist[i].ISCLOSED != oldTasklist[i].ISCLOSED)
                    {
                        //Add new WhatID to Update if it's campaign and not null
                        if(newTasklist[i].WhatID != null && String.valueOf(newTasklist[i].WhatID).startswith('701'))
                            listcampaigns.add(newTasklist[i].WhatID);
                            
                        //Add Old WhatID to Update if it's campaign, not null and has been changed
                        if (newTasklist[i].WhatID != oldTasklist[i].WhatID)
                        {
                            if(oldTasklist[i].WhatID != null && String.valueOf(oldTasklist[i].WhatID).startswith('701'))
                                listcampaigns.add(oldTasklist[i].WhatID);
                        }
                    }
                }
            }
        }
        
        if(listcampaigns.size() > 0)
        {
          //Get Counts of Open and Completed Tasks for Campaigns
          listcompletedAggregate = [SELECT WhatID,count(id) Total FROM Task WHERE WhatID IN :listcampaigns AND Status = 'Completed' GROUP BY WhatID]; 
          listnotCompletedAggregate = [SELECT WhatID,count(id) Total FROM Task WHERE WhatID IN :listcampaigns AND Status <> 'Completed' GROUP BY WhatID]; 
        
          //Create Map for Non Completed Count
          for(integer i = 0; i< listnotCompletedAggregate.size(); i++)
          {
              mapOpenCount.put((ID)listnotCompletedAggregate[i].get('WhatId'),(Integer)listnotCompletedAggregate[i].get('Total'));
          }
        
          //Create Map for completed count
          for(integer i = 0; i< listcompletedAggregate.size(); i++)
          {
              mapCompleteCount.put((ID)listcompletedAggregate[i].get('WhatId'),(Integer)listcompletedAggregate[i].get('Total'));
          }
        
          //Retrieve the campaign to be updated in a list and update
          listCampaigntoUpdate = [select id,Num_of_Completed_Acticities__c,Total_Num_of_Open_Activities__c from campaign where id in : listcampaigns];
          for(integer i = 0; i < listCampaigntoUpdate.size(); i++ )
          {
              listCampaigntoUpdate[i].Num_of_Completed_Acticities__c = mapCompleteCount.get(listCampaigntoUpdate[i].ID);
              listCampaigntoUpdate[i].Total_Num_of_Open_Activities__c = mapOpenCount.get(listCampaigntoUpdate[i].ID);
          }
          update listCampaigntoUpdate;
        }
    }
    
    //Added function below for case #00137492 by DaveM
    public static void SendClientRefRequestEmail(List<Task> newTasklist, List<Task> oldTasklist)
    {
        //Make a list of opportunity ids related to Client Reference Requests
        set<Id> oppIDs = new set<Id>();
        for(Task t : newtasklist){
            if(t.Type == 'Client Reference Request'){
                oppIDs.add(t.WhatId);
            }
        }
        //Get global settings
        ClientReference__c CRSettings = ClientReference__c.getInstance();
        
        //Get opportunity field data into a map
        map<Id, Opportunity> oppMap = new map<Id,Opportunity>([Select Id, Name, ReferenceRequestUser__c From Opportunity Where Id In : oppIDs]); 

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        //For each Task
        for(integer i=0; i < newTasklist.size();i++) {
            //If the task is a Client Refence Request and it is not complete and was not previously complete
            if(newTasklist[i].Type == 'Client Reference Request' && newTasklist[i].Status == 'Completed' && oldTaskList[i].Status != 'Completed'){

                //Get the opportunity data from the map
                Opportunity currOpp = oppMap.get(newTasklist[i].whatid);
                //Get the Requesting Users's information
                User RequestingUser = [select ID, name, email from user where id = :curropp.ReferenceRequestUser__c];

                //Create the email
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setTemplateId(CRSettings.TaskCompleteEmailTemplate__c);
                email.setTargetObjectID(RequestingUser.ID);
                email.setsaveAsActivity(FALSE);
                email.setwhatid(curropp.id);
                emails.add(email);
            }
        }
        
        //If we have any emails to send, send them.
        if(!emails.isEmpty()){
            Messaging.sendEmail(emails);
        }

    }    
}