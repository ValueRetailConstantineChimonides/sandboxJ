/*
13/06/2012  Event.Event_Department__cc now used to categorize event by subject types. Variable & Method name
may still refer to subject or subjectTypess 
*/

public class B2BEventsAlertSender {
        private B2BAlertViewGenerator viewGenerator;
        B2B_Config_Settings__c b2bSettings;
        
        public B2BEventsAlertSender(){
            viewGenerator = new B2BAlertViewGenerator();
            b2bSettings = B2B_Config_Settings__c.getInstance();
        }
        
        private Map<String,Map<String,List<Event>>>   initializeDataViewMap(){
            Map<String,Map<String,List<Event>>> eventsByVillageAndSubject = new Map<String,Map<String,List<Event>>>();
            
            Set<String> subjectTypes = viewGenerator.describeSubjectPickList();
            List<String> villages = viewGenerator.describeEventVillageCategory();
            
            for(String aSubject : subjectTypes ){
                if(eventsByVillageAndSubject.get(aSubject) == null){
                    
                    Map<String,List<Event>> avillageEvents = new Map<String,List<Event>>();
                    for(String aVillage : villages){
                        avillageEvents.put(aVillage, new List<Event>());
                    }
                    eventsByVillageAndSubject.put(aSubject,avillageEvents);
                }
            }
            return eventsByVillageAndSubject; 
        }
        
/*
        public String outHTML {get{
            // 
            String emailAdd = 'mojo@valueretail.com';
            VR_Employee__c testEmp = [Select Email__c,Communications_Subjects_Of_Interest__c ,Communications_Distribution_List__c,First_Name__c ,Communications_Villages_of_Interest__c  from VR_Employee__c where Email__c = :emailAdd];
            Set<VR_Employee__c> testers = new Set<VR_Employee__c>();
            testers.add(testEmp);
            sendReportReminder();
            
            return outHTML;
            
        }set;}
*/
        
