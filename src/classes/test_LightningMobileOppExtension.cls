@isTest
private class test_LightningMobileOppExtension {
	@testSetup 
    static void setupClientData() {
    	//Set up sample data

    	//Competitor
    	Competitor__c comp1 = new Competitor__c(Name='Aon Hewitt');
    	Competitor__c comp2 = new Competitor__c(Name='Other');
    	List<Competitor__c> compList = new List<Competitor__c>{comp1, comp2};
    	insert(compList);

    	
    }     
	
	static testMethod void test_CreateMobileOpportunity(){
		//Set up sample data
		Office_Country_Pricebook_Mapping__c  ocpm = new Office_Country_Pricebook_Mapping__c(
    		Name = 'United States',
    		ISO_Currency__c = 'USD',
    		Pricebook_Id__c = Test.getStandardPricebookId(),
    		Country_Name__c = 'United States');
    	insert(ocpm);

    	Product2 p1 = new Product2(Name='Product Monthly 1111', Family='Monthly', isActive=true, CurrencyIsoCode='USD', Practice__c='Absence Management');
    	insert(p1);

    	Id pricebookId = Test.getStandardPricebookId();

    	PricebookEntry pbe1 = new PricebookEntry(Pricebook2id=pricebookId, Product2id=p1.ID, isActive=true, CurrencyIsoCode='USD', unitPrice=100);
    	insert(pbe1);

		Account acct = util_sampleDataGenerator.createAccount_Client();
		Contact ctct = util_sampleDataGenerator.createContact_External(acct.Id);

		Test.startTest();

			//Get controller handles
	        LightningMobileOppExtension custController = new LightningMobileOppExtension();

	        //Tests
	        System.assertEquals(custController.activePanel, 'slds-tabs__content slds-tabs--default__content slds-show');
	        System.assertEquals(custController.activeTab, 'slds-tabs__item slds-tabs--default__item slds-text-heading--label slds-active');
	        System.assertEquals(custController.inactivePanel, 'slds-tabs__content slds-tabs--default__content slds-hide');
	        System.assertEquals(custController.inactiveTab, 'slds-tabs__item slds-tabs--default__item slds-text-heading--label');
	        System.assertEquals(custController.showSalesCredit, true);

			//Handle to the Apex page          
	        PageReference pageRef = Page.LightningMobileOpportunity;

	        //Default Tab should be Opportunity
	        System.assertEquals(custController.tabToShow, 'Opportunity');

	        //Try going to Products Tab
	        custController.goToProducts();

	        //Opportunity not set, should not go to products yet
	        System.assertNotEquals(custController.tabToShow, 'Products');

	        //Set Controller Opportunity
	        custController.opp.Name='Test Mobile Opp';
	        custController.opp.AccountId = acct.Id;
	        custController.opp.CloseDate = System.today();
	        custController.selectedOpportunityStage = 'Closed Won';
	        custController.rerenderStageFields();

	        custController.selectedOpportunityStage = 'Negotiate';
	        custController.rerenderStageFields();

	        custController.selectedOpportunityStage = 'Propose Solution';
	        custController.rerenderStageFields();

	        custController.selectedOpportunityStage = 'Non-Qualified Opportunity';
	        custController.rerenderStageFields();   

	        custController.selectedOpportunityStage = 'Propose Solution';
	        custController.rerenderStageFields();     

	        custController.selectedOpportunityStage = 'Qualify Opportunity';
	        custController.rerenderStageFields();  

	        custController.goToOpportunity();   


	        //Try again going to Products Tab
	        custController.goToProducts();

	        //Opportunity not set, should not go to products yet
	        System.assertEquals(custController.tabToShow, 'Products');

	        //try going to Contact Tab
	        custController.goToContact();
	        System.assertNotEquals(custController.tabToShow, 'Contact');

	        //test for missing product or practice
	        custController.practiceSelection = 'Please Select a practice';
	        custController.productSelection = 'Please select a product';
	        custController.addProduct();
	        System.assertEquals(custController.toast.toastMsg, 'Please select a Practice and Product.');

	        //Set practice and Product
	        custController.refreshPracticeOptions();
	        custController.practiceSelection = p1.Practice__c;
	        custController.refreshProductOptions();
	        custController.productSelection = p1.Id;

	        //test for null service dates
	        custController.addProduct();
	        System.assertEquals(custController.toast.toastMsg, 'Please enter Service Start Date and Service End Date.');

	        custController.currOLI.PricebookEntryId = pbe1.Id;
	        custController.currOLI.Recurring_Non_Recurring__c = 'Non-Recurring';
	        custController.currOLI.Fee_Commission__c = 'Fee';
	        custController.currOLI.Type__c = 'New Client Sale - A';
	        custController.currOLI.First_Year_Value__c = 5000;
	        custController.currOLI.UnitPrice = 5000;
	        custController.currOLI.Service_Start_Date__c = Date.today();
	        custController.currOLI.Service_End_Date__c = Date.today();

	        //Add Product to list
	        custController.addProduct();
	        System.assert(custController.addedOLI.size(	) > 0);

	        //check productd
	        custController.checkProducts();

	        //Remove Product
	        custController.productId = custController.pbEntryList[0].Id;
	        custController.removeProduct();

	        //Add Product Back
	        custController.addProduct();
	        System.assert(custController.addedOLI.size(	) > 0); 

	        //try again to go to the Contact Tab
	        custController.goToContact();
	        System.assertEquals(custController.tabToShow, 'Contact');

	        //try to save opportunity
	        custController.saveWithProducts();

	        custController.contactRoles[0].Role = 'Business User';
	        custController.saveWithProducts();

	        //go to Sales Credit
	        custController.goToSalesCredit();
	        System.assertEquals(custController.tabToShow, 'SalesCredit');

	       	//navigate to Opportunity
	       	custController.navigateToOpportunity();

	       	LightningMobileOppUtil.getPricebookOptions();

	    Test.stopTest();

	}


	static testMethod void test_CreateMobileSalesCredit(){	
		//Account
    	Account acct = util_sampleDataGenerator.createAccount_Client();
    	Contact ctct1 = util_sampleDataGenerator.createContact_Internal(acct.Id);
    	Contact ctct2 = util_sampleDataGenerator.createContact_External(acct.Id);
    	SLDS_Toast toast = new SLDS_Toast();

    	//Opportunity
    	Opportunity opp = new Opportunity(Name='Test Mobile Opp2',
    		AccountId = acct.Id,
    		StageName = 'Qualify Opportunity',
    		Probability = 25,
    		CloseDate = System.today());
    	insert(opp);

		Test.startTest();

			//Get controller handles
	        ctlr_MobileOpportunitySalesCredit custController = new ctlr_MobileOpportunitySalesCredit();
	        custController.mytoast = toast;

	        custController.opp = opp;
	        custController.salesCredit.Credit_Recipient__c = ctct2.Id;
	        custController.salesCredit.Dual_Initiation_Credit__c = 5;
	        custController.salesCredit.Sales_Assist_Credit__c = 10;
	        custController.salesCredit.Sales_Credit__c = 15;

	        custController.addSalesCredit();

	        custController.salesCredit.Credit_Recipient__c = ctct1.Id;

	        custController.addSalesCredit();

	    Test.stopTest();


	}

	
}