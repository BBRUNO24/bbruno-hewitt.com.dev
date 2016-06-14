trigger ContactSegmentation_Delete_Undelete_After on Contact_Segmentation__c (after delete,after undelete) 
{
    //00008792 - Ritu Sharma - This function will populate contact segmentation field of the contact object
    blogic_Contact.populateContactSegmentationInfo(Trigger.new,Trigger.old);
}