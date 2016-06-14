/** Controller that sends out an email when Submit Proposal Request button is clicked
  * Case 10167. Chintan Adhyapak. September 10, 2012 */
public with sharing class ctlr_SubmitProposalRequest {
    /* class attributes */
    private String proposalId       {get;set;}
    public String emailList         {get;set;}
    public String attachmentList    {get;set;}
    public String errorMessage      {get;set;}
    
    /* constructor */
    public ctlr_SubmitProposalRequest(ApexPages.StandardController controller) {
        Proposal_Request__c currProposal = (Proposal_Request__c)controller.getRecord();
        currProposal = [SELECT Id, Opportunity__c FROM Proposal_Request__c WHERE Id = :currProposal.Id];
        this.proposalId = currProposal.Id;
        attachmentList = '';
        errorMessage = '';
    }

    /* action method */
    public PageReference init() {
        //local vars
        PageReference retPage = null;

        //Read Data
        Proposal_Request__c myProposal = [Select Id, Account__r.Name, Opportunity__r.Name, Opportunity__r.StageName, Type__c, RFP_Type__c, Status__c, Requestor__r.Name, What_is_Needed__c, 
            Delivery_Method__c, Hard_Copies_Number_Needed__c, Global_RFP__c, Global_Countries__c, Account_Executive__r.Name, Sales_Manager__r.Name, 
            Sales_Executive__r.Name, Sales_Bid_Manager__r.Name, Proposal_Writer__r.Name, N_C__r.Name, Finance__r.Name, Solution_Architect__r.Name, 
            General_Counsel_Contracts__r.Name, Production_Assistant__r.Name, Other_Interested_Stakeholders__c, Date_RFP_Received__c, Vendor_Questions_Due_to_Customer__c, 
            Expected_RFP_Decision_Date__c, Proposal_Submission_Due_Date__c, General_Counsel_Review_Required__c, Existing_Aon_Hewitt_Relationship__c, 
            Current_HRIS_System__c, Proposed_HRIS_System__c, Special_Instructions__c, Requestor__r.Email, Sales_Executive__r.Email,
            Account_Executive__r.Email, Sales_Manager__r.Email, Sales_Bid_Manager__r.Email, Proposal_Writer__r.Email, N_C__r.Email, Finance__r.Email,
            Solution_Architect__r.Email, General_Counsel_Contracts__r.Email, Production_Assistant__r.Email,Third_Party_Advisors_Involved__r.Name, Opportunity__c, Email_Error__c, Name,
            Number_of_Positions_in_Scope__c, Type_of_Positions_in_Scope__c, Notify_Legal_Only__c
            from Proposal_Request__c Where Id = :proposalId];
            System.debug('CHINTAN Proposal Opportunity ID is: ' + myProposal.Opportunity__c);
        
         //00077630-Ritu-Return if RFP Type is other than RFI and opp is not in proposal+ stage
         if ((myProposal.RFP_Type__c != 'RFI') && (myProposal.Opportunity__r.StageName == 'Non-Qualified Opportunity' || myProposal.Opportunity__r.StageName == 'Qualify Opportunity')) {            
             errorMessage = 'The Opportunity must have reached the Propose Solution stage in order for the request to be submitted.';
             return retPage;
         }
        
        //Read Type
        String[] types = myProposal.Type__c.split(';');
        
        //Read Custom Setting
        List<Proposal_Request_Settings__c> appSettings = [Select Email_Recipients__c, Type__c, Help__c from Proposal_Request_Settings__c Where Type__c in :types];
        //Proposal_Request_Settings__c appSettings = Proposal_Request_Settings__c.getInstance(myProposal.Type__c);
        
        this.emailList = '';
        //Check if Notify Legal Only checkbox is selected
        if (myProposal.Notify_Legal_Only__c) {
        	System.debug('CPA - URL: ' + System.Url.getSalesforceBaseUrl().getHost());
        	if (URL.getSalesforceBaseUrl().getHost().containsIgnorecase('cs')) {
        		emailList = 'Marissa.Alonso@aon.com,Chintan.Adhyapak@aon.com';
        	} else {
        		emailList = 'DG-AH-Americas-CloudDeploymentSolutionsContracts@aon.com';
        		//emailList = 'chintan.adhyapak@aon.com';
        	}
        } else {
        	for (Proposal_Request_Settings__c setting : appSettings) {
	            emailList += setting.Email_Recipients__c + ',';
        	}
        	emailList += myProposal.Requestor__r.Email + ',' + myProposal.Sales_Executive__r.Email + ',' + myProposal.Account_Executive__r.Email;
        	emailList += myProposal.Sales_Manager__r.Email != null ? ',' + myProposal.Sales_Manager__r.Email : '';
        	emailList += myProposal.Sales_Bid_Manager__r.Email != null ? ',' + myProposal.Sales_Bid_Manager__r.Email : '';
        	emailList += myProposal.Proposal_Writer__r.Email != null ? ',' + myProposal.Proposal_Writer__r.Email : '';
        	emailList += myProposal.N_C__r.Email != null ? ',' + myProposal.N_C__r.Email : '';
        	emailList += myProposal.Finance__r.Email != null ? ',' + myProposal.Finance__r.Email : '';
        	emailList += myProposal.Solution_Architect__r.Email != null ? ',' + myProposal.Solution_Architect__r.Email : '';
        	emailList += myProposal.General_Counsel_Contracts__r.Email != null ? ',' + myProposal.General_Counsel_Contracts__r.Email : '';
        	emailList += myProposal.Production_Assistant__r.Email != null ? ',' + myProposal.Production_Assistant__r.Email : '';
        }
        System.debug('CPA Email List is: ' + emailList);
        
        //Create a Mail Message
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setCharset('UTF-8');
        List<Messaging.EmailFileAttachment> fileAttachments = new List<Messaging.EmailFileAttachment> ();
        String[] toAddresses = emailList.split(',', 0); 
    
        //Read Attachments tied to this Proposal
        List<Attachment> attachments = [Select Body, Name from Attachment where parentId = :proposalId];
    
        //Loop through all attachments and add to fileattachments list
        for (Attachment myAttachment : attachments) {
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();  
            efa.setFileName(myAttachment.Name);
            attachmentList += myAttachment.Name + ', ';
            efa.setBody(myAttachment.Body); 
            fileAttachments.add(efa);
        }
        attachmentList = attachmentList.length() > 0 ? attachmentList.substring(0, attachmentList.length() - 2) : '';
        
        //Set Mail Content            
        mail.setSubject('RFP from Account ' + myProposal.Account__r.Name);
        mail.setToAddresses(toAddresses);
        mail.setHtmlBody(getEmailBody(myProposal, appSettings[0]));
        mail.setFileAttachments(fileAttachments);
        
        //Send Email
        try {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
        } catch (Exception e) {
            //errorMessage += 'Error in Sending Email: ' + e.getMessage() + '<br>';
            //Trap the Attachment size error
            if (e.getMessage().containsIgnoreCase('MAXIMUM_SIZE_OF_ATTACHMENT')) {
                myProposal.Email_Error__c = true;
                update myProposal;
                return retPage;
            } else {
                throw e;
            }
        }
        //Clear Email Error if no error
        myProposal.Email_Error__c = false;
        update myProposal;
        
        //Create Task Record
        Task myTask = new Task();
        myTask.OwnerId = UserInfo.getUserId();
        myTask.Subject = 'Proposal Request Email Sent';
        myTask.ActivityDate = Date.today();
        myTask.Type = 'Operational';
        myTask.WhatId = myProposal.Id;
        myTask.Description = 'Email of files for Proposal Record has been completed';
        myTask.Status = 'Completed';
        myTask.Priority = 'Normal';
        try { insert myTask;
        } catch (Exception e) {
            errorMessage += 'Error in creating Task: ' + e.getMessage();
        }
        
        //Return
        return retPage;        
    } //init
    
    
    /** Return to Proposal Request Form */
    public PageReference returnBack() {
        PageReference redirect = new PageReference('/' + proposalId);
        redirect.setRedirect(true);
        
        return redirect;
    } //returnBack
    
    
    /** Returns a HTML String that will be the email body */  
    private String getEmailBody(Proposal_Request__c myProposal, Proposal_Request_Settings__c appSettings) {
        //local vars
        String dark = '#659EC7';
        String light = '#F0F0F0';
        String[] helperList = new String[0];
        String helperString = '';
        
        //Read Associated Service records tied to this Proposal
        List<Associated_Service__c> associatedServices = [Select Service__c, First_Year_Value__c, Eligible_Participants_Units__c, Service_Start_Date__c, Service_End_Date__c, Platform__c, Type__c from Associated_Service__c Where Proposal_Request__c = :proposalId];
        
        //Read details of help associates to put in the email
        String helpers = appSettings.Help__c;
        if (helpers != null) {
            helperList = helpers.split(',', 0);
        }
        if (helperList.size() == 6) {
            //00144996 - Updated Text
            helperString = '<a href="mailto:' + helperList[1] + '?Subject=RFP%20Help">' + helperList[0] + '</a> for Investment Consulting RFPs<br>';
            helperString += '<a href="mailto:' + helperList[3] + '?Subject=RFP%20Help">' + helperList[2] + '</a> for all other Consulting RFPs<br>';
            helperString += '<a href="mailto:' + helperList[5] + '?Subject=RFP%20Help">' + helperList[4] + '</a> for Outsourcing RFPs';
        }
        if (helperString.length() == 0) {
            helperString = ' your local Sales Operations Team.';
        }
        
        //Format dates for the email
        Datetime closeDate = datetime.newInstance(myProposal.Proposal_Submission_Due_Date__c.year(), myProposal.Proposal_Submission_Due_Date__c.month(),myProposal.Proposal_Submission_Due_Date__c.day());
        Datetime dateRFPReceived = datetime.newInstance(myProposal.Date_RFP_Received__c.year(), myProposal.Date_RFP_Received__c.month(),myProposal.Date_RFP_Received__c.day());
        Datetime vendorQuestions = null;
        if (myProposal.Vendor_Questions_Due_to_Customer__c != null) {
            vendorQuestions = datetime.newInstance(myProposal.Vendor_Questions_Due_to_Customer__c.year(),myProposal.Vendor_Questions_Due_to_Customer__c.month(),myProposal.Vendor_Questions_Due_to_Customer__c.day());
        }
        Datetime expectedDecisionDate = datetime.newInstance(myProposal.Expected_RFP_Decision_Date__c.year(), myProposal.Expected_RFP_Decision_Date__c.month(),myProposal.Expected_RFP_Decision_Date__c.day());
        String type = myProposal.Type__c.replaceAll(';', '/');
        
        String emailBody = 'A RFP has been received from Account <b>' + myProposal.Account__r.Name + '</b> for <b>' + type + '</b> services. ';
        emailBody += 'It is due on <font color="red"><b>' + closeDate.format('MMM dd, yyyy') + '</b></font>.';
        if (!myProposal.Notify_Legal_Only__c) {
        	emailBody += '<br>Please reply to everyone on this email with the name of your team\'s resource that will be aligned to this opportunity.<br>';
        	emailBody += 'The information provided in this email, including any attachment(s), should help in identifying the appropriate resource.';
        }
        emailBody += '<br><a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + myProposal.Id + '">Click here to access the RFP in SFDC</a>';
        emailBody += '<br><br>For any additional help please contact:<br>';
        emailBody += helperString;
        emailBody += '<br><br>Thank you for your assistance with this opportunity.<br>';
        emailBody += '<hr/><br>';
        emailBody += '<table style="border-style:solid; border-width:2px;" width="100%">';
        emailBody += '<tr>';
        emailBody += '<td style="border-style:none; background-color:' + dark + ';" colspan="3">Proposal Request Details</td>';
        emailBody += '</tr><tr>';
        emailBody += '<td style="border-style:none;">Account&nbsp;&nbsp;<b>' + myProposal.Account__r.Name + '</b></td>';
        emailBody += '<td style="border-style:none;">Opportunity&nbsp;&nbsp;<b>' + myProposal.Opportunity__r.Name + '</b></td>';
        emailBody += '<td style="border-style:none;">Type&nbsp;&nbsp;<b>' + myProposal.Type__c + '</b></td>';
        emailBody += '</tr><tr>';
        emailBody += '<td style="border-style:none; background-color: ' + light + ';">RFP Type&nbsp;&nbsp;<b>' + myProposal.RFP_Type__c + '</b></td>';
        emailBody += '<td style="border-style:none; background-color: ' + light + ';">Requestor&nbsp;&nbsp;<b>' + myProposal.Requestor__r.Name + '</b></td>';
        emailBody += '<td style="border-style:none; background-color: ' + light + ';">Status&nbsp;&nbsp;<b>' + myProposal.Status__c + '</b></td>';
        emailBody += '</tr><tr>';
        emailBody += '<td style="border-style:none;">What is Needed&nbsp;&nbsp;<b>' + myProposal.What_is_Needed__c + '</b></td>';
        emailBody += '<td style="border-style:none;">Delivery Method&nbsp;&nbsp;<b>' + myProposal.Delivery_Method__c + '</b></td>';
        emailBody += '<td style="border-style:none;">Hard Copies (Number Needed)&nbsp;&nbsp;<b>' + (myProposal.Hard_Copies_Number_Needed__c > 0 ? myProposal.Hard_Copies_Number_Needed__c : 0) + '</b></td>';
        emailBody += '</tr><tr>';
        emailBody += '<td style="border-style:none; background-color: ' + light + ';">Global RFP&nbsp;&nbsp;<b>' + (myProposal.Global_RFP__c == true ? 'True' : 'False') + '</b></td>';
        emailBody += '<td style="border-style:none; background-color: ' + light + ';">Global Countries&nbsp;&nbsp;<b>' + (myProposal.Global_Countries__c != null ? myProposal.Global_Countries__c : '') + '</b></td>';
        emailBody += '<td style="border-style:none; background-color: ' + light + ';">General Counsel Review Required&nbsp;&nbsp;<b>' + (myProposal.General_Counsel_Review_Required__c != null ? myProposal.General_Counsel_Review_Required__c : '') + '</b></td>';
        emailBody += '</tr><tr>';
        emailBody += '<td style="border-style:none;">Third Party Advisor Involved&nbsp;&nbsp;<b>' + (myProposal.Third_Party_Advisors_Involved__c  != null ? myProposal.Third_Party_Advisors_Involved__r.Name : '') + '</b></td>';
        emailBody += '<td style="border-style:none;">Existing Aon Hewitt Relationship&nbsp;&nbsp;<b>' + myProposal.Existing_Aon_Hewitt_Relationship__c + '</b></td>';
        emailBody += '<td style="border-style:none;">Proposal Request ID&nbsp;&nbsp;<b>' + myProposal.get('Name') + '</b></td>';
        emailBody += '</tr><tr>';
        emailBody += '<td style="border-style:none; background-color:' + light + ';">Special Instructions&nbsp;&nbsp;<b>' + (myProposal.Special_Instructions__c != null ? myProposal.Special_Instructions__c : '') + '</b></td>';
        //Case 110757. Chintan, January 30, 2014
        System.debug('CPA Type is: ' + myProposal.Type__c);
        if (myProposal.Type__c.contains('RPO')) {
            emailBody += '<td style="border-style:none; background-color:' + light + ';">Number of Positions in Scope&nbsp;&nbsp;<b>' + (myProposal.Number_of_Positions_in_Scope__c != null ? myProposal.Number_of_Positions_in_Scope__c : '') + '</b></td>';
            emailBody += '<td style="border-style:none; background-color:' + light + ';">Type of Positions in Scope&nbsp;&nbsp;<b>' + (myProposal.Type_of_Positions_in_Scope__c != null ? myProposal.Type_of_Positions_in_Scope__c : '') + '</b></td>';
        } else {
            emailBody += '<td style="border-style:none; background-color:' + light + ';">&nbsp;&nbsp;</td>';
            emailBody += '<td style="border-style:none; background-color:' + light + ';">&nbsp;&nbsp;</td>';
        }
        emailBody += '</tr><tr>';
        emailBody += '<td style="border-style:none; background-color:' + dark + ';" colspan="3">Key Dates</td>';
        emailBody += '</tr><tr>';
        emailBody += '<td style="border-style:none;">Date RFP Received&nbsp;&nbsp;<b>' + dateRFPReceived.format('MMM dd, yyyy') + '</b></td>';
        emailBody += '<td style="border-style:none;">Vendor Questions Due to Customer&nbsp;&nbsp;<b>' + (myProposal.Vendor_Questions_Due_to_Customer__c != null ? vendorQuestions.format('MMM dd, yyyy') : '') + '</b></td>';
        emailBody += '<td style="border-style:none;">Proposal Submission Due-Date&nbsp;&nbsp;<b>' + closeDate.format('MMM dd, yyyy') + '</b></td>';
        emailBody += '</tr><tr>';
        emailBody += '<td style="border-style:none; background-color: ' + light + ';">Expected RFP Decision Date&nbsp;&nbsp;<b>' + expectedDecisionDate.format('MMM dd, yyyy') + '</b></td>';
        emailBody += '<td style="border-style:none; background-color: ' + light + ';">&nbsp;&nbsp;</td>';
        emailBody += '<td style="border-style:none; background-color: ' + light + ';">&nbsp;&nbsp;</td>';
        emailBody += '</tr><tr>';
        emailBody += '<td style="border-style:none; background-color:' + dark + ';" colspan="3">Associated Services</td>';
        emailBody += '</tr>';
        for (Associated_Service__c service : associatedServices) {
            Datetime serviceStartDate = (service.Service_Start_Date__c != null) ? Datetime.newInstance(service.Service_Start_Date__c.year(), service.Service_Start_Date__c.month(), service.Service_Start_Date__c.day()) : null;
            emailBody += '<tr>';
            emailBody += '<td style="border-style:none;">Service Name&nbsp;&nbsp;<b>' + service.Service__c + '</b></td>';
            emailBody += '<td style="border-style:none;">First Year Value&nbsp;&nbsp;<b>$ ' + (service.First_Year_Value__c).format() + '</b></td>';
            emailBody += '<td style="border-style:none;">Eligible Participants/Units&nbsp;&nbsp;<b>' + service.Eligible_Participants_Units__c + '</b></td>';
            emailBody += '</tr><tr>';
            //Case 110757. Chintan, January 30, 2014
            if (myProposal.Type__c.contains('RPO')) {
                Datetime serviceEndDate = (service.Service_End_Date__c != null) ? Datetime.newInstance(service.Service_End_Date__c.year(), service.Service_End_Date__c.month(), service.Service_End_Date__c.day()) : null;
                emailBody += '<td style="border-style:none; background-color:' + light + ';">Service Start Date&nbsp;&nbsp;<b>' + (serviceStartDate != null ? serviceStartDate.format('MMM dd, yyyy') : '&nbsp;') + '</b></td>';
                emailBody += '<td style="border-style:none; background-color:' + light + ';">Platform&nbsp;&nbsp;<b>' + (service.Platform__c != null ? service.Platform__c : '') + '</b></td>';
                emailBody += '<td style="border-style:none; background-color:' + light + ';">Type&nbsp;&nbsp;<b>' + service.Type__c + '</b></td>';
                emailBody += '</tr><tr>';
                emailBody += '<td style="border-style:none; border-bottom:1px solid black;">Service End Date&nbsp;&nbsp;<b>' + (serviceEndDate != null ? serviceEndDate.format('MMM dd, yyyy') : '&nbsp;') + '</b></td>';
                emailBody += '<td style="border-style:none; border-bottom:1px solid black;">&nbsp;</td>';
                emailBody += '<td style="border-style:none; border-bottom:1px solid black;">&nbsp;</td>';
                emailBody += '</tr>';
            } else {
                emailBody += '<td style="border-style:none; border-bottom:1px solid black; background-color:' + light + ';">Service Start Date&nbsp;&nbsp;<b>' + (serviceStartDate != null ? serviceStartDate.format('MMM dd, yyyy') : '&nbsp;') + '</b></td>';
                emailBody += '<td style="border-style:none; border-bottom:1px solid black; background-color:' + light + ';">Platform&nbsp;&nbsp;<b>' + (service.Platform__c != null ? service.Platform__c : '') + '</b></td>';
                emailBody += '<td style="border-style:none; border-bottom:1px solid black; background-color:' + light + ';">Type&nbsp;&nbsp;<b>' + service.Type__c + '</b></td>';
                emailBody += '</tr>';
            }
        }
        emailBody += '<tr>';
        emailBody += '<td style="border-style:none; background-color:' + dark + ';" colspan="3">Key Contacts</td>';
        emailBody += '</tr><tr>';
        emailBody += '<td style="border-style:none;">Account Executive&nbsp;&nbsp;<b>' + myProposal.Account_Executive__r.Name + '</b></td>';
        emailBody += '<td style="border-style:none;">Sales Manager&nbsp;&nbsp;<b>' + (myProposal.Sales_Manager__r.Name != null ? myProposal.Sales_Manager__r.Name : '') + '</b></td>';
        emailBody += '<td style="border-style:none;">Sales Executive&nbsp;&nbsp;<b>' + myProposal.Sales_Executive__r.Name + '</b></td>';
        emailBody += '</tr><tr>';
        emailBody += '<td style="border-style:none; background-color: ' + light + ';">Sales Bid Manager&nbsp;&nbsp;<b>' + (myProposal.Sales_Bid_Manager__r.Name != null ? myProposal.Sales_Bid_Manager__r.Name : '') + '</b></td>';
        emailBody += '<td style="border-style:none; background-color: ' + light + ';">Proposal Writer&nbsp;&nbsp;<b>' + (myProposal.Proposal_Writer__r.Name != null ? myProposal.Proposal_Writer__r.Name : '') + '</b></td>';
        emailBody += '<td style="border-style:none; background-color: ' + light + ';">N&C&nbsp;&nbsp;<b>' + (myProposal.N_C__r.Name != null ? myProposal.N_C__r.Name : '') + '</b></td>';
        emailBody += '</tr><tr>';
        emailBody += '<td style="border-style:none;">Finance&nbsp;&nbsp;<b>' + (myProposal.Finance__r.Name != null ? myProposal.Finance__r.Name : '') + '</b></td>';
        emailBody += '<td style="border-style:none;">Solution Architect&nbsp;&nbsp;<b>' + (myProposal.Solution_Architect__r.Name != null ? myProposal.Solution_Architect__r.Name : '') + '</b></td>';
        emailBody += '<td style="border-style:none;">General Counsel/Contracts&nbsp;&nbsp;<b>' + (myProposal.General_Counsel_Contracts__r.Name != null ? myProposal.General_Counsel_Contracts__r.Name : '') + '</b></td>';
        emailBody += '</tr><tr>';
        emailBody += '<td style="border-style:none; background-color: ' + light + ';">Production Assistant&nbsp;&nbsp;<b>' + (myProposal.Production_Assistant__r.Name != null ? myProposal.Production_Assistant__r.Name : '') + '</b></td>';
        emailBody += '<td style="border-style:none; background-color: ' + light + ';">Other Interested Stakeholders&nbsp;&nbsp;<b>' + (myProposal.Other_Interested_Stakeholders__c != null ? myProposal.Other_Interested_Stakeholders__c : '') + '</b></td>';
        emailBody += '<td style="border-style:none; background-color: ' + light + ';">&nbsp;&nbsp;</td>';
        emailBody += '</tr></table>';
        
        //return
        return emailBody;
    } //getEmailBody    
}