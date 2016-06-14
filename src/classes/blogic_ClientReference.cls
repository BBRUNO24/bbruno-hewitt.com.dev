//Created by DaveM This code will send emails as various Client Reference Request fields are completed
Public class blogic_ClientReference
{
    
    public static void SendClientRefRequestEmails(List<Client_Reference__c> newRequestlist, List<Client_Reference__c> oldRequestlist)
    {
        //Get global Client Reference Settings
        ClientReference__c CRSettings = ClientReference__c.getInstance();

        //Build lists of opportunities and accounts used for the updated client reference records
        set<Id> oppIDs = new set<Id>();
        set<Id> acctIDs = new set<Id>();
        set<Id> userIDs = new set<Id>();
        List<String> toEmails = new List<String>();

        for(Client_Reference__c clientreference : newRequestlist){
            oppIDs.add(clientreference.Opportunity__c);
            acctIDs.add(clientreference.Account__c);
            //userIDs.add(clientreference.Opportunity__r.ReferenceRequestUser__c);
        }

        //Build a map of opportunity and account data
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([SELECT Id, Name, Owner.ID, Owner.Name, Owner.email, account.name, account.industry, account.NumberOfEmployees, account.billingstate, account.billingcountry, ReferenceRequestUser__c, ReferenceRequestUser__r.Id, ReferenceRequestContact__c, ReferenceRequestEstimateDate__c, ReferenceRequestServices__c FROM Opportunity WHERE Id IN :oppIds]);
        Map<Id, Account> acctMap = new Map<Id, Account>([SELECT Id, Owner.ID, Name FROM Account WHERE Id IN :acctIds]);
        //Map<ID, User> userMap = new Map<ID, User>([select ID, name, email from user where id in :userIds]);
        Map<ID, List< Internal_Account_Team__c>> acctemailsMap = new Map<ID, List< Internal_Account_Team__c>>();
        for(account iaccount :[SELECT Id, (SELECT Contact__r.ID, Contact__r.corresponding_user_email__c, Contact__r.email  FROM Internal_Account_Team__r where (Contact_Role__c = 'Benefits Delivery Manager' or Contact_Role__c = 'Client Service Executive')) FROM Account WHERE Id IN :acctIds]) {
            acctemailsMap.put(iaccount.Id, iaccount.Internal_Account_Team__r);
        }

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        //For each updated client request
        for(integer i=0; i < newRequestlist.size();i++) {

            //Get the current opportunity and account and accountemails
            Opportunity currOpp = oppMap.get(newRequestlist[i].opportunity__c);
            Account currAccount = acctMap.get(newRequestlist[i].account__c);
            //User currUser = userMap.get(curropp.ReferenceRequestUser__c);
            system.debug(logginglevel.ERROR,'UserID');
            system.debug(logginglevel.ERROR,currOpp.ReferenceRequestUser__c);

            system.debug(logginglevel.error,currOpp.ReferenceRequestUser__c);
            Internal_Account_Team__c[] internalemails = acctemailsMap.get(currAccount.id);

            //If the request for approval box is checked and was not previously
            if(newRequestlist[i].Request_Approval__c && !oldRequestlist[i].Request_Approval__c){
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setTemplateId(CRSettings.ApprovalEmailTemplate__c);
                email.setTargetObjectID(currAccount.Owner.ID);
//               email.setTargetObjectID('005f00000011Qn6');  // For Testing
                toEmails.add(string.valueof('aonhewitt.salesandclientmanagement.references@aonhewitt.com'));
                if (internalemails.size() > 0) {
                    for(Internal_Account_Team__c iat : internalemails ){
                        if (!string.isempty(string.valueof(iat.Contact__r.corresponding_user_email__c))){
                            toEmails.add(string.valueof(iat.Contact__r.corresponding_user_email__c));
                            system.debug(logginglevel.ERROR,'UserID');
                            system.debug(logginglevel.ERROR,iat.Contact__r.corresponding_user_email__c);
                        }
                        else if (!string.isempty(string.valueof(iat.Contact__r.email))) {
                            toEmails.add(string.valueof(iat.Contact__r.email));
                            system.debug(logginglevel.ERROR,'UserID');
                            system.debug(logginglevel.ERROR,iat.Contact__r.email);
                        }
                    }
//                    email.setToAddresses(new String[] { 'dmcchristie@rightpoint.com'});  // For Testing
                    if(toemails.size() > 0 ) {
                        email.setToAddresses(toEmails);    
                    }
                }
                email.setsaveAsActivity(FALSE);
                email.setwhatid(newRequestlist[i].id);
                email.setOrgWideEmailAddressId(CRSettings.ReplyOrgAddress__c);    
                emails.add(email);

            //Otherwise if approved is checked
            } else if(newRequestlist[i].Approved__c && !oldRequestlist[i].Approved__c){
                //Send the approved email to the requesting user
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setTemplateId(CRSettings.ApprovedEmailTemplate__c);
                
                email.setTargetObjectID(currOpp.ReferenceRequestUser__c);
//                email.setTargetObjectID('005f00000011Qn6');   // For Testing
                email.setsaveAsActivity(FALSE);
                email.setwhatid(newRequestlist[i].id);
                email.setOrgWideEmailAddressId(CRSettings.ReplyOrgAddress__c);
                emails.add(email);

            //Otherwise if denied is checked
            } else if(newRequestlist[i].Denied__c && !oldRequestlist[i].Denied__c){
                //Send the denied email to the requesting user
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setTemplateId(CRSettings.DeniedEmailTemplate__c);
                email.setTargetObjectID(currOpp.ReferenceRequestUser__c);
//                email.setTargetObjectID('005f00000011Qn6');   // For Testing
                email.setsaveAsActivity(FALSE);
                email.setwhatid(newRequestlist[i].id);
                email.setOrgWideEmailAddressId(CRSettings.ReplyOrgAddress__c);
                emails.add(email);
            }
        }
        
        // If we have any emails to send, send them
        if(!emails.isEmpty() && !Test.isRunningTest()){
            Messaging.sendEmail(emails);
        }
    }    
}