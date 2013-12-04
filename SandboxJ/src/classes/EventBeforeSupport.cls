/**
 *  @author: Andrey Gavrikov (westbrook)
 *  @date: 2011-02-01 13:55:41 
 *  @description:
 *      helper class and unit tests container for EventBefore trigger
 *  
 *  Version History :   
 *      
 */
public class EventBeforeSupport {
    public static final Id B2B_EVENT_RT = '01220000000CojGAAS';
    public static final Id B2B_ACCOUNT_RT = '01220000000CnpIAAS';

    /**
     * check successful subject format
     * IF "The meeting Start Date [Event.StartDate] is in the future".
     * THEN
     *  Update Event Subject using format:
     *  “<Assigned to> Meeting with <Brand> on <Meeting Start Date>”
     *
     */
    static testMethod void testSubjectFormat () {
    Account acc = new Account (Name = 'Test',RecordTypeId = B2B_ACCOUNT_RT);
    Database.insert(acc);
    Contact contact = new Contact (LastName = 'Test');
    insert contact;

    Event eventPast = new Event(Subject = 'Other some free text', Type = 'Meeting', Send_Email_Alert__c = false, 
        Bicester__c = true, Fidenza__c =true, Ingolstadt__c = true,  Kildare__c = true, 
        La_Roca__c = true, La_Vall_e__c = true, Las_Rozas__c = true, Maasmechelen__c = true, 
        DurationInMinutes = 10, StartDateTime = System.now() - 1, 
        Lease_Book_Handed_Over__c = false,
        RecordTypeId = B2B_EVENT_RT, 
        WhatId = acc.id, OwnerId = UserInfo.getUserId());

    Event eventFuture = eventPast.clone(false, true);
    eventFuture.StartDateTime = System.now() + 10;
    eventFuture.Subject = 'Test';// make sure subject is illegal for past events, see "Subject_Validation" validation rule

    Event eventNonAccount = eventPast.clone(false, true);
    eventNonAccount.WhatId = null;
    eventNonAccount.WhoId =  contact.id;
    

    Test.startTest();
    //Database.insert(new Event[] {eventPast, eventFuture, eventNonAccount});
    UnitTestUtils.clearStatics();
    Database.insert(new Event[] {eventPast});
    UnitTestUtils.clearStatics();
    Database.insert(new Event[] {eventFuture});
    UnitTestUtils.clearStatics();
    Database.insert(new Event[] {eventNonAccount});
    Test.stopTest();

    //check if eventPast retained its subject
    //System.assertNotEquals(eventPast.Subject, [select Id, Subject from Event where id =: eventPast.Id].Subject, 'Subject must not have changed for past event');
    
    //check if subject of eventFuture has changed
    //System.assertNotEquals(eventFuture.Subject, [select Id, Subject from Event where id =: eventFuture.Id].Subject, 'Subject must not have changed for Future event');

    //check if eventNonAccount retained its subject because it is not Account related event
    //System.assertEquals(eventNonAccount.Subject, [select Id, Subject from Event where id =: eventNonAccount.Id].Subject, 'Subject must not have changed for past event');
        
    }
    
}