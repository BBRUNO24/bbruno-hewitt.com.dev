public class SoqlBuilder {
  public SoqlBuilder() {
    this.childQueries = new Map<String, ChildQuery>();
  }

  String objectName;
  Set<String> fields;
  List<String> wheres;
  Aggregation agg;
  Boolean groupBy = false;
  Boolean isLimit = false;
  Boolean isOffset = false;
  Integer offsetRows = 50;
  Integer limitRows = 50;
  String groupByExpr;
  String orderBy;
  Map<String, ChildQuery> childQueries;

  public class ChildQuery{
    String name {get; set;}
    String pluralName {get; set;}
    List<String> fields {get; set;}
    List<String> wheres;
    Integer limitRows = 50;
    String orderBy {get; set;}
    public ChildQuery(){
      this.fields = new List<String>();
    }
    public void addLimit(Integer limitRows){
      this.limitRows = limitRows;
    }
    public void addWhere(String whereCondition){
      if(this.wheres == null) this.wheres = new List<String>();
      this.wheres.add(whereCondition);
    }
  }

  public List<SObject> getQueryResult(){
    return Database.query(getSoql());
  }

  public String getSoql(){
    String soql = 'SELECT ';
    soql+= String.join(getFields(), ',');
    soql+= ' FROM '+objectName;
    if(wheres != null){
      soql+= ' WHERE ';
      soql+= String.join(wheres, ' AND ');
    }
    if(groupBy){
      soql+= ' '+groupByExpr +' ';
    }
    if(orderBy != null){
      soql+=' ORDER BY '+orderBy;
    }
    if(isLimit){
      soql+=' LIMIT '+limitRows;
      if(isOffset){
        soql+=' OFFSET '+offsetRows;
      }
    }
    System.debug(soql);
    return soql;
  }

  public Boolean childQueriesInit(){
    return (this.childQueries != null);
  }

  public Boolean hasChildObject(String objectName){
    if(childQueriesInit()){
      return childQueries.containsKey(objectName);
    }else{
      return false;
    }
  }

  

  public void setOrderBy(String orderByField){
    this.orderBy = orderByField;
  }

  public void setOffset(Integer newOffset){
    this.isOffset = true;
    this.offsetRows = newOffset;
  }

  public void setLimit(Integer newLimit){
    this.isLimit = true;
    this.limitRows = newLimit;
  }
   public void setLimit(Decimal newLimit){
    Integer theLimit = Integer.valueOf(newLimit);
    this.isLimit = true;
    this.limitRows = theLimit;
  }
  public void aggregate(String type, String field){
    this.agg = new Aggregation(type, field);
  }

  public void selectField(String field){
    if(field == null) return;
    if( this.fields == null) this.fields = new Set<String>();
    field = field.toLowerCase();
    this.fields.add(field);
  }

  public void selectFields(List<String> fields){
    if( this.fields == null) this.fields = new Set<String>();
    for(String s : fields){
      s = s.toLowerCase();
      this.fields.add(s);
    }
  }

  public void addGroupBy(String gb){
    groupBy = true;
    groupByExpr = gb;
  }

  public List<String> getFields(){
    List<String> f = new List<String>();
    if(this.fields != null){
      f.addAll(this.fields);
    }
    if(this.agg != null){
      f.add(agg.type +'('+agg.field+') agg');
    }
    if(childQueriesInit()){
      Set<String> keys = childQueries.keySet();
      if(keys.size() > 0){
        for(String key: keys){
          ChildQuery q = childQueries.get(key);
          String fields = String.join(q.fields, ', ');
          String query = '(SELECT ';
          query+=fields;
          query+=' FROM '+q.pluralName;
          if(q.wheres!=null){
            query += ' WHERE ';
            query+=String.join(q.wheres, ', ');
          }
          if(q.orderBy != null){
            query +=' ORDER BY '+q.orderBy;
          }
          query+=')';
          f.add(query);
        }
      }
    }
    return f;
  }

  public void addAllFieldsForObject(String objectName){
    objectName = objectName.toLowerCase();
    fromSobject(objectName);
    Map<String, Schema.SObjectField> fields = SchemaHelpers.getSobjectTypeMapResults(objectName);
    for(String s : fields.keySet()){
      selectField(s);
    }
  }

  public void addChildOrderBy(String childName, String orderBy){
    childName = childName.toLowerCase();
    this.childQueries.get(childName).orderBy = orderBy;
  }

  public void addChildWhere(String childName, String whereCondition){
    childName = childName.toLowerCase();
    if(this.childQueries.get(childName).wheres == null) this.childQueries.get(childName).wheres = new List<String>();
    this.childQueries.get(childName).wheres.add(whereCondition);
  }

  public void addAllFieldsForChildObject(String childName){
    childName = childName.toLowerCase();
    DescribeSObjectResult describe = SchemaHelpers.getDescribeResult(this.objectName.toLowerCase());
    List<Schema.ChildRelationship> children = describe.getChildRelationships(); 
    for(Schema.ChildRelationship cr : children){
      String field  = cr.getChildSObject().getDescribe().getLocalName();
      if(field.toLowerCase() == childName){
        String relationshipName = cr.getRelationshipName();
        addChildObject(childName);
        this.childQueries.get(childName).pluralName = relationshipName;
        Map<String, Schema.SObjectField> fields = SchemaHelpers.getSobjectTypeMapResults(childName);
        for(String s : fields.keySet()){
          addChildField(childName, s);
        }
      }
    }    
  }

  public void addChildObject(String childName, List<String> fields){
    childName = childName.toLowerCase();
    DescribeSObjectResult describe = SchemaHelpers.getDescribeResult(this.objectName.toLowerCase());
    List<Schema.ChildRelationship> children = describe.getChildRelationships(); 
    for(Schema.ChildRelationship cr : children){
      String field  = cr.getChildSObject().getDescribe().getLocalName();
      if(field.toLowerCase() == childName){
        String relationshipName = cr.getRelationshipName();
        addChildObject(childName);
        this.childQueries.get(childName).pluralName = relationshipName;
        for(String s : fields){
          addChildField(childName, s);
        }
      }
    }    
  }

  public void addRelationshipForChild(String childObj, String relationshipName, List<String> fields){
    childObj = childObj.toLowerCase();
    for(String s : fields){
      String rField = relationshipName+'.'+s;
      addChildField(childObj, rField);
    }
  }

  public void addChildField(String objectName, String fieldName){
    if(!hasChildObject(objectName)){
      addChildObject(objectName);
    }
    childQueries.get(objectName).fields.add(fieldName);
  }

  public void addChildObject(String objectName){
    ChildQuery query = new ChildQuery();
    query.name =objectName;
    if(!childQueriesInit()){      
      this.childQueries = new Map<String, ChildQuery>();
    }
    this.childQueries.put(objectName, query);
  }

  public void fromSobject(String objectName){
    this.objectName = objectName;
  }
  public void addWhere(String field, String operator, String condition){
    if(wheres == null) this.wheres = new List<String>();
    String w = field+' '+operator+' \''+condition+'\'';
    this.wheres.add(w);
  }
  public void addWhere(String field, String operator, Boolean condition){
    if(wheres == null) this.wheres = new List<String>();
    String w = field+' '+operator+' '+condition+'';
    this.wheres.add(w);
  }
  public void addWhereDate(String field, String operator, String condition){
    if(wheres == null) this.wheres = new List<String>();
    String w = field+' '+operator+' '+condition;
    this.wheres.add(w);
  }
  public void addWhere(String whereCondition){
    if(wheres == null) this.wheres = new List<String>();
    this.wheres.add(whereCondition);
  }
  public void addWhere(String field, String operator, List<String> arr){
    if(wheres == null) this.wheres = new List<String>();
    String s = '(\'' + String.join(arr,'\',\'') + '\')';
    String w = field+' '+operator+' '+s;
    this.wheres.add(w);
  }


  private String escapeString(String s){
    if(s == null){
      return s;
    }else{
      return String.escapeSingleQuotes(s);
    }
  }

  private Boolean isDate(Schema.DisplayType dt){
    return (dt == Schema.DisplayType.Date ) ? true:false;
  }

  private Boolean isId(Schema.DisplayType dt){
    return (dt == Schema.DisplayType.ID || dt == Schema.DisplayType.Reference) ? true:false;
  }

  private Boolean isIdValid(String idString){
    Boolean isValid = false;
    Id i;
    try{
      i = idString;
      isValid = true;
    }catch(Exception ex){
      System.debug('looks like a bad ID');
    }
    return isValid;
  }

  private Boolean isBoolean(Schema.DisplayType dt){
    return (dt == Schema.DisplayType.Boolean ) ? true:false;
  }

  private Boolean isDateTime(Schema.DisplayType dt){
    return (dt == Schema.DisplayType.DateTime ) ? true:false;
  }

  private Boolean isNumeric(Schema.DisplayType dt){
    return (dt == Schema.DisplayType.Integer || dt == Schema.DisplayType.Currency || dt == Schema.DisplayType.Double) ? true:false;
  }

  class Aggregation {
    Aggregation(String type, String field){
      this.type = type;
      this.field = field;
    }
    String type;
    String field;
  }
}