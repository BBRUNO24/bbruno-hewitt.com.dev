public class AccountTeam {
	public AccountTeam() {}
	public AccountTeam(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap) {
		this.oldMap = oldMap;
		this.newMap = newMap;
	}
	public static final String CONTACT_ROLE = 'Business Developer';
	public static final Set<String> REGIONS = new Set<String>{'Africa', 'Greater China', 'India', 'Pacific', 'Japan', 'Korea', 'South East Asia', 'Middle East'};
	
    public Map<String, Set<String>> internalContactMap {get; set;}
	public Map<Id, Opportunity> oldMap {get; set;}
	public Map<Id, Opportunity> newMap {get; set;}
	public Map<String, String> opportunityRegionMap {get; set;}

	private List<Internal_Account_Team__c> internalContactsToCreate {get; set;}
	private List<Opportunity> opptysToProcess {get; set;}

	public static void updateAccountTeamMembers(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap){
		AccountTeam controller = new AccountTeam(oldMap, newMap);

    	//Populate the region map
		controller.populateRegionMap();

		//Find the opprtys where the owner
    	Set<String> opptyIdsChanged = controller.findOwnersWhoChanged();

    	//early return
    	if(opptyIdsChanged.size() == 0) return;
    	controller.populateContactMap(opptyIdsChanged);
    	controller.processRecords(opptyIdsChanged);
    	controller.createTeamMembers(opptyIdsChanged);
    }

    private void createTeamMembers(Set<String> opptyIds){
    	if(this.opptysToProcess.size() > 0){
    		Map<String, Contact> contactMap = getInternalContactMap( getOwnerIdsFromChangedOpptys(opptyIds) );
    		for(Opportunity o : opptysToProcess){
    			internalContactsToCreate.add(create(o, contactMap));
    		}
    	}
    	if(internalContactsToCreate.size() > 0){
    		List<Database.SaveResult> srs = Database.insert(internalContactsToCreate);
    		for(Database.SaveResult sr : srs ){
    			if(sr.isSuccess()){

				}else{
					System.debug('Internal err');
					System.debug(sr.getErrors());	
				}
    		}
    	}
    }

    private void populateRegionMap(){
    	this.opportunityRegionMap = new Map<String, String>();
    	List<Opportunity> opptys = [SELECT Id, Account.Region__c FROM Opportunity WHERE Id IN :newMap.keySet()];
    	for(Opportunity o : opptys){
    		if(o.Account.Region__c != null){
    			this.opportunityRegionMap.put(o.Id, o.Account.Region__c);
    		}
    	}
    }

    private Internal_Account_Team__c create(Opportunity opp, Map<String, Contact> contactMap){
    	Internal_Account_Team__c iat = new Internal_Account_Team__c();
    	iat.Account__c = opp.AccountId;
    	iat.Contact_Role__c = AccountTeam.CONTACT_ROLE;
    	if(contactMap.containsKey(opp.OwnerId)){
    		iat.Contact__c = contactMap.get(opp.OwnerId).Id;
    	}
    	return iat;
    }

    private Map<String, Contact> getInternalContactMap(Set<String> ownerIds){
    	Map<String, Contact> internalContacts = new Map<String, Contact>();
    	List<String> owners = new List<String>();
    	owners.addALl(ownerIds);
    	String query = 'SELECT Id, Corresponding_User_Id__c FROM Contact WHERE Corresponding_User_Id__c IN :owners';

    	List<Contact> contacts = Database.query(query);
    	for(Contact c : contacts){
    		internalContacts.put(c.Corresponding_User_Id__c, c);
    	}
    	return internalContacts;
    }

    private void processRecords(Set<String> opptyIds){
    	this.internalContactsToCreate = new List<Internal_Account_Team__c>();
    	this.opptysToProcess = new List<Opportunity>();
    	for(String s : opptyIds){
    		if(newMap.containsKey(s)){
    			Opportunity opp = newMap.get(s);
    			if(opp.AccountId != null){
    				Boolean doesExist = doesAccountTeamMemberExistForOwner(opp.AccountId, opp.ownerId);
    				if(!doesExist){
    					createAccountTeamMember(opp);
    				}
    			}
    		}
    	}
    }

    private void createAccountTeamMember(Opportunity opp){
    	addOwnerToAccountMapToPreventDupes(opp.AccountId, opp.ownerId);
    	opptysToProcess.add(opp);
    }

     private void addOwnerToAccountMapToPreventDupes(String acctId, String ownerId){
    	if(internalContactMap.containsKey(acctId)){
    		internalContactMap.get(acctId).add(ownerId);
    	}else{
    		internalContactMap.put(acctId, new Set<String>{ownerId});
    	}
    }

    private Boolean doesAccountTeamMemberExistForOwner(String acctId, String ownerId){
    	if(internalContactMap.containsKey(acctId)){
    		Set<String> acctTeamMemberIds = internalContactMap.get(acctId);
    		return acctTeamMemberIds.contains(ownerId);
    	}else{
    		return false;
    	}
    }

    private void populateContactMap(Set<String> opptyIds){
    	this.internalContactMap = new Map<String, Set<String>>();
    	List<Internal_Account_Team__c> internalContacts = (List<Internal_Account_Team__c>)getContactQuery(opptyIds);
    	for(Internal_Account_Team__c iat : internalContacts){
    		addContactToContactMap(iat);
    	}
    }

    private List<SObject> getContactQuery(Set<String> opptyIds){
    	List<String> ownerIds = new List<String>();
    	List<String> acctIds = new List<String>();
    	ownerIds.addAll(getOwnerIdsFromChangedOpptys(opptyIds));
    	acctIds.addAll(getAccountIdsFromChangedOpptys(opptyIds));
        System.debug('OwnerIds Size: '+ownerIds.size());
        System.debug('acctIds Size: '+acctIds.size());

    	String query = 'SELECT Id, Contact__r.Corresponding_User_Id__c, Account__c FROM Internal_Account_Team__c ';
    	query+=' WHERE Contact__r.Corresponding_User_Id__c IN :ownerIds';
    	query+=' AND Account__c IN :acctIds';
    	System.debug('Query: '+query);
    	return Database.query(query);
    }

    private void addContactToContactMap(Internal_Account_Team__c iat){
    	if(iat.Account__c != null){
    		if(internalContactMap.containsKey(iat.Account__c)){
    			internalContactMap.get(iat.Account__c).add(iat.Contact__r.Corresponding_User_Id__c);
    		}else{
    			internalContactMap.put(iat.Account__c, new Set<String>{iat.Contact__r.Corresponding_User_Id__c});
    		}
    	}
    }

    private Set<String> getOwnerIdsFromChangedOpptys(Set<String> changedOpptyIds){
    	Set<String> ownerIds = new Set<String>();
    	for(String s : changedOpptyIds){
    		if(newMap.containsKey(s)){
    			Opportunity opp = newMap.get(s);
    			ownerIds.add(opp.OwnerId);
    		}
    	}
    	return ownerIds;
    }

    private Set<String> getAccountIdsFromChangedOpptys(Set<String> changedOpptyIds){
    	Set<String> acctIds = new Set<String>();
    	for(String s : changedOpptyIds){
    		if(newMap.containsKey(s)){
    			Opportunity opp = newMap.get(s);
    			if(opp.AccountId != null){
    				acctIds.add(opp.AccountId);
    			}
    		}
    	}

    	return acctIds;
    }

    private Boolean isInApplicableRegion(String opptyId){
    	Opportunity opp = newMap.get(opptyId);
    	return opportunityRegionMap.containsKey(opptyId) && AccountTeam.REGIONS.contains( opportunityRegionMap.get(opptyId) );
    }

    private Set<String> findOwnersWhoChanged(){
    	Set<String> ids = new Set<String>();
    	for(Id i : newMap.keySet()){
    		if( isInApplicableRegion(i) && didOwnerChange(i) ){
    			ids.add(i);
    		}
    	}
    	return ids;
    }

    private Boolean didOwnerChange(String opptyId){
    	if(oldMap == null){
    		return true;
    	}else{
    		return oldMap.get(opptyId).OwnerId != newMap.get(opptyId).OwnerId;
    	}
    }
}