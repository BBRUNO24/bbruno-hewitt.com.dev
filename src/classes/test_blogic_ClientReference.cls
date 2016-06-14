@isTest
private class test_blogic_ClientReference{
@testSetup 
static void setupTestData() {

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
// Added by DaveM for Case# 00137492
static testMethod void test_UpdateClientReference(){

    system.debug('ClientReferenceTest');

    List<Client_Reference__c> myClientReferences = new List<Client_Reference__c>();
    User testUser = new User();
    Client_Reference__c clientreference1 = new Client_Reference__c();
    Client_Reference__c clientreference2 = new Client_Reference__c();


    // create a product
    //Product2 product = util_sampleDataGenerator.createProduct('LJ TEST PRODUCT', 'Consulting', false, 'Consulting');
    //System.assertNotEquals(null, product.Id);
        
    // create a pricebookentry
    //PricebookEntry pbe = util_sampleDataGenerator.createStandardPriceForProduct(product.id, 100.0);
    //System.assertNotEquals(null, pbe.Id);
        
    //Insert User
    testUser = util_sampleDataGenerator.createUser([select id from Profile where Name = 'Standard User Profile']);      
    System.assertNotEquals(null, testUser.id);

    // create an account
    Account account1 = util_sampleDataGenerator.createAccount_Client();
    System.assertNotEquals(null, account.Id);

    // create an account
    Account account2 = util_sampleDataGenerator.createAccount_Client();
    System.assertNotEquals(null, account.Id);
        
    // create an opportunity
    Opportunity oppty = util_sampleDataGenerator.createOpportunity_US(account1.Id);
    System.assertNotEquals(null, oppty.Id);
    oppty.ReferenceRequestUser__c  = testUser.Id;
    update oppty;
    system.debug(logginglevel.ERROR,'UserID');
    system.debug(logginglevel.ERROR,testuser.id);

    //Insert User
    //testUser = util_sampleDataGenerator.createUser([select id from Profile where Name = 'Standard User Profile']);      
    //System.assertNotEquals(null, testUser.id);

    // Insert & build list of ClientReferences to perform checks 
    for(integer i=0; i<=100 ; i++)
    {
        Client_Reference__c myClientReference = new Client_Reference__c ();
        myClientReference.opportunity__c = oppty.id;
        myClientReference.account__c = account2.id;
        myClientReferences.add(myClientReference );
    }
    
    insert myClientReferences;  

    Test.startTest();
    system.debug('ClientReferenceTest');
    for(Client_Reference__c myClientReference : myClientReferences){
        myClientReference.Request_Approval__c = True;
    }
    
    update myClientReferences;

    for(Client_Reference__c myClientReference : myClientReferences){
        myClientReference.Approved__c = True;
        
    }
    
    update myClientReferences;

    for(Client_Reference__c myClientReference : myClientReferences){
        myClientReference.Approved__c = False;
        myClientReference.Denied__c = True;
        
    }
    
    update myClientReferences;

        
    Test.stopTest();
}
}