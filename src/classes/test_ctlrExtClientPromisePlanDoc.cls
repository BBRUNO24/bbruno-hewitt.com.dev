@isTest(SeeAllData=true)
private class test_ctlrExtClientPromisePlanDoc {

    static testMethod void myUnitTest() {
       //Create an account
        List<Account> accounts = util_SampleDataGenerator.createPeopleSoftClients('Apex Text Account', 1, false);
        Account account = accounts[0];        
        account.HW_Ret_Pre_65_PPT_Count__c = 200;
        account.HW_Ret_Post_65_PPT_Count__c = 100;
        insert account;
        System.assertNotEquals(null, account.Id);
        
        //Create a plan
        Annual_Account_Plan__c plan = new Annual_Account_Plan__c();
        plan.Account__c = account.Id;
        plan.Mergers_Acquisitions__c = true;
        plan.Organic_Growth__c = true;
        plan.Operational_Improvement__c = true;
        plan.Improved_Productivity__c = true;
        plan.Cost_Management__c = true;
        plan.Customer_Retention_and_Growth__c = true;
        plan.Sales_Effectiveness__c = true;
        plan.Global_Expansion__c = true;
        plan.Reduce_Exposure_Financial_Inflation__c = true;
        plan.Corporate_Social_Responsibility__c = true;
        plan.Emerging_Workforce__c = true;
        plan.Improve_Engagement__c = true;
        plan.Total_Rewards_Strategy__c = true;
        plan.Reduce_Health_Care_Costs__c = true;
        plan.Retention__c = true;
        plan.Workforce_Reduction__c = true;
        plan.Talent_Development__c = true;
        plan.Develop_EE_Value_Proposition__c = true;
        plan.HR_Effectiveness__c = true;
        plan.Organization_Effectiveness__c = true;
        plan.Improve_Retirement_Readiness__c = true;
        plan.Manage_Pension_Risk__c = true;
        plan.Salesforce_Effectiveness__c = true;
        plan.Incentive_Plan_Effectiveness__c = true;
        plan.Outsourcing__c = true;
        plan.External_Cost_Control__c = true;
        plan.Shortage_of_Pension_Focused_Resource__c = true;
        plan.De_Risking__c = true;
        plan.Diversification__c = true;
        plan.Dynamism__c = true;
        plan.Enhance_Transfer_Values__c = true;
        plan.Pension_Increse_Exercises__c = true;
        plan.Trivial_Commutation_Exercises__c = true;
        plan.Scheme_Open_to_New_Members_and_Accrual__c = true;
        plan.Scheme_Closed_to_New_Members_but_with_Be__c = true;
        plan.Scheme_Closed_to_New_members_and_No_Accr__c = true;
        plan.Buy_Outs__c = true;
        plan.Buy_Ins__c = true;
        plan.Longevity_Hedging__c = true;
        plan.Delegated_Investment__c = true;
        plan.Data_Issues__c = true;
        plan.Investment_to_Reduce_Future_Admin_Risks__c = true;
        plan.Conflicts_of_Interests__c = true;
        plan.Auto_Enrolment__c = true;
        plan.Concentration_of_Knowledge__c = true;
        plan.Member_Nominated_Trustees__c = true;
        plan.Sponsor_Covenant__c = true;
        plan.Retain__c = 'This is a test';
        plan.Retain_Comments__c = 'This is a test';
        plan.Expand__c = 'This is a test';
        plan.Expand_Comments__c = 'This is a test';
        plan.Relationship__c = 'This is a test';
        insert plan;
        System.assertNotEquals(null, plan.Id);
        
        //Create Internal Account Team records
        List<String> roles = new String[] {'Additional Account Owner','BGM (Business Group Manager)','Benefits Delivery Manager','General Manager (HRO GM)',
            'Service Delivery Manager (SDM)','COMM Practice Lead','COMM Practice Team','H&B Practice Lead','H&B Practice Team','RET Practice Lead',
            'RET Practice Team','CTT Practice Team','T&R Practice Lead','N&C Lead','Outsourcing SE','Ben Admin Lead PM','Ben Admin PM','Legal/GC',
            'Executive Sponsor', 'Global Account Executive', 'Client Lead ARS','Client Lead Aon Benfield'};
        System.debug('CPA roles size: ' + roles.size());
        
        //Create Internal Contacts
        List<Contact> contacts = util_sampleDataGenerator.createInternalContact_bulk(account.Id, roles.size(), true);
        for (integer i=0; i<contacts.size(); i++) {
            System.debug('CPA contact: ' + contacts[i].Id);
            System.assertNotEquals(null, contacts[i].Id);
        }
        
        List<Internal_Account_Team__c> iatList = new List<Internal_Account_Team__c> ();
        for (integer i=0; i<roles.size(); i++) {
            System.debug('CPA iat for role: ' + roles[i]);
            Internal_Account_Team__c iat = util_sampleDataGenerator.createInternalAccountTeam(account.Id, contacts[i].Id, roles[i]);
            iatList.add(iat);
        }
        for (integer i=0; i<roles.size(); i++) {
            System.assertNotEquals(null, iatList[i].Id);
        }
                
        //Create Events
        List<Event> eventList = new List<Event> ();
        
        Event evt1 = new Event();
        evt1.WhatId = account.Id;
        evt1.ActivityDate = System.today();
        evt1.Subject = 'My Test Subject';
        evt1.Type = 'Client Promise Launch';
        evt1.DurationInMinutes = 5;
        evt1.ActivityDateTime = System.today();
        eventList.add(evt1);
        
        Event evt10 = new Event();
        evt10.WhatId = account.Id;
        evt10.ActivityDate = System.today();
        evt10.Subject = 'My Test Subject';
        evt10.Type = 'Partnership';
        evt10.DurationInMinutes = 5;
        evt10.ActivityDateTime = System.today();
        eventList.add(evt10);
        
        Event evt2 = new Event();
        evt2.WhatId = account.Id;
        evt2.ActivityDate = System.today();
        evt2.Subject = 'My Test Subject';
        evt2.Type = 'Planning - External';
        evt2.DurationInMinutes = 5;
        evt2.ActivityDateTime = System.today();
        eventList.add(evt2);
        
        Event evt3 = new Event();
        evt3.WhatId = account.Id;
        evt3.ActivityDate = System.today();
        evt3.Subject = 'My Test Subject';
        evt3.Type = 'Planning - Internal';
        evt3.DurationInMinutes = 5;
        evt3.ActivityDateTime = System.today();
        eventList.add(evt3);
        
        Event evt4 = new Event();
        evt4.WhatId = account.Id;
        evt4.ActivityDate = System.today();
        evt4.Subject = 'My Test Subject';
        evt4.Type = 'Innovation';
        evt4.DurationInMinutes = 5;
        evt4.ActivityDateTime = System.today();
        eventList.add(evt4);
        
        Event evt5 = new Event();
        evt5.WhatId = account.Id;
        evt5.ActivityDate = System.today();
        evt5.Subject = 'My Test Subject';
        evt5.Type = 'Blue Sky Day';
        evt5.DurationInMinutes = 5;
        evt5.ActivityDateTime = System.today();
        eventList.add(evt5);
        
        Event evt6 = new Event();
        evt6.WhatId = account.Id;
        evt6.ActivityDate = System.today();
        evt6.Subject = 'My Test Subject';
        evt6.Type = 'Results & Insights';
        evt6.DurationInMinutes = 5;
        evt6.ActivityDateTime = System.today();
        eventList.add(evt6);
        
        Event evt7 = new Event();
        evt7.WhatId = account.Id;
        evt7.ActivityDate = System.today();
        evt7.Subject = 'My Test Subject';
        evt7.Type = 'Executive Sponsor';
        evt7.DurationInMinutes = 5;
        evt7.ActivityDateTime = System.today();
        eventList.add(evt7);
        
        Event evt8 = new Event();
        evt8.WhatId = account.Id;
        evt8.ActivityDate = System.today();
        evt8.Subject = 'My Test Subject';
        evt8.Type = 'Annual Review';
        evt8.DurationInMinutes = 5;
        evt8.ActivityDateTime = System.today();
        eventList.add(evt8);
        
        Event evt9 = new Event();
        evt9.WhatId = account.Id;
        evt9.ActivityDate = System.today();
        evt9.Subject = 'Email: Test Subject';
        evt9.Type = 'Annual Review';
        evt9.DurationInMinutes = 5;
        evt9.ActivityDateTime = System.today();
        eventList.add(evt9);
        
        insert eventList;
        for (integer i=0; i<eventList.size(); i++) {
            System.assertNotEquals(null, eventList[i].Id);
        }
        
        //Create Task
        Task task = new Task();
        task.WhatId = account.Id;
        task.ActivityDate = System.today();
        task.Subject = 'Test Task Subject';
        task.Type = 'Client Development';
        insert task;
        
        //Client Sat
        Client_Satisfaction_Data__c csd = new Client_Satisfaction_Data__c();
        csd.Account__c = account.Id;
        csd.Year__c = '2013';
        csd.Likelihood_to_Recommend__c = 8.0;
        csd.Overall_Satisfaction__c = 7.5;
        csd.Net_Promoter_Score__c = 'Net Promoter Score';
        csd.Partnership_Importance__c = 8.8;
        csd.Partnership_Performance__c = 7.7;
        insert csd;
        
        //HRO Renewal
        HRO_Renewal__c hro = new HRO_Renewal__c();
        hro.Account__c = account.Id;
        insert hro;
        
        //Revenue
        Revenue_Sales_Pipeline__c rev = new Revenue_Sales_Pipeline__c();
        rev.Account__c = account.Id;
        rev.Year__c = '2013';
        rev.Quarter__c = 'Q1';
        insert rev;
        
        Test.startTest();
        
        //Handle to the Apex page          
        PageReference pageRef = Page.ClientPromisePlanDocPdf;
        Test.setCurrentPage(pageRef);
        
        //Get controller handles
        ApexPages.standardController stdController = new ApexPages.standardController(plan);
        ctlr_ext_ClientPromisePlanDoc cusController = new ctlr_ext_ClientPromisePlanDoc(stdController);
        
        //update account to asia pac
        account.SDO_Billing_Country_Name__c = 'Fiji';
        update account;
        
        //handle
        cusController = new ctlr_ext_ClientPromisePlanDoc(stdController);

        Test.stopTest();
    } //myUnitTest
    
    
    
    
    //Second unit Test to get coverage
    static testMethod void myUnitTest2() {
       //Create an account
        List<Account> accounts = util_SampleDataGenerator.createPeopleSoftClients('Apex Text Account', 1, false);
        Account account = accounts[0];        
        account.HW_Ret_Pre_65_PPT_Count__c = 200;
        account.HW_Ret_Post_65_PPT_Count__c = 100;
        insert account;
        System.assertNotEquals(null, account.Id);
        
        //Create a plan
        Annual_Account_Plan__c plan = new Annual_Account_Plan__c();
        plan.Account__c = account.Id;
        plan.Mergers_Acquisitions__c = true;
        plan.Comments_Mergers_Acquisitions__c = 'Test Comments';
        plan.Organic_Growth__c = true;
        plan.Comments_Organic_Growth__c = 'Test Comments';
        plan.Operational_Improvement__c = true;
        plan.Comments_Operational_Improvement__c = 'Test Comments';
        plan.Improved_Productivity__c = true;
        plan.Comments_Improved_Productivity__c = 'Test Comments';
        plan.Cost_Management__c = true;
        plan.Comments_Cost_Management__c = 'Test Comments';
        plan.Customer_Retention_and_Growth__c = true;
        plan.Comments_Customer_Retention_and_Growth__c = 'Test Comments';
        plan.Sales_Effectiveness__c = true;
        plan.Comments_Sales_Effectiveness__c = 'Test Comments';
        plan.Global_Expansion__c = true;
        plan.Comments_Global_Expansion__c = 'Test Comments';
        plan.Reduce_Exposure_Financial_Inflation__c = true;
        plan.Comments_Reduce_Exposure__c = 'Test Comments';
        plan.Corporate_Social_Responsibility__c = true;
        plan.Comments_Corporate_Social_Responsibility__c = 'Test Comments';
        plan.Emerging_Workforce__c = true;
        plan.Comments_Emerging_Workforce__c = 'Test Comments';
        plan.Improve_Engagement__c = true;
        plan.Comments_Improve_Engagement__c = 'Test Comments';
        plan.Total_Rewards_Strategy__c = true;
        plan.Comments_Total_Rewards_Strategy__c = 'Test Comments';
        plan.Reduce_Health_Care_Costs__c = true;
        plan.Comments_Reduce_Health_Care_Costs__c = 'Test Comments';
        plan.Retention__c = true;
        plan.Comments_Retention__c = 'Test Comments';
        plan.Workforce_Reduction__c = true;
        plan.Comments_Workforce_Reduction__c = 'Test Comments';
        plan.Talent_Development__c = true;
        plan.Comments_Talent_Development__c = 'Test Comments';
        plan.Develop_EE_Value_Proposition__c = true;
        plan.Comments_Develop_EE_Value_Proposition__c = 'Test Comments';
        plan.HR_Effectiveness__c = true;
        plan.Comments_HR_Effectiveness__c = 'Test Comments';
        plan.Organization_Effectiveness__c = true;
        plan.Comments_Organization_Effectiveness__c = 'Test Comments';
        plan.Improve_Retirement_Readiness__c = true;
        plan.Comments_Improve_Retirement_Readiness__c = 'Test Comments';
        plan.Manage_Pension_Risk__c = true;
        plan.Comments_Manage_Pension_Risk__c = 'Test Comments';
        plan.Salesforce_Effectiveness__c = true;
        plan.Comments_Salesforce_Effectiveness__c = 'Test Comments';
        plan.Incentive_Plan_Effectiveness__c = true;
        plan.Comments_Incentive_Plan_Effectiveness__c = 'Test Comments';
        plan.Outsourcing__c = true;
        plan.Comments_Outsourcing__c = 'Test Comments';
        plan.External_Cost_Control__c = true;
        plan.Comments_External_Cost_Control__c = 'Test Comments';
        plan.Shortage_of_Pension_Focused_Resource__c = true;
        plan.Comments_Shortage_of_Pension_Focused_Res__c = 'Test Comments';
        plan.De_Risking__c = true;
        plan.Comments_De_Risking__c = 'Test Comments';
        plan.Diversification__c = true;
        plan.Comments_Diversification__c = 'Test Comments';
        plan.Dynamism__c = true;
        plan.Comments_Dynamism__c = 'Test Comments';
        plan.Enhance_Transfer_Values__c = true;
        plan.Comments_Enhance_Transfer_Values__c = 'Test Comments';
        plan.Pension_Increse_Exercises__c = true;
        plan.Comments_Pension_Increse_Exercises__c = 'Test Comments';
        plan.Trivial_Commutation_Exercises__c = true;
        plan.Comments_Trivial_Commutation_Exercises__c = 'Test Comments';
        plan.Scheme_Open_to_New_Members_and_Accrual__c = true;
        plan.Comments_Scheme_Open_to_New_Members_and__c = 'Test Comments';
        plan.Scheme_Closed_to_New_Members_but_with_Be__c = true;
        plan.Comments_Scheme_Closed_to_New_members_an__c = 'Test Comments';
        plan.Scheme_Closed_to_New_members_and_No_Accr__c = true;
        plan.Comments_Scheme_Closed_to_New_members_an__c = 'Test Comments';
        plan.Buy_Outs__c = true;
        plan.Comments_Buy_Outs__c = 'Test Comments';
        plan.Buy_Ins__c = true;
        plan.Comments_Buy_Ins__c = 'Test Comments';
        plan.Longevity_Hedging__c = true;
        plan.Comments_Longevity_Hedging__c = 'Test Comments';
        plan.Delegated_Investment__c = true;
        plan.Comments_Delegated_Investment__c = 'Test Comments';
        plan.Data_Issues__c = true;
        plan.Comments_Data_Issues__c = 'Test Comments';
        plan.Investment_to_Reduce_Future_Admin_Risks__c = true;
        plan.Comments_Investment_to_Reduce_Future_Adm__c = 'Test Comments';
        plan.Conflicts_of_Interests__c = true;
        plan.Comments_Conflicts_of_Interests__c = 'Test Comments';
        plan.Auto_Enrolment__c = true;
        plan.Comments_Auto_Enrolment__c = 'Test Comments';
        plan.Concentration_of_Knowledge__c = true;
        plan.Comments_Concentration_of_Knowledge__c = 'Test Comments';
        plan.Member_Nominated_Trustees__c = true;
        plan.Comments_Member_Nominated_Trustees__c = 'Test Comments';
        plan.Sponsor_Covenant__c = true;
        plan.Comments_Sponsor_Covenant__c = 'Test Comments';
        plan.Improve_Wellness_and_Safety__c = true;
        plan.Comments_Improve_Wellness_and_Safety__c = 'Line Uno';
        plan.Improve_Benchmarking__c = true;
        plan.Comments_Improve_Benchmarking__c = 'Line Uno';
        plan.Manage_People_Risks__c = true;
        plan.Comments_Manage_People_Risks__c = 'Test Comments';
        insert plan;
        System.assertNotEquals(null, plan.Id);
        
        //Create External Contacts
        List<Contact> externalContacts = util_sampleDataGenerator.createExternalContact_bulk(account.Id, 27, false);
        externalContacts[0].Functional_Role__c = 'Corporate Operations - Chief Executive Officer (CEO)';
        externalContacts[1].Functional_Role__c = 'Finance - Chief Financial Officer (CFO)';
        externalContacts[2].Functional_Role__c = 'Human Resources - CHRO';
        externalContacts[3].Functional_Role__c = 'Corporate Operations - Purchasing/Procurement';
        externalContacts[4].Functional_Role__c = 'Risk Management - Chief Risk Officer';
        externalContacts[5].Functional_Role__c = 'Human Resources - Communication';
        externalContacts[6].Functional_Role__c = 'Finance - Controller';
        externalContacts[7].Functional_Role__c = 'Finance - Procurement';
        externalContacts[8].Functional_Role__c = 'Human Resources - Benefits General';
        externalContacts[9].Functional_Role__c = 'Human Resources - Compensation';
        externalContacts[10].Functional_Role__c = 'Human Resources - Compensation & Benefits';
        externalContacts[11].Functional_Role__c = 'Human Resources - Benefits Healthcare';
        externalContacts[12].Functional_Role__c = 'Human Resources - Recruiting';
        externalContacts[13].Functional_Role__c = 'Human Resources - Benefits Retirement';
        externalContacts[14].Functional_Role__c = 'Human Resources - Top Talent';
        externalContacts[15].Functional_Role__c = 'Human Resources - Training';
        externalContacts[16].Functional_Role__c = 'Finance - Treasurer';
        externalContacts[17].Functional_Role__c = 'Corporate Operations - Owner';
        externalContacts[18].Functional_Role__c = 'Corporate Operations - Partner';
        externalContacts[19].Functional_Role__c = 'Corporate Operations - Chairman';
        externalContacts[20].Functional_Role__c = 'Corporate Operations - Board Member';
        externalContacts[21].Functional_Role__c = 'Human Resources - General';
        externalContacts[22].Functional_Role__c = 'Other - Trustee';
        externalContacts[23].Functional_Role__c = 'Pension Fund - Manager';
        externalContacts[24].Functional_Role__c = 'Pension Fund - Board Member';
        externalContacts[25].Functional_Role__c = 'Risk Management - Health and Safety';
        externalContacts[26].Functional_Role__c = 'Risk Management - Risk/Insurance';
        
        insert externalContacts;
        
        //Client Sat
        Client_Satisfaction_Data__c csd = new Client_Satisfaction_Data__c();
        csd.Account__c = account.Id;
        csd.Year__c = '2013';
        csd.Likelihood_to_Recommend__c = 8.0;
        csd.Overall_Satisfaction__c = 7.5;
        csd.Net_Promoter_Score__c = 'Net Promoter Score';
        csd.Partnership_Importance__c = 8.8;
        csd.Partnership_Performance__c = 7.7;
        insert csd;
        
        //HRO Renewal
        HRO_Renewal__c hro = new HRO_Renewal__c();
        hro.Account__c = account.Id;
        insert hro;
        
        //Revenue
        Revenue_Sales_Pipeline__c rev = new Revenue_Sales_Pipeline__c();
        rev.Account__c = account.Id;
        rev.Year__c = '2013';
        rev.Quarter__c = 'Q1';
        insert rev;
        
        //Create two Client Satisfaction Surveys
        List<Client_Satisfaction_Survey__c> surveys = new List<Client_Satisfaction_Survey__c> ();
        Client_Satisfaction_Survey__c css1 = new Client_Satisfaction_Survey__c();
        css1.Account__c = account.Id;
        css1.Contact_del__c = externalContacts[0].Id;
        css1.Overall_Satisfaction__c = 9.0;
        css1.Recommend_Aon_Hewitt_to_others__c = 9.0;
        css1.Survey_Year__c = String.valueOf(System.today().year());
        css1.Survey_Date__c = Date.today();
        surveys.add(css1);
        
        Client_Satisfaction_Survey__c css2 = new Client_Satisfaction_Survey__c();
        css2.Account__c = account.Id;
        css2.Contact_del__c = externalContacts[0].Id;
        css2.Overall_Satisfaction__c = 9.0;
        css2.Recommend_Aon_Hewitt_to_others__c = 9.0;
        css2.Survey_Year__c = String.valueOf(System.today().year() -1);
        css2.Survey_Date__c = Date.today();
        surveys.add(css2);
        
        insert surveys;
        
        //Note
        Note note = new note();
        note.ParentId = plan.Id;
        note.Body = 'This is a test note';
        note.Title = 'Text Apex Note';
        insert note;
        
        //Account Segment
        Account_Segmentation__c segment = new Account_Segmentation__c();
        segment.Associated_Account__c = account.Id;
        segment.Country__c = 'United States';
        segment.Segment__c = 'Chintan';
        segment.Sub_Segment__c = 'Sub';
        insert segment;

        Test.startTest();
        
        //Handle to the Apex page          
        PageReference pageRef = Page.ClientPromisePlanDocPdf;
        Test.setCurrentPage(pageRef);
        
        //Get controller handles
        ApexPages.standardController stdController = new ApexPages.standardController(plan);
        ctlr_ext_ClientPromisePlanDoc cusController = new ctlr_ext_ClientPromisePlanDoc(stdController);
        
        //update account to asia pac
        account.SDO_Billing_Country_Name__c = 'Fiji';
        update account;
        
        //handle
        cusController = new ctlr_ext_ClientPromisePlanDoc(stdController);

        Test.stopTest();
    } //myUnitTest2
}