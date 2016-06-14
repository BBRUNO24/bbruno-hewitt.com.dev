/** 
*This class is created to achieve requirement of #00014300 Display Lead and Cntact Records on home page
*The conroller methods are getting call from VF page to show the Lead or contact data
*Created By- VinodK. 07/30/2012
**/

public class ctlr_LeadandContactHomePage {   
        
    List<Marketing_Lead__c> newerleads;
    List<Marketing_Lead__c> olderleads;
    List<Contact> activecontacts;
    
//Getting date of last 90th day        
    Date LastDate(){        
        Date dttoday = System.today();
        system.debug('Date before'+dttoday);
        dttoday = dttoday-90;
        return dttoday;        
    }

//Fetching Lead records within last 90 days
    public List<Marketing_Lead__c> getNewerLeads(){        
        date dtlastdate = LastDate();        
        if(newerleads == null) newerleads = [select name, Contact__r.Full_Name__c,status__c,Marketing_Campaign_Source__c, Marketing_Campaign_Source__r.Name    from Marketing_Lead__c where createddate >: dtlastdate  and ownerid =: UserInfo.getUserId() and (Status__c=:'Open' or Status__c=: 'In Progress (Contacted)'or Status__c=:'Nurture') order by createddate ASC  limit 5];        
        return newerleads;
    }

//Fetching Lead records before last 90 days
    public List<Marketing_Lead__c> getOlderLeads(){        
        date dtlastdate = LastDate();        
        if(olderleads == null) olderleads  = [select name, Contact__r.Full_Name__c,status__c, Marketing_Campaign_Source__c, Marketing_Campaign_Source__r.Name    from Marketing_Lead__c where createddate <: dtlastdate and ownerid =: UserInfo.getUserId() and (Status__c=:'Open' or Status__c=: 'In Progress (Contacted)'or Status__c=:'Nurture') order by createddate ASC  limit 5];        
        return olderleads ;
    }
    

//Fetching Active Contact records
    public List<Contact> getActiveContacts(){  
        if(activecontacts== null) activecontacts = [select name, accountid,Account.name from contact where Contact_Review__c =: TRUE and ownerid =: UserInfo.getUserId()and Contact_Status__c=: 'Active'  limit 5];
        return activecontacts ;
    }
//Logic to hide/unhide the Newer Lead        
    public boolean getShowNewLeadTable(){
        boolean ShowNewLeadTable= true;
        if(getNewerLeads().size() == 0){
            ShowNewLeadTable = false;
        }
        return ShowNewLeadTable;
    }
//Method to show message if no new Lead existing        
    public boolean getnewleadmessage (){
        boolean newleadmessage = false;
        if(getNewerLeads().size() == 0){
            newleadmessage = true;
        }
        return newleadmessage ;
    }
 //Logic to hide/unhide the older Lead       
    public boolean getShowoldLeadTable(){
        boolean ShowoldLeadTable = true;
        if(getolderLeads().size() == 0){
            ShowoldLeadTable = false;
        }
        return ShowoldLeadTable;
    }
 //Method to show message if no old Lead existing       
    public boolean getoldleadmessage (){
        boolean oldleadmessage= false;
        if(getolderLeads().size() == 0){
            oldleadmessage= true;
        }
        return oldleadmessage;
    }
//Logic to hide/unhide the active contact data        
    public boolean getshowActiveContacts(){
        boolean showActiveContacts = true;
        if(getActiveContacts().size() == 0){
            showActiveContacts = false;
        }
        return showActiveContacts;
    }
 //Method to show message if no active contact existing    
    public boolean getcontactmessage (){
        boolean contactmessage= false;
        if(getActiveContacts().size() == 0){
            contactmessage= true;
        }
        return contactmessage;
    }
        

}