        private String buildWeeklyMessageFOrRecipients(B2BEventVisibilityController b2bCalendarCtl,VR_Employee__c anEmployee){
            String sectionHTML = '<SPAN style="font-family: Calibri,Sans-Serif;font-size : 12px;">'; // Start With Opening SPAN
                    sectionHTML += 'Dear '+anEmployee.First_Name__c;
                    sectionHTML += '<BR/><BR/>';
                    sectionHTML += 'Please find below the calendar of the meetings due to take place next week:</BR></BR>';
            sectionHTML+='</SPAN>';

             sectionHTML += '<SPAN style="font-family: Calibri,Sans-Serif;font-size : 12px;">';
                sectionHTML += '<style type="text/css">';
                    sectionHTML += 'table{';
                        sectionHTML += 'font-family: Calibri,Sans-Serif;font-size : 11px;';
                    sectionHTML += '}';
                    sectionHTML += '.datatableHeading{';
                        sectionHTML += 'font-weight : bold;';
                        sectionHTML += 'background-color :  #BFEFFF;';
                    sectionHTML += '}';
                    sectionHTML += '.datatableHeading td {';
                        sectionHTML += 'vertical-align : top;';
                   sectionHTML += '}';
                sectionHTML += '</style>';
                
                sectionHTML += '<TABLE width="95%" style="background-color:#F8F8F8 ;border-collapse:collapse;font-size : 11px;" >';
                    sectionHTML += '<TR>';
                        sectionHTML += '<TD>';
                        sectionHTML += '</TD>';
                        
                        sectionHTML += '<TD>';
                            sectionHTML += 'Monday </BR>';
                            sectionHTML +=DateTime.newInstance(b2bCalendarCtl.mondayDate.year(),b2bCalendarCtl.mondayDate.month(),b2bCalendarCtl.mondayDate.day()).format('dd/MM/yyyy');
                        sectionHTML += '</TD>';
                        
                        sectionHTML += '<TD>';
                            sectionHTML += 'Tuesday</BR>';
                            sectionHTML +=DateTime.newInstance(b2bCalendarCtl.tuesdayDate.year(),b2bCalendarCtl.tuesdayDate.month(),b2bCalendarCtl.tuesdayDate.day()).format('dd/MM/yyyy');
                        sectionHTML += '</TD>';
                        
                        sectionHTML += '<TD>';
                            sectionHTML += 'Wednesday</BR>';
                            sectionHTML +=DateTime.newInstance(b2bCalendarCtl.wednesdayDate.year(),b2bCalendarCtl.wednesdayDate.month(),b2bCalendarCtl.wednesdayDate.day()).format('dd/MM/yyyy');
                        sectionHTML += '</TD>';
                        
                        sectionHTML += '<TD>';
                            sectionHTML += 'Thursday</BR>';
                            sectionHTML +=DateTime.newInstance(b2bCalendarCtl.thursdayDate.year(),b2bCalendarCtl.thursdayDate.month(),b2bCalendarCtl.thursdayDate.day()).format('dd/MM/yyyy');
                        sectionHTML += '</TD>';
                        
                        sectionHTML += '<TD>';
                            sectionHTML += 'Friday</BR>';
                            sectionHTML +=DateTime.newInstance(b2bCalendarCtl.fridayDate.year(),b2bCalendarCtl.fridayDate.month(),b2bCalendarCtl.fridayDate.day()).format('dd/MM/yyyy');
                        sectionHTML += '</TD>';
                        
                        sectionHTML += '<TD>';
                            sectionHTML += 'Saturday</BR>';
                            sectionHTML +=DateTime.newInstance(b2bCalendarCtl.saturdayDate.year(),b2bCalendarCtl.saturdayDate.month(),b2bCalendarCtl.saturdayDate.day()).format('dd/MM/yyyy');
                        sectionHTML += '</TD>';
                        
                        sectionHTML += '<TD>';
                            sectionHTML += 'Sunday</BR>';
                            sectionHTML +=DateTime.newInstance(b2bCalendarCtl.sundayDate.year(),b2bCalendarCtl.sundayDate.month(),b2bCalendarCtl.sundayDate.day()).format('dd/MM/yyyy');
                        sectionHTML += '</TD>';
                    sectionHTML += '</TR>';
                    
                    boolean backgroundToggle = false;
                    String rowBck = '';
                    for(String aVillage : b2bCalendarCtl.getRenderVillageCategorization()){
                        if(backgroundToggle){
                            rowBck = ' style= "background-color: #E8E8E8  ;padding : 2px ; border:3px solid #FFFFFF;" ';
                        }else{
                            rowBck  = ' style="background-color: #F8F8F8 ;padding : 2px; border:3px solid #FFFFFF;"';
                        }
                        

                        backgroundToggle = !backgroundToggle;
                        
                        sectionHTML += '<TR '+rowBck +'>';
                            sectionHTML += '<TD style="vertical-align : top; background-color: #C0C0C0;padding : 2px;text-align:left;border:3px solid #FFFFFF;font-size:11.5px" >';
                                sectionHTML += aVillage;
                            sectionHTML += '</TD>';
                            
                            sectionHTML += '<TD>';
                                // Monday
                                sectionHTML += '<TABLE width="100%">';
                                for(Event anEvent : b2bCalendarCtl.mondayEvents.get(aVillage)){
                                    sectionHTML += '<TR>';
                                        sectionHTML += '<TD>';
                                            sectionHTML += anEvent.What.Name;
                                        sectionHTML += '</TD>';
                                    sectionHTML += '</TR>';
                                }
                                sectionHTML += '</TABLE>';
                            sectionHTML += '</TD>';
                            
                            sectionHTML += '<TD>';
                                // Tuesday
                                sectionHTML += '<TABLE width="100%">';
                                for(Event anEvent : b2bCalendarCtl.tuesdayEvents.get(aVillage)){
                                    sectionHTML += '<TR>';
                                        sectionHTML += '<TD>';
                                            sectionHTML += anEvent.What.Name;
                                        sectionHTML += '</TD>';
                                    sectionHTML += '</TR>';
                                }
                                sectionHTML += '</TABLE>';
                            sectionHTML += '</TD>';
                            
                            sectionHTML += '<TD>';
                                // Wednesday
                                sectionHTML += '<TABLE width="100%">';
                                for(Event anEvent : b2bCalendarCtl.wednesdayEvents.get(aVillage)){
                                    sectionHTML += '<TR>';
                                        sectionHTML += '<TD>';
                                            sectionHTML += anEvent.What.Name;
                                        sectionHTML += '</TD>';
                                    sectionHTML += '</TR>';
                                }
                                sectionHTML += '</TABLE>';
                            sectionHTML += '</TD>';
                            
                            sectionHTML += '<TD>';
                                // Thursday
                                sectionHTML += '<TABLE width="100%">';
                                for(Event anEvent : b2bCalendarCtl.thursdayEvents.get(aVillage)){
                                    sectionHTML += '<TR>';
                                        sectionHTML += '<TD>';
                                            sectionHTML += anEvent.What.Name;
                                        sectionHTML += '</TD>';
                                    sectionHTML += '</TR>';
                                }
                                sectionHTML += '</TABLE>';
                            sectionHTML += '</TD>';
                            
                            sectionHTML += '<TD>';
                                // Friday
                                sectionHTML += '<TABLE width="100%">';
                                for(Event anEvent : b2bCalendarCtl.fridayEvents.get(aVillage)){
                                    sectionHTML += '<TR>';
                                        sectionHTML += '<TD>';
                                            sectionHTML += anEvent.What.Name;
                                        sectionHTML += '</TD>';
                                    sectionHTML += '</TR>';
                                }
                                sectionHTML += '</TABLE>';
                            sectionHTML += '</TD>';
                            
                            sectionHTML += '<TD>';
                                // Saturday
                                sectionHTML += '<TABLE width="100%">';
                                for(Event anEvent : b2bCalendarCtl.saturdayEvents.get(aVillage)){
                                    sectionHTML += '<TR>';
                                        sectionHTML += '<TD>';
                                            sectionHTML += anEvent.What.Name;
                                        sectionHTML += '</TD>';
                                    sectionHTML += '</TR>';
                                }
                                sectionHTML += '</TABLE>';
                            sectionHTML += '</TD>';
                            
                            sectionHTML += '<TD>';
                                // Sunday
                                sectionHTML += '<TABLE width="100%">';
                                for(Event anEvent : b2bCalendarCtl.sundayEvents.get(aVillage)){
                                    sectionHTML += '<TR>';
                                        sectionHTML += '<TD>';
                                            sectionHTML += anEvent.What.Name;
                                        sectionHTML += '</TD>';
                                    sectionHTML += '</TR>';
                                }
                                sectionHTML += '</TABLE>';
                            sectionHTML += '</TD>';
                        sectionHTML += '</TR>';
                    }
                sectionHTML += '</TABLE>';
                
                //sectionHTML += '<BR/><BR/>';
                sectionHTML += getFooterSection_Week();
                
            sectionHTML += '</SPAN>';
            
            return sectionHTML;
        }
        public Boolean sendWeeklyAlerts(Set<VR_Employee__c> B2BAdminContactRecipients){
            if(null == B2BAdminContactRecipients || B2BAdminContactRecipients.size() < 0)return false;
            
            Boolean allSent = false;
            B2BEventVisibilityController b2bCalendarCtl = new B2BEventVisibilityController(System.now().addDays(7));
            
            Map<String,String> messagesByEmail = new Map<String,String>();
            for(VR_Employee__c anEmployee : B2BAdminContactRecipients){
                String msgHTML = buildWeeklyMessageFOrRecipients(b2bCalendarCtl,anEmployee);
                messagesByEmail.put(anEmployee.Email__c , msgHTML);
            }

            Date startOfWeekDate = System.now().addDays(7).date().toStartOfWeek();
            DateTime DateForFormat = DateTime.newInstance(startOfWeekDate.year(),startOfWeekDate.month(),startOfWeekDate.day());
            String alertSubject = 'Meeting Alert – Weekly Calendar – Week Beginning ' + DateForFormat.format('dd MMM yyyy');
            
            List<Messaging.SingleEmailMessage> weeklyMessagesByRecipients = new List<Messaging.SingleEmailMessage>();
             
             // Get User Ids by Email
             Map<String,Id> UserIdsByEmail = getUserIdsByEmailAddresses(B2BAdminContactRecipients);
             
             Integer mailing_tracker_logger = 0;
            for(String recipientEmail : messagesByEmail.keySet()){
                Messaging.SingleEmailMessage weeklyAlertMsg = new Messaging.SingleEmailMessage();
                weeklyAlertMsg.setSubject(alertSubject);
                weeklyAlertMsg.setHtmlBody(messagesByEmail.get(recipientEmail));
                
                if(null != UserIdsByEmail.get(recipientEmail)){
                    weeklyAlertMsg.setTargetObjectId(UserIdsByEmail.get(recipientEmail));
                }else{
                    mailing_tracker_logger++;
                    weeklyAlertMsg.setToAddresses(new String [] {recipientEmail});
                }
                
                weeklyAlertMsg.setReplyTo(b2bSettings.B2B_Alert_Reply_To__c);
                //weeklyAlertMsg.setSenderDisplayName(b2bSettings.B2B_Alert_Display_Name__c);
                weeklyAlertMsg.setOrgWideEmailAddressId(b2bSettings.Alert_Origin_Id__c);
            
                weeklyAlertMsg.setUseSignature(false);
                weeklyAlertMsg.setSaveAsActivity(false);
                
                weeklyMessagesByRecipients.add(weeklyAlertMsg);
            }
            
            if(mailing_tracker_logger > 0){
                B2BAlertViewGenerator.updateMailingLimitTracker(System.now().date(),mailing_tracker_logger);
            }
            
            Messaging.sendEmail(weeklyMessagesByRecipients);
            
            allSent = true;
            
            //outHTML = messagesByEmail.size() > 0  ? messagesByEmail.values().get(0) : null ;
            
            return allSent;
        }
        
