@isTest
private class test_blogicLead 
{
	 static testMethod void test_addCampaignMemberFromEloqua(){
          //Declaring variables       
        User user;
        Account acc;
        Contact con;
        Lead lead;
        
        List<Profile> profileList;
        List<User> userList;
        List<Lead> leadList;
        List<AccountTeamMember> memberList;
        
        //Getting handle of 2 mexico profiles
        profileList = New List<Profile>([Select ID,Name from Profile where Name=:'Standard User']);
        
        //Creating 100 test users for each profile
        userList=new List<User>();
        for (Integer i=0;i<profileList.size();i++)
        {
            for(Integer j=0;j<100;j++)
            {
                user=new User(emailencodingkey='UTF-8', languagelocalekey='en_US', localesidkey='en_US',
                timezonesidkey='America/New_York', Alias='T-'+i+'-'+j, email='TestUser'+i+'@aon.com', lastname='TestUser-'+i+'-'+j, 
                username='TestUser-'+i+'-'+j+'@aon.com', Reporting_Country__c='Netherlands', ProfileId=profileList[i].ID);
                userList.add(user);
            }
        }
        insert userList;

        for (Integer i=0;i<100;i++)
            system.assertNotEquals(userList[i].id,null);

          
        //Creating an account
        acc=util_sampleDataGenerator.createAccount_Client(false); 
        insert acc;
        System.assertNotEquals(null,acc.Id);
        
        //Creating a contact
        con=util_sampleDataGenerator.createContact_External(acc.Id);
        System.assertNotEquals(null,con.Id);            

        //Create Campaign
        Campaign camp = new Campaign(Name='test', Type='Email', Status='Targeting', CurrencyIsoCode='USD');
        insert camp;
        system.assertNotEquals(null, camp.id);

        //Creating Campaign Member
        CampaignMember campMember = new CampaignMember(ContactId=con.Id, Status='Sent', CampaignId=camp.Id); 
        insert campMember;
        System.assertNotEquals(null, campMember.Id);

        //Creating Lead
        lead=new Lead(LastName='Test Lead', Status='Open', 
            Company='Test Company', Related_Account__c=acc.id, Related_Contact__c=con.id, Eloqua_Campaign_Id__c=camp.Id, Eloqua_contact_ID__c=con.Id, Prospect_Score__c='A4');
        insert lead;
        System.assertNotEquals(null, lead.Id);

        CampaignMember cm = [SELECT Id, Prospect_Score__c FROM CampaignMember WHERE ContactId = :con.Id AND CampaignId = :camp.Id];
        System.assertEquals(cm.Prospect_Score__c, lead.Prospect_Score__c);

    }
}