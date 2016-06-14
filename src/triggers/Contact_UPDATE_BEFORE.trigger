trigger Contact_UPDATE_BEFORE on Contact (before update) 
{
    //Case No. 00006090 - Added to avoid duplicate external contacts i.e. contacts having same email id
    //Duplicate check, only if trigger is fired for the 1st time
    if(!util_globalUtilityMethods.checkRestrictDupExternalContacts) {        
        blogic_Contact.restrictDupExternalContacts(trigger.oldMap,trigger.new);
    }
    
    // sync billing country
    blogic_AddressStandardization.syncContactBillingAddressCountry(trigger.new);
    
    //Case No. 00010091 - Intialize variables to 0 if no value added
    blogic_Contact.initializeCurrencyVariables(trigger.new);
}