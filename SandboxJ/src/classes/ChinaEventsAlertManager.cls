public with sharing class ChinaEventsAlertManager {
    public static void processChinaEventAlert(Map<ID,Event > newMap,Map<ID,Event > oldMap){
        China_Event_Settings__c chinaEventSettinfs = China_Event_Settings__c.getInstance();
        String SERVERL_URL = chinaEventSettinfs.Server_Instance_Url__c;
        String B2BRecordtypeIdContact = chinaEventSettinfs.B2B_Contact_RecordTypeId__c;
        
        Set<Id > eventsForAlertProcessing = new Set<Id>();
        for(Event  anEvent : newMap.values()){
            if(null != anEvent.Village_Category__c  && 
                    (anEvent.Village_Category__c.indexOf('Suzhou') >=0 || anEvent.Village_Category__c.indexOf('Pudong') >=0 ) ){
                eventsForAlertProcessing.add(anEvent.Id);
            }
            
        }
        
        if(eventsForAlertProcessing.size() > 0 && inclassTest == false ){
            User CURRENT_USER = [select Id, email from User where Id=:UserInfo.getUserId()];
            try{
                Database.executeBatch(new AsyncChinaEventsAlert(eventsForAlertProcessing,CURRENT_USER.Email+'',SERVERL_URL,B2BRecordtypeIdContact));
            }catch(Exception exp){
                System.debug('***************** EXCEPTION ****************');
                
                System.debug('***************** EXCEPTION ****************   '+exp);
            }
            
        }
    }
    
    public static Boolean inclassTest = false;
    
    static testMethod void testChineseEventAlert(){
        China_Event_Settings__c chinaEventSettinfs = China_Event_Settings__c.getInstance();
        
        // Create the test contact
        Contact testContact = new Contact();
        testContact.RecordTypeId =  chinaEventSettinfs.B2B_Contact_RecordTypeId__c;
         testContact.FirstName = 'Testing_ One';
         testContact.LastName = 'Testing1';
         testContact.China_Event_Alert__c = true;
         User CURRENT_USER = [select Id, email from User where Id=:UserInfo.getUserId()];
         testContact.Email = CURRENT_USER.Email;
         
         Test.startTest();
         
         Database.insert(testContact);
         
          // Create the Event
         List<Event> testEventsList = new List<Event>();
         for(Integer x =0; x<4; x++){
            Event testEvent = new Event();
            
            testEvent.Village_Category__c ='Suzhou';
            
                testEvent.Subject = 'Leasing/Commercialisation';
            testEvent.description = 'Testing In Unit Test for  China Event';
            
            
            testEvent.StartDateTime = System.now();
            testEvent.EndDateTime = System.now();
            
            testEventsList.add(testEvent);
         }
         
         Set<Id> testEventIDs = new Set<Id>();
         Database.Saveresult[] insertEventResultList =  Database.insert(testEventsList);
         for(Database.Saveresult aResult : insertEventResultList){
            testEventIDs.add(aResult.getId());
         }
         // retrieve the inserted Event
         Map<ID,Event> insertedTestEventList = new Map<ID,Event>([SELECT id, Village_Category__c,Description FROM Event WHERE Id IN :testEventIDs]); 
                
            Event testEvent_1 = insertedTestEventList.values().get(0);
            Event testEvent_2 = insertedTestEventList.values().get(1);
            Event testEvent_3 = insertedTestEventList.values().get(2);
            Event testEvent_4 = insertedTestEventList.values().get(3);
         
         // Call the Class Trigger Logic
         inclassTest = true;
         processChinaEventAlert(insertedTestEventList , null);
         inclassTest = false;
         
         Map<Id,Event> update_1 = new Map<Id,Event>();
         update_1.put(testEvent_1.Id,testEvent_1);
         
         update_1.put(testEvent_2.Id,testEvent_2);
         
         update_1.put(testEvent_3.Id,testEvent_3);
         
         update_1.put(testEvent_4.Id,testEvent_4);
         
         // Call the Class Trigger Logic
         inclassTest = true;
         processChinaEventAlert( update_1,insertedTestEventList);
         inclassTest = false;
         
         Database.update(update_1.values());
         
        
         
         Test.stopTest();
        
    }

}