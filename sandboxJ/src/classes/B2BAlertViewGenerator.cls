/*
13/06/2012  Event.Department__cc now used to categorize event by subject types. Variable & Method name
may still refer to subject or subjectTypess 
*/

public class B2BAlertViewGenerator {
    List<String> filterRecordType;
    B2B_Config_Settings__c b2bSettings;
    
    public static final String ATTENDEE_TYPE_VR = 'VR';
    public static final String ATTENDEE_TYPE_BRAND = 'Brand';
    
    public B2BAlertViewGenerator(){
        filterRecordType =  new List<String>();
        filterRecordType.add('B2B Event');
        filterRecordType.add('B2B Event China');
        
        b2bSettings = B2B_Config_Settings__c.getInstance();
        
    }
    
    public Map<Id,Event> getDayEvents(DateTime eventDate){
        if(null == eventDate)eventDate = System.now();
        Map <Id,Event> eventsFilteredForDay = new Map<Id,Event>();
        
        Date filterOnStartDate = eventDate.dateGmt().addDays(-4);
        Date filterOnEndDate = eventDate.dateGmt().addDays(-1);
        
        // Query to retrieve Events Data
        for(Event anEvent : [SELECT Id, RecordTypeId,Subject,WhatId, What.Name, WhoId, Who.Name,Location, IsAllDayEvent, ActivityDateTime, ActivityDate, 
                StartDateTime, EndDateTime, Village_Category__c,Non_VR_Outlet_Full_Price_Performance__c, Description, AccountId, Owner.Name, OwnerId, Type, IsChild, IsGroupEvent, 
                GroupEventType, CreatedDate, CreatedById, Location_Time_Zone__c,StartDateTimeString__c,EndDateTimeString__c,Event_Department__c,Reason__c
                    FROM Event  
                    WHERE
                    RecordType.Name IN :filterRecordType
                    And
                    (StartDateTime > :filterOnStartDate  And EndDateTime > :filterOnEndDate )
                    And 
                    IsChild = false
                    
                    Order By StartDateTime DESC
                    LIMIT 4900
                    ]){
           // Pick out the day from StartDateString  and EnddateTimeString
           // If  Start DayDate <= And End DayDate >= todayDate
           String  startString =  anEvent.StartDateTimeString__c;
           String endDateString = anEvent.EndDateTimeString__c;
           
           Integer startDay = 0;
           Integer startYear = 0;
           Integer startMonth = 0;
           
           Integer endDay = 0;
           Integer endYear = 0;
           Integer endMonth = 0;
           
           if(Null != startString && startString.trim().length() > 12){
                startDay =  Integer.valueOf( ( startString.substring(0,2) ) );
                startYear =     Integer.valueOf( ( startString.substring(6,10) ) );
                startMonth =    Integer.valueOf( ( startString.substring(3,5) ) );
           }
           
           if(Null != endDateString && endDateString.trim().length() > 12){
                endDay =    Integer.valueOf( ( endDateString.substring(0,2) ) );
                endYear =   Integer.valueOf( ( endDateString.substring(6,10) ) );
                endMonth =  Integer.valueOf( ( endDateString.substring(3,5) ) );
           }
           
           Integer todayDateDay = eventDate.dateGmt().day();
           Integer todayDatemonth = eventDate.dateGmt().month();
           Integer todayDateYear = eventDate.dateGmt().year();
           
           
           Date startDateFromString = Date.newInstance(startYear, startMonth, startDay);
           Date endDateFromString = Date.newInstance(endYear, endMonth, endDay);
           
           if(startDay == todayDateDay && startMonth == todayDatemonth){
                // add to return Map
                eventsFilteredForDay.put(anEvent.Id,anEvent);
           }else if( startDateFromString <= eventDate.dateGmt() && endDateFromString >= eventDate.dateGmt() ){
                // add to return Map
                eventsFilteredForDay.put(anEvent.Id,anEvent);
           }
        }
        
        return eventsFilteredForDay;
    }


    public Map<Id,Event>  getCalendarViewOfEvents(DateTime newDateRange, Set<String> subjectTypes){
        return getWeeklyViewOfEventData(newDateRange,subjectTypes);
    }
    
    /*
        private String convertToMultiSelectIncludeString(Set<String> setOfOptions){
        String multiSelectOpyionsList = '';
        Integer counter = 0; 
        for(String anOption : setOfOptions){
            counter++;
            multiSelectOpyionsList += '\''+ anOption +'\'';
            if(counter < setOfOptions.size())multiSelectOpyionsList += ',';
        }
        
        return multiSelectOpyionsList;
    }
    */
    
