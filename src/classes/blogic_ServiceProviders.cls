public without sharing class blogic_ServiceProviders {


	/************************************************************************************************************
	Author: Shreyas Ringe
	Method Name: createDefaultProviderEntries
	Purpose: 
	When an account is created, a corresponding record created in the followinf three objects: 
	
	-Consulting Service Provider
	-Outsourcing Service Provider
	-Point Solution Provider
	         
	**************************************************************************************************************/
	public static void createDefaultProviderEntries(List <Account> newAccounts)
	{
		// declare local vars
    	String defaultCoreServiceProviderName = 'List of Outsourcing Service Providers';
    	String defaultConsultingServiceProviderName = 'List of Consulting Service Providers';
    	String defaultPointSolutionProviderName = 'List of Point Solution Service Providers';
    	List<Core_Service_Providers__c> coreServiceProvidersInsertList = new List<Core_Service_Providers__c>();
    	List<Consulting_Service_Provider__c> consultingServiceProvidersInsertList = new List<Consulting_Service_Provider__c>();
    	List<Point_Solution_Providers__c> pointSolutionProvidersInsertList = new List<Point_Solution_Providers__c>();
    	
    	for(Account newAccount : newAccounts)
    	{
    		Core_Service_Providers__c coreServiceProvidersInsert = 
    			new Core_Service_Providers__c (Name = defaultCoreServiceProviderName, Account__c = newAccount.Id);
    		Consulting_Service_Provider__c consultingServiceProvidersInsert = 
    			new Consulting_Service_Provider__c (Name = defaultConsultingServiceProviderName, Account__c = newAccount.Id);
    		Point_Solution_Providers__c pointSolutionProvidersInsert = 
    			new Point_Solution_Providers__c (Name = defaultPointSolutionProviderName, Account__c = newAccount.Id);
									
			system.debug('coreServiceProvidersInsert: ' + coreServiceProvidersInsert);
			system.debug('consultingServiceProvidersInsert: ' + consultingServiceProvidersInsert);
			system.debug('pointSolutionProvidersInsert: ' + pointSolutionProvidersInsert);
			
			coreServiceProvidersInsertList.add(coreServiceProvidersInsert);
			consultingServiceProvidersInsertList.add(consultingServiceProvidersInsert);
			pointSolutionProvidersInsertList.add(pointSolutionProvidersInsert);

    	}
    	
    	insert coreServiceProvidersInsertList;
    	insert consultingServiceProvidersInsertList;
    	insert pointSolutionProvidersInsertList;
	}

}