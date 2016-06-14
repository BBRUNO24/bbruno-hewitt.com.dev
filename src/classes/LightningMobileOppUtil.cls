public with sharing class LightningMobileOppUtil {
	public LightningMobileOppUtil() {
		
	}

    public static List<SelectOption> getPricebookOptions() {
    	List<SelectOption> options = new List<SelectOption>();
    	List<Pricebook2> pricebookRecords = [SELECT Id, Name FROM Pricebook2 WHERE IsActive = true ORDER BY Name];
    	System.debug('pricebookRecords size after query is: ' + pricebookRecords.size());

        options.add(new SelectOption('Please select a pricebook','--Please select a pricebook--'));
    	for (Pricebook2 p : pricebookRecords) {
    		options.add(new SelectOption(p.Id, p.Name));
    	}
    	return options;
    }	

    public static List<SelectOption> getProductOptions(String pricebookId, String practiceSelection) {
    	System.debug('entering getProductOptions');
        System.debug('pricebookId: ' + pricebookId);
        System.debug('practiceSelection: ' + practiceSelection);

    	List<SelectOption> options = new List<SelectOption>();
    	
    	//System.debug('currPricebook is: ' + currPricebook);
    	Set<Id> productIds = new Set<Id>();
    	List<PricebookEntry> junctionRecords = [SELECT id, Pricebook2Id, Product2Id FROM PricebookEntry WHERE ISActive = true AND Pricebook2id = :pricebookId AND Product2.Practice__c = :practiceSelection];
    	System.debug('junction records size is: ' + junctionRecords.size());

    	for (PricebookEntry pe : junctionRecords) {
    		productIds.add(pe.Product2id); 
    	}

    	List<Product2> productRecords = [SELECT Id, Name, Practice__c 
            FROM Product2 
            WHERE Id IN :productIds LIMIT 999];
    	System.debug('product records size is: ' + productRecords.size());

        options.add(new SelectOption('Please select a product','--Please select a product--'));
    	for (Product2 p : productRecords) { 
    		options.add(new SelectOption(p.Id, p.Name)); 
    	}

    	return options; 
    }

    public static List<SelectOption> getPracticeOptions(Id pricebookId) {
        System.debug('usersPricebook: ' + pricebookId);
        List<SelectOption> options = new List<SelectOption>();
        Set<String> practiceNames = new Set<String>();
        
        List<PricebookEntry> pbEntries = [select id, Product2.Practice__c from PricebookEntry where IsActive = true and Pricebook2Id = :pricebookId Order By Product2.Practice__c ASC];
        //logMessage('reteived ' + pbEntries.size() + ' price book entries for the designated pricebook: ' + this.opportunity.Pricebook2Id);
        
        
        for (PricebookEntry pbEntry : pbEntries) {
          practiceNames.add(pbEntry.Product2.Practice__c);
        }
        options.add(new SelectOption('Please select a practice','--Please select a practice--'));
        for (String s : practiceNames) {
            options.add(new SelectOption(s, s));
        }

        return options;
    }    

    public static void setPricebook(Opportunity opp){
        String sdoBillingCountry = [SELECT SDO_Billing_Country_Name__c FROM Account WHERE Id = :opp.AccountId].SDO_Billing_Country_Name__c;
        System.debug('sdoBillingCountry: ' + sdoBillingCountry);

        Office_Country_Pricebook_Mapping__c pricbookMapping;

        if(!String.isBlank(sdoBillingCountry)){
            pricbookMapping = [SELECT Id, Pricebook_Id__c, ISO_Currency__c  FROM Office_Country_Pricebook_Mapping__c WHERE Country_Name__c = :sdoBillingCountry.toLowerCase() LIMIT 1];
        }
        System.debug('pricbookMapping: ' + pricbookMapping);

        System.debug('opp: ' + opp);
        opp.Pricebook2id = pricbookMapping.Pricebook_Id__c;
        //  opp.CurrencyIsoCode = pricbookMapping.ISO_Currency__c;

    }

    public static List<selectOption> getPickValues(Sobject object_name, String field_name, String first_val) {
      //new list for holding all of the picklist options
      List<selectOption> options = new List<selectOption>(); 

      //if there is a first value being provided
      if (first_val != null) { 
        //add the first option
         options.add(new selectOption(first_val, first_val)); 
      }
      //grab the sobject that was passed
      Schema.sObjectType sobject_type = object_name.getSObjectType(); 
      System.debug('sobject_type: ' + sobject_type);
      //describe the sobject
      Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); 
      System.debug('sobject_describe: ' + sobject_describe);
      //get a map of fields for the passed sobject
      Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); 
      System.debug('field_map: ' + field_map);
      //grab the list of picklist values for the passed field on the sobject
      List<Schema.PicklistEntry> pick_list_values = field_map.get(field_name).getDescribe().getPickListValues(); 
      System.debug('pick_list_values: ' + pick_list_values);
      //for all values in the picklist list
      for (Schema.PicklistEntry a : pick_list_values) { 
            //add the value and label to our final list
            options.add(new selectOption(a.getValue(), a.getLabel())); 
      }
      //return the List
      System.debug('options: ' + options);
      return options; 
}



}