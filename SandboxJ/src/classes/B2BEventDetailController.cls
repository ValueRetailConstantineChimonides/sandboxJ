public class B2BEventDetailController {
    B2B_Config_Settings__c b2bSettings;
    public B2BEventDetailController(){
        b2bSettings = B2B_Config_Settings__c.getInstance();
        
        Id eventId =  ApexPages.currentPage().getParameters().get('theEventId');
        Event currentEvent = getTheDetailEvent(eventId);
        if(null != currentEvent ){
            detailEvent = currentEvent;
        }else{
            detailEvent = new Event();
        }
        
        findAttendees(eventId);
        
    }

    public Event detailEvent{get;set;}
    public Boolean getRenderTimeZone(){
        if( null != detailEvent  && null != detailEvent.Location_Time_Zone__c){
            return true;
        }else{
            return false;
        }
    }
    public List<B2BAlertViewGenerator.AttendeeRender> attendees{get;set;}
    public String villagesDiscussed {get;set;}
    
    private Event getTheDetailEvent(Id eventId){
        Event returnEvent = null;
  
            Event retrievedEventFromDB = [SELECT Id, RecordTypeId,Subject,Event_Department__c,WhatId, What.Name, WhoId, Who.Name,Location, IsAllDayEvent, ActivityDateTime, ActivityDate, 
                StartDateTime, EndDateTime, Description, Village_Category__c, Non_VR_Outlet_Full_Price_Performance__c, AccountId, Owner.Name, OwnerId, Type, IsChild, IsGroupEvent, 
                GroupEventType, CreatedDate, CreatedById,Location_Time_Zone__c,StartDateTimeString__c,EndDateTimeString__c,Reason__c
                    FROM Event  
                    WHERE
                    Id = :eventId 
                    ];

            returnEvent = retrievedEventFromDB;
            
            // Set villages discussed
            if(null != retrievedEventFromDB.Village_Category__c && retrievedEventFromDB.Village_Category__c.length() > 0){
                List<String>  villagesDiscussedList = retrievedEventFromDB.Village_Category__c.split(';');
                villagesDiscussed ='';
                Integer villageCounter = 0;
                for(String aVillage : villagesDiscussedList){
                    villageCounter++;
                    villagesDiscussed += aVillage;
                    if(villageCounter < villagesDiscussedList.size()) villagesDiscussed+=', ';
                }

            }
        return returnEvent;
    }
    
      private void findAttendees(Id eventId){
        B2BAlertViewGenerator viewGenerator = new B2BAlertViewGenerator();
        Set<Id> eventIds = new Set<Id>();
        eventIds.add(eventId);
        
        attendees = ( viewGenerator.findAttendees(eventIds)  ).get(eventId);        
    }
    
    
    
}