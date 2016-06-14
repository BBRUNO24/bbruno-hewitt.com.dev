public class CaseWorkflow {

  public static void updateStatus(List<Case> cases) {
    Id recordId = util_sampleDataGenerator.getRecordType('Case', 'Enhancement Request').Id;
    for (Case c : cases) {
      if (c.RecordTypeId == recordId) {
        c.Development_Status__c = 'Waiting on Approval';

        if (c.Migration_Complete__c == 'Yes') {
          c.Development_Status__c = 'Released';
        } else if (c.UAT_Testing_Complete__c == 'Passed') {
          c.Development_Status__c = 'Released';
        } else if (c.QA_Test_Results__c == 'Passed') {
          c.Development_Status__c = 'UAT';
        } else if (c.Dev_Testing_Complete__c == 'Passed') {
          c.Development_Status__c = 'QA';
        } else if (c.Req_Review_Complete__c == 'Yes' && c.Assigned_Aon_Help_Desk__c != null) {
          c.Development_Status__c = 'In Development';
        } else if (c.Req_Review_Complete__c == 'Yes' && c.Assigned_Aon_Help_Desk__c == null) {
          c.Development_Status__c = 'Waiting for Resources';
        }
      }
    }
  }


  @RemoteAction
  public static List<Case> getCases() {
    SoqlBuilder builder = CaseWorkflow.getBuilder();
    return (List<Case>)builder.getQueryResult();
  }

  @RemoteAction
  public static Case fetchCase(String id) {
    SoqlBuilder builder = CaseWorkflow.getBuilder();
    builder.addWhere('Id', '=', id);
    builder.setLimit(1);
    List<Case> cases = (List<Case>)builder.getQueryResult();
    return cases[0];
  }

  @RemoteAction
  public static Case updateCase(Case c) {
    update c;
    return c;
  }

  @RemoteAction
  public static void addComment(String caseId, String comment) {
    Id currentUserId = UserInfo.getUserId();
    CaseComment c = new CaseComment();
    c.CommentBody = comment;
    c.ParentId = caseId;
    insert c;
  }

  public String  getCaseModel() {
    return JSON.serialize(new SchemaModel('Case'));
  }

  public String getUsers() {
    SoqlBuilder builder = new SoqlBuilder();
    builder.addAllFieldsForObject('User');
    builder.addWhere('Name', 'IN', getAonTeam());
    List<User> users = (List<User>)builder.getQueryResult();
    return JSON.serialize(users);
  }

  public String getUser() {
    SoqlBuilder builder = new SoqlBuilder();
    builder.addAllFieldsForObject('User');
    builder.addWhere('Id', '=', UserInfo.getUserId());
    builder.setLimit(1);
    List<User> users = (List<User>)builder.getQueryResult();
    return JSON.serialize(users[0]);
  }

  private List<String> getAonTeam() {
    List<String> options = new List<String>();
    options.add('Aon Internal Contact Owner');
    Schema.DescribeFieldResult fieldResult =  Case.Assigned_Aon_Help_Desk__c.getDescribe();
    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

    for ( Schema.PicklistEntry f : ple) {
      options.add(f.getLabel());
    }
    return options;
  }

  public static SoqlBuilder getBuilder() {
    String recordId = util_sampleDataGenerator.getRecordType('Case', 'Enhancement Request').Id;
    SoqlBuilder builder = new SoqlBuilder();
    builder.addAllFieldsForObject('Case');
    builder.selectField('Contact.Name');
    builder.addWhere('RecordTypeId', '=', recordId);
    builder.addWhere('IsClosed', '=', false);
    builder.selectField('RecordType.Name');
    builder.selectField('Rq_Reviewer__r.Name');
    builder.addChildObject('Attachment', new List<String> {'Id', 'BodyLength', 'ContentType', 'Description', 'Name'});
    builder.addAllFieldsForChildObject('CaseComment');
    builder.addChildOrderBy('CaseComment', 'CreatedDate DESC');
    builder.addRelationshipForChild('CaseComment', 'CreatedBy', new List<String> {'Name'});
    builder.selectField('Owner.Name');
    return builder;
  }
}