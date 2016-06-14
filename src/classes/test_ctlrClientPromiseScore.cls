/** Test Class for Controller. Chintan, June 18, 2014
 */
@isTest(SeeAllData=true)
private class test_ctlrClientPromiseScore {

    static testMethod void myUnitTest() {
        //Create an Account
    	Account myAccount = util_sampleDataGenerator.createAccount_Client();
        System.assertNotEquals(null, myAccount.Id);
        
        //Create a client Plan
    	Annual_Account_Plan__c myPlan = new Annual_Account_Plan__c();
    	myPlan.Account__c = myAccount.Id;
    	myPlan.Account_Plan_Year__c = '2014';
    	insert myPlan;
    	System.assertNotEquals(null, myPlan.Id);
        
        Test.startTest();
        	
        	//Handle to the Apex page          
        	PageReference pageRef = Page.Client_Promise_Score;
        	Test.setCurrentPage(pageRef);
        
	        //Get controller handles
        	ApexPages.standardController stdController = new ApexPages.standardController(myAccount);
        	ctlr_ClientPromiseScore cusController = new ctlr_ClientPromiseScore(stdController);

        Test.stopTest();
    } //myUnitTest
}