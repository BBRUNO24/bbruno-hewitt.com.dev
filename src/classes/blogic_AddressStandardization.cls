public with sharing class blogic_AddressStandardization {

	public static void syncContactBillingAddressCountry(List <Contact> contacts) {
		for(Contact contact : contacts) {
        	if(contact.SDO_Billing_Country_Name__c != NULL) {
            	contact.OtherCountry = contact.SDO_Billing_Country_Name__c;
        	}
    	}
	}
}