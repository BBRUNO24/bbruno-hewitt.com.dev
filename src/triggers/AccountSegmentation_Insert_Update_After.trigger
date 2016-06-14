trigger AccountSegmentation_Insert_Update_After on Account_Segmentation__c (after insert,after update) 
{
    //00008792 - Ritu Sharma - This function will populate account segmentation field of the account object
    blogic_Account.populateAccSegmentationInfo(Trigger.New,Trigger.Old);
}