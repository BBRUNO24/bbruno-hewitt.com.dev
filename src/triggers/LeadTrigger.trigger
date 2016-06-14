trigger LeadTrigger on Lead (
	before insert, 
	before update, 
	before delete, 
	after insert, 
	after update, 
	after delete, 
	after undelete) {

		if (Trigger.isBefore) {
	    	//call your handler.before method
	    
		} else if (Trigger.isAfter) {
	    	if(Trigger.isInsert){
	    		blogic_Lead.addCampaignMemberFromEloqua(trigger.new);
	    	}
	    
		}
}