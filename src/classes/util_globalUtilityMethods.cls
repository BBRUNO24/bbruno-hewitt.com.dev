public global class util_globalUtilityMethods {
    
    public static Boolean checkRestrictDupExternalContacts=False;  //Case No. 00006090 - Added a static variable to avoid recurssive calls of restrictDupExternalContacts function of blogic_Contact class
    //global static variable used to prevent multiple calls to any function in update triggers
    private static Boolean runOnceFlag = False; 
    
    //Getter for global flag
    public static boolean getRunOnceFlag() {
        return runOnceFlag;
    }
    
    
    //Setter for global flag
    public static void setRunOnceFlag(Boolean flag) {
        runOnceFlag = flag;
    }
    
    
    
    public static String generateRandomString(Integer numChars) {
        
        //declare local vars 
        String randomNumString = ''; 
        String returnVal = ''; 
        List <String> charArray = new String [] {'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','0','1','2','3','4','5','6','7','8','9','-','$','#','!','@','+','=','%'};
        
        // determine how many random number strings we need 
        //System.debug('Number of requested characters: ' + numChars);
        
        // generate the requisite random number strings 
        for (Integer x = 0; x < 100; x++) {
            // generate a random number
            String tempStr = String.valueOf(Math.random()); 
            //System.debug('Generated random number string: ' + tempStr);
            
            // take all of the digits to the right of the decimal point
            randomNumString += tempStr.substring(2);
            //System.debug('Running random number string: ' + randomNumString);
             
            // determine if we have enough characters
            if (randomNumString.length() >= numChars) {
                //System.debug('Number string has ' + randomNumString.length() + ' chars and is long enough');
                x = 101;
            }
        }
        // trim the string if we ran over
        if (randomNumString.length() > numChars) {
            //System.debug('Generated string is too long.  Trimming...');
            randomNumString = randomNumString.substring(0,numChars);
            //System.debug('Trimming complete.  Requested Length: ' + numChars + '; Actual Length: ' + randomNumString.length());
            //System.debug('Final Random Number String: ' + randomNumString);
        }
        
        // build the random character string
        for (Integer x = 0; x < randomNumString.length(); x++) {
        
            // declare local vars
            String currentNum = '';
            String newChar = '';
            String randomNum = String.valueOf(Math.random());
            Integer ndxMultiplier = 0;
        
            // get a handle on the current character
            currentNum = randomNumString.substring(x,x+1);
            //System.debug('Current number char is: ' + currentNum);
            
            // get the multiplier from the new random number string
            for (Integer y = 2; y < randomNum.length(); y++) {
                ndxMultiplier = Integer.valueOf(randomNum.substring(y,y+1));
                if (ndxMultiplier < 8) {
                    newChar = charArray[ndxMultiplier * Integer.valueOf(currentNum)];
                    y = randomNum.length();
                }
            }
            returnVal += newChar; 
        }
        //System.debug('Generated Random String: ' + returnVal);
        
        // return the random character string
        return returnVal;
    }
    
    public static String joinStringSet(List <String> values, Boolean wrapValuesInSingleQuotes) {
        String returnVal = '';
        
        for (Integer x = 0; x < values.size(); x++) {
        
        /*if(values.get(x)=='First_Year_Value__c')
        {
        values.set(x,'convertCurrency(First_Year_Value__c)');
        }*/
            if (wrapValuesInSingleQuotes) { 
                returnVal += '\'' + values.get(x) + '\'';
            } else {
                returnVal += values.get(x);
            }
            if (x != (values.size() - 1) ) {
                returnVal += ',';
            } 
        }
        
        System.debug('#####################'+returnVal);
        return returnVal;
    }
    
    public static String joinStringSet(Set <String> values, Boolean wrapValuesInSingleQuotes) {
        List <String> temp = new List<String>();
        temp.addAll(values);
        return joinStringSet(temp, wrapValuesInSingleQuotes);       
    }
    
    public static List<String> getFieldsForObject(String so) {
        Integer i;
        List<String> f = new List<String>();
   
        SObjectType sot = Schema.getGlobalDescribe().get(so);
        if (sot == null) return null;
   
        List<Schema.SObjectField> fields = sot.getDescribe().fields.getMap().values();
       
        for (i = 0; i < fields.size(); i++)
            f.add(fields[i].getDescribe().LocalName);
               
        return f;
    } 
    
    public static void logMessage_INFO(String msg) {
        System.debug(LoggingLevel.INFO, msg);
    }
    
    public static void generateLongID(List<sObject> newRecords, String objectType) {
        //local var
        Map<Id, String> recordIdMap = new Map<Id, String> ();
        
        //grab inbound IDs and store as Strings
        for (integer x = 0; x < newRecords.size(); x++) {
            sObject myRecord = newRecords[x];
            recordIdMap.put(myRecord.Id, String.valueOf(myRecord.Id));
        }
        
        //Call asynch method to save long Ids
        setLongID_asynch(recordIdMap, objectType);
    }
    
    @future
    private static void setLongID_asynch(Map<Id, String> recordIdMap, String objectType) {
        //local var
        List<SObject> recordsToUpdate = null;
        List<Id> listOfIds = new List<Id> ();
        
        //Pull record IDs to update
        for (Id newRecordId : recordIdMap.keySet()) {
            //System.debug('Incoming ID: ' + newRecordId);
            listOfIds.add(newRecordId);
        }
        
        //retrieve the records to update
        System.debug('querying for records...');
        recordsToUpdate = Database.query('select id, long_id__c from ' + objectType + ' where id IN: listOfIds');
        System.debug('retrieved ' + recordsToUpdate.size() + ' records: ' + recordsToUpdate);
        
        //iterate over the records and stamp them with the long id
        for (SObject record : recordsToUpdate) {
            System.debug('Record Before: ' + record);
            record.put('long_id__c', recordIdMap.get((Id)record.get('id')));
            System.debug('Record After: ' + record);
        }
        //update the records
        update recordsToUpdate;
    }
    
    
    /***********************************************************************************
    * Builds a SOQL query equivelant to a SELECT * SQL statement for the SobjectType 
    * passed as a parameter to the function. 
    * EXAMPLE USAGE -
    * String strSOQL = getSelectStarSOQL(Custom_Object__c.getsObjectType()); 
    */
    public static String getSelectStarSOQL (Schema.SObjectType objectType) {
        String selectStarSOQL;
        Set<String> objectFieldNames = new Set<String>();

        objectFieldNames.addAll(objectType.getDescribe().fields.getMap().keySet());
        objectFieldNames.removeAll(new List<String>{'isdeleted', 'createdbyid', 'createddate', 'lastmodifiedbyid', 'lastmodifieddate', 'systemmodstamp'});        
    
        selectStarSOQL = 'SELECT ';
        for (String fieldName : objectFieldNames) {
            selectStarSOQL += fieldName + ', ';
        }
        selectStarSOQL = selectStarSOQL.substring(0,selectStarSOQL.length()-2);
        //selectStarSOQL += ' FROM ' + objectType.getDescribe().getName();
    
        return selectStarSOQL;
  } //getSelectStarSOQL
  

}