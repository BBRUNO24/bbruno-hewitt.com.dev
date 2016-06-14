public class RestrictInternalAcntTeamDeletionClass
{
	/** Verifies the user's permission to delete specific Internal Account Team Roles
	 * Chintan Adhyapak, August 30, 2011
	 */
	public static void restrictIntAcntTeam(Internal_Account_Team__c[] internalAccountTeamList) {
		//Read custom setting that stores delete permissions
		InternalAccountTeamDeleteAccess__c iatAccess = InternalAccountTeamDeleteAccess__c.getInstance();
		
		//Read custom setting that stores the list of financial roles 
		List<FinancialRoles__c> financialRoles = [SELECT Name FROM FinancialRoles__c];
		System.debug('CHINTAN Financial Role Read: ' + financialRoles);

		//Create a Set for easy comparison
		Set<String> financialRolesSet = new Set<String>{};
		for (FinancialRoles__c role : financialRoles)
			financialRolesSet.add(role.Name);
		
		//Read custom setting to read protected roles
		List<ProtectedRoles__c> protectedRoles = [SELECT Name FROM ProtectedRoles__c];
		System.debug('CHINTAN Protected Role Read: ' + protectedRoles);

		//Create a Set for easy comparison
		Set<String> protectedRolesSet = new Set<String>{};
		for (ProtectedRoles__c role : protectedRoles)
			protectedRolesSet.add(role.Name);
		
		//loop through incoming records
		for(Internal_Account_Team__c iat : internalAccountTeamList) {
			System.debug('CHINTAN Attempting to Delete Role ' + iat.Contact_Role__c);
			//Check if user has permission to delete a financial role
			if (financialRolesSet.contains(iat.Contact_Role__c) && !iatAccess.Can_Delete_Financial_Roles__c) {
				iat.addError('You do not have permission to delete this record.');
			}
			//Check if user has permission to delete Account Owner and Executive Sponsor roles
			if (protectedRolesSet.contains(iat.Contact_Role__c) && !iatAccess.Can_Delete_Owner_Exec_Sponsor__c) {
				iat.addError('You do not have permission to delete this record.');
			}
		}
	} //restrictIntAcntTeam    
}