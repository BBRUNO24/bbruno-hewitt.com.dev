//Created as per Case #00110071 by SunnyM
trigger Task_INSERT_UPDATE_DELETE_UNDELETE_AFTER on Task (after Insert,after update,after delete, after undelete) 
{
    If(Trigger.isdelete)
    {
        blogic_Activities.UpdateCampaign(null,Trigger.Old);
    }
    else if(Trigger.isUpdate)
    {
        blogic_Activities.UpdateCampaign(Trigger.New, Trigger.Old);
        //Added line below for case #00137492 by DaveM
        blogic_Activities.SendClientRefRequestEmail(Trigger.New, Trigger.old);
    }
    else
    {
        blogic_Activities.UpdateCampaign(Trigger.New, null);
    }

}