@isTest
private class testChatterOpptyOnAccount {
    @testSetup static void setupAonData() {
        /*
            Insert the Organizational_Defaults__c
        */
        Organizational_Defaults__c orgDefaultSettings = new Organizational_Defaults__c();
        orgDefaultSettings.Enable_CAPIS_Id_Assignment__c = false;
        insert orgDefaultSettings;

        /*
            Insert the Chatter Custom Settings
        */
        Chatter_Up__c chatterSetting = new Chatter_Up__c();
        chatterSetting.name = 'Opportunity Settings';
        chatterSetting.object_api_name__c = 'Opportunity';
        chatterSetting.parent_id_field__c = 'accountid';
        chatterSetting.chatter_post_body__c = 'This is a test';
        chatterSetting.chatter_link_title__c = 'This is test title';
        insert chatterSetting;

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

    static testMethod void testChatterOppty() {
        List<Opportunity> myOpportunities = new List<Opportunity>();
        //Chatter_Up__c settings = createChatterUpConfig();
        //insert settings;
        
        /* Create 1 test account */
        //Account a = new Account(name = 'testAccount');
        //insert a;
        Account a = util_sampleDataGenerator.createAccount_Client();
        
        /* Create 100 test opportunities */
        for(Integer i=0; i < 100; i++){
            Opportunity o = new Opportunity(Name = 'TestOpp_'+i);
            o.AccountId = a.id;
            o.CloseDate = date.Today()+i;
            o.StageName = 'Negotiation/Review';
            myOpportunities.add(o);
        }
        
        Test.startTest();
            insert myOpportunities;
            List<AccountFeed> chatterPosts = [select id from AccountFeed where parentId = :a.id];
            System.assertEquals(chatterPosts.size(), 100, 'It should have a list of 100 chatter posts created');
        Test.stopTest();

    }
    
    static private Chatter_Up__c createChatterUpConfig() {
        
        Chatter_Up__c setting = new Chatter_Up__c();
        
        setting.name = 'Opportunity Settings';
        setting.object_api_name__c = 'Opportunity';
        setting.parent_id_field__c = 'accountid';
        setting.chatter_post_body__c = 'This is a test';
        setting.chatter_link_title__c = 'This is test title';
        
        return setting;
    }     
}