        private Map<String,Id> getUserIdsByEmailAddresses(Set<VR_Employee__c> B2BAdminContactRecipients){
            Map<String,Id>  UserIdsByEmail = new Map<String,Id>();
            Set<String> emailAddrForFilter = new Set<String>();
            for(VR_Employee__c vrEmployee : B2BAdminContactRecipients){
                if(null != vrEmployee.Email__c)emailAddrForFilter.add(vrEmployee.Email__c);
            }
            for(User aUser : [SELECT Id, Email FROM  User WHERE Email IN :emailAddrForFilter And IsActive = true]){
                UserIdsByEmail.put(aUser.Email,aUser.Id);
            }
            
            return UserIdsByEmail;
        }
        
        /////////  DAILY ALERT SENDER  ////////////////////
    
            public Boolean sendTommorrowsAlerts(Set<VR_Employee__c> B2BAdminContactRecipients){
                Boolean allSentSuccessful = false;
                Map<Id,Event> allOfTommorrowsEvents = new Map<Id,Event> ();
                // Get all the Events for Tommorrow Or Monday
                String meetingSubject = 'Meeting Alert – Day View: Tomorrow\'s Meetings '+ System.now().addDays(1).format('dd MMM yyyy');
                 Date startOWeekDate = System.today().toStartOfWeek();
                 // Check If today is friday
                if(startOWeekDate.addDays(4) == System.today()){
                    // get Monday's Meeting
                    meetingSubject = 'Meeting Alert – Day View:  Monday\'s Meetings '+ System.now().addDays(3).format('dd MMM yyyy');
                    allOfTommorrowsEvents = viewGenerator.getDayEvents(System.now().addDays(3));
                }else{
                    // get tommorrow's meetings
                    allOfTommorrowsEvents = viewGenerator.getDayEvents(System.now().addDays(1));
                }
                
                // Get All attendes stored by  event ID
                 Map<Id,List<B2BAlertViewGenerator.AttendeeRender>> attendeesByEventId = viewGenerator.findAttendees(allOfTommorrowsEvents.keySet());
    
                //Organise by subject type and village  
                Map<String,Map<String,List<Event>>>  eventsByVillageAndSubject = initializeDataViewMap();
    
                for(Event anEvent : allOfTommorrowsEvents.values()){
                    String eventSubject = anEvent.Event_Department__c;
                    String eventVillage = anEvent.Village_Category__c;
                    
                    // check if the Event is relevent to more than one village
                    if(null != eventVillage && eventVillage.indexOf(';') >= 0 ){
                        String[] villagesOftheEvent = eventVillage.split(';');
                        for(String avillageOption : villagesOftheEvent){
                            if(eventsByVillageAndSubject.get(eventSubject) != null  && null != eventsByVillageAndSubject.get(eventSubject).get(avillageOption)){
                                ( eventsByVillageAndSubject.get(eventSubject).get(avillageOption) ).add(anEvent);
                            }
                        }
                    }else if( (null != eventVillage && eventVillage.trim().length() > 0 ) && eventVillage.indexOf(';') < 0){
                        if(eventsByVillageAndSubject.get(eventSubject) != null  && null != eventsByVillageAndSubject.get(eventSubject).get(eventVillage)){
                            ( eventsByVillageAndSubject.get(eventSubject).get(eventVillage) ).add(anEvent); 
                        }
                    }   
                }
            
                // Build the Email mapped by the contact
                Map<String,Map<String,String>> emailMessageMap =  new Map<String,Map<String,String>>(); 
                for(VR_Employee__c arecipient : B2BAdminContactRecipients){
                    Map<String,String> personalizedMailing = buildPersonalizedEventAlert(arecipient,eventsByVillageAndSubject,attendeesByEventId);
                    
                    emailMessageMap.put(arecipient.Email__c,personalizedMailing);
                    
                }
                
                // Iterate through and send the Emails
                List<Messaging.SingleEmailMessage> readyToGoEmails = new List<Messaging.SingleEmailMessage>();
                
                // Get User Ids by Email
                Map<String,Id> UserIdsByEmail = getUserIdsByEmailAddresses(B2BAdminContactRecipients);
                
                Integer mailing_tracker_logger = 0;
                for( String aRecipientEmail : emailMessageMap.keySet() ){
                    Messaging.SingleEmailMessage aRecipientEmailMsg = new Messaging.SingleEmailMessage();
                    
                    Map<String,String> currentRecipientsPersonalMessage = emailMessageMap.get(aRecipientEmail);
                    
                    aRecipientEmailMsg.setSubject(meetingSubject);
                    // aRecipientEmailMsg.setPlainTextBody(currentRecipientsPersonalMessage.get('TEXT-MSG'));
                    aRecipientEmailMsg.setHtmlBody(currentRecipientsPersonalMessage.get('HTML-MSG'));
                    //outHTML = currentRecipientsPersonalMessage.get('HTML-MSG');
                    
                    if(null != UserIdsByEmail.get(aRecipientEmail)){
                        aRecipientEmailMsg.setTargetObjectId(UserIdsByEmail.get(aRecipientEmail));
                    }else{
                        mailing_tracker_logger++;
                        aRecipientEmailMsg.setToAddresses(new String[] {aRecipientEmail} );
                    }
                    
                     // Specify the address used when the recipients reply to the email.
                    aRecipientEmailMsg.setReplyTo(b2bSettings.B2B_Alert_Reply_To__c);
                    //aRecipientEmailMsg.setSenderDisplayName(b2bSettings.B2B_Alert_Display_Name__c);
                    aRecipientEmailMsg.setOrgWideEmailAddressId(b2bSettings.Alert_Origin_Id__c);

                    aRecipientEmailMsg.setUseSignature(false);
                    aRecipientEmailMsg.setSaveAsActivity(false);
                    
                    readyToGoEmails.add(aRecipientEmailMsg);
                }
                
                if(mailing_tracker_logger > 0){
                    B2BAlertViewGenerator.updateMailingLimitTracker(System.now().date(),mailing_tracker_logger);
                }
    
                Messaging.sendEmail(readyToGoEmails);
                
                allSentSuccessful = true;
                
                return allSentSuccessful; 
            }
            
