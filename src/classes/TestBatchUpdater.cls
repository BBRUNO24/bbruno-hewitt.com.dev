@isTest
private class TestBatchUpdater {

  @TestSetup
  static void setupAccount(){
    Organizational_Defaults__c orgDefaultSettings = new Organizational_Defaults__c();
    orgDefaultSettings.Enable_CAPIS_Id_Assignment__c = false;
    insert orgDefaultSettings;

    Territory__c il = new Territory__c(Public_Group_Id__c=UserInfo.getUserId(), Name='IL', Country__c='United States');
    Territory__c ny = new Territory__c(Public_Group_Id__c=UserInfo.getUserId(), Name='NY', Country__c='United States');
    Territory__c ca = new Territory__c(Public_Group_Id__c=UserInfo.getUserId(), Name='CA', Country__c='Canada', Areas_included_in_Territory__c='CA;ON');

    Territory__c can = new Territory__c(Public_Group_Id__c=UserInfo.getUserId(), Name='CA', Country__c='United States', Areas_included_in_Territory__c='');
    Territory__c qc = new Territory__c(Public_Group_Id__c=UserInfo.getUserId(), Name='QC', Country__c='Canada', Areas_included_in_Territory__c='QC;c');
    Territory__c sk = new Territory__c(Public_Group_Id__c=UserInfo.getUserId(), Name='SK', Country__c='Canada', Areas_included_in_Territory__c='SK');
    Territory__c yt = new Territory__c(Public_Group_Id__c=UserInfo.getUserId(), Name='YT', Country__c='Canada', Areas_included_in_Territory__c='YT');
    Territory__c onT = new Territory__c(Public_Group_Id__c=UserInfo.getUserId(), Name='ON', Country__c='Canada', Areas_included_in_Territory__c='ON');
    List<Territory__c> ter = new List<Territory__c>();
    ter.add(il);
    ter.add(can);
    ter.add(ny);
    ter.add(qc);
    ter.add(sk);
    ter.add(yt);
    ter.add(onT);
    insert ter;

    SIC_Code_to_Industry_Mapping__c sic = new SIC_Code_to_Industry_Mapping__c();
    sic.Name = '9932';
    sic.Aon_Global_Industry_Level_4__c = 'Museums, Art Galleries, And Botanical And Zoological Gardens Other';
    sic.Aon_Global_Industry_Level_2__c = 'Museums, Art Galleries, And Botanical And Zoological Gardens';
    sic.Industry__c = 'Entertainment and Leisure';
    insert sic;

    SIC_Code_to_Industry_Mapping__c sic1 = new SIC_Code_to_Industry_Mapping__c();
    sic1.Name = '9933';
    sic1.Aon_Global_Industry_Level_4__c = 'Motor Freight Transportation And Warehousing Other';
    sic1.Aon_Global_Industry_Level_2__c = 'Motor Freight Transportation And Warehousing';
    sic1.Industry__c = 'Transportation and Logistics';
    insert sic1;

    Contact con = new Contact();
    con.Corresponding_User_Id__c = UserInfo.getUserId();
    con.FirstName = 'Test';
    con.LastName = 'User';
    insert con;
    System.assertNotEquals(null, con.Id, 'It should have a an ID saved');

    Single_Entry_Roles__c singleRole = new Single_Entry_Roles__c();
    singleRole.Name = 'Test';
    insert singleRole;

    List<Zip_Code_to_Market_Mapping__c> zips = new List<Zip_Code_to_Market_Mapping__c>();
    zips.add(new Zip_Code_to_Market_Mapping__c(Market__c='Chicago', Name='600', City__c='Chicago', State__c='IL', Country__c='United States', Global_Region__c='North America', Market_Lead__c=UserInfo.getUserId(), CCO__c=UserInfo.getUserId(), Market_Lead_Email__c='Aon@test.com', Region__c='Midwest', Region_Director__c=UserInfo.getUserId(), Sales_Analyst__c=UserInfo.getUserId()));
    zips.add(new Zip_Code_to_Market_Mapping__c(Market__c='New Random', Name='988', City__c='Random City', State__c='CA', Country__c='United States', Global_Region__c='North America', Market_Lead__c=UserInfo.getUserId(), CCO__c=UserInfo.getUserId(), Market_Lead_Email__c='Aon@test.com', Region__c='Midwest', Region_Director__c=UserInfo.getUserId(), Sales_Analyst__c=UserInfo.getUserId()));
    zips.add(new Zip_Code_to_Market_Mapping__c(Market__c='London', Name='UK', City__c='London', State__c='ON', Country__c='United Kingdom', Global_Region__c='Europe', Market_Lead__c=UserInfo.getUserId(), CCO__c=UserInfo.getUserId(), Market_Lead_Email__c='Aon@test.com', Region__c='Midwest', Region_Director__c=UserInfo.getUserId(), Sales_Analyst__c=UserInfo.getUserId()));
    zips.add(new Zip_Code_to_Market_Mapping__c(Market__c='London', Name='ON', City__c='London', State__c='ON', Country__c='Canada', Global_Region__c='Europe', Market_Lead__c=UserInfo.getUserId(), CCO__c=UserInfo.getUserId(), Market_Lead_Email__c='Aon@test.com', Region__c='Midwest', Region_Director__c=UserInfo.getUserId(), Sales_Analyst__c=UserInfo.getUserId()));
    zips.add(new Zip_Code_to_Market_Mapping__c(Market__c='London', Name='111', City__c='NYC', State__c='NY', Country__c='United States', Global_Region__c='North America', Market_Lead__c=UserInfo.getUserId(), CCO__c=UserInfo.getUserId(), Market_Lead_Email__c='Aon@test.com', Region__c='Midwest', Region_Director__c=UserInfo.getUserId(), Sales_Analyst__c=UserInfo.getUserId()));
    insert zips;

    Account account = util_SampleDataGenerator.createPeopleSoftClient('TEST ACCOUNT', util_SampleDataGenerator.getRecordType('Account', 'Client Account Record Type').Id, false);
    account.Additional_CAPIS_Indicator__c = 'Yes';
    account.ACW_Client_Type__c = 'Client';
    account.Account_Status__c = 'Active';
    account.Global_Region__c = 'North America';
    account.Region_Market_Override__c = true;
    insert account;
    System.assertNotEquals(null, account.Id); 
  }

