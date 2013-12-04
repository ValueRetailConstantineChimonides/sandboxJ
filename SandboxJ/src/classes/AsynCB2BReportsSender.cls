/*
    To Schedule 
    
     System.Schedule('B2B Reports Sender','0 5 4,7 * * ?', new AsynCB2BReportsSender() );
    
*/

global without sharing class AsynCB2BReportsSender 
                    implements Database.Batchable<SObject>, Schedulable {

        private final Integer BATCH_SIZE = 5;

        global void execute(SchedulableContext SC) {
            Database.executeBatch(new AsynCB2BReportsSender(),BATCH_SIZE);
        }
        
        global Database.QueryLocator start(Database.BatchableContext BC){
            final String soqlStr = 'select id, Event_Id__c,Recipients__c,Sent__c , Ready_To_Dispatch__c from B2B_Alert_Recipient__c where Sent__c = null order by Event_Id__c  ';
            return Database.getQueryLocator(soqlStr);
        }
        
        global void execute(Database.BatchableContext BC, List<Sobject> scope){
            if(null != scope && scope.size() >0 ){
                final List<B2B_Alert_Recipient__c> recipients = (List<B2B_Alert_Recipient__c>)scope;
                
                processBatchForSending(recipients);
            }
        }
        
        global void finish(Database.BatchableContext BC){
            System.debug('### finishing AsynCB2BReportsSender ## ');
            new B2BEventsAlertSender().sendVRFollowUp();
        }
        
        private void processBatchForSending(List<B2B_Alert_Recipient__c> recipients) {
                // Mark for deletion
                for(B2B_Alert_Recipient__c aRec: recipients){
                    aRec.Ready_To_Dispatch__c = true;
                }
                Database.update(recipients);

         }
            
            // Added to extend code Coverage so as to enable and disable onEventChange_Updated & onEventChange triggers
            private static testMethod void testB2BRecipientsGenerator() {
                Test.startTest();
                
                VR_Employee__c anEmployee = new VR_Employee__c();
                anEmployee.Name = 'Test Name';
                anEmployee.First_Name__c ='Test';
                anEmployee.Last_Name__c = 'Name';
                anEmployee.Active__c = true;
                anEmployee.Communications_Distribution_List__c= 'B2B Europe';
                anEmployee.Communications_Subjects_Of_Interest__c = 'Retail;Leasing/Commercialisation';
                anEmployee.Communications_Villages_of_Interest__c = 'Bicester';
                anEmployee.Email__c = 'testing@valueretail.com';
            
                Database.Saveresult insertResult = Database.insert(anEmployee);
            
                //prepare to run in TEST mode
                B2BContactReportAlertGenerator.TEST_MODE = true;
        
                Event event = new Event(Subject = 'Retail', Type = 'Meeting', Send_Email_Alert__c = true, 
                                    Bicester__c = true, Bispingen__c = true, Fidenza__c =true, Ingolstadt__c = true,  Kildare__c = true, La_Roca__c = true, La_Vall_e__c = true, Las_Rozas__c = true, Maasmechelen__c = true, 
                                    DurationInMinutes = 10, ActivityDateTime = System.now(), Description='Test Description',Village_Category__c = 'Bicester',h_Additional_Email_Recipients__c = 'mojo@valueretail.com');
                insert event;//trigger shall be initiated here
            
                //test deletion of old Brand_Activity__c objects
                DateTime startAt = System.now();
                DateTime endAt = startAt.addMinutes(10);
            
                Event event2 = new Event(Subject = 'Site Visit', Type = 'Meeting', Send_Email_Alert__c = true, Bicester__c = true, Fidenza__c =true, 
                                DurationInMinutes = 10, Description = 'Event Description',
                                ActivityDateTime = startAt,StartDateTime = startAt, EndDateTime = endAt,
                                RecordTypeId = EventBeforeSupport.B2B_EVENT_RT,Village_Category__c = 'Bicester');
                insert event2;
                
                B2BContactReportAlertGenerator generator = new B2BContactReportAlertGenerator();
                
                Set<Id> testEventIds = new Set<Id>();testEventIds.add(event.Id);testEventIds.add(event2.Id);
                
                generator.generateRecipients(new Event[]{event,event2});
                B2BContactReportAlertGenerator.cleanOldRecipients(testEventIds,0);
                
                new B2BContactReportAlertGenerator_updated().generateRecipients(new Event[]{event,event2});
                B2BContactReportAlertGenerator.cleanOldRecipients(testEventIds,0);
                
                Test.stopTest();
            
            }
            
            private static testMethod void testLogic() {
                Test.startTest();
                
                VR_Employee__c anEmployee = new VR_Employee__c();
                anEmployee.Name = 'Test Name';
                anEmployee.First_Name__c ='Test';
                anEmployee.Last_Name__c = 'Name';
                anEmployee.Active__c = true;
                anEmployee.Communications_Distribution_List__c= 'B2B Europe';
                anEmployee.Communications_Subjects_Of_Interest__c = 'Retail;Leasing/Commercialisation';
                anEmployee.Communications_Villages_of_Interest__c = 'Bicester';
                anEmployee.Email__c = 'testing@valueretail.com';
            
                Database.Saveresult insertResult = Database.insert(anEmployee);
            
                //prepare to run in TEST mode
                B2BContactReportAlertGenerator.TEST_MODE = true;
        
                Event event = new Event(Subject = 'Retail', Type = 'Meeting', Send_Email_Alert__c = true, 
                                    Bicester__c = true, Bispingen__c = true, Fidenza__c =true, Ingolstadt__c = true,  Kildare__c = true, La_Roca__c = true, La_Vall_e__c = true, Las_Rozas__c = true, Maasmechelen__c = true, 
                                    DurationInMinutes = 10, ActivityDateTime = System.now(), Description='Test Description',Village_Category__c = 'Bicester',h_Additional_Email_Recipients__c = 'mojo@valueretail.com');
                insert event;//trigger shall be initiated here
            
                //test deletion of old Brand_Activity__c objects
                DateTime startAt = System.now();
                DateTime endAt = startAt.addMinutes(10);
            
                Event event2 = new Event(Subject = 'Site Visit', Type = 'Meeting', Send_Email_Alert__c = true, Bicester__c = true, Fidenza__c =true, 
                                DurationInMinutes = 10, Description = 'Event Description',
                                ActivityDateTime = startAt,StartDateTime = startAt, EndDateTime = endAt,
                                RecordTypeId = EventBeforeSupport.B2B_EVENT_RT,Village_Category__c = 'Bicester');
                insert event2;
                System.debug(' ===========++++++++ '+event2.Id);
                //et<String> normalIds = new Set<String>();normalIds.add(event.Id);normalIds.add(event2.id);
                Set<String> normalIds = B2BContactReportAlertGenerator.normaliseIds(new Set<Id>{event.Id, event2.id}); 

                AsynCB2BReportsSender job = new AsynCB2BReportsSender(); 
                B2B_Alert_Recipient__c[] recipients = [select Id, Event_Id__c, Recipients__c from B2B_Alert_Recipient__c where Event_Id__c in : normalIds];
                System.debug(' ===========++++++++ '+recipients);                     
                         
                System.assert(recipients.size() >0, 'Expected more than 0 recipient holders, actual =' + recipients.size());                                    
                //make sure we do not issue too many sendEmail calls, remove all but 1
                List<B2B_Alert_Recipient__c> batchRecipients = new B2B_Alert_Recipient__c[]{recipients[0]};
                
                //  Call Senders before using the Job
                B2BContactReportAlertSender sender = new B2BContactReportAlertSender();
                sender.sendAlerts(batchRecipients);
        
                AsynCB2BReportsSender.B2BReportsSender sender2 = new AsynCB2BReportsSender.B2BReportsSender();
                sender2.sendAlerts(batchRecipients);
                
                System.debug(' ===========++++++++ '+batchRecipients);
                
                job.processBatchForSending(batchRecipients);

                recipients.remove(0);

                Test.stopTest();
            }
            
            private static testMethod void codeCoverage() {
                Database.executeBatch(new AsynCB2BReportsSender(), 1);
                AsynCB2BReportsSender job = new AsynCB2BReportsSender();
                job.execute(null);//schedulable
                job.start(null);
                job.execute(null, new List<Event>());
                job.finish(null);       
    }   
    
        
        /////////////////////    Sender Class  ///////////////////////
        public class B2BReportsSender{
        
            private String SERVERL_URL = 'https://emea.salesforce.com/';

            private Map<Id, String> emailBodyHTMLByEventId = new Map<Id, String>();
            private Map<Id, String> emailBodyPlainByEventId = new Map<Id, String>();
            
            public void sendAlerts(B2B_Alert_Recipient__c[] recipientList) {
                final Map<Id, Event> eventsMap = loadEvents(recipientList);
                
                if (!eventsMap.isEmpty()) {
                    final List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();

                    for (B2B_Alert_Recipient__c recipientsObj : recipientList) {
                        Event eventRecord = eventsMap.get(recipientsObj.Event_Id__c);
                        if (null == eventRecord) {
                            continue;
                        }

                        String[] toAddresses = recipientsObj.Recipients__c.split(',');

                        ////////  ***** Organize for Send ****** ////////
                        for (String toId : toAddresses) {
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        
                            if (toId.contains('@')) {
                                //this is not ID but email address
                                mail.setToAddresses(new String[] {toId} );
                            }else {
                                mail.setTargetObjectId(toId);
                            }
                            
                            // Email Content
                            mail.setReplyTo(System.label.B2B_Alert_ReplyTo_Address);
                            mail.setSenderDisplayName(System.label.B2B_Alert_Historical_Sender_Name);
                            mail.setSubject(eventRecord.What.Name + ' - ' + eventRecord.Subject + ' - B2B Alert');
                            mail.setBccSender(false);
                            mail.setUseSignature(false);

                            mail.setPlainTextBody(getPlainBody(eventRecord));
                    
                            mail.setHtmlBody(getHTMLBody(eventRecord));
                        
                            mail.setSaveAsActivity(false);
                            
                            emailMessages.add(mail);
                        }   
                    }
                    if(!emailMessages.isEmpty()){
                        Messaging.sendEmail(emailMessages);
                    }
                }
            }
            
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
            
            public Map<Id, Event> loadEvents (B2B_Alert_Recipient__c[] recipients) {
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
                                from Event where id in :eventIds  And IsChild = false ]);
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
        public String getNotNull(String value, String defaultVal, Boolean isHtml) {
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
            
            private String getEventInvitees (ID eventId, Boolean isHtml) {
                String namesList = '';
                for ( EventAttendee eventAttendee: [Select AttendeeId, Attendee.Name From EventAttendee where EventId =: eventId]) {
                    namesList += '- ' + (isUser(eventAttendee.AttendeeId)? 'VR' : 'Brand') + ' - ' + eventAttendee.Attendee.Name + (isHtml?'<br>':'\n');
                }
                return namesList;
            }
            
            private  boolean isUser(ID attendeeId) {
                String attId = attendeeId;
                return attId.startsWith('005');
            }
            
        }
            //////////////////// End Of Sender Class //////////////////
            
    }