            private Map<String,String> buildPersonalizedEventAlert(VR_Employee__c recipient,Map<String,Map<String,
                List<Event>>>  eventsByVillageAndSubject , Map<Id,List<B2BAlertViewGenerator.AttendeeRender>> attendeesByEventId){
                
                Date startOWeekDate = System.today().toStartOfWeek();
                 // Check If today is friday
                 String messageLine1 = 'Please find below a list of the meetings due to take place tomorrow:<BR/><BR/>';
                if(startOWeekDate.addDays(4) == System.today()){
                    // get Monday's Meeting
                    messageLine1 = 'Please find below a list of the meetings due to take place next monday.<BR/><BR/>';
                }                   
                Map<String,String> personalizedMailing = new Map<String,String>();
                    
                List<String> subjectsOfInterest= null;
                List<String> villagesOfInterest = null;
                
                // Build Subjects/Departments of Interest
                if(null != recipient.Communications_Subjects_Of_Interest__c && recipient.Communications_Subjects_Of_Interest__c.indexOf(';') >= 0){
                    subjectsOfInterest = recipient.Communications_Subjects_Of_Interest__c.split(';');
                }else if( (null != recipient.Communications_Subjects_Of_Interest__c && recipient.Communications_Subjects_Of_Interest__c.trim().length() > 0 ) 
                    && recipient.Communications_Subjects_Of_Interest__c.indexOf(';') < 0){
                        subjectsOfInterest = new List<String>();
                        subjectsOfInterest.add(recipient.Communications_Subjects_Of_Interest__c);
                }
                
                // Setup Villages of Interest
                if(null != recipient.Communications_Villages_of_Interest__c && recipient.Communications_Villages_of_Interest__c.indexOf(';') >= 0){
                    villagesOfInterest = recipient.Communications_Villages_of_Interest__c.split(';');
                }else if( (null != recipient.Communications_Villages_of_Interest__c && recipient.Communications_Villages_of_Interest__c.trim().length() > 0 ) 
                    && recipient.Communications_Villages_of_Interest__c.indexOf(';') < 0){
                        villagesOfInterest = new List<String>();
                        villagesOfInterest.add(recipient.Communications_Villages_of_Interest__c);
                }
                
                // Iterate through the Preferences
                String htmlMessage = '<SPAN style="font-family: Calibri,Sans-Serif;font-size : 12px;">'; // Start With Opening SPAN
                    htmlMessage += ('Dear '+recipient.First_Name__c+',<BR/><BR/>');
                htmlMessage+='</SPAN>';
                 if(null != subjectsOfInterest && null != villagesOfInterest ){
                    htmlMessage += '<SPAN style="font-family: Calibri,Sans-Serif;font-size : 12px;">'; // Start With Opening SPAN
                        htmlMessage += messageLine1;
                    htmlMessage+='</SPAN>';
                    htmlMessage += getHeaderSection();
                    for(String asubj : subjectsOfInterest){
                        htmlMessage += '<FONT class="subjHeader" >'+asubj+'</FONT><BR/>';
                        htmlMessage += getEventsHTMLForSubjecOfInterest(asubj,eventsByVillageAndSubject.get(asubj),villagesOfInterest,attendeesByEventId);
                    }
                    htmlMessage += getFooterSection();
                 }else{
                    htmlMessage += '<FONT color="red" size="4pt" style="font-weight : bold">';
                        htmlMessage += 'You have been added to the B2B distribution list but your account has not been set up with the appropriate mailing subscriptions. Please reply to this message with your village and department of interest to start receiving the B2B Alerts.';
                    htmlMessage += '</FONT>';
                    
                    htmlMessage += '<BR/><BR/>';
                    
                    htmlMessage  += getRemoveFromeListAndRegards();
                    
                    
                 }

                
                personalizedMailing.put('HTML-MSG',htmlMessage);
                personalizedMailing.put('TEXT-MSG','');
    
                return personalizedMailing;
            }
            
       /////////////////////////////////////////////////////////////////////////////////
        
