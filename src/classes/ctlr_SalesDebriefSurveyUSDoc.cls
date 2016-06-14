/** Controller for the PDF Sales Debrief Surveys Document for the US
  * Case 110034. Chintan Adhyapak. April 04, 2014 */
public without sharing class ctlr_SalesDebriefSurveyUSDoc {
	//class variables
    public Opportunity myOpp									{get; set;}
    public Sales_Debrief_Survey__c mySurvey						{get; set;}
    public Opportunity_Strategy__c myStrategy					{get; set;}
    public String score                         				{get; set;}
    public String postCloseScore								{get; set;}
    public List<Opportunity_Competitive_Analysis__c> compList   {get; set;}
    public List<Opportunity_Contact_Role__c> ocrList            {get; set;}
	
	/* Constructor */
    public ctlr_SalesDebriefSurveyUSDoc(ApexPages.StandardController controller) {
    	Id surveyId = ApexPages.currentPage().getParameters().get('id');
        //Read all fieldNames for Survey
        Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Sales_Debrief_Survey__c.fields.getMap();
        String fieldNames = '';
        for(String fieldName : schemaFieldMap.keySet()) {
            fieldNames += ',' + fieldName;
        }
        fieldNames += ',Contact__r.Name, Interviewer_Name__r.Name';
        fieldNames = fieldNames.substring(1);
        String soql = 'Select ' + fieldNames + ' From Sales_Debrief_Survey__c Where Id = \'' + surveyId + '\'';
        System.debug('CPA SQL: ' + soql);
        mySurvey = Database.query(soql);
        
        //Read Opp
        Id oppId = mySurvey.Opportunity_ID__c;
        //Read all fieldNames for Opportunity
        schemaFieldMap = Schema.SObjectType.Opportunity.fields.getMap();
        fieldNames = '';
        for(String fieldName : schemaFieldMap.keySet()) {
            fieldNames += ',' + fieldName;
        }
        fieldNames = fieldNames + ', Account.Legal_Name__c';
        fieldNames = fieldNames.substring(1);
        soql = 'Select ' + fieldNames + ' From Opportunity Where Id = \'' + oppId + '\'';
        System.debug('CPA SQL: ' + soql);
        myOpp = Database.query(soql);
        
        //Handle Newlines
        mySurvey.Situation_Post_Close__c = mySurvey.Situation_Post_Close__c != null ? mySurvey.Situation_Post_Close__c.replaceAll('\n', '<br>') : '';
        mySurvey.Opportunity_Post_Close__c = mySurvey.Opportunity_Post_Close__c != null ? mySurvey.Opportunity_Post_Close__c.replaceAll('\n', '<br>') : '';
        mySurvey.Walls_Post_Close__c = mySurvey.Walls_Post_Close__c != null ? mySurvey.Walls_Post_Close__c.replaceAll('\n', '<br>') : '';
        mySurvey.Solutions_Post_Close__c = mySurvey.Solutions_Post_Close__c != null ? mySurvey.Solutions_Post_Close__c.replaceAll('\n', '<br>') : '';
        mySurvey.Value_Proposition_Post_Close__c = mySurvey.Value_Proposition_Post_Close__c != null ? mySurvey.Value_Proposition_Post_Close__c.replaceAll('\n', '<br>') : '';
        mySurvey.Elevator_Message_Post_Close__c = mySurvey.Elevator_Message_Post_Close__c != null ? mySurvey.Elevator_Message_Post_Close__c.replaceAll('\n', '<br>') : '';
        mySurvey.Steps_to_Win_This_Deal_Post_Close__c = mySurvey.Steps_to_Win_This_Deal_Post_Close__c != null ? mySurvey.Steps_to_Win_This_Deal_Post_Close__c.replaceAll('\n', '<br>') : '';
        mySurvey.Close_This_Deal_Post_Close__c = mySurvey.Close_This_Deal_Post_Close__c != null ? mySurvey.Close_This_Deal_Post_Close__c.replaceAll('\n', '<br>') : '';
        mySurvey.Burning_Platform_Post_Close_Comments__c = mySurvey.Burning_Platform_Post_Close_Comments__c != null ? mySurvey.Burning_Platform_Post_Close_Comments__c.replaceAll('\n', '<br>') : '';
        mySurvey.Relationship_Post_Close_Comments__c = mySurvey.Relationship_Post_Close_Comments__c != null ? mySurvey.Relationship_Post_Close_Comments__c.replaceAll('\n', '<br>') : '';
        mySurvey.Active_Opportunities_Post_Close_Comments__c = mySurvey.Active_Opportunities_Post_Close_Comments__c != null ? mySurvey.Active_Opportunities_Post_Close_Comments__c.replaceAll('\n', '<br>') : '';
        mySurvey.Decision_Making_Post_Close_Comments__c = mySurvey.Decision_Making_Post_Close_Comments__c != null ? mySurvey.Decision_Making_Post_Close_Comments__c.replaceAll('\n', '<br>') : '';
        mySurvey.Solution_Fit_Post_Close_Comments__c = mySurvey.Solution_Fit_Post_Close_Comments__c != null ? mySurvey.Solution_Fit_Post_Close_Comments__c.replaceAll('\n', '<br>') : '';
        mySurvey.Q_and_R_Post_Close_Comments__c = mySurvey.Q_and_R_Post_Close_Comments__c != null ? mySurvey.Q_and_R_Post_Close_Comments__c.replaceAll('\n', '<br>') : '';
        mySurvey.Revenue_Growth_Post_Close_Comments__c = mySurvey.Revenue_Growth_Post_Close_Comments__c != null ? mySurvey.Revenue_Growth_Post_Close_Comments__c.replaceAll('\n', '<br>') : '';
        mySurvey.Firm_Leverage_Post_Close_Comments__c = mySurvey.Firm_Leverage_Post_Close_Comments__c != null ? mySurvey.Firm_Leverage_Post_Close_Comments__c.replaceAll('\n', '<br>') : '';
        mySurvey.Financial_Factors_Post_Close_Comments__c = mySurvey.Financial_Factors_Post_Close_Comments__c != null ? mySurvey.Financial_Factors_Post_Close_Comments__c.replaceAll('\n', '<br>') : '';
        mySurvey.Risk_Factors_Post_Close_Comments__c = mySurvey.Risk_Factors_Post_Close_Comments__c != null ? mySurvey.Risk_Factors_Post_Close_Comments__c.replaceAll('\n', '<br>') : '';
        mySurvey.Competition_Post_Close_Comments__c = mySurvey.Competition_Post_Close_Comments__c != null ? mySurvey.Competition_Post_Close_Comments__c.replaceAll('\n', '<br>') : '';
        mySurvey.Form_of_Contract_Post_Close_Comments__c = mySurvey.Form_of_Contract_Post_Close_Comments__c != null ? mySurvey.Form_of_Contract_Post_Close_Comments__c.replaceAll('\n', '<br>') : '';
        mySurvey.Term_of_Convenience_Post_Close_Comments__c = mySurvey.Term_of_Convenience_Post_Close_Comments__c != null ? mySurvey.Term_of_Convenience_Post_Close_Comments__c.replaceAll('\n', '<br>') : '';
        mySurvey.Liability_Cap_Post_Close_Comments__c = mySurvey.Liability_Cap_Post_Close_Comments__c != null ? mySurvey.Liability_Cap_Post_Close_Comments__c.replaceAll('\n', '<br>') : '';
        mySurvey.Fee_Escalator_Post_Close_Comments__c = mySurvey.Fee_Escalator_Post_Close_Comments__c != null ? mySurvey.Fee_Escalator_Post_Close_Comments__c.replaceAll('\n', '<br>') : '';
        mySurvey.Service_Levels_Post_Close_Comments__c = mySurvey.Service_Levels_Post_Close_Comments__c != null ? mySurvey.Service_Levels_Post_Close_Comments__c.replaceAll('\n', '<br>') : '';
        mySurvey.Payment_Terms_Post_Close_Comments__c = mySurvey.Payment_Terms_Post_Close_Comments__c != null ? mySurvey.Payment_Terms_Post_Close_Comments__c.replaceAll('\n', '<br>') : '';
        mySurvey.Required_Decision_Post_Close_Comments__c = mySurvey.Required_Decision_Post_Close_Comments__c != null ? mySurvey.Required_Decision_Post_Close_Comments__c.replaceAll('\n', '<br>') : '';
        mySurvey.Key_Terms_Post_Close_Comments__c = mySurvey.Key_Terms_Post_Close_Comments__c != null ? mySurvey.Key_Terms_Post_Close_Comments__c.replaceAll('\n', '<br>') : '';
        mySurvey.Pricing_Comments__c = mySurvey.Pricing_Comments__c != null ? mySurvey.Pricing_Comments__c.replaceAll('\n', '<br>') : '';
        mySurvey.Third_Party_Evaluators_Comments__c = mySurvey.Third_Party_Evaluators_Comments__c != null ? mySurvey.Third_Party_Evaluators_Comments__c.replaceAll('\n', '<br>') : '';
        mySurvey.Finalist_Site_Visit_Meetings_Comments__c = mySurvey.Finalist_Site_Visit_Meetings_Comments__c != null ? mySurvey.Finalist_Site_Visit_Meetings_Comments__c.replaceAll('\n', '<br>') : '';
        mySurvey.Demo_Feedback_Comments__c = mySurvey.Demo_Feedback_Comments__c != null ? mySurvey.Demo_Feedback_Comments__c.replaceAll('\n', '<br>') : '';
        mySurvey.Lost_Any_other_comments_on_Aon_Hewitt__c = mySurvey.Lost_Any_other_comments_on_Aon_Hewitt__c != null ? mySurvey.Lost_Any_other_comments_on_Aon_Hewitt__c.replaceAll('\n', '<br>') : '';
        mySurvey.Won_Any_other_comments_on_Aon_Hewitt__c = mySurvey.Won_Any_other_comments_on_Aon_Hewitt__c != null ? mySurvey.Won_Any_other_comments_on_Aon_Hewitt__c.replaceAll('\n', '<br>') : '';
        mySurvey.Conclusions__c = mySurvey.Conclusions__c != null ? mySurvey.Conclusions__c.replaceAll('\n', '<br>') : '';
        
        //Read all fieldNames for Opportunity Strategy object
       	schemaFieldMap = Schema.SObjectType.Opportunity_Strategy__c.fields.getMap();
        
        //Create a SOQL string with all fields
        fieldNames = '';
        for(String fieldName : schemaFieldMap.keySet()) {
            fieldNames += ',' + fieldName;
        }
        fieldNames = fieldNames.substring(1);
        soql = 'Select ' + fieldNames + ' From Opportunity_Strategy__c Where Related_Opportunity__c = \'' + oppId + '\'';
        
        //Read Strategy data
        List<Opportunity_Strategy__c> strategyList = Database.query(soql);
        
        if (strategyList.isEmpty()) {
            myStrategy = new Opportunity_Strategy__c();
        } else {
            myStrategy = strategyList[0];
            myStrategy.Situation__c = myStrategy.Situation__c != null ? myStrategy.Situation__c.replaceAll('\n', '<br>') : '';
            myStrategy.Opportunity__c = myStrategy.Opportunity__c != null ? myStrategy.Opportunity__c.replaceAll('\n', '<br>') : '';
            myStrategy.Walls__c = myStrategy.Walls__c != null ? myStrategy.Walls__c.replaceAll('\n', '<br>') : '';
            myStrategy.Solutions__c = myStrategy.Solutions__c != null ? myStrategy.Solutions__c.replaceAll('\n', '<br>') : '';
            myStrategy.Value_Proposition__c = myStrategy.Value_Proposition__c != null ? myStrategy.Value_Proposition__c.replaceAll('\n', '<br>') : '';
            myStrategy.Elevator_Message__c = myStrategy.Elevator_Message__c != null ? myStrategy.Elevator_Message__c.replaceAll('\n', '<br>') : '';
            myStrategy.Steps_to_Win_This_Deal__c = myStrategy.Steps_to_Win_This_Deal__c != null ? myStrategy.Steps_to_Win_This_Deal__c.replaceAll('\n', '<br>') : '';
            myStrategy.Close_This_Deal__c = myStrategy.Close_This_Deal__c != null ? myStrategy.Close_This_Deal__c.replaceAll('\n', '<br>') : '';
            myStrategy.Burning_Platform_Comments__c = myStrategy.Burning_Platform_Comments__c != null ? myStrategy.Burning_Platform_Comments__c.replaceAll('\n', '<br>') : '';
            myStrategy.Relationship_Comments__c = myStrategy.Relationship_Comments__c != null ? myStrategy.Relationship_Comments__c.replaceAll('\n', '<br>') : '';
            myStrategy.Active_Opportunities_Comments__c = myStrategy.Active_Opportunities_Comments__c != null ? myStrategy.Active_Opportunities_Comments__c.replaceAll('\n', '<br>') : '';
            myStrategy.Decision_Making_Process_Comments__c = myStrategy.Decision_Making_Process_Comments__c != null ? myStrategy.Decision_Making_Process_Comments__c.replaceAll('\n', '<br>') : '';
            myStrategy.Solution_Fit_Comments__c = myStrategy.Solution_Fit_Comments__c != null ? myStrategy.Solution_Fit_Comments__c.replaceAll('\n', '<br>') : '';
            myStrategy.Qualifications_References_Comments__c = myStrategy.Qualifications_References_Comments__c != null ? myStrategy.Qualifications_References_Comments__c.replaceAll('\n', '<br>') : '';
            myStrategy.Revenue_Growth_Comments__c = myStrategy.Revenue_Growth_Comments__c != null ? myStrategy.Revenue_Growth_Comments__c.replaceAll('\n', '<br>') : '';
            myStrategy.Firm_Leverage_Comments__c = myStrategy.Firm_Leverage_Comments__c != null ? myStrategy.Firm_Leverage_Comments__c.replaceAll('\n', '<br>') : '';
            myStrategy.Financial_Factors_Comments__c = myStrategy.Financial_Factors_Comments__c != null ? myStrategy.Financial_Factors_Comments__c.replaceAll('\n', '<br>') : '';
            myStrategy.Risk_Factors_Comments__c = myStrategy.Risk_Factors_Comments__c != null ? myStrategy.Risk_Factors_Comments__c.replaceAll('\n', '<br>') : '';
            myStrategy.Competition_Comments__c = myStrategy.Competition_Comments__c != null ? myStrategy.Competition_Comments__c.replaceAll('\n', '<br>') : '';
            myStrategy.Form_of_Contract_Client__c = myStrategy.Form_of_Contract_Client__c != null ? myStrategy.Form_of_Contract_Client__c.replaceAll('\n', '<br>') : '';
            myStrategy.Form_of_Contract_Aon_Hewitt__c = myStrategy.Form_of_Contract_Aon_Hewitt__c != null ? myStrategy.Form_of_Contract_Aon_Hewitt__c.replaceAll('\n', '<br>') : '';
            myStrategy.Term_for_Convenience_Client__c = myStrategy.Term_for_Convenience_Client__c != null ? myStrategy.Term_for_Convenience_Client__c.replaceAll('\n', '<br>') : '';
            myStrategy.Term_for_Convenience_Aon_Hewitt__c = myStrategy.Term_for_Convenience_Aon_Hewitt__c != null ? myStrategy.Term_for_Convenience_Aon_Hewitt__c.replaceAll('\n', '<br>') : '';
            myStrategy.Liability_Cap_Client__c = myStrategy.Liability_Cap_Client__c != null ? myStrategy.Liability_Cap_Client__c.replaceAll('\n', '<br>') : '';
            myStrategy.Liability_Cap_Aon_Hewitt__c = myStrategy.Liability_Cap_Aon_Hewitt__c != null ? myStrategy.Liability_Cap_Aon_Hewitt__c.replaceAll('\n', '<br>') : '';
            myStrategy.Fee_Escalator_Client__c = myStrategy.Fee_Escalator_Client__c != null ? myStrategy.Fee_Escalator_Client__c.replaceAll('\n', '<br>') : '';
            myStrategy.Fee_Escalator_Aon_Hewitt__c = myStrategy.Fee_Escalator_Aon_Hewitt__c != null ? myStrategy.Fee_Escalator_Aon_Hewitt__c.replaceAll('\n', '<br>') : '';
            myStrategy.Service_Levels_Client__c = myStrategy.Service_Levels_Client__c != null ? myStrategy.Service_Levels_Client__c.replaceAll('\n', '<br>') : '';
            myStrategy.Service_Levels_Aon_Hewitt__c = myStrategy.Service_Levels_Aon_Hewitt__c != null ? myStrategy.Service_Levels_Aon_Hewitt__c.replaceAll('\n', '<br>') : '';
            myStrategy.Payment_Terms_Client__c = myStrategy.Payment_Terms_Client__c != null ? myStrategy.Payment_Terms_Client__c.replaceAll('\n', '<br>') : '';
            myStrategy.Payment_Terms_Aon_Hewitt__c = myStrategy.Payment_Terms_Aon_Hewitt__c != null ? myStrategy.Payment_Terms_Aon_Hewitt__c.replaceAll('\n', '<br>') : '';
            myStrategy.Required_Decision_Date_Client__c = myStrategy.Required_Decision_Date_Client__c != null ? myStrategy.Required_Decision_Date_Client__c.replaceAll('\n', '<br>') : '';
            myStrategy.Required_Decision_Date_Aon_Hewitt__c = myStrategy.Required_Decision_Date_Aon_Hewitt__c != null ? myStrategy.Required_Decision_Date_Aon_Hewitt__c.replaceAll('\n', '<br>') : '';
            myStrategy.Other_Key_Terms_Client__c = myStrategy.Other_Key_Terms_Client__c != null ? myStrategy.Other_Key_Terms_Client__c.replaceAll('\n', '<br>') : '';
            myStrategy.Other_Key_Terms_Aon_Hewitt__c = myStrategy.Other_Key_Terms_Aon_Hewitt__c != null ? myStrategy.Other_Key_Terms_Aon_Hewitt__c.replaceAll('\n', '<br>') : '';
        }
        
        //Set Score
        score = 'Red';
        if (myStrategy.Total__c < 0) {
            score = 'Red';
        } else if (myStrategy.Total__c <= 5) {
            score = 'Yellow';
        } else if (myStrategy.Total__c > 5){
            score = 'Green';
        }
        
        //Set Post Close Score
         postCloseScore = 'Red';
        if (mySurvey.Total_Post_Close__c < 0) {
            postCloseScore = 'Red';
        } else if (mySurvey.Total_Post_Close__c <= 5) {
            postCloseScore = 'Yellow';
        } else if (mySurvey.Total_Post_Close__c > 5){
            postCloseScore = 'Green';
        }
        
        //Set compList
        compList = [Select Competitor__c, Strength__c, Weakness__c, Client_View__c, Estimated_Fees__c, Post_Close_Comments__c from Opportunity_Competitive_Analysis__c 
            Where Opportunity__c = :oppId Order By Competitor__c];
       	for (Opportunity_Competitive_Analysis__c comp : compList) {
       		comp.Strength__c = comp.Strength__c != null ? comp.Strength__c.replaceAll('\n', '<br>') : '';
       		comp.Weakness__c = comp.Weakness__c != null ? comp.Weakness__c.replaceAll('\n', '<br>') : '';
       		comp.Client_View__c = comp.Client_View__c != null ? comp.Client_View__c.replaceAll('\n', '<br>') : '';
       		comp.Estimated_Fees__c = comp.Estimated_Fees__c != null ? comp.Estimated_Fees__c.replaceAll('\n', '<br>') : '';
       		comp.Post_Close_Comments__c = comp.Post_Close_Comments__c != null ? comp.Post_Close_Comments__c.replaceAll('\n', '<br>') : '';
       	}
       	
       	//Set Contact List
        ocrList = [Select Account__r.Name, Comments__c, Contact__r.Name, Role__c, Post_Close_Comments__c From Opportunity_Contact_Role__c Where Opportunity__c = :oppId 
            Order By Contact__r.Name];
        for (Opportunity_Contact_Role__c ocr : ocrList) {
        	ocr.Comments__c = ocr.Comments__c != null ? ocr.Comments__c.replaceAll('\n', '<br>') : '';
        	ocr.Post_Close_Comments__c = ocr.Post_Close_Comments__c != null ? ocr.Post_Close_Comments__c.replaceAll('\n', '<br>') : '';
        }
    } //constructor
} //class