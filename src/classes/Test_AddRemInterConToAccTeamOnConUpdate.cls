@isTest
private class Test_AddRemInterConToAccTeamOnConUpdate 
{
    static testMethod void myUnitTest() 
    {
        //User u = [Select Id from User where Name = UserInfo.getUserName()]; //00039290 - Ritu Sharma - No need to get the handle of the user record
        User u1 = [Select Id from User where IsActive=True limit 1]; //00039290 - Ritu Sharma - picking any user instead of any hardcoded user
        
        Account acc = new Account();
        acc.Name = 'Test Account_NS';
        acc.SDO_Billing_Country_Name__c = 'India';
        acc.OwnerId = UserInfo.getUserID();   
        acc.BillingPostalCode = '1111';    
        insert acc;
        
        RecordType rt = [Select Id From RecordType where Name =: 'Internal Contact Record Type'];

        Contact con = new Contact();
        con.RecordTypeId = rt.Id;
        con.FirstName = 'Test Acc111';
        con.LastName = 'Contact';
        con.AccountId = acc.Id;
        con.User_ID__c = UserInfo.getUserID(); //00039290 - Ritu Sharma - Uncommented the code so that user could be changed later 
        insert con;
        
        Contact conObj = [Select User_ID__c From Contact where FirstName =: 'Test Acc111'];
        conObj.User_ID__c = u1.Id; 
        update conObj;
    }
}