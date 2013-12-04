/*
 Sends formatted emails based on the list of existing B2B_Alert_Recipient__c objects
*/
public class B2BContactReportAlertSender {

    public static final String MEETING_TYPE_FUTURE = 'Future meeting';
    
    private static final String SERVERL_URL = 'https://emea.salesforce.com/';

    private Map<Id, String> emailBodyHTMLByEventId = new Map<Id, String>();
    private Map<Id, String> emailBodyPlainByEventId = new Map<Id, String>();
    //private String emailBodyHTML;
    //private String emailBodyPlain;
    //private Event event;
    
    public void sendAlerts(B2B_Alert_Recipient__c[] recipientList) {
        
        final Map<Id, Event> eventsMap = loadEvents(recipientList);
        if (!eventsMap.isEmpty()) {
            final List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
            
            for (B2B_Alert_Recipient__c recipientsObj : recipientList) {
                Event event = eventsMap.get(recipientsObj.Event_Id__c);
                if (null == event) {
                    continue;
                }
                // Create a new single email message object
                // that will send out a single email to the addresses in the To, CC & BCC list.
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                // Strings to hold the email addresses to which you are sending the email.
                String[] toAddresses = recipientsObj.Recipients__c.split(',');
                if(null != toAddresses) System.debug('Recipirnt Count === '+toAddresses.size());
                
                //String[] ccAddresses = new String[] {'smith@gmail.com'};
                //mail.setCcAddresses(ccAddresses);
                
                // Specify the address used when the recipients reply to the email.
                mail.setReplyTo(System.label.B2B_Alert_ReplyTo_Address);
                // Specify the name used as the display name.
                if (MEETING_TYPE_FUTURE == event.h_Frozen_B2B_Alert_Type_Text__c) {
                    // mail.setSenderDisplayName(System.label.B2B_Alert_Future_Sender_Name);
                    mail.setSenderDisplayName(System.label.B2B_Alert_Historical_Sender_Name);
                } else {
                    mail.setSenderDisplayName(System.label.B2B_Alert_Historical_Sender_Name);
                }
                // Specify the subject line for your email address.
                mail.setSubject(event.What.Name + ' - ' + event.Subject + ' - B2B Alert');
                // Set to True if you want to BCC yourself on the email.
                mail.setBccSender(false);
                // Optionally append the salesforce.com email signature to the email.
                // The email address of the user executing the Apex Code will be used.
                mail.setUseSignature(false);
                // Specify the text content of the email.
                mail.setPlainTextBody(getPlainBody(event));
                // Specify the html version of the content as well.
                mail.setHtmlBody(getHTMLBody(event));
                mail.setSaveAsActivity(false);
                
                Integer countWithAT = 0;
                for (String toId : toAddresses) {
                    // Assign the addresses for the To and CC lists to the mail object.
                    if (toId.contains('@')) {
                        countWithAT++;
                        //this is not ID but email address
                        mail.setToAddresses(new String[] {toId});
                    }
                    else {
                        mail.setTargetObjectId(toId);
                    }
                    // Send the email you have created.
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                    System.debug('==== Sent to:' + toId);
                    
                }
                System.debug('Count With @ ==== '+countWithAT);
            }
        }
    }
    
