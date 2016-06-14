/*
Copyright (c) 2011 salesforce.com, inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.
3. The name of the author may not be used to endorse or promote products
   derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS" AND ANY EXPRESS OR
IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, 
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
public with sharing class ChatterUpHelper {

    private List<Chatter_Up__c> chatterUpSettings;
    
    /*
        Constructor grabs the Chatter Up Custom Settings.
    */
    public ChatterUpHelper() {
        chatterUpSettings = Chatter_Up__c.getall().values();
    }
    
    /*
        Call chatterUp with a list of objects that have just been created.
        Ideally, this should be called from an AFTER INSERT trigger.
        e.g.  for an AFTER INSERT trigger on an Opportunity.
            chatterUp(Trigger.new)  
            
        Method will create a new Chatter Post on the parent for each newly created object 
        if the object type is a candidate for Chatter Up
        
    */
    public void chatterUp(List<sObject> objects) {
        List<FeedItem> posts = new List<FeedItem>();

        if(objects.size() > 0) {
                
            Chatter_Up__c chatterUp = null;

            set<Id> oppIDs = new set<Id>();
            for(sObject O : objects){
                if (string.valueof(O.id).substring(0,3) == '006') {
                    oppIDs.add(O.ID);
                }
            }
            Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([SELECT Id, Name FROM Opportunity WHERE Id IN :oppIds]);



                // for each newly created object - create a chatter post
            for(sObject obj : objects){
                    // test if this object has ChatterUp settings
                chatterUp = getChatterUpSetting(obj);
                if(chatterUp != null) {

                    Opportunity currOpp = oppMap.get(obj.id);
                    
                        // skip this object if it doesn't have a parent OR it fails due to a picklist value being excluded in configuration
                    if(obj.get(chatterUp.parent_id_field__c) != null && checkPicklistValues(obj, chatterUp)) {
                        FeedItem item = createFeedItem(obj, chatterUp, curropp.name);
                        if(item != null) {
                            posts.add(item);
                        }
                    } 
                } else {
                    System.debug('Object ['+objects[0].getSObjectType().getDescribe().getName()+'] has not been configured in the Chatter Up Custom Settings.');
                }
            }
                // defensive - check before we insert
            if(posts.size() > 0) { 
                insert posts;
            }
        }
    }
    
    /*
        Create a new FeedPost
    */
    private FeedItem createFeedItem(sObject obj, Chatter_Up__c chatterUp, string ChatterText) {
        
        // Making a Chatter Post (from http://wiki.developerforce.com/index.php/Chatter_Code_Recipes )
        FeedItem item = new FeedItem();
        item.ParentId = (Id)obj.get(chatterUp.parent_id_field__c); //eg. Opportunity id, custom object id..
        item.Body = chatterUp.chatter_post_body__c;
        if (string.valueof(obj.id).substring(0,3) == '006') {
            //list<opportunity> lstOpptys = new list<opportunity>([select name from opportunity where id = :obj.id]);
            //for(opportunity Oppty  : lstOpptys ){
                      item.Body = item.Body + '\nThe name of the opportunity is:' + ChatterText;
            //}
        }

        // Chatter Link is not required field - need to test first.
        if(chatterUp.chatter_link_title__c != null ){
            item.title = chatterUp.chatter_link_title__c;
            item.LinkUrl = '/'+obj.get('id');
        }
        
        return item;
    }
    
    /*
        Returns the Object if found in the Custom Settings Chatter Up
        See Chatter Up documentation for setup guide.
    */
    private Chatter_Up__c getChatterUpSetting(sObject obj) {
        // loop thru the chatter setting entries and see if this Object
        // is a candidate for Chatter Up
        for(Chatter_Up__c setting : chatterUpSettings) {
        
            if(setting.object_api_name__c.equals(obj.getSObjectType().getDescribe().getName())) {
                return setting;
            }
        }
        // a null return will indicate this object type is not configured Chatter Up.
        return null;
    }

    /*
        will check the Picklist_that_Constrains_Chatter_Up__c field and 
        see if the value of this Object would keep it from being included
        in the Chatter Up
    */  
    private boolean checkPicklistValues(sObject obj, Chatter_Up__c settings) {
    
        String picklistFieldName = settings.picklist_that_constrains_chatter_up__c;
        String picklistValues = settings.picklist_values__c;
        if(picklistFieldName != null && picklistValues != null)  {
        
            if(contains(picklistValues.split(';'), (String)obj.get(picklistFieldName))) {
                return true;
            } else {
                return false;
            }   
        }
        return true;
    }
    
    private boolean contains(List<String> values, String value) {
        
        for(String s : values) {
            if(s.equals(value)) {
                return true;
            }
        }
        return false;
    } 
    
}