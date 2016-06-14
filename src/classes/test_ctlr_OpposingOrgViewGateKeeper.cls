@isTest(SeeAllData=true) 
public class test_ctlr_OpposingOrgViewGateKeeper {
    
    static testmethod void checkAccountTeamMembership(){
        //local vars
        Account account2 = null;
        Test.startTest();  
        
        //CASE 1 - Checking for admin user access based on profile
        //Create an account
        Account account1 = util_SampleDataGenerator.createAccount_Client(); 
        account1.Opposite_Org_Account_ID__c = '0013000000wygHH';       
        update account1;
        System.assertNotEquals(null, account1.Id);  
            
        //Get controller handles
        ApexPages.standardController stdController = new ApexPages.standardController(account1);
        
          //Handle to the Apex page          
        PageReference pageRef = Page.OpposingOrgViewGateKeeper;
        pageRef.getParameters().put('accountid', account1.id);
        
        // set the test context
        test.setCurrentPage(pageRef);
        
        ctlr_OpposingOrgViewGateKeeper cusController = new ctlr_OpposingOrgViewGateKeeper();        
        //Check access
        PageReference newPageRef = cusController.checkAccountTeamMembership(); 
        
          //Verify by checking the URL of the redirected page
        System.debug('Original URL: '+(String)pageRef.getURL()+' Redirected URL: '+(String)newPageRef.getURL());
        System.assertEquals(true, ((String)newPageRef.getURL()).contains('acctid=')); 
                
        
    }

}