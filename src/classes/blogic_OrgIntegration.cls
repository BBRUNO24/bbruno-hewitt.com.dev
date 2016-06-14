public class blogic_OrgIntegration {

	public static void severSharedAccountRelationshipsWithSourceOrg(List <Account> newAccounts) {
		
		List <PartnerNetworkRecordConnection> bondsToBreak = new List <PartnerNetworkRecordConnection>();
		List <Org_Integration_Record_Correlation__c> correlationsToStore = new List <Org_Integration_Record_Correlation__c>();
		Set <String> idsOfBondsToBreak = new Set<String>();
		
		// iterate over the inbound accounts and look for any that need their source org relationship cut
		System.debug('looking for any ARS-sourced accounts that need to have their relationships cut...');
		for (Account account : newAccounts) {
			if (account.ConnectionReceivedId != null) {
				idsOfBondsToBreak.add(account.Id);
			}
		}
		System.debug('identified ' + idsOfBondsToBreak.size() + ' records to delete: ' + idsOfBondsToBreak);
		
		// retrieve source connections for any shared records
		System.debug('retrieving shares to delete...');
		bondsToBreak = [select id, LocalRecordId, PartnerRecordId from PartnerNetworkRecordConnection where LocalRecordId IN :idsOfBondsToBreak];
		System.debug('retrieved ' + bondsToBreak.size() + ' records: ' + bondsToBreak);
		
		// before we break the bond, we store the relationship so that it can be processed
		for (PartnerNetworkRecordConnection bond : bondsToBreak) {
			correlationsToStore.add(new Org_Integration_Record_Correlation__c(Local_Record_Id__c = bond.LocalRecordId, Remote_Record_Id__c = bond.PartnerRecordId));
		}
		
		// store the correlations
		System.debug('storing correlations...');
		insert correlationsToStore;
		System.debug('correlations stored');
		
		// delete any collected records
		System.debug('deleting records...');
		delete bondsToBreak;
		System.debug('records deleted');
	}

}