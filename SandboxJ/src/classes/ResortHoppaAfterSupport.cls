/**
 *  @author: Andrey Gavrikov (westbrook)
 *  @date: 2011-09-14 14:25:37 
 *  @description:
 *      Segment 1 movement: on the date of the transfer date, the customer should be moved into Segment 1 on the date of travel.
 *      – Development is required and when we implement it this will only affect the new records. 
 *      Create a trigger – Current Segment filed should be update with “1” on Contact object on the date of the 
 *      transfer date field (“XferDate1” from Shopping Express object). 
 *      If file was provided on the server later than day of transfer then trigger will update “Current Segment” 
 *      field with “1” on Contact record with same date when record will be created on SFDC. When “Shopping Express”
 *      does not create a new record of Contact and transaction will be attached to an existing Contact then also “Current Segment” 
 *      field should be updated to “1” on Contact record. 
 *      In other words: if XferDate1 is <= today() then set:
 *      - Contact.Current_Segment__c = 1
 *      otherwise setup a time based workflow to trigger on XferDate1
 *  
 *  Version History :   
 *      
 */
public class ResortHoppaAfterSupport {
    public static void assignContactCurrentSegment(final List<Resort_Hoppa_Transaction__c> transactions ) {
        final Map<Id, Date> oldestDateByContactId = new Map<Id, Date>();// contact.Id -> oldest XferDate1__c
        
        for (Resort_Hoppa_Transaction__c trans : transactions) {
            Date travelDate = oldestDateByContactId.get(trans.Contact__c);
            if (null == travelDate || travelDate > trans.XferDate1__c) {
                oldestDateByContactId.put(trans.Contact__c, trans.XferDate1__c);
            }
        }
        
        final List<Contact> contactsToUpdate = new List<Contact>();
        Date today = System.today();

        for (Contact cont : [select Id, Current_Segment__c, TAG_Travel_Date__c from Contact 
                            where Id in: oldestDateByContactId.keySet()
                                and Current_Segment__c <> 1]) {
            Date travelDate = oldestDateByContactId.get(cont.Id);
            cont.TAG_Travel_Date__c = travelDate;
            if (travelDate <= today) {
                cont.Current_Segment__c = 1;//travel date is in the past, mark Current_Segment__c = 1
            }
            contactsToUpdate.add(cont);
        }
        if (!contactsToUpdate.isEmpty()) {
            Database.update(contactsToUpdate);
        }
    }


    //////////////// unit tests ////////////////////////
    private static final Id DEFAULT_MEMBERS_B2C_CONTACT_RT = CampaignAfterSupport.DEFAULT_MEMBERS_B2C_CONTACT_RT;
    /**
     * 
     */
    static testMethod void testAssignContactCurrentSegment () {

        final Account acc = new Account (Name='acc',RecordTypeId=EventBeforeSupport.B2B_ACCOUNT_RT);
        Database.insert(acc);

        final Contact contact1 = new Contact (LastName = 'Test1', AccountId = acc.Id, RecordTypeId = DEFAULT_MEMBERS_B2C_CONTACT_RT, Current_Segment__c = null, Last_Redemption_Date__c = null, Current_Segment_Campaign__c = null);
        final Contact contact2 = new Contact (LastName = 'Test2', AccountId = acc.Id, RecordTypeId = DEFAULT_MEMBERS_B2C_CONTACT_RT, Current_Segment__c = null, Last_Redemption_Date__c = null, Current_Segment_Campaign__c = null);
        final Contact contact3 = new Contact (LastName = 'Test3', AccountId = acc.Id, RecordTypeId = DEFAULT_MEMBERS_B2C_CONTACT_RT, Current_Segment__c = null, Last_Redemption_Date__c = null, Current_Segment_Campaign__c = null);
        Database.insert(new Contact[] {contact1, contact2, contact3});

        Resort_Hoppa_Transaction__c trans1_Past_10 = new Resort_Hoppa_Transaction__c(Contact__c = contact1.Id, XferDate1__c = (System.today() -10));
        Resort_Hoppa_Transaction__c trans1_Past_5 = new Resort_Hoppa_Transaction__c(Contact__c = contact1.Id, XferDate1__c = (System.today() -5));

        Resort_Hoppa_Transaction__c trans2_Today = new Resort_Hoppa_Transaction__c(Contact__c = contact2.Id, XferDate1__c = System.today());
        Resort_Hoppa_Transaction__c trans2_Future = new Resort_Hoppa_Transaction__c(Contact__c = contact2.Id, XferDate1__c = (System.today() + 10));

        Resort_Hoppa_Transaction__c trans3_Future = new Resort_Hoppa_Transaction__c(Contact__c = contact3.Id, XferDate1__c = (System.today() + 10));

        Test.startTest();
        Database.insert(new Resort_Hoppa_Transaction__c[] {trans1_Past_10, trans1_Past_5, trans2_Today, trans2_Future, trans3_Future});

        //for Contact 1 expect Current_Segment__c = 1 and TAG_Travel_Date__c = trans1_Past_10.XferDate1__c
        Contact cont = [select Id, Current_Segment__c, TAG_Travel_Date__c from Contact where Id =: contact1.Id];
        System.assertEquals(1, cont.Current_Segment__c);
        System.assertEquals(trans1_Past_10.XferDate1__c, cont.TAG_Travel_Date__c);
        

        //for Contact 2 expect Current_Segment__c = 1 and TAG_Travel_Date__c = trans2_Today.XferDate1__c
        cont = [select Id, Current_Segment__c, TAG_Travel_Date__c from Contact where Id =: contact2.Id];
        System.assertEquals(1, cont.Current_Segment__c);
        System.assertEquals(trans2_Today.XferDate1__c, cont.TAG_Travel_Date__c);

        //for Contact 3 expect Current_Segment__c = null and TAG_Travel_Date__c = trans3_Future.XferDate1__c
        cont = [select Id, Current_Segment__c, TAG_Travel_Date__c from Contact where Id =: contact3.Id];
        System.assertEquals(null, cont.Current_Segment__c);
        System.assertEquals(trans3_Future.XferDate1__c, cont.TAG_Travel_Date__c);

    }
    
}