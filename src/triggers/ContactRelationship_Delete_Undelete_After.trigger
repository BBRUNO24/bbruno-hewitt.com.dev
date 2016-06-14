trigger ContactRelationship_Delete_Undelete_After on Contact_Relationship__c (after delete,after undelete) 
{
    //00008792 - Ritu Sharma - This function will populate contact relationship field of the contact object    
    blogic_Contact.populateContactRelationshipInfo(Trigger.new,Trigger.old);
}