        private String getEventsHTMLForSubjecOfInterest(String theSubject, Map<String,List<Event>> theEvents,
            List<String> villagesOfInterest, Map<Id,List<B2BAlertViewGenerator.AttendeeRender>> attendeesByEventId){
            boolean backgroundToggle = true;
                String rowBck = '';
                
            Set<Id> addedEvents = new Set<Id>();
            String sectionHTML = '';
            
            sectionHTML += '<TABLE style="font-size : 11px;" width="90%">';
                sectionHTML += '<TR class="datatableHeading">';
                    sectionHTML += '<TD width="20%">';
                        sectionHTML += 'Villages Discussed';
                    sectionHTML += '</TD>';
                    
                    sectionHTML += '<TD width="12%">';
                        sectionHTML += 'Brand';
                    sectionHTML += '</TD>';
                    
                    sectionHTML += '<TD width="18%">';
                        sectionHTML += 'Reason';
                    sectionHTML += '</TD>';
                    
                    sectionHTML += '<TD width="16%">';
                        sectionHTML += 'VR Contact';
                    sectionHTML += '</TD>';
                    
                    sectionHTML += '<TD width="16%">';
                        sectionHTML += 'Brand Contact';
                    sectionHTML += '</TD>';
                    
                    sectionHTML += '<TD width="10%">';
                        sectionHTML += 'Location';
                    sectionHTML += '</TD>';
                    
                    sectionHTML += '<TD width="8%">';
                        sectionHTML += 'Time';
                    sectionHTML += '</TD>';
                sectionHTML += '</TR>';
                
                String currentVillage ='NA';
                
                // To add seperator lines
                
                
                for(String villageName : villagesOfInterest){
                    if(theEvents == null) continue;
                        List<Event> theVillageEvents = theEvents.get(villageName);
                        if(null == theVillageEvents)continue;
                        
                        for(Event theEvent : theVillageEvents){
                            if(backgroundToggle){
                                rowBck = ' style= "font-family: Calibri,Sans-Serif;background-color: #E8E8E8;padding : 2px ; border:3px solid #FFFFFF;font-size : 11px; vertical-align : top;" ';
                            }else{
                                rowBck  = ' style="font-family: Calibri,Sans-Serif;background-color: #F8F8F8 ;padding : 2px; border:3px solid #FFFFFF;font-size : 11px; vertical-align : top;"';
                            }

                            if(addedEvents.contains(theEvent.Id))continue;
                            backgroundToggle = !backgroundToggle;
                            
                            sectionHTML += '<TR '+rowBck +'>';
                                sectionHTML += '<TD >';
                                    String formattedVillagesDiscussed = formatVillagesDiscussed(theEvent.Village_Category__c);
                                    //if(currentVillage != formattedVillagesDiscussed){
                                        currentVillage = formattedVillagesDiscussed;
                                        sectionHTML += formattedVillagesDiscussed; 
                                    //}
                                sectionHTML += '</TD>';
                                
                                sectionHTML += '<TD>';
                                    sectionHTML += theEvent.What.Name;
                                sectionHTML += '</TD>';
                                
                                sectionHTML += '<TD>';
                                    sectionHTML += theEvent.Reason__c;
                                sectionHTML += '</TD>';
                                
                                sectionHTML += '<TD>';
                                    sectionHTML += theEvent.Owner.Name;
                                    sectionHTML += '<BR/>';
                                    if(null != attendeesByEventId.get(theEvent.Id))
                                    sectionHTML += getOtherAttendeesByType(attendeesByEventId.get(theEvent.Id),
                                                        B2BAlertViewGenerator.ATTENDEE_TYPE_VR);
                                sectionHTML += '</TD>';
                                
                                sectionHTML += '<TD>';
                                    sectionHTML += theEvent.Who.Name;
                                    sectionHTML += '<BR/>';
                                    if(null != attendeesByEventId.get(theEvent.Id))
                                    sectionHTML += getOtherAttendeesByType(attendeesByEventId.get(theEvent.Id),
                                                            B2BAlertViewGenerator.ATTENDEE_TYPE_BRAND);
                                sectionHTML += '</TD>';
                                
                                sectionHTML += '<TD>';
                                    sectionHTML += theEvent.Location;
                                sectionHTML += '</TD>';
                                
                                sectionHTML += '<TD>';
                                    if(null != theEvent.StartDateTimeString__c && theEvent.StartDateTimeString__c.length() > 10){
                                        sectionHTML += (theEvent.StartDateTimeString__c.substring(10,theEvent.StartDateTimeString__c.length()) +' '+theEvent.Location_Time_Zone__c);    
                                    }
                                sectionHTML += '</TD>';
                                
                            sectionHTML += '</TR>';
                            
                            addedEvents.add(theEvent.Id);
                        }   
                }
                
            sectionHTML += '</TABLE>';
            sectionHTML += '<BR/><BR/>';
            
            if(addedEvents.isEmpty()){
                sectionHTML = 'There are no meetings for this department. <BR/><BR/>' ;
             }
                
            return sectionHTML;
        }
        
        private String getOtherAttendeesByType(List<B2BAlertViewGenerator.AttendeeRender> attendees,String type){
            Boolean addedRow = false;
            String sectionHTML = '';
            sectionHTML += '<TABLE>';
                for(B2BAlertViewGenerator.AttendeeRender anAttendee : attendees){
                    if(anAttendee.attendeeType == type){
                        sectionHTML += '<TR style="font-family: Calibri,Sans-Serif;font-size : 11px; vertical-align : top;">';
                            sectionHTML += '<TD>';
                                sectionHTML += anAttendee.attendeeName;
                                addedRow = true;
                            sectionHTML += '</TD>';
                        sectionHTML += '</TR>';
                    }
                }
            sectionHTML += '</TABLE>';
            
            if(addedRow == true){
                return sectionHTML;
            }else{
                return '';
            }
        }
        
        private String getHeaderSection(){
            String sectionHTML = '';
            sectionHTML += '<SPAN style="font-family: Calibri,Sans-Serif;font-size : 12px;">'; // Start With Opening SPAN
            
                sectionHTML += '<style type="text/css">';
                    sectionHTML += '.subjHeader{';
                        sectionHTML += 'font-size : 12px; text-decoration : underline;font-weight : bold';
                    sectionHTML += '}';
                    sectionHTML += '.datatableHeading{';
                        sectionHTML += 'font-family: Calibri,Sans-Serif;font-weight : bold;';
                        sectionHTML += 'background-color :  #C0C0C0;';
                        sectionHTML += 'text-align :  center;';
                    sectionHTML += '}';
                    sectionHTML += '.datatableHeading td {';
                        sectionHTML += 'vertical-align : top;';
                   sectionHTML += '}';
                sectionHTML += '</style>';
    
            return sectionHTML;
        }
        
