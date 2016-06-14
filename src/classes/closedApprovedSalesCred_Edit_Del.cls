public class closedApprovedSalesCred_Edit_Del {
    
    public Sales_Credit__c sCred {get;set;}
    public Boolean closedApprovedCheck {get;set;}
    private Id oppId {get;set;}
    private ClosedOpptyUserAccess__c opptyAccess {get;set;} 

    /********************************************************************************
                            CONSTRUCTOR
    ********************************************************************************/
    public closedApprovedSalesCred_Edit_Del (ApexPages.StandardController controller) 
    {           
        this.sCred = [Select Related_Opportunity__r.StageName, Related_Opportunity__c, Id From Sales_Credit__c where id =:ApexPages.currentPage().getParameters().get('id')];
        oppId = this.sCred.Related_Opportunity__c;
        this.opptyAccess = ClosedOpptyUserAccess__c.getInstance();
                                        
    }
    /*******************************************************************************/
 
            
     public PageReference ret()
        {                   
            PageReference pg1 = new PageReference('/' + sCred.Related_Opportunity__c);
            return pg1;
            
        }
            
    public PageReference del()
        {   
            if((this.sCred.Related_Opportunity__r.StageName == 'Closed Approved') && (!this.opptyAccess.Can_Delete_Sales_Credits__c))
            {
                closedApprovedCheck = true;
                return null;                
            }
            else 
            {
                closedApprovedCheck = false;
                /*PageReference pg2 = new PageReference('/setup/own/deleteredirect.jsp?delID=' + sCred.Id + '&retURL=%2F' +oppId+ '&nooverride=1');   
                pg2.setRedirect(true);
                return pg2;*/                 
                //00117482-Ritu Sharma-Commented the above code and added new logic to delete the record
                delete this.sCred;
                return ret();  
            }           

        }
                
    public PageReference edit()
        {           
            if((this.sCred.Related_Opportunity__r.StageName == 'Closed Approved') && (!this.opptyAccess.Can_Edit_Sales_Credits__c))
            {
                closedApprovedCheck = true;
                return null;                
            }
            
            else 
            {
                closedApprovedCheck = false;
                PageReference pg3 = new PageReference('/'+sCred.Id + '/' + 'e?retURL=%2F' + sCred.Id + '&nooverride=1');
                pg3.setRedirect(true);                                                
                return pg3; 
            }       
        }
     
     
}