trigger Account_DELETE_UNDELETE_AFTER on Account (after delete, after undelete) {
    if (trigger.isDelete) {
        //Create or Delete records in the Delete Audit table
        blogic_DeleteAudit.createDeleteAuditRecords(trigger.old);
        //Store MasterRecordId in case of delete due to merge
        blogic_Account.createMergeAuditRecords(trigger.old);
    } else if (trigger.isUnDelete) {
        blogic_DeleteAudit.createDeleteAuditRecords(trigger.new);
    }
}