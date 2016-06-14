public class BatchUpdateController {
  public BatchUpdateController(){
    this.batchConfig = new BatchUpdate();
    this.updates = new List<BatchUpdate>();
  }
  public BatchUpdate batchConfig {get; set;}
  public List<BatchUpdate> updates {get; set;}
  Map<String, Schema.DescribeSObjectResult> globalDescribeResults {get; set;}

  public List<SelectOption> getObjectOptions(){
    List<SelectOption> opts = new List<SelectOption>();
    opts.add(new SelectOption('', ''));
    Set<String> keys = SchemaHelpers.getGlobalDescribeResults().keySet();
    List<String> lKeys = new List<String>();
    lKeys.addAll(keys);
    lKeys.sort();
    for(String key : lKeys){
      DescribeSObjectResult res = SchemaHelpers.getDescribeResult(key);
      if(res.isUpdateable() && res.isQueryable()){
        opts.add(new SelectOption(key, SchemaHelpers.getObjectName(key)));
      }
      
    }
    return opts;
  }

  public PageReference fetchJobStatus(){
    List<String> jobIds = new List<String>();
    Map<String, BatchUpdate> buMap = new Map<String, BatchUpdate>();
    for(BatchUpdate bu : updates){
      if(bu.result.isComplete != true && bu.result.batchId != ''){
        jobIds.add(bu.result.batchId);
        buMap.put(bu.result.batchId, bu);
      }
    }
    if(jobIds.size() > 0){
      List<AsyncApexJob> aaj = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors  FROM AsyncApexJob WHERE ID =: jobIds ];
      for(AsyncApexJob a : aaj){
        BatchUpdate bu = buMap.get(a.Id);
        bu.result.status = a.Status;
        if(bu.result.status == 'Completed'){
          bu.result.isComplete = true;
        }else if(bu.result.status == 'Failed' || bu.result.status == 'Aborted'){
          bu.result.isComplete = true;
        }
      }
    }
    return null;
  }

  public PageReference doNothing(){
    batchConfig.hasCounted = false;
    return null;
  }

  public void doUpdateInBatch(SoqlBuilder builder){
    BatchUpdateRunner job = new BatchUpdateRunner(builder.getSoql(), batchConfig.fieldApiName, batchConfig.changeToValue);
    Id BatchProcessId = Database.executeBatch(job);
    batchConfig.result.batchId = (String)BatchProcessId;
    batchConfig.result.isComplete = false;
    batchConfig.result.isSuccess = false;
    updates.add(batchConfig);
    batchConfig = new BatchUpdate();  
  }
  public void doUpdateSync(SoqlBuilder builder){
    List<SObject> res = (List<SObject>)builder.getQueryResult();
    for(SObject sobj : res){
      sobj.put(batchConfig.fieldApiName, batchConfig.changeToValue);
    }
    List<Database.SaveResult> srs = Database.update(res);
    batchConfig.result.isComplete = true;
    batchConfig.result.isSuccess = true;
    for(Database.SaveResult sr : srs){
      if(!sr.isSuccess()){
        batchConfig.result.isSuccess = false;
        batchConfig.result.status = 'Failed';
        for(Database.Error err : sr.getErrors()) {
          batchConfig.result.errorMsgs.add(err.getMessage());
          System.debug('The following error has occurred.');                   
          System.debug(err.getStatusCode() + ': ' + err.getMessage());
          System.debug('Account fields that affected this error: ' + err.getFields());
        }
      }else{
        batchConfig.result.status = 'Completed';
      }
    }
    updates.add(batchConfig);
    batchConfig = new BatchUpdate();
  }
  public PageReference doUpdate(){
    SoqlBuilder builder = new SoqlBuilder();
    builder.fromSobject(batchConfig.objectApiName);
    builder.selectField(batchConfig.fieldApiName);
    builder.addWhere(batchConfig.fieldApiName, '=', batchConfig.oldValue);

    if(batchConfig.recordCount >= 200){
      doUpdateInBatch(builder);
    }else{
      doUpdateSync(builder);
    }
    
    return null;
  }

  public PageReference showEstimates(){
    if(batchConfig.getIsValid()){
      SoqlBuilder builder = new SoqlBuilder();
      builder.fromSobject(batchConfig.objectApiName);
      builder.addWhere(batchConfig.fieldApiName, '=', batchConfig.oldValue);
      builder.aggregate('COUNT', 'Id');

      List<AggregateResult> res = (List<AggregateResult>)builder.getQueryResult();
      batchConfig.hasCounted = true;
      batchConfig.recordCount = 0;
      if(res.size() == 1){
        AggregateResult r = res[0];
        batchConfig.hasCounted = true;
        batchConfig.recordCount = (Integer)r.get('agg');
      }
    }
    return null;
  }


  public List<SelectOption> getFieldOptions(){
    List<SelectOption> opts = new List<SelectOption>();
    opts.add(new SelectOption('', ''));
    if(batchConfig.objectApiName != null && batchConfig.objectApiName != ''){
       Map<String, Schema.SObjectField> fieldMap = SchemaHelpers.getSobjectTypeMapResults(batchConfig.objectApiName);
       List<String> lKeys = new List<String>();
       lKeys.addAll(fieldMap.keySet());
       lKeys.sort();
       for(String key : lKeys){
        Schema.DescribeFieldResult dr = SchemaHelpers.getFieldDescribe(batchConfig.objectApiName, key);
        if(dr.isUpdateable()){
          opts.add(new SelectOption(dr.getName(), dr.getLabel()));
        }
      }
    }else{
      opts.add(new SelectOption('', ''));
    }
    return opts;
  }

  public class BatchUpdate{
    public BatchUpdate(){
      this.result = new UpdateResult();
      this.hasCounted = false;
      this.recordCount = 0;
    }
    public String fieldApiName {get; set;}
    public String objectApiName {get; set;}
    public String oldValue {get; set;}
    public String changeToValue {get; set;}
    public UpdateResult result {get; set;}
    public Boolean hasCounted {get; set;}
    public Integer recordCount {get; set;}
    public Boolean getIsValid(){
      if(fieldApiName != null && objectApiName != null && oldValue != null && changeToValue !=null){
        if(fieldApiName != '' && objectApiName != '' && oldValue != '' && changeToValue !=''){
          return true;
        }
      }
      return false;
    }
  }
  public class UpdateResult{
    public UpdateResult(){
      this.isComplete = false;
      this.isSuccess = false;
      this.useBatch = false;
      this.batchId = '';
      this.status = '';
      this.errorMsgs = new List<String>();
    }
    public String status {get; set;}
    public Boolean isComplete {get; set;}
    public Boolean isSuccess {get; set;}
    public String batchId {get; set;}
    public Boolean useBatch {get; set;}
    public List<String> errorMsgs {get; set;}
  }
}