@isTest
private class test_utilGlobalUtilityMethods {

    static testMethod void myUnitTest() {
        
        String test1 = util_globalUtilityMethods.generateRandomString(10);
        String test2 = util_globalUtilityMethods.generateRandomString(10);
        System.assertNotEquals(test1, test2);
        
        Set <String> testSet = new Set<String>();
        testSet.add('1');
        testSet.add('2');
        String test3 = util_globalUtilityMethods.joinStringSet(testSet, false);
        System.assertEquals('1,2',test3);
        String test4 = util_globalUtilityMethods.joinStringSet(testSet, true);
        System.assertEquals('\'1\',\'2\'',test4);
        
        List <String> testList = new List<String>();
        testList.addAll(testSet);
        String test5 = util_globalUtilityMethods.joinStringSet(testList, false);
        System.assertEquals('1,2',test5);
        String test6 = util_globalUtilityMethods.joinStringSet(testList, true);
        System.assertEquals('\'1\',\'2\'',test6);
        
        util_globalUtilityMethods.getFieldsForObject('Opportunity');
    }
/*    
    static testMethod void validateSingleLongIDGenerator() {
		//Validate Single Insert
		System.debug('Validating Single Record Insertion');
		Account a1 = new Account(name = 'Test Account', SDO_Billing_Country_Name__c = 'UNITED STATES', BillingPostalCode = '60069', BillingState='IL');
		//Account a2 = util_sampleDataGenerator.createAccount_Client();
		
		Test.startTest();
		insert a1;
		Test.stopTest();
		//insert a2;
		a1 = [Select Id, Long_ID__c from Account Where Id =:a1.id];
		System.assertEquals(a1.Long_ID__c.length(), 18);
		System.debug('CHINTAN TEST CLASS: Long ID is: ' + a1.Long_ID__c);
	}
	
	
	static testMethod void validateBulkLongIDGenerator() {		
		//Validating Bulk Record Insertion
		List<Account> testAccounts = new List<Account> ();
		for (integer i=0; i<30; i++) {
			testAccounts.add(new Account(name = 'Test Account '+i, SDO_Billing_Country_Name__c = 'UNITED STATES', BillingPostalCode = '60069', BillingState='IL'));
		}
		Test.startTest();
		insert testAccounts;
		Test.stopTest();
		for (Account acct:[Select Id, Long_ID__c from Account Where createdDate = TODAY]) {
			System.assertEquals(acct.Long_ID__c.length(), 18);
			System.debug('CHINTAN TEST CLASS: Long ID is: ' + acct.Long_ID__c);
		}
	}
*/	
}