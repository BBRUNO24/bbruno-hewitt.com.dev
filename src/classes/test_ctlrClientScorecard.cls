@isTest(SeeAllData=true)
private class test_ctlrClientScorecard {

    static testMethod void myUnitTest() {
        //Create an account
        Account account = util_SampleDataGenerator.createAccount_Client();        
        System.assertNotEquals(null, account.Id);

        Test.startTest();
        
        //Handle to the Apex page          
        PageReference pageRef = Page.Client_Scorecard;
        pageRef.getParameters().put('id', account.Id);
        pageRef.getParameters().put('year', '2012');
        pageRef.getParameters().put('quarter', 'Q1');

        Test.setCurrentPage(pageRef);
        
        //Get controller handles
        ApexPages.standardController stdController = new ApexPages.standardController(account);
        ctlr_Client_Scorecard cusController = new ctlr_Client_Scorecard(stdController);
        
        Test.stopTest();
    }
}