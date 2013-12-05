global with sharing class AsyncChinaEventsAlert  implements Database.Batchable<SObject>, Schedulable {
    
    private final String TriggerName = 'ChinaEventAlert';
    private Set<Id> eventsIdList;
    private String replyToEmail  ;
    private String SERVERL_URL;
    private String B2BAdminContactRecordTypeId;
    
    public AsyncChinaEventsAlert(Set<Id> eventsForAlertProcessing,String CURRENT_USER_EMAIL, String serverUrl,String b2bAdminContactRecordTypeIdParam){
        eventsIdList = eventsForAlertProcessing;
        replyToEmail = CURRENT_USER_EMAIL;
        SERVERL_URL = serverUrl;
        B2BAdminContactRecordTypeId = b2bAdminContactRecordTypeIdParam;
        
    }
    public AsyncChinaEventsAlert(){
        
    }
    global void execute(SchedulableContext SC) {
        Database.executeBatch(new AsyncChinaEventsAlert());
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        // get All contacts that should recieve China events mail
        String soqlStr = 'SELECT Id,China_Event_Alert__c,Email'+
                                ' FROM Contact'+
                                    ' WHERE '+ 
                                    ' China_Event_Alert__c = true And RecordTypeId = '+ '\'' + B2BAdminContactRecordTypeId + '\'' ;
                                    
        return Database.getQueryLocator(soqlStr);
        
    }
    
    global void execute(Database.BatchableContext BC, List<Sobject> scope){
        List<String> recipientEmails = new List<String>();
        if(scope != null){
            if(scope.size() > 0){
                for(SObject so : scope){
                    Contact recipientContact = (Contact)so;
                    recipientEmails.add(recipientContact.Email);
                }
            }
        }
        if(recipientEmails.size() > 0){
            sendOutAlert(recipientEmails);
        }
    }
    
    private void sendOutAlert(List<String> targetRecipients){
        final Map<Id, Event> eventsMap = loadEvents(eventsIdList);
        
        for(Event anEvent : eventsMap.values()){
            String eventAlertSubject  = (anEvent.What.Name + ' - ' + anEvent.Subject + ' - B2B China Alert');
            String mailPlainBody = getPlainBody(anEvent);
            String mailHTMLBody = getHTMLBody(anEvent);
            
            Messaging.SingleEmailMessage chinaMail = new Messaging.SingleEmailMessage();
            chinaMail.setSubject(eventAlertSubject);
            chinaMail.setPlainTextBody(mailPlainBody);
            chinaMail.setHtmlBody(mailHTMLBody);
            chinaMail.setReplyTo(replyToEmail);
            chinaMail.setToAddresses(targetRecipients);
            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { chinaMail });
        }
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
    
    private String getHTMLBody(final Event anEvent) {
        String emailBodyHTML = emailBodyHTMLByEventId.get(anEvent.Id);        
        if (emailBodyHTML != null)
            return emailBodyHTML;
    
        //open main span    
        emailBodyHTML = '<span style="font-weight: bold;font-size: 10pt;font-family: \'Arial\', \'Helvetica\';">';
        
        emailBodyHTML +=
                '<span style="color: black;">' + 
                'Account/Brand - </span><span style="color: blue;font-size: 12pt;">' + anEvent.What.Name + '</span>'+
                '<br>';
        emailBodyHTML += ''+
                'Subject - <span style="color: blue;">' + anEvent.Subject + '</span>' +
                '<br>';

        emailBodyHTML += '<br>';
        emailBodyHTML += 'Chinese Village/s of Interest :';
         emailBodyHTML += '<span style="color: green;">' + anEvent.Chinese_Village_of_Interest__c + '</span><br>';
        emailBodyHTML += '<span style="color: green;">' + getWhoIsInvolved(anEvent, true) + '</span><br>';
        
        emailBodyHTML += 'Key Contact - <span style="font-weight: normal;">' + anEvent.Who.Name + '</span><br>';
        emailBodyHTML += 'Assigned To - <span style="font-weight: normal;">' + anEvent.Owner.Name + '</span><br>';
        //emailBodyHTML += 'Other Invitees:<br>';
        // emailBodyHTML += '<span style="font-weight: normal;">' + getEventInvitees(anEvent.id, true) + '</span><br>';
        
        emailBodyHTML += 'Contact for Asia/China : <br>';
        emailBodyHTML += '<span style="font-weight: normal;">' + getNotNull(anEvent.Contact_for_Asia_China__c, true) + '</span><br>';
        
        emailBodyHTML += '<br>';
        emailBodyHTML += 'Meeting Comments:<br>';
        emailBodyHTML += '<span style="font-weight: normal;">' + getNotNull(anEvent.Description, true) + '</span><br>';
        //emailBodyHTML += '<span style="font-weight: normal;">' + getNotNull(anEvent.Meeting_Summary_2__c, true) + '</span><br>';
        //emailBodyHTML += '<span style="font-weight: normal;">' + getNotNull(anEvent.Meeting_Summary_3__c, true) + '</span><br>';
        
        emailBodyHTML += '<br>';
        Date activityDate = anEvent.ActivityDate;
        if (activityDate != null)
            emailBodyHTML += 'Date of Meeting - <span style="font-weight: normal;">'+ activityDate.day() + '/' + activityDate.month() + '/' + activityDate.year() +'</span><br>';
        emailBodyHTML += 'Location - <span style="font-weight: normal;">'+ getNotNull(anEvent.Location, true) +'</span><br>';
        emailBodyHTML += 'Lease Book Handed Over - <span style="font-weight: normal;">' + (anEvent.Lease_Book_Handed_Over__c? 'Yes':'No') + '</span><br>';
        emailBodyHTML += 'Follow Up - <span style="font-weight: normal;">'+ getNotNull(anEvent.Follow_Up_1__c, true) +'</span><br>';
        emailBodyHTML += 'Link to Report in Salesforce - <span style="font-weight: normal;"><a href="'+SERVERL_URL + anEvent.id+'">' + anEvent.Subject + '</a>' +'</span><br>';
        emailBodyHTML += '</span>';//close main span
        //save for future use
        emailBodyHTMLByEventId.put(anEvent.Id, emailBodyHTML);         
        return emailBodyHTML;   
    }
    
    private Map<Id, String> emailBodyPlainByEventId = new Map<Id, String>();
    private Map<Id, String> emailBodyHTMLByEventId = new Map<Id, String>();
    
    private String getPlainBody(final Event anEvent) {
        String emailBodyPlain = emailBodyPlainByEventId.get(anEvent.Id);      
        if (emailBodyPlain != null)
            return emailBodyPlain;
            
        String emailBody;
        emailBody = '';
        
        emailBody += 'Account/Brand - ' + anEvent.What.Name + '\n';
        emailBody += 'Subject - ' + anEvent.Subject + '\n';
        
        emailBody += '\n';
        emailBody += 'Chinese Village/s of Interest :\n';
        emailBody += anEvent.Chinese_Village_of_Interest__c + '\n';
        emailBody += getWhoIsInvolved(anEvent, false) + '\n';
        
        emailBody += 'Key Contact - ' + anEvent.Who.Name + '\n';
        emailBody += 'Assigned To - ' + anEvent.Owner.Name + '\n';
        //emailBody += 'Other Invitees:\n';
        // <<emailBody += getEventInvitees(event.id, false) + '\n';>>
        
        emailBody += 'Contact for Asia/China';
        emailBody += getNotNull(anEvent.Contact_for_Asia_China__c, false) + '\n';
        
        emailBody += '\n';
        emailBody += 'Meeting Comments:\n';
        emailBody += getNotNull(anEvent.Description, false) + '\n';
        //emailBody += getNotNull(anEvent.Meeting_Summary_2__c, false) + '\n';
        //emailBody += getNotNull(anEvent.Meeting_Summary_3__c, false) + '\n';
        
        emailBody += '\n';
        Date activityDate = anEvent.ActivityDate;
        if (activityDate != null)
            emailBody += 'Date of Meeting - '+ activityDate.day() + '/' + activityDate.month() + '/' + activityDate.year() +'\n';
        emailBody += 'Location - '+ getNotNull(anEvent.Location, false) +'\n';
        emailBody += 'Lease Book Handed Over - ' + (anEvent.Lease_Book_Handed_Over__c? 'Yes':'No')+'\n';
        emailBody += 'Follow Up - '+ getNotNull(anEvent.Follow_Up_1__c, false) +'\n';
        emailBody += 'Link to Report in Salesforce:' + SERVERL_URL + anEvent.id + '\n';
        emailBodyPlain = emailBody;
        
        //save for future use
        emailBodyPlainByEventId.put(anEvent.Id, emailBodyPlain);       
        
        return emailBodyPlain;  
    }
    
    private String getNotNull(String value, Boolean isHtml) {
        return getNotNull(value, null, isHtml); 
    }
    public static String getNotNull(String value, String defaultVal, Boolean isHtml) {
        Pattern newLinePattern = Pattern.compile('\n');
        String retValue = '';
        if (value != null)
            retValue = value;
        else if (defaultVal != null)
            retValue = defaultVal;
        
        if (isHtml) {
            //replace lines separator
            retValue = newLinePattern.matcher(retValue).replaceAll('<br>');
        }   
        return retValue;
            
    }
    
    private String getWhoIsInvolved(Event theEvent, Boolean isHtml) {
        String villageCategoryList = '';
        
        // Set villages discussed
            if(null != theEvent.Village_Category__c && theEvent.Village_Category__c.length() > 0){
                List<String>  villagesDiscussedList = theEvent.Village_Category__c.split(';');
                
                for(String aVillage : villagesDiscussedList){
                    villageCategoryList += '-'+aVillage + (isHtml?'<br>':'\n') ;
                }            
            }
            return villageCategoryList;
        
    }
    
    private static Map<Id, Event> loadEvents (Set<Id> eventIds) {
        return new Map<Id, Event> ([select id, WhatId, What.Name, WhoId, Who.Name,
                            OwnerId, Owner.Name,
                            Follow_Up_1__c, ActivityDate, Location,
                            Contact_for_Asia_China__c,
                            Description, Lease_Book_Handed_Over__c,
                            Subject,Event.Chinese_Village_of_Interest__c,Village_Category__c
                            
                            from Event where id in: eventIds]);
    }
    

    
}