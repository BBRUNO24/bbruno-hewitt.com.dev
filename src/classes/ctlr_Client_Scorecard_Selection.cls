//Implemented for Case 10713. Chintan Adhyapak. June 18, 2012 
public class ctlr_Client_Scorecard_Selection{

    private final Account account;
    public String financialYear {get; set;} //user selected parameter from selection panel
    public String quarter       {get; set;} //user selected parameter from selection panel
    public List<SelectOption> validFinancialYears; //used to populate dropdown on user selection panel
    public List<SelectOption> validQuarters; //used to populate dropdown on user selection panel

    //getter for validFinancialYears 
    public List<SelectOption> getValidFinancialYears() {
        Map<string, schema.sobjectfield> fieldsMap = Schema.SObjectType.Client_Satisfaction_Data__c.fields.getMap();
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '--Select--'));
        for (Schema.PicklistEntry p : fieldsMap.get('Year__c').getDescribe().getPicklistValues()) {
            options.add(new SelectOption(p.getValue(), p.getLabel()));
        }
        return options;
    } //getValidFinancialYears
    
    
    //getter for validQuarters
    public List<SelectOption> getValidQuarters() {
        Map<string, schema.sobjectfield> fieldsMap = Schema.SObjectType.Client_Satisfaction_Data__c.fields.getMap();
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '--Select--'));
        for (Schema.PicklistEntry p : fieldsMap.get('Quarter__c').getDescribe().getPicklistValues()) {
            options.add(new SelectOption(p.getValue(), p.getLabel()));
        }
        return options;
    } //getValidQuarters
    

    // Constructor
    public ctlr_Client_Scorecard_Selection(ApexPages.StandardController controller) {
        Account currAcct = (Account)controller.getRecord();
        this.account = [SELECT Name, Market__c, Owner.Name, Aon_Hewitt_Executive_Sponsor__c, Global_Region__c  FROM Account WHERE ID = :currAcct.ID];
    }
    
    
    //Method to redirect user to the scorecard 
    public PageReference printScorecard() {
        PageReference retPage = null;
        if (account.Global_Region__c.equalsIgnoreCase('North America')) {
        	String pgURL = '/apex/Client_Scorecard?id=' + account.Id + '&year=' + financialYear + '&quarter=' + quarter;
        	retPage = new PageReference(pgURL);
        } else if (account.Global_Region__c.equalsIgnoreCase('Asia Pacific')) {
        	String pgURL = '/apex/Client_Scorecard_APAC?id=' + account.Id + '&year=' + financialYear + '&quarter=' + quarter;
        	retPage = new PageReference(pgURL);
        }
        System.debug('CPA returning: ' + retPage);
        return retPage;
    } //printScorecard
}