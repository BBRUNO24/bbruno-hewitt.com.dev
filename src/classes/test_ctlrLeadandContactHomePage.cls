/**
 * This class contains unit tests for validating the behavior of Apex classe ctlr_LeadandContactHomePage for #00014300
 * Created By- VinodK. 07/30/2012
 */
@isTest
private class test_ctlrLeadandContactHomePage {

    static testMethod void myUnitTest() {
        
// Calling the constructor
        ctlr_LeadandContactHomePage ctlrhome = new ctlr_LeadandContactHomePage();
// Calling the controller methods.
        ctlrhome.getActiveContacts();
        ctlrhome.getNewerLeads();
        ctlrhome.getOlderLeads();
        ctlrhome.getcontactmessage();
        ctlrhome.getnewleadmessage();
        ctlrhome.getoldleadmessage();
        ctlrhome.getShowNewLeadTable();
        ctlrhome.getShowoldLeadTable();
        ctlrhome.getshowActiveContacts();
    }
    
    
}