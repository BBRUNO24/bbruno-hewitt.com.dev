public with sharing class Adoption {
	public Adoption() {
		List<Option> options = new List<Option>{new Option('','')};
    List<Option> globalOptions = new List<Option>{new Option('','')};
    List<Option> globalCountryOptions = new List<Option>{new Option('','')};
    Schema.DescribeFieldResult globaldfr = User.Global_Reporting_Region__c.getDescribe();
    Schema.DescribeFieldResult countrydfr = User.Reporting_Country__c.getDescribe();
    Schema.DescribeFieldResult dfr = User.Reporting_Region__c.getDescribe();
    for(Schema.PicklistEntry p : dfr.getPicklistValues()){
      options.add(new Option(p.getValue(), p.getValue()));
    }
    for(Schema.PicklistEntry p : globaldfr.getPicklistValues()){
      globalOptions.add(new Option(p.getValue(), p.getValue()));
    }
    for(Schema.PicklistEntry p : countrydfr.getPicklistValues()){
      globalCountryOptions.add(new Option(p.getValue(), p.getValue()));
    }
    this.userOptions = JSON.serialize(options);
    this.globalUserOptions = JSON.serialize(globalOptions);
    this.globalCountryOptions = JSON.serialize(globalCountryOptions);
	}  

  public String userOptions {get; set;}
  public String globalUserOptions {get; set;}
  public String globalCountryOptions {get; set;}

  public class Option {
    public Option(Object value, Object label){
      this.value = value;
      this.label = label;
    }
    public Object value {get; set;}
    public Object label {get; set;}
  }

  public class config {
    public String objectName {get; set;}
    public String operation {get; set;}
    public String field {get; set;}
    public String groupBy {get; set;}
    public String orderBy {get; set;}
    public Integer limitRows {get; set;}
    public List<String> wheres {get; set;}
    public List<String> fields {get; set;}
  }

  @RemoteAction @ReadOnly
  public static Object fetchData(Adoption.config config){
    List<SObject> objs = new List<SObject>();
    SoqlBuilder builder = new SoqlBuilder();
    builder.fromSobject(config.objectName);
    if(config.operation != null && config.operation != ''){
      builder.aggregate(config.operation, config.field);
    }
    
    if(config.wheres != null && config.wheres.size() > 0){
      for(Integer i = 0; i < config.wheres.size(); i++){
        if(config.wheres[i] == null){

        }else{
          builder.addWhere(config.wheres[i]);
        }
        
      }
    }
    if(config.limitRows != null && config.limitRows > 0){
      builder.setLimit(config.limitRows);
    }
    if(config.groupBy != null && config.groupBy != ''){
      builder.selectField(config.groupBy);
      builder.addGroupBy('GROUP By '+ config.groupBy);
    }
    if(config.orderBy != null && config.orderBy != ''){
      builder.setOrderBy(config.orderBy);
    }
    if(config.fields != null && config.fields.size() > 0){
      for(Integer i = 0; i < config.fields.size(); i++){
        builder.selectField(config.fields[i]);
      }
    }
    objs = builder.getQueryResult();
    System.debug(objs);
    return objs;
  }

}