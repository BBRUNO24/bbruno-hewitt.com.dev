public class closedApprovedProd_Edit_Del {

	public OpportunityLineItem oppLI {get;set;}
	public Boolean closedApprovedCheck {get;set;}
	private Id oppId {get;set;} 

    /********************************************************************************
							CONSTRUCTOR
	********************************************************************************/
	public closedApprovedProd_Edit_Del (ApexPages.StandardController controller) 
	{           
     			this.oppLI = [select id, OpportunityId, Opportunity.StageName from OpportunityLineItem where id =:ApexPages.currentPage().getParameters().get('id')];
     			oppId = this.oppLI.OpportunityId;
			     			   			
    }
    /*******************************************************************************/
 
     		
     public PageReference ret()
    	{      		 		
    		PageReference pg1 = new PageReference('/' + oppId);
	    	return pg1;
	    	
    	}
    	  	
    public PageReference del()
    	{   
    		if(this.oppLI.Opportunity.StageName == 'Closed Approved')
 			{
 				closedApprovedCheck = true;
 				return null;				
 			}
 			else 
 			{
 				closedApprovedCheck = false;
 				PageReference pg2 = new PageReference('/setup/own/deleteredirect.jsp?delID=' + oppLI.Id + '&retURL=%2F' +oppId+ '&nooverride=1');	
		    	pg2.setRedirect(true);
		    	return pg2;					
 			} 			

    	}
    	
   	public PageReference edit()
    	{    		
    		if(this.oppLI.Opportunity.StageName == 'Closed Approved')
 			{
 				closedApprovedCheck = true;
 				return null;				
 			}
 			
 			else 
 			{
 				closedApprovedCheck = false;
    			PageReference pg3 = new PageReference('/'+oppLI.Id + '/' + 'e?retURL=%2F' + oppLI.Id + '&nooverride=1');
    			pg3.setRedirect(true);    											  
	    		return pg3;	
 			}    	
    	}
     
     
}