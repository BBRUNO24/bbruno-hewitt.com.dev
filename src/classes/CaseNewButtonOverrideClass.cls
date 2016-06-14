/************************************************************************************************************
Author: Nishant Sinha
Class Name: CaseNewButtonOverrideClass
Purpose: 
When 'New Case' button is clicked, the reporting attributes of the case will already be populated with the reporting attributes 
of the corresponding contact record of the logged in user.          
**************************************************************************************************************/ 
public class CaseNewButtonOverrideClass 
{
    User usrObj = new User();
    public static Contact contObj = new Contact();
    Id recTypeId;
    
    /********************************************************************************
                            CONSTRUCTOR
    ********************************************************************************/    
    public CaseNewButtonOverrideClass(ApexPages.StandardController controller) 
    {
    }
    /*******************************************************************************/

        
         
        public PageReference newCasePage()
        {        

        String currentUserId = UserInfo.getUserId();
        System.debug('currentUserId*******'+currentUserId);
                
        try
        {
            contObj = [select Id, User_ID__c, Corresponding_User_ID__c, Reporting_Business_Unit_Region__c, Reporting_Country__c, Reporting_Office__c, Reporting_Region__c from Contact where Corresponding_User_ID__c =: currentUserId];
        }
        catch (Exception e) {}              
        System.debug('contObj*******: '+contObj);         
                     
        recTypeId = ApexPages.currentPage().getParameters().get('RecordType');
        System.debug('recTypeId*******'+recTypeId);
        
        PageReference pageRef = new PageReference('/500/e?retURL=%2F500%2Fo&RecordType='+recTypeId+'&nooverride=1'+'&00N30000005rU4u=' + contObj.Reporting_Office__c + '&00N30000005saqO=' + contObj.Reporting_Business_Unit_Region__c +'&00N30000005rU4k=' + contObj.Reporting_Country__c +'&00N30000005sanP=' + contObj.Reporting_Region__c);
        System.debug('pageRef*******'+pageRef);
      
        pageRef.setRedirect(true);
        return pageRef;
   
        }
}