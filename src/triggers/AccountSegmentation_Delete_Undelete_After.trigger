trigger AccountSegmentation_Delete_Undelete_After on Account_Segmentation__c (after delete,after undelete) 
{
    //00008792 - Ritu Sharma - This function will populate account segmentation field of the account object
    blogic_Account.populateAccSegmentationInfo(Trigger.new,Trigger.old);
}