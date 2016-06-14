trigger Opportunity_DELETE_UNDELETE_AFTER on Opportunity (after delete, after undelete) {
    //Create or Delete records in the Delete Audit table
    if (trigger.isDelete) {
        blogic_DeleteAudit.createDeleteAuditRecords(trigger.old);
    } else if (trigger.isUnDelete) {
        blogic_DeleteAudit.createDeleteAuditRecords(trigger.new);
    }
}