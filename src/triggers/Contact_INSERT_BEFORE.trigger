trigger Contact_INSERT_BEFORE on Contact (before insert) {

    //Case No. 00006090 - Added to avoid duplicate contacts i.e. contacts having same email id
    blogic_Contact.restrictDupExternalContacts(null,trigger.new); 
    
    //Case No. 00010091 - Intialize variables to 0 if no value added
    blogic_Contact.initializeCurrencyVariables(trigger.new);
    
    // sync billing country
    blogic_AddressStandardization.syncContactBillingAddressCountry(trigger.new);
}