public with sharing class blogic_Lead {
 
 	public static void addCampaignMemberFromEloqua(List<Lead> leadList)
    {
        List<Id> campaignIds = new List<Id>();
        CampaignMember campaignMember;
        List<CampaignMember> campaignMemberList = new List<CampaignMember>();
        List<CampaignMember> campaignMemberToUpdate = new List<CampaignMember>();
        Map<string, CampaignMember> campaignMemberMap = new Map<string, CampaignMember>();
        String contactId;
        String campaignId;
        String key;

        // get Campaign Id's
        for(Lead l : leadList)
        {
            campaignIds.add(l.Eloqua_Campaign_ID__c);
        }
        System.debug('campaignIds: ' + campaignIds);


        // query campaign members
        campaignMemberList = [SELECT Id, CampaignId, ContactId, Eloqua_Prospect_Scoring_Model__c, Prospect_Score__c, Prospect_Score_Date__c FROM CampaignMember WHERE CampaignId IN :campaignIds];
        System.debug('campaignMemberList: ' + campaignMemberList);

        // set Campaign Membe Map
        for (CampaignMember cm : campaignMemberList)
        {
        	if( cm.campaignId != null && cm.contactId != null){
	        	campaignId = (String)cm.CampaignId;
	        	contactId = (String)cm.ContactId;

	            key =  campaignId.substring(0, 15) + contactId.substring(0, 15);
	            campaignMemberMap.put(key , cm);
            }
        }
        System.debug('campaignMemberMap: ' + campaignMemberMap);


        for(Lead l : leadList)
        {
        	if( l.Eloqua_Campaign_Id__c != null && l.Eloqua_contact_ID__c != null){
	        	campaignId = (String)l.Eloqua_Campaign_Id__c ;
	        	contactId = (String)l.Eloqua_contact_ID__c;

	            key = campaignId.substring(0, 15) + contactId.substring(0, 15);
	            campaignMember = campaignMemberMap.get(key);

	            If(campaignMember != null)
	            {
	                System.debug('campaignMember: ' + campaignMember);

	                campaignMember.Prospect_Score__c = l.Prospect_Score__c;
	                campaignMember.Eloqua_Prospect_Scoring_Model__c = l.Eloqua_Prospect_Scoring_Model__c;
	                campaignMember.Prospect_Score_Date__c = l.CreatedDate;

	                campaignMemberToUpdate.add(campaignMember);
	            }
        	}
        }
        System.debug('campaignMemberToUpdate: ' + campaignMemberToUpdate);


        //Insert CampaignMember
        if (campaignMemberToUpdate.size() > 0) {
            try {
                update(campaignMemberToUpdate);
            } catch (System.DmlException e) {
                for (Integer ei = 0; ei < e.getNumDml(); ei++) {
                System.debug(e.getDmlMessage(ei));
                }
            }
        }        
    }


}