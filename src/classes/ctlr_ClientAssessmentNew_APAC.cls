/** Controller for a new Client Assessment Survey Form for APAC
  * Case 98847. Chintan Adhyapak. October 10, 2013 */
public with sharing class ctlr_ClientAssessmentNew_APAC {
    //Class variables
    public Client_Assessment_Survey__c myCas {get; set;}
    public Account myAccount {get; set;}
    public Client_Assessment_Survey__c currRec {get; set;}
    
    // Constructor
    public ctlr_ClientAssessmentNew_APAC(ApexPages.StandardController controller) {
        //Get Account Id
        String myAccountId = ApexPages.currentPage().getParameters().get('RetURL');
        myAccountId = myAccountId.substring(1, myAccountId.length());
        System.debug('myAccountId: ' + myAccountId);
        
        //Get Account Data
        myAccount = [Select Id, Active_DB_Ret_PPTS__c, Active_DC_Ret_PPTS__c, Active_Health_Care_PPTS__c from Account Where Id = :myAccountId];
        
        //Get handle to current record
        currRec = (Client_Assessment_Survey__c)controller.getRecord();
        
        //Get Previous Quarter's Survey Data
        integer surveyCount = [Select Count() from Client_Assessment_Survey__c Where Account__c = :myAccountId];
        if (surveyCount > 0) {
            //read all fieldNames for Client_Assessment_Survey__c object
            Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Client_Assessment_Survey__c.fields.getMap();
        
            //Create a SOQL string with all fields
            String fieldNames = '';
            for(String fieldName : schemaFieldMap.keySet()) {
                fieldNames += ',' + fieldName;
            }
            fieldNames = fieldNames.substring(1);
            String soql = 'Select ' + fieldNames + ' From Client_Assessment_Survey__c Where Account__c = \'' + myAccountId + '\' order by CreatedDate Desc limit 1';
        
            //Read CAS data
            myCas = Database.query(soql);
            
            //Pre Load Data from Last Survey
            currRec.Performance_and_Organisation__c = myCas.Performance_and_Organisation__c;
            currRec.Talent_and_Engagement_Consulting__c = myCas.Talent_and_Engagement_Consulting__c;
            currRec.Engagement_Surveys__c = myCas.Engagement_Surveys__c;
            currRec.Best_Employers__c = myCas.Best_Employers__c;
            currRec.Leadership_Consulting__c = myCas.Leadership_Consulting__c;
            currRec.Selection_and_Assessment__c = myCas.Selection_and_Assessment__c;
            currRec.HRE__c = myCas.HRE__c;
            currRec.Sales_Force_Effectiveness__c = myCas.Sales_Force_Effectiveness__c;
            currRec.Broad_Based_Compensation__c = myCas.Broad_Based_Compensation__c;
            currRec.Productivity_and_Performance_Measurement__c = myCas.Productivity_and_Performance_Measurement__c;
            currRec.Executive_Compensation__c = myCas.Executive_Compensation__c;
            currRec.Total_Rewards__c = myCas.Total_Rewards__c;
            currRec.Job_Evaluation__c = myCas.Job_Evaluation__c;
            currRec.Sales_Compensation__c = myCas.Sales_Compensation__c;
            currRec.Pay_Strategy_Pay_Design__c = myCas.Pay_Strategy_Pay_Design__c;
            currRec.Remuneration_Review__c = myCas.Remuneration_Review__c;
            currRec.Actuarial_Services__c = myCas.Actuarial_Services__c;
            currRec.Retirement_Plan_Consulting__c = myCas.Retirement_Plan_Consulting__c;
            currRec.Retirement_Plan_Administration__c = myCas.Retirement_Plan_Administration__c;
            currRec.Accounting_Services__c = myCas.Accounting_Services__c;
            currRec.Financial_Planning__c = myCas.Financial_Planning__c;
            currRec.Investment_Consulting__c = myCas.Investment_Consulting__c;
            currRec.Group_Insurance__c = myCas.Group_Insurance__c;
            currRec.Corporate_Health__c = myCas.Corporate_Health__c;
            currRec.Personal_Accident__c = myCas.Personal_Accident__c;
            currRec.Corporate_Travel__c = myCas.Corporate_Travel__c;
            currRec.Expat_or_Non_Resident_Medical__c = myCas.Expat_or_Non_Resident_Medical__c;
            currRec.Life_Disability_Consulting__c = myCas.Life_Disability_Consulting__c;
            currRec.Mergers_Acquisitions__c = myCas.Mergers_Acquisitions__c;
            currRec.Global_Benefits_Brokerage__c = myCas.Global_Benefits_Brokerage__c;
            currRec.Workers_Compensation__c = myCas.Workers_Compensation__c;
            currRec.Workforce_Risk__c = myCas.Workforce_Risk__c;
            currRec.Workday_Implementation_Services__c = myCas.Workday_Implementation_Services__c;
            currRec.Cornerstone_OnDemand_Services__c = myCas.Cornerstone_OnDemand_Services__c;
            //currRec.Overall_Relationship_Status__c = myCas.Overall_Relationship_Status__c; // Removed for case 135733
            currRec.Consulting_Relationship_Status__c = myCas.Consulting_Relationship_Status__c;
            currRec.Outsourcing_Relationship_Status__c = myCas.Outsourcing_Relationship_Status__c;
            currRec.ARS_Relationship__c = myCas.ARS_Relationship__c;
            currRec.Risks__c = myCas.Risks__c;
            currRec.Opportunities__c = myCas.Opportunities__c;
            
        }
    } 
}