global class ctlr_CreateCaseCommentChatter {

    public final SObject parent {get; set;}
    public CaseComment theComment {get; set; }
    public String lastError {get; set; }
    public List<CaseComment> oldComments {get; set;}
    public CaseComment lastComment {get; set;}
    
    public ctlr_CreateCaseCommentChatter(ApexPages.StandardController controller) {
        parent = controller.getRecord();
        theComment = new CaseComment();
        theComment.ParentId = parent.id;
        lastError = 'waiting';
        
        oldComments = new List<CaseComment>();
        oldComments = [SELECT CreatedBy.Name, CreatedDate, CommentBody from CaseComment WHERE ParentId = :parent.id ORDER BY CreatedDate DESC Limit:3];
        if(oldComments.size() > 1) {
            lastComment = oldComments.get(0);
        } else {
            lastComment = new CaseComment();
        }    
    }
    
    public PageReference createComment() {
    
       if (!Schema.sObjectType.CaseComment.isCreateable()){
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access'));
           lastError = 'nope';
           return null;
          }
        createCaseComment();
        theComment = new CaseComment();
        theComment.ParentId = parent.Id;
        oldComments = [SELECT CreatedBy.Name, CreatedDate, CommentBody from CaseComment WHERE ParentId = :parent.id ORDER BY CreatedDate DESC Limit:3];
        return null;
    }
    
    public void createCaseComment() {
        try {
            insert theComment;
            lastError = 'ok';
        } catch(System.Exception ex) {
            lastError = ex.getMessage();
        }
    }
    
    @RemoteAction
    Global static string createComment(String CaseId, String CommentBody, Boolean CommentisPublished){
       
    if (!Schema.sObjectType.CaseComment.isCreateable()){
         ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access'));
         return 'Insufficient access';
    }

      CaseComment theComment = new CaseComment();
      theComment.ParentId = CaseId;

    try {
        theComment.CommentBody=CommentBody;
        theComment.isPublished=CommentisPublished;
        insert theComment;
        return 'Success';
    } catch(System.Exception ex) {
        return ex.getMessage();
    }
    }
}