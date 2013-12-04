/**
    Batch activation of "B2B Contact Report" alert delivery
    Allows scheduling and batch processing of B2B_Alert_Recipient__c records
    NOTE: Batch SIZE must be =1 otherwise email delivery will hit governor limit 
    
    Manual run: Database.executeBatch(new B2BAlertActivator(), 1);
    
    Manual Schedule
    //ex: at 06:55am every day
    //System.schedule('B2BAlertActivator Job', '0 55 6 ? * *', new B2BAlertActivator());
    //to run every hour replace hour with "start slash one"
    
*/
global without sharing class B2BAlertActivator implements Database.Batchable<SObject>, Schedulable {


    /************** SchedulableContext ************/
    global void execute(SchedulableContext SC) {
        //start batch process
        final Integer BATCH_SIZE = 1;
        Database.executeBatch(new B2BAlertActivator(), BATCH_SIZE);
    }
    
    /************** Batchable ************/
    global Database.QueryLocator start(Database.BatchableContext BC){
        final String soqlStr = 'select id, Event_Id__c from B2B_Alert_Recipient__c where Sent__c = null order by Event_Id__c  ';
        return Database.getQueryLocator(soqlStr);
    }
    global void execute(Database.BatchableContext BC, List<Sobject> scope){
        System.debug('### execute B2BAlertActivator ');
        processBatch(scope);
    }
    global void finish(Database.BatchableContext BC){
        System.debug('### finish B2BAlertActivator ');
        System.debug('### Send Follow up action Alert  ');
        // Send Notification to VR Employee
        new B2BEventsAlertSender().sendVRFollowUp();
        
        System.debug('### FINISHED B2BAlertActivator ');
     
     

    }
    
    /**
        this method assumes that scope size is always =1
        otherwise semail delivery may fail due to governor limits
    */
    private void processBatch(List<Sobject> scope) {
        if (scope.size() >0) {
            final List<B2B_Alert_Recipient__c> recipients = new List<B2B_Alert_Recipient__c>();
            for (SObject o : scope) {
                B2B_Alert_Recipient__c recipient = (B2B_Alert_Recipient__c)o;
                recipient.Ready_To_Dispatch__c = true;
                recipients.add(recipient);
            }
            Database.update(recipients);
        }
    }
    
    ////////////////////// Tests ////////////////////////
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
        Set<String> normalIds = B2BContactReportAlertGenerator.normaliseIds(new Set<Id>{event.Id, event2.id}); 
        
        
        B2BAlertActivator job = new B2BAlertActivator(); 
        B2B_Alert_Recipient__c[] recipients = [select Id, Event_Id__c from B2B_Alert_Recipient__c where Event_Id__c in : normalIds];
        System.debug(' ===========++++++++ '+recipients);                     
                     
         System.assert(recipients.size() >0, 'Expected more than 0 recipient holders, actual =' + recipients.size());                                    
        //make sure we do not issue too many sendEmail calls, remove all but 1
        List<B2B_Alert_Recipient__c> batchRecipients = new B2B_Alert_Recipient__c[]{recipients[0]};
        
        System.debug(' ===========++++++++ '+batchRecipients);
        job.processBatch(batchRecipients);

        recipients.remove(0);
        Database.delete(recipients);
 
        Test.stopTest();
    }
    
    /**
        this is just code coverage, no logic
    */
    private static testMethod void codeCoverage() {
        Database.executeBatch(new B2BAlertActivator(), 1);
        B2BAlertActivator job = new B2BAlertActivator();
        job.execute(null);//schedulable
        job.start(null);
        job.execute(null, new List<Event>());
        job.finish(null);       
    }   
}