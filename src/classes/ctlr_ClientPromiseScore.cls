//Implemented for Case 52501. Chintan Adhyapak. February 18, 2013
public without sharing class ctlr_ClientPromiseScore {
	//local vars
	public integer score	{get; set;}

	/** constructor */
    public ctlr_ClientPromiseScore(ApexPages.StandardController controller) {
        Account account = (Account)controller.getRecord();
        
        //Look for a Client Plan record for the same Year
        String currYear = String.valueOf(System.today().year());
        List<Annual_Account_Plan__c> planList = [Select  Client_Promise_Score__c From Annual_Account_Plan__c 
        		Where Account_Plan_Year__c = :currYear And Account__c = :account.Id Limit 1];
    	
    	//Read Client Promise Score
    	score = planList.size() > 0 ? Integer.valueOf(planList[0].Client_Promise_Score__c) : 0;
    }
}