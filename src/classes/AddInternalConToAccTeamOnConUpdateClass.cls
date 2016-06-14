public class AddInternalConToAccTeamOnConUpdateClass 
{
    public static void addInternalContact()
    {
        Contact[] newContactList = (Contact[])Trigger.new;
        Contact[] oldContactList = (Contact[])Trigger.old;     
         
        List<Contact> updatedContactList = new List<Contact>();
        List<Contact> inactiveContactList = new List<Contact>();
        List<Internal_Account_Team__c> internalAccTeamList = new List<Internal_Account_Team__c>();
        List<Internal_Account_Team__c> deleteInternalAccTeamList = new List<Internal_Account_Team__c>();
        List<AccountTeamMember> accTeamMemberList = new List<AccountTeamMember>();
        List<AccountShare> acntShareList = new List<AccountShare>();
    
        //THIS LIST GATHERS ALL THE NEW ACCOUNT IDS AND USER IDS AND GIVES THEM EDIT ACCESS ON ACCOUNTS,CONTACTS AND OPPORTUNITIES.
        List<String> accountShareAccountId = new List <String>();
        List<String> accountShareUserId = new List <String>();
        
        for(Integer i=0; i<newContactList.size(); i++)
        {
            if(newContactList[i].RecordTypeId == '01230000000mudK' && oldContactList[i].User_ID__c == null && newContactList[i].User_ID__c != null)
            {
                updatedContactList.add(newContactList[i]);
            }
            
            if(newContactList[i].RecordTypeId == '01230000000mudK' && oldContactList[i].Inactive__c == false && newContactList[i].Inactive__c == true)
            {
                inactiveContactList.add(newContactList[i]);
            }
        }
        
        if(updatedContactList.size()>0)
        {
            internalAccTeamList = [select Id,User_ID__c,Account__c from Internal_Account_Team__c where Contact__c in: updatedContactList];
        }
        
        if(inactiveContactList.size()>0)
        {
            deleteInternalAccTeamList = [select Id,User_ID__c,Account__c from Internal_Account_Team__c where Contact__c in: inactiveContactList];
        }
        
        //update internalAccTeamList;
        
        if(internalAccTeamList.size() > 0)
        {
            for(Integer i=0; i<internalAccTeamList.size();i++)
            {           
                 AccountTeamMember accTeamMember = new AccountTeamMember(UserId=internalAccTeamList[i].User_ID__c, AccountId=internalAccTeamList[i].Account__c, TeamMemberRole='Account Team Member');
                 accTeamMemberList.add(accTeamMember);
                 accountShareAccountId.add(internalAccTeamList[i].Account__c);
                 accountShareUserId.add(internalAccTeamList[i].User_ID__c);
            }
        }
        
        if(accTeamMemberList.size()>0)
        {
            System.debug('accTeamMemberList******'+accTeamMemberList);
            insert accTeamMemberList;
        }
        
        //==================THIS CODE BLOCK GIVES EDIT ACCESS TO THE ACCOUNT TEAM MEMBERS============       
        if(accountShareAccountId.size()!=0)
        {         
            /*for(Integer i=0; i<accountShareAccountId.size();i++)
            {
              AccountShare acntShare = new AccountShare();
              acntShare.AccountId = accountShareAccountId[i];
              acntShare.UserOrGroupId = accountShareUserId[i];
           
              acntShare.AccountAccessLevel = 'Edit';
              acntShare.CaseAccessLevel = 'Edit';
              acntShare.OpportunityAccessLevel = 'Edit';
              acntShareList.add(acntShare); //a.ContactAccessLevel, 
            }
            System.debug('acntShareList******'+acntShareList);
            System.debug('acntShareList.size()******'+acntShareList.size());
            if(acntShareList.size()>0)
            {
                try
                {
                    insert acntShareList;
                }
                catch(Exception e){}
            }*/
            
            //---------------
            AccountShare[] accountShareObjects=[Select Id, AccountAccessLevel, ContactAccessLevel, CaseAccessLevel, OpportunityAccessLevel From AccountShare where AccountId IN:accountShareAccountId and UserOrGroupId IN:accountShareUserId];
            System.debug('accountShareObjects.size()******'+accountShareObjects.size());
            if(accountShareObjects.size() > 0)
            {
                System.debug('Inside 2nd ifffff******');
                for(AccountShare accountShareObject:accountShareObjects)
                {
                    accountShareObject.AccountAccessLevel='Edit';                  
                    accountShareObject.OpportunityAccessLevel='Edit';
                    accountShareObject.ContactAccessLevel='Edit';
                }
                System.debug('accountShareObjects******'+accountShareObjects);
                try
                {
                	update accountShareObjects;
                }
                catch(Exception e){}
            } 
        }
        
        if(deleteInternalAccTeamList.size()>0)
        {
            delete deleteInternalAccTeamList;
        }
    }
}