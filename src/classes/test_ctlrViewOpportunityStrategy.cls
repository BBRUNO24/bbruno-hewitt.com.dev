@isTest
private class test_ctlrViewOpportunityStrategy {
    @testSetup 
    static void setupClientData() {
        /*
            Insert the Organizational_Defaults__c
        */
        Organizational_Defaults__c orgDefaultSettings = new Organizational_Defaults__c();
        orgDefaultSettings.Enable_CAPIS_Id_Assignment__c = false;
        insert orgDefaultSettings;
        /*                                                                                                                                                                                                                                    
            Insert the Competitor__c Accounts
        */
        List<Competitor__c> competitors = new List<Competitor__c>();
        Competitor__c aon = new Competitor__c(name='Aon Hewitt');
        Competitor__c other = new Competitor__c(name='Other');
        competitors.add(aon);
        competitors.add(other);
        insert competitors;
    }     
    static testMethod void myUnitTest() {
    	//Create Account
        Account myAccount = util_SampleDataGenerator.createAccount_Client();
        System.assertNotEquals(null, myAccount.Id);
        
        //Create Contact
        Contact myContact = util_sampleDataGenerator.createContact_External(myAccount.Id);
        System.assertNotEquals(null, myContact.Id);
        
        //Create an Opp
        Opportunity myOpp = util_SampleDataGenerator.createOpportunity_US(myAccount.Id);
        System.assertNotEquals(null, myOpp.Id);
        myOpp.Competitor__c = 'CompetitorA;CompetitorB';
        update myOpp;
        
        //Add Opp Competitive Analysis
        Opportunity_Competitive_Analysis__c oca = new Opportunity_Competitive_Analysis__c();
        oca.Competitor__c = 'CompetitorC';
        oca.Opportunity__c = myOpp.Id;
        insert oca;
        System.assertNotEquals(null, oca.Id);
        
        //Add opp Contact Role
        Opportunity_Contact_Role__c ocr = new Opportunity_Contact_Role__c();
        ocr.Account__c = myAccount.Id;
        ocr.Contact__c = myContact.Id;
        ocr.Opportunity__c = myOpp.Id;
        ocr.Comments__c = 'Comments';
        insert ocr;
        System.assertNotEquals(null, ocr.Id);
        
        Test.startTest();
            
            //Handle to the Apex page
            PageReference pageRef = Page.ViewOpportunityStrategy;
            Test.setCurrentPage(pageRef);
            
            //Get controller handles
            ApexPages.standardController stdController = new ApexPages.standardController(myOpp);
            ctlr_ViewOpportunityStrategy cusController = new ctlr_ViewOpportunityStrategy(stdController);
            
            //init
            cusController.init();
            
            //Delete OCR
            cusController.selectedOcrId = ocr.Id;
            cusController.deleteOCR();
            
            //save
            pageRef = cusController.saveData();
            
            //print plan
            PageReference plan = cusController.createPlan();
        
        Test.stopTest();
    } //myUnitTest
}