@isTest
private class test_ctlr_SubmitProposalRequest {
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

        Proposal_Request_Settings__c requestSetting = new Proposal_Request_Settings__c();
        requestSetting.Type__c = 'BPO Proposal';
        requestSetting.Help__c = 'Leslie Davis, Leslie.Davis@aonhewitt.com,Larry Farina, larry.farina@aonhewitt.com, Valerie Mammales, Valerie.mammales@aonhewitt.com';
        requestSetting.Email_Recipients__c = 'DG-AH-Americas-SSRForm-HRBPO@aon.com';
        requestSetting.Name = 'Request_Settings';
        insert requestSetting;
    }
    static testMethod void submitProposalRequest() {
        //local var
        Date myDate = Date.today();
        
        Test.startTest();
        
        //Create two Accounts
        Account account = util_sampleDataGenerator.createAccount_Client();
        System.assertNotEquals(null, account.Id);
        Account account2 = util_sampleDataGenerator.createAccount_Client();
        System.assertNotEquals(null, account2.Id);
        
        //Create a Competitor
        Competitor__c myCompetitor = new Competitor__c();
        myCompetitor.Name = 'Hot Shot Competitor';
        insert myCompetitor;
        System.assertNotEquals(null, myCompetitor.Id);

        // create an opportunity
        Opportunity oppty = util_sampleDataGenerator.createOpportunity_US(account.Id);
        System.assertNotEquals(null, oppty.Id);
        
        //Create a product        
        Product2 product = util_sampleDataGenerator.createProduct('CHINTAN PRODUCT', 'Consulting', false, 'Consulting');
        System.assertNotEquals(null, product.Id);                
                  
        //Create a pricebookentry        
        PricebookEntry pbe = util_sampleDataGenerator.createStandardPriceForProduct(product.id, 100.0);       
        System.assertNotEquals(null, pbe.Id);
          
        OpportunityLineItem oli = util_sampleDataGenerator.createOpportunityProduct(oppty.Id, pbe.Id, 5, 150.0); 
        System.assertNotEquals(null, oli.Id);
        oli = [Select Service_Start_Date__c from OpportunityLineItem Where Id = :oli.Id];
        oli.Service_Start_Date__c = Date.today();
        update oli;
         
        //Create a Proposal
        Proposal_Request__c myProposal = new Proposal_Request__c();
        myProposal.Type__c = 'BPO Proposal;Absence Management Proposal';
        myProposal.Requestor__c = UserInfo.getUserID();
        myProposal.RFP_Type__c = 'RFP';
        myProposal.Status__c = 'New';
        myProposal.What_is_Needed__c = 'Full Sales Support';
        myProposal.Delivery_Method__c = 'CD';
        myProposal.Account_Executive__c = UserInfo.getUserID();
        myProposal.Sales_Executive__c = UserInfo.getUserID();
        myProposal.Date_RFP_Received__c = myDate;
        myProposal.Proposal_Submission_Due_Date__c = myDate;
        myProposal.Vendor_Questions_Due_to_Customer__c = myDate;
        myProposal.Estimated_Completion_Date__c = myDate;
        myProposal.Expected_RFP_Decision_Date__c = myDate;
        myProposal.Account__c = account.Id;
        myProposal.Opportunity__c = oppty.Id;
        myProposal.Existing_Aon_Hewitt_Relationship__c = 'Consulting';
        myProposal.Third_Party_Advisors_Involved__c = account2.Id;
        myProposal.Notify_Legal_Only__c = true;
        insert myProposal;
        System.AssertNotEquals(NULL ,myProposal.Id);
        
        //Create an attachment
        Attachment attach = new Attachment();
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=myProposal.id;
        insert attach;
          
        //Set up the test page
        PageReference testPage = Page.SubmitProposalRequest;
        testPage.getParameters().put('proposalId', myProposal.Id);
          
        //Set the test context
        Test.setCurrentPage(testPage);
            
        //Grab an instance to the controller
        ApexPages.StandardController stdController = new ApexPages.StandardController(myProposal);
        ctlr_SubmitProposalRequest myController = new ctlr_SubmitProposalRequest(stdController);
            
        //initialize & verify
        PageReference redirect = myController.init();
        System.debug('CPA Controller Error Message: ' + myController.errorMessage);
        System.assert(myController.errorMessage.contains('Propose Solution stage'));
        System.assertEquals(null, redirect);
        
        //Update Opp
        oppty.StageName = 'Propose Solution';
        oppty.Competitor__c = 'Accenture';
        oppty.Current_Provider_Reference__c = myCompetitor.Id;
        update oppty;
        
        //Verify
        myController = new ctlr_SubmitProposalRequest(stdController);
        redirect = myController.init();
        System.debug('CPA Controller Error Message: ' + myController.errorMessage);
        //System.assert(myController.errorMessage.contains('Third Party Advisor'));
        System.assertEquals(null, redirect);
        
        Test.stopTest();
        
        //Verify the Return button functionality
        redirect = myController.returnBack();
        System.assertEquals(redirect.getUrl(), '/' + myProposal.Id);
    } //submitProposalRequest    
}