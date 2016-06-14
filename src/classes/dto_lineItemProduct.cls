public with sharing class dto_lineItemProduct {
	public Opportunity							Opp				{get; set;}
	public OpportunityLineItem 					LineItem		{get; set;}
	public PricebookEntry						Pricebook		{get; set;}
	public Product2								Product			{get; set;}
	public List<Product_Field_List__c>			FieldList		{get; set;}
	
	public dto_lineItemProduct(Opportunity opportunity, OpportunityLineItem lineItem, PricebookEntry pricebook, Product2 product, List<Product_Field_List__c> initialProductFieldList) {
		this.Opp = opportunity;
		this.LineItem = lineItem;
		this.Pricebook = pricebook;
		this.Product = product;
		this.FieldList = determineFinalFieldList(initialProductFieldList);
	}	
	
	private List<Product_Field_List__c> determineFinalFieldList(List<Product_Field_List__c> initialFieldList) {
		System.debug('############# getFieldList START ##################');
		System.debug('Use Product Specific Field List: ' + Product.Use_Product_Specific_Field_List__c);
		
		// declare local vars
		List<Product_Field_List__c> finalFieldList = new List<Product_Field_List__c>();
		
		List<Product_Field_List__c> productFieldList = null;
		if (Product.Use_Product_Specific_Field_List__c) {
			System.debug('ProductId: ' + this.Product.Id);
		
			// filter the received list by product service classification 
			for (Product_Field_List__c productField : initialFieldList) {
				System.debug('evaluating: ' + productField);
				if ((productField.Product_Id__c != null) && (productField.Product_Id__c.equalsIgnoreCase(this.Product.Id))) {
					finalFieldList.add(productField);
				}
			}
		} else {
			System.debug('Opportunity Record Type: + ' + Opp.RecordTypeId);
			System.debug('Opportunity Stage: + ' + Opp.StageName);
			System.debug('Product Service Classification: ' + Product.Service_Classification__c);
			
			// filter the received list by product service classification 
			for (Product_Field_List__c productField : initialFieldList) {
				if ((productField.Product_Service_Classification__c != null) && (productField.Product_Service_Classification__c.equalsIgnoreCase(this.Product.Service_Classification__c))) {
					finalFieldList.add(productField);
				}
			}
		}
		
		if (productFieldList == null) {
			System.debug('productFieldList is NULL');
		} else {
			System.debug('There were ' + productFieldList.size() + ' fields returned.');
		}
		
		System.debug('############# getFieldList END ##################');
		
//		return fieldList;
		return finalFieldList;
	}
}