  @isTest
  static void itShould()  {
    Account acc = [SELECT Id, Name FROM Account LIMIT 1];

    System.assertEquals('TEST ACCOUNT', acc.Name, 'it should have TEST ACCOUNT as the name');

    BatchUpdateController controller = new BatchUpdateController();

    List<SelectOption> opts = controller.getObjectOptions();
    System.assertEquals(true, opts.size() > 0, 'It should have options');
    PageReference ref;// = controller.showEstimates();
    controller.batchConfig.objectApiName = 'Account';
    controller.batchConfig.fieldApiName = 'name';
    controller.batchConfig.oldValue = 'TEST ACCOUNT';

    ref = controller.doNothing();
    List<SelectOption> fieldOpts = controller.getFieldOptions();
    System.assertEquals(true, opts.size() > 0, 'It should have options');
    System.assertEquals(false, controller.batchConfig.hasCounted, 'It should NOT have counted'); 
    System.assertEquals(false, controller.batchConfig.getIsValid(), 'It should NOT be valid'); 

    ref = controller.showEstimates();
    System.assertEquals(false, controller.batchConfig.hasCounted, 'It should NOT have counted'); 
    System.assertEquals(false, controller.batchConfig.getIsValid(), 'It should NOT be valid'); 

    controller.batchConfig.changeToValue = 'Update';
    ref = controller.showEstimates();
    System.assertEquals(1, controller.batchConfig.recordCount, 'It should return one record'); 
    System.assertEquals(true, controller.batchConfig.hasCounted, 'It should have counted'); 
    System.assertEquals(false, controller.batchConfig.result.isComplete, 'It should NOT be complete'); 

    ref = controller.doUpdate();
    System.assertEquals(false, controller.batchConfig.hasCounted, 'It should not have counted'); 
    System.assertEquals(1, controller.updates.size(), 'It should have 1 result'); 
    System.assertEquals(true, controller.updates[0].result.isComplete, 'It should be complete'); 

    List<Account> accounts = [SELECT Id FROM Account WHERE Name = :controller.updates[0].changeToValue];
    System.assertEquals(1, accounts.size(), 'It should have one account');

    accounts.clear();
    accounts = [SELECT Id FROM Account WHERE Name = :controller.updates[0].oldValue];
    System.assertEquals(0, accounts.size(), 'It should have no accounts');
  }

  @isTest
  static void itShouldHandleLots()  {
    List<Account> accs = util_SampleDataGenerator.createPeopleSoftClients('TEST BULK ACCOUNT', 200, false);


    for(Account a : accs){
      a.Additional_CAPIS_Indicator__c = 'Yes';
      a.ACW_Client_Type__c = 'Client';
      a.Account_Status__c = 'Active';
      a.Global_Region__c = 'North America';
      a.Region_Market_Override__c = true;
      System.assertEquals('TEST BULK ACCOUNT', a.Name, 'it should have TEST BULK ACCOUNT as the name');
    }
    insert accs;
    BatchUpdateController controller = new BatchUpdateController();

    List<SelectOption> opts = controller.getObjectOptions();
    System.assertEquals(true, opts.size() > 0, 'It should have options');
    PageReference ref;// = controller.showEstimates();
    controller.batchConfig.objectApiName = 'Account';
    controller.batchConfig.fieldApiName = 'name';
    controller.batchConfig.oldValue = 'TEST BULK ACCOUNT';

    ref = controller.doNothing();
    List<SelectOption> fieldOpts = controller.getFieldOptions();
    System.assertEquals(true, opts.size() > 0, 'It should have options');
    System.assertEquals(false, controller.batchConfig.hasCounted, 'It should NOT have counted'); 
    System.assertEquals(false, controller.batchConfig.getIsValid(), 'It should NOT be valid'); 

    ref = controller.showEstimates();
    System.assertEquals(false, controller.batchConfig.hasCounted, 'It should NOT have counted'); 
    System.assertEquals(false, controller.batchConfig.getIsValid(), 'It should NOT be valid'); 

    controller.batchConfig.changeToValue = 'Update';
    ref = controller.showEstimates();
    System.assertEquals(200, controller.batchConfig.recordCount, 'It should return one record'); 
    System.assertEquals(true, controller.batchConfig.hasCounted, 'It should have counted'); 
    System.assertEquals(false, controller.batchConfig.result.isComplete, 'It should NOT be complete'); 

    Test.startTest();
      ref = controller.doUpdate();
    Test.stopTest(); 

    System.assertEquals(false, controller.batchConfig.hasCounted, 'It should not have counted'); 
    System.assertEquals(1, controller.updates.size(), 'It should have 1 result'); 
    System.assertEquals(false, controller.updates[0].result.isComplete, 'It should be NOT be complete'); 

    List<Account> accounts = [SELECT Id FROM Account WHERE Name = :controller.updates[0].changeToValue];
    System.assertEquals(200, accounts.size(), 'It should have one account');

    ref = controller.fetchJobStatus();

    accounts.clear();
    accounts = [SELECT Id FROM Account WHERE Name = :controller.updates[0].oldValue];
    System.assertEquals(0, accounts.size(), 'It should have no accounts');
  }
}