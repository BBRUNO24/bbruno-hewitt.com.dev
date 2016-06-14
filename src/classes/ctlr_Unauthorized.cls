public with sharing class ctlr_Unauthorized {
	
	public ctlr_Unauthorized() {
		System.debug('dumping page headers...');
		for (String key : ApexPages.currentPage().getHeaders().keySet()) {
			System.debug(key + ': ' + ApexPages.currentPage().getHeaders().get(key));
		}		
	}
	
	static testMethod void MyTestMethod() {
		ctlr_Unauthorized controller = new ctlr_Unauthorized();
	}
}