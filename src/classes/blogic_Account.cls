//This class handles business logic tied to the Account Object
//Chintan Adhyapak, June 10, 2011 
public without sharing class blogic_Account {

    //This method handles all CAPIS ID maintenance
    public static void assignCapisId(List<Account> accounts) {
        //local vars
        integer lowNumRec = 0;
        integer highNumRec = 0;
        decimal capisId = 0;
        integer extraRec = 0;
        Set <Integer> accountIdsToUpdateLow = new Set<Integer>();
        Set <Integer> accountIdsToUpdateHigh = new Set<Integer>();
        Set <Integer> reservedLowCAPISIds = new Set<Integer>();
        Set <Integer> reservedHighCAPISIds = new Set<Integer>();
        Organizational_Defaults__c orgSettings = null;
        
        // determine if CAPIS ID assignment is enabled
        System.debug('getting organizational defaults...');
        orgSettings = Organizational_Defaults__c.getInstance();
        System.debug('retrieved: ' + orgSettings);
        
        if (orgSettings.Enable_CAPIS_Id_Assignment__c) {
        
            //Get the record type Id for Client Records
            Id clientRecordId = [Select Id from RecordType where sObjectType = 'Account' and isActive = true and Name = 'Client Account Record Type' limit 1].Id;
            System.debug('Client Account Type Id read is: ' + clientRecordId);
            
            //Get the number of incoming records that need a capis id
            for(Integer x = 0; x < accounts.size(); x++) {
                //System.debug('CPA RecordTypeId: ' + accounts[x].RecordTypeId);
                //System.debug('CPA Financial System: ' + accounts[x].Legacy_Hewitt_Financial_System__c);
                //System.debug('CPA Account Status: ' + accounts[x].Account_Status__c);
                //System.debug('CPA CAPIS ID: ' + accounts[x].CAPIS_ID__c);
                //System.debug('CPA Additional CAPIS ID: ' + accounts[x].Additional_CAPIS_Indicator__c);
                //System.debug('CPA Global Region: ' + accounts[x].Global_Region__c);
                if((accounts[x].RecordTypeId == clientRecordId) &&
                    //Commenting out Financial System and adding Account Type = Client per Case 110622, Chintan, 3/13/2014 
                    //(accounts[x].Legacy_Hewitt_Financial_System__c == 'Peoplesoft') && 
                    (accounts[x].ACW_Client_Type__c == 'Client') &&
                    (accounts[x].Account_Status__c == 'Active') && 
                    (accounts[x].CAPIS_ID__c == null) && 
                    (accounts[x].Additional_CAPIS_Indicator__c != null) &&
                    (accounts[x].Global_Region__c == 'North America')) 
                {
                    if (accounts[x].Additional_CAPIS_Indicator__c.equalsIgnoreCase('yes')) {
                        lowNumRec++;
                        accountIdsToUpdateLow.add(x);
                    } else if (accounts[x].Additional_CAPIS_Indicator__c.equalsIgnoreCase('no')) {
                        highNumRec++;
                        accountIdsToUpdateHigh.add(x);
                    }
                }
            }
            System.debug('Number of Accounts that need a low CAPIS ID is ' + lowNumRec);
            System.debug('Number of Accounts collected that need a low CAPIS ID is ' + accountIdsToUpdateLow.size());
            System.debug('Number of Accounts that need a high CAPIS ID is ' + highNumRec);
            System.debug('Number of Accounts collected that need a high CAPIS ID is ' + accountIdsToUpdateHigh.size());
            
            // only bother with low CAPIS Ids if a low CAPIS account was found
            if (lowNumRec > 0) {
            
                // get CAPIS IDs 
                reservedLowCAPISIds = reserveLowCapisIds(lowNumRec);
                
                // verify we received enough ids
                if (reservedLowCAPISIds.size() != lowNumRec) {
                    System.debug('WARNING!  Not enough low CAPIS Ids were reserved!');
                }
                
                // iterate over the accounts and assign CAPIS Ids where possible
                integer myCount = 0;
                for (Integer x = 0; x < accounts.size(); x++) {
                    if (accountIdsToUpdateLow.contains(x)) {
                        System.debug('reservedLowCAPISIds size is ' + reservedLowCAPISIds.size());
                        if (reservedLowCAPISIds.size() > 0) {
                            Integer idToAssign = -1;
                            for (Integer temp : reservedLowCAPISIds) {
                                System.debug('Assigning capis id ' + temp + ' to account ' + accounts[x].Name);
                                idToAssign = temp;
                                myCount++;
                                break;
                            }
                            reservedLowCAPISIds.remove(idToAssign);
                            accounts[x].CAPIS_ID__c = String.valueOf(idToAssign);
                        } else {
                            System.debug('ERROR!  Unable to assign CAPIS ID to record.  Erring the record.');
                            accounts[x].addError('ERROR!  Unable to secure a CAPIS ID for assignment.');
                        }
                    }   
                }
                System.debug(myCount + ' Accounts were assigned a low capis id');
            }
                        
            // only bother with high CAPIS Ids if a high CAPIS account was found
            if (highNumRec > 0) {
                // get CAPIS IDs 
                reservedHighCAPISIds = reserveHighCapisIds(highNumRec);
                
                // verify we received enough ids
                if (reservedHighCapisIds.size() != highNumRec) {
                    System.debug('WARNING!  Not enough high CAPIS Ids were reserved!');
                }
                
                // iterate over the accounts and assign CAPIS Ids where possible
                integer myCount = 0;
                for (Integer x = 0; x < accounts.size(); x++) {
                    if (accountIdsToUpdateHigh.contains(x)) {
                        System.debug('reservedLowCAPISIds size is ' + reservedHighCAPISIds.size());
                        if (reservedHighCAPISIds.size() > 0) {
                            Integer idToAssign = -1;
                            for (Integer temp : reservedHighCAPISIds) {
                                System.debug('Assigning capis id ' + temp + ' to account ' + accounts[x].Name);
                                idToAssign = temp;
                                myCount++;
                                break;
                            }
                            reservedHighCAPISIds.remove(idToAssign);
                            accounts[x].CAPIS_ID__c = String.valueOf(idToAssign);
                        } else {
                            System.debug('ERROR!  Unable to assign CAPIS ID to record.  Erring the record.');
                            accounts[x].addError('ERROR!  Unable to secure a CAPIS ID for assignment.');
                        }
                    }   
                }
                System.debug(myCount + ' Accounts were assigned a high capis id');
            }
            
        } else {
            System.debug('CAPIS Id Assignment DISABLED.');
        }
    } //assignCapisId
    
    
    //This method returns a set of reserved low range CAPIS IDs
    private static Set <Integer> reserveLowCapisIds(Integer numIdsToReserve) {
        
        Integer numTries = 0;
        decimal remainingCAPISIds = 0;
        decimal capisId = 0;
        Set <Integer> reservedIds = new Set <Integer>();
        
        while ((reservedIds.size() < numIdsToReserve) && (numTries < 2)) {
            
            // determine how many ids we need to get
            numIdsToReserve -= reservedIds.size(); 
            
            // Read last capis Id
            Last_CAPIS_Id__c lastCapisIdInfo = [SELECT Id, Name, Low_Range_Last_Id__c, Low_Range_Upper_Limit__c from Last_CAPIS_Id__c limit 1 for update];
            capisId = lastCapisIdInfo.Low_Range_Last_Id__c;
            remainingCAPISIds = lastCapisIdInfo.Low_Range_Upper_Limit__c - lastCapisIdInfo.Low_Range_Last_Id__c; 
            System.debug('Last low CAPIS ID read initially is ' + capisId);
            System.debug('Remaining low CAPIS Ids: ' + (remainingCAPISIds - 1));
            
            // warn if not enough capis ids exist
            if (numIdsToReserve >= remainingCAPISIds) {
                System.debug('WARNING, NOT ENOUGH LOW CAPIS REMAIN!');
                numIdsToReserve = remainingCAPISIds.intValue() - 1;
                System.debug('adjusting num to reserve to: ' + numIdsToReserve); 
            }
            
            //Reserve the needed number of capis ids
            System.debug('Adding the required number of ids onto the existing count...');
            System.debug('Adding ' + numIdsToReserve + ' ids onto the block of reserved numbers...');
            lastCapisIdInfo.Low_Range_Last_Id__c += numIdsToReserve;
            System.debug('Updating last capis id to ' + lastCapisIdInfo.Low_Range_Last_Id__c);
            Database.Saveresult saveResult = Database.update(lastCapisIdInfo);
            System.debug('update returned the following result: ' + saveResult);
                
            // if the reservation was successful, proceed
            if (saveResult.isSuccess()) {
                
                Integer initialCapisIdAsInteger = capisId.intValue();
                Integer maxCapisIdAsInteger = initialCapisIdAsInteger + numIdsToReserve;
                
                // add the reserved ids into the collection of reserved ids
                for (Integer x = initialCapisIdAsInteger + 1; x <= maxCapisIdAsInteger; x++) {
                    reservedIds.add(x);
                }
                     
                System.debug('initial capis id reservation was performed successfully.  assessing whether any additional ids must be reserved due to collision with existing records...');
                List <Account> accountCollisions = [select id, CAPIS_ID__c, CAPIS_As_Number__c from Account where CAPIS_As_Number__c > :initialCapisIdAsInteger and CAPIS_As_Number__c <= :maxCapisIdAsInteger];
                if (!accountCollisions.isEmpty()) {
                    System.debug('check for collisions returned ' + accountCollisions.size() + ' collisions: ' + accountCollisions);
                    System.debug('removing collisions from collected set');
                    for (Account accountCollision : accountCollisions) {  
                        Integer capisAsInteger = accountCollision.CAPIS_As_Number__c.intValue();
                        reservedIds.remove(capisAsInteger);
                    }
                } else {
                    System.debug('no collisions detected');
                }
                
            } else {
                System.debug('ERROR!  Unable to reserve the necesary capis ids...');
            }
            numTries++;
        }
        System.debug('returning ' + reservedIds.size() + ' reserved ids: ' + reservedIds);
        return reservedIds;
    } //reserveLowCapisIds
    
    
    //This method returns a set of reserved high range CAPIS IDs
    private static Set <Integer> reserveHighCapisIds(Integer numIdsToReserve) {
        
        Integer numTries = 0;
        decimal remainingCAPISIds = 0;
        decimal capisId = 0;
        Set <Integer> reservedIds = new Set <Integer>();
        
        while ((reservedIds.size() < numIdsToReserve) && (numTries < 2)) {
            
            // determine how many ids we need to get
            numIdsToReserve -= reservedIds.size(); 
            
            // Read last capis Id
            Last_CAPIS_Id__c lastCapisIdInfo = [SELECT Id, Name, High_Range_Last_Id__c from Last_CAPIS_Id__c limit 1 for update];
            capisId = lastCapisIdInfo.High_Range_Last_Id__c;
            System.debug('Last high CAPIS ID read initially is ' + capisId);
            
            //Reserve the needed number of capis ids
            System.debug('Adding the required number of ids onto the existing count...');
            System.debug('Adding ' + numIdsToReserve + ' ids onto the block of reserved numbers...');
            lastCapisIdInfo.High_Range_Last_Id__c += numIdsToReserve;
            System.debug('Updating last capis id to ' + lastCapisIdInfo.High_Range_Last_Id__c);
            Database.Saveresult saveResult = Database.update(lastCapisIdInfo);
            System.debug('update returned the following result: ' + saveResult);
                
            // if the reservation was successful, proceed
            if (saveResult.isSuccess()) {
                
                Integer initialCapisIdAsInteger = capisId.intValue();
                Integer maxCapisIdAsInteger = initialCapisIdAsInteger + numIdsToReserve;
                
                // add the reserved ids into the collection of reserved ids
                for (Integer x = initialCapisIdAsInteger + 1; x <= maxCapisIdAsInteger; x++) {
                    reservedIds.add(x);
                }
                     
                System.debug('initial capis id reservation was performed successfully.  assessing whether any additional ids must be reserved due to collision with existing records...');
                List <Account> accountCollisions = [select id, CAPIS_ID__c, CAPIS_As_Number__c from Account where Global_Region__c = 'North America' and CAPIS_ID__c != null and CAPIS_As_Number__c > :initialCapisIdAsInteger and CAPIS_As_Number__c <= :maxCapisIdAsInteger];
                if (!accountCollisions.isEmpty()) {
                    System.debug('check for collisions returned ' + accountCollisions.size() + ' collisions: ' + accountCollisions);
                    System.debug('removing collisions from collected set');
                    for (Account accountCollision : accountCollisions) {  
                        Integer capisAsInteger = accountCollision.CAPIS_As_Number__c.intValue();
                        reservedIds.remove(capisAsInteger);
                    }
                } else {
                    System.debug('no collisions detected');
                }
                
            } else {
                System.debug('ERROR!  Unable to reserve the necesary capis ids...');
            }
            numTries++;
        }
        
        System.debug('returning ' + reservedIds.size() + ' reserved ids: ' + reservedIds);
        return reservedIds;
    } //reserveHighCapisIds
    
   
    //This method sets the Global Region, Region and Market fields on the Account based on Country 
    //Reading Market Leader Email and Region Director Email and setting it on Accounts as part of Case 11082. June 22, 2012 - Chintan
    public static void setAccountRegionMarket(List<Account> newAccountList){
        //local vars
        Map <String, String> usGlobalRegionMap = new Map<String, String>();
        Map <String, String> usRegionMap = new Map<String, String>();
        Map <String, String> usMarketMap = new Map<String, String>();
        Map <String, String> caGlobalRegionMap = new Map<String, String>();
        Map <String, String> caRegionMap = new Map<String, String>();
        Map <String, String> caMarketMap = new Map<String, String>();
        Map <String, String> otherGlobalRegionMap = new Map<String, String>();
        Map <String, String> otherRegionMap = new Map<String, String>();
        Map <String, String> otherMarketMap = new Map<String, String>();
        boolean needUSMapping = false;
        boolean needCanadaMapping = false;
        boolean needOtherMapping = false;
        
        //Check which mappings we need to query for
        for (Account newAccount : newAccountList) {
            String country = newAccount.SDO_Billing_Country_Name__c;
            String state = newAccount.BillingState;
            boolean isOverride = newAccount.Region_Market_Override__c;
            if (!isOverride) {
                if (country == 'United States' && state == 'PR') {
                    needUSMapping = true;
                } else if (country == 'United States') {
                    needUSMapping = true;
                } else if (country == 'Canada') {
                    needCanadaMapping = true;
                } else {
                    needOtherMapping = true;
                }
            }
        }
        
        //Read Market Lead and Region Director Email info into Maps
        List<Zip_Code_To_Market_Mapping__c> zipList = [Select Market_Lead_Email__c, Region_Director_Email__c, Market__c from Zip_Code_To_Market_Mapping__c where Market__c <> ''];
        Map<String, String> marketLeadEmailMap = new Map<String, String> ();
        Map<String, String> regionDirectorEmailMap = new Map<String, String> ();
        for (Zip_Code_to_Market_Mapping__c myZip : zipList) {
            marketLeadEmailMap.put(myZip.Market__c, myZip.Market_Lead_Email__c);
            regionDirectorEmailMap.put(myZip.Market__c, myZip.Region_Director_Email__c);
        }
        
        //Read the mapping data into local vars so that we do not query the object for every record in case of bulk updates
        if (needUSMapping) {
            System.debug('CHINTAN Reading US Mappings...');
            Zip_Code_to_Market_Mapping__c[] usMapping = [Select z.Name, z.Market__c, z.Region__c, z.Global_Region__c From Zip_Code_to_Market_Mapping__c z WHERE z.Country__c = 'United States'];
            for (Zip_Code_to_Market_Mapping__c myUsMap : usMapping) {
                usGlobalRegionMap.put(myUsMap.Name, myUsMap.Global_Region__c);
                usRegionMap.put(myUsMap.Name, myUsMap.Region__c);
                usMarketMap.put(myUsMap.Name, myUsMap.Market__c);
            }
        }
        //Read Canadian Mapping data
        if (needCanadaMapping) {
            System.debug('CHINTAN Reading Canada Mappings...');
            Zip_Code_to_Market_Mapping__c[] caMapping = [Select z.State__c, z.Market__c, z.Region__c, z.Global_Region__c From Zip_Code_to_Market_Mapping__c z WHERE z.Country__c = 'Canada'];
            for (Zip_Code_to_Market_Mapping__c myCaMap : caMapping) {
                caGlobalRegionMap.put(myCaMap.State__c, myCaMap.Global_Region__c);
                caRegionMap.put(myCaMap.State__c, myCaMap.Region__c);
                caMarketMap.put(myCaMap.State__c, myCaMap.Market__c);
            }
        }
        //Read Mapping for Other Countries
        if (needOtherMapping) {
            System.debug('CHINTAN Reading Other Mappings...');
            Zip_Code_to_Market_Mapping__c[] otherMapping = [Select z.Country__c, z.Market__c, z.Region__c, z.Global_Region__c From Zip_Code_to_Market_Mapping__c z WHERE z.Country__c != 'United States' AND z.Country__c != 'Canada' AND z.Country__c != ''];
            for (Zip_Code_to_Market_Mapping__c myOtherMap : otherMapping) {
                otherGlobalRegionMap.put(myOtherMap.Country__c, myOtherMap.Global_Region__c);
                otherRegionMap.put(myOtherMap.Country__c, myOtherMap.Region__c);
                otherMarketMap.put(myOtherMap.Country__c, myOtherMap.Market__c);
            }
        }
        
        //Now cycle through the data and set values
        for (Account newAccount : newAccountList) {
            String country = newAccount.SDO_Billing_Country_Name__c;
            String state = newAccount.BillingState;
            boolean isOverride = newAccount.Region_Market_Override__c;
            System.debug('CHINTAN Account Country is ' + country + ' and Override is ' + isOverride);
            if (!isOverride) {
                if (country == 'United States' && state != 'PR') {
                    newAccount.Global_Region__c = usGlobalRegionMap.get(newAccount.Zip_code_first_3_digits__c);
                    newAccount.Region__c = usRegionMap.get(newAccount.Zip_code_first_3_digits__c);
                    newAccount.Market__c = usMarketMap.get(newAccount.Zip_code_first_3_digits__c);
                } else if (country == 'United States' && state == 'PR') {
                    newAccount.Global_Region__c = 'Latin America';
                    newAccount.Region__c = 'Caribbean';
                    newAccount.Market__c = 'Puerto Rico';
                } else if (country == 'Canada') {
                    newAccount.Global_Region__c = caGlobalRegionMap.get(newAccount.BillingState);
                    newAccount.Region__c = caRegionMap.get(newAccount.BillingState);
                    newAccount.Market__c = caMarketMap.get(newAccount.BillingState);
                    //Exception for Ottawa
                    if ((newAccount.BillingCity != null) && (newAccount.BillingCity.equalsIgnoreCase('Ottawa'))) {
                        newAccount.Region__c = 'CA - East';
                    }
                } else if (otherGlobalRegionMap.get(country) != null) {
                    newAccount.Global_Region__c = otherGlobalRegionMap.get(country);
                    newAccount.Region__c = otherRegionMap.get(country);
                    newAccount.Market__c = otherMarketMap.get(country);
                } else {
                    newAccount.Region__c = '';
                    newAccount.Market__c = '';
                }
            }
            
            //Put Emails
            newAccount.Market_Lead_Email__c = marketLeadEmailMap.get(newAccount.Market__c);
            newAccount.Region_Director_Email__c = regionDirectorEmailMap.get(newAccount.Market__c);
            
            System.debug('CHINTAN set Global Region as ' + newAccount.Global_Region__c);
            System.debug('CHINTAN set Region as ' + newAccount.Region__c);
            System.debug('CHINTAN set Market as ' + newAccount.Market__c);
            System.debug('CHINTAN set Market Lead Email as ' + newAccount.Market_Lead_Email__c);
            System.debug('CHINTAN set Region Director Email as ' + newAccount.Region_Director_Email__c);
        } //for
    } //setAccountRegionMarket
    
    
    //This method updates the Global Region, Region and Market fields on the Account based on Country 
    //August 30, 2012 - Chintan
    public static void updateAccountRegionMarket(List<Account> oldAccounts, List<Account> newAccounts){
        //local vars
        Map <String, String> usGlobalRegionMap = new Map<String, String>();
        Map <String, String> usRegionMap = new Map<String, String>();
        Map <String, String> usMarketMap = new Map<String, String>();
        Map <String, String> caGlobalRegionMap = new Map<String, String>();
        Map <String, String> caRegionMap = new Map<String, String>();
        Map <String, String> caMarketMap = new Map<String, String>();
        Map <String, String> otherGlobalRegionMap = new Map<String, String>();
        Map <String, String> otherRegionMap = new Map<String, String>();
        Map <String, String> otherMarketMap = new Map<String, String>();
        Map<String, String> marketLeadEmailMap = new Map<String, String> ();
        Map<String, String> regionDirectorEmailMap = new Map<String, String> ();
        boolean needUSMapping = false;
        boolean needCanadaMapping = false;
        boolean needOtherMapping = false;
        boolean needEmailMapping = true;
        
        //Check which mappings we need to query for
        for (integer i=0; i<newAccounts.size(); i++) {
            //System.debug('CHINTAN oldAccount Country is: ' + oldAccounts[i].SDO_Billing_Country_Name__c + '; Global Region is: ' + oldAccounts[i].Global_region__c + '; Region is: ' + oldAccounts[i].Region__c + '; Market is: ' + oldAccounts[i].Market__c + '; Zip is: ' + oldAccounts[i].Zip_code_first_3_digits__c);
            //System.debug('CHINTAN newAccount Country is: ' + newAccounts[i].SDO_Billing_Country_Name__c + '; Global Region is: ' + newAccounts[i].Global_region__c + '; Region is: ' + newAccounts[i].Region__c + '; Market is: ' + newAccounts[i].Market__c + '; Zip is: ' + oldAccounts[i].Zip_code_first_3_digits__c);
            boolean isOverride = newAccounts[i].Region_Market_Override__c;
            if (!isOverride) {
                if ((newAccounts[i].SDO_Billing_Country_Name__c == 'United States') && ((oldAccounts[i].Zip_code_first_3_digits__c != newAccounts[i].Zip_code_first_3_digits__c) || 
                        (oldAccounts[i].SDO_Billing_Country_Name__c != newAccounts[i].SDO_Billing_Country_Name__c) || (oldAccounts[i].Global_Region__c != newAccounts[i].Global_Region__c) ||
                        (oldAccounts[i].Region__c != newAccounts[i].Region__c) || (oldAccounts[i].Market__c != newAccounts[i].Market__c) ||(oldAccounts[i].BillingState != newAccounts[i].BillingState))) {
                    needUSMapping = true;
                } else if ((newAccounts[i].SDO_Billing_Country_Name__c == 'Canada') && ((oldAccounts[i].BillingState != newAccounts[i].BillingState) || (oldAccounts[i].BillingCity != newAccounts[i].BillingCity) ||
                        (oldAccounts[i].SDO_Billing_Country_Name__c != newAccounts[i].SDO_Billing_Country_Name__c) || (oldAccounts[i].Global_Region__c != newAccounts[i].Global_Region__c) ||
                        (oldAccounts[i].Region__c != newAccounts[i].Region__c) || (oldAccounts[i].Market__c != newAccounts[i].Market__c))) {
                    needCanadaMapping = true;
                } else if ((newAccounts[i].SDO_Billing_Country_Name__c != oldAccounts[i].SDO_Billing_Country_Name__c) && (newAccounts[i].SDO_Billing_Country_Name__c != 'United States') && (newAccounts[i].SDO_Billing_Country_Name__c != 'Canada')) {
                    needOtherMapping = true;
                }
            }
        }
        
        //Read the mapping data into local vars so that we do not query the object for every record in case of bulk updates
        System.debug('CHINTAN needUSMapping is ' + needUSMapping);
        if (needUSMapping) {
            System.debug('CHINTAN Reading US Mappings...');
            Zip_Code_to_Market_Mapping__c[] usMapping = [Select z.Name, z.Market__c, z.Region__c, z.Global_Region__c From Zip_Code_to_Market_Mapping__c z WHERE z.Country__c = 'United States'];
            for (Zip_Code_to_Market_Mapping__c myUsMap : usMapping) {
                usGlobalRegionMap.put(myUsMap.Name, myUsMap.Global_Region__c);
                usRegionMap.put(myUsMap.Name, myUsMap.Region__c);
                usMarketMap.put(myUsMap.Name, myUsMap.Market__c);
            }
        }
        
        //Read Canadian Mapping data
        System.debug('CHINTAN needCanadaMapping is ' + needCanadaMapping);
        if (needCanadaMapping) {
            System.debug('CHINTAN Reading Canada Mappings...');
            Zip_Code_to_Market_Mapping__c[] caMapping = [Select z.State__c, z.Market__c, z.Region__c, z.Global_Region__c From Zip_Code_to_Market_Mapping__c z WHERE z.Country__c = 'Canada'];
            for (Zip_Code_to_Market_Mapping__c myCaMap : caMapping) {
                caGlobalRegionMap.put(myCaMap.State__c, myCaMap.Global_Region__c);
                caRegionMap.put(myCaMap.State__c, myCaMap.Region__c);
                caMarketMap.put(myCaMap.State__c, myCaMap.Market__c);
            }
        }
        
        //Read Mapping for Other Countries
        System.debug('CHINTAN needOtherMapping is ' + needOtherMapping);
        if (needOtherMapping) {
            System.debug('CHINTAN Reading Other Mappings...');
            Zip_Code_to_Market_Mapping__c[] otherMapping = [Select z.Country__c, z.Market__c, z.Region__c, z.Global_Region__c From Zip_Code_to_Market_Mapping__c z WHERE z.Country__c != 'United States' AND z.Country__c != 'Canada' AND z.Country__c != ''];
            for (Zip_Code_to_Market_Mapping__c myOtherMap : otherMapping) {
                otherGlobalRegionMap.put(myOtherMap.Country__c, myOtherMap.Global_Region__c);
                otherRegionMap.put(myOtherMap.Country__c, myOtherMap.Region__c);
                otherMarketMap.put(myOtherMap.Country__c, myOtherMap.Market__c);
            }
        }
        
        //Spin through and process each record
        for (integer i=0; i<newAccounts.size(); i++) {
            Account newAccount = newAccounts[i];
            String country = newAccount.SDO_Billing_Country_Name__c;
            String state = newAccount.BillingState;
            boolean isOverride = newAccount.Region_Market_Override__c;
            System.debug('CHINTAN Account Country is ' + country + ' and Override is ' + isOverride+' and needsUsMapping = '+needUSMapping+' and needCanadaMapping = '+needCanadaMapping+' and needOtherMapping = '+needOtherMapping);
            if (!isOverride) {
                if (needUSMapping && (country == 'United States') && (state != 'PR')) {
                    System.debug('Needs US Mapping: and regional amp is: ');
                    System.debug(usGlobalRegionMap);
                    System.debug(newAccount);
                    newAccount.Global_Region__c = usGlobalRegionMap.get(newAccount.Zip_code_first_3_digits__c);
                    newAccount.Region__c = usRegionMap.get(newAccount.Zip_code_first_3_digits__c);
                    newAccount.Market__c = usMarketMap.get(newAccount.Zip_code_first_3_digits__c);
                } else if (needUSMapping && (country == 'United States') && (state == 'PR')) {
                    newAccount.Global_Region__c = 'Latin America';
                    newAccount.Region__c = 'Caribbean';
                    newAccount.Market__c = 'Puerto Rico';
                } else if (needCanadaMapping && (country == 'Canada')) {
                    newAccount.Global_Region__c = caGlobalRegionMap.get(newAccount.BillingState);
                    System.debug('CHINTAN Setting Region as ' + caRegionMap.get(newAccount.BillingState));
                    newAccount.Region__c = caRegionMap.get(newAccount.BillingState);
                    newAccount.Market__c = caMarketMap.get(newAccount.BillingState);
                    //Exception for Ottawa
                    if ((newAccount.BillingCity != null) && (newAccount.BillingCity.equalsIgnoreCase('Ottawa'))) {
                        System.debug('CHINTAN Ottawa Exception. Setting Region to CA - East');
                        newAccount.Region__c = 'CA - East';
                    }
                } else if (needOtherMapping && (otherGlobalRegionMap.get(country) != null)) {
                    newAccount.Global_Region__c = otherGlobalRegionMap.get(country);
                    newAccount.Region__c = otherRegionMap.get(country);
                    newAccount.Market__c = otherMarketMap.get(country);
                } else if (needOtherMapping) {
                    newAccount.Region__c = '';
                    newAccount.Market__c = '';
                }
            }
            //Do we need to update Market Lead and Region Director Emails
            if (oldAccounts[i].Market__c != newAccount.Market__c) {
                System.debug('CHINTAN Account Market has changed from ' + oldAccounts[i].Market__c + ' to ' + newAccounts[i].Market__c);
                //Grab all the Emails once 
                if (needEmailMapping) {
                    System.debug('CHINTAN Reading zipToMarket for Email Data');
                    List<Zip_Code_To_Market_Mapping__c> zipList = [Select Market_Lead_Email__c, Region_Director_Email__c, Market__c from Zip_Code_To_Market_Mapping__c where Market__c <> ''];
                    for (Zip_Code_to_Market_Mapping__c myZip : zipList) {
                        marketLeadEmailMap.put(myZip.Market__c, myZip.Market_Lead_Email__c);
                        regionDirectorEmailMap.put(myZip.Market__c, myZip.Region_Director_Email__c);
                    }
                    needEmailMapping = false;
                }
                newAccount.Market_Lead_Email__c = marketLeadEmailMap.get(newAccount.Market__c);
                newAccount.Region_Director_Email__c = regionDirectorEmailMap.get(newAccount.Market__c);
            }
            System.debug('CHINTAN set Global Region as ' + newAccount.Global_Region__c);
            System.debug('CHINTAN set Region as ' + newAccount.Region__c);
            System.debug('CHINTAN set Market as ' + newAccount.Market__c);
            System.debug('CHINTAN set Market Lead Email as ' + newAccount.Market_Lead_Email__c);
            System.debug('CHINTAN set Region Director Email as ' + newAccount.Region_Director_Email__c);
        } //for
    } //updateAccountRegionMarket
   
    
    /** This method prevents the duplicate entry of an internal contact into the Internal Account Team for an account with the same role 
      * v2 - Rewritten to only check for single entry roles. Other logic moved to non code solution. Use a custom setting instead of hard coded values. Chintan. Aug 29, 2012    
    */
    public static void checkDuplicateInternalAccountTeamEntry(List <Internal_Account_Team__c> iatList) {
        //local vars
        List<String> newAccountIdList = new List<String>();
        Set<String> singleEntryRolesSet = new Set<String> ();
    
        for(Internal_Account_Team__c myTeam : iatList) {
            newAccountIdList.add(myTeam.Account__c);
        }
        
        //Read Single Entry Roles
        List<Single_Entry_Roles__c> roleList = [Select Name from Single_Entry_Roles__c];
        for (Single_Entry_Roles__c myRole : roleList) {
            singleEntryRolesSet.add(myRole.Name);
        }
    
        //Read all existing records for incoming Accounts and Single Entry Roles
        List<Internal_Account_Team__c> existingIATlist = [Select Contact_Role__c, Account__c From Internal_Account_Team__c where Account__c in :newAccountIdList AND Contact_Role__c in :singleEntryRolesSet];
        System.debug('CHINTAN existingIATlist size is '+existingIATlist.size());
    
        if(existingIATlist.size() > 0) {
            //Store the combinaton of Account Id and Role as a string that serves as a unique Identifier
            Set<String> existingRecordsIdSet = new Set<String> ();
            for (Internal_Account_Team__c myTeam : existingIATlist) {
                existingRecordsIdSet.add(myTeam.Account__c + '-' + myTeam.Contact_Role__c);
            } 
            
            for(Internal_Account_Team__c myTeam : iatList) {
                String myAccount = myTeam.Account__c;
                String id1 = myAccount + '-' + myTeam.Contact_Role__c;
                String id2 = myAccount.substring(0,15) + myTeam.Contact_Role__c; 
                System.debug('CHINTAN Unique Identifier Strings are '+ id1 + ' and ' + id2);
                
                //Restrict duplicate entry in the Internal Account Team for certain roles which are restricted to only one per account.
                if(singleEntryRolesSet.contains(myTeam.Contact_Role__c) && (existingRecordsIdSet.contains(id1) || existingRecordsIdSet.contains(id2))) {
                    System.debug('CHINTAN Detected Duplicate Entry for given role');
                    myTeam.addError('A Contact with the role '+ myTeam.Contact_Role__c+ ' already exists. Please select some other Role.');
                    break;
                }
                //Add this record itself in case there are dups in the incoming data. Chintan Adyapak, May 8, 2015
                existingRecordsIdSet.add(id1);
                existingRecordsIdSet.add(id2);
            }
        }
    } //checkDuplicateInternalAccountTeamEntry
    

    
    /** This method ties a US Account to its matching territory before account insertion.
      * Chintan. February 15, 2012 
      * Case 58092. Territories for Canada. Chintan, March 22, 2013 */
    public static void tieAccountToTerritory(List<Account> newAccounts) {
        System.debug('CHINTAN tieAccountToTerritory START');
        //local vars
        Map<String, Id> USterritoryMap = new Map<String, Id> ();
        Map<String, Id> CAterritoryMap = new Map<String, Id> ();
        boolean needUSTerritory = false;
        boolean needCATerritory = false;
        
        //Check for US or Canadian accounts
        for (Account account : newAccounts) {
            if (account.SDO_Billing_Country_Name__c == 'United States' && account.Account_Status__c != 'Defunct') needUSTerritory = true;
            else if (account.SDO_Billing_Country_Name__c == 'Canada' && account.Account_Status__c != 'Defunct') needCATerritory = true;
        }
        
        //Only proceed if there is something to process
        if (needUSTerritory) {
            //Read all US territories
            List <Territory__c> territories = [SELECT Public_Group_Id__c, Name, Id from Territory__c Where Country__c = 'United States'];
            //Put the data in a map for easy retrieval
            for (Territory__c territory : territories) {
                USterritoryMap.put(territory.Name, territory.Id);
            }
        }
        if (needCATerritory) {
            //Read all Canadian territories
            List <Territory__c> territories = [SELECT Areas_included_in_Territory__c, Id from Territory__c Where Country__c = 'Canada'];
            //Put the data in a map for easy retrieval
            for (Territory__c territory : territories) {
                System.debug('CHINTAN Areas Included in Territory: ' + territory.Areas_included_in_Territory__c);
                String[] provinces = territory.Areas_included_in_Territory__c.split(';', 0);
                for (String province : provinces) {
                    System.debug('CHINTAN Adding Province ' + province + ' to Map');
                    CAterritoryMap.put(province, territory.Id);
                }
            }
        }
        //Spin through and process
        for (Account account : newAccounts) {
            if ((account.SDO_Billing_Country_Name__c == 'United States') && (account.BillingState != null) && (USterritoryMap.get(account.BillingState.toUpperCase()) != null)) {
                //Assign Territory
                account.Territory__c = USterritoryMap.get(account.BillingState.toUpperCase());
                System.debug('CHINTAN Setting Territory ' + account.BillingState);
            }
            if ((account.SDO_Billing_Country_Name__c == 'Canada') && (account.BillingState != null) && (CAterritoryMap.get(account.BillingState.toUpperCase()) != null)) {
                //Assign Territory with Exception for Ottawa
                if ((account.BillingCity != null) && (account.BillingCity.equalsIgnoreCase('Ottawa')))
                    account.Territory__c = CAterritoryMap.get('QC');
                else
                    account.Territory__c = CAterritoryMap.get(account.BillingState.toUpperCase());
                System.debug('CHINTAN Setting Territory ' + account.BillingState);
            }
        }
    } //tieAccountToTerritory
    
    
    /** This method ties a US Account to its matching public group after account insertion.
      * Chintan. February 16, 2012 
      * Case 58092. Public Groups for Canada. Chintan, March 22, 2013 */
    public static void tieAccountToPublicGroup(List<Account> newAccounts) {
        System.debug('CHINTAN tieAccountToPublicGroup START');
        boolean needPublicGroup = false;
        
        //Check for US or Canadian accounts
        for (Account account : newAccounts) {
            if ((account.SDO_Billing_Country_Name__c == 'United States' || account.SDO_Billing_Country_Name__c == 'Canada')  && (account.Account_Status__c != 'Defunct')) 
                needPublicGroup = true;
        }
        
        //Only proceed if there is something to process
        if (needPublicGroup) {
            //local vars
            Map<Id, Id> publicGroupMap = new Map<Id, Id> ();
            List<AccountShare> accountSharesToAdd = new List<AccountShare> ();
        
            //Read all US and Canadian territories
            List <Territory__c> territories = [SELECT Public_Group_Id__c, Name, Id from Territory__c Where Country__c = 'United States' Or Country__c = 'Canada'];
            //Put the data in a map for easy retrieval
            for (Territory__c territory : territories) {
                publicGroupMap.put(territory.Id, territory.Public_group_Id__c);
            }
        
            //Spin through and process
            for (Account account : newAccounts) {
                if (((account.SDO_Billing_Country_Name__c == 'United States') || (account.SDO_Billing_Country_Name__c == 'Canada')) && (account.Territory__c != null) && (publicGroupMap.get(account.Territory__c) != null)) {
                    //Public Group Membership
                    AccountShare myAccountShare = new AccountShare();
                    myAccountShare.AccountId = account.Id;
                    myAccountShare.UserOrGroupId = publicGroupMap.get(account.Territory__c);
                    myAccountShare.AccountAccessLevel= 'Edit';
                    myAccountShare.OpportunityAccessLevel = 'Edit';
                    myAccountShare.ContactAccessLevel = 'Edit';
                    accountSharesToAdd.add(myAccountShare);
                }
            }
            if (accountSharesToAdd.size() > 0) {
                System.debug('CHINTAN ' + accountSharesToAdd.size() + ' AccountShare Record to Add');
                try {
                    insert accountSharesToAdd;
                } catch (Exception e) {
                    System.debug('CHINTAN Error inserting accountShare record');
                }
            }
        }
    } //tieAccountToPublicGroup
    
    
    /** Private Method to support updateAccountTerritory public method
      * Chintan, March 25, 2013 */
    private static void populateTerritoryAndPublicGroupMaps(Map<String, Id> territoryMap, Map<Id, Id> publicGroupMap) {
        for (Territory__c territory : [SELECT Public_Group_Id__c, Name, Areas_included_in_Territory__c, Country__c, Id from Territory__c Where Country__c = 'United States' Or Country__c = 'Canada']) {
            if (territory.Country__c.equalsIgnoreCase('United States')) {
                territoryMap.put(territory.Name.toUpperCase(), territory.Id);
                publicGroupMap.put(territory.Id, territory.Public_group_Id__c);
            } else {
                String[] provinces = territory.Areas_included_in_Territory__c.split(';', 0);
                for (String province : provinces) {
                    territoryMap.put(province.toUpperCase(), territory.Id);
                }
                publicGroupMap.put(territory.Id, territory.Public_group_Id__c);
            }
        }
        System.debug('populateTerritoryAndPublicGroupMaps returning territoryMap keysey: ' + territoryMap.keySet());
    } //populateTerritoryAndPublicGroupMaps
    
    
    /** Private Method to support updateAccountTerritory public method
      * Chintan, March 25, 2013 */
    private static AccountShare getAccountShareRecord(Account account, Map<Id, Id> publicGroupMap) {
        AccountShare accountShare = new AccountShare();
        accountShare.AccountId = account.Id;
        accountShare.UserOrGroupId = publicGroupMap.get(account.territory__c);
        accountShare.AccountAccessLevel= 'Edit';
        accountShare.OpportunityAccessLevel = 'Edit';
        accountShare.ContactAccessLevel = 'Edit';
        return accountShare;
    } //getAccountShareRecord
    
    
    /** This method ties a US Account to its matching territory and public group
      * Chintan. February 15, 2012
      * Case 58092. Support for Canada. Chintan, March 25, 2013 */
    public static void updateAccountTerritory(List<Account> oldAccounts, List<Account> newAccounts) {
        System.debug('CHINTAN updateAccountTerritory START');
        //local vars
        Map<String, Id> territoryMap = new Map<String, Id> ();
        Map<Id, Id> publicGroupMap = new Map<Id, Id> ();
        Map<Id, Id> accountShareMap = new Map<Id, Id> ();
        List<AccountShare> accountSharesToAdd = new List<AccountShare> ();
        List<AccountShare> accountSharesToDelete = new List<AccountShare> ();
        boolean found = false;
        
        //Spin through and process
        for (integer i=0; i<newAccounts.size(); i++) {
            Account oldAccount = oldAccounts[i];
            Account newAccount = newAccounts[i];
            String oldCountry = oldAccount.SDO_Billing_Country_Name__c;
            String newCountry = newAccount.SDO_Billing_Country_Name__c;
            String oldStatus = oldAccount.Account_Status__c;
            String newStatus = newAccount.Account_Status__c;
            
            //Defunct processing
            if (oldStatus == 'Defunct' && newStatus == 'Defunct') {
                continue;
            }
            
            //US processing
            if (oldCountry == 'United States' || newCountry == 'United States') {
                if (oldCountry == 'United States' && newCountry != 'United States') {
                    if ((oldStatus != 'Defunct' && newStatus == 'Defunct') || (oldStatus != 'Defunct' && newStatus != 'Defunct')) {
                        System.debug('CHINTAN Wiping out US Territory');
                        newAccount.Territory__c = null;
                    
                        //Delete AccountShare
                        if (!found) {
                            populateTerritoryAndPublicGroupMaps(territoryMap, publicGroupMap);
                            found = true;
                        }
                        accountShareMap.put(oldAccount.Id, publicGroupMap.get(oldAccount.territory__c));
                    }
                } else if (oldCountry != 'United States' && newCountry == 'United States') {
                    if ((oldStatus == 'Defunct' && newStatus != 'Defunct') || (oldStatus != 'Defunct' && newStatus != 'Defunct')) {
                        if (!found) {
                            populateTerritoryAndPublicGroupMaps(territoryMap, publicGroupMap);
                            found = true;
                        }
                        System.debug('CHINTAN Mapping US Account to territory ' + newAccount.BillingState);
                        newAccount.Territory__c = territoryMap.get(newAccount.BillingState.toUpperCase());
                    
                        //Add AccountShare Record
                        accountSharesToAdd.add(getAccountShareRecord(newAccount, publicGroupMap));
                    }
                } else if (oldAccount.BillingState != newAccount.BillingState) {
                    System.debug('CHINTAN Changing US territory from ' + oldAccount.BillingState + ' to ' + newAccount.BillingState);
                    if ((oldStatus != 'Defunct' && newStatus == 'Defunct') || (oldStatus != 'Defunct' && newStatus != 'Defunct')) {
                        //Wipe out Territory
                        newAccount.Territory__c = null;
                        if (!found) {
                            populateTerritoryAndPublicGroupMaps(territoryMap, publicGroupMap);
                            found = true;
                        }
                        //Delete old accountshare
                        if (oldAccount.territory__c != null) {
                            accountShareMap.put(oldAccount.Id, publicGroupMap.get(oldAccount.territory__c));
                        }
                    }
                    if ((oldStatus == 'Defunct' && newStatus != 'Defunct') || (oldStatus != 'Defunct' && newStatus != 'Defunct')) {
                        if (!found) {
                            populateTerritoryAndPublicGroupMaps(territoryMap, publicGroupMap);
                            found = true;
                        }
                        newAccount.Territory__c = territoryMap.get(newAccount.BillingState.toUpperCase());
                    
                        //Add AccountShare Record
                        accountSharesToAdd.add(getAccountShareRecord(newAccount, publicGroupMap));
                    }
                } else if (oldStatus != 'Defunct' && newStatus == 'Defunct') {
                    //Wipe out Territory
                    newAccount.Territory__c = null;
                    if (!found) {
                        populateTerritoryAndPublicGroupMaps(territoryMap, publicGroupMap);
                        found = true;
                    }
                    //Delete old accountshare
                    if (oldAccount.territory__c != null) {
                        accountShareMap.put(oldAccount.Id, publicGroupMap.get(oldAccount.territory__c));
                    }
                } else if (oldStatus == 'Defunct' && newStatus != 'Defunct') {
                    if (!found) {
                        populateTerritoryAndPublicGroupMaps(territoryMap, publicGroupMap);
                        found = true;
                    }
                    System.debug('CHINTAN Mapping US Account to territory ' + newAccount.BillingState);
                    newAccount.Territory__c = territoryMap.get(newAccount.BillingState.toUpperCase());
                    
                    //Add AccountShare Record
                    accountSharesToAdd.add(getAccountShareRecord(newAccount, publicGroupMap));
                }
            } //End US processing 
            
            //Canadian processing   
            if (oldCountry == 'Canada' || newCountry == 'Canada') {
                if (oldCountry == 'Canada' && newCountry != 'Canada') {
                    if ((oldStatus != 'Defunct' && newStatus == 'Defunct') || (oldStatus != 'Defunct' && newStatus != 'Defunct')) {
                        if ((oldStatus != 'Defunct' && newStatus != 'Defunct') && (newCountry != 'United States')) {
                            System.debug('CHINTAN Wiping out Canadian Territory');
                            newAccount.Territory__c = null;
                        }
                        if (!found) {
                            populateTerritoryAndPublicGroupMaps(territoryMap, publicGroupMap);
                            found = true;
                        }
                        //Delete AccountShare
                        accountShareMap.put(oldAccount.Id, publicGroupMap.get(oldAccount.territory__c));
                    }
                } else if (oldCountry != 'Canada' && newCountry == 'Canada') {
                    if ((oldStatus == 'Defunct' && newStatus != 'Defunct') || (oldStatus != 'Defunct' && newStatus != 'Defunct')) {
                        if (!found) {
                            populateTerritoryAndPublicGroupMaps(territoryMap, publicGroupMap);
                            found = true;
                        }
                        System.debug('CHINTAN Mapping Canadian Account to territory ' + newAccount.BillingState + ' barring Ottawa Exception');
                        if ((newAccount.BillingCity != null) && (newAccount.BillingCity.equalsIgnoreCase('Ottawa')))
                            newAccount.Territory__c = territoryMap.get('QC');
                        else
                            newAccount.Territory__c = territoryMap.get(newAccount.BillingState.toUpperCase());
                    
                        //Add AccountShare Record
                        accountSharesToAdd.add(getAccountShareRecord(newAccount, publicGroupMap));
                    }
                } else if (oldAccount.BillingState != newAccount.BillingState) {
                    System.debug('CHINTAN Changing Canadian territory from ' + oldAccount.BillingState + ' to ' + newAccount.BillingState);
                    if ((oldStatus != 'Defunct' && newStatus == 'Defunct') || (oldStatus != 'Defunct' && newStatus != 'Defunct')) {
                        //Wipe out Territory
                        newAccount.Territory__c = null;
                        if (!found) {
                            populateTerritoryAndPublicGroupMaps(territoryMap, publicGroupMap);
                            found = true;
                        }
                        //delete old accountshare
                        if (oldAccount.territory__c != null) {
                            accountShareMap.put(oldAccount.Id, publicGroupMap.get(oldAccount.territory__c));
                        }
                    }
                    if ((oldStatus == 'Defunct' && newStatus != 'Defunct') || (oldStatus != 'Defunct' && newStatus != 'Defunct')) {
                        if ((newAccount.BillingCity != null) && (newAccount.BillingCity.equalsIgnoreCase('Ottawa')))
                            newAccount.Territory__c = territoryMap.get('QC');
                        else
                            newAccount.Territory__c = territoryMap.get(newAccount.BillingState.toUpperCase());
                    
                        //Add AccountShare Record
                        accountSharesToAdd.add(getAccountShareRecord(newAccount, publicGroupMap));
                    }
                } else if (oldStatus != 'Defunct' && newStatus == 'Defunct') {
                    //Wipe out Territory
                    newAccount.Territory__c = null;
                    if (!found) {
                        populateTerritoryAndPublicGroupMaps(territoryMap, publicGroupMap);
                        found = true;
                    }
                    //Delete old accountshare
                    if (oldAccount.territory__c != null) {
                        accountShareMap.put(oldAccount.Id, publicGroupMap.get(oldAccount.territory__c));
                    }
                } else if (oldStatus == 'Defunct' && newStatus != 'Defunct') {
                    if (!found) {
                        populateTerritoryAndPublicGroupMaps(territoryMap, publicGroupMap);
                        found = true;
                    }
                    System.debug('CHINTAN Mapping Canadian Account to territory ' + newAccount.BillingState + ' barring Ottawa Exception');
                    if ((newAccount.BillingCity != null) && (newAccount.BillingCity.equalsIgnoreCase('Ottawa')))
                        newAccount.Territory__c = territoryMap.get('QC');
                    else
                        newAccount.Territory__c = territoryMap.get(newAccount.BillingState.toUpperCase());
                    
                    //Add AccountShare Record
                    accountSharesToAdd.add(getAccountShareRecord(newAccount, publicGroupMap));
                }
            } //End Canadian processing
        } //for
        
        //Add AccountShare Records
        if (accountSharesToAdd.size() > 0) {
            System.debug('CHINTAN ' + accountSharesToAdd.size() + ' AccountShare Records to Add');
            try {
                insert accountSharesToAdd;
            } catch (Exception e) {
                System.debug('CHINTAN Error Adding AccountShare Record');
            }
        }
        
        //Delete AccountShare Records
        if (accountShareMap.size() > 0) {
            System.debug('CHINTAN ' + accountShareMap.size() + ' AccountShare Records in accountShareMap');
            for (AccountShare accountShare : [Select Id, AccountId, UserOrGroupId From AccountShare Where AccountId IN :accountShareMap.keySet() AND UserOrGroupId IN :accountShareMap.Values()]) {
                if (accountShareMap.containsKey(accountShare.AccountId) && accountShare.UserOrGroupId == accountShareMap.get(accountShare.AccountId)) {
                    accountSharesToDelete.add(accountShare);
                }
            }
        }
        if (accountSharesToDelete.size() > 0) {
            System.debug('CHINTAN ' + accountSharesToDelete.size() + ' AccountShare Records to Delete');
            try {
                delete accountSharesToDelete;
            } catch (Exception e) {
                System.debug('CHINTAN Error Deleting AccountShare Record');
            }
        }
    } //updateAccountTerritory


    //00008792 - Ritu Sharma - This function will populate account segmentation field of the account object
    public static void populateAccSegmentationInfo(List<Account_Segmentation__c> newRecords,List<Account_Segmentation__c> oldRecords)
    {
        //Variables Declaration
        List <String> parentIdsList = new List<String>(); //List of IDs of parent records i.e. account records
        Map <ID,Account> accountsMap = Null; //List of account records that need to be updated
        List<Account_Segmentation__c> allAccSegmentsList = new List<Account_Segmentation__c>();
        Account account = Null;
        Integer i;
        Integer totalRecords  = (newRecords == null) ? oldRecords.size() : newRecords.size();
        
        //00018911 - Ritu Sharma - Added variables instead of hardcoding in functions
        String valueSep = ',';
        String recordSep = ';';

        //Looping through all records
        for(i=0;i<totalRecords;i++) 
        {
            if (trigger.isUpdate)
            { 
                System.debug('In Update');                   
                //Checking if user has changed the associated account
                if (newRecords[i].Associated_Account__c!=oldRecords[i].Associated_Account__c)
                {
                    //Both old and new accounts will need to be updated
                    parentIdsList.add(newRecords[i].Associated_Account__c);
                    parentIdsList.add(oldRecords[i].Associated_Account__c);
                }
                
                //Checking if user has actually updated the segmentation record
                if (newRecords[i].Country__c!=oldRecords[i].Country__c || newRecords[i].Segment__c!=oldRecords[i].Segment__c || newRecords[i].Sub_Segment__c!=oldRecords[i].Sub_Segment__c)
                { 
                    parentIdsList.add(newRecords[i].Associated_Account__c);
                }
            }
            else if(trigger.isDelete)
            {
                if(oldRecords[i].Associated_Account__c!=Null)
                    parentIdsList.add(oldRecords[i].Associated_Account__c);
            }
            else //Record is created or undeleted
            {
                System.debug('In Else Condition');
                parentIdsList.add(newRecords[i].Associated_Account__c);
            }
        }
        
        if (parentIdsList.size()>0)
        {    
            //Get handle of accounts i.e. parent records that will need to be updated in one go to restrict SOQL queries
            accountsMap = new Map <ID,Account>([Select ID,Account_Segmentation__c from Account where ID IN:parentIdsList]);
        
            //Getting handle of all account segment records
            allAccSegmentsList=[Select ID,Associated_Account__c,Country__c,Segment__c,Sub_Segment__c from Account_Segmentation__c where Associated_Account__c IN:parentIdsList];
        
            //Removing the existing value of account segmentation field
            for(i=0;i<parentIdsList.size();i++) 
            {
                accountsMap.get(parentIdsList[i]).Account_Segmentation__c='';
            }
        
            //Looping through all segment records
            for(i=0;i<allAccSegmentsList.size();i++) 
            {            
                account=accountsMap.get(allAccSegmentsList[i].Associated_Account__c);
                if (account.Account_Segmentation__c=='' || account.Account_Segmentation__c==Null)
                    account.Account_Segmentation__c=allAccSegmentsList[i].Country__c+valueSep+allAccSegmentsList[i].Segment__c+valueSep+allAccSegmentsList[i].Sub_Segment__c;
                else
                    account.Account_Segmentation__c=account.Account_Segmentation__c+recordSep+allAccSegmentsList[i].Country__c+valueSep+allAccSegmentsList[i].Segment__c+valueSep+allAccSegmentsList[i].Sub_Segment__c;
                System.debug('account.Account_Segmentation__c '+account.Account_Segmentation__c);
            }        
            
            //update accountsMap.values(); //Updating all accounts in one go                     
            Boolean errOccured=False;
            String emailText='';
            if(accountsMap.values().size()==1) //One record, manual entry
                update accountsMap.values();
            else { //Bulk processing 
                Database.SaveResult[] srList = Database.update(accountsMap.values(), false); 
                for (Database.SaveResult sr : srList) { // Iterate through each returned result
                    if (!sr.isSuccess()) { //Error Occured
                        for(Database.Error err : sr.getErrors()) {
                            errOccured=True;
                            emailText+='<br>/Error Code: '+err.getStatusCode()+'-Error Details: '+err.getMessage();                  
                        }
                    }
                }
                
                if(errOccured) {                    
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    String[] toAddresses = new String[]{UserInfo.getUserEmail()};      
                    mail.setSubject('blogic_Account - populateAccSegmentationInfo - Error Occured while updating segmentation information on accounts');
                    mail.setToAddresses(toAddresses);
                    mail.setHtmlBody(emailText); 
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
                }
            }
        }       
    } //populateAccSegmentationInfo
    
    
    /** This method maintains the Internal_Account_Team__c record for Account Owner changes  
      * Chintan. July 20, 2012 */
    public static void updateInternalAccountTeam(List<Account> oldAccounts, List<Account> newAccounts) {
        //local vars
        Map<Id,Id> oldAccountOwnerMap = new Map<Id,Id>();
        Map<Id,Id> oldUserContactMap = new Map<Id,Id>();
        List<Id> oldOwnerIdList = new List<Id>();
        Map<Id,Id> newAccountOwnerMap = new Map<Id,Id>();
        Map<Id,Id> newUserContactMap = new Map<Id,Id>();
        List<Id> newOwnerIdList = new List<Id>();
        List<Internal_Account_Team__c>iatList = new List<Internal_Account_Team__c>();
        
        //New Account Add
        if(trigger.isInsert) {
            for(Account account : newAccounts) {
                System.debug('CPA Adding Account Id '+account.Id + ' and OwnerId ' + account.OwnerId + ' to newAccountOwnerMap');
                newAccountOwnerMap.put(account.Id, account.OwnerId);
                newOwnerIdList.add(account.OwnerId);
            }
            //Get the Corresponding Contact Id for the Account Owners
            List<Contact> contacts = [Select Id, Corresponding_User_Id__c from Contact where Corresponding_User_Id__c in :newOwnerIdList];
            for (Contact contact : contacts) {
                System.debug('CPA Adding User Id ' + contact.Corresponding_User_Id__c + ' and Contact Id ' + contact.Id + ' to newUserContactMap');
                newUserContactMap.put(contact.Corresponding_User_Id__c, contact.Id);
            }
            if (newUserContactMap.size() > 0) { //At least one contact was found
                //Add record to the Internal Account Team
                for (Account account : newAccounts) {
                    Internal_Account_Team__c iat = new Internal_Account_Team__c();
                    iat.Account__c = account.Id;
                    iat.Contact__c = newUserContactMap.get(newAccountOwnerMap.get(account.Id));
                    iat.Contact_Role__c = 'Account Owner';
                    System.debug('CPA Adding Account: '+ iat.Account__c + ' Contact: ' + iat.Contact__c + ' to iatList');
                    if (iat.Contact__c != null) {
                        iatList.add(iat);
                    } else {
                        account.addError('A matching Contact record could not be located for the Account Owner. An Internal Account Team entry cannot be created.');
                    }
                }
                if (iatList.size() > 0) {
                    try {
                        insert iatList;
                    } catch(Exception e) {
                        System.debug('CPA Caught Error in Inserting Internal Account Team Records: ' + e.getMessage());
                    }
                }
            }
        } else if (trigger.isUpdate) {
            System.debug('CPA Method updateInternalAccountTeam triggered for isUpdate on Account');
            //Spin through and process
            for (integer i=0; i<newAccounts.size(); i++) {
                Account oldAccount = oldAccounts[i];
                Account newAccount = newAccounts[i];
                //Change in AE
                if (oldAccount.OwnerId != newAccount.OwnerId) {
                    oldAccountOwnerMap.put(oldAccount.Id, oldAccount.OwnerId);
                    newAccountOwnerMap.put(newAccount.Id, newAccount.OwnerId);
                    oldOwnerIdList.add(oldAccount.OwnerId);
                    newOwnerIdList.add(newAccount.OwnerId);
                }
            }
            //Get the Corresponding Contact Id for the new Account Owners
            List<Contact> contacts = [Select Id, Corresponding_User_Id__c from Contact where Corresponding_User_Id__c in :newOwnerIdList];
            for (Contact contact : contacts) {
                System.debug('CPA Adding User Id ' + contact.Corresponding_User_Id__c + ' and Contact Id ' + contact.Id + ' to newUserContactMap');
                newUserContactMap.put(contact.Corresponding_User_Id__c, contact.Id);
            }
            //Delete the records for old Account Owners
            Internal_Account_Team__c[] iatToDelete = [Select Id from Internal_Account_Team__c where Account__c in :oldAccountOwnerMap.keySet() and Contact_Role__c = 'Account Owner'];
            try {
                delete iatToDelete;
            } catch (Exception e) {
                System.debug('CPA Caught Error in Deleting Internal Account Team Records: ' + e.getMessage());
            }
            //Add records for new Account Owners
            if (newUserContactMap.size() > 0) {
                //Add record to the Internal Account Team
                for (Account account : newAccounts) {
                    Internal_Account_Team__c iat = new Internal_Account_Team__c();
                    iat.Account__c = account.Id;
                    iat.Contact__c = newUserContactMap.get(newAccountOwnerMap.get(account.Id));
                    iat.Contact_Role__c = 'Account Owner';
                    System.debug('CPA Adding Account: '+ iat.Account__c + ' Contact: ' + iat.Contact__c + ' to iatList');
                    if (iat.Contact__c != null) {
                        iatList.add(iat);
                    } else {
                        account.addError('A matching Contact record could not be located for the Account Owner. An Internal Account Team entry cannot be created.');
                    }
                }
                if (iatList.size() > 0) {
                    try {
                        insert iatList;
                        System.debug('iatList>>>'+iatList );
                    } catch(Exception e) {
                        System.debug('CPA Caught Error in Inserting Internal Account Team Records: ' + e.getMessage());
                    }
                }
            }
        }
    } //updateInternalAccountTeam
    
    
    /** This method maintains the Account Team and AccountShare records based on Internal Account Team maintenance  
      * Chintan. August 1, 2012 */
    public static void updateAccountTeam(List<Internal_Account_Team__c> oldMembers, List<Internal_Account_Team__c> newMembers) {
        //local vars
        List<AccountTeamMember> accountTeamMemberList = new List<AccountTeamMember> ();
        List<Id> accountIdList = new List<Id> ();
        List<Id> userIdList = new List<Id> ();
        List<Id> contactIdList = new List<Id> ();
        Boolean found = false;
        
        if(trigger.isInsert) {  
            for(Internal_Account_Team__c member : newMembers) {
                if(member.User_ID__c != null) {
                    //Create Account Team Record
                    AccountTeamMember accountTeamMember = new AccountTeamMember();
                    accountTeamMember.UserId = member.User_ID__c;
                    accountTeamMember.AccountId = member.Account__c;
                    accountTeamMember.TeamMemberRole='Account Team Member';
                        
                    //Add to List
                    accountTeamMemberList.add(accountTeamMember);
                        
                    //Add Data to Lists
                    accountIdList.add(member.Account__c);
                    userIdList.add(member.User_ID__c);
                }
            }
            
            //Add Account Team Records
            System.debug('CPA accountTeamMemberList size is ' + accountTeamMemberList.size());
            System.debug('CPA accountTeamMemberList Data is ' + accountTeamMemberList);
            if (accountTeamMemberList.size() > 0) {
                try { insert accountTeamMemberList; }
                catch (Exception e) {
                    System.debug('CPA ERROR in inserting accountTeamMemberList - ' + e.getMessage());
                }
            }
            
            //Adding a record to the Account Team automatically adds a record to the AccountShare table. 
            //Update the existing records in AccountShare table to give them Edit access to Contacts, Opps etc.
            AccountShare[] existingAccountShareList = [Select Id, AccountId, UserOrGroupId, AccountAccessLevel, ContactAccessLevel, CaseAccessLevel, OpportunityAccessLevel From AccountShare where AccountId in :accountIdList and UserOrGroupId in :userIdList];
            System.debug('CPA existingAccountShareList size is '+ existingAccountShareList.size());
            System.debug('CPA existingAccountShareList Data is '+ existingAccountShareList);
            if(existingAccountShareList.size() > 0) {
                for(AccountShare accountShare : existingAccountShareList) {
                    //Leave 'All' for Account Owners
                    accountShare.AccountAccessLevel = accountShare.AccountAccessLevel.equalsIgnoreCase('All') ? 'All' : 'Edit';
                    accountShare.CaseAccessLevel = 'Edit';
                    accountShare.OpportunityAccessLevel = 'Edit';
                    accountShare.ContactAccessLevel = 'Edit';
                }
                try { update existingAccountShareList; }
                catch (Exception e) {
                    System.debug('CPA ERROR in updating existingAccountShareList - ' + e.getMessage());
                }
            }
        } else if(trigger.isDelete) {
            for(Internal_Account_Team__c member : oldMembers) {
                if(member.User_ID__c != null) {
                    //Add Data to Lists
                    accountIdList.add(member.Account__c);
                    userIdList.add(member.User_ID__c);
                    contactIdList.add(member.Contact__c);
                }
            }
            
            //Check for any remaining Internal Account Team records for the same users as the ones deleted
            List<Internal_Account_Team__c> existingIatMembers = [Select Contact__c, User_ID__c, Account__c, Contact_Role__c from Internal_Account_Team__c where Contact__c in :contactIdList and Account__c in :accountIdList];
            System.debug('CPA existingIatMembers size is ' + existingIatMembers.size());
            System.debug('CPA existingIatMembers data is ' + existingIatMembers);
            
            //Make a copy of all deleted data
            List<Internal_Account_Team__c> iatList = new List<Internal_Account_Team__c> ();
            iatList.addAll(oldMembers);
            
            //Remove from this list any users that are still in the Internal Account Team in some other role
            for (integer i=0; i<iatList.size(); i++) {
                Internal_Account_Team__c iat = iatList[i];
                found = false;
                for (Internal_Account_Team__c existingMember : existingIatMembers) {
                    if (existingMember.Account__c == iat.Account__c && existingMember.Contact__c == iat.Contact__c) {
                        found = true;
                        System.debug('CPA Found IAT record with Account ' + iat.Account__c + ' and Contact ' + iat.Contact__c);
                        break;
                    }
                }
                if (found) {
                    iatList.remove(i);
                }
            }
            System.debug('CPA After cleaning iatList size is: ' + iatList.size());
            System.debug('CPA account team member List to delete: ' + iatList);
            
            //Add data to delete in Lists
            accountIdList.clear();
            userIdList.clear();
            for (Internal_Account_Team__c iat : iatList) {
                accountIdList.add(iat.Account__c);
                userIdList.add(iat.User_ID__c);
            }
            
            //Delete records from the AccountTeamMember table
            List<AccountTeamMember> accountTeamMembersToDelete = [Select id from AccountTeamMember where AccountId in :accountIdList and UserId in :userIdList];
            System.debug('CPA accountTeamMembersToDelete size is ' + accountTeamMembersToDelete.size());
            System.debug('CPA accountTeamMembersToDelete is: ' + accountTeamMembersToDelete);
            try { delete accountTeamMembersToDelete; }
            catch (Exception e) {
                    System.debug('CPA ERROR in deleting accountTeamMembersToDelete - ' + e.getMessage());
                }
        }
    } //updateAccountTeam
    
    
    
    /** Copies the Executive Sponsor Internal Account Team Member to the corresponding Account field
      * Chintan. August 31, 2012 */
    public static void copyExecutiveSponsor(List<Internal_Account_Team__c> oldTeamList, List<Internal_Account_Team__c> newTeamList) {
        //local vars
        List<Id> accountIds = new List<Id> ();
        Map<Id, Id> accountContactMap = new Map<Id, Id> ();
        
        if (trigger.isInsert) {
            for(Internal_Account_Team__c myTeam : newTeamList) {  
                if(myTeam.Contact_Role__c == 'Executive Sponsor') { 
                    accountContactMap.put(myTeam.Account__c, myTeam.Contact__c);
                    accountIds.add(myTeam.Account__c);
                }            
            }
            System.debug('CHINTAN Executive Sponsor Insert trigger accountContactMap: ' + accountContactMap);
            
            //Update Accounts
            if (!accountIds.isEmpty()) {
                List<Account> accountsToUpdate = [Select Id, Aon_Hewitt_Executive_Sponsor__c From Account Where Id IN :accountIds];
                for (Account myAccount : accountsToUpdate) {
                    myAccount.Aon_Hewitt_Executive_Sponsor__c = accountContactMap.get(myAccount.Id);
                }
                try {
                    update accountsToUpdate;
                } catch (Exception e) {
                    System.debug('CHINTAN ERROR in updating Accounts with Executive Sponsor data. Error Message: ' + e.getMessage());
                }
            }           
        } else if(trigger.isDelete) {
            for(Internal_Account_Team__c myTeam : oldTeamList) {
                if(myTeam.Contact_Role__c == 'Executive Sponsor') {
                    accountContactMap.put(myTeam.Account__c, null);
                    accountIds.add(myTeam.Account__c);
                }   
            }
            System.debug('CHINTAN Executive Sponsor Delete trigger accountIds: ' + accountIds);
            
            if (!accountIds.isEmpty()) {
                List<Account> accountsToUpdate = [Select Id, Aon_Hewitt_Executive_Sponsor__c From Account Where Id IN :accountIds];
                for (Account myAccount : accountsToUpdate) {
                    myAccount.Aon_Hewitt_Executive_Sponsor__c = null;
                }
                try {
                    update accountsToUpdate;
                } catch (Exception e) {
                    System.debug('CHINTAN ERROR in updating Accounts with Executive Sponsor data. Error Message: ' + e.getMessage());
                }
            }
        }
    } //copyExecutiveSponsor

    
    /** Autofill some data before saving 
      * Chintan. September 19, 2012 
      * Ritu - 00078331 - Revamped the code to fulfill new requirements 
      * Case 103298, November 20, 2013, Chintan */
    public static void autofillData(List<Account> oldAccounts, List<Account> newAccounts) {
        System.debug('Ritu - autofillData');
        //local vars
        List<String> sicCodesList = new List<String> ();
        List<String> dunsList = new List<String> ();
        Map<String,SIC_Code_to_Industry_Mapping__c> sicMap = new Map<String,SIC_Code_to_Industry_Mapping__c> ();
        Map<String, Id> dunsAccountMap = new Map<String, Id> ();
            
        //Collect a list of SICs and Global Ultimate DUNS
        if(trigger.isInsert) {
            for(Account myAccount : newAccounts) {
                if(myAccount.Sic != null)
                    sicCodesList.add(myAccount.Sic);
                if (myAccount.Glb_Ult_Duns__c != null && !myAccount.Glb_Ult__c)
                    dunsList.add(myAccount.Glb_Ult_Duns__c);
            }
        } else if(trigger.isUpdate) {
            for(integer i=0; i<newAccounts.size(); i++) {
                 //Not able to make SIC code description and Industry level 4 read only for admins so checking if user has changed the values 
                if (oldAccounts[i].Sic != newAccounts[i].Sic || oldAccounts[i].SIC_Code_Description__c!=newAccounts[i].SIC_Code_Description__c || oldAccounts[i].Aon_Global_Industry_Level_2__c!=newAccounts[i].Aon_Global_Industry_Level_2__c) {
                    sicCodesList.add(newAccounts[i].Sic);
                }
                if (newAccounts[i].Glb_Ult_Duns__c != null && !newAccounts[i].Glb_Ult__c) {
                    dunsList.add(newAccounts[i].Glb_Ult_Duns__c);
                }
            }
        }
   
        //Get SIC records
        if(!sicCodesList.isEmpty()) {
            for (SIC_Code_to_Industry_Mapping__c sic : [Select Name,Industry__c,Aon_Global_Industry_Level_2__c,Aon_Global_Industry_Level_4__c from SIC_Code_to_Industry_Mapping__c where Name In :sicCodesList])
                sicMap.put(sic.Name, sic);
        }
        
        //Get Accounts based on Global Ultimate DUNS
        if (!dunsList.isEmpty()) {
            //TERRIBLE DESIGN but done to get past the non-selective query error
            for (Account account : [Select Id, DunsNumber, Glb_Ult_Duns__c from Account WHERE DunsNumber in :dunsList And CreatedDate < 2011-05-31T00:00:00Z]) {
                dunsAccountMap.put(account.DunsNumber, account.Id);
            }
            for (Account account : [Select Id, DunsNumber from Account Where DunsNumber in :dunsList And CreatedDate >= 2011-05-31T00:00:00Z And CreatedDate < 2011-11-30T00:00:00Z]) {
                dunsAccountMap.put(account.DunsNumber, account.Id);
            }
            for (Account account : [Select Id, DunsNumber from Account Where DunsNumber in :dunsList And CreatedDate >= 2011-11-30T00:00:00Z And CreatedDate < 2012-02-29T00:00:00Z]) {
                dunsAccountMap.put(account.DunsNumber, account.Id);
            }
            for (Account account : [Select Id, DunsNumber from Account Where DunsNumber in :dunsList And CreatedDate >= 2012-02-29T00:00:00Z And CreatedDate < 2012-08-29T00:00:00Z]) {
                dunsAccountMap.put(account.DunsNumber, account.Id);
            }
            for (Account account : [Select Id, DunsNumber from Account Where DunsNumber in :dunsList And CreatedDate >= 2012-08-29T00:00:00Z And CreatedDate <= TODAY]) {
                dunsAccountMap.put(account.DunsNumber, account.Id);
            }
        }
        System.debug('CPA dunsAccountMap is: ' + dunsAccountMap);
        
        //Update Accounts
        for(Account myAccount : newAccounts) {
            if (!sicCodesList.isEmpty()) {
                SIC_Code_to_Industry_Mapping__c mySic = sicMap.get(myAccount.Sic);
                if (mySic != null)  {              
                    //set the fields
                    myAccount.Industry = mySic.Industry__c;
                    myAccount.SIC_Code_Description__c = mySic.Aon_Global_Industry_Level_4__c;
                    myAccount.Aon_Global_Industry_Level_2__c = mySic.Aon_Global_Industry_Level_2__c;
                } else { 
                    //Clear the fields
                    myAccount.SIC_Code_Description__c = '';
                    myAccount.Aon_Global_Industry_Level_2__c = '';                
                }
            }
            system.debug('Before - myAccount.ParentId '+myAccount.ParentId);
            myAccount.ParentId = myAccount.Glb_Ult_Duns__c != null && myAccount.Id != dunsAccountMap.get(myAccount.Glb_Ult_Duns__c) && !myAccount.Glb_Ult__c ? dunsAccountMap.get(myAccount.Glb_Ult_Duns__c) : null;
            system.debug('After - myAccount.ParentId '+myAccount.ParentId);
                        
            myAccount.BillingCountry = myAccount.SDO_Billing_Country_Name__c;
            System.debug('CPA Glb Ult Duns for ' + myAccount.Name + ' is: ' + myAccount.Glb_Ult_Duns__c);
            System.debug('CPA Parent Id ' + myAccount.Name + ' is: ' + myAccount.ParentId);
        }
    } //autofillData
    

    
    /** Update all Accounts tied to the Market if the Market Lead or Region Director tied to the Market is changed in zipToMarketMapping object
      * Chintan, September 19, 2012 */
    public static void updateMarketLeadRegionDirector(List<Zip_Code_to_Market_Mapping__c> oldZips, List<Zip_Code_to_Market_Mapping__c> newZips) {
        //local vars
        Set<String> marketSet = new Set<String> ();
        Set<String> countrySet = new Set<String> ();
        Map<String, Zip_Code_to_Market_Mapping__c> emailMap = new Map<String, Zip_Code_to_Market_Mapping__c> ();
        
        //Identify Markets for which a change has occured
        for (integer i=0; i<newZips.size(); i++) {
            if ((oldZips[i].Market_Lead_Email__c != newZips[i].Market_Lead_Email__c) || (oldZips[i].Region_Director_Email__c != newZips[i].Region_Director_Email__c)) {
                marketSet.add(newZips[i].Market__c);
                countrySet.add(newZips[i].Country__c);
                if (!emailMap.containsKey(newZips[i].Market__c)) {
                    System.debug('CHINTAN Adding Market: ' + newZips[i].Market__c + ' and zipToMarket record: ' + newZips[i]);
                    emailMap.put(newZips[i].Market__c, newZips[i]);
                }
            }
        }        
      
        //Update Accounts in that market
        //TERRIBLE design but I could not figure out how to get past the non-selective query against a large object error any other way
        List<Account> accountsToUpdate = new List<Account> ();
        for (Account myAccount : [Select Id, Market__c, Market_Lead_Email__c, Region_Director_Email__c from Account Where Market__c in :marketSet And CreatedDate < 2011-05-31T00:00:00Z]) {
            Zip_Code_to_Market_Mapping__c myZipRecord = (Zip_Code_to_Market_Mapping__c)emailMap.get(myAccount.Market__c);
            myAccount.Market_Lead_Email__c = myZipRecord.Market_Lead_Email__c;
            myAccount.Region_Director_Email__c = myZipRecord.Region_Director_Email__c;
            accountsToUpdate.add(myAccount);
        }
        for (Account myAccount : [Select Id, Market__c, Market_Lead_Email__c, Region_Director_Email__c from Account Where Market__c in :marketSet And CreatedDate >= 2011-05-31T00:00:00Z And CreatedDate < 2011-11-30T00:00:00Z]) {
            Zip_Code_to_Market_Mapping__c myZipRecord = (Zip_Code_to_Market_Mapping__c)emailMap.get(myAccount.Market__c);
            myAccount.Market_Lead_Email__c = myZipRecord.Market_Lead_Email__c;
            myAccount.Region_Director_Email__c = myZipRecord.Region_Director_Email__c;
            accountsToUpdate.add(myAccount);
        }
        for (Account myAccount : [Select Id, Market__c, Market_Lead_Email__c, Region_Director_Email__c from Account Where Market__c in :marketSet And CreatedDate >= 2011-11-30T00:00:00Z And CreatedDate < 2012-02-29T00:00:00Z]) {
            Zip_Code_to_Market_Mapping__c myZipRecord = (Zip_Code_to_Market_Mapping__c)emailMap.get(myAccount.Market__c);
            myAccount.Market_Lead_Email__c = myZipRecord.Market_Lead_Email__c;
            myAccount.Region_Director_Email__c = myZipRecord.Region_Director_Email__c;
            accountsToUpdate.add(myAccount);
        }
        for (Account myAccount : [Select Id, Market__c, Market_Lead_Email__c, Region_Director_Email__c from Account Where Market__c in :marketSet And CreatedDate >= 2012-02-29T00:00:00Z And CreatedDate < 2012-08-29T00:00:00Z]) {
            Zip_Code_to_Market_Mapping__c myZipRecord = (Zip_Code_to_Market_Mapping__c)emailMap.get(myAccount.Market__c);
            myAccount.Market_Lead_Email__c = myZipRecord.Market_Lead_Email__c;
            myAccount.Region_Director_Email__c = myZipRecord.Region_Director_Email__c;
            accountsToUpdate.add(myAccount);
        }
        for (Account myAccount : [Select Id, Market__c, Market_Lead_Email__c, Region_Director_Email__c from Account Where Market__c in :marketSet And CreatedDate >= 2012-08-29T00:00:00Z And CreatedDate <= TODAY]) {
            Zip_Code_to_Market_Mapping__c myZipRecord = (Zip_Code_to_Market_Mapping__c)emailMap.get(myAccount.Market__c);
            myAccount.Market_Lead_Email__c = myZipRecord.Market_Lead_Email__c;
            myAccount.Region_Director_Email__c = myZipRecord.Region_Director_Email__c;
            accountsToUpdate.add(myAccount);
        }       
        System.debug('CHINTAN Number of Accounts to update is: ' + accountsToUpdate.size());
    
        try { update accountsToUpdate; }
        catch (Exception e) { System.debug('CHINTAN Error in update accountsToUpdate: ' + e.getMessage()); }
    } //updateMarketLeadRegionDirector
    
    
    /** Apex Object that is utilized by the methods below to store data from the Client Assessment Survey 
      * form and then write back to the Account on save
      * Chintan Adhyapak, December 10, 2012 */
    private class SurveyData {
        //Data Members
        public Double dbCount               {get; set;}
        public Double dcCount               {get; set;}
        public Double hwCount               {get; set;}
        public Id dbAdminId                 {get; set;} 
        public Id dcAdminId                 {get; set;}
        public Id hwAdminId                 {get; set;}
        public Date dbAdminDate             {get; set;}
        public Date dcAdminDate             {get; set;}
        public Date hwAdminDate             {get; set;}
        public String relationshipStatus    {get; set;}
        
        //Constructor
        public SurveyData(Client_Assessment_Survey__c survey) {
            System.debug('CHINTAN SurveyData Constructor called with: ' + survey);
            this.dbCount = survey.Active_DB_Ret_PPTS__c;
            this.dcCount = survey.Active_DC_Ret_PPTS__c;
            this.hwCount = survey.Active_Health_Care_PPTS__c;
            this.dbAdminId = survey.DB_Administrator__c;
            this.dcAdminId = survey.DC_Administrator__c;
            this.hwAdminId = survey.HW_Administrator__c;
            this.dbAdminDate = survey.DB_Contract_End_Date__c;
            this.dcAdminDate = survey.DC_Contract_End_Date__c;
            this.hwAdminDate = survey.HW_Contract_End_Date__c;
            //this.relationshipStatus = survey.Overall_Relationship_Status__c;  //Removed for case 135733
        } //constructor
    } //SurveyData
    
    
    /** Private Utility Method to determine if any data on Client Assesment Survey form needs to be written back to the Account
      * Chintan Adhyapak, December 10, 2012 
      * v2. Case 67150, Chintan, March 14, 2013 */
    private static boolean doesAccountNeedUpdate(Account account, SurveyData mySurveyData) {
        boolean flag = false;
        if ((account.Active_DB_Ret_PPTS__c != mySurveyData.dbCount)
                || (account.Active_DC_Ret_PPTS__c != mySurveyData.dcCount) 
                || (account.Active_Health_Care_PPTS__c != mySurveyData.hwCount)) {
                //|| (account.Overall_Relationship_Status__c != mySurveyData.relationshipStatus)) { // Removed for case 135733
            flag = true;            
        }
        return flag;
    } //doesAccountNeedUpdate
    
    
    /** Private Utility Method to determine if any data on Client Assesment Survey form needs to be written back to the Service Provider
      * Chintan Adhyapak, December 10, 2012 */
    private static boolean doesProviderNeedUpdate(Core_Service_Providers__c provider, SurveyData mySurveyData) {
        boolean flag = false;
        if (provider.Defined_Benefit_Administrator__c != mySurveyData.dbAdminId 
                || (provider.Defined_Contribution_Administrator__c != mySurveyData.dcAdminId) 
                || (provider.Health_Welfare_Administrator__c != mySurveyData.hwAdminId) 
                || (provider.Defined_Benefit_End_Date__c != mySurveyData.dbAdminDate)
                || (provider.Defined_Contribution_End_Date__c != mySurveyData.dcAdminDate) 
                || (provider.Health_Welfare_End_Date__c != mySurveyData.hwAdminDate)) {
            flag = true;            
        }
        return flag;
    } //doesProviderNeedUpdate
    
        
    /** Update Employee Count and Service Provider data tied to an Account when a Client Assessment Survey is created
      * Chintan, October 04, 2012 
      * v2. Case 67150, Chintan, March 14, 2013 */
    public static void updateAccountWithSurveyData(List<Client_Assessment_Survey__c> surveys) {
        //local vars
        Map<Id, SurveyData> surveyMap = new Map<Id, SurveyData> ();
        //List<Id> accountIds = new List<Id> ();
        List<Account> accountsToUpdate = new List<Account> ();
        List<Core_Service_Providers__c> providersToUpdate = new List<Core_Service_Providers__c> ();
        
        //Spin through records
        for (Client_Assessment_Survey__c survey : surveys) {
            System.debug('CHINTAN updateAccountWithSurveyData reading survey: ' + survey);
            surveyMap.put(survey.Account__c, new SurveyData(survey));
            //accountIds.add(survey.Account__c);
        }
        //System.debug('CHINTAN updateAccountWithSurveyData accountIds size is: ' + accountIds.size());
        
        //Pull Account Data
        for (Account account : [Select Id, Active_DB_Ret_PPTS__c, Active_DC_Ret_PPTS__c, Active_Health_Care_PPTS__c, 
                Overall_Relationship_Status__c from Account Where Id in :surveyMap.keySet()]) {
            System.debug('CHINTAN updateAccountWithSurveyData Reading Account: ' + account);
            //Pull the survey data from the map for this account
            SurveyData mySurveyData = surveyMap.get(account.Id);
            System.debug('CHINTAN updateAccountWithSurveyData mySurveyData pulled: ' + mySurveyData);
            //Has any data changed that requires an account update
            if (doesAccountNeedUpdate(account, mySurveyData)) {
                account.Active_DB_Ret_PPTS__c = mySurveyData.dbCount;
                account.Active_DC_Ret_PPTS__c = mySurveyData.dcCount;
                account.Active_Health_Care_PPTS__c = mySurveyData.hwCount;
                //account.Overall_Relationship_Status__c = mySurveyData.relationshipStatus;  //Removed for case 135733
                accountsToUpdate.add(account);
            }
        }
        System.debug('CHINTAN updateAccountWithSurveyData accountsToUpdate size is: ' + accountsToUpdate.size());
    
        //Pull Outsourcing Service Provider Data
        //TERRIBLE design but I could not figure out how to get past the non-selective query against a large object error any other way
        for (Core_Service_Providers__c provider : [Select Id, Defined_Benefit_Administrator__c, Defined_Contribution_Administrator__c, Health_Welfare_Administrator__c, Account__c, 
                Defined_Benefit_End_Date__c, Defined_Contribution_End_Date__c, Health_Welfare_End_Date__c from Core_Service_Providers__c 
                Where Account__c in :surveyMap.keySet() And CreatedDate < 2011-05-31T00:00:00Z]) {
            SurveyData mySurveyData = surveyMap.get(provider.Account__c);
            if (doesProviderNeedUpdate(provider, mySurveyData)) {
                provider.Defined_Benefit_Administrator__c = mySurveyData.dbAdminId;
                provider.Defined_Contribution_Administrator__c = mySurveyData.dcAdminId;
                provider.Health_Welfare_Administrator__c = mySurveyData.hwAdminId;
                provider.Defined_Benefit_End_Date__c = mySurveyData.dbAdminDate;
                provider.Defined_Contribution_End_Date__c = mySurveyData.dcAdminDate;
                provider.Health_Welfare_End_Date__c = mySurveyData.hwAdminDate;
                providersToUpdate.add(provider);
            }
        }
        for (Core_Service_Providers__c provider : [Select Id, Defined_Benefit_Administrator__c, Defined_Contribution_Administrator__c, Health_Welfare_Administrator__c, Account__c, 
                Defined_Benefit_End_Date__c, Defined_Contribution_End_Date__c, Health_Welfare_End_Date__c from Core_Service_Providers__c 
                Where Account__c in :surveyMap.keySet() And CreatedDate >= 2011-05-31T00:00:00Z And CreatedDate < 2011-11-30T00:00:00Z]) {
            SurveyData mySurveyData = surveyMap.get(provider.Account__c);
            if (doesProviderNeedUpdate(provider, mySurveyData)) {
                provider.Defined_Benefit_Administrator__c = mySurveyData.dbAdminId;
                provider.Defined_Contribution_Administrator__c = mySurveyData.dcAdminId;
                provider.Health_Welfare_Administrator__c = mySurveyData.hwAdminId;
                provider.Defined_Benefit_End_Date__c = mySurveyData.dbAdminDate;
                provider.Defined_Contribution_End_Date__c = mySurveyData.dcAdminDate;
                provider.Health_Welfare_End_Date__c = mySurveyData.hwAdminDate;
                providersToUpdate.add(provider);
            }
        }
        for (Core_Service_Providers__c provider : [Select Id, Defined_Benefit_Administrator__c, Defined_Contribution_Administrator__c, Health_Welfare_Administrator__c, Account__c, 
                Defined_Benefit_End_Date__c, Defined_Contribution_End_Date__c, Health_Welfare_End_Date__c from Core_Service_Providers__c 
                Where Account__c in :surveyMap.keySet() And CreatedDate >= 2011-11-30T00:00:00Z And CreatedDate < 2012-01-30T00:00:00Z]) {
            SurveyData mySurveyData = surveyMap.get(provider.Account__c);
            if (doesProviderNeedUpdate(provider, mySurveyData)) {
                provider.Defined_Benefit_Administrator__c = mySurveyData.dbAdminId;
                provider.Defined_Contribution_Administrator__c = mySurveyData.dcAdminId;
                provider.Health_Welfare_Administrator__c = mySurveyData.hwAdminId;
                provider.Defined_Benefit_End_Date__c = mySurveyData.dbAdminDate;
                provider.Defined_Contribution_End_Date__c = mySurveyData.dcAdminDate;
                provider.Health_Welfare_End_Date__c = mySurveyData.hwAdminDate;
                providersToUpdate.add(provider);
            }
        }
        for (Core_Service_Providers__c provider : [Select Id, Defined_Benefit_Administrator__c, Defined_Contribution_Administrator__c, Health_Welfare_Administrator__c, Account__c, 
                Defined_Benefit_End_Date__c, Defined_Contribution_End_Date__c, Health_Welfare_End_Date__c from Core_Service_Providers__c 
                Where Account__c in :surveyMap.keySet() And CreatedDate >= 2012-01-30T00:00:00Z And CreatedDate < 2012-02-29T00:00:00Z]) {
            SurveyData mySurveyData = surveyMap.get(provider.Account__c);
            if (doesProviderNeedUpdate(provider, mySurveyData)) {
                provider.Defined_Benefit_Administrator__c = mySurveyData.dbAdminId;
                provider.Defined_Contribution_Administrator__c = mySurveyData.dcAdminId;
                provider.Health_Welfare_Administrator__c = mySurveyData.hwAdminId;
                provider.Defined_Benefit_End_Date__c = mySurveyData.dbAdminDate;
                provider.Defined_Contribution_End_Date__c = mySurveyData.dcAdminDate;
                provider.Health_Welfare_End_Date__c = mySurveyData.hwAdminDate;
                providersToUpdate.add(provider);
            }
        }
        for (Core_Service_Providers__c provider : [Select Id, Defined_Benefit_Administrator__c, Defined_Contribution_Administrator__c, Health_Welfare_Administrator__c, Account__c, 
                Defined_Benefit_End_Date__c, Defined_Contribution_End_Date__c, Health_Welfare_End_Date__c from Core_Service_Providers__c 
                Where Account__c in :surveyMap.keySet() And CreatedDate >= 2012-02-29T00:00:00Z And CreatedDate < 2012-08-29T00:00:00Z]) {
            SurveyData mySurveyData = surveyMap.get(provider.Account__c);
            if (doesProviderNeedUpdate(provider, mySurveyData)) {
                provider.Defined_Benefit_Administrator__c = mySurveyData.dbAdminId;
                provider.Defined_Contribution_Administrator__c = mySurveyData.dcAdminId;
                provider.Health_Welfare_Administrator__c = mySurveyData.hwAdminId;
                provider.Defined_Benefit_End_Date__c = mySurveyData.dbAdminDate;
                provider.Defined_Contribution_End_Date__c = mySurveyData.dcAdminDate;
                provider.Health_Welfare_End_Date__c = mySurveyData.hwAdminDate;
                providersToUpdate.add(provider);
            }
        }
        for (Core_Service_Providers__c provider : [Select Id, Defined_Benefit_Administrator__c, Defined_Contribution_Administrator__c, Health_Welfare_Administrator__c, Account__c, 
                Defined_Benefit_End_Date__c, Defined_Contribution_End_Date__c, Health_Welfare_End_Date__c from Core_Service_Providers__c 
                Where Account__c in :surveyMap.keySet() And CreatedDate >= 2012-08-29T00:00:00Z And CreatedDate <= TODAY]) {
            SurveyData mySurveyData = surveyMap.get(provider.Account__c);
            if (doesProviderNeedUpdate(provider, mySurveyData)) {
                provider.Defined_Benefit_Administrator__c = mySurveyData.dbAdminId;
                provider.Defined_Contribution_Administrator__c = mySurveyData.dcAdminId;
                provider.Health_Welfare_Administrator__c = mySurveyData.hwAdminId;
                provider.Defined_Benefit_End_Date__c = mySurveyData.dbAdminDate;
                provider.Defined_Contribution_End_Date__c = mySurveyData.dcAdminDate;
                provider.Health_Welfare_End_Date__c = mySurveyData.hwAdminDate;
                providersToUpdate.add(provider);
            }
        }
        System.debug('CHINTAN updateAccountWithSurveyData providersToUpdate size is: ' + providersToUpdate.size());
        
        //Update Accounts
        if (!accountsToUpdate.isEmpty()) {
            try {
                update accountsToUpdate;
            } catch (Exception e) {
                System.debug('CHINTAN Error in updating Account data: ' + e.getMessage());
            }
        }
        
        //Update Service Provider Data
        if (!providersToUpdate.isEmpty()) {
            try {
                update providersToUpdate;
            } catch (Exception e) {
                System.debug('CHINTAN Error in updating Service Provider data: ' + e.getMessage());
            }
        }
    } //updateAccountWithSurveyData
    
    
 	/** Create a MergeAudit record from the deleted Account when two accounts are merged in order to process duplicate data 
    * in a batch daily.
    * Chintan Adhyapak, January 14, 2015. Case 161986
    */
  	public static void createMergeAuditRecords(List<Account> accounts) {
    	System.debug('CPA recordMasterId fired on AFTER DELETE');
    	List<Merge_Audit__c> recordList = new List<Merge_Audit__c> ();
    	Set<Id> mriSet = new Set<Id> ();
    
    	//Cycle through and identify unique merge records
    	for (Account account : accounts) {
      		if ((account.MasterRecordId != null) && (!doesIdExistInMergeAudit(account.MasterRecordId))) {
        		mriSet.add(account.MasterRecordId);
      		}
    	}
    
	    //Create records
    	for (Id recordId : mriSet) {
      		System.debug('CPA Creating Merge Audit Record for MasterRecordId: ' + recordId);
      		Merge_Audit__c auditRecord = new Merge_Audit__c();
      		auditRecord.MasterRecordId__c = recordId;
      		auditRecord.Processed__c = false;
      		recordList.add(auditRecord);
    	}
    
    	//insert
    	if (!recordList.isEmpty()) {
      		insert recordList;
    	}
  	} //createMergeAuditRecords
  
  
  	/** Private Utility Method to determine if given ID exists in the Merge Audit object
      * Chintan Adhyapak, January 15, 2015 
      */
    private static boolean doesIdExistInMergeAudit(Id accountId) {
      integer count;
      List<Merge_Audit__c> recordList = new List<Merge_Audit__c> ();
        
        recordList = [Select Id From Merge_Audit__c Where MasterRecordId__c = :accountId and Processed__c = false];
        System.debug('CPA doesIdExistInMergeAudit returning ' + (!recordList.isEmpty()) + ' for accountId ' + accountId);
        return (!recordList.isEmpty());
    } //doesAccountNeedUpdate
}