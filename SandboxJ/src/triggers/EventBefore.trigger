/**
 *  @author: Andrey Gavrikov (Westbrook)
 *  @date: 2011-02-01 12:48:51 
 
 *  @description: 
 *      IF 
 *          "The meeting Start Date [Event.StartDate] is in the future".
 *          AND
 *          Event.RecordTypeID is "B2B Event"
 *      THEN
 *      Update Event Subject using format:
 *      “<Assigned to> Meeting with <Brand> on <Meeting Start Date>”
 *
 *      Where:
 *      "Assigned to" - is taken from - Event: "Assigned To [OwnerId]" field, assume only User here
 *      "Brand" - is taken from - Event: "Related To [WhatId]" field, assume only Account here
 *      "Meeting Start Date" - is taken from - Event: "StartDate" field
 *  
 *  Version History :
 *      2011-03-26 - AG
 *          Implementation of the "Greater or equal to today + 1 day" criteria which specifies that the meeting is in the future.      
 *      
 */
 
 trigger EventBefore on Event (before insert, before update) {
    if (TriggerUtils.skipTrigger('EventBefore')) {return;}
    
    TriggerUtils.addToSkipTriggerMap('EventBefore', 'execute once');
    
    final Date futureDate_verify_Status = System.today().addDays(1);
    final Datetime timeFuture_Verify_Status = Datetime.newInstance(futureDate_verify_Status.year(), futureDate_verify_Status.month(), futureDate_verify_Status.day());

    final Date futureDate = System.today() +1;
    final Datetime timeFuture = Datetime.newInstance(futureDate.year(), futureDate.month(), futureDate.day());
    Map<Id, Account> brandById = new Map<Id, Account>();
    Map<Id, User> userById = new Map<Id, User>();
    
    final String DATE_FORMAT_ALL_DAY_EVENT = 'dd MMM yyyy';
    final String DATE_FORMAT = 'dd MMM yyyy HH:mm';
    final String CALENDAR_VIEW_DATE_FORMAT = 'dd/MM/yyyy HH:mm';
    
    for (Event evt : Trigger.new) {
        String meetingCompleyedState = 'Meeting Completed';
        // Default meeting confirmed
        if(evt.Send_Email_Alert__c == false && meetingCompleyedState != evt.Event_Status__c ){
            evt.Event_Status__c = 'Meeting Confirmed';
        }
        
        // Validate Follow up Emails
        if( null != evt.VR_Employee_Actions__c && evt.VR_Employee_Actions__c.trim().length() > 0){
            String invalidatedEmail = B2BEventsUtility.validateFollowUPEmails(evt.VR_Employee_Actions__c);
            if(invalidatedEmail != ''){
                String errorMsg = 'Error !!! the "VR Follow Up Event owner(s)" field may have invalid or unauthorised email addresses. Please check the following emails :  ';
                errorMsg += invalidatedEmail;
               throw new B2BEventsUtility.ValidationException(errorMsg);
            }
        }
        
        
        if (evt.Send_Email_Alert__c && ( null != evt.Description && evt.Description.trim().length() > 0 ) ) {
                if(null != evt.EndDateTime && evt.EndDateTime < timeFuture_Verify_Status){
                    evt.Event_Status__c =  'Meeting completed';
                 }
        }
        
        //Make sure every Event has StartDateTime__c field populated
        evt.StartDateTime__c = evt.StartDateTime;
        
        if(null != evt.StartDateTime)evt.StartDateTimeString__c = evt.StartDateTime.format(CALENDAR_VIEW_DATE_FORMAT) ;
        if(null != evt.EndDateTime)evt.EndDateTimeString__c = evt.EndDateTime.format(CALENDAR_VIEW_DATE_FORMAT);
        
        if (EventBeforeSupport.B2B_EVENT_RT == evt.RecordTypeId && null != evt.StartDateTime){ 
            // Event is in the future and of correct RT
            //collect Account & User ids
            if (null != evt.WhatId) {
                brandById.put(evt.WhatId, null);
            }
            if (null != evt.OwnerId) {
                userById.put(evt.OwnerId, null);
            }
        
        }
    }
    
    if (!brandById.isEmpty()) {
    //load accounts
        brandById = new Map<Id, Account> ([select Id, Name from Account where Id in: brandById.keySet() ]);
    }
    if (!userById.isEmpty()) {
    //load accounts
        userById = new Map<Id, User> ([select Id, Name from User where Id in: userById.keySet() ]);
    }
    
        //assign new subjects now
    for (Event evt : Trigger.new) {
        
        if (EventBeforeSupport.B2B_EVENT_RT == evt.RecordTypeId && null != evt.StartDateTime ) { // Event is in the future   && evt.StartDateTime >= timeFuture
            //set new subject: "<Assigned to> Meeting with <Brand> on <Meeting Start Date>"
            User usr = userById.get(evt.OwnerId);
            String userName = null != usr ? usr.Name : null;
    
            Account acc = brandById.get(evt.WhatId);
            String brandName = null != acc ? acc.Name : null;
            
            if (null != brandName && null != userName) {
                String dateFormat = evt.IsAllDayEvent ? DATE_FORMAT_ALL_DAY_EVENT : DATE_FORMAT;
                evt.Subject = String.format(System.Label.Brand_Meeting_Subject, new String[] {userName, brandName, evt.StartDateTime.format(dateFormat)});
            }
        }
    }
}