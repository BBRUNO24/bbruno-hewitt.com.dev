//00091993-Ritu Sharma-Added to override the standard detail page layout
public with sharing class ctlr_OpportunityView {
  public ctlr_OpportunityView(ApexPages.StandardController controller) {
  }
  public Id getRecordId() {
    if (ApexPages.currentPage().getParameters().containsKey('id')) {
      Id recordId = ApexPages.currentPage().getParameters().get('id');
      if (recordId != null) {
        return recordId;
      } else {
        return '';
      }
    }
    return '';
  }
  public Integer getContactCount() {
    if (ApexPages.currentPage().getParameters().containsKey('id')) {
      Id recordId = ApexPages.currentPage().getParameters().get('id');
      if (recordId != null) {
        return [SELECT COUNT() FROM OpportunityContactRole WHERE OpportunityId = :recordId];
      } else {
        return 0;
      }
    }
    return 0;
  }
  public PageReference init() {
    try {
      Opportunity opp = [select ID from Opportunity where Id = : ApexPages.currentPage().getParameters().get('id') Limit 1];
      ApexPages.StandardController stdController = new ApexPages.StandardController(opp);
      ctlr_TabbedProductList controller = new ctlr_TabbedProductList(stdController);
      String redirectTo = controller.getRevenueSchedulePage();

      if (redirectTo != '') {
        pagereference page = new pagereference(redirectTo);
        page.setredirect(true);
        return page;
      }
    } catch (Exception e) {
      apexPages.addMessages(e);
    }
    return null;
  }
}