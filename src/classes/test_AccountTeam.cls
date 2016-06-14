@isTest
private class test_AccountTeam {
	@testSetup static void setupData() {
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

        Account acc1 = util_SampleDataGenerator.createAccount_Client();
        acc1.Region_Market_Override__c = true;
        acc1.Region__c = 'Africa';
        update acc1;
        System.assertEquals('Africa', acc1.Region__c, 'It should have an updated region');

        Account acc2 = util_SampleDataGenerator.createAccount_Client();
        acc2.Region_Market_Override__c = true;
        acc2.Region__c = 'Greater China';
        update acc2;
        System.assertEquals('Greater China', acc2.Region__c, 'It should have an updated region');

        Account acc3 = util_SampleDataGenerator.createAccount_Client();
        acc3.Region_Market_Override__c = true;
        acc3.Region__c = 'US - East';
        update acc3;
        System.assertEquals('US - East', acc3.Region__c, 'It should have a region');

        Account acc4 = util_SampleDataGenerator.createAccount_Client();
        acc4.Region_Market_Override__c = true;
        acc4.Region__c = 'Central America';
        update acc4;
        System.assertEquals('Central America', acc4.Region__c, 'It should have a region');

        User testUser1 = util_SampleDataGenerator.createHewittStandardUser(true);
        Contact c1 = util_SampleDataGenerator.createContact_Internal(acc1.Id);
        c1.Corresponding_User_Id__c = testUser1.Id;
        update c1;

        User testUser2 = util_SampleDataGenerator.createAdminUser();

        testUser1.ManagerId = testUser2.Id;
      update testUser1;

        Contact c2 = util_SampleDataGenerator.createContact_Internal(acc1.Id);
        c2.Corresponding_User_Id__c = testUser2.Id;
        update c2;

        Contact c3 = util_SampleDataGenerator.createContact_Internal(acc3.Id);
        c3.Corresponding_User_Id__c = testUser2.Id;
        update c3;

        Contact c4 = util_SampleDataGenerator.createContact_Internal(acc4.Id);
        c4.Corresponding_User_Id__c = testUser2.Id;
        update c4;

    }
	
    @isTest 
    static void testNoTeamRecords() {
		List<Internal_Account_Team__c> internalTeam = [SELECT Id FROM Internal_Account_Team__c];

		Test.startTest();
			System.assertEquals(0, internalTeam.size(), 'It should not have any internal contacts to start');
		Test.stopTest();
	}

	@isTest 
	static void testAfrica() {
		Account acc = [SELECT Id FROM Account WHERE Region__c = 'Africa' LIMIT 1];
		System.assertNotEquals(null, acc, 'It should  have an account for Africa');
		
		Contact con = [SELECT Id, Corresponding_User_Id__c FROM Contact WHERE AccountId = :acc.Id AND Corresponding_User_Id__r.ManagerId = null LIMIT 1];
		System.assertNotEquals(null, con, 'It should  have an contact for Africa');

		User u = [SELECT Id FROM User WHERE Id = :con.Corresponding_User_Id__c LIMIT 1];
		System.assertNotEquals(null, u, 'It should  have an user');

		List<Internal_Account_Team__c> internalTeam = [SELECT Id FROM Internal_Account_Team__c];
		System.assertEquals(0, internalTeam.size(), 'It should not have any internal contacts to start');

		Test.startTest();
			System.runAs(u){
				Opportunity opp = util_SampleDataGenerator.createOpportunityForAccount(acc.Id, false);
				opp.OwnerId = con.Corresponding_User_Id__c;
		        insert opp;

		        List<Internal_Account_Team__c> iat = [SELECT Id, Contact__c, Contact__r.Corresponding_User_Id__c FROM Internal_Account_Team__c];
		        System.assertEquals(1, iat.size(), 'It should have inserted 1 record');

		        System.assertEquals(u.Id, iat[0].Contact__r.Corresponding_User_Id__c, 'It should have inserted 1 record where the contacts user id matches');
			}
	     Test.stopTest();
	}

