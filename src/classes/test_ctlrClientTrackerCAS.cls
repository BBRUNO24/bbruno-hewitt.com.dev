/** Test Class for Controller. Chintan, June 18, 2014
 */
@isTest(SeeAllData=true)
private class test_ctlrClientTrackerCAS {

    static testMethod void myUnitTest() {
    	//Create an Account
    	Account myAccount = util_sampleDataGenerator.createAccount_Client();
        System.assertNotEquals(null, myAccount.Id);
        
    	//Create a CAS
    	Client_Assessment_Survey__c myCas = new Client_Assessment_Survey__c();
    	myCas.Account__c = myAccount.Id;
    	myCas.Quarter__c = 'Q1';
    	myCas.Year__c = '2014';
    	insert myCas;
    	System.assertNotEquals(null, myCas.Id);
    	
    	//Create a client Plan
    	Annual_Account_Plan__c myPlan = new Annual_Account_Plan__c();
    	myPlan.Account__c = myAccount.Id;
    	myPlan.Account_Plan_Year__c = '2014';
    	insert myPlan;
    	System.assertNotEquals(null, myPlan.Id);
    	
        Test.startTest();
        	
        	//Handle to the Apex page          
        	PageReference pageRef = Page.ClientTrackerCAS;
        	Test.setCurrentPage(pageRef);
        
	        //Get controller handles
        	ApexPages.standardController stdController = new ApexPages.standardController(myCas);
        	ctlr_ClientTrackerCAS cusController = new ctlr_ClientTrackerCAS(stdController);

        Test.stopTest();
    } //myUnitTest
}