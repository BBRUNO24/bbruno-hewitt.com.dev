@isTest
private class test_LexInputFieldCompCtrl {
	
	static testMethod void LexInputFieldCompCtrl() {
		Opportunity opp = new Opportunity();

		Test.startTest();
			LexInputFieldCompCtrl lexField = new LexInputFieldCompCtrl();
			System.assertEquals(lexField.objectName, '');

			lexField.inputObject = opp;
			lexField.fieldRendered = true;
			lexField.displayLabel = true;
			lexField.readOnlyOverride = false;

			System.assertEquals(lexField.getLabelDescribe(), null);

			lexField.fieldName = 'Name';
			System.assertEquals(lexField.isReadOnly, false);
			System.assertEquals(lexField.isInput, true);
			System.assertEquals(lexField.isTextArea, false);
			System.assertEquals(lexField.isPicklist, false);
			System.assertEquals(lexField.isMultiPicklist, false);
			System.assertEquals(lexField.isCheckbox, false);
			System.assertEquals(lexField.isDateTime, false);
			System.assertEquals(lexField.isLookup, false);

			System.assertEquals(lexField.getLabelDescribe(), 'Name');
			lexField.altLabel = 'Opportunity Name';
			System.assertEquals(lexField.getLabelDescribe(), 'Opportunity Name');			

			lexField.fieldName = 'StageName';
			System.assertEquals(lexField.isReadOnly, false);
			System.assertEquals(lexField.isInput, false);
			System.assertEquals(lexField.isTextArea, false);
			System.assertEquals(lexField.isPicklist, true);
			System.assertEquals(lexField.isMultiPicklist, false);
			System.assertEquals(lexField.isCheckbox, false);
			System.assertEquals(lexField.isDateTime, false);
			System.assertEquals(lexField.isLookup, false);	

			lexField.fieldName = 'Competitor__c';
			System.assertEquals(lexField.isReadOnly, false);
			System.assertEquals(lexField.isInput, false);
			System.assertEquals(lexField.isTextArea, false);
			System.assertEquals(lexField.isPicklist, false);
			System.assertEquals(lexField.isMultiPicklist, true);
			System.assertEquals(lexField.isCheckbox, false);
			System.assertEquals(lexField.isDateTime, false);
			System.assertEquals(lexField.isLookup, false);		

			lexField.fieldName = 'Bundled_Opportunity__c';
			System.assertEquals(lexField.isReadOnly, false);
			System.assertEquals(lexField.isInput, false);
			System.assertEquals(lexField.isTextArea, false);
			System.assertEquals(lexField.isPicklist, false);
			System.assertEquals(lexField.isMultiPicklist, false);
			System.assertEquals(lexField.isCheckbox, true);
			System.assertEquals(lexField.isDateTime, false);
			System.assertEquals(lexField.isLookup, false);			

			lexField.fieldName = 'Chatter_Update__c';
			System.assertEquals(lexField.isReadOnly, false);
			System.assertEquals(lexField.isInput, false);
			System.assertEquals(lexField.isTextArea, true);
			System.assertEquals(lexField.isPicklist, false);
			System.assertEquals(lexField.isMultiPicklist, false);
			System.assertEquals(lexField.isCheckbox, false);
			System.assertEquals(lexField.isDateTime, false);
			System.assertEquals(lexField.isLookup, false);				


			System.assertEquals(lexField.objectName, 'Opportunity');



		Test.stopTest();
	}
	
	
	
}