@isTest
private class test_utilSampleDataGenerator {
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
        
        // create products
        System.debug('create test product...');
        Product2 prod1 = util_sampleDataGenerator.createProduct('Product A', 'Consulting', true, 'Consulting'); 
        System.assertNotEquals(null,prod1.Id);
        System.debug('product created.');
        
        // add standard prices
        System.debug('adding standard price to product...');
        PricebookEntry pbe1 = util_sampleDataGenerator.createStandardPriceForProduct(prod1.Id, 100.0);
        System.assertNotEquals(null,pbe1.Id);
        System.debug('standard price added.');
        
        // create an account
        System.debug('creating test account...');
        Account account = util_sampleDataGenerator.createAccount_Client();
        System.assertNotEquals(null,account.Id);
        System.debug('account created.');
        
        // create a second account
        // Case 00103100 - Fix Test Classes
        // Error Message for this method: System.LimitException: Too many SOQL queries: 101
        // Jean Hsiung, Dec 3, 2013, util_sampleDataGenerator.createAccount() is tested in util_sampleDataGenerator.createAccount_Client() in the above statements
        //System.debug('creating test account...');
        //account = util_sampleDataGenerator.createAccount('APEX TEST ACCOUNT', util_sampleDataGenerator.getRecordType('Account', 'Client Account Record Type').Id, 'United States','IL');
        //System.assertNotEquals(null,account.Id);
        //System.debug('account created.');
        // End of Case 00103100 - Fix Test Classes

        // create a test contact
        System.debug('creating test contact...');
        Contact contact = util_sampleDataGenerator.createContact_External(account.Id);
        System.assertNotEquals(null,contact.Id); 
        System.debug('contact created.');
        
        // create a second contact
		// Case 00103100 - Fix Test Classes
        // Jean Hsiung, Dec 3, 2013, util_sampleDataGenerator.createContact() is tested in util_sampleDataGenerator.createContact_External in the above statements
        //System.debug('creating test contact...');
        //contact = util_sampleDataGenerator.createContact(account.Id, util_sampleDataGenerator.getRecordType('Contact', 'External Contact Record Type').Id, 'LARRY', 'JOVANOVIC', 'lj1@aonapextest.com', 'United States', 'Other - Other');
        //System.assertNotEquals(null,contact.Id);
        //System.debug('contact created.');
        // End of Case 00103100 - Fix Test Classes
        
        // create a third contact
        System.debug('creating test contact...'); 
        Contact contact2 = util_sampleDataGenerator.createContact(account.Id, util_sampleDataGenerator.getRecordType('Contact', 'Internal Contact Record Type').Id, 'Joe', 'Schmoe', 'joe.schmoe@aon.com', 'USA', 'Other', 'A00007');
        //System.assertNotEquals(null,contact.Id);	Jean correct
        System.assertNotEquals(null,contact2.Id);
        System.debug('contact created.');
            
        // create an opportunity
        System.debug('creating test opportunity...');
        Opportunity oppty = util_sampleDataGenerator.createOpportunity_US(account.Id);
        System.assertNotEquals(null,oppty.Id);
        System.debug('opportunity created.');
        
        // create a second opportunity
        System.debug('creating test opportunity...');
        oppty = util_sampleDataGenerator.createOpportunity(account.Id, util_sampleDataGenerator.getRecordType('Opportunity', 'Oppty Record').Id, 'Killer Whale Opportunity', 1000.0, 'Qualify Opportunity', Date.today().addDays(30), 25);
        System.assertNotEquals(null,oppty.Id);
        System.debug('opportunity created.');
        
        // create products on the opportunity
        System.debug('creating opportunity line item...');
        OpportunityLineItem oli1 = util_sampleDataGenerator.createOpportunityProduct(oppty.Id, pbe1.Id, 3, 75.0);
        System.assertNotEquals(null,oli1.Id);
        System.debug('opportunity product created.');

        // create a configuration for the read-only interface based on a stage, record type, etc.
        System.debug('creating product field list configuration...');
        Product_Field_List__c pfl1 = util_sampleDataGenerator.createProductFieldList_ReadOnly('OpportunityLineItem', 'Type__c', 1, null, null, null, prod1.Id);
        System.assertNotEquals(null, pfl1.Id);
        System.debug('field list created.');
        
        // create a configuration for the edit interface based on a stage, record type, etc.
        System.debug('creating product field list configuration...');
        Product_Field_List__c pfl2 = util_sampleDataGenerator.createProductFieldList_EntryEdit('OpportunityLineItem', 'Type__c', 1, null, null, null, prod1.Id);
        System.assertNotEquals(null, pfl2.Id);
        System.debug('field list created.');
        