	@isTest 
	static void testAfricaOwnerChanges() {
		Account acc = [SELECT Id FROM Account WHERE Region__c = 'Africa' LIMIT 1];
		System.assertNotEquals(null, acc, 'It should  have an account for Africa');
		
		Contact con = [SELECT Id, Corresponding_User_Id__c FROM Contact WHERE AccountId = :acc.Id AND Corresponding_User_Id__r.ManagerId = null LIMIT 1];
		System.assertNotEquals(null, con, 'It should  have an contact for Africa');

		User u = [SELECT Id FROM User WHERE Id = :con.Corresponding_User_Id__c LIMIT 1];
		System.assertNotEquals(null, u, 'It should  have an user');

    Contact nextCon = [SELECT Id, Corresponding_User_Id__c FROM Contact WHERE Corresponding_User_Id__c != :u.Id LIMIT 1];

		User nextOwner = [SELECT Id FROM User WHERE Id = :nextCon.Corresponding_User_Id__c AND IsActive = true LIMIT 1];
		System.assertNotEquals(null, nextOwner, 'It should  have an user');
		System.assertNotEquals(u.Id, nextOwner.Id, 'It should  have a different user');

		List<Internal_Account_Team__c> internalTeam = [SELECT Id FROM Internal_Account_Team__c];
		System.assertEquals(0, internalTeam.size(), 'It should not have any internal contacts to start');

		List<Internal_Account_Team__c> iat;
		Opportunity opp;
		Test.startTest();
			opp = util_SampleDataGenerator.createOpportunityForAccount(acc.Id, false);
			opp.OwnerId = con.Corresponding_User_Id__c;
        System.runAs(u){
          insert opp;
        }

	        util_globalUtilityMethods.setRunOnceFlag(false);

	        iat = [SELECT Id, Contact__c, Contact__r.Corresponding_User_Id__c FROM Internal_Account_Team__c];
	        System.assertEquals(1, iat.size(), 'It should have inserted 1 record');

	        System.assertEquals(u.Id, iat[0].Contact__r.Corresponding_User_Id__c, 'It should have inserted 1 record where the contacts user id matches');				

	        opp.OwnerId = nextOwner.Id;
	        update opp;

	        opp = [SELECT Id, OwnerId, AccountId FROM Opportunity WHERE Id = :opp.Id LIMIT 1];

	        System.assertEquals(nextOwner.Id, opp.OwnerId, 'It should have updated the oppty owner');

	        Set<String> userIds = new Set<String>{u.Id, nextOwner.Id};
          Set<String> checked = new Set<String>();

	        iat = [SELECT Id, Contact__c, Account__c, Contact__r.Corresponding_User_Id__c FROM Internal_Account_Team__c];
	        System.assertEquals(2, iat.size(), 'It should have 2 records now for the Internal Account Team');
	        for(Internal_Account_Team__c i : iat){
            checked.add(i.Contact__r.Corresponding_User_Id__c);
	        	System.assertEquals(opp.AccountId, i.Account__c, 'It should have the account joined');
            System.assertNotEquals(null, i.Contact__r.Corresponding_User_Id__c, 'it should have a value for the UserId');
	        	System.assertEquals(true, userIds.contains(i.Contact__r.Corresponding_User_Id__c), 'It should have the correct user id');
	        }
          System.assertEquals(2, checked.size(), 'It should have two unique Ids');
	     Test.stopTest();
	}
	
	@isTest 
	static void testUSFails() {
		Account acc = [SELECT Id FROM Account WHERE Region__c = 'US - East' LIMIT 1];
		System.assertNotEquals(null, acc, 'It should  have an account for United State');
		
		Contact con = [SELECT Id, Corresponding_User_Id__c FROM Contact WHERE AccountId = :acc.Id AND Corresponding_User_Id__r.ManagerId = null LIMIT 1];
		System.assertNotEquals(null, con, 'It should  have an contact for US - East');

		User u = [SELECT Id FROM User WHERE Id = :con.Corresponding_User_Id__c LIMIT 1];
		System.assertNotEquals(null, u, 'It should  have an user');

		List<Internal_Account_Team__c> internalTeam = [SELECT Id FROM Internal_Account_Team__c];
		System.assertEquals(0, internalTeam.size(), 'It should not have any internal contacts to start');

		Test.startTest();
			System.runAs(u){
				Opportunity opp = util_SampleDataGenerator.createOpportunityForAccount(acc.Id, false);
				opp.OwnerId = con.Corresponding_User_Id__c;
        insert opp;
        List<Internal_Account_Team__c> iat = [SELECT Id, Contact__c, Account__c, Contact__r.Corresponding_User_Id__c FROM Internal_Account_Team__c];
        System.assertEquals(0, iat.size(), 'It should  have inserted 0 records');
			}
	     Test.stopTest();
	}

  @isTest 
  static void testCentralAmericaFails() {
    Account acc = [SELECT Id FROM Account WHERE Region__c = 'Central America' LIMIT 1];
    System.assertNotEquals(null, acc, 'It should  have an account for Central America');
    
    Contact con = [SELECT Id, Corresponding_User_Id__c FROM Contact WHERE AccountId = :acc.Id AND Corresponding_User_Id__r.ManagerId = null LIMIT 1];
    System.assertNotEquals(null, con, 'It should  have an contact for Central America');

    User u = [SELECT Id FROM User WHERE Id = :con.Corresponding_User_Id__c LIMIT 1];
    System.assertNotEquals(null, u, 'It should  have an user');

    List<Internal_Account_Team__c> internalTeam = [SELECT Id FROM Internal_Account_Team__c];
    System.assertEquals(0, internalTeam.size(), 'It should not have any internal contacts to start');

    Test.startTest();
      System.runAs(u){
        Opportunity opp = util_SampleDataGenerator.createOpportunityForAccount(acc.Id, false);
        opp.OwnerId = con.Corresponding_User_Id__c;
        insert opp;
        List<Internal_Account_Team__c> iat = [SELECT Id, Contact__c, Account__c, Contact__r.Corresponding_User_Id__c FROM Internal_Account_Team__c];
        System.assertEquals(0, iat.size(), 'It should  have inserted 1 records');
      }
       Test.stopTest();
  }
	
}