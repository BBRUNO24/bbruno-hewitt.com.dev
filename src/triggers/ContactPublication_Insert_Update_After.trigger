trigger ContactPublication_Insert_Update_After on Contact_Publication__c (after insert,after update) 
{
    //00008792 - Ritu Sharma - This function will populate contact publication field of the contact object
    blogic_Contact.populateContactPublicationInfo(Trigger.new,Trigger.old);
}