    private Map <Id,Event> getWeeklyViewOfEventData(DateTime newDateRange, Set<String> subjectTypes){
        if(null != newDateRange){
            newDateRange = DateTime.newInstanceGmt(newDateRange.date(), newDateRange.time());
        }else{
            newDateRange = DateTime.newInstanceGmt(System.now().date(), System.now().time());
        }
   
        // Set Start Date
        Date filterStartDate = newDateRange.date().toStartOfWeek();
        filterStartDate = filterStartDate.addDays(-1); // Make allowance for Time Zone differences;
        Date filterEndDate = filterStartDate.addDays(6);
        
            // Query to retrieve Events Data
            Map <Id,Event> eventsFilteredForWeek =  new Map <Id,Event>([SELECT Id, RecordTypeId,Subject,Event_Department__c,WhatId, What.Name, WhoId, Who.Name,Location, IsAllDayEvent, ActivityDateTime, ActivityDate, 
                StartDateTime, EndDateTime, Village_Category__c,Non_VR_Outlet_Full_Price_Performance__c, Description, AccountId, Owner.Name, OwnerId, Type, IsChild, IsGroupEvent, 
                GroupEventType, CreatedDate, CreatedById,
                Location_Time_Zone__c, EndDateTimeString__c,StartDateTimeString__c
                    FROM Event  
                    WHERE
                    (Event_Department__c IN :subjectTypes  Or Subject IN :subjectTypes )
                    And
                    RecordType.Name IN :filterRecordType
                    And 
                    IsChild = false
                    And 
                    (StartDateTime >= :filterStartDate 
                    Or
                    EndDateTime >= :filterStartDate)
                    Order By StartDateTime, What.Name
                    LIMIT 4900
                    
                    ]);
                    
        if(null != eventsFilteredForWeek){
            return eventsFilteredForWeek;
        }else{
            return new Map<Id,Event>();   
        }
    }
    
    public List<String> describeEventVillageCategory(){
        // Get the pickList Values
        List<String> villageOptions = new List<String>(); 
        Schema.DescribeFieldResult fieldDesc = Event.Village_Category__c.getDescribe();
        for (Schema.PicklistEntry pickOption : fieldDesc.getPicklistValues()){
            villageOptions.add(pickOption.getLabel());
        }
        
        return villageOptions;
        
    }
    
    public Set<String> describeSubjectPickList(){
        // Get the pickList Values
        Set<String> filterOptions = new Set<String>(); 
        Schema.DescribeFieldResult fieldDesc = Event.Event_Department__c.getDescribe();
        for (Schema.PicklistEntry pickOption : fieldDesc.getPicklistValues()){
            filterOptions.add(pickOption.getLabel());
        }
        return filterOptions;
    }
    
    public Map<Id,List<AttendeeRender>> findAttendees(Set<Id> eventIds){
        List<EventAttendee> attendeesList = [Select Id, EventId, AttendeeId from EventAttendee where EventId IN :eventIds];
        
        Map<Id,List<AttendeeRender>> attendeeRenderByEventId = new Map<Id,List<AttendeeRender>>();
        
        Map<Id,List<Id>> attendeeIdsByEventId = new Map<Id,List<Id>>();
        for( EventAttendee anAttendee  : attendeesList){
            if( null != attendeeIdsByEventId.get(anAttendee.EventId) ){
                attendeeIdsByEventId.get(anAttendee.EventId).add(anAttendee.AttendeeId);
            }else {
                List<Id> attendeeIdsList = new List<Id>();
                attendeeIdsList.add(anAttendee.AttendeeId);
                attendeeIdsByEventId.put(anAttendee.EventId , attendeeIdsList );
            }
        }
        
        for( Id anEventId : attendeeIdsByEventId.keySet() ){
            // Find all Users that may be attendees
            for(user aUser : [Select Id, Username, LastName, FirstName, Name FROM uSER wHERE Id In :attendeeIdsByEventId.get(anEventId)]){
                AttendeeRender  anAttendee = new AttendeeRender();
                anAttendee.attendeeName = aUser.FirstName +' '+ aUser.LastName;
                anAttendee.attendeeType = ATTENDEE_TYPE_VR;
            
                addAttendeeRender(anEventId,attendeeRenderByEventId,anAttendee);
            }
            
             // Find all Leads that may be attendees
            for(Lead aLead : [ Select Id,LastName, FirstName, Salutation From Lead Where Id In :attendeeIdsByEventId.get(anEventId) ]){
                AttendeeRender  anAttendee = new AttendeeRender();
                anAttendee.attendeeName = aLead.FirstName +' '+ aLead.LastName;
                anAttendee.attendeeType = ATTENDEE_TYPE_BRAND;
            
                addAttendeeRender(anEventId,attendeeRenderByEventId,anAttendee);
            }
            
            // Find all Contacts that may be attendees
            for(Contact aContact : [ Select Id, AccountId, LastName, FirstName, Salutation, Name, RecordTypeId FROM Contact where Id In :attendeeIdsByEventId.get(anEventId) ]){
                AttendeeRender  anAttendee = new AttendeeRender();
                anAttendee.attendeeName = aContact.FirstName +' '+ aContact.LastName;
            
                if( null != aContact.RecordTypeId && aContact.RecordTypeId == b2bSettings.B2B_Brand_Contact_Record_Type_Id__c){
                    anAttendee.attendeeType = ATTENDEE_TYPE_BRAND;  
                }else if(null != aContact.RecordTypeId && aContact.RecordTypeId == b2bSettings.B2B_Admin_Contact_Type_Id_VR__c){
                    anAttendee.attendeeType = ATTENDEE_TYPE_VR;
                }else{
                    anAttendee.attendeeType = 'NA';
                }
                addAttendeeRender(anEventId,attendeeRenderByEventId,anAttendee);
            }
        }
        
        return attendeeRenderByEventId;
        
    }
    
