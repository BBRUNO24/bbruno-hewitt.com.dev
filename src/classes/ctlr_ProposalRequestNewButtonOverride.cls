/** Controller That Prepopulates Data on a new Proposal Request Form
  * Case 10167. Chintan Adhyapak. September 10, 2012 */
public with sharing class ctlr_ProposalRequestNewButtonOverride {
    /* class attributes */
    public String oppId         {get;set;}
    public String errorMessage  {get; set;}
    
    /* constructor */
    public ctlr_ProposalRequestNewButtonOverride(ApexPages.StandardController controller) {
        //String myOppId = ApexPages.currentPage().getParameters().get('retURL');
        this.oppId = ((Proposal_Request__c)controller.getRecord()).Opportunity__c;
        this.errorMessage = '';
    } //constructor
    
    
    /* action method */
    public PageReference init() {
        //Local vars
        PageReference redirect = null;
        Account myProvider = null;
        Proposal_Request_Field_ID__c fieldIds = Proposal_Request_Field_ID__c.getInstance();
        
        //Read Data
        //00077996-Ritu-Added Sourcing Provider to the SOQL query
        Opportunity myOpp = [Select Id, Name, StageName, Bundled_Opportunity__c, Opportunity.Account.Id, Opportunity.Account.OwnerId,Sourcing_Provider__c from Opportunity Where Id = :oppId];
        System.debug('CPA myOpp is: ' + myOpp);
        
        //Return if Bundled Opp
        if (myOpp.Bundled_Opportunity__c) {
            errorMessage = 'A Proposal Request cannot be created on a Bundled Opportunity. Please create this request on the Lead Opportunity. Contact your local Sales Operations team for further assistance.'; 
            return redirect; 
        }
        
        //00077630-Ritu-Commented the code as now user can create proposal requests for all opps(except bundled) irrespective of the stage
        //Return if Opp Stage not at least Propose Solution
        /*if (myOpp.StageName == 'Non-Qualified Opportunity' || myOpp.StageName == 'Qualify Opportunity') {
            errorMessage = 'The Opportunity must have reached the Propose Solution stage in order for the request to be submitted.';
            return redirect;
        }*/
        
        User currUser = [Select Id, Name from User Where Id = :UserInfo.getUserId()];
        User accountExec = [Select Id, Name from User Where Id = :myOpp.Account.OwnerId];
        Account myAccount = [Select Id, Name from Account Where Id = :myOpp.AccountId];
        //00077996-Ritu-Handle of Sourcing Provider
        if (myOpp.Sourcing_Provider__c!=Null)
            myProvider = [Select Id, Name from Account Where Id = :myOpp.Sourcing_Provider__c]; 
        
        //Create the URL String
        String objPrepend = Schema.getGlobalDescribe().get('Proposal_Request__c').getDescribe().getKeyPrefix();
        String retUrl = '/' + objPrePend + '/e?CF' + fieldIds.Opportunity__c + '=' + EncodingUtil.urlEncode(myOpp.Name, 'UTF-8') + '&CF' + fieldIds.Opportunity__c + '_lkid=' + myOpp.Id;
        retUrl += '&CF' + fieldIds.Requestor__c + '=' + EncodingUtil.urlEncode(currUser.Name, 'UTF-8') + '&CF' + fieldIds.Requestor__c+ '_lkid=' + currUser.Id;
        retUrl += '&CF' + fieldIds.Account_Executive__c + '=' + EncodingUtil.urlEncode(accountExec.Name, 'UTF-8') + '&CF' + fieldIds.Account_Executive__c +'_lkid=' + accountExec.Id;
        retUrl += '&CF' + fieldIds.Account__c + '=' + EncodingUtil.urlEncode(myAccount.Name, 'UTF-8') + '&CF' + fieldIds.Account__c + '_lkid=' + myAccount.Id;
        //00077996-Ritu-Passing value of Sourcing Provider field through URL
        if (myOpp.Sourcing_Provider__c!=Null)
            retUrl += '&CF' + fieldIds.Third_Party_Advisors_Involved__c + '=' + EncodingUtil.urlEncode(myProvider.Name, 'UTF-8')+ '&CF' + fieldIds.Third_Party_Advisors_Involved__c + '_lkid=' + myProvider.Id;
        
        retUrl += '&nooverride=1&retURL=%2F' + myOpp.Id;
        System.debug('CHINTAN returning URL: ' + retUrl);

        //Create PageReference
        redirect = new PageReference(retUrl);
        redirect.setRedirect(true);
        
        return redirect;
    } //init
    
    /** Return to Opportunity */
    public PageReference returnBack() {
        PageReference redirect = new PageReference('/' + oppId);
        redirect.setRedirect(true);
        
        return redirect;
    } //returnBack
}