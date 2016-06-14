public with sharing class SchemaModel {
  public String name {get; set;}
  public String label {get; set;}
  public List<FieldModel> fields {get; set;}
  public SchemaModel(String objectName) {
    objectName = objectName.toLowerCase();
    DescribeSObjectResult sobjResult = SchemaHelpers.getDescribeResult(objectName);
    this.name = sobjResult.name.toLowerCase();
    this.label = sobjResult.label;
    this.fields = new List<FieldModel>();
    Map<String, Schema.SObjectField> fieldMap = sobjResult.fields.getMap();
    for(String f : fieldMap.keySet()){
      this.fields.add(new FieldModel(fieldMap.get(f)));
    }
  }

  public SchemaModel(DescribeSObjectResult sobjResult) {
    this.name = sobjResult.name.toLowerCase();
    this.label = sobjResult.label;
    this.fields = new List<FieldModel>();
    Map<String, Schema.SObjectField> fieldMap = sobjResult.fields.getMap();
    for(String f : fieldMap.keySet()){
      this.fields.add(new FieldModel(fieldMap.get(f)));
    }
  }
  public class PickListOpt {
    public String label;
    public String value;
    public PickListOpt(String value, String label){
      this.label = label;
      this.value = value;
    }
  }

  public class FieldModel{
    public String name {get; set;}
    public String apiName {get; set;}
    public String label {get; set;}
    public String type {get; set;}
    public String helpText {get; set;}
    public String formula {get; set;}
    public Boolean filterable {get; set;}
    public Boolean updatable {get; set;}
    public Boolean groupable {get; set;}
    public Boolean isCustom {get; set;}
    public Boolean isUserField {get; set;}
    public String referenceToApiName {get; set;}
    public String referenceTo {get; set;}
    public String referenceToLabel {get; set;}
    public String relationshipName {get; set;}
    public Integer length {get; set;}
    public List<PickListOpt> options {get; set;}
    public String getPicklistOptions(){
      List<String> str = new List<String>();
      for(PickListOpt opt : this.options){
        str.add(opt.value);
      }
      return String.join(str, ';');
    }
    public FieldModel(Schema.SObjectField f){
      Schema.DescribeFieldResult dfr = f.getDescribe();
      this.name = dfr.getname().toLowerCase();
      this.isCustom = dfr.isCustom();
      this.apiName = dfr.getName();
      this.label = dfr.getlabel();
      this.type = dfr.getType() != null ? String.valueOf(dfr.getType()) : '';
      this.filterable = dfr.isFilterable();
      this.groupable = dfr.isGroupable();
      this.formula = '';
      this.isUserField = false;
      this.updatable = dfr.isUpdateable();
      this.helpText = dfr.getInlineHelpText();
      Schema.DisplayType dt = dfr.getType();
      this.length = dfr.getLength();
      if(dfr.isCalculated()){
        this.formula = dfr.getCalculatedFormula();
      }

      if(dt == Schema.DisplayType.Reference){
        this.relationshipName = dfr.getRelationshipName();
        for(Schema.sObjectType sot: dfr.getReferenceTo()){
          if(sot.getDescribe().getName().toLowerCase() == 'user'){
            this.isUserField=true;
          }else{
            this.isUserField=false;
          }

          this.referenceTo = sot.getDescribe().getName().toLowerCase();
          this.referenceToApiName = sot.getDescribe().getName().toLowerCase();
          this.referenceToLabel = sot.getDescribe().getLabel();
        }
      }else if(dt == Schema.DisplayType.Picklist || dt == Schema.DisplayType.MultiPicklist){
        this.options = new List<pickListOpt>();
        for(Schema.PicklistEntry pe : dfr.getPicklistValues()){
          this.options.add(new pickListOpt(pe.getValue(), pe.getLabel()));
        }
      }else if(dt == Schema.DisplayType.Boolean){
        this.options = new List<pickListOpt>();
        this.options.add(new pickListOpt('true', 'True'));
        this.options.add(new pickListOpt('false', 'False'));
      }else{
        
      }
    }
  }

}