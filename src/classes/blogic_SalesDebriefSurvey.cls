public without sharing class blogic_SalesDebriefSurvey {
    /** Creates Associated Service records for the Sales Debrief Survey
      * Case 43640. Chintan Adhyapak. December 04, 2012 */
    public static void createAssociatedServices(List<Sales_Debrief_Survey__c> newSurveys) {
        Map<Id, Id> opportunitySurveyMap = new Map<Id, Id> ();
        Map<Id, Id> bundledOppSurveyMap = new Map<Id, Id> ();
        List<Associated_Service__c> associatedServicesToCreate = new List<Associated_Service__c> ();
        List<Opportunity> oppsToUpdate = new List<Opportunity> ();
        
        //Cycle through and save data into a map
        for (Sales_Debrief_Survey__c mySurvey : newSurveys) {
            opportunitySurveyMap.put(mySurvey.Opportunity_ID__c, mySurvey.Id);
        }
        
        //Pull Opportunity Data
        List<Opportunity> opportunities = [Select Id, (Select Id, Opportunity_Product__c from OpportunityLineItems), (Select Id from Opportunities__r) from Opportunity Where Id In :opportunitySurveyMap.keySet()];
        for (Opportunity myOpp : opportunities) {
            System.debug('CHINTAN Working on Opportunity Id: ' + myOpp.Id);
            //Flag Opp for Survey
            myOpp.Sales_Debrief_Survey_Completed__c = 'Yes';
            oppsToUpdate.add(myOpp);
            
            //Read Services Tied to the Opp
            for (OpportunityLineItem lineItem : myOpp.OpportunityLineItems) {
                System.debug('CHINTAN Read Service Id: ' + lineItem.Opportunity_Product__c);
                associatedServicesToCreate.add(getAssociatedService(opportunitySurveyMap.get(myOpp.Id), lineItem.Opportunity_Product__c));
            }
            //Get Bundled Opps tied to this opp and store in a map
            for (Opportunity bundledOpp : myOpp.Opportunities__r) {
                System.debug('CHINTAN Read Bundled Opportunity Id: ' + bundledOpp.Id);
                bundledOppSurveyMap.put(bundledOpp.Id, opportunitySurveyMap.get(myOpp.Id));
            }
        }
        
        //Pull Bundled Opps Data
        opportunities = [Select Id, (Select Id, Opportunity_Product__c from OpportunityLineItems) from Opportunity Where Id = :bundledOppSurveyMap.keySet()];
        for (Opportunity myOpp : opportunities) {
            //Read Services tied to the Bundled Opp
            for (OpportunityLineItem lineItem : myOpp.OpportunityLineItems) {
                System.debug('CHINTAN Read Bundled Service Id: ' + lineItem.Opportunity_Product__c);
                associatedServicesToCreate.add(getAssociatedService(bundledOppSurveyMap.get(myOpp.Id), lineItem.Opportunity_Product__c));
            }
        }
        
        //Finally, insert Associated Services
        if (!associatedServicesToCreate.isEmpty()) {
            try {
                insert associatedServicesToCreate;
            } catch (Exception e) {
                System.debug('CHINTAN ERROR in Creating Survey Associated Services: ' + e.getMessage());
            }
        }
        
        //Update Opportunity Survey Flag
        System.debug('CPA In method createAssociatedServices, list oppsToUpdate is: ' + oppsToUpdate);
        update oppsToUpdate;
    } //createAssociatedServices


    //CSModBegin SunnyM 00070499 2July2013
    public static void createTaskRelatedtoDebriefSurvey(List<Sales_Debrief_Survey__c> listNewSurveys) {
        //local vars
        List<Task> listTasks = new List<Task> ();
        List<string> listInterviewers = new List<string> ();
        Map<Id, Contact> mapContactUsers;
        List<Sales_Debrief_Survey__c> surveyList = new List<Sales_Debrief_Survey__c> ();
        
        //Case 55319 - Only do this for sales debrief survey type and not End of Project Review Survey type
        //Chintan, September 5, 2013
        for (Sales_Debrief_Survey__c survey : listNewSurveys) {
        	if (survey.Sales_Survey_Type__c.equalsIgnoreCase('Sales Debrief') && survey.Account_Global_Region__c.equalsIgnoreCase('Asia Pacific')) {
        		surveyList.add(survey);
        		//get list of contact IDs
        		listInterviewers.add(survey.Interviewer_Name__c);
        	}
        }
        
        //Store Contact ID and corrsponding user Id in a map
        mapContactUsers = new Map<Id, Contact> ([select Id, Corresponding_User_Id__c from Contact where Id in :listInterviewers]);
 
        //Cycle through survey list and create task list
        for (Sales_Debrief_Survey__c mySurvey : surveyList) {
            System.debug('Interviewer is' + mapContactUsers.get(mySurvey.Interviewer_Name__c).Corresponding_User_Id__c);
            Task newTask = new Task();
            Datetime currentdate = System.now();
            newTask.WhatId = mySurvey.Opportunity_ID__c;
            newTask.WhoId = mySurvey.Contact__c;
            newTask.Subject = 'Sales Debrief Survey';
            newTask.priority = 'High';
            newTask.status = mySurvey.Status__c;
            newTask.description = mySurvey.Comments__c;
            //newTask.ActivityDate = mySurvey.Due_Date__c.addDays(28);
            newTask.ActivityDate = mySurvey.Due_Date__c != null ? mySurvey.Due_Date__c.addDays(28) : System.today().addDays(28);
            newTask.Type = 'Sales Debrief Survey';
            newTask.ISREMINDERSET = true;
            newTask.REMINDERDATETIME = currentdate.addDays(21);
            newTask.OWNERID = mapContactUsers.get(mySurvey.Interviewer_Name__c).Corresponding_User_Id__c;
            listTasks.add(newTask);
        }
                
        if(!listTasks.isEmpty())
            insert listTasks;
    } 
    //CSModEnd SunnyM 00070499 2July2013
    
    
    
    /** Private utility method to create and return an Associated Service record
      * Chintan Adhyapak. December 4, 2012 */
    private static Associated_Service__c getAssociatedService(Id surveyId, Id serviceId) {
        Associated_Service__c myRecord = new Associated_Service__c();
        myRecord.Sales_Debrief_Survey__c = surveyId;
        myRecord.Opportunity_Service__c = serviceId;
        return myRecord;
    } //getProposalService
}