/************************************************************************************************************
Author: Shreyas Ringe
Class Name: populateCompetitorOnAccountClass
Trigger using this class: populateCompetitorOnAccount
Purpose: 
Populate the field Competetor (hidden from the page) which is a Lookup to the 'Core_Service_Providers__c' object (Parent) on the account  
with the Id of the newly created 'Core_Service_Providers__c' record (child of the account object) via the related list so as to
populate the following fields on account record.   
**************************************************************************************************************/ 


public class populateCompetitorOnAccountClass {
    
    public static void populateCompetitor(){
        
        Core_Service_Providers__c [] newCspList = (Core_Service_Providers__c [])Trigger.new;
    	Core_Service_Providers__c [] oldCspList = (Core_Service_Providers__c [])Trigger.old;
    	Map<String, String> accIdCspIdmap = new Map<String, String>();
    	List<String> accId1 = new List<String>();
    	List<String> accId2 = new List<String>();
    	List<Account> tempAccList1 = new List<Account>();
    	List<Account> tempAccList2 = new List<Account>();
    	
    	
    	if(trigger.isinsert || trigger.isupdate)
    	{
    		if(trigger.isinsert)
    			for(integer i=0;i<newCspList.size();i++)
    			{
    				accIdCspIdmap.put(newCspList[i].Account__c, newCspList[i].Id);
    				accId1.add(newCspList[i].Account__c);    			   		
    			}	
    		
    		if(trigger.isupdate)
    		{    			
    			for(integer i=0;i<oldCspList.size();i++)
    			{
    				if(oldCspList[i].Account__c != newCspList[i].Account__c)
    				{
    					accIdCspIdmap.put(newCspList[i].Account__c, newCspList[i].Id);
    					accId1.add(newCspList[i].Account__c);
    					accId2.add(oldCspList[i].Account__c);
    				}
    			}   		
    		}	
    	
    	system.debug('capturing the Account Id-' + accIdCspIdmap.keySet() + ' for the CoreServiceProvider, id-' + accIdCspIdmap.values());    
    	system.debug('accId1 List: ' + accId1);
    	system.debug('accId2 List: ' + accId2);
    	}


		if(trigger.isdelete)
		{
			for(integer i=0;i<oldCspList.size();i++)
    		{
    		accId2.add(oldCspList[i].Account__c);
    		}
    		system.debug('accId2 List: ' + accId2);
		}


    	
    	if(accId1.size()>0)
    	{
    	tempAccList1 = [Select a.Id, a.Competitor__c From Account a where a.Id IN: accId1];
    	system.debug('capturing the accounts to be updated: ' + tempAccList1);
    	
    	for(integer i=0;i<tempAccList1.size();i++)
    	{
    		tempAccList1[i].Competitor__c = accIdCspIdmap.get(tempAccList1[i].Id);
    	}
    	
    	try
    	{ update tempAccList1; }
    	
    	catch(Exception e) {}
    		
    	} 
		
    	if(accId2.size()>0)
    		{
    		tempAccList2 = [Select a.Id, a.Competitor__c From Account a where a.Id IN: accId2];
    		system.debug('capturing the accounts to be updated: ' + tempAccList2);
    		
    		for(integer i=0;i<tempAccList2.size();i++)
    		{
    		tempAccList2[i].Competitor__c = null;
    		}
    		
    		try
    		{ update tempAccList2; }
    	
    		catch(Exception e) {}
    		}
    		
		
    }
}