// This class is controller for "OpportunityProductRedirectPage" page 
// Whenever the user tries to open the Opportunity Product page directly
// It will allow to redirect to the Opportunity View Page, 
// Cerated by : Amrita on “02/23/12”
public with sharing class ctrl_OpportunityProductRedirectPage {

    private ApexPages.StandardController controller;    // To store the standard controller object
    private OpportunityLineItem oli {get; set;}         // To Store the current Opp Prod 
    private String RevenueSchedulePage;                 // To Store the Revenue Schedule Page link
    
    // Constructor
    public ctrl_OpportunityProductRedirectPage(ApexPages.StandardController controller) {
        this.controller = controller;
    }
    
    // This method will be called on Opportunity Page Load through JS Code
    public String getRevenueSchedulePage() {
        String strReturnVal = '';
        // The Opportunity Product Page should always be redirected to Opportunity View Page
        if (((OpportunityLineItem)controller.getRecord()).Id != null) {
                this.oli = Database.query('select OpportunityId from OpportunityLineItem where id = \'' + ((OpportunityLineItem)controller.getRecord()).Id + '\'');
                String SfBaseURL = System.URL.getSalesforceBaseUrl().toExternalForm();
                String URL = SfBaseURL + '/' + (this.oli).OpportunityId;
                strReturnVal = URL;
        }
        return strReturnVal;
    }
}