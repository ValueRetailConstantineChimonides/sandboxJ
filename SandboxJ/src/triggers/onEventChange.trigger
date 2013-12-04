/* ENG-0711-58
Auto-update Contact field based on B2B Contact Report
On Insert or update of B2B Contact Report field 'Lease Book Handed Over' (True or False) 
update the associated named Contact field 'Actual Handover Date' with the date value of the B2B Contact Report "Due Date". 

*/
trigger onEventChange on Event (after insert, after update) {
            
    /* B2B Alerts */
    if (Trigger.isDelete) {
        B2BContactReportAlertGenerator.cleanOldRecipients(Trigger.oldMap.keySet(), null);
        return;
    }
    
    final Date futureDate = System.today().addDays(1);
    final Datetime timeFuture = Datetime.newInstance(futureDate.year(), futureDate.month(), futureDate.day());
    
    //insert/update
    final Map<Id, Event> b2bAlertEventMapToSend = new Map<Id, Event>();
    final Set<Id> b2bAlertCancelledEventId = new Set<Id>();
    for (Event anEvent : trigger.new) {
        if (anEvent.IsChild) { 
            continue;
        }
            
        if (anEvent.Send_Email_Alert__c) {          
            // With New requirement to enforce only sending of Reports i.e when the 
            //description field is filled out and the event is in the PAST
            if( (null != anEvent.Description && anEvent.Description.trim().length() >0 ) && 
                (EventBeforeSupport.B2B_EVENT_RT == anEvent.RecordTypeId ) ){
                    // && (null != anEvent.StartDateTime && anEvent.StartDateTime < timeFuture)
                    if(null != anEvent.EndDateTime && anEvent.EndDateTime < timeFuture){
                        b2bAlertEventMapToSend.put(anEvent.Id, anEvent);
                    }
            }
            
        } else if (Trigger.isUpdate && Trigger.oldMap.get(anEvent.Id).Send_Email_Alert__c) {
            //Send_Email_Alert__c used to be true but user changed it to False
            b2bAlertCancelledEventId.add(anEvent.Id);
        }
    }
 
    if (!b2bAlertEventMapToSend.isEmpty()) {
        //remove any existing recipient holders
        B2BContactReportAlertGenerator.cleanOldRecipients(b2bAlertEventMapToSend.keySet(), null);
        //generate new recipient holders
        B2BContactReportAlertGenerator generator = new B2BContactReportAlertGenerator();
        generator.generateRecipients(b2bAlertEventMapToSend.values());
        
        //delete old Recipient Holders
        B2BContactReportAlertGenerator.cleanOldRecipients(null, 7);
    }
    
    if (!b2bAlertCancelledEventId.isEmpty()) {
        //Send_Email_Alert__c used to be true but user changed it to False
        B2BContactReportAlertGenerator.cleanOldRecipients(b2bAlertCancelledEventId, null);  
    }
    

    
    ////////////// Works only for Batch size =1 ///////////////
    final Event event = trigger.new[0];
    /* Lease_Book_Handed_Over__c */
    if (!event.Lease_Book_Handed_Over__c && !event.Shopfit_Book_Handed_Over__c)
        return;
    //mark date when Lease_Book was Handed_Over
    //Event event = Trigger.new[0];
    if (event.ActivityDate != null && event.WhoId != null) {
        Contact contact = null;
        try {
            contact = [select id, Actual_Handover_Date__c, Actual_Handover_Date_SB__c from Contact where id =: event.WhoId];
        } catch (Exception e) {
            return;//Who does not seem to be existing contact
        }
        Boolean needUpdate = false;
        if (event.Lease_Book_Handed_Over__c && contact.Actual_Handover_Date__c == null) {
            contact.Actual_Handover_Date__c = event.ActivityDate;
            needUpdate = true;
        }
        if (event.Shopfit_Book_Handed_Over__c && contact.Actual_Handover_Date_SB__c == null) {
            contact.Actual_Handover_Date_SB__c = event.ActivityDate;
            needUpdate = true;
        }
        
        if (needUpdate)
            update contact;
            
            
           
    }
}