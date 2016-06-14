public global class ctlr_AccountNowCopyRedirect {

    public String accountIdToGet    {get;set;}
    public String confirmationTxt   {get;set;}
    public List<Account> accntRecList {get;set;}
    public Integer countLog {get;set;}
    
    public ctlr_AccountNowCopyRedirect(){
        this.countLog = 0;
    }
    
    public Pagereference init(){
        this.accountIdToGet = ApexPages.currentPage().getParameters().get('acctid'); 
        findAccount();
        return null;
    }
    
    public Pagereference returnHome(){
        return new PageReference ('/home/home.jsp');
    }
    
    public Pagereference openCopiedAccount(){
        return new PageReference('/'+this.accountIdToGet);
    }
    
    public PageReference findAccount(){
        
        System.debug('findAccount: ' + this.accountIdToGet + ' - ' + this.accountIdToGet.substring(0, 15) );
        
        this.accntRecList = [Select ID From Account Where Opposite_Org_Account_ID__c = : this.accountIdToGet.substring(0, 15) ];
        System.debug('accntRecID: ' + this.accntRecList);
        if (this.accntRecList != null && this.accntRecList.size() > 0){
            return new PageReference('/'+this.accntRecList[0].Id);
        }else{
            return null;
        }
    }
    
    @RemoteAction
    global static String findCopiedAccount(string accntid) {
        
        // debug
        System.debug('attempting to locate account: ' + accntid);
        
        // declare local vars
        String cpyId = '';
        
        if(accntid != null && accntid.length() > 14) {
            System.debug('executing query...');
            List<Account> accntRecList = [Select ID From Account Where Opposite_Org_Account_ID__c = : accntid.substring(0, 15) ];
            System.debug('query returned ' + accntRecList.size() + ' results: ' + accntRecList);
            
            if(accntRecList !=null && accntRecList.size() > 0){
                cpyId = accntRecList[0].Id;
            }
        }
        
        System.debug('findCopiedAccount: ' +  cpyId );
        return cpyId;
    }
}