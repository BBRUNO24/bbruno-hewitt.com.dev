trigger MailingCountryUpdate on Contact (before insert, before update) 
{
	for(Integer i=0;i<Trigger.new.size();i++)
    {
        if(Trigger.new[i].SDO_Mailing_Country_Name__c!=NULL)
        {
            Trigger.new[i].MailingCountry=Trigger.new[i].SDO_Mailing_Country_Name__c;
        }
    }

}