@isTest
private class BrandTransactionTests {
    
    private static final Id DEFAULT_MEMBERS_B2C_CONTACT_RT = CampaignAfterSupport.DEFAULT_MEMBERS_B2C_CONTACT_RT;
    private static final Id DEFAULT_MEMBERS_B2C_CAMPAIGN_RT = CampaignAfterSupport.DEFAULT_MEMBERS_B2C_CAMPAIGN_RT;
    private static final String DEFAULT_MEMBERS_CAMPAIGN_TYPE = CampaignAfterSupport.DEFAULT_MEMBERS_CAMPAIGN_TYPE;
    
     
    /**
        BrandTransactionAfter
        Count of unique contacts with transactions against a campaign e.g. 10 transactions against 
        a campaign across 3 contacts therefore we need 3 to display against the campaign.
    */
    static testMethod void testBrandTransactionAfter() {
        final Campaign camp = new Campaign(Name='test', RecordTypeId = DEFAULT_MEMBERS_B2C_CAMPAIGN_RT, 
                                            Type = DEFAULT_MEMBERS_CAMPAIGN_TYPE, Active_Redemption_Segments__c = true);
        final Campaign camp2 = new Campaign(Name='test2', RecordTypeId = DEFAULT_MEMBERS_B2C_CAMPAIGN_RT, 
                                            Type = DEFAULT_MEMBERS_CAMPAIGN_TYPE, Active_Redemption_Segments__c = true);

        Database.insert(new Campaign[] {camp, camp2});
        
        final Account acc = new Account (Name='acc',RecordTypeId=EventBeforeSupport.B2B_ACCOUNT_RT);
        Database.insert(acc);
        final Contact contact1 = new Contact (LastName = 'Test1', AccountId = acc.Id, RecordTypeId = DEFAULT_MEMBERS_B2C_CONTACT_RT, Current_Segment__c = null, Last_Redemption_Date__c = null, Current_Segment_Campaign__c = null);
        final Contact contact2 = new Contact (LastName = 'Test2', AccountId = acc.Id, RecordTypeId = DEFAULT_MEMBERS_B2C_CONTACT_RT, Current_Segment__c = null, Last_Redemption_Date__c = null, Current_Segment_Campaign__c = null);
        final Contact contact3NoTrans = new Contact (LastName = 'Test3', AccountId = acc.Id, RecordTypeId = DEFAULT_MEMBERS_B2C_CONTACT_RT, Current_Segment__c = null, Last_Redemption_Date__c = null, Current_Segment_Campaign__c = null);
        final Contact contact4OfCamp2 = new Contact (LastName = 'Test4', AccountId = acc.Id, RecordTypeId = DEFAULT_MEMBERS_B2C_CONTACT_RT, Current_Segment__c = null, Last_Redemption_Date__c = null, Current_Segment_Campaign__c = null);
        List<Contact> contacts = new Contact[] {contact1, contact2, contact3NoTrans, contact4OfCamp2};
        Database.insert(contacts);
        
        List<CampaignMember> members = new List<CampaignMember>();
        Set<Id> contactIds = new Set<Id>();
        for (Contact cont : contacts) {
            CampaignMember cm = new CampaignMember();
            cm.ContactId = cont.Id;
            if (cont.Id == contact4OfCamp2.Id) {
                cm.CampaignId = camp2.Id;//camp2
            } else {
                cm.CampaignId = camp.Id;//camp
            }
            
            contactIds.add(cont.Id);
            members.add(cm);
        }
        Database.insert(members);
        Map<Id, Boolean> buyerByMemberId = new Map<Id, Boolean>();
        Map<Id, Decimal> amountByMemberId = new Map<Id, Decimal>();
        Map<Id, Integer> countByMemberId = new Map<Id, Integer>();
        //contact1
        CampaignMember cm = members[0];
        buyerByMemberId.put(cm.Id, true);
        amountByMemberId.put(cm.Id, 3.0);//sum of amount
        countByMemberId.put(cm.Id, 2); //count of Brand_Transaction__c records
        //contact2
        cm = members[1];
        buyerByMemberId.put(cm.Id, true);
        amountByMemberId.put(cm.Id, 4.0);//sum of amount
        countByMemberId.put(cm.Id, 1); //count of Brand_Transaction__c records        

        //contact3NoTrans
        cm = members[2];
        buyerByMemberId.put(cm.Id, false);
        amountByMemberId.put(cm.Id, null);//sum of amount
        countByMemberId.put(cm.Id, null); //count of Brand_Transaction__c records        

        //contact4OfCamp2
        cm = members[3];
        buyerByMemberId.put(cm.Id, true);
        amountByMemberId.put(cm.Id, 100);//sum of amount
        countByMemberId.put(cm.Id, 1); //count of Brand_Transaction__c records        
        
        Test.startTest();
        //camp
        Brand_Transaction__c bt1_1 = new Brand_Transaction__c(Campaign__c = camp.Id, Contact__c = contact1.Id, Amount__c = 1);
        Brand_Transaction__c bt1_2 = new Brand_Transaction__c(Campaign__c = camp.Id, Contact__c = contact1.Id, Amount__c = 2);
        Brand_Transaction__c bt2_1 = new Brand_Transaction__c(Campaign__c = camp.Id, Contact__c = contact2.Id, Amount__c = 4);
        //Camp2
        Brand_Transaction__c bt4_1 = new Brand_Transaction__c(Campaign__c = camp2.Id, Contact__c = contact4OfCamp2.Id, Amount__c = 100);
        Database.insert(new Brand_Transaction__c[] {bt1_1, bt1_2, bt2_1, bt4_1});
        //we have 3 transactions against 2 contacts in Campaign 'camp', i.e. expect Total_Buyers__c = 2
        System.assertEquals(2.0, [select Id, Total_Buyers__c from Campaign where Id = : camp.Id].Total_Buyers__c);
        //we have 1 transactions against 1 contacts in Campaign 'camp2', i.e. expect Total_Buyers__c = 1
        System.assertEquals(1.0, [select Id, Total_Buyers__c from Campaign where Id = : camp2.Id].Total_Buyers__c);
        
        //validate Campaign Member fields 
        //Total_transaction_value__c
        //Total_transaction_count__c
        //Buyer__c
        for ( CampaignMember memberLoaded : [select Id, Total_transaction_value__c, Total_transaction_count__c, Buyer__c,
                                                    CampaignId, ContactId, Contact.Name 
                                             from CampaignMember where id in: buyerByMemberId.keySet()]) {
            //check if each CampaignMember has valid total figures
            System.assertEquals((Boolean)buyerByMemberId.get(memberLoaded.Id), memberLoaded.Buyer__c);
            System.assertEquals((Decimal)amountByMemberId.get(memberLoaded.Id), memberLoaded.Total_transaction_value__c);
            System.assertEquals((Integer)countByMemberId.get(memberLoaded.Id), memberLoaded.Total_transaction_count__c); 
        }
         
    }
    

}