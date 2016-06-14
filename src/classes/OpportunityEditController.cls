public with sharing class OpportunityEditController {
	public OpportunityEditController() {
		this.currentUser = [SELECT Id, Reporting_Country__c FROM User where Id =:UserInfo.getUserId()];
    this.editSections = [Select Name, Collapsible__c, Columns__c, (Select Field_Name__c From Opportunity_Edit_Fields__r Order By Sort_Order__c) From Opportunity_Edit_Section__c Order By Sort_Order__c];
    this.toast = new SLDS_Toast();
  this.alerts = new AlertBar(this.toast);
    this.opportunityContacts = new List<OpportunityContactRole>();
    this.contacts = new List<Contact>();
    if (ApexPages.currentPage().getParameters().containsKey('id')) {
      Id recordId = ApexPages.currentPage().getParameters().get('id');
      if (recordId != null) {
        this.opportunityId = recordId;
        SoqlBuilder builder = new SoqlBuilder();
        builder.addAllFieldsForObject('Opportunity');
        builder.addWhere('Id', '=', recordId);
        List<SObject> sobjs = builder.getQueryResult();
        if(sobjs.size() == 1){
          this.opportunity = (Opportunity)sobjs[0];
          SoqlBuilder contactRoleBuilder = new SoqlBuilder();
          contactRoleBuilder.addAllFieldsForObject('OpportunityContactRole');
          contactRoleBuilder.addWhere('OpportunityId', '=', recordId);
          contactRoleBuilder.selectField('Contact.Name');
          contactRoleBuilder.selectField('Contact.Email');
          contactRoleBuilder.selectField('Contact.Phone');
          this.opportunityContacts = (List<OpportunityContactRole>)contactRoleBuilder.getQueryResult();
        }
      } else {
        this.opportunity = new Opportunity(Name='Default Opportunity', OwnerId = UserInfo.getUserId());
      }
    }else{
      this.opportunity = new Opportunity(Name='Default Opportunity', OwnerId = UserInfo.getUserId());
    }

    if (ApexPages.currentPage().getParameters().containsKey('accountid')) {
      String accountid = ApexPages.currentPage().getParameters().get('accountid');
      this.account = [SELECT Id, Name, SDO_Billing_Country_Name__c FROM Account WHERE Id = :accountid LIMIT 1];
      this.contacts = [SELECT Id, Name, Email, Phone FROM Contact WHERE AccountId = :accountid];
      this.opportunity.AccountId = accountid;
    }else{
      if(opportunity.AccountId != null){
        this.account = [SELECT Id, Name, SDO_Billing_Country_Name__c FROM Account WHERE Id = :opportunity.AccountId LIMIT 1];
        this.contacts = [SELECT Id, Name, Email, Phone FROM Contact WHERE AccountId = :opportunity.AccountId ORDER BY Name];
      }
    }
    this.sections = new List<Section>();
    for(Opportunity_Edit_Section__c section : this.editSections){
      this.sections.add(new Section(section));
    }
    this.navigator = new Navigator(this);
    this.steps = new Steps(this.navigator);
    this.idsToDelete = new Set<String>();
    this.contactManager = new ContactManager(this);
    if(this.contacts.size() > 0){
      this.contactManager.addContacts(this.contacts);
    }
    if(this.opportunityContacts.size() > 0){
      this.contactManager.addContactRoles(this.opportunityContacts);
    }
    this.updatePriceBook();
    this.productsController = new OpportunityProductsController(this);
    if (ApexPages.currentPage().getParameters().containsKey('step')) {
      String stepId = ApexPages.currentPage().getParameters().get('step');
      this.navigator.goToIndex(Integer.valueOf(stepId));
    } 
	}
  public void init(){

  }
  public Navigator navigator {get; set;}
  public OpportunityProductsController productsController {get; set;}
  public ContactManager contactManager {get; set;}
  public Set<String> idsToDelete {get; set;}
  public List<Contact> contacts {get; set;}
  public Account account {get; set;}
  public AlertBar alerts {get; set;}
  public Steps steps {get; set;}
  public List<OpportunityContactRole> opportunityContacts {get; set;}
  public String currentStep {get; set;}
  public List<Opportunity_Edit_Section__c> editSections   {get; set;}
  public SLDS_Toast toast { get; set; }
  public User currentUser {get; set;}
  public String opportunityId {get; set;}
  public Opportunity opportunity {get; set;}
  public List<Section> sections {get; set;}
  PriceBook2 currentPricebook;
  List<PricebookEntry> priceBookEntries;
  Set<String> practices;

  public class Section{
    public Section(Opportunity_Edit_Section__c section){
      this.name = section.Name;
      this.columnsSize = section.Columns__c;
      this.collapsible = section.Collapsible__c;
      this.eFields = section.Opportunity_Edit_Fields__r;
      this.columns = new Map<Integer, Column>();
      load();
    }
    public List<Opportunity_Edit_Field__c> eFields {get; set;}
    public Boolean collapsible {get; set;}
    public String name {get; set;}
    public Decimal columnsSize {get; set;}
    public Map<Integer, Column> columns {get; set;}
    public List<Column> getLayout(){
      return columns.values();
    }
    public void load(){
      Integer count = 0;
      for(Opportunity_Edit_Field__c f : this.eFields){
        if(columns.containsKey(count)){
          columns.get(count).fields.add(new Field(f));
        }else{
          Column col = new Column();
          col.fields.add(new Field(f));
          columns.put(count, col);
        }
        if(count + 1 == columnsSize){
          count = 0;
        }else{
          count++;
        }
        
      }
    }

  }
  public class Column{
    public Column(){
      this.fields = new List<Field>();
    }
    public List<Field> fields {get; set;}
  }
  public class Field{
    public Field(Opportunity_Edit_Field__c field){
      this.fieldName = field.Field_Name__c;
    }
    public String fieldName {get; set;}
  }
  public class Steps {
    public Steps(Navigator navigator){
      this.navigator = navigator;
      this.steps = new List<Step>();
      Step contacts = new Step('Opportunity Contacts', 0, 'Add or Update Opportunity Contact Roles', navigator);
      this.steps.add(contacts);
      Step details = new Step('Opportunity Details', 1, 'Update Opportunity Details', navigator);
      this.steps.add(details);
      Step products = new Step('Products', 2, 'Select Products and Services', navigator);
      this.steps.add(products);
      Step revsc = new Step('Revenue Schedule', 3, '', navigator);
      this.steps.add(revsc);
      this.currentStep = contacts;
    }

    public Decimal getStepPercent(){
      Decimal i = Decimal.valueOf(this.currentStep.num);
      Decimal size = Decimal.valueOf(this.steps.size()-1);
      Decimal per = i.divide(size, 2) * 100;
      return per;
    }
    public List<Step> steps {get; set;}
    public Step currentStep {get; set;}
    public Navigator navigator {get; set;}

    public Integer getStepNum(String stepName){
      for(Step s : steps){
        if(s.name == stepName){
          return s.num;
          break;
        }
      }
      return null;
    }
    public void setCurrentStep(Integer i){
      for(Step s : steps){
        if(s.num == i){
          this.currentStep = s;
        }
      }
    }
  }
  public Boolean isStepComplete(String stepName){
    if(stepName == 'Opportunity Contacts'){
      return isContactStepComplete();
    }else if(stepName == 'Opportunity Details'){
      return isDetailsStepComplete();
    }else if(stepName == 'Products'){
      return isProductsStepComplete();
    }else{
      return false;
    }
  }
  public class AlertBar{
    public AlertBar(SLDS_Toast toast){
      this.toast = toast;
    }
    public SLDS_Toast toast {get; set;}
    public void clearAlerts(){
      toast.showToast = false;
    }
    public void addError(String msg){
      toast.showToast = true;
      toast.toastMsg = msg;
      toast.toastType = SLDS_ToastEnum.ERROR;
    }
    public void addWarning(String msg){
      toast.showToast = true;
      toast.toastMsg = msg;
      toast.toastType = SLDS_ToastEnum.BASE;
    }
    public void addSuccess(String msg){
      toast.showToast = true;
      toast.toastMsg = msg;
      toast.toastType = SLDS_ToastEnum.SUCCESS;
    }
  }
  public class Step {
    public Step(String name, Integer num, String descript, Navigator navigator){
      this.name = name;
      this.num = num;
      this.descript = descript;
      this.navigator = navigator;
    }
    public String descript {get; set;}
    public String name {get; set;}
    public Integer num {get; set;}
    public Navigator navigator {get; set;}
    public void goToIndex(){
      navigator.goToIndex(this.num);
    }
  }
  public void priorStep(){
    alerts.clearAlerts();
    Step currentStep = steps.currentStep;
    if(currentStep.num > 0){
      steps.setCurrentStep(currentStep.num - 1);
    }
  }

  public class ContactManager{
    public ContactManager(OpportunityEditController ec){
      this.controller = ec;
      this.contacts = new Map<String, Contact>();
      this.contactRoles = new List<ContactRoleWrapper>();
      this.idsToDelete = new Set<String>();
    }
    public void addContacts(List<Contact> contacts){
      for(Contact c : contacts){
        this.contacts.put(c.Id, c);
        ContactRoleWrapper cw = new ContactRoleWrapper(this);
        cw.contact = c;
        this.contactRoles.add(cw);
      }
    }
    public void addContactRoles(List<OpportunityContactRole> ocrs){
      for(OpportunityContactRole ocr : ocrs){
        ContactRoleWrapper cw = new ContactRoleWrapper(this);
        cw.contact = this.getContact(ocr.ContactId);
        cw.contactRole = ocr;
        this.contactRoles.add(cw);
      }
    }
    public Contact getContact(String id){
      return this.contacts.get(id);
    }
    public List<ContactRoleWrapper> getContactRolesFiltered(){
      List<ContactRoleWrapper> cs = new List<ContactRoleWrapper>();
      for(ContactRoleWrapper cw : this.contactRoles){
        if(cw.isContactRole()){
          cs.add(cw);
        }
      }
      return cs;
    }
    public List<ContactRoleWrapper> getContacts(){
      List<ContactRoleWrapper> cs = new List<ContactRoleWrapper>();
      for(ContactRoleWrapper cw : this.contactRoles){
        if(!cw.isContactRole()){
          cs.add(cw);
        }
      }
      return cs;
    }
    private Boolean isOpportunityIdSet(){
      String s = this.getOpportunityId();
      return s != null;
    }
    private String getOpportunityId(){
      if(this.controller.opportunity.Id != null){
        return this.controller.opportunity.Id;
      }else{
        return null;
      }
    }
    private Boolean doesContactAlreadyExist(Id i){
      Boolean exists = false;
      List<ContactRoleWrapper> cws = this.getContactRolesFiltered();
      for(ContactRoleWrapper cw : cws){
        if(cw.contact.Id == i){
          exists = true;
          break;
        }
      }
      return exists;
    }
    public void addContactToContactRoles(Contact c){
      controller.alerts.clearAlerts();
      Id i = c.Id;
      if(!doesContactAlreadyExist(i)){
        ContactRoleWrapper cw = new ContactRoleWrapper(this);
        cw.contact = c;
        cw.contactRole = new OpportunityContactRole(ContactId=c.Id);
        if(this.getContactRolesFiltered().size() == 0){
          cw.contactRole.IsPrimary = true;
        }
        this.contactRoles.add(cw);
        controller.alerts.addSuccess(C.Name + ' has been added.');
      }else{
        controller.alerts.addWarning(C.Name + ' has already been added.');
      }
      
    }
    public void makePrimaryContact(Contact con){
      controller.alerts.clearAlerts();
      List<ContactRoleWrapper> cws = this.getContactRolesFiltered();
      for(ContactRoleWrapper cw : cws){
        if(cw.contact.Id == con.ID){
          cw.contactRole.IsPrimary = true;
          controller.alerts.addSuccess(con.Name+' is now the primary contact');
        }else{
          cw.contactRole.IsPrimary = false;
        }
      }
    }
    public Set<String> idsToDelete {get; set;}
    public List<ContactRoleWrapper> contactRoles {get; set;}

    Map<String, Contact> contacts {get; set;}
    OpportunityEditController controller {get; set;}
  }
  public class ContactRoleWrapper{
    public ContactRoleWrapper(ContactManager controller){
      this.controller = controller;
    }
    ContactManager controller {get; set;}
    public Contact contact {get; set;}
    public OpportunityContactRole contactRole {get; set;}
    public void addToContactRoles(){
      this.controller.addContactToContactRoles(this.contact);
    }
    public void makePrimaryContact(){
      this.controller.makePrimaryContact(this.contact);
    }
    public Boolean isContactRole(){
      return this.contactRole != null;
    }
  }
/*  public void addContactToContactRoles(Contact con){
    OpportunityContactRole ocr = new OpportunityContactRole();
    //ocr.OpportunityId = this.opportunity.Id;
    oc.ContactId = con.Id;
  }*/
  public void nextStep(){
    alerts.clearAlerts();
    Step currentStep = steps.currentStep;
    if(currentStep.num == 0){
      if(isStepComplete(currentStep.name)){
        steps.setCurrentStep(1);
      }else{
        String msg = '';
        if(opportunity.AccountId == null){
          msg+='You must have an account selected. ';
        }
        if(!hasContacts()){
          msg+='You must have at least one contact selected. ';
        }
        if(msg != '') alerts.addError(msg);
      }
    }else if(currentStep.num == 1){
      if(isStepComplete(currentStep.name)){
        steps.setCurrentStep(2);
      }else{
        String msg = '';
        alerts.addError(msg);
      }
    }else if(currentStep.num == 2){
      if(isStepComplete(currentStep.name)){
        steps.setCurrentStep(3);
      }else{
        String msg = '';
        alerts.addError(msg);
      }
    }
  }

  

  public Boolean hasContacts(){
    return contactManager.getContactRolesFiltered().size() > 0;// && areContactRolesSet();
  }
  public Boolean areContactRolesSet(){
    Boolean roleSet = true;
    for(ContactRoleWrapper cw : contactManager.getContactRolesFiltered()){
      if(cw.contactRole.Role == null || cw.contactRole.Role == ''){
        roleSet = false;
        alerts.addError(cw.contact.Name +' does not have a role selected');
        break;
      }
    }
    return roleSet;
  }
  private Boolean isProductsStepComplete(){
    return true;
  }
  private Boolean isDetailsStepComplete(){
    return true;
  }
  private Boolean isContactStepComplete(){
    return (opportunity.AccountId != null && hasContacts() && areContactRolesSet());
  }

  public Set<String> getPractices(){
    return this.practices;
  }

  public List<PricebookEntry> getProducts(){
    return this.priceBookEntries;
  }

  public void updatePriceBook(){
    if(opportunity.Pricebook2Id != null ){
      setOpportunityPriceBook(opportunity.Pricebook2Id);
      setPriceBookEntries(opportunity.Pricebook2Id);
      setPractices(opportunity.Pricebook2Id);
    }else{

    }

  }

  public void setPractices(String priceBookId){
    if(this.practices == null || (this.currentPriceBook != null && this.currentPricebook.Id != priceBookId)){
      Set <String> practiceNames = new Set <String>();
      List <PricebookEntry> pbEntries = [select id, Product2.Practice__c from PricebookEntry where IsActive = true and Pricebook2Id = :priceBookId];
      for (PricebookEntry pbEntry : pbEntries) {
        practiceNames.add(pbEntry.Product2.Practice__c);
      }
      this.practices = practiceNames;
    }
  }

  public void setPriceBookEntries(String priceBookId){
    if(this.priceBookEntries == null || (this.currentPriceBook != null && this.currentPricebook.Id != priceBookId)){
      List <PricebookEntry> pbEntries = [SELECT Id, Product2.Practice__c FROM PricebookEntry WHERE IsActive = true AND Pricebook2Id = :priceBookId];
      if(pbEntries != null){
        this.priceBookEntries = pbEntries;
      }else{
        this.priceBookEntries = new List<PricebookEntry>();
      }
    }
    
  }
  public void setOpportunityPriceBook(String priceBookId){
    if(this.currentPricebook == null || this.currentPricebook.Id != priceBookId){
      Pricebook2 pb2 = [SELECT Name, Id FROM Pricebook2 WHERE isActive = true AND Id = :priceBookId LIMIT 1];
      if(pb2 != null){
        this.currentPriceBook = pb2;
      }
    }
  }

  private Boolean isAccountNorthAmerica(){
    if(this.account == null || this.account.SDO_Billing_Country_Name__c == null){
      return false;
    }
    String country = this.account.SDO_Billing_Country_Name__c;
    if(country.equalsIgnoreCase('United States') || country.equalsIgnoreCase('Canada')){
      return true;
    }
    return false;
  }

  public class Navigator{
    public Navigator(OpportunityEditController controller){
      this.controller = controller;
    }
    public void goToIndex(Integer i){
      controller.steps.setCurrentStep(i);
    }
    public void goToContacts(){
      this.goToIndex(0);
    }
    public void goToDetails(){
      this.goToIndex(1);
    }
    public void goToProducts(){
      this.goToIndex(2);
    }
    public OpportunityEditController controller {get; set;}
  }
 

}