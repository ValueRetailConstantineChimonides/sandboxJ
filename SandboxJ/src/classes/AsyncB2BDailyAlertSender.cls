/*
    To  Schedule as a job, execute the following code in Developer console (NB :- Use the first three numbers to specify Seconds, Minutes, and Hour )
        System.Schedule('Daily B2B Alerts','0 30 14 ? * 2-6', new AsyncB2BDailyAlertSender() );
        
*/

global  class AsyncB2BDailyAlertSender implements Database.Batchable<SObject>, Schedulable {
    private static String filterDistributionList ='\'B2B Europe\',\'B2B China\'';

    global void execute(SchedulableContext SC) {
        Database.executeBatch(new AsyncB2BDailyAlertSender());
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        // get All B2B Admin contacts that should recieve events mail
        String soqlStr = 'SELECT Id,First_Name__c, Email__c, Communications_Subjects_Of_Interest__c,Communications_Villages_of_Interest__c'+
                    ' From VR_Employee__c ' +
                    'Where '+
                    ' Communications_Distribution_List__c INCLUDES  (' +filterDistributionList + ') '+
                    ' And '+
                    'Active__c = true' ;
                    

        return Database.getQueryLocator(soqlStr);
    }
    
    global void execute(Database.BatchableContext BC, List<Sobject> scope){
        Set<VR_Employee__c> recipients = new Set<VR_Employee__c>();
        for(Sobject anSobject : scope){
            recipients.add( ((VR_Employee__c)anSobject) );
        }
        
        B2BEventsAlertSender alertSender = new B2BEventsAlertSender();
        if(recipients.size() > 0){
            alertSender.sendTommorrowsAlerts(recipients);
            //call send weekly Alerts   
            sendWeeklyAlertIfNecessary(recipients ,alertSender);
        }
        
        // Send Report Reminder
        alertSender.sendReportReminder();
    }
    
    private void sendWeeklyAlertIfNecessary(Set<VR_Employee__c> recipients 
                                                        ,B2BEventsAlertSender alertSender){
        Date startOWeekDate = System.today().toStartOfWeek();
        if(startOWeekDate.addDays(3) == System.today() || this.inTesting == true){
            // Call send weekly Alert
            alertSender.sendWeeklyAlerts(recipients);
        }
    }
    
    global void finish(Database.BatchableContext BC){
        // new B2BEventsAlertSender().sendVRFollowUp();
        
    }
   //////////////////////////////////////// Unit Test //////////////////////////////////////////
   Boolean inTesting = false;

    static testMethod void  testDailyAlerts(){
        // Create aVR Employee
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
        
        VR_Employee__c testEmp = [Select Email__c,Communications_Subjects_Of_Interest__c ,Communications_Distribution_List__c,First_Name__c ,Communications_Villages_of_Interest__c  from VR_Employee__c where Id  = :insertResult.getId()];
            Set<VR_Employee__c> testers = new Set<VR_Employee__c>();
            testers.add(testEmp);

        // Create Events
        Event event1= new Event(Subject = 'Retail',Type = 'Meeting',Description = 'Event Description',StartDateTime = System.now().addDays(1),
                    EndDateTime = System.now().addDays(1).addMinutes(30),RecordTypeId = EventBeforeSupport.B2B_EVENT_RT,
                    Village_Category__c = 'Bicester;Ingolstadt',Event_Department__c='Retail',VR_Employee_Actions__c= 'mojo@valueretail.com'
                    ,Reason__c = 'Performance Review – Group');
                    
        Event event2= new Event(Subject = 'Leasing/Commercialisation',Type = 'Meeting',Description = 'Event Description',StartDateTime = System.now().addDays(1),
                    EndDateTime = System.now().addDays(1).addMinutes(30),RecordTypeId = EventBeforeSupport.B2B_EVENT_RT,
                    Village_Category__c = 'Bicester',Event_Department__c='Retail',Reason__c = 'Performance Review – Group',VR_Employee_Actions__c= 'mojo@valueretail.com');
            
        Event event3= new Event(Subject = 'Leasing/Commercialisation',Type = 'Meeting',Description = 'Event Description',StartDateTime = System.now().addDays(-2),
                    EndDateTime = System.now().addDays(-2).addMinutes(30),RecordTypeId = EventBeforeSupport.B2B_EVENT_RT,
                    Village_Category__c = 'Bicester',Event_Status__c='Meeting Confirmed' ,Report_Reminder_Sent__c= false,Event_Department__c='Retail'
                    ,VR_Employee_Actions__c= 'mojo@valueretail.com',Reason__c = 'Performance Review – Group');
                    
Event event4= new Event(Subject = 'Leasing/Commercialisation',Type = 'Meeting',Description = 'Event Description',StartDateTime = System.now().addDays(-2),
                    EndDateTime = System.now().addDays(-2).addMinutes(30),RecordTypeId = EventBeforeSupport.B2B_EVENT_RT,
                    Village_Category__c = 'Bicester',Event_Status__c='Meeting completed' ,Report_Reminder_Sent__c= false,Event_Department__c='Retail'
                    ,VR_Employee_Actions__c= 'mojo@valueretail.com',Reason__c = 'Performance Review – Group');
                    
        
        List<Database.SaveResult> saveSuccess = Database.insert(new Event[]{event1,event2,event3,event4});
        List<Id> eventIds = new List<Id>();
        
        for(Database.SaveResult aResult : saveSuccess){
            eventIds.add(aResult.Id);
            
        }
        
        new B2BEventsAlertSender().sendVRFollowUp();
        
        AsyncB2BDailyAlertSender testAsyncInstance = new AsyncB2BDailyAlertSender();
        testAsyncInstance.inTesting = true;
        // test weekly event
        testAsyncInstance.sendWeeklyAlertIfNecessary(testers , new B2BEventsAlertSender());
        
        Database.executeBatch(testAsyncInstance);
        
        testAsyncInstance.inTesting = false;
        
        Test.stopTest();
    }


}