public abstract class AccountSearchController {
/*   
    public final String SEARCH='SEARCH';
    public final String DETAIL='DETAIL';
    public final String AON_ACCOUNT='Aon_Accounts__c';
    public final String HEWITT_ACCOUNT='Hewitt_Accounts__c';
    public final Integer MAX_COUNT=100;
    public final Integer MAX_SEARCH=100;
    public final String MAX_COUNT_ERR_MSG = 'You have reached the maximum number of allowable search for today. Please contact your system administrator.';
    public final String MAX_SEARCH_ERR_MSG = 'Your search results returned more than ' + MAX_SEARCH + ' records. Please refine your search criteria and click on the search button.';
    public Boolean isTest = false;
    public String operation {get;set;}
    public String selectedAccountId {get;set;}
    public Account_Search__c accountSearch {get;set;}
    public String displayType {
        get {
            if(displayType==null || displayType=='')
                displayType=SEARCH;
            return displayType;
        }
        set;}

    public void redirect() {
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String stype = getParamValue('type',params);


        String saccountName = getParamValue('accountname',params);
        String semail = getParamValue('email',params);
        String sname = getParamValue('fullname',params);
        if(stype!=null && stype.equalsIgnoreCase('direct')
        && semail!=null && semail.length()>0
        && sname!=null && sname.length()>0
        && saccountName!=null && saccountName.length()>0) {
            accountSearch.Full_Name__c=sname;
            accountSearch.Email__c=semail;
            accountSearch.Search_Account_Name__c=saccountName;

            String scity = getParamValue('city',params);
            accountSearch.Search_City__c= (scity!=null && scity.length()>0) ? scity : '';
            String sstate = getParamValue('state',params);
            accountSearch.Search_State__c= (sstate!=null && sstate.length()>0) ? sstate : '';
            directDisplayAccountDetail();
        }
    }

    public abstract void directDisplayAccountDetail();

    public String getParamValue(String s, Map<String,String> params) {
        String value = params.get(s);
        if(value!=null && value.length()>0)
            value = EncodingUtil.urlDecode(value, 'UTF-8');
        return value;
    }

    public void insertAccountSearch(){
        insertAccountSearch(accountSearch.Full_Name__c,
                            accountSearch.Email__c,
                            accountSearch.Search_Account_Name__c,
                            accountSearch.Search_City__c,
                            accountSearch.Search_State__c
                            );
    }

    public Integer insertAccountSearch(String fullname, String email, String criteria, String city, String state) {
        Map<String,String> headerMap = ApexPages.currentPage().getHeaders();
        String ipAddress = headerMap.get('True-Client-IP');
        if(ipAddress==null || ipAddress=='')
            ipAddress=(headerMap.get('X-Salesforce-SIP')!=null) ? headerMap.get('X-Salesforce-SIP') : '';

        Account_Search__c accountSearch = new Account_Search__c(Search_Account_Name__c=criteria,
                                                                Email__c=email,
                                                                Full_Name__c=fullname,
                                                                Search_Timestamp__c=System.now(),
                                                                User_IP_Address__c=ipAddress,
                                                                Search_City__c=city,
                                                                Search_State__c=state
                                                                );
        insert accountSearch;

        //Integer icount = [Select count() From Account_Search__c where CreatedDate > TODAY];
        //if(icount>MAX_COUNT || isTest)
        //  addErrorMessage(MAX_COUNT_ERR_MSG);

        return 0;
    }

    //Add Error Message
    public void addErrorMessage(String errMsg) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, errMsg));
    }

    public List<SObject> doSearch(Map<String, Schema.SObjectField> fieldsMap, String objectName) {
        String sfields = getObjectFields(fieldsMap);
        String criteria = ' WHERE Name LIKE \'%' + String.escapeSingleQuotes(accountSearch.Search_Account_Name__c) + '%\'';
        if(accountSearch.Search_City__c!=null && accountSearch.Search_City__c.length()>0)
            criteria = criteria + ' AND City__c LIKE \'%' + String.escapeSingleQuotes(accountSearch.Search_City__c) + '%\'';
        if(accountSearch.Search_State__c!=null && accountSearch.Search_State__c.length()>0)
            criteria = criteria + ' AND State__c LIKE \'%' + String.escapeSingleQuotes(accountSearch.Search_State__c) + '%\'';
        criteria = criteria + ' ORDER BY NAME LIMIT ' + (MAX_SEARCH + 1);
        String sql = buildSQLStatement(sfields, objectName, criteria);
        return processSObjectList(retrieveObjectRecord(sql),MAX_SEARCH);
    }

    public List<SObject> processSObjectList(List<SObject> sObjList, Integer maxSearch) {
        System.debug('>>> processSObjectList 111 sObjList.size - maxSearch = ' + sObjList.size() + ' - ' + maxSearch);
        if(sObjList!=null && sObjList.size() > maxSearch) {
            System.debug('>>> processSObjectList 222 sObjList.size - maxSearch = ' + sObjList.size() + ' - ' + maxSearch);
             addErrorMessage(MAX_SEARCH_ERR_MSG);
             sObjList.remove(sObjList.size()-1);
            System.debug('>>> processSObjectList 333 sObjList.size - maxSearch = ' + sObjList.size() + ' - ' + maxSearch);
        }
        System.debug('>>> processSObjectList 444 sObjList.size - maxSearch = ' + sObjList.size() + ' - ' + maxSearch);
        return sObjList;
    }

    public Map<String, Schema.SObjectField> getAONAccountFieldMap() {
         return Schema.SobjectType.Aon_Accounts__c.fields.getMap();
    }

    public Map<String, Schema.SObjectField> getHewittAccountFieldMap() {
         return Schema.SobjectType.Hewitt_Accounts__c.fields.getMap();
    }

    //Construct and build sql statement based on the fields name object name, and criteria
    public String buildSQLStatement(String fields, String objectName, String criteria) {
        String sql = 'Select ' + fields + ' from ' + objectName + (criteria != null && !''.equals(criteria) ? criteria : '');
        return sql;
    }

    //Retrieve meta-data fields name from SObject
    public String getObjectFields(Map<String, Schema.SObjectField> fieldsMap) {
        String ssql = '';
        Boolean bfirst = true;
        for(String fieldName:fieldsMap.keySet()) {
            if(bfirst) {
                ssql = fieldName;
                bfirst = false;
            } else {
                ssql = ssql + ',' + fieldName;
            }
        }
        return ssql;
    }
    //Retrieve the record from SObject
    public List<SObject> retrieveObjectRecord(String sql) {
        return Database.query(sql);
    }

    public Aon_Accounts__c getAonAccountById(String accountId) {
        List<Aon_Accounts__c> accountList = [Select a.TOC_Human_Capital_Communication__c,
                                                    a.State__c,
                                                    a.Name,
                                                    a.Id,
                                                    a.Health_Management_Health_and_Benefits__c,
                                                    a.Country__c,
                                                    a.City__c,
                                                    a.Account_Owner__c,
                                                    a.Account_Owner_Phone__c,
                                                    a.Account_Owner_Email__c,
                                                    a.Outsourcing__c,
                                                    a.Retirement_Financial_Mgmt_Retirement__c
                                               From Aon_Accounts__c a
                                              Where a.Id = :accountId
                                             ];

        if(accountList!=null && !accountList.isEmpty())
            return accountList[0];
        return null;
    }


    public List<Aon_Related_Opportunity__c> getAonRelatedOpportunityList(String accountId) {
        return [Select a.Product_Service_Type__c, a.Opportunity_Stage__c, a.Name, a.Id, a.Aon_Account__c,
                       a.Opportunity_Owner__c, a.Opportunity_Owner_Email__c, a.Opportunity_Owner_Phone__c
                  From Aon_Related_Opportunity__c a
                 Where a.Aon_Account__c = :accountId
               ];
    }

    public Hewitt_Accounts__c getHewittAccountById(String accountId) {
        List<Hewitt_Accounts__c> accountList = [Select a.TOC_Human_Capital_Communication__c,
                                                    a.State__c,
                                                    a.Name,
                                                    a.Id,
                                                    a.Health_Management_Health_and_Benefits__c,
                                                    a.Country__c,
                                                    a.City__c,
                                                    a.Account_Owner__c,
                                                    a.Account_Owner_Phone__c,
                                                    a.Account_Owner_Email__c,
                                                    a.Outsourcing__c,
                                                    a.Retirement_Financial_Mgmt_Retirement__c
                                               From Hewitt_Accounts__c a
                                              Where a.Id = :accountId
                                             ];

        if(accountList!=null && !accountList.isEmpty())
            return accountList[0];
        return null;
    }


    public List<Hewitt_Related_Opportunity__c> getHewittRelatedOpportunityList(String accountId) {
        return [Select a.Product_Service_Type__c, a.Opportunity_Stage__c, a.Name, a.Id, a.Hewitt_Account__c,
                       a.Opportunity_Owner__c, a.Opportunity_Owner_Email__c, a.Opportunity_Owner_Phone__c
                  From Hewitt_Related_Opportunity__c a
                 Where a.Hewitt_Account__c = :accountId
               ];
    }
    */

}