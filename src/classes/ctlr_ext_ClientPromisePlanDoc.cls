//Implemented for Case 48061. Chintan Adhyapak. December 20, 2012
public with sharing class ctlr_ext_ClientPromisePlanDoc {
    //Object to hold external contact data
    private class MyContact {
        public String Name              {get; set;}
        public String Role              {get; set;}
        public String JobLevel          {get; set;}
        public Decimal OverallScore     {get; set;}
        public Decimal EngageScore      {get; set;}
        public String Year              {get; set;}
        public Date SurveyDate          {get; set;}
        public String FunctionalRole    {get; set;}
        public String Title             {get; set;}
    } //MyContact
    
    //Object to hold Tasks and Events both. Case 125704. Chintan Adhyapak, July 23, 2014
    private class Activity {
        public String Type          {get; set;}
        public String Owner         {get; set;}
        public String Subject       {get; set;}
        public Date ActivityDate    {get; set;}
    } //Activity
    
    //Wrapper class implements Comparable interface to allow for sorting of a list of Activity objects for Case 177354. Chintan, Nov 10, 2014
    public class ActivityWrapper implements Comparable {
    	public Activity myActivity {get; set;}
    	
    	//constructor
    	public ActivityWrapper(Activity activity) {
    		myActivity = activity;
    	}
    	
    	public Integer compareTo(Object compareTo) {
        	ActivityWrapper compareToActivity = (ActivityWrapper) compareTo;
        	if (myActivity.ActivityDate == compareToActivity.myActivity.ActivityDate) return 0;
        	if (myActivity.ActivityDate > compareToActivity.myActivity.ActivityDate) return 1;
        	return -1;        
    	}
    } //ActivityWrapper
	
    //local vars
    public Annual_Account_Plan__c plan                          {get; set;}
    public Account account                                      {get; set;}
    public String pre65                                         {get; set;}
    public String post65                                        {get; set;}
    public List<String> keyBusinessStrategies                   {get; set;}
    public List<String> keyHRGoals                              {get; set;}
    public List<String> keyPensionFundStrategies                {get; set;}
    public Consulting_Service_Provider__c consultingSP          {get; set;}
    public Core_Service_Providers__c outsourcingSP              {get; set;}
    public Point_Solution_Providers__c pointSolutionsSP         {get; set;}
    public List<Internal_Account_Team__c> internalContactList   {get; set;}
    public List<Task> xsaleList                                 {get; set;}
    public Client_Satisfaction_Data__c csat                     {get; set;}
    public integer csatSize                                     {get; set;}
    public String cpri                                          {get; set;}
    public HRO_Renewal__c renewal                               {get; set;}
    public integer hroSize                                      {get; set;}
    public Revenue_Sales_Pipeline__c rsp                        {get; set;}
    public integer rspListSize                                  {get; set;}
    public String asOfDate                                      {get; set;}
    public String financialYear                                 {get; set;}
    public String quarter                                       {get; set;}
    public integer prevYear                                     {get; set;}
    public integer prevPrevYear                                 {get; set;}
    public List<Opportunity> winList                            {get; set;}
    public List<Opportunity> openList                           {get; set;}
    public List<MyContact> contactList                          {get; set;}
    public List<MyContact> alignedExecList                      {get; set;}
    public integer contactListSize                              {get; set;}
    public String region                                        {get; set;}
    public String currentDate                                   {get; set;}
    public List<Note> noteList                                  {get; set;}
    public List<Attachment> attachmentList                      {get; set;}
    public Map<String, String> cssMap                           {get; set;}
    public String currYear                                      {get; set;}
    public String lastYear                                      {get; set;}
    public integer currYearCssSize                              {get; set;}
    public integer lastYearCssSize                              {get; set;}
    public List<Account_Segmentation__c> segmentList            {get; set;}
    public List<ActivityWrapper> activityList                   {get; set;}
    
    /** constructor */
    public ctlr_ext_ClientPromisePlanDoc(ApexPages.StandardController controller) {
        plan = (Annual_Account_Plan__c)controller.getRecord();
        //read all fieldNames for Annual_Account_Plan__c object
        Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Annual_Account_Plan__c.fields.getMap();
        
        //00135435-Declaring Variables
        List<CP_Roles__c> roleList;
        Set<String> roleNameSet;
        
        //Create a SOQL string with all fields
        String fieldNames = '';
        for(String fieldName : schemaFieldMap.keySet()) {
            fieldNames += ',' + fieldName;
        }
        fieldNames = fieldNames.substring(1);
        String soql = 'Select ' + fieldNames + ' From Annual_Account_Plan__c Where Id = \'' + plan.Id + '\'';
        
        //Read Plan data
        plan = Database.query(soql);
        plan.Partnership__c = plan.Partnership__c != null ? plan.Partnership__c.replaceAll('\n', '<br>') : '';
        plan.Innovation__c = plan.Innovation__c != null ? plan.Innovation__c.replaceAll('\n', '<br>') : '';
        plan.Talent__c = plan.Talent__c != null ? plan.Talent__c.replaceAll('\n', '<br>') : '';
        plan.Excellence__c = plan.Excellence__c != null ? plan.Excellence__c.replaceAll('\n', '<br>') : '';
        plan.Results__c = plan.Results__c != null ? plan.Results__c.replaceAll('\n', '<br>') : '';
        plan.Recent_News_Worthy_Events__c = plan.Recent_News_Worthy_Events__c != null ? plan.Recent_News_Worthy_Events__c.replaceAll('\n', '<br>') : '';
        plan.Situation__c = plan.Situation__c != null ? plan.Situation__c.replaceAll('\n', '<br>') : '';
        plan.Opportunities__c = plan.Opportunities__c != null ? plan.Opportunities__c.replaceAll('\n', '<br>') : '';
        plan.Barriers__c = plan.Barriers__c != null ? plan.Barriers__c.replaceAll('\n', '<br>') : '';
        plan.Solutions__c = plan.Solutions__c != null ? plan.Solutions__c.replaceAll('\n', '<br>') : '';
        plan.MCA_ASA_MSA_Contract_Comments__c = plan.MCA_ASA_MSA_Contract_Comments__c != null ? plan.MCA_ASA_MSA_Contract_Comments__c.replaceAll('\n', '<br>') : '';
        plan.Special_Pricing_Arrangements__c = plan.Special_Pricing_Arrangements__c != null ? plan.Special_Pricing_Arrangements__c.replaceAll('\n', '<br>') : '';
        plan.Balance_of_Trade_Considerations__c = plan.Balance_of_Trade_Considerations__c != null ? plan.Balance_of_Trade_Considerations__c.replaceAll('\n', '<br>') : '';
        plan.Other_Relationships__c = plan.Other_Relationships__c != null ? plan.Other_Relationships__c.replaceAll('\n', '<br>') : '';
        plan.Existing_Aon_Contact__c = plan.Existing_Aon_Contact__c != null ? plan.Existing_Aon_Contact__c.replaceAll('\n', '<br>') : '';
        plan.Existing_ARR_Revenue__c = plan.Existing_ARR_Revenue__c != null ? plan.Existing_ARR_Revenue__c.replaceAll('\n', '<br>') : '';
        plan.Existing_Business__c = plan.Existing_Business__c != null ? plan.Existing_Business__c.replaceAll('\n', '<br>') : '';
        plan.Existing_Client_Contact__c = plan.Existing_Client_Contact__c != null ? plan.Existing_Client_Contact__c.replaceAll('\n', '<br>') : '';
        plan.Existing_Practices__c = plan.Existing_Practices__c != null ? plan.Existing_Practices__c.replaceAll('\n', '<br>') : '';
        plan.Existing_Renewal_Date_Comments__c = plan.Existing_Renewal_Date_Comments__c != null ? plan.Existing_Renewal_Date_Comments__c.replaceAll('\n', '<br>') : '';
        plan.Opportunities_Aon_Contact__c = plan.Opportunities_Aon_Contact__c != null ? plan.Opportunities_Aon_Contact__c.replaceAll('\n', '<br>') : '';
        plan.Opportunities_ARR_Revenue__c = plan.Opportunities_ARR_Revenue__c != null ? plan.Opportunities_ARR_Revenue__c.replaceAll('\n', '<br>') : '';
        plan.Opportunities_Business__c = plan.Opportunities_Business__c != null ? plan.Opportunities_Business__c.replaceAll('\n', '<br>') : '';
        plan.Opportunities_Client_Contact__c = plan.Opportunities_Client_Contact__c != null ? plan.Opportunities_Client_Contact__c.replaceAll('\n', '<br>') : '';
        plan.Opportunities_Practices__c = plan.Opportunities_Practices__c != null ? plan.Opportunities_Practices__c.replaceAll('\n', '<br>') : '';
        plan.Opportunities_Renewal_Date_Comments__c = plan.Opportunities_Renewal_Date_Comments__c != null ? plan.Opportunities_Renewal_Date_Comments__c.replaceAll('\n', '<br>') : '';
        plan.Retain__c = plan.Retain__c != null ? plan.Retain__c.replaceAll('\n', '<br>') : '';
        plan.Retain_Comments__c = plan.Retain_Comments__c != null ? plan.Retain_Comments__c.replaceAll('\n', '<br>') : '';
        plan.Expand__c = plan.Expand__c != null ? plan.Expand__c.replaceAll('\n', '<br>') : '';
        plan.Expand_Comments__c = plan.Expand_Comments__c != null ? plan.Expand_Comments__c.replaceAll('\n', '<br>') : '';
        plan.Relationship__c = plan.Relationship__c != null ? plan.Relationship__c.replaceAll('\n', '<br>') : '';
        

        //Read all fields on Account object
        schemaFieldMap = Schema.SObjectType.Account.fields.getMap();
        
        //Create a SOQL string with all fields
        fieldNames = '';
        for(String fieldName : schemaFieldMap.keySet()) {
            fieldNames += ',' + fieldName;
        }
        fieldNames += ',Owner.Name';
        fieldNames = fieldNames.substring(1);
        soql = 'Select ' + fieldNames + ' From Account Where Id = \'' + plan.Account__c + '\'';
        
        //Read Account data
        account = Database.query(soql);
        
        //Global Region
        region = account.Global_Region__c;
        Datetime dt = Datetime.now();
        if (region == 'Asia Pacific') {
            currentDate = dt.format('dd-MMM-yyyy');
        } else {
            currentDate = dt.format('MMMM dd, yyyy');
        }
        
        //populate pre65 and post65
        pre65 = '';
        post65 = '';
        if (account.HW_Ret_Pre_65_PPT_Count__c != null && account.HW_Ret_Pre_65_PPT_Count__c > 0) {
            pre65 = account.HW_Ret_Subsidized_Pre_65__c == 'Yes' ? 'Subsidized' : 'Unsubsidized';
        }
        if (account.HW_Ret_Post_65_PPT_Count__c != null && account.HW_Ret_Post_65_PPT_Count__c > 0) {
            post65 = account.HW_Ret_Subsidized_Post_65__c == 'Yes' ? 'Subsidized' : 'Unsubsidized';
        }

        //populate Key Business Strategies
        String comments = '';
        this.keyBusinessStrategies = new List<string> ();
        if (plan.Mergers_Acquisitions__c) {
            comments = plan.Comments_Mergers_Acquisitions__c != null ? '<br>' + plan.Comments_Mergers_Acquisitions__c.replaceAll('\n', '<br>') : '';
            keyBusinessStrategies.add('<b>Mergers/Acquisitions</b>' + comments );
        }
        if (plan.Organic_Growth__c) {
            comments = plan.Comments_Organic_Growth__c != null ? '<br>' + plan.Comments_Organic_Growth__c.replaceAll('\n', '<br>') : '';
            keyBusinessStrategies.add('<b>Organic Growth</b>' + comments);
        }
        if (plan.Operational_Improvement__c) {
            comments = plan.Comments_Operational_Improvement__c != null ? '<br>' + plan.Comments_Operational_Improvement__c.replaceAll('\n', '<br>') : '';
            keyBusinessStrategies.add('<b>Operational Improvement</b>' + comments);
        }
        if (plan.Improved_Productivity__c) {
            comments = plan.Comments_Improved_Productivity__c != null ? '<br>' + plan.Comments_Improved_Productivity__c.replaceAll('\n', '<br>') : '';
            keyBusinessStrategies.add('<b>Improved Productivity</b>' + comments);
        }
        if (plan.Cost_Management__c) {
            comments = plan.Comments_Cost_Management__c != null ? '<br>' + plan.Comments_Cost_Management__c.replaceAll('\n', '<br>') : '';
            keyBusinessStrategies.add('<b>Cost Management</b>' + comments);
        }
        if (plan.Customer_Retention_and_Growth__c) {
            comments = plan.Comments_Customer_Retention_and_Growth__c != null ? '<br>' + plan.Comments_Customer_Retention_and_Growth__c.replaceAll('\n', '<br>') : '';
            keyBusinessStrategies.add('<b>Customer Retention and Growth</b>' + comments);
        }
        if (plan.Sales_Effectiveness__c) {
            comments = plan.Comments_Sales_Effectiveness__c != null ? '<br>' + plan.Comments_Sales_Effectiveness__c.replaceAll('\n', '<br>') : '';
            keyBusinessStrategies.add('<b>Sales Effectiveness</b>' + comments);
        }
        if (plan.Global_Expansion__c) {
            comments = plan.Comments_Global_Expansion__c != null ? '<br>' + plan.Comments_Global_Expansion__c.replaceAll('\n', '<br>') : '';
            keyBusinessStrategies.add('<b>Global Expansion</b>' + comments);
        }
        if (plan.Reduce_Exposure_Financial_Inflation__c) {
            comments = plan.Comments_Reduce_Exposure__c != null ? '<br>' + plan.Comments_Reduce_Exposure__c.replaceAll('\n', '<br>') : '';
            keyBusinessStrategies.add('<b>Reduce Exposure to Financial Or Inflation Risks</b>' + comments);
        }
        if (plan.Corporate_Social_Responsibility__c) {
            comments = plan.Comments_Corporate_Social_Responsibility__c != null ? '<br>' + plan.Comments_Corporate_Social_Responsibility__c.replaceAll('\n', '<br>') : '';
            keyBusinessStrategies.add('<b>Corporate Social Responsibility</b>' + comments);
        }
        if (plan.Emerging_Workforce__c) {
            comments = plan.Comments_Emerging_Workforce__c != null ? '<br>' + plan.Comments_Emerging_Workforce__c.replaceAll('\n', '<br>') : '';
            keyBusinessStrategies.add('<b>Emerging Workforce</b>' + comments);
        }
        
        //populate Key HR Goals
        this.keyHRGoals = new List<String> ();
        if (plan.Improve_Engagement__c) {
            comments = plan.Comments_Improve_Engagement__c != null ? '<br>' + plan.Comments_Improve_Engagement__c.replaceAll('\n', '<br>') : '';
            keyHRGoals.add('<b>Improve Engagement</b>' + comments);
        }
        if (plan.Total_Rewards_Strategy__c) {
            comments = plan.Comments_Total_Rewards_Strategy__c != null ? '<br>' + plan.Comments_Total_Rewards_Strategy__c.replaceAll('\n', '<br>') : '';
            keyHRGoals.add('<b>Total Rewards Strategy</b>' + comments);
        }
        if (plan.Reduce_Health_Care_Costs__c) {
            comments = plan.Comments_Reduce_Health_Care_Costs__c != null ? '<br>' + plan.Comments_Reduce_Health_Care_Costs__c.replaceAll('\n', '<br>') : '';
            keyHRGoals.add('<b>Reduce Healthcare Costs</b>' + comments);
        }
        if (plan.Retention__c) {
            comments = plan.Comments_Retention__c != null ? '<br>' + plan.Comments_Retention__c.replaceAll('\n', '<br>') : '';
            keyHRGoals.add('<b>Retention</b>' + comments);
        }
        if (plan.Workforce_Reduction__c) {
            comments = plan.Comments_Workforce_Reduction__c != null ? '<br>' + plan.Comments_Workforce_Reduction__c.replaceAll('\n', '<br>') : '';
            keyHRGoals.add('<b>Workforce Reduction</b>' + comments);
        }
        if (plan.Talent_Development__c) {
            comments = plan.Comments_Talent_Development__c != null ? '<br>' + plan.Comments_Talent_Development__c.replaceAll('\n', '<br>') : '';
            keyHRGoals.add('<b>Talent Development</b>' + comments);
        }
        if (plan.Develop_EE_Value_Proposition__c) {
            comments = plan.Comments_Develop_EE_Value_Proposition__c != null ? '<br>' + plan.Comments_Develop_EE_Value_Proposition__c.replaceAll('\n', '<br>') : '';
            keyHRGoals.add('<b>Develop EE Value Proposition</b>' + comments);
        }
        if (plan.HR_Effectiveness__c) {
            comments = plan.Comments_HR_Effectiveness__c != null ? '<br>' + plan.Comments_HR_Effectiveness__c.replaceAll('\n', '<br>') : '';
            keyHRGoals.add('<b>HR Effectiveness</b>' + comments);
        }
        if (plan.Organization_Effectiveness__c) {
            comments = plan.Comments_Organization_Effectiveness__c != null ? '<br>' + plan.Comments_Organization_Effectiveness__c.replaceAll('\n', '<br>') : '';
            keyHRGoals.add('<b>Organizational Effectiveness</b>' + comments);
        }
        if (plan.Improve_Retirement_Readiness__c) {
            comments = plan.Comments_Improve_Retirement_Readiness__c != null ? '<br>' + plan.Comments_Improve_Retirement_Readiness__c.replaceAll('\n', '<br>') : '';
            keyHRGoals.add('<b>Improve Retirement Readiness</b>' + comments);
        }
        if (plan.Manage_Pension_Risk__c) {
            comments = plan.Comments_Manage_Pension_Risk__c != null ? '<br>' + plan.Comments_Manage_Pension_Risk__c.replaceAll('\n', '<br>') : '';
            keyHRGoals.add('<b>Manage Pension Risk</b>' + comments);
        }
        if (plan.Salesforce_Effectiveness__c) {
            comments = plan.Comments_Salesforce_Effectiveness__c != null ? '<br>' + plan.Comments_Salesforce_Effectiveness__c.replaceAll('\n', '<br>') : '';
            keyHRGoals.add('<b>Salesforce Effectiveness</b>' + comments);
        }
        if (plan.Incentive_Plan_Effectiveness__c) {
            comments = plan.Comments_Incentive_Plan_Effectiveness__c != null ? '<br>' + plan.Comments_Incentive_Plan_Effectiveness__c.replaceAll('\n', '<br>') : '';
            keyHRGoals.add('<b>Incentive Plan Effectiveness</b>' + comments);
        }
        if (plan.Outsourcing__c) {
            comments = plan.Comments_Outsourcing__c != null ? '<br>' + plan.Comments_Outsourcing__c.replaceAll('\n', '<br>') : '';
            keyHRGoals.add('<b>Outsourcing</b>' + comments);
        }
        if (plan.Improve_Wellness_and_Safety__c) {
            comments = plan.Comments_Improve_Wellness_and_Safety__c != null ? '<br>' + plan.Comments_Improve_Wellness_and_Safety__c.replaceAll('\n', '<br>') : '';
            keyHRGoals.add('<b>Improve Wellness and Safety</b>' + comments);
        }
        if (plan.Improve_Benchmarking__c) {
            comments = plan.Comments_Improve_Benchmarking__c != null ? '<br>' + plan.Comments_Improve_Benchmarking__c.replaceAll('\n', '<br>') : '';
            keyHRGoals.add('<b>Improve Benchmarking</b>' + comments);
        }
        if (plan.Manage_People_Risks__c) {
            comments = plan.Comments_Manage_People_Risks__c != null ? '<br>' + plan.Comments_Manage_People_Risks__c.replaceAll('\n', '<br>') : '';
            keyHRGoals.add('<b>Manage People Risks</b>' + comments);
        }
        
        //Populate Key Pension Fund Strategies
        this.keyPensionFundStrategies = new List<String> ();
        if (plan.External_Cost_Control__c) {
            comments = plan.Comments_External_Cost_Control__c != null ? '<br>' + plan.Comments_External_Cost_Control__c.replaceAll('\n', '<br>') : '';
            keyPensionFundStrategies.add('<b>External Cost Control</b>' + comments);
        }
        if (plan.Shortage_of_Pension_Focused_Resource__c) {
            comments = plan.Comments_Shortage_of_Pension_Focused_Res__c != null ? '<br>' + plan.Comments_Shortage_of_Pension_Focused_Res__c.replaceAll('\n', '<br>') : '';
            keyPensionFundStrategies.add('<b>Shortage of Pension Focused Resource</b>' + comments);
        }
        if (plan.De_Risking__c) {
            comments = plan.Comments_De_Risking__c != null ? '<br>' + plan.Comments_De_Risking__c.replaceAll('\n', '<br>') : '';
            keyPensionFundStrategies.add('<b>De-Risking</b>' + comments);
        }
        if (plan.Diversification__c) {
            comments = plan.Comments_Diversification__c != null ? '<br>' + plan.Comments_Diversification__c.replaceAll('\n', '<br>') : '';
            keyPensionFundStrategies.add('<b>Diversification</b>' + comments);
        }
        if (plan.Dynamism__c) {
            comments = plan.Comments_Dynamism__c != null ? '<br>' + plan.Comments_Dynamism__c.replaceAll('\n', '<br>') : '';
            keyPensionFundStrategies.add('<b>Dynamism</b>' + comments);
        }
        if (plan.Enhance_Transfer_Values__c) {
            comments = plan.Comments_Enhance_Transfer_Values__c != null ? '<br>' + plan.Comments_Enhance_Transfer_Values__c.replaceAll('\n', '<br>') : '';
            keyPensionFundStrategies.add('<b>Enhance Transfer Values</b>' + comments);
        }
        if (plan.Pension_Increse_Exercises__c) {
            comments = plan.Comments_Pension_Increse_Exercises__c != null ? '<br>' + plan.Comments_Pension_Increse_Exercises__c.replaceAll('\n', '<br>') : '';
            keyPensionFundStrategies.add('<b>Pension Increase Exercises</b>' + comments);
        }
        if (plan.Trivial_Commutation_Exercises__c) {
            comments = plan.Comments_Trivial_Commutation_Exercises__c != null ? '<br>' + plan.Comments_Trivial_Commutation_Exercises__c.replaceAll('\n', '<br>') : '';
            keyPensionFundStrategies.add('<b>Trivial Commutation Exercises</b>' + comments);
        }
        if (plan.Scheme_Open_to_New_Members_and_Accrual__c) {
            comments = plan.Comments_Scheme_Open_to_New_Members_and__c != null ? '<br>' + plan.Comments_Scheme_Open_to_New_Members_and__c.replaceAll('\n', '<br>') : '';
            keyPensionFundStrategies.add('<b>Scheme Open to New Members and Accrual</b>' + comments);
        }
        if (plan.Scheme_Closed_to_New_Members_but_with_Be__c) {
            comments = plan.Comments_Scheme_Closed_Benefit_Accrual__c != null ? '<br>' + plan.Comments_Scheme_Closed_Benefit_Accrual__c.replaceAll('\n', '<br>') : '';
            keyPensionFundStrategies.add('<b>Scheme Closed to New Members but with Benefit Accrual</b>' + comments);
        }
        if (plan.Scheme_Closed_to_New_members_and_No_Accr__c) {
            comments = plan.Comments_Scheme_Closed_to_New_members_an__c != null ? '<br>' + plan.Comments_Scheme_Closed_to_New_members_an__c.replaceAll('\n', '<br>') : '';
            keyPensionFundStrategies.add('<b>Scheme Closed to new Members and No Accrual</b>' + comments);
        }
        if (plan.Buy_Outs__c) {
            comments = plan.Comments_Buy_Outs__c != null ? '<br>' + plan.Comments_Buy_Outs__c.replaceAll('\n', '<br>') : '';
            keyPensionFundStrategies.add('<b>Buy-outs</b>' + comments);
        }
        if (plan.Buy_Ins__c) {
            comments = plan.Comments_Buy_Ins__c != null ? '<br>' + plan.Comments_Buy_Ins__c.replaceAll('\n', '<br>') : '';
            keyPensionFundStrategies.add('<b>Buy-ins</b>' + comments);
        }
        if (plan.Longevity_Hedging__c) {
            comments = plan.Comments_Longevity_Hedging__c != null ? '<br>' + plan.Comments_Longevity_Hedging__c.replaceAll('\n', '<br>') : '';
            keyPensionFundStrategies.add('<b>Longevity Hedging</b>' + comments);
        }
        if (plan.Delegated_Investment__c) {
            comments = plan.Comments_Delegated_Investment__c != null ? '<br>' + plan.Comments_Delegated_Investment__c.replaceAll('\n', '<br>') : '';
            keyPensionFundStrategies.add('<b>Delegated Investment</b>' + comments);
        }
        if (plan.Data_Issues__c) {
            comments = plan.Comments_Data_Issues__c != null ? '<br>' + plan.Comments_Data_Issues__c.replaceAll('\n', '<br>') : '';
            keyPensionFundStrategies.add('<b>Data Issues</b>' + comments);
        }
        if (plan.Investment_to_Reduce_Future_Admin_Risks__c) {
            comments = plan.Comments_Investment_to_Reduce_Future_Adm__c != null ? '<br>' + plan.Comments_Investment_to_Reduce_Future_Adm__c.replaceAll('\n', '<br>') : '';
            keyPensionFundStrategies.add('<b>Investments to Reduce Future Admin Risks</b>' + comments);
        }
        if (plan.Conflicts_of_Interests__c) {
            comments = plan.Comments_Conflicts_of_Interests__c != null ? '<br>' + plan.Comments_Conflicts_of_Interests__c.replaceAll('\n', '<br>') : '';
            keyPensionFundStrategies.add('<b>Conflicts of Interests</b>' + comments);
        }
        if (plan.Auto_Enrolment__c) {
            comments = plan.Comments_Auto_Enrolment__c != null ? '<br>' + plan.Comments_Auto_Enrolment__c.replaceAll('\n', '<br>') : '';
            keyPensionFundStrategies.add('<b>Auto Enrolment</b>' + comments);
        }
        if (plan.Concentration_of_Knowledge__c) {
            comments = plan.Comments_Concentration_of_Knowledge__c != null ? '<br>' + plan.Comments_Concentration_of_Knowledge__c.replaceAll('\n', '<br>') : '';
            keyPensionFundStrategies.add('<b>Concentration of Knowledge</b>' + comments);
        }
        if (plan.Member_Nominated_Trustees__c) {
            comments = plan.Comments_Member_Nominated_Trustees__c != null ? '<br>' + plan.Comments_Member_Nominated_Trustees__c.replaceAll('\n', '<br>') : '';
            keyPensionFundStrategies.add('<b>Member Nominated Trustees</b>' + comments);
        }
        if (plan.Sponsor_Covenant__c) {
            comments = plan.Comments_Sponsor_Covenant__c != null ? '<br>' + plan.Comments_Sponsor_Covenant__c.replaceAll('\n', '<br>') : '';
            keyPensionFundStrategies.add('<b>Sponsor Covenant</b>' + comments);
        }
        
        //Read Consulting Service Provider Data
        consultingSP = [Select Actuary_Pension_Company__r.Name,Health_Welfare_Consulting__r.Name,Communication_Consulting__r.Name,Executive_Compensation_Mgmt_Consultant__r.Name,
            Global_Benefits_Consulting_Broker__r.Name,HR_M_A_Consulting__r.Name,Retirement_Consultant__r.Name,Broadbased_Compensation_Consultant__r.Name,
            Actuary_Pension_Contract_End_Date__c,Reward__r.Name,FLEX_Benefits__r.Name, Investment__r.Name, Investment_Consultant__r.Name,
            Covenant_Assessment_Advisors__r.Name, Covenant_Assess_Advisors_Contract_End_Dt__c, Retirement_Consultant_DC__r.Name,Global_Actuary__r.Name,
            Global_Accounting__r.Name, International_Retirement_Consulting__r.Name from Consulting_Service_Provider__c
            Where Account__c = :plan.Account__c Limit 1];

        //Read Outsourcing Service Provider Data
        schemaFieldMap = Schema.SObjectType.Core_Service_Providers__c.fields.getMap();
        
        //Create a SOQL string with all fields
        fieldNames = '';
        for(String fieldName : schemaFieldMap.keySet()) {
            fieldNames += ',' + fieldName;
        }
        fieldNames += ',Defined_Benefit_Administrator__r.Name,Defined_Contribution_Administrator__r.Name,Health_Welfare_Administrator__r.Name,';
        fieldNames += 'BPO_HR__r.Name,Payroll__r.Name,Pension_Payroll__r.Name,Recruiting_and_Staffing_Administrator__r.Name,';
        fieldNames += 'Retiree_Medical_Exchange__r.Name,Bundled_Services__r.Name,Flex_Administration__r.Name';
        fieldNames = fieldNames.substring(1);
        soql = 'Select ' + fieldNames + ' From Core_Service_Providers__c Where Account__c = \'' + plan.Account__c + '\' Limit 1';
        
        //Query
        outsourcingSP = Database.query(soql);
        
        //Read Point Solutions Provider Data
        schemaFieldMap = Schema.SObjectType.Point_Solution_Providers__c.fields.getMap();
        
        //Create a SOQL string with all fields
        fieldNames = '';
        for(String fieldName : schemaFieldMap.keySet()) {
            fieldNames += ',' + fieldName;
        }
        fieldNames += ',Advocacy_Services__r.Name,Dependent_Audit_Services__r.Name,Spending_Accounts_FSA__r.Name,Total_Rewards_Solution__r.Name';
        fieldNames = fieldNames.substring(1);
        soql = 'Select ' + fieldNames + ' From Point_Solution_Providers__c Where Account__c = \'' + plan.Account__c + '\' Limit 1';
        
        //Query
        pointSolutionsSP = Database.query(soql);
        
        //Read Internal Contact Team - All Roles for APAC. Case 125704. Chintan, July 22, 2014
        internalContactList = new List<Internal_Account_Team__c> ();
        roleList = [Select Role__c from CP_Roles__c where Region__c=:region and Role_Type__c='Internal'];
        if (roleList.size() == 0) {//All Roles
            internalContactList = [SELECT Contact_Role__c, Contact__r.Name FROM Internal_Account_Team__c WHERE account__r.Id = :plan.Account__c 
                   Order By Contact_Role__c, Contact__r.Name];
        } else {
            roleNameSet = new Set<String>();
            for(CP_Roles__c role:roleList) {
                roleNameSet.add(role.Role__c);
            }
            internalContactList = [SELECT Contact_Role__c, Contact__r.Name FROM Internal_Account_Team__c WHERE account__r.Id = :plan.Account__c AND 
                Contact_Role__c IN:roleNameSet Order By Contact_Role__c, Contact__r.Name];
        }
        
        //Read Aligned Exec List
         List<Internal_Account_Team__c> execList = [SELECT Contact_Role__c, Contact__r.Name FROM Internal_Account_Team__c WHERE account__r.Id = :plan.Account__c AND 
            Contact_Role__c IN ('Account Owner', 'Executive Sponsor','Global Account Executive','Client Lead ARS','Client Lead Aon Benfield')];
         //Sort
         alignedExecList = new List<MyContact> ();
         for (Internal_Account_Team__c iat : execList) {
            if (iat.Contact_Role__c == 'Account Owner') {
                MyContact myContact = new MyContact();
                myContact.Name = iat.Contact__r.Name;
                myContact.Role = region == 'Asia Pacific' ? 'Account Manager' : 'Account Executive';
                alignedExecList.add(myContact);
            }
         }
         for (Internal_Account_Team__c iat : execList) {
            if (iat.Contact_Role__c == 'Executive Sponsor') {
                MyContact myContact = new MyContact();
                myContact.Name = iat.Contact__r.Name;
                myContact.Role = 'Executive Sponsor';
                alignedExecList.add(myContact);
            }
         }
         for (Internal_Account_Team__c iat : execList) {
            if (iat.Contact_Role__c == 'Global Account Executive') {
                MyContact myContact = new MyContact();
                myContact.Name = iat.Contact__r.Name;
                myContact.Role = 'Global Account Executive';
                alignedExecList.add(myContact);
            }
         }
         for (Internal_Account_Team__c iat : execList) {
            if (iat.Contact_Role__c == 'Client Lead ARS') {
                MyContact myContact = new MyContact();
                myContact.Name = iat.Contact__r.Name;
                myContact.Role = 'Client Lead ARS';
                alignedExecList.add(myContact);
            }
         }
         for (Internal_Account_Team__c iat : execList) {
            if (iat.Contact_Role__c == 'Client Lead Aon Benfield') {
                MyContact myContact = new MyContact();
                myContact.Name = iat.Contact__r.Name;
                myContact.Role = 'Client Lead Aon Benfield';
                alignedExecList.add(myContact);
            }
         }

        //Read Events & Tasks
        //Last 2 years for APAC. Case 125704. Chintan, July 22, 2014
        if (region == 'Asia Pacific') {
            this.activityList = new List<ActivityWrapper> ();
            List<Event> allEvents = [Select Owner.Name, ActivityDate, Subject, Type From Event Where AccountId = :plan.Account__c And Owner.Name <> 'Eloqua Marketing' And (ActivityDate = LAST_N_DAYS:365 Or ActivityDate = NEXT_N_DAYS:365) Order By ActivityDate Desc];
            for (Event evt : allEvents) {
                if (evt.Type != 'Other' && !evt.Subject.startsWithIgnoreCase('Email')) {
                    Activity activity = new Activity();
                    activity.Type = evt.Type;
                    activity.Subject = evt.Subject;
                    activity.Owner = evt.Owner.Name;
                    activity.ActivityDate = evt.ActivityDate;
                    activityList.add(new ActivityWrapper(activity));
                }
            }
            List<Task> allTasks = [Select Owner.Name, ActivityDate, Subject, Type From Task Where AccountId = :plan.Account__c And Owner.Name <> 'Eloqua Marketing' And (ActivityDate = LAST_N_DAYS:365 Or ActivityDate = NEXT_N_DAYS:365) Order By ActivityDate Desc];
            for (Task task : allTasks) {
                if (task.Type != 'Cross Sale/Referral' && !task.Subject.startsWithIgnoreCase('Email')) {
                    Activity activity = new Activity();
                    activity.Type = task.Type;
                    activity.Subject = task.Subject;
                    activity.Owner = task.Owner.Name;
                    activity.ActivityDate = task.ActivityDate;
                    activityList.add(new ActivityWrapper(activity));
                }
            }
            
            //Sort List
        	if (!activityList.isEmpty()) {
        	activityList.sort();
        	}
        }

        //Read Cross Sale Tasks
        xsaleList = [Select Owner.Name, ActivityDate, Subject, Status From Task Where AccountId = :plan.Account__c And ActivityDate = THIS_YEAR And Type = 'Cross Sale/Referral' Order By ActivityDate Desc];
        
        //Read Client Satisfaction Data Record
        schemaFieldMap = Schema.SObjectType.Client_Satisfaction_Data__c.fields.getMap();
        
        //Create a SOQL string with all fields
        fieldNames = '';
        for(String fieldName : schemaFieldMap.keySet()) {
            fieldNames += ',' + fieldName;
        }
        fieldNames = fieldNames.substring(1);
        soql = 'Select ' + fieldNames + ' From Client_Satisfaction_Data__c Where Account__c = \'' + plan.Account__c + '\' Order By CreatedDate Desc';
        
        //Query
        List<Client_Satisfaction_Data__c> csatList = Database.query(soql);
        
        //Does a Client Sat Data record exist
        csatSize = csatList.size();
        
        //Assign Client Sat Record
        if (csatSize > 0) {
            csat = csatList[0];
        }
        
        //Get CPRI value
        List<HRO_Renewal__c> hroList = [Select CPRI_Total__c, Year__c, Quarter__c, Last_ECC_Date__c From HRO_Renewal__c Where Account__c = :plan.Account__c Order By CreatedDate Desc];
        
        //Does a Renewal record exist
        hroSize = hroList.size();
        
        //assign renewal record
        renewal = new HRO_Renewal__c();
        if (hroSize > 0) {
            renewal = hroList[0]; 
        }
        
        //Read Revenue Data
        schemaFieldMap = Schema.SObjectType.Revenue_Sales_Pipeline__c.fields.getMap();
        
        //Create a SOQL string with all fields
        fieldNames = '';
        for(String fieldName : schemaFieldMap.keySet()) {
            fieldNames += ',' + fieldName;
        }
        fieldNames = fieldNames.substring(1);
        soql = 'Select ' + fieldNames + ' From Revenue_Sales_Pipeline__c Where Account__c = \'' + plan.Account__c + '\' Order By CreatedDate Desc';
        
        //Query
        List<Revenue_Sales_Pipeline__c> rspList = Database.query(soql);
        
        //Does a Revenue record exist
        rspListSize = rspList.size();
        
        //Assign Revenue Record
        rsp = new Revenue_Sales_Pipeline__c();
        financialYear = '';
        quarter = '';
        prevYear = 0;
        prevPrevYear = 0;
        asOfDate = '';
        if (rspListSize > 0) {
            rsp = rspList[0];
            this.financialYear = rsp.Year__c != null ? rsp.Year__c : financialYear;
            this.quarter = rsp.Quarter__c != null ? rsp.Quarter__c : quarter;
            this.prevYear=integer.valueof(financialYear);
            prevYear = prevYear - 1;
            prevPrevYear = prevYear - 1;
        }
        
        //Pull Open Opps
        if (region == 'North America') {
            openList = [Select Name, StageName, Total_First_Year_Value__c, Probability, CloseDate, Current_Provider_Reference__r.Name, SalesTeamCredits__c, Owner.Name, Owner.Reporting_Practice__c, CurrencyIsoCode 
                From Opportunity 
                Where AccountId = :plan.Account__c And (IsClosed = False Or (StageName = 'Closed Won' And LOI_Contract_Date__c = null)) 
                Order By Total_First_Year_Value__c Desc];
        } else {
            openList = [Select Name, StageName, Total_First_Year_Value__c, Probability, CloseDate, Current_Provider_Reference__r.Name, SalesTeamCredits__c, Owner.Name, Owner.Reporting_Practice__c, CurrencyIsoCode 
                From Opportunity 
                Where AccountId = :plan.Account__c And (IsClosed = False) 
                Order By CloseDate Desc];
        }
                
        //Pull Closed Opps
        if (region == 'North America') {
            winList = [Select Name, Owner.Name, Owner.Reporting_Practice__c, CurrencyIsoCode, Opportunity_Closed_Date__c, StageName, Total_First_Year_Value__c, Chosen_Provider_Reference__r.Name, LOI_Contract_Date__c, SalesTeamCredits__c, Reason_Won_or_Lost__c 
                From Opportunity 
                Where AccountId = :account.Id And IsWon = True And LOI_Contract_Date__c = LAST_N_DAYS:365 Order By Total_First_Year_Value__c];
        } else {
            winList = [Select Name, Owner.Name, Owner.Reporting_Practice__c, CurrencyIsoCode, Opportunity_Closed_Date__c, StageName, Total_First_Year_Value__c, Chosen_Provider_Reference__r.Name, LOI_Contract_Date__c, SalesTeamCredits__c, Reason_Won_or_Lost__c 
                From Opportunity 
                Where AccountId = :account.Id And IsClosed = True And Opportunity_Closed_Date__c = LAST_N_DAYS:365 Order By Opportunity_Closed_Date__c Desc];
        }
        
        //Pull External Contacts
        List<Contact> allContacts = [Select Name, Functional_Role__c, Title, Job_Level__c, Key_Contact__c, (Select Overall_Satisfaction__c, Recommend_Aon_Hewitt_to_others__c,
                Survey_Year__c, Survey_Date__c From Client_Satisfaction_Surveys__r Order by CreatedDate Desc) 
                From Contact Where AccountId = :plan.Account__c And Contact_Status__c = 'Active' Order By Name];
        contactList = new List<MyContact> ();
        
        //Print all active contacts for APAC. Case 125704. Chintan, July 22, 2014
        roleList=[Select Role__c from CP_Roles__c where Region__c=:region and Role_Type__c='External'];
        if(roleList.size()>0) {
            roleNameSet = new Set<String>();
            for(CP_Roles__c role:roleList) {
                roleNameSet.add(role.Role__c);
            }
        }
        for (Contact contact : allContacts) {
            //Checking if all role needs to be printed or current contact role needs to be printed for this region
            if (roleList.size()==0 || roleNameSet.contains(contact.Functional_Role__c)) {
                MyContact myContact = new MyContact();
                myContact.Name = contact.Name;
                myContact.JobLevel = contact.Job_Level__c;
                myContact.FunctionalRole = contact.Functional_Role__c;
                myContact.Title = contact.Title;
                If ((contact.Client_Satisfaction_Surveys__r).size() > 0) {
                    myContact.OverallScore = contact.Client_Satisfaction_Surveys__r[0].Overall_Satisfaction__c;
                    myContact.EngageScore = contact.Client_Satisfaction_Surveys__r[0].Recommend_Aon_Hewitt_to_others__c;
                    myContact.Year = contact.Client_Satisfaction_Surveys__r[0].Survey_Year__c;
                    myContact.SurveyDate = contact.Client_Satisfaction_Surveys__r[0].Survey_Date__c;
                }
                contactList.add(myContact);
            }
        }
        contactListSize = contactList.size();
        
        //Read Notes
        noteList = [Select Body, Title, CreatedDate from Note Where ParentId = :plan.Id Order By CreatedDate Desc];
        for (Note note : noteList) {
            note.Body = note.Body != null ? note.Body.replaceAll('\n', '<br>') : '';
        }
        if (noteList.isEmpty()) {
            noteList = new List<Note> ();
        }
        
        //Read Attachments
        attachmentList = [Select Name, CreatedDate, CreatedBy.Name from Attachment Where ParentId = :plan.Id Order By CreatedDate Desc];
        attachmentList = attachmentList.isEmpty() ? new List<Attachment> () : attachmentList;
        System.debug('CPA attachmentList is: ' + attachmentList);
        
        //Get Client Satisfaction Survey data for this and previous year for APAC. Case 125704. Chintan, July 21, 2014
        cssMap = new Map<String, String> ();
        currYear = String.valueOf(System.today().year());
        lastYear = String.valueOf(System.today().year() - 1);
        List<Client_Satisfaction_Survey__c >currYearCss = [SELECT Recommend_Aon_Hewitt_to_others__c, Overall_Satisfaction__c, Partnership__c, Innovation__c, Talent__c, Excellence__c, Results__c FROM Client_Satisfaction_Survey__c 
            WHERE account__r.Id = :account.Id AND Survey_Year__c = :currYear Order By CreatedDate Desc];
        currYearCssSize = currYearCss.size();
        List<Client_Satisfaction_Survey__c >prevYearCss = [SELECT Recommend_Aon_Hewitt_to_others__c, Overall_Satisfaction__c, Partnership__c, Innovation__c, Talent__c, Excellence__c, Results__c FROM Client_Satisfaction_Survey__c 
            WHERE account__r.Id = :account.Id AND Survey_Year__c = :lastYear Order By CreatedDate Desc];
        lastYearCssSize = prevYearCss.size();
        
        if (currYearCss.size() > 0) {
            //Calculate avg score from all surveys for the year
            decimal avgScore = 0;
            decimal avgSat = 0;
            decimal avgPartnership = 0;
            decimal avgInnovation = 0;
            decimal avgTalent = 0;
            decimal avgExcellence = 0;
            decimal avgResult = 0;
            integer scoreCount = 0;
            integer satCount = 0;
            integer pCount = 0;
            integer iCount = 0;
            integer tCount = 0;
            integer eCount = 0;
            integer rCount = 0; 
            
            for (Client_Satisfaction_Survey__c css : currYearCss) {
                scoreCount = css.Recommend_Aon_Hewitt_to_others__c != null ? scoreCount + 1 : scoreCount;
                avgScore = css.Recommend_Aon_Hewitt_to_others__c != null ? avgScore + css.Recommend_Aon_Hewitt_to_others__c : avgScore;
                satCount = css.Overall_Satisfaction__c != null ? satCount + 1 : satCount;
                avgSat = css.Overall_Satisfaction__c !=null ? avgSat + css.Overall_Satisfaction__c : avgSat;
                pCount = css.Partnership__c != null ? pCount + 1 : pCount;
                avgPartnership =  css.Partnership__c != null ? avgPartnership + css.Partnership__c : avgPartnership;
                iCount = css.Innovation__c != null ? iCount + 1 : iCount;
                avgInnovation = css.Innovation__c != null ? avgInnovation + css.Innovation__c : avgInnovation;
                tCount = css.Talent__c != null ? tCount + 1 : tCount;
                avgTalent = css.Talent__c != null ? avgTalent + css.Talent__c : avgTalent;
                eCount = css.Excellence__c != null ? eCount + 1 : eCount;
                avgExcellence = css.Excellence__c != null ? avgExcellence + css.Excellence__c : avgExcellence;
                rCount = css.Results__c != null ? rCount + 1 : rCount;
                avgResult = css.Results__c != null ? avgResult + css.Results__c : avgResult;
            }
            
            //Divide and Set decimal
            avgScore = avgScore > 0 ? avgScore.divide(scoreCount, 1) : 0;
            avgSat = avgSat > 0 ? avgSat.divide(satCount, 1) : 0;
            avgPartnership = avgPartnership > 0 ? avgPartnership.divide(pCount, 1) : 0;
            avgInnovation = avgInnovation > 0 ? avgInnovation.divide(iCount, 1) : avgInnovation;
            avgTalent = avgTalent > 0 ? avgTalent.divide(tCount, 1) : 0;
            avgExcellence = avgExcellence > 0 ? avgExcellence.divide(eCount, 1) : avgExcellence;
            avgResult = avgResult > 0 ? avgResult.divide(rCount, 1) : avgResult;
            
            cssMap.put('CYlikelihood', String.valueOf(avgScore));
            cssMap.put('CYsatisfaction', String.valueOf(avgSat));
            cssMap.put('CYpartnership', String.valueOf(avgPartnership));
            cssMap.put('CYinnovation', String.valueOf(avgInnovation));
            cssMap.put('CYtalent', String.valueOf(avgTalent));
            cssMap.put('CYexcellence', String.valueOf(avgExcellence));
            cssMap.put('CYresults', String.valueOf(avgResult));
        } else {
            cssMap.put('CYlikelihood', 'N/A');
            cssMap.put('CYsatisfaction', 'N/A');
            cssMap.put('CYpartnership', 'N/A');
            cssMap.put('CYinnovation', 'N/A');
            cssMap.put('CYtalent', 'N/A');
            cssMap.put('CYexcellence', 'N/A');
            cssMap.put('CYresults', 'N/A');
        }
        
        if (prevYearCss.size() > 0) {
            //Calculate avg score from all surveys for the year
            decimal avgScore = 0;
            decimal avgSat = 0;
            decimal avgPartnership = 0;
            decimal avgInnovation = 0;
            decimal avgTalent = 0;
            decimal avgExcellence = 0;
            decimal avgResult = 0;
            integer scoreCount = 0;
            integer satCount = 0;
            integer pCount = 0;
            integer iCount = 0;
            integer tCount = 0;
            integer eCount = 0;
            integer rCount = 0;
            
            for (Client_Satisfaction_Survey__c css : prevYearCss) {
                System.debug('CPA Prev Year css is: ' + css);
                scoreCount = css.Recommend_Aon_Hewitt_to_others__c != null ? scoreCount + 1 : scoreCount;
                avgScore = css.Recommend_Aon_Hewitt_to_others__c != null ? avgScore + css.Recommend_Aon_Hewitt_to_others__c : avgScore;
                satCount = css.Overall_Satisfaction__c != null ? satCount + 1 : satCount;
                avgSat = css.Overall_Satisfaction__c !=null ? avgSat + css.Overall_Satisfaction__c : avgSat;
                pCount = css.Partnership__c != null ? pCount + 1 : pCount;
                avgPartnership =  css.Partnership__c != null ? avgPartnership + css.Partnership__c : avgPartnership;
                iCount = css.Innovation__c != null ? iCount + 1 : iCount;
                avgInnovation = css.Innovation__c != null ? avgInnovation + css.Innovation__c : avgInnovation;
                tCount = css.Talent__c != null ? tCount + 1 : tCount;
                avgTalent = css.Talent__c != null ? avgTalent + css.Talent__c : avgTalent;
                eCount = css.Excellence__c != null ? eCount + 1 : eCount;
                avgExcellence = css.Excellence__c != null ? avgExcellence + css.Excellence__c : avgExcellence;
                rCount = css.Results__c != null ? rCount + 1 : rCount;
                avgResult = css.Results__c != null ? avgResult + css.Results__c : avgResult;
            }
        
            //Divide and Set decimal
            avgScore = avgScore > 0 ? avgScore.divide(scoreCount, 1) : 0;
            avgSat = avgSat > 0 ? avgSat.divide(satCount, 1) : 0;
            avgPartnership = avgPartnership > 0 ? avgPartnership.divide(pCount, 1) : 0;
            avgInnovation = avgInnovation > 0 ? avgInnovation.divide(iCount, 1) : avgInnovation;
            avgTalent = avgTalent > 0 ? avgTalent.divide(tCount, 1) : 0;
            avgExcellence = avgExcellence > 0 ? avgExcellence.divide(eCount, 1) : avgExcellence;
            avgResult = avgResult > 0 ? avgResult.divide(rCount, 1) : avgResult;
            
            cssMap.put('PYlikelihood',String.valueOf(avgScore));
            cssMap.put('PYsatisfaction', String.valueOf(avgSat));
            cssMap.put('PYpartnership', String.valueOf(avgPartnership));
            cssMap.put('PYinnovation', String.valueOf(avgInnovation));
            cssMap.put('PYtalent', String.valueOf(avgTalent));
            cssMap.put('PYexcellence', String.valueOf(avgExcellence));
            cssMap.put('PYresults', String.valueOf(avgResult));
        } else {
            cssMap.put('PYlikelihood', 'N/A');
            cssMap.put('PYsatisfaction', 'N/A');
            cssMap.put('PYpartnership', 'N/A');
            cssMap.put('PYinnovation', 'N/A');
            cssMap.put('PYtalent', 'N/A');
            cssMap.put('PYexcellence', 'N/A');
            cssMap.put('PYresults', 'N/A');
        } 
        System.debug('CPA cssMap is: ' + cssMap);
        
        //Get Account Segmentation Data. Chintan, July 22, 2014. Case 125704
        segmentList = [SELECT Country__c, Segment__c FROM Account_Segmentation__c WHERE Associated_Account__c = :account.Id];
        for (Account_Segmentation__c segment : segmentList) {
            segment.Country__c = segment.Country__c.toLowerCase().capitalize();
        }
    } //constructor
}