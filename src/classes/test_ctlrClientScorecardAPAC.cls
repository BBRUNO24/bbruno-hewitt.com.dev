@isTest(seeAllData = true)
private class test_ctlrClientScorecardAPAC {
    static testMethod void myUnitTest() {
        //Create an account
        Account account = util_SampleDataGenerator.createAccount_Client();        
        System.assertNotEquals(null, account.Id);
        
        //Create a CAS for this account
    	Client_Assessment_Survey__c cas = new Client_Assessment_Survey__c();
    	cas.Account__c = account.Id;
    	cas.Year__c = '2012';
    	cas.Quarter__c = 'Q1';
    	cas.APAC_Score_1__c = 11;
    	cas.APAC_Score_2__c = 7;
    	cas.Absence_Management_Analytics__c = 'Not Viable';
    	cas.Broad_Based_Compensation__c = 'Lead Provider';
    	cas.RecordTypeId = [SELECT Id,Name FROM RecordType WHERE SobjectType='Client_Assessment_Survey__c' and Name = 'APAC Client Assessment Record'].Id;
    	insert cas;
    	System.assertNotEquals(null, cas.Id);
        
        //Create a CSS for this account
    	Client_Satisfaction_Survey__c css = new Client_Satisfaction_Survey__c();
    	css.Account__c = account.Id;
    	css.Survey_Year__c = '2012';
    	css.Recommend_Aon_Hewitt_to_others__c = 9.0;
    	css.Overall_Satisfaction__c = 7.7;
    	insert css;
    	System.assertNotEquals(null, css.Id);
    	
    	Client_Satisfaction_Survey__c css2 = new Client_Satisfaction_Survey__c();
    	css2.Account__c = account.Id;
    	css2.Survey_Year__c = '2011';
    	css2.Recommend_Aon_Hewitt_to_others__c = 9.0;
    	css2.Overall_Satisfaction__c = 7.7;
    	insert css2;
    	System.assertNotEquals(null, css2.Id);

        Test.startTest();
        
        //Handle to the Apex page          
        PageReference pageRef = Page.Client_Scorecard_APAC;
        pageRef.getParameters().put('id', account.Id);
        pageRef.getParameters().put('year', '2012');
        pageRef.getParameters().put('quarter', 'Q1');

        Test.setCurrentPage(pageRef);
        
        //Get controller handles
        ApexPages.standardController stdController = new ApexPages.standardController(account);
        ctlr_Client_Scorecard_APAC cusController = new ctlr_Client_Scorecard_APAC(stdController);
        
        Test.stopTest();
    }
}