        private String getFooterSection(){
            String sectionHTML = '';
            for(Integer xx=0;xx<3;xx++){
                sectionHTML += '<BR/>';
            }
            sectionHTML += 'Consistent and transparent communication is vital in order to maximise opportunities for every Brand within the group.';
            sectionHTML += '<A style="color: black;text-decoration : none; " HREF = "' +b2bSettings.B2B_Calendar_VRNET_URL__c+'" >';
            sectionHTML += 'Please view the full calendar ';
            sectionHTML += '<font style="text-decoration : underline; "> here </font>';
            sectionHTML += 'on a regular basis to ensure that all opportunities to leverage brand relationships have been explored.';
            sectionHTML += '</A>';
            
            sectionHTML += '<BR/><BR/><BR/>';
            
            sectionHTML += getRemoveFromeListAndRegards();

            sectionHTML += '</SPAN>'; // End With Closing SPAN
            
            return sectionHTML;
        }
        
        private String getFooterSection_Week(){
            String sectionHTML = '';
            for(Integer xx=0;xx<3;xx++){
                sectionHTML += '<BR/>';
            }
            sectionHTML += 'Consistent and transparent communication is vital in order to maximise opportunities for every Brand within the group. ';
            sectionHTML += '<A style="color: black;text-decoration : none; " HREF = "' +b2bSettings.B2B_Calendar_VRNET_URL__c+'" >';
            sectionHTML += 'Please view the interactive  calendar ';
            sectionHTML += '<font style="text-decoration : underline; "> here </font>';
            sectionHTML += 'on a regular basis to ensure that all opportunities to leverage brand relationships have been explored.';
            sectionHTML += '</A>';
            
            sectionHTML += '<BR/><BR/><BR/>';
            
            sectionHTML += getRemoveFromeListAndRegards();

            sectionHTML += '</SPAN>'; // End With Closing SPAN
            
            return sectionHTML;
        }
        
        
        private String getRemoveFromeListAndRegards(){
            String sectionHTML = '<SPAN style="font-family: Calibri,Sans-Serif;font-size : 12px;">'; 

            sectionHTML += '<A style="color: black;text-decoration : none; " HREF = "mailto:' +b2bSettings.B2B_Alert_Reply_To__c+'?subject=Please remove me from the Salesforce - Meeting Alert/Reports Distribution List" >';
            sectionHTML += 'If you would like to be removed from this distribution list please click';
            sectionHTML += '<font style="text-decoration : underline; "> here </font>';
            sectionHTML += '</A>';
            
            sectionHTML += '<BR/><BR/>';
            
            sectionHTML += 'Kind Regards';
            sectionHTML += '</SPAN>';
            
            return sectionHTML;
            
        }

        private String formatVillagesDiscussed(String unFormattedVillagesDiscussed){
            String villagesDiscussed ='';
            if(null != unFormattedVillagesDiscussed && unFormattedVillagesDiscussed.length() > 0){
                    List<String>  villagesDiscussedList = unFormattedVillagesDiscussed.split(';');
                    Integer villageCounter = 0;
                    for(String aVillage : villagesDiscussedList){
                        villageCounter++;
                        villagesDiscussed += aVillage;
                        if(villageCounter < villagesDiscussedList.size()) villagesDiscussed+=', ';
                    }
    
                }
            return  villagesDiscussed;
        }
        
