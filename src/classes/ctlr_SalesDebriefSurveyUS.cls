/** Controller for displaying and editing Sales Debrief Surveys for the US
  * Case 110034. Chintan Adhyapak. March 03, 2014 */
public without sharing class ctlr_SalesDebriefSurveyUS {
	//class variables
    public Opportunity myOpp									{get; set;}
    public Sales_Debrief_Survey__c mySurvey						{get; set;}
    public Opportunity_Strategy__c myStrategy					{get; set;}
    public String score                         				{get; set;}
    public String postCloseScore								{get;set;}
    public List<Opportunity_Competitive_Analysis__c> compList   {get; set;}
    public List<Opportunity_Contact_Role__c> ocrList            {get; set;}
    private Id recordTypeId;
	
	/* Constructor */
    public ctlr_SalesDebriefSurveyUS(ApexPages.StandardController controller) {
        Id oppId = ApexPages.currentPage().getParameters().get('oppId');
        recordTypeId = ApexPages.currentPage().getParameters().get('RecordType');
        //read all fieldNames for Opportunity
        Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Opportunity.fields.getMap();
        String fieldNames = '';
        for(String fieldName : schemaFieldMap.keySet()) {
            fieldNames += ',' + fieldName;
        }
        fieldNames = fieldNames + ', Account.Legal_Name__c';
        fieldNames = fieldNames.substring(1);
        String soql = 'Select ' + fieldNames + ' From Opportunity Where Id = \'' + oppId + '\'';
        myOpp = Database.query(soql);
    } //constructor
    
    
    //Create Record if it doesn't exist
    public void init() {
        //read all fieldNames for Survey object
        Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Sales_Debrief_Survey__c.fields.getMap();
        
        //Create a SOQL string with all fields
        String fieldNames = '';
        for(String fieldName : schemaFieldMap.keySet()) {
            fieldNames += ',' + fieldName;
        }
        fieldNames = fieldNames.substring(1);
        String soql = 'Select ' + fieldNames + ' From Sales_Debrief_Survey__c Where RecordTypeId = \'' + recordTypeId + '\' And Opportunity_ID__c = \'' + myOpp.Id + '\'';
        
        //Read Survey
        List<Sales_Debrief_Survey__c> surveyList = Database.query(soql);
        if (surveyList.isEmpty()) {
            mySurvey = new Sales_Debrief_Survey__c();
            mySurvey.Opportunity_ID__c = myOpp.Id;
            mySurvey.RecordTypeId = recordTypeId;
            mySurvey.Account__c = myOpp.AccountId;
            mySurvey.Due_Date__c = myOpp.CloseDate.addDays(60);
            mySurvey.Interviewer_Name__c = getContactId(System.Userinfo.getUserId());
            insert mySurvey;
        } else {
            mySurvey = surveyList[0];
        }
        
        //Read all fieldNames for Opportunity Strategy object
       	schemaFieldMap = Schema.SObjectType.Opportunity_Strategy__c.fields.getMap();
        
        //Create a SOQL string with all fields
        fieldNames = '';
        for(String fieldName : schemaFieldMap.keySet()) {
            fieldNames += ',' + fieldName;
        }
        fieldNames = fieldNames.substring(1);
        soql = 'Select ' + fieldNames + ' From Opportunity_Strategy__c Where Related_Opportunity__c = \'' + myOpp.Id + '\'';
        
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
            Where Opportunity__c = :myOpp.Id Order By Competitor__c];
       	for (Opportunity_Competitive_Analysis__c comp : compList) {
       		comp.Strength__c = comp.Strength__c != null ? comp.Strength__c.replaceAll('\n', '<br>') : '';
       		comp.Weakness__c = comp.Weakness__c != null ? comp.Weakness__c.replaceAll('\n', '<br>') : '';
       		comp.Client_View__c = comp.Client_View__c != null ? comp.Client_View__c.replaceAll('\n', '<br>') : '';
       		comp.Estimated_Fees__c = comp.Estimated_Fees__c != null ? comp.Estimated_Fees__c.replaceAll('\n', '<br>') : '';
       	}
       	
       	//Set Contact List
        ocrList = [Select Account__c, Comments__c, Contact__r.Name, Role__c, Post_Close_Comments__c From Opportunity_Contact_Role__c Where Opportunity__c = :myOpp.Id 
            Order By Contact__r.Name];
        for (Opportunity_Contact_Role__c ocr : ocrList) {
        	ocr.Comments__c = ocr.Comments__c != null ? ocr.Comments__c.replaceAll('\n', '<br>') : '';
        }
    } //init
    
    
    //Autosave the data
    public PageReference autosave() {
        try {
            update mySurvey;
        } catch (Exception e1) {
            Apexpages.addMessages(e1);
            return null;
        }
        try {
        	for (Opportunity_Competitive_Analysis__c comp : compList) {
       			comp.Strength__c = comp.Strength__c != null ? comp.Strength__c.replaceAll('<br>', '\n') : '';
       			comp.Weakness__c = comp.Weakness__c != null ? comp.Weakness__c.replaceAll('<br>', '\n') : '';
       			comp.Client_View__c = comp.Client_View__c != null ? comp.Client_View__c.replaceAll('<br>', '\n') : '';
       			comp.Estimated_Fees__c = comp.Estimated_Fees__c != null ? comp.Estimated_Fees__c.replaceAll('<br>', '\n') : '';
       			comp.Post_Close_Comments__c = comp.Post_Close_Comments__c != null ? comp.Post_Close_Comments__c.replaceAll('<br>', '\n') : '';
       		}
            update compList;
        } catch (Exception e2) {
            Apexpages.addMessages(e2);
            return null;
        }
        try {
        	for (Opportunity_Contact_Role__c ocr : ocrList) {
        	ocr.Comments__c = ocr.Comments__c != null ? ocr.Comments__c.replaceAll('<br>', '\n') : '';
        	ocr.Post_Close_Comments__c = ocr.Post_Close_Comments__c != null ? ocr.Post_Close_Comments__c.replaceAll('<bt>', '\n') : '';
        	}
            update ocrList;
        } catch (Exception e3) {
            Apexpages.addMessages(e3);
            return null;
        }
        
        //Reload page
        PageReference redirect = new PageReference('/apex/SalesDebriefSurveyUS?oppid=' + myOpp.Id + '&RecordType=' + recordTypeId);
        redirect.setRedirect(true);
        return redirect;
    } //autosave
    
    
    /** Return to Opportunity */
    public PageReference returnBack() {
        PageReference redirect = new PageReference('/' + myOpp.Id);
        redirect.setRedirect(true);
        
        return redirect;
    } //returnBack
    
    
    //Save data and return back
    public PageReference saveAndClose() {
    	try {
            update mySurvey;
        } catch (Exception e1) {
            Apexpages.addMessages(e1);
            return null;
        }
        try {
        	for (Opportunity_Competitive_Analysis__c comp : compList) {
       			comp.Strength__c = comp.Strength__c != null ? comp.Strength__c.replaceAll('<br>', '\n') : '';
       			comp.Weakness__c = comp.Weakness__c != null ? comp.Weakness__c.replaceAll('<br>', '\n') : '';
       			comp.Client_View__c = comp.Client_View__c != null ? comp.Client_View__c.replaceAll('<br>', '\n') : '';
       			comp.Estimated_Fees__c = comp.Estimated_Fees__c != null ? comp.Estimated_Fees__c.replaceAll('<br>', '\n') : '';
       			comp.Post_Close_Comments__c = comp.Post_Close_Comments__c != null ? comp.Post_Close_Comments__c.replaceAll('<br>', '\n') : '';
       		}
            update compList;
        } catch (Exception e2) {
            Apexpages.addMessages(e2);
            return null;
        }
        try {
        	for (Opportunity_Contact_Role__c ocr : ocrList) {
        	ocr.Comments__c = ocr.Comments__c != null ? ocr.Comments__c.replaceAll('<br>', '\n') : '';
        	ocr.Post_Close_Comments__c = ocr.Post_Close_Comments__c != null ? ocr.Post_Close_Comments__c.replaceAll('<bt>', '\n') : '';
        	}
            update ocrList;
        } catch (Exception e3) {
            Apexpages.addMessages(e3);
            return null;
        }
        
        //Return back
        return this.returnBack();
    } //saveAndClose
    
    
    //Pass on to PDF page
    public PageReference generatePDF() {
    	PageReference redirect = new PageReference('/apex/SalesDebriefSurveyUSDoc?id=' + mySurvey.Id);
        redirect.setRedirect(true);
        return redirect;
    } //generatePDF
    
    
    //Get the Contact ID for the given User ID
    private Id getContactId(String userid) {
    	//local var
    	Id contactId = null;
    	//query
    	Contact myContact = [Select Id from Contact Where Corresponding_User_Id__c = :userId Limit 1];
    	if (myContact != null) {
    		contactId = myContact.Id;
    	}
    	//return
    	return contactId;
    } //getContactId
}