global class B2BContactReportAlertGeneratorTests {
    private static Integer SUBJECT_INDEX = 0;  
    public static testMethod void testRunProcess() {
        try {
            //prepare to run in TEST mode
            B2BContactReportAlertGenerator.TEST_MODE = true;
        
            Event event = new Event(Subject = 'Retail', Type = 'Meeting', Send_Email_Alert__c = true, 
                                    Bicester__c = true, Bispingen__c = true, Fidenza__c =true, Ingolstadt__c = true,  Kildare__c = true, La_Roca__c = true, La_Vall_e__c = true, Las_Rozas__c = true, Maasmechelen__c = true, 
                                    DurationInMinutes = 10, ActivityDateTime = System.now(),Description = 'Test Describe');
            insert event;//trigger shall be initiated here
            
            //test deletion of old Brand_Activity__c objects
            Event event2 = new Event(Subject = 'Retail', Type = 'Meeting', Send_Email_Alert__c = true, Bicester__c = true, Fidenza__c =true, 
                                DurationInMinutes = 10, ActivityDateTime = System.now(),Description = 'Test 2 Describe');
            insert event2;
            
        
            //make sure there are only 2 Brand_Activity__c
            
            System.debug('===event.id=' + get15DigitsId(event.id));
            B2B_Alert_Recipient__c[] recipients = [select id from B2B_Alert_Recipient__c where Event_Id__c =: get15DigitsId(event.id) or Event_Id__c =: get15DigitsId(event2.id)];
            //System.assert(recipients.size() > 1, 'Number of created B2B_Alert_Recipient__c objects is not what we expected.' + recipients.size());
            for (B2B_Alert_Recipient__c recipient: recipients) {
                recipient.Ready_To_Dispatch__c = true;
                update recipient;
                break;//test only 1
            }
            //clear Send_Email_Alert__c
            event.Send_Email_Alert__c = false;
            update event;
            event2.Send_Email_Alert__c = false;
            update event2;
            //make sure recipients have been deleted
            Integer count = [select count() from B2B_Alert_Recipient__c where Event_Id__c =: get15DigitsId(event.id) or Event_Id__c =: get15DigitsId(event2.id)];
            System.assert(count == 0, 'Number of created B2B_Alert_Recipient__c objects is not what we expected.' + count);
            
            
        } finally {
            B2BContactReportAlertGenerator.TEST_MODE = false;
        }
    }
    private static String get15DigitsId(String eventId) {
        return eventId.substring(0,15);
    }
    /*
    public static testMethod void testMatcher() {
        Event event = [select Description from Event where id= '00UT00000015oTW'];
        System.debug('=== Original: ' + event.Description);
        System.debug('============================================================================================ ');
        System.debug('=== Replaced HTML: ' + B2BContactReportAlertSender.getNotNull(event.Description, null, true));
    }
    */
}