trigger ContactSegmentation_Insert_Update_After on Contact_Segmentation__c (after insert,after update) 
{
    //00008792 - Ritu Sharma - This function will populate contact segmentation field of the contact object    
    blogic_Contact.populateContactSegmentationInfo(Trigger.new,Trigger.old);
}