    private void addAttendeeRender(Id eventId, Map<Id,List<AttendeeRender>> attendeeRenderByEventId, AttendeeRender  anAttendee){
            if( null != attendeeRenderByEventId.get(eventId) ){
                attendeeRenderByEventId.get(eventId).add(anAttendee);
            }else {
                List<AttendeeRender> attendeeRenderList = new List<AttendeeRender>();
                attendeeRenderList.add(anAttendee);
                attendeeRenderByEventId.put(eventId , attendeeRenderList );
            }
    }
    
    public Map<Id,Event> findDueForReporting(){
        DateTime filterOnStartDate = System.now().addHours(-18);
        DateTime startDateFilter = DateTime.newInstance(2012, 6, 1);
         
        String eventStatus = 'Meeting Confirmed';
        
        Map<Id,Event> allDueEvents = new Map<Id,Event>([SELECT Id, RecordTypeId,Subject,Event_Department__c,WhatId, What.Name, WhoId, Who.Name,Location, IsAllDayEvent, ActivityDateTime, ActivityDate, 
                StartDateTime, EndDateTime, Village_Category__c,Non_VR_Outlet_Full_Price_Performance__c, Description, AccountId, Owner.Name,Owner.FirstName, Owner.Email , OwnerId, Type, IsChild, IsGroupEvent, 
                GroupEventType, CreatedDate, CreatedById, Location_Time_Zone__c,StartDateTimeString__c,EndDateTimeString__c,Reason__c
                    FROM Event  
                    WHERE
                    RecordType.Name IN :filterRecordType
                    And
                    (EndDateTime < :filterOnStartDate )
                    And
                    (StartDateTime > :startDateFilter )
                    And
                    Event_Status__c = :eventStatus
                    And 
                    Report_Reminder_Sent__c = false
                    And
                    IsChild = false
                    
                    Order By StartDateTime DESC
                    LIMIT 4900]);

         return allDueEvents;
    }
    
    public Map<Id,Event> findForFollowUpNotify(){
        DateTime startDateFilter = DateTime.newInstance(2012, 6, 1);
        
        final Date futureDate = System.today().addDays(1);
        final Datetime filterOnStartDate = Datetime.newInstance(futureDate.year(), futureDate.month(), futureDate.day());
         
        String eventStatus = 'Meeting completed';
        
        Map<Id,Event> allDueEvents = new Map<Id,Event>([SELECT Id, RecordTypeId,Subject,Event_Department__c,WhatId, What.Name, WhoId, Who.Name,Location, IsAllDayEvent, ActivityDateTime, ActivityDate, 
                StartDateTime, EndDateTime, Village_Category__c,Non_VR_Outlet_Full_Price_Performance__c, Description, AccountId, Owner.Name,Owner.FirstName, Owner.Email , OwnerId, Type, IsChild, IsGroupEvent, 
                GroupEventType, CreatedDate, CreatedById, Location_Time_Zone__c,StartDateTimeString__c,EndDateTimeString__c,Reason__c,Follow_Up_1__c,VR_Employee_Actions__c,VR_Employee_Actions_Alert_Sent__c
                    FROM Event  
                    WHERE
                    RecordType.Name IN :filterRecordType
                    And
                    (EndDateTime < :filterOnStartDate )
                    And
                    (StartDateTime > :startDateFilter )
                    And
                    Event_Status__c = :eventStatus
                    And
                    VR_Employee_Actions_Alert_Sent__c = false
                    And
                    IsChild = false
                    
                    Order By StartDateTime DESC
                    LIMIT 4900]);

         return allDueEvents;
    }
    
    public static void updateMailingLimitTracker(Date trackingDate, Integer ItemCount){
        List<EMail_Limits_Logger__c> emloggerRecs = [SELECT Id, Usage_Date__c, Usage_Count__c From EMail_Limits_Logger__c WHERE Usage_Date__c = :trackingDate];
        
        if(null != emloggerRecs && emloggerRecs.size() >0){
            EMail_Limits_Logger__c loggerRec = emloggerRecs[0];
            Integer usageCount = (null != loggerRec.Usage_Count__c)  ? Integer.valueOf(loggerRec.Usage_Count__c) : 0;
            
            loggerRec.Usage_Count__c = (usageCount + ItemCount);
            
            Database.Update(loggerRec);
        }Else{
            EMail_Limits_Logger__c aloggerRec = new EMail_Limits_Logger__c();
            
            aloggerRec .Name = 'Email Limit Usage For '+ trackingDate;
            aloggerRec.Usage_Count__c = ItemCount;
            aloggerRec.Usage_Date__c = trackingDate;
            
            Database.insert(aloggerRec);
        }
    
    }
    
    public class AttendeeRender{
        public String attendeeName {get;set;}
        public String attendeeType {get;set;}
    }
    
}