        public void sendReportReminder(){
            Map<Id,Event> dueForReporting = viewGenerator.findDueForReporting();
            Map<String , List<Event>> eventsByEmail = new Map<String , List<Event>>();
            
            List<Event> toUpdateSentReportReminder = new List<Event>();
            
            String alertSubject = 'Meeting Report Reminder' ;
            String serverURL = b2bSettings.SFDC_Target_URL__c;
            String eventHome = '/home/home.jsp';
            
            // Iterate 
            for(Event anEvent  : dueForReporting.values()){
                // An owner anOwnerEmail Email changed to User Id
                //String anOwnerEmail = anEvent.Owner.Email;
                String anOwnerEmail = anEvent.Owner.Id+'';
                
                if(null == anOwnerEmail)continue;
                
                if(null == eventsByEmail.get(anOwnerEmail)){
                    List<Event> theEvents = new List<Event>();
                    theEvents.add(anEvent);
                    eventsByEmail.put(anOwnerEmail , theEvents);
                }else{
                    eventsByEmail.get(anOwnerEmail).add(anEvent);
                }

            }
            
            List<Messaging.SingleEmailMessage> reporrtDueMessages = new List<Messaging.SingleEmailMessage>();
            
            for(String anOwner : eventsByEmail.keySet() ){
                Messaging.SingleEmailMessage aReportMessage = new Messaging.SingleEmailMessage();
                
                List<Event> ownerEvents = eventsByEmail.get(anOwner);
                String firstName = ownerEvents[0].Owner.FirstName;
                
                String theReminderMessage = '<SPAN style="font-family: Calibri,Sans-Serif;font-size : 12px;">'; 
                theReminderMessage += ('Dear '+firstName+',<BR/><BR/>');
                
                theReminderMessage +='Please complete your B2B meeting report for the following event(s) by clicking ';
                theReminderMessage += '<A href="'+(SERVERURL + eventHome)+'" style="color: black;text-decoration : underline; " target="_blank">';
                    theReminderMessage += ' here ';
                theReminderMessage += '</A>';
                
                theReminderMessage += '<BR/><BR/>';

                
                theReminderMessage += '<table width="97%">';
                    theReminderMessage += '<tr style = "text-align : center ;family: Calibri,Sans-Serif;font-weight : bold;background-color :  #C0C0C0; font-size : 11px" >';
                        theReminderMessage += '<td width="18%">';
                            theReminderMessage += 'Brand';
                        theReminderMessage += '</td>';
                        
                        theReminderMessage += '<td width="20%">';
                            theReminderMessage += 'Brand Contact';
                        theReminderMessage += '</td>';
                        
                        theReminderMessage += '<td width="20%" >';
                            theReminderMessage += 'VR Contact';
                        theReminderMessage += '</td>';
                        
                        theReminderMessage += '<td width="25%">';
                            theReminderMessage += 'Reason For Meeting';
                        theReminderMessage += '</td>';
                        
                        /*
                        theReminderMessage += '<td width="25%" >';
                            theReminderMessage += 'Department';
                        theReminderMessage += '</td>';
                        */
                        
                        theReminderMessage += '<td width="17%">';
                            theReminderMessage += 'Start Date';
                        theReminderMessage += '</td>';
                        
                        /*
                        theReminderMessage += '<td width="12.5%">';
                            theReminderMessage += 'End Date';
                        theReminderMessage += '</td>';
                        */
                    theReminderMessage += '</tr>';
                    
                        boolean backgroundToggle = false;
                        String rowBck = '';
                        for( Event oneEvent : ownerEvents){
                            backgroundToggle = !backgroundToggle;
                            if(backgroundToggle){
                                rowBck = ' style= "font-family: Calibri,Sans-Serif;background-color: #E8E8E8;padding : 2px ; border:3px solid #FFFFFF;font-size : 11px; vertical-align : top;" ';
                            }else{
                                rowBck  = ' style="font-family: Calibri,Sans-Serif;background-color: #F8F8F8 ;padding : 2px; border:3px solid #FFFFFF;font-size : 11px; vertical-align : top;"';
                            }
                            
                            
                            theReminderMessage += '<tr '+rowBck +'>';
                                theReminderMessage += '<td>';
                                    theReminderMessage += '<A href="'+(SERVERURL +oneEvent.Id )+'" style="color: black;text-decoration : underline; " target="_blank">';
                                        theReminderMessage += oneEvent.What.Name;
                                    theReminderMessage += '</A>';
                                theReminderMessage += '</td>';
                                
                                theReminderMessage += '<td>';
                                    theReminderMessage += oneEvent.Who.Name;
                                theReminderMessage += '</td>';
                                
                                theReminderMessage += '<td>';
                                    theReminderMessage += oneEvent.Owner.Name;
                                theReminderMessage += '</td>';
                                
                                theReminderMessage += '<td>';
                                    theReminderMessage += oneEvent.Reason__c;
                                theReminderMessage += '</td>';
                        
                                /*
                                theReminderMessage += '<td>';
                                        theReminderMessage += oneEvent.Event_Department__c;
                                theReminderMessage += '</td>';
                                */
                                
                                theReminderMessage += '<td>';
                                    theReminderMessage += oneEvent.StartDateTimeString__c;
                                theReminderMessage += '</td>';
                                
                                /*
                                theReminderMessage += '<td>';
                                    theReminderMessage += oneEvent.EndDateTimeString__c;
                                theReminderMessage += '</td>';
                                */
                            theReminderMessage += '</tr>';
                            
                            oneEvent.Report_Reminder_Sent__c = true;
                            toUpdateSentReportReminder.add(oneEvent);
                        }
                theReminderMessage += '</table>';
                theReminderMessage+='<BR/><BR/>';
                
                theReminderMessage +='Reminder: Please ensure all B2B events are recorded in Salesforce as soon as the meeting is arranged. Following the meeting please complete a meeting report in Salesforce for distribution to the wider business.';
                
                theReminderMessage+='<BR/><BR/>';
                theReminderMessage +='Visibility of communication with brands is vital in order for all teams to leverage on brand relationships across the group. ';
                
                theReminderMessage+='<BR/><BR/>';
                
                theReminderMessage+='Many thanks';
                theReminderMessage+='<BR/><BR/>';
                
                 // theReminderMessage += getFooterSection_Reminder();
                theReminderMessage += '</SPAN>';
                
                aReportMessage.setSubject(alertSubject);
                aReportMessage.setHtmlBody(theReminderMessage);
                //aReportMessage.setToAddresses(new String [] {anOwner,'mojo@valueretail.com'});
                aReportMessage.setTargetObjectId(anOwner);
                
                aReportMessage.setReplyTo(b2bSettings.B2B_Alert_Reply_To__c);
                //weeklyAlertMsg.setSenderDisplayName(b2bSettings.B2B_Alert_Display_Name__c);
                aReportMessage.setOrgWideEmailAddressId(b2bSettings.Alert_Origin_Id__c);
            
                aReportMessage.setUseSignature(false);
                aReportMessage.setSaveAsActivity(false);
                
                reporrtDueMessages.add(aReportMessage);
                
                //outHTML = theReminderMessage;
                
            }
            
            Messaging.sendEmail(reporrtDueMessages);   
            
            Database.update(toUpdateSentReportReminder); 
        }
        
        
/*
        private String getFooterSection_Reminder(){
            String sectionHTML = '';
            for(Integer xx=0;xx<3;xx++){
                sectionHTML += '<BR/>';
            }
            sectionHTML += 'Consistent and transparent communication is vital in order to maximise opportunities for every Brand within the group.';
            sectionHTML += '<A style="color: black;text-decoration : none; " HREF = "' +b2bSettings.B2B_Calendar_VRNET_URL__c+'" >';
            sectionHTML += 'Please view the full calendar ';
            sectionHTML += '<font style="text-decoration : underline; "> here </font>';
            sectionHTML += 'on a regular basis to ensure that all opportunities to leverage brand relationships have been explored.';
            sectionHTML += '</A>';
            
            sectionHTML += '<BR/><BR/><BR/>';
            
            sectionHTML += getRemoveFromeListAndRegards();

            return sectionHTML;
        }
*/
        
        
        public void sendVRFollowUp(){
            Map<Id,Event> dueForNotify =viewGenerator.findForFollowUpNotify();
            String serverURL = b2bSettings.SFDC_Target_URL__c;
            
            List<Event> markAsSent = new List<Event>();
            
            final String DELIM_STR = ',';

            List<Messaging.SingleEmailMessage> reporrtDueMessages = new List<Messaging.SingleEmailMessage>();
            String rowBck =  ' style= "font-family: Calibri,Sans-Serif;background-color: #E8E8E8;padding : 2px ; border:3px solid #FFFFFF;font-size : 11px; vertical-align : top;" ';
            String rowBck2 =  ' style= "font-family: Calibri,Sans-Serif;padding : 2px ; border:3px solid #FFFFFF;font-size : 11px; vertical-align : top;" ';

            for(Event  anEvent : dueForNotify.values()  ){
                String anOwner = anEvent.VR_Employee_Actions__c;
                if(null == anOwner || anOwner.trim().length() ==0 )continue;
                
                Messaging.SingleEmailMessage aReportMessage = new Messaging.SingleEmailMessage();
                Boolean urgencyFlag = (anEvent.Follow_Up_1__c == 'Urgent'? true :false);
                
                List<String> toAddresses = new List<String>();
                //toAddresses.add('mojo@valueretail.com');
                
                // Check If for multple recipients
                if(null != anOwner && anOwner.indexOf(DELIM_STR) > 0 ){
                    String[] emailOwners  = anOwner.split(DELIM_STR);
                    toAddresses.addAll(emailOwners);
                }else if(null != anOwner && anOwner.indexOf(DELIM_STR) < 0 ){
                    toAddresses.add(anOwner);
                }
                
                aReportMessage.setSubject('Action Required – '+anEvent.What.Name + ' '+ anEvent.StartDateTimeString__c);
                
                String theReminderMessage = '<SPAN style="font-family: Calibri,Sans-Serif;font-size : 12px;">'; 
                
                theReminderMessage +='Hi,';
                theReminderMessage +='<BR/>';
                theReminderMessage +='<BR/>';
                
                theReminderMessage +='Please note your ';
                if(urgencyFlag == true)theReminderMessage +='immediate  ';
                theReminderMessage +='attention is required to follow up on the B2B meeting below. The minutes of the meeting, including your required follow up actions are given below. ';
                
                //theReminderMessage += '<A href="#" style="color: black;text-decoration : underline; " target="_blank">';
                    //theReminderMessage += ' here.';
                //theReminderMessage += '</A>';
                
                theReminderMessage +='<BR/><BR/>';
                
                theReminderMessage += '<table width="97%">';
                    theReminderMessage += '<tr style = "text-align : center ;family: Calibri,Sans-Serif;font-weight : bold;background-color :  #C0C0C0; font-size : 11px" >';
                        theReminderMessage += '<td width="18%">';
                            theReminderMessage += 'Brand';
                        theReminderMessage += '</td>';
                        
                        theReminderMessage += '<td width="20%">';
                            theReminderMessage += 'Brand Contact';
                        theReminderMessage += '</td>';
                        
                        theReminderMessage += '<td width="20%" >';
                            theReminderMessage += 'VR Contact';
                        theReminderMessage += '</td>';
                        
                        theReminderMessage += '<td width="25%">';
                            theReminderMessage += 'Reason For Meeting';
                        theReminderMessage += '</td>';
                        
                        theReminderMessage += '<td width="17%">';
                            theReminderMessage += 'Start Date';
                        theReminderMessage += '</td>';
                        
                        /*
                            theReminderMessage += '<td width="7.5%">';
                            theReminderMessage += 'End Date';
                        theReminderMessage += '</td>';
                        */
                    theReminderMessage += '</tr>';

                            theReminderMessage += '<tr '+rowBck +'>';
                                theReminderMessage += '<td>';
                                    theReminderMessage += anEvent.What.Name;
                                theReminderMessage += '</td>';
                        
                                theReminderMessage += '<td>';
                                    theReminderMessage += anEvent.Who.Name;
                                theReminderMessage += '</td>';
                                
                                theReminderMessage += '<td>';
                                    theReminderMessage += anEvent.Owner.Name;
                                theReminderMessage += '</td>';
                                
                                theReminderMessage += '<td>';
                                    theReminderMessage += anEvent.Reason__c;
                                theReminderMessage += '</td>';
                                
                                theReminderMessage += '<td>';
                                    theReminderMessage += anEvent.StartDateTimeString__c;
                                theReminderMessage += '</td>';
                        
                                /*
                                    theReminderMessage += '<td>';
                                    theReminderMessage += anEvent.EndDateTimeString__c;
                                theReminderMessage += '</td>';
                                */
                            theReminderMessage += '</tr>';
                            
                            theReminderMessage += '<tr '+rowBck2 +'>';
                                theReminderMessage += '<td colspan="5">';
                                    theReminderMessage +='</br>';
                                theReminderMessage += '</td>';
                            theReminderMessage += '</tr>';
                            
                            theReminderMessage += '<tr '+rowBck2 +'>';
                                theReminderMessage += '<td colspan="5">';
                                    theReminderMessage +='<b>Meeting Minutes</b>';
                                theReminderMessage += '</td>';
                            theReminderMessage += '</tr>';
                            
                            theReminderMessage += '<tr '+rowBck2 +'>';
                                theReminderMessage += '<td colspan="4">';
                                    theReminderMessage += anEvent.Description;
                                theReminderMessage += '</td>';
                                
                                theReminderMessage += '<td>';
                                theReminderMessage += '</td>';
                                
                                theReminderMessage += '<td>';
                                theReminderMessage += '</td>';
                            theReminderMessage += '</tr>';
                        
                theReminderMessage += '</table>';
                
                theReminderMessage +='<BR/>';
                
                 theReminderMessage += ' Your timely follow up is appreciated.  </BR></BR>';
                 theReminderMessage += ' Salesforce';
                 
                theReminderMessage += '</SPAN>';

                aReportMessage.setHtmlBody(theReminderMessage);
                aReportMessage.setToAddresses(toAddresses);
                //aReportMessage.setToAddresses(new String [] {'mojo@valueretail.com'});
                aReportMessage.setReplyTo(b2bSettings.B2B_Alert_Reply_To__c);
                //weeklyAlertMsg.setSenderDisplayName(b2bSettings.B2B_Alert_Display_Name__c);
                aReportMessage.setOrgWideEmailAddressId(b2bSettings.Alert_Origin_Id_Follow_Up__c);
            
                aReportMessage.setUseSignature(false);
                aReportMessage.setSaveAsActivity(false);
                
                reporrtDueMessages.add(aReportMessage);
                
                //outHTML = theReminderMessage;
                
                anEvent.VR_Employee_Actions_Alert_Sent__c = true;
                markAsSent.add(anEvent);
                
                if(toAddresses.size() > 0){
                    B2BAlertViewGenerator.updateMailingLimitTracker(System.now().date(),toAddresses.size());
                }
            }
            
            Messaging.sendEmail(reporrtDueMessages); 
            Database.update(markAsSent);
        }
    }