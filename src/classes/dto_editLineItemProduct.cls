public with sharing class dto_editLineItemProduct {
	
	public Opportunity			Opp					{get; set;}
	public OpportunityLineItem 	LineItem			{get; set;}
	public PricebookEntry		Pricebook			{get; set;}
	public List<Product_Field_List__c> FieldList	{get; private set;}
	
	public dto_editLineItemProduct(Opportunity opportunity, OpportunityLineItem lineItem, PricebookEntry pricebook) {
		System.debug(System.LoggingLevel.INFO, 'dto_editLineItemProduct START');
		this.Opp = opportunity;
		this.LineItem = lineItem;
		this.Pricebook = pricebook;
		this.FieldList = getFieldList();
		System.debug(System.LoggingLevel.INFO, 'dto_editLineItemProduct END');
	}	
	
	private List<Product_Field_List__c> getFieldList() {
		// debug
		System.debug(System.LoggingLevel.INFO, '############# getFieldList START ##################');
		System.debug(System.LoggingLevel.INFO, 'Use Product Specific Field List: ' + this.Pricebook.Product2.Use_Product_Specific_Field_List__c);
		
		// declare local vars
		List<Product_Field_List__c> productFieldList = null;
		
		System.debug(System.LoggingLevel.INFO, 'determining the field set to be retrieved...');
		if (this.Pricebook.Product2.Use_Product_Specific_Field_List__c) {
			System.debug(System.LoggingLevel.INFO, 'retrieving product-specific fields...');
			productFieldList = [Select Source_Object__c, Field_Name__c From Product_Field_List__c Where Product_Id__c = :this.Pricebook.Product2Id and source_object__c = 'OpportunityLineItem' and RecordType.Name = 'Edit UI Field' Order By Sort_Order__c];
		} else {
			System.debug(System.LoggingLevel.INFO, 'retrieving non-product-specific fields fields...');
			
			// get handles the the relevant values
			String rtId = this.Opp.RecordTypeId;
			String stage = this.Opp.StageName;
			String service = this.Pricebook.Product2.Service_Classification__c;
			
			System.debug(System.LoggingLevel.INFO, 'Opportunity Record Type: + ' + rtId);
			System.debug(System.LoggingLevel.INFO, 'Opportunity Stage: + ' + stage);
			System.debug(System.LoggingLevel.INFO, 'Product Service Classification: ' + service);
			
			productFieldList = [Select Source_Object__c, Field_Name__c From Product_Field_List__c 
				Where ((Opportunity_Record_Type__c = :rtId) or (Opportunity_Record_Type_Short__c = :rtId)) And Opportunity_Stage__c = :stage And Product_Service_Classification__c = :service and source_object__c = 'OpportunityLineItem' and RecordType.Name = 'Edit UI Field' Order By Sort_Order__c];
		}
		System.debug(System.LoggingLevel.INFO, 'retrieved ' + productFieldList.size() + ' fields: ' + productFieldList);
		
		System.debug(System.LoggingLevel.INFO, '############# getFieldList END ##################');
		return productFieldList;
	}
}