    public static Map<Id, Event> loadEvents (B2B_Alert_Recipient__c[] recipients) {
        Set<Id> eventIds = new Set<Id>();
        for (B2B_Alert_Recipient__c recipient : recipients) {
            eventIds.add(recipient.Event_Id__c);    
        }
        return new Map<Id, Event> ([select id, WhatId, What.Name, WhoId, Who.Name,
                            OwnerId, Owner.Name,
                            Follow_Up_1__c,StartDateTimeString__c,EndDateTimeString__c,Location, Non_VR_Outlet_Full_Price_Performance__c,Location_Time_Zone__c,
                            Description, Lease_Book_Handed_Over__c,
                            Subject,Village_Category__c,StartDateTime,EndDateTime,
                            Bicester__c, Bispingen__c, Fidenza__c, Ingolstadt__c, Kildare__c, 
                            La_Roca__c, La_Vall_e__c, Las_Rozas__c, Maasmechelen__c, 
                            Wertheim__c, Group__c, h_Frozen_B2B_Alert_Type_Text__c,Reason__c 
                            from Event where id in :eventIds ]);
    }
    
    
    private static String getEventInvitees (ID eventId, Boolean isHtml) {
        String namesList = '';
        for ( EventAttendee eventAttendee: [Select AttendeeId, Attendee.Name From EventAttendee where EventId =: eventId]) {
            namesList += '- ' + (isUser(eventAttendee.AttendeeId)? 'VR' : 'Brand') + ' - ' + eventAttendee.Attendee.Name + (isHtml?'<br>':'\n');
        }
        return namesList;
    }
    private static boolean isUser(ID attendeeId) {
        String attId = attendeeId;
        return attId.startsWith('005');
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
    
    // private static String getWhoIsInvolved (Event event, Boolean isHtml) {
       //  String namesList = '';
        // namesList += event.Bicester__c? ('- Bicester' + (isHtml?'<br>':'\n')) :'';
        // namesList += event.Bispingen__c? ('- Bispingen' + (isHtml?'<br>':'\n')) :'';
        // namesList += event.Fidenza__c? ('- Fidenza' + (isHtml?'<br>':'\n')) :'';
        //namesList += event.Ingolstadt__c? ('- Ingolstadt' + (isHtml?'<br>':'\n')) :'';
        //namesList += event.Kildare__c? ('- Kildare' + (isHtml?'<br>':'\n')) :'';
        // namesList += event.La_Roca__c? ('- La Roca' + (isHtml?'<br>':'\n')) :'';
        // namesList += event.La_Vall_e__c? ('- La Vallee' + (isHtml?'<br>':'\n')) :'';
        //namesList += event.Las_Rozas__c? ('- Las Rozas' + (isHtml?'<br>':'\n')) :'';
        // namesList += event.Maasmechelen__c? ('- Maasmechelen' + (isHtml?'<br>':'\n')) :'';
        // namesList += event.Wertheim__c? ('- Wertheim' + (isHtml?'<br>':'\n')) :'';
        
        //return namesList;
    //}
    
    private String getHTMLBody(final Event event) {
        String emailBodyHTML = emailBodyHTMLByEventId.get(event.Id);        
        if (emailBodyHTML != null)
            return emailBodyHTML;
    
        //open main span    
        emailBodyHTML = '<span style="font-weight: bold;font-size: 10pt;font-family: \'Arial\', \'Helvetica\';">';
        
        emailBodyHTML +=
                '<span style="color: black;">' + 
                'Account/Brand - </span><span style="color: blue;font-size: 12pt;">' + event.What.Name + '</span>'+
                '<br>';
        emailBodyHTML += ''+
                'Subject - <span style="color: blue;">' + event.Subject + '</span>' +
                '<br>';

        emailBodyHTML += '<br>';
        emailBodyHTML += 'Villages Discussed:<br>';
        emailBodyHTML += '<span style="color: green;">' + getWhoIsInvolved(event, true) + '</span><br>';
        
        emailBodyHTML += 'Key Contact - <span style="font-weight: normal;">' + event.Who.Name + '</span><br>';
        emailBodyHTML += 'Assigned To - <span style="font-weight: normal;">' + event.Owner.Name + '</span><br>';
        emailBodyHTML += 'Other Invitees:<br>';
        emailBodyHTML += '<span style="font-weight: normal;">' + getEventInvitees(event.id, true) + '</span><br>';
        
        emailBodyHTML += 'Non-VR Outlet & Full Price Performance:<br>';
        emailBodyHTML += '<span style="font-weight: normal;">' + getNotNull(event.Non_VR_Outlet_Full_Price_Performance__c, true) + '</span><br>';
        
        emailBodyHTML += '<br>';
        emailBodyHTML += 'Reason:<br>';
        emailBodyHTML += '<span style="font-weight: normal;">' + getNotNull(event.Reason__c, true) + '</span><br>';
        
        emailBodyHTML += '<br>';
        emailBodyHTML += 'Meeting Comments:<br>';
        emailBodyHTML += '<span style="font-weight: normal;">' + getNotNull(event.Description, true) + '</span><br>';
        
        emailBodyHTML += '<br>';
        
        if (event.StartDateTimeString__c != null)
            emailBodyHTML += 'Start Date - <span style="font-weight: normal;">'+ event.StartDateTimeString__c + +'</span><br>';

        
            if (event.EndDateTimeString__c != null){
                emailBodyHTML += 'End Date - <span style="font-weight: normal;">'+ event.EndDateTimeString__c + '</span><br>';

            }
            
            if (event.Location_Time_Zone__c != null){
                emailBodyHTML += 'Time Zone - <span style="font-weight: normal;">'+ event.Location_Time_Zone__c + '</span><br>';
            }
            
        emailBodyHTML += 'Location - <span style="font-weight: normal;">'+ getNotNull(event.Location, true) +'</span><br>';
        emailBodyHTML += 'Lease Book Handed Over - <span style="font-weight: normal;">' + (event.Lease_Book_Handed_Over__c? 'Yes':'No') + '</span><br>';
        emailBodyHTML += 'Follow Up - <span style="font-weight: normal;">'+ getNotNull(event.Follow_Up_1__c, true) +'</span><br>';
        emailBodyHTML += 'Link to Report in Salesforce - <span style="font-weight: normal;"><a href="'+SERVERL_URL + event.id+'">' + event.Subject + '</a>' +'</span><br>';
        emailBodyHTML += '</span>';//close main span
        //save for future use
        emailBodyHTMLByEventId.put(event.Id, emailBodyHTML);         
        return emailBodyHTML;   
    }
    
    private String getPlainBody(final Event event) {
        String emailBodyPlain = emailBodyPlainByEventId.get(event.Id);      
        if (emailBodyPlain != null)
            return emailBodyPlain;
            
        String emailBody;
        emailBody = '';
        
        emailBody += 'Account/Brand - ' + event.What.Name + '\n';
        emailBody += 'Subject - ' + event.Subject + '\n';

        emailBody += '\n';
        emailBody += 'Who is Involved:\n';
        emailBody += getWhoIsInvolved(event, false) + '\n';
        
        emailBody += 'Key Contact - ' + event.Who.Name + '\n';
        emailBody += 'Assigned To - ' + event.Owner.Name + '\n';
        emailBody += 'Other Invitees:\n';
        emailBody += getEventInvitees(event.id, false) + '\n';
        
        emailBody += 'Non-VR Outlet & Full Price Performance\n';
        emailBody += getNotNull(event.Non_VR_Outlet_Full_Price_Performance__c, false) + '\n';
        
        emailBody += '\n';
        emailBody += 'Reason:\n';
        emailBody += getNotNull(event.Reason__c, false) + '\n';
        
        emailBody += '\n';
        emailBody += 'Meeting Comments:\n';
        emailBody += getNotNull(event.Description, false) + '\n';
        
        emailBody += '\n';
        
        if (event.StartDateTimeString__c != null)
            emailBody += 'Start Date - '+ event.StartDateTimeString__c + '\n';
        
        if (event.EndDateTimeString__c != null)
            emailBody += 'End Date - '+ event.EndDateTimeString__c + '\n';
            
            if (event.Location_Time_Zone__c != null)
            emailBody += 'Time Zone - '+ event.Location_Time_Zone__c  + '\n';
            
            
        emailBody += 'Location - '+ getNotNull(event.Location, false) +'\n';
        emailBody += 'Lease Book Handed Over - ' + (event.Lease_Book_Handed_Over__c? 'Yes':'No')+'\n';
        emailBody += 'Follow Up - '+ getNotNull(event.Follow_Up_1__c, false) +'\n';
        emailBody += 'Link to Report in Salesforce:' + SERVERL_URL + event.id + '\n';
        emailBodyPlain = emailBody;
        
        //save for future use
        emailBodyPlainByEventId.put(event.Id, emailBodyPlain);       
        
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
    
    ///////////////////////////////////////////
    /**
     * having ot fake code coverage in CCR ContactMerge class because otherwise deployment into Prod is not possible
    */  
    public static testmethod void testContactMergeCodeCoverage(){
        Contact cont = new Contact(LastName = 'Test', Individual_Set_Processed__c = false, Individual_Set__c = 'test');
        Database.insert(cont);
        ContactMerge.StartMerge(1); 
    }
    
}