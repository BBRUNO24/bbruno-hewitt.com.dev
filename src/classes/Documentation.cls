public with sharing class Documentation {
    public Documentation() {

    for (Schema.SObjectType objectType : Task.WhatId.getDescribe().getReferenceTo()) {
       objectsWithActivitiesEnabled.add(objectType);
    }
  }
  public SchemaModel objModel {get; set;}
  public Map<String, Documentation_Object__c> documentObjectMap {get; set;}
  public Set<Schema.SObjectType> objectsWithActivitiesEnabled = new Set<Schema.SObjectType>();
  public Map<String, Documentation_Object__c> docMap {get; set;}

  public Documentation_Object__c currentObject {get; set;}

  public List<Documentation_Object__c> getObjects(){
    return getDocMap().values();
  }

  public List<Documentation_Field__c> getFields(){
    SoqlBuilder builder = new SoqlBuilder();
    builder.addAllFieldsForObject('Documentation_Field__c');
    if(currentObject != null){
      builder.addWhere('Documentation_Object__c', '=', currentObject.Id);
    }
    builder.setOrderBy('Name');
    List<Documentation_Field__c> fields = (List<Documentation_Field__c>)builder.getQueryResult();
    System.debug(fields);
    return fields;
     
  }

  public static void startRunner(){
    Id batchInstanceId = Database.executeBatch(new Documenter(), 1);
  }

  public void loadDocObjectMap(){
    this.documentObjectMap = getDocMap();
  }

  @future
  public static void describeSObjects(){
    Documentation doc = new Documentation();
    Map<String, Schema.DescribeSObjectResult> gdr = SchemaHelpers.getGlobalDescribeResults();
    Map<String, Documentation_Object__c> docMap = doc.getDocMap();
    List<Documentation_Object__c> docsToInsert = new List<Documentation_Object__c>();
    for(String key : gdr.keySet()){
      if(docMap.containsKey( gdr.get(key).getName().toLowerCase() )){
        docsToInsert.add(doc.getDocFromDescribeResult( docMap.get(key), gdr.get(key)));
      }else{
        docsToInsert.add(doc.getDocFromDescribeResult(gdr.get(key)));
      }
    }
    upsert docsToInsert;
  }

  public static void documentFields(Documentation_Object__c docObj){
    Documentation doc = new Documentation();
    doc.objModel = new SchemaModel(docObj.API__c);
    doc.loadDocObjectMap();
    Documentation_Object__c obj = doc.getDocs(docObj.API__c)[0];
    Map<String, Documentation_Field__c> fieldMap = new Map<String, Documentation_Field__c>();
    if(obj.Documentation_Fields__r != null && obj.Documentation_Fields__r.size() > 0){
      for(Documentation_Field__c field : obj.Documentation_Fields__r){
        fieldMap.put(field.API__c, field);
      }
    }
    for(SchemaModel.FieldModel fieldModel : doc.objModel.fields){
      Documentation_Field__c docField;
      if(fieldMap.containsKey(fieldModel.apiName)){
        docField = fieldMap.get(fieldModel.apiName);
      }else{
        docField = new Documentation_Field__c(Documentation_Object__c=docObj.Id);
      }
      System.debug('About to call getField with: '+docObj.Name);
      System.debug(docObj);
      System.debug('Field Model: '+docObj.Name);
      System.debug(fieldModel);
      fieldMap.put(fieldModel.apiName, doc.getField(docField, fieldModel));
    }
    upsert fieldMap.values();
  }

  public Documentation_Field__c getField(Documentation_Field__c field, SchemaModel.FieldModel fieldModel){
    field.Type__c = fieldModel.type;
    field.API__c = fieldModel.apiName;
    field.Custom__c = fieldModel.isCustom;
    field.Name = fieldModel.label;
    field.Formula_Value__c = fieldModel.formula;
    field.Help_Text__c = fieldModel.helpText;
    field.Length__c = String.valueOf(fieldModel.length);
    if(fieldModel.type == 'REFERENCE'){
      field.Reference_To__c = documentObjectMap.get(fieldModel.referenceTo).Id;
    }
    if(fieldModel.type == 'PICKLIST' || fieldModel.type == 'MULTIPICKLIST'){
      field.Picklist_Values__c = fieldModel.getPicklistOptions();
    }
    
    return field;
  }
  @future
  public static void deleteDocs(){
    Database.delete([SELECT Id FROM Documentation_Object__c]);
    Database.delete([SELECT Id FROM Documentation_Field__c]);
  }
  public Documentation_Object__c getDocFromDescribeResult(Schema.DescribeSObjectResult dsr){
    Documentation_Object__c obj = new Documentation_Object__c();
    return getDocFromDescribeResult(obj, dsr);
  }
  public Documentation_Object__c getDocFromDescribeResult(Documentation_Object__c obj, Schema.DescribeSObjectResult dsr){
    obj.API__c = dsr.getName();
    obj.Name = dsr.getLabel();
    obj.Custom__c = dsr.isCustom();
    obj.Custom_Setting__c = dsr.isCustomSetting();
    obj.Number_of_Fields__c = dsr.fields.getMap().keySet().size();
    obj.Number_of_Record_Types__c = dsr.getRecordTypeInfosById().keySet().size();
    obj.Track_Activities__c = objectsWithActivitiesEnabled.contains(dsr.getSobjectType());
    return obj;
  }
  public Map<String, Documentation_Object__c> getDocMap(){
    if(this.docMap == null){
      this.docMap = new Map<String, Documentation_Object__c>();
      List<Documentation_Object__c> docs = getDocs();
      for(Documentation_Object__c d : docs){
        docMap.put(d.API__c.toLowerCase(), d);
      }
    }    
    return docMap;
  }
  public List<Documentation_Object__c> getDocs(){
    return getDocs(null);
  }
  public List<Documentation_Object__c> getDocs(String objectName){
    SoqlBuilder builder = new SoqlBuilder();
    builder.addAllFieldsForObject('Documentation_Object__c');
    builder.addAllFieldsForChildObject('Documentation_Field__c');
    if(objectName != null){
      builder.addWhere('API__c', '=', objectName);
    }
    builder.setOrderBy('Name');
    return (List<Documentation_Object__c>)builder.getQueryResult();
  }
}