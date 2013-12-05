public class OnEventChangeTests {
    static testMethod void testActualHandoverDate() {
        Contact contact = new Contact (LastName = 'Test');
        insert contact;
        
        Event event = new Event(Subject = 'Retail', Type = 'Meeting', Send_Email_Alert__c = false, 
                                Bicester__c = true, Fidenza__c =true, Ingolstadt__c = true,  Kildare__c = true, 
                                La_Roca__c = true, La_Vall_e__c = true, Las_Rozas__c = true, Maasmechelen__c = true, 
                                DurationInMinutes = 10, ActivityDateTime = System.now(), 
                                Lease_Book_Handed_Over__c = false, WhoId = contact.id);
        insert event;//trigger shall be initiated here
        //check if contac's Actual_Handover_Date__c is still null
        contact = [select id, Actual_Handover_Date__c from Contact where id =: event.WhoId];
        System.assert(contact.Actual_Handover_Date__c == null, 'Expected empty Actual_Handover_Date__c');
        
        //fill in Actual_Handover_Date__c
        event.Lease_Book_Handed_Over__c = true;
        event.Shopfit_Book_Handed_Over__c = true;
        
        update event;
        contact = [select id, Actual_Handover_Date__c from Contact where id =: event.WhoId];
        System.assert(contact.Actual_Handover_Date__c != null, 'Expected not empty Actual_Handover_Date__c');
        
        
    }
    

}