        // get the standard pricebook
        System.debug('getting the standard pricebook...');
        Id pbId = util_sampleDataGenerator.getStandardPricebookId();
        System.assertNotEquals(null, pbId);
        System.debug('retrieved pricebook.');
        
        User au = util_sampleDataGenerator.createAdminUser();
        User su = util_sampleDataGenerator.createHewittStandardUser();
        Opportunity_Edit_Section__c section = util_sampleDataGenerator.createOpptyEditSection(new String[]{'test'});
        Pricebook2 pb2 = util_sampleDataGenerator.createPricebook();
        
    }
    
    
    static testMethod void myUnitTest2() {
        
        // create another account
        System.debug('creating test account...');
        Account account = util_sampleDataGenerator.createPeopleSoftClient('APEX TEST ACCOUNT', util_sampleDataGenerator.getRecordType('Account', 'Client Account Record Type').Id, false);
        System.assertEquals(null,account.Id);
        System.debug('account created.');
        
        // create another account
        System.debug('creating test account...');
        account = util_sampleDataGenerator.createPeopleSoftClient('APEX TEST ACCOUNT', util_sampleDataGenerator.getRecordType('Account', 'Client Account Record Type').Id, true);
        System.assertNotEquals(null,account.Id);
        System.debug('account created.');
        
        // create multiple accounts
        System.debug('creating multiple test account...');
        List <Account> accounts = util_sampleDataGenerator.createPeopleSoftClients('APEX TEST ACCOUNT', 2, true);
        for (Account accountTemp : accounts) {
            System.assertNotEquals(null,accountTemp.Id);
        }
        System.debug('accounts created.');
        
        // create a test internal contact
        System.debug('creating an internal contact...');
        Contact contact = util_sampleDataGenerator.createContact_Internal(account.Id);
        System.assertNotEquals(null,contact.Id);
        System.debug('contact created.');

        Contact contact1 = util_sampleDataGenerator.createContactWithFName_Internal(account.Id,'Test1');
        System.assertNotEquals(null,contact1.Id);
        
        // create a test user
        System.debug('creating a test user...');
        User user = util_sampleDataGenerator.createHewittStandardUser();
        System.assertNotEquals(null,user.Id);
        System.debug('user created.');
        
        // prep records for the internal account team member
        contact.Corresponding_User_Id__c = user.Id;
        update contact;
        user.Internal_Contact_Id__c = contact.Id;
        update user;
        
        // create a test internal account team member
        System.debug('creating an internal account team member');
        Internal_Account_Team__c teamMember = util_sampleDataGenerator.createInternalAccountTeam(account.Id, contact.Id, 'TEST ROLE');
        System.assertNotEquals(null,teamMember.Id);
        System.debug('internal account team member created.');
    }
    
    static testMethod void myUnitTest3() {
        util_sampleDataGenerator.getOpportunityRecordType_USOpptyRecord();
    }

    /** 
     * Case 00103100 - Fix Test Classes
     * Test method util_sampleDataGenerator.createInternalContact_bulk()
     * Dec 3, 2013
     * @author	Jean Hsiung
     */
    static testMethod void testCreateInternalContact_bulk() {
        System.debug('========= in testCreateInternalContact_bulk() ================================');
        //Number of Records to Create
        integer numToCreate = 50;
        List<String> contactIds = new List<String> ();
        List<String> userIds = new List<String> ();
        
        //create an account
        Account myAccount = util_sampleDataGenerator.createAccount_Client();
        System.assertNotEquals(myAccount.Id, null);
        System.debug('========= myAccount Id : ' + myAccount.Id);
        
        //Create internal contacts
        List<Contact> internalContacts = util_sampleDataGenerator.createInternalContact_bulk(myAccount.Id, numToCreate, true);
        System.assertEquals(numToCreate, internalContacts.size());
        System.debug('========= ' + numToCreate + ' Internal Contacts created');
        
    } //testCreateInternalContact_bulk

    /** 
     * Case 00103100 - Fix Test Classes
     * Test method util_sampleDataGenerator.createContact(String accountId, String recordTypeId, String fName, String lName, String email, String billingCountry, String functionalRole, Boolean saveBeforeExit)
     * Dec 3, 2013 
     * @author	Jean Hsiung
     */
    static testMethod void testCreateContactWithBooleanParameterForSave() {
        System.debug('========= in testCreateContactWithBooleanParameterForSave() ================================');
        
        //create an account
        Account myAccount = util_sampleDataGenerator.createAccount_Client();
        System.assertNotEquals(myAccount.Id, null);
        System.debug('========= myAccount Id : ' + myAccount.Id);
        
        //Create internal contacts
        Contact contact = util_sampleDataGenerator.createContact(myAccount.Id, util_sampleDataGenerator.getRecordType('Contact', 'Internal Contact Record Type').Id, 'Joe', 'Schmoe', 'joe.schmoe@aon.com', 'USA', 'Other', true);
        System.assertNotEquals(null,contact.Id);
        System.debug('========= Contact created: ' + contact);
        
    } //testCreateContactWithBooleanParameterForSave


    /** 
     * Case 00103100 - Fix Test Classes
     * Test method util_sampleDataGenerator.createOpportunityFromMarLead(String accountId, String leadID, String recordTypeId, String name, Decimal amount, String stage, Date closeDate, Decimal probability)
     * Dec 6, 2013 
     * @author	Jean Hsiung
     */
    static testMethod void testCreateOpportunityFromMarLead()
    {   
        System.debug('========= in testCreateOpportunityFromMarLead() ================================');

        //Variable Declarations
        Account testAccount = new Account();
        Contact testContact = new Contact();
        Marketing_Lead__c testMarkLead = new Marketing_Lead__c();
        Opportunity testOpp = new Opportunity();
        List <Marketing_Lead__c> testMarkLeads = new List<Marketing_Lead__c>();
        List <String> testMarkLeadIds = new List<String>();
        List <Opportunity > testOpps= new List<Opportunity >();
        String opptyRecTypeID = '';
        Integer i=0;
        Integer countUpdatedLeads=0;
        
        //Getting Oppty Record Type ID
        opptyRecTypeID=util_sampleDataGenerator.getRecordType('Opportunity', 'Oppty Record').Id;
        
        //Create a dummy Account
        testAccount = util_sampleDataGenerator.createAccount_Client();
        System.assertNotEquals(null, testAccount.Id);
        System.debug('testAccount.Id - '+testAccount.Id);
        
        //Create a dummy Contact
        testContact = util_SampleDataGenerator.createContact_External(testAccount.Id); 
        System.assertNotEquals(null, testContact.Id);
        System.debug('testContact.Id - '+testContact.Id);
        
        //Create a dummy Marketing Lead
        testMarkLead = new Marketing_Lead__c();
        testMarkLead.Contact__c=testContact.ID;
        testMarkLead.Status__c='Open';      
        insert testMarkLead;
        System.assertNotEquals(null, testMarkLead.Id); 
        System.debug('testMarkLead.Id - '+testMarkLead.Id);      
        
        //Create a dummy opportunity
        testOpp = util_SampleDataGenerator.createOpportunityFromMarLead(testAccount.Id,testMarkLead.ID,opptyRecTypeID,'Test Opp', 1000.0, 'Qualify Opportunity', Date.today().addDays(30), 25);
        Insert testOpp ;
        System.assertNotEquals(null, testOpp.Id); 
        System.debug('testOpp.Id - '+testOpp.Id);
        
    } //testCreateOpportunityFromMarLead()

    /** 
     * Case 00103100 - Fix Test Classes
     * Test method util_sampleDataGenerator.createHewittStandardUser(Boolean saveBeforeExit),
     *      method util_sampleDataGenerator.createUser(Profile profile, Boolean saveBeforeExit),
     *      method util_sampleDataGenerator.createUser(Profile profile, String associateId, Boolean saveBeforeExit)
     * Dec 6, 2013 
     * @author	Jean Hsiung
     */
    static testMethod void testCreateHewittStandardUser()
    {   
        System.debug('========= in testCreateHewittStandardUser() ================================');
        User testUser = util_SampleDataGenerator.createHewittStandardUser(true);      
        System.assertNotEquals(null, testUser.id);

    } //testCreateHewittStandardUser()

    /** 
     * Case 00103100 - Fix Test Classes
     * Test method util_sampleDataGenerator.createHewittStandardUser_bulk(Integer numToCreate, Boolean saveBeforeExit)
     * Dec 6, 2013 
     * @author	Jean Hsiung
     */
    static testMethod void testCreateHewittStandardUser_bulk()
    {   
        System.debug('========= in testCreateHewittStandardUser_bulk() ================================');

        //Number of Records to Create
        integer numToCreate = 50;
        
        List<User> users = util_SampleDataGenerator.createHewittStandardUser_bulk(numToCreate, true);      
        System.assertEquals(numToCreate, users.size());
        System.debug('========= ' + numToCreate + ' Users created');

    } //testCreateHewittStandardUser_bulk()

    /** 
     * Case 00103100 - Fix Test Classes
     * Test method util_sampleDataGenerator.createSalesCredit(String opportunityId, String contactId)
     * Dec 6, 2013 
     * @author	Jean Hsiung
     */
	static testMethod void testCreateSalesCredit() {
        System.debug('========= in testCreateSalesCredit() ================================');

		// create a test client Account
		Account clientAccount = util_SampleDataGenerator.createAccount_Client();
		System.assertNotEquals(null,clientAccount.Id);
		
		// create a test internal account
		Account internalAccount = util_SampleDataGenerator.createAccount_Client();
		System.assertNotEquals(null,internalAccount.Id);
		
		// create a test internal contact
		Contact internalContact = util_SampleDataGenerator.createContact_Internal(internalAccount.Id);
		System.assertNotEquals(null,internalContact.Id);
		
		// create a test opportunity
		Opportunity oppty = util_SampleDataGenerator.createOpportunity_US(clientAccount.Id);
        System.assertNotEquals(null, oppty.Id);
		
		// create a test sales team entry for non user
		Sales_Credit__c salesCredit = util_SampleDataGenerator.createSalesCredit(oppty.Id, internalContact.Id);
		System.assertNotEquals(null, salesCredit.Id);
					
	} //testCreateSalesCredit()

    /** 
     * Case 00103100 - Fix Test Classes
     * Test method util_sampleDataGenerator.createSalesCredit(String opportunityId, String contactId, Boolean saveBeforeExiting)
     * Dec 6, 2013 
     * @author	Jean Hsiung
     */
	static testMethod void testCreateSalesCreditWithBooleanParameterForSave() {
        System.debug('========= in testCreateSalesCreditWithBooleanParameterForSave() ================================');

		// create a test client Account
		Account clientAccount = util_SampleDataGenerator.createAccount_Client();
		System.assertNotEquals(null,clientAccount.Id);
		
		// create a test internal account
		Account internalAccount = util_SampleDataGenerator.createAccount_Client();
		System.assertNotEquals(null,internalAccount.Id);
		
		// create a test internal contact
		Contact internalContact = util_SampleDataGenerator.createContact_Internal(internalAccount.Id);
		System.assertNotEquals(null,internalContact.Id);
		
		// create a test opportunity
		Opportunity oppty = util_SampleDataGenerator.createOpportunity_US(clientAccount.Id);
        System.assertNotEquals(null, oppty.Id);
		
		// create a test sales team entry for non user
		Sales_Credit__c salesCredit = util_SampleDataGenerator.createSalesCredit(oppty.Id, internalContact.Id, true);
		System.assertNotEquals(null, salesCredit.Id);
					
	} //testCreateSalesCreditWithBooleanParameterForSave()

    /** 
     * Case 00103100 - Fix Test Classes
     * Test method util_sampleDataGenerator.createInternalAccountTeam_bulk(String accountId, List<String> contactIds, String role, integer numToCreate, Boolean saveBeforeExit)
     * Dec 6, 2013 
     * @author	Jean Hsiung
     */
	static testMethod void testCreateInternalAccountTeam_bulk() {
        System.debug('========= in testCreateInternalAccountTeam_bulk() ================================');

        //Number of Records to Create
        integer numToCreate = 50;
        List<String> contactIds = new List<String> ();
        List<String> userIds = new List<String> ();
        
        //create an account
        Account myAccount = util_sampleDataGenerator.createAccount_Client();
        System.assertNotEquals(myAccount.Id, null);
        System.debug('========= Account with Id ' + myAccount.Id + ' created');
        
        //Create internal contacts
        List<Contact> internalContacts = util_sampleDataGenerator.createInternalContact_bulk(myAccount.Id, numToCreate, true);
        System.assertEquals(numToCreate, internalContacts.size());
        System.debug('=========  ' + numToCreate + ' Internal Contacts created');
        
        // collect the distinct set of ids created
        for (Contact contact : internalContacts) {
            contactIds.add(contact.Id);
        }
        System.assertEquals(numToCreate, contactIds.size());

        //Create users
        List<User> users = util_sampleDataGenerator.createHewittStandardUser_bulk(numToCreate, false);
        //Pull internal contacts again
        internalContacts = [Select Corresponding_User_Id__c from Contact where Id in :contactIds];
        System.assertEquals(numToCreate, internalContacts.size());
        for (integer i=0; i<numToCreate; i++) {
            users[i].Internal_Contact_Id__c = internalContacts[i].Id;
        }
        insert users;
        System.assertEquals(numToCreate, users.size());
        System.debug('=========  ' + numToCreate + ' Users created');
        
        // collect the distinct set of ids created
        for (User user : users) {
            userIds.add(user.Id);
        }
        System.assertEquals(numToCreate, userIds.size());

        //Pull user records again
        users = [Select Id from User where Id in :userIds];
        System.assertEquals(numToCreate, users.size());
        
        //Update internal contacts
        for (integer i=0; i<internalContacts.size(); i++) {
            internalContacts[i].Corresponding_User_Id__c = users[i].Id;
        } 
        update internalContacts;
        
        //Create Internal Account Team Records
        List<Internal_Account_Team__c> iatList = util_sampleDataGenerator.createInternalAccountTeam_bulk(myAccount.Id, contactIds, 'General Support', numToCreate, true);
        
        //Verify AccountTeamMember record
        AccountTeamMember[] atmList = [Select AccountId, UserId, TeamMemberRole From AccountTeamMember Where AccountId = :myAccount.Id and UserId in :userIds];
        System.assertEquals(atmList.size(), numToCreate);
        for (integer i=0; i<numToCreate; i++) {
            System.assertEquals(atmList[i].TeamMemberRole, 'Account Team Member');
        }
        
        //Verify AccountShare Record
        AccountShare[] accountShareList = [Select AccountAccessLevel, ContactAccessLevel, CaseAccessLevel, OpportunityAccessLevel From AccountShare where AccountId = :myAccount.Id and UserOrGroupId in :userIds];
        System.assertEquals(accountShareList.size(), numToCreate);
        for (integer i=0; i<numToCreate; i++) {
            System.assertEquals(accountShareList[i].ContactAccessLevel, 'Edit');
            System.assertEquals(accountShareList[i].CaseAccessLevel, 'Edit');
            System.assertEquals(accountShareList[i].OpportunityAccessLevel, 'Edit');
            System.assertEquals(accountShareList[i].AccountAccessLevel, 'Edit');
        }
					
	} //testCreateInternalAccountTeam_bulk()

    /** 
     * Case 00103100 - Fix Test Classes
     * Test method util_sampleDataGenerator.CreateContactPublication(String ContactID,String Country,String Publication),
     *             util_sampleDataGenerator.createContact_External(String fName, String lName, String recordTypeID, String emailID, String accountID, Boolean billingCon)
     * Dec 7, 2013 
     * @author	Jean Hsiung
     */
    static testMethod void testCreateContactPublication()
    {   
        System.debug('========= in testCreateContactPublication() ================================');

        // create an account
        System.debug('========= creating test account...');
        Account account = util_sampleDataGenerator.createAccount_Client();
        System.assertNotEquals(null,account.Id);
        System.debug('========= account created:' + account);

        // create a test contact
        System.debug('========= creating test contact...');
        //Contact contact = util_sampleDataGenerator.createContact_External(account.Id);
        Contact contact = util_sampleDataGenerator.createContact_External('John', 'Smith', util_sampleDataGenerator.getRecordType('Contact', 'External Contact Record Type').Id, 'test@test.com', account.Id, true);
        insert contact;
        System.assertNotEquals(null,contact.Id); 
        System.debug('========= contact created:' + contact);
        
        // create a test contact publication
        System.debug('========= creating test contact...');
        Contact_Publication__c contactPublication = util_sampleDataGenerator.CreateContactPublication(contact.Id, 'United States', 'Aon Hewitt Global Report');
        System.assertNotEquals(null, contactPublication.Id);
        System.debug('========= contact publictation created:' + contactPublication);

    } //testCreateContactPublication()

    /** 
     * Case 00103100 - Fix Test Classes
     * Test method util_sampleDataGenerator.createCampaign()
     * Dec 7, 2013 
     * @author	Jean Hsiung
     */
    static testMethod void testCreateCampaign()
    {   
        System.debug('========= in testCreateCampaign() ================================');

        Campaign campaign = util_sampleDataGenerator.CreateCampaign();
        System.assertNotEquals(null, campaign.Id);
        System.debug('========= campaign created:' + campaign);

    } //testCreateCampaign()

}