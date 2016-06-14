/** Controller for a new Client Assessment Survey Form
  * Case 22431. Chintan Adhyapak. October 03, 2012 */
public with sharing class ctlr_ClientAssessmentNew {
    //Class variables
    public Client_Assessment_Survey__c myCas {get; set;}
    public Account myAccount {get; set;}
    public String headerMsg {get; set;}
    
    // Constructor
    public ctlr_ClientAssessmentNew(ApexPages.StandardController controller) {
        //Get Account Id
        String myAccountId = ApexPages.currentPage().getParameters().get('RetURL');
        myAccountId = myAccountId.substring(1, myAccountId.length());
        System.debug('myAccountId: ' + myAccountId);
        
        //Get Account Data
        myAccount = [Select Id, Active_DB_Ret_PPTS__c, Active_DC_Ret_PPTS__c, Active_Health_Care_PPTS__c from Account Where Id = :myAccountId];
        
        //Get Outsourcing Service Provider data for this account
        Core_Service_Providers__c myServiceProviders = [Select Id, Defined_Benefit_Administrator__c, Defined_Benefit_End_Date__c, Defined_Contribution_Administrator__c, 
            Defined_Contribution_End_Date__c, Health_Welfare_Administrator__c, Health_Welfare_End_Date__c From Core_Service_Providers__c 
            Where Account__c = :myAccountId];
            
        //Get handle to current record
        Client_Assessment_Survey__c currRec = (Client_Assessment_Survey__c)controller.getRecord();
        
        //Get Previous Quarter's Survey Data
        integer surveyCount = [Select Count() from Client_Assessment_Survey__c Where Account__c = :myAccountId];
        if (surveyCount > 0) {
            myCas = [Select Year__c, Quarter__c, H_B_Consulting__c, H_W_Admin__c, Absence_Mgmt__c, Exchanges__c, Advocacy__c, Dependent_Verification__c, 
                Spending_Acct_Admin__c, Actuarial__c, Investment__c, DB_Admin__c, DC_Admin__c, Advisory__c, Compensation__c, Engagement__c, Selection_Assessment__c, Talent_Acquisition_Solutions__c, 
                HRE__c, Leadership__c, Communications__c, AMAS_M_A__c, Global_Benefits_Brokerage__c, BPO__c, Is_CY_Account_Plan_On_File__c, // Overall_Relationship_Status__c,  //Removed for case 135733
                Consulting_Relationship_Status__c, Outsourcing_Relationship_Status__c, ARS_Relationship__c, Risks__c, Opportunities__c from Client_Assessment_Survey__c 
                Where Account__c = :myAccountId order by CreatedDate Desc limit 1];
            headerMsg = 'Note: For your convenience, this survey has been prepopulated with data from the survey filled out for Year ' + myCas.Year__c + ' and Quarter ' + myCas.Quarter__c;
            
            //Pre Load Data from Last Survey
            currRec.H_B_Consulting__c = myCas.H_B_Consulting__c;
            currRec.H_W_Admin__c = myCas.H_W_Admin__c;
            currRec.Absence_Mgmt__c = myCas.Absence_Mgmt__c;
            currRec.Exchanges__c = myCas.Exchanges__c;
            currRec.Advocacy__c = myCas.Advocacy__c;
            currRec.Dependent_Verification__c = myCas.Dependent_Verification__c;
            currRec.Spending_Acct_Admin__c = myCas.Spending_Acct_Admin__c;
            currRec.Actuarial__c = myCas.Actuarial__c;
            currRec.Investment__c = myCas.Investment__c;
            currRec.DB_Admin__c = myCas.DB_Admin__c;
            currRec.DC_Admin__c = myCas.DC_Admin__c;
            currRec.Advisory__c = myCas.Advisory__c;
            currRec.Compensation__c = myCas.Compensation__c;
            currRec.Engagement__c = myCas.Engagement__c;
            currRec.Selection_Assessment__c = myCas.Selection_Assessment__c;
            currRec.Talent_Acquisition_Solutions__c = myCas.Talent_Acquisition_Solutions__c;
            currRec.HRE__c = myCas.HRE__c;
            currRec.Leadership__c = myCas.Leadership__c;
            currRec.Communications__c = myCas.Communications__c;
            currRec.AMAS_M_A__c = myCas.AMAS_M_A__c;
            currRec.Global_Benefits_Brokerage__c = myCas.Global_Benefits_Brokerage__c;
            currRec.BPO__c = myCas.BPO__c;
            currRec.Is_CY_Account_Plan_On_File__c = myCas.Is_CY_Account_Plan_On_File__c;
            //currRec.Overall_Relationship_Status__c = myCas.Overall_Relationship_Status__c; //Removed for case 135733
            currRec.Consulting_Relationship_Status__c = myCas.Consulting_Relationship_Status__c;
            currRec.Outsourcing_Relationship_Status__c = myCas.Outsourcing_Relationship_Status__c;
            currRec.ARS_Relationship__c = myCas.ARS_Relationship__c;
            currRec.Risks__c = myCas.Risks__c;
            currRec.Opportunities__c = myCas.Opportunities__c;
            
        } else {
            headerMsg = '';
        }
        
        //Preload Service Provider data
        currRec.DB_Administrator__c = myServiceProviders.Defined_Benefit_Administrator__c;
        currRec.DC_Administrator__c = myServiceProviders.Defined_Contribution_Administrator__c;
        currRec.HW_Administrator__c = myServiceProviders.Health_Welfare_Administrator__c;
        currRec.DB_Contract_End_Date__c = myServiceProviders.Defined_Benefit_End_Date__c;
        currRec.DC_Contract_End_Date__c = myServiceProviders.Defined_Contribution_End_Date__c;
        currRec.HW_Contract_End_Date__c = myServiceProviders.Health_Welfare_End_Date__c;
        
        //Preload Account Data
        currRec.Active_DB_Ret_PPTS__c = myAccount.Active_DB_Ret_PPTS__c;
        currRec.Active_DC_Ret_PPTS__c = myAccount.Active_DC_Ret_PPTS__c;
        currRec.Active_Health_Care_PPTS__c = myAccount.Active_Health_Care_PPTS__c;
    } 
}