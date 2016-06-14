public class util_sampleDataGenerator {

    // method to create an account with the client record type, populated with the minimum amount of required fields
    public static Account createAccount_Client() {
        return createAccount('APEX TEST ACCOUNT', getRecordType('Account', 'Client Account Record Type').Id, 'United States', 'IL');
    }

    public static Account createAccount_Client(Boolean saveBeforeExiting) {
        return createAccount('APEX TEST ACCOUNT', getRecordType('Account', 'Client Account Record Type').Id, 'United States', 'IL', saveBeforeExiting);
    }

    public static Account createAccount(String accountName, String recordTypeId, String billingCountry, String billingState) {
        return createAccount(accountName, recordTypeId, billingCountry, billingState, true);
    }
    // method to create and return an account record populated with the fields required to facilitate record creation
    public static Account createAccount(String accountName, String recordTypeId, String billingCountry, String billingState, Boolean saveBeforeExiting) {
        // declare local vars 
        Account account = new Account();
        
        // populate the record with values
        account.RecordTypeId = recordTypeId;
        account.Name = accountName;
        account.SDO_Billing_Country_Name__c = billingCountry;
        account.BillingPostalCode = '60051';
        account.BillingState = billingState;
        // insert the record
        if(saveBeforeExiting){
           insert account; 
        }
        
        // return the account
        return account;
    }
    
    // method to create and return an account record populated with the fields required to facilitate record creation
    public static Account createPeopleSoftClient(String accountName, String recordTypeId, Boolean saveBeforeExiting) {
        // declare local vars
        Account account = new Account();
        
        // populate the record with values
        account.RecordTypeId = recordTypeId;
        account.Name = accountName;
        account.SDO_Billing_Country_Name__c = 'United States';
        account.BillingPostalCode = '60051';
        account.BillingState = 'IL';
        account.ACW_Client_Type__c = 'Client';
        account.Legacy_Hewitt_Financial_System__c = 'Peoplesoft';
        account.Additional_CAPIS_Indicator__c = 'No';
        
        if (saveBeforeExiting) {
            // insert the record
            insert account;
        }
        
        // return the account
        return account;
    }
    
    // method to create and return an account record populated with the fields required to facilitate record creation
    public static List <Account> createPeopleSoftClients(String accountNamePrefix, Integer numToCreate, Boolean saveBeforeExiting) {
        
        List <Account> recordsToCreate = new List<Account>();
        String recordTypeid = getRecordType('Account', 'Client Account Record Type').Id;
        
        for (Integer x = 0; x < numToCreate; x++) {
            recordsToCreate.add(createPeopleSoftClient(accountNamePrefix, recordTypeId, false));
        }
                
        if (saveBeforeExiting) {
            // insert the records
            insert recordsToCreate;
        }
        
        // return the account
        return recordsToCreate;
    }
    
    // utility method to retrieve a given record type
    public static RecordType getRecordType(String objectName, String recordTypeName) {
        RecordType rt = null;
        rt = [select id, name from RecordType where sObjectType = :objectName and Name = :recordTypeName and IsActive = true limit 1];
        return rt;
    }
    
    // method to create a contact with the external contact record type, populated with the minimum amount of required fields
    public static Contact createContact_External(String accountId) {
        return createContact(accountId, getRecordType('Contact', 'External Contact Record Type').Id, 'Apex', 'External Contact', util_globalUtilityMethods.generateRandomString(10)+'@aon.com', 'United States', 'Other - Other');
    }
    
    // method to create a contact with the internal contact record type, populated with the minimum amount of required fields
    public static Contact createContact_Internal(String accountId) {
        return createContact(accountId, getRecordType('Contact', 'Internal Contact Record Type').Id, 'Apex', 'Internal Contact', 'aic@aonapextest.com', 'UNITED STATES', 'Other - Other');
    }
    
    // method to create and return multiple Internal Contacts. Chintan,  August 02, 2012 
    public static List<Contact> createInternalContact_bulk(String accountId, Integer numToCreate, Boolean saveBeforeExiting) {
        List <Contact> recordsToCreate = new List<Contact>();
        String recordTypeid = getRecordType('Contact', 'Internal Contact Record Type').Id;
        
        for (Integer x = 0; x < numToCreate; x++) {
            Contact contact = new Contact();
            contact.RecordTypeId = recordTypeId;
            contact.FirstName = 'Apex';
            contact.LastName = 'Contact ' + x;
            contact.email = util_globalUtilityMethods.generateRandomString(10) + '@aon.com';
            contact.AccountId = accountId;
            contact.SDO_Mailing_Country_Name__c = 'UNITED STATES';
            contact.Functional_Role__c = 'Other - Other';
            String associateID = String.valueOf(x);
            //System.debug('CPA associateID initialized as: ' + associateID + ' with length: ' + associateID.length());
            associateID = associateID.leftPad(5);
            //System.debug('CPA associateID after leftPad is: *' + associateID + '*');
            associateID = associateID.replaceAll(' ', '0');
            //contact.Legacy_Hewitt_Associate_ID__c = 'A' + associateID;
            contact.Associate_ID__c = 'A' + associateID;
            //contact.Source_HR_System__c = 'Aon Hewitt';
            contact.Aon_Hewitt_Employee_Status__c = 'Active';
            //System.debug('CPA Contact Associate ID is: ' + contact.Associate_ID__c);
            recordsToCreate.add(contact);
        }
        if (saveBeforeExiting) {
            // insert the records
            insert recordsToCreate;
        }
        // return the records
        return recordsToCreate;
    } //createInternalContact_bulk
    
    
    // method to create and return multiple External Contacts. Chintan,  June 18, 2014 
    public static List<Contact> createExternalContact_bulk(String accountId, Integer numToCreate, Boolean saveBeforeExiting) {
        List <Contact> recordsToCreate = new List<Contact>();
        String recordTypeid = getRecordType('Contact', 'External Contact Record Type').Id;
        
        for (Integer x = 0; x < numToCreate; x++) {
            Contact contact = new Contact();
            contact.RecordTypeId = recordTypeId;
            contact.FirstName = 'Apex';
            contact.LastName = 'Contact ' + x;
            contact.email = util_globalUtilityMethods.generateRandomString(10) + '@aon.com';
            contact.AccountId = accountId;
            contact.SDO_Mailing_Country_Name__c = 'UNITED STATES';
            contact.Functional_Role__c = 'Other - Other';

            recordsToCreate.add(contact);
        }
        if (saveBeforeExiting) {
            // insert the records
            insert recordsToCreate;
        }
        // return the records
        return recordsToCreate;
    } //createExternalContact_bulk
    
    
    // method to create a contact with (parameter as First Name) the internal contact record type, populated with the minimum amount of required fields
    public static Contact createContactWithFName_Internal(String accountId, String FName) {
        return createContact(accountId, getRecordType('Contact', 'Internal Contact Record Type').Id, FName, 'JOVANOVIC', 'lj@aonapextest.com', 'UNITED STATES', 'Other - Other');
    }

    // method to create and return a contact record populated with the fields required to facilitate record creation
    public static Contact createContact(String accountId, String recordTypeId, String fName, String lName, String email, String billingCountry, String functionalRole) {
        // declare local vars
        Contact contact = new Contact();
        
        // populate the record with values
        contact.RecordTypeId = recordTypeId;
        contact.FirstName = fName;
        contact.LastName = lName;
        contact.email = email;
        if (accountId.length() > 0) {
            contact.AccountId = accountId;
        }
        contact.SDO_Mailing_Country_Name__c = billingCountry;
        contact.Functional_Role__c = functionalRole;
        contact.Contact_Status__c = 'Active';
        
        //if internal contact populate files to allow it to be added to internal team
        if (recordTypeId == getRecordType('Contact', 'Internal Contact Record Type').Id) {
            //contact.Legacy_Hewitt_Associate_ID__c = 'A00000';
            contact.Associate_ID__c = 'A00000';
            //contact.Source_HR_System__c = 'Aon Hewitt';
            contact.Aon_Hewitt_Employee_Status__c = 'Active';
        }
        
        // insert the record
        insert contact;
        
        // return the record
        return contact;
    }
    
    
    // method to create and return a contact record populated with the fields required to facilitate record creation with boolean parameter indicating save before return or not
    //Chintan, August 02, 2012
    public static Contact createContact(String accountId, String recordTypeId, String fName, String lName, String email, String billingCountry, String functionalRole, Boolean saveBeforeExit) {
        // declare local vars
        Contact contact = new Contact();
        
        // populate the record with values
        contact.RecordTypeId = recordTypeId;
        contact.FirstName = fName;
        contact.LastName = lName;
        contact.email = email;
        if (accountId.length() > 0) {
            contact.AccountId = accountId;
        }
        contact.SDO_Mailing_Country_Name__c = billingCountry;
        contact.Functional_Role__c = functionalRole;
        
        //if internal contact populate files to allow it to be added to internal team
        if (recordTypeId == getRecordType('Contact', 'Internal Contact Record Type').Id) {
            //contact.Legacy_Hewitt_Associate_ID__c = 'A00000';
            contact.Associate_ID__c = 'A00000';
            //contact.Source_HR_System__c = 'Aon Hewitt';
            contact.Aon_Hewitt_Employee_Status__c = 'Active';
        }
        
        // insert the record
        if (saveBeforeExit) {
            insert contact;
        }
        
        // return the record
        return contact;
    }
    
    
    // method to create and return a contact record populated with the fields required to facilitate record creation
    public static Contact createContact(String accountId, String recordTypeId, String fName, String lName, String email, String billingCountry, String functionalRole, String associateId) {
        // declare local vars
        Contact contact = new Contact();
        
        // populate the record with values
        contact.RecordTypeId = recordTypeId;
        contact.FirstName = fName;
        contact.LastName = lName;
        contact.email = email;
        contact.AccountId = accountId;
        contact.SDO_Mailing_Country_Name__c = billingCountry;
        contact.Functional_Role__c = functionalRole;
        contact.Associate_ID__c = associateId;
        
        // insert the record
        insert contact;
        // return the record
        return contact;
    }
    
    // method to create an opportunity with the US oppty record type, populated with the minimum amount of required fields
    public static Opportunity createOpportunity_US(String accountId) {
        return createOpportunity(accountId, getRecordType('Opportunity', 'Oppty Record').Id, 'Killer Whale Opportunity', 1000.0, 'Qualify Opportunity', Date.today().addDays(30), 25);
    }

    // method to create an opportunity with the US oppty record type, populated with the minimum amount of required fields
    public static Opportunity createOpportunityForAccount(String accountId, Boolean shouldInsert) {
        Opportunity oppty = new Opportunity();
        
        // populate the record with values
        oppty.RecordTypeId = getRecordType('Opportunity', 'Oppty Record').Id;
        oppty.accountId = accountId;
        oppty.name = 'Test Oppty';
        oppty.amount = 1000.0;
        oppty.StageName = 'Qualify Opportunity';
        oppty.CloseDate = Date.today().addDays(30);
        oppty.Probability = 25;
        
        if(shouldInsert){
            insert oppty;
        }
        // return the record
        return oppty;
    }
    
    // method to create and return an opportunity record populated with the fields required to facilitate record creation
    public static Opportunity createOpportunity(String accountId, String recordTypeId, String name, Decimal amount, String stage, Date closeDate, Decimal probability) {
        // declare local vars
        Opportunity oppty = new Opportunity();
        
        // populate the record with values
        oppty.RecordTypeId = recordTypeId;
        oppty.accountId = accountId;
        oppty.name = name;
        oppty.amount = amount;
        oppty.StageName = stage;
        oppty.CloseDate = closeDate;
        oppty.Probability = probability;
        
        // insert the record
        insert oppty;
        // return the record
        return oppty;
    }
    
    //Ritu Sharma - 00010036 - Method to create and return an opportunity record created from marketing lead record, populated with the fields required to facilitate record creation
    public static Opportunity createOpportunityFromMarLead(String accountId, String leadID, String recordTypeId, String name, Decimal amount, String stage, Date closeDate, Decimal probability) {
        // declare local vars
        Opportunity oppty = new Opportunity();
        
        // populate the record with values
        oppty.RecordTypeId = recordTypeId;
        oppty.accountId = accountId;
        oppty.Marketing_Lead_ID__c=leadID;
        oppty.name = name;
        oppty.amount = amount;
        oppty.StageName = stage;
        oppty.CloseDate = closeDate;
        oppty.Probability = probability;
        
        // return the record
        return oppty;
    }
    
    // method to create and return a product populated with the fields required to facilitate record creation
    public static Product2 createProduct(String name, String serviceClassification, Boolean useProductSpecificFieldList, String validationProcess) {
        // declare local vars
        Product2 product = new Product2();
        
        // populate the record with values
        product.Name = name;
        product.Service_Classification__c = serviceClassification;
        product.Use_Product_Specific_Field_List__c = useProductSpecificFieldList;
        product.Validation_Process__c = validationProcess;
        
        // insert the record
        insert product;
        // return the record
        return product;
    }
    
    // method to create and return a pricebook entry populated with the fields required to facilitate record creation
    public static PricebookEntry createPricebookEntry(String productId, String pricebookId, Decimal unitPrice) {
        // declare local vars
        PricebookEntry pbe = new PricebookEntry();
        
        // populate the record
        pbe.Pricebook2Id = pricebookId;
        pbe.Product2Id = productId;
        pbe.UnitPrice = unitPrice;
        pbe.IsActive = true;
        
        // insert the record
        insert pbe;
        // return the record
        return pbe;
    }
        
    
    // method to create a standard price for a given product
    public static PricebookEntry createStandardPriceForProduct(String productId, Decimal standardPrice) {
        // declare local vars
        PricebookEntry pbe = new PricebookEntry();
        //Pricebook2 pb2 = [select id from Pricebook2 where IsActive = true and IsStandard = true LIMIT 1];
        
        Id standardPriceBookId = Test.getStandardPricebookId();
        return createPricebookEntry(productId, standardPriceBookId, standardPrice); 
    }
    
    // method to get the standard pricebook
    public static Pricebook2 getStandardPricebook() {
        return [select id, name from Pricebook2 where IsActive = true and IsStandard = true LIMIT 1];
    }
    
    // method to get the standard pricebook
    public static Id getStandardPricebookId() {
        return Test.getStandardPricebookId();
    }    
    // method to create and return an opportunity line item populated with the fields required to facilitate record creation
    public static OpportunityLineItem createOpportunityProduct(String opptyId, String pricebookEntryId, Integer quantity, Decimal salePrice) {
        return createOpportunityProduct(opptyId, pricebookEntryId, quantity, salePrice, 'Recurring', 'Fee', 'New Client Sale - A');
    }
    public static OpportunityLineItem createOpportunityProduct(String opptyId, String pricebookEntryId, Integer quantity, Decimal salePrice, String recurringOrNone, String feeOrCommission, String oliType) {
        // declare local vars
        OpportunityLineItem oli = new OpportunityLineItem();
        
        // populate the record
        oli.OpportunityId = opptyId;
        oli.PricebookEntryId = pricebookEntryId;
        oli.Quantity = quantity;
        oli.UnitPrice = salePrice;
        oli.Recurring_Non_Recurring__c = recurringOrNone;
        oli.Fee_Commission__c = feeOrCommission;
        oli.Type__c = oliType;
        oli.First_Year_Value__c = 10;
        
        // insert the record
        insert oli;
        // return the record
        return oli;
    }
    
    // method to create and return a product field list populated with the received details
    public static Product_Field_List__c createProductFieldList(String sourceObject, String fieldName, Integer sequence, String opptyRecordTypeId, String opptyStage, String serviceClassification, String productId, String recordTypeId) {
        // declare local vars
        Product_Field_List__c pfl = new Product_Field_List__c();
        
        // populate the record
        pfl.Source_Object__c = sourceObject;
        pfl.Field_Name__c = fieldName;
        pfl.Opportunity_Record_Type__c = opptyRecordTypeId;
        pfl.Opportunity_Stage__c = opptyStage;
        pfl.Product_Service_Classification__c = serviceClassification;
        pfl.Sort_Order__c = sequence;
        pfl.Product_Id__c = productId;
        pfl.recordTypeId = recordTypeId;
        
        // insert the record
        insert pfl;
        // return the record
        return pfl;
    }
    
    // method to create and return a product field list populated with the received details for the read only interface
    public static Product_Field_List__c createProductFieldList_ReadOnly(String sourceObject, String fieldName, Integer sequence, String opptyRecordTypeId, String opptyStage, String serviceClassification, String productId) {
        RecordType rt = [select id from RecordType where IsActive = true and sObjectType = 'Product_Field_List__c' and Name = 'Read Only UI Field'];
        return createProductFieldList(sourceObject, fieldName, sequence, opptyRecordTypeId, opptyStage, serviceClassification, productId, rt.Id);
    } 
    
    // method to create and return a product field list populated with the received details for the edit interface
    public static Product_Field_List__c createProductFieldList_EntryEdit(String sourceObject, String fieldName, Integer sequence, String opptyRecordTypeId, String opptyStage, String serviceClassification, String productId) {
        RecordType rt = [select id from RecordType where IsActive = true and sObjectType = 'Product_Field_List__c' and Name = 'Edit UI Field'];
        return createProductFieldList(sourceObject, fieldName, sequence, opptyRecordTypeId, opptyStage, serviceClassification, productId, rt.Id);
    } 
    
    // method to create and return a user that has been created with the received profile and populated with defaulted data
    public static User createUser(Profile profile) {    
        
        // populate the user record
        return createUser(profile, '999AAA');
    }
    
    public static User createUser(Profile profile, Boolean saveBeforeExit) {    
        
        // populate the user record
        return createUser(profile, '999AAA', saveBeforeExit);
    }
    
    // method to create and return a user that has been created with the received profile and populated with defaulted data
    public static User createUser(Profile profile, String associateId) {    
        
        // populate the user record
        User testUser = new User(emailencodingkey='UTF-8',languagelocalekey='en_US',localesidkey='en_US',timezonesidkey='America/New_York');
        testUser.Alias = util_globalUtilityMethods.generateRandomString(5);
        testUser.email = util_globalUtilityMethods.generateRandomString(10) + '@aon.com';
        testUser.lastname = util_globalUtilityMethods.generateRandomString(10);
        testUser.username = testUser.email;
        testUser.ProfileId = profile.Id;
        testUser.LanguageLocaleKey = 'en_US';
        testUser.Associate_ID__c = associateId;
        
        // insert the record
        insert testUser;
        // return the user
        return testUser;
    }
    
    
    // method to create and return a user that has been created with the received profile and populated with defaulted data
    public static User createUser(Profile profile, String associateId, Boolean saveBeforeExit) {    
        // populate the user record
        User testUser = new User(emailencodingkey='UTF-8',languagelocalekey='en_US',localesidkey='en_US',timezonesidkey='America/New_York');
        testUser.Alias = util_globalUtilityMethods.generateRandomString(5);
        testUser.email = util_globalUtilityMethods.generateRandomString(10) + '@aon.com';
        testUser.lastname = util_globalUtilityMethods.generateRandomString(10);
        testUser.username = testUser.email;
        testUser.ProfileId = profile.Id;
        testUser.LanguageLocaleKey = 'en_US';
        testUser.Associate_ID__c = associateId;
        
        if (saveBeforeExit) {
            // insert the record
            insert testUser;
        }
        
        // return the user
        return testUser;
    }
    
    
    // method to create and return an admin user that has been created and populated with defaulted data
    public static User createAdminUser() {
        return createUser([select id from Profile where Name = 'System Administrator']);    
    }
    
    // method to create and return a standard user that has been created and populated with defaulted data
    public static User createHewittStandardUser() {
        return createUser([select id from Profile where Name = 'Standard User Profile']);   
    }
    
    // method to create and return a standard user that has been created and populated with defaulted data
    public static User createHewittStandardUser(Boolean saveBeforeExit) {
        return createUser([select id from Profile where Name = 'Standard User Profile'], saveBeforeExit);   
    }
    
    
    // method to create and return multiple Users. Chintan, August 02, 2012 
    public static List<User> createHewittStandardUser_bulk(Integer numToCreate, Boolean saveBeforeExit) {
        List<User> recordsToCreate = new List<User>();
        Profile profile = [select id from Profile where Name = 'Standard User Profile'];
        
        for (Integer x = 0; x < numToCreate; x++) {
            User testUser = new User(emailencodingkey='UTF-8',languagelocalekey='en_US',localesidkey='en_US',timezonesidkey='America/New_York');
            testUser.Alias = util_globalUtilityMethods.generateRandomString(5);
            testUser.email = util_globalUtilityMethods.generateRandomString(10) + '@aon.com';
            testUser.lastname = 'Contact ' + x;
            testUser.username = testUser.email;
            testUser.ProfileId = profile.Id;
            testUser.Associate_ID__c = 'A00000';
            recordsToCreate.add(testUser);
        }
        if (saveBeforeExit) {
            // insert the records
            insert recordsToCreate;
        }
        // return the records
        return recordsToCreate;
    } //createHewittStandardUser_bulk
    
    
    // method to create and return a populated opportunity edit section
    public static Opportunity_Edit_Section__c createOpptyEditSection(List<String> opptyFieldsToIncludeInSection) {
        // declare local vars
        Opportunity_Edit_Section__c section = new Opportunity_Edit_Section__c();
        List<Opportunity_Edit_Field__c> fieldsToCreate = new List<Opportunity_Edit_Field__c>();
        
        // populate the record
        section.Columns__c = 1;
        section.Collapsible__c = true;
        section.Name = util_globalUtilityMethods.generateRandomString(5);
        section.Sort_Order__c = 1;
        
        // insert the record
        insert section;
        
        // iterate over the received field names and create section fields
        for (Integer x = 0; x < opptyFieldsToIncludeInSection.size(); x++) {
            Opportunity_Edit_Field__c editField = new Opportunity_Edit_Field__c();
            editField.Field_Name__c = opptyFieldsToIncludeInSection[x];
            editField.Sort_Order__c = x + 1;
            editField.Opportunity_Edit_Section__c = section.Id;
            fieldsToCreate.add(editField);
        }       
        
        // insert the records
        insert fieldsToCreate;
        // return the data
        return [Select Name, Collapsible__c, Columns__c, (Select Field_Name__c From Opportunity_Edit_Fields__r Order By Sort_Order__c) From Opportunity_Edit_Section__c Where Id = :section.Id Order By Sort_Order__c];     
    }
    
    // method to create and return a pricebook populated with defaulted data
    public static Pricebook2 createPricebook() {
        return null;
    }
    
    // method to retrieve the recordtype information for US Oppty Record opportunity record type
    public static RecordType getOpportunityRecordType_USOpptyRecord() {
        return [select id, name from RecordType where IsActive = true and sObjectType = 'Opportunity' and Name = 'Oppty Record'];
    }
    
    //method to create and return an Opportunity Sales Credit record
    public static Sales_Credit__c createSalesCredit(String opportunityId, String contactId) {
        // declare local vars
        Sales_Credit__c stc = new Sales_Credit__c();
        
        // populate the record
        stc.Related_Opportunity__c = opportunityId;
        stc.Credit_Recipient__c = contactId;
        stc.Sales_Credit__c = 50;
        stc.Dual_Initiation_Credit__c = 50;
        stc.Sales_Assist_Credit__c = 50;
        
        // insert the record
        insert stc;
        
        // return the record
        return stc;
    } //createSalesCredit
    
    
    
    //method to create and return an Opportunity Sales Credit record with conditional insert
    public static Sales_Credit__c createSalesCredit(String opportunityId, String contactId, Boolean saveBeforeExiting) {
        // declare local vars
        Sales_Credit__c stc = new Sales_Credit__c();
        
        // populate the record
        stc.Related_Opportunity__c = opportunityId;
        stc.Credit_Recipient__c = contactId;
        stc.Sales_Credit__c = 50;
        stc.Dual_Initiation_Credit__c = 50;
        stc.Sales_Assist_Credit__c = 50;
        
        if (saveBeforeExiting) {
            // insert the record
            insert stc;
        }
        
        // return the record
        return stc;
    } //createSalesCredit
    
    
    //method to create and return an internal account team record
    public static Internal_Account_Team__c createInternalAccountTeam(String accountId, String contactId, String role) {
        //local var
        Internal_Account_Team__c iat = new Internal_Account_Team__c();
        
        //populate the record with values
        iat.Account__c = accountId;
        iat.Contact__c = contactId;
        iat.Contact_Role__c = role;
        
        //insert record
        insert iat;
        
        //return record
        return iat;
    }
    
    
    //method to create and return bulk internal account team records. Chintan, August 03, 2012
    public static List<Internal_Account_Team__c> createInternalAccountTeam_bulk(String accountId, List<String> contactIds, String role, integer numToCreate, Boolean saveBeforeExit) {
        //local var
        List<Internal_Account_Team__c> iatList = new List<Internal_Account_Team__c> ();
        
        for (integer i=0; i<numToCreate; i++) {
            Internal_Account_Team__c iat = new Internal_Account_Team__c ();
            iat.Account__c = accountId;
            iat.Contact__c = contactIds[i];
            iat.Contact_Role__c = role;
            
            iatList.add(iat);
        }
        
        //insert record
        if (saveBeforeExit) {
            insert iatList;
        }
        
        //return records
        return iatList;
    } //createInternalAccountTeam_bulk
    
    
    //csModBegin VinodK 11/15/2011 #00005704 Method to create Sample data of Contact Publication
    public static Contact_Publication__c CreateContactPublication(String ContactID,String Country,String Publication){
    
        Contact_Publication__c  CP = new Contact_Publication__c();
        CP.Associated_Contacts__c = ContactID;
        CP.Country__c = Country;
        CP.Publications__c = Publication;
        //Insert Contact Publication
        insert CP;
        //Return Contact Publication
        return CP;
    }
    //csModEnd VinodK 11/15/2011 #00005704 Method to create Sample data of Contact Publication
    
    //Case No. 00006090 - START - Added to create a dummy external contact
    public static Contact createContact_External(String fName, String lName, String recordTypeID,String emailID,String accountID,Boolean billingCon)
    {
      //Creating a contact object on the basis of values passed through arguments but not doing any DML operation
      Contact contact = new Contact();
      contact.RecordTypeId = recordTypeID;
      contact.FirstName = fName;
      contact.LastName = lName;
      contact.email = emailID;
      contact.AccountId = accountID;
      contact.SDO_Mailing_Country_Name__c = 'India';
      contact.Functional_Role__c = 'Other - Other';
      contact.Billing_Contact__c=billingCon;
      contact.Functional_Role__c = 'Other - Other';
      
      if(billingCon)
      {
         contact.SDO_Billing_Country_Name__c='India';
         contact.OtherStreet='Street';
         contact.OtherCity='City';
         contact.OtherPostalCode='Postal Code';
         contact.OtherState='State';         
      }
      
      return contact;
    }
    //Case No. 00006090 - END
    
    // Method to create new campain
    public static Campaign createCampaign(){
    Campaign c = new Campaign();
    c.Name = 'Test Campaign for Testing';
    insert c;
    return c;
        
    }

}