/**
 * unit tests for Campaign Member triggers
 */
@isTest
private class CampaignMemberTests {
    private static final Id DEFAULT_MEMBERS_B2C_CONTACT_RT = CampaignAfterSupport.DEFAULT_MEMBERS_B2C_CONTACT_RT;
    private static final Id DEFAULT_MEMBERS_B2C_CAMPAIGN_RT = CampaignAfterSupport.DEFAULT_MEMBERS_B2C_CAMPAIGN_RT;
    private static final String DEFAULT_MEMBERS_CAMPAIGN_TYPE = CampaignAfterSupport.DEFAULT_MEMBERS_CAMPAIGN_TYPE;

    /**
        @return: Map: "Campaign" -> Campaign, "Account"->Account, 
                    "Contact0"  -> Contact, ... "ContactN"  -> Contact,
                    "CampaignMember0" -> CampaignMember0 ... "CampaignMemberN" -> CampaignMemberN   
        Campaign, Account & Contacts will be INSERTED into the Database
        CampaignMember-s will NOT be Inserted into the Database
    */  
    private static Map<String, SObject> createTestCampaignWithNMembers(final Id campaignRtId, Id contactRT, final String campaignType, final Integer numOfMembers, final String memberStatus) {
        final Map<String, SObject> dataMap = new Map<String, SObject>();
        System.debug('*** campaignRtId *** '+campaignRtId);
        
        final Campaign camp = new Campaign(Name='test', RecordTypeId = campaignRtId, 
                                            Type = campaignType, Active_Redemption_Segments__c = true);
        Database.insert(camp);
        dataMap.put('Campaign', camp);
        
        final Account acc = new Account (Name='acc',RecordTypeId=EventBeforeSupport.B2B_ACCOUNT_RT);
        Database.insert(acc);
        dataMap.put('Account', acc);
        
        List<Contact> contacts = new List<Contact>();
        for (Integer i=0 ; i< numOfMembers; i++) {
            Contact cont = new Contact (LastName = 'Test1', AccountId = acc.Id, RecordTypeId = contactRT, Current_Segment__c = null, Last_Redemption_Date__c = null, Current_Segment_Campaign__c = null);
            dataMap.put('Contact' + i, cont);
            contacts.add(cont);
        }
        Database.insert(contacts);
        
        List<CampaignMember> members = new List<CampaignMember>();
        Set<Id> contactIds = new Set<Id>();
        Integer i=0;
        for (Contact cont : contacts) {
            CampaignMember cm = new CampaignMember();
            cm.ContactId = cont.Id;
            cm.CampaignId = camp.Id;
            dataMap.put('CampaignMember' + i, cm);
            i++;
        }
        
        return dataMap;
        
    }
    /**
            b. IF
                 There is an update to the Campaign Member status to Responded
                 AND 
                 Campaign.Active Redemption Segments is True 
               THEN proceed (otherwise do nothing)
            
            c. Update Contact.Current Segment with a value of 1
            
            d. Update Contact.Last Redemption Date with the date the redemption was captured
                 i.e. CampaignMember.FirstRespondedDate 
            
            e. Update Contact.Current Segment Campaign with the name of the campaign that caused redemption
    
    */    
    static testMethod void testCampaignMemberAfter_Responded() {
        final String STATUS_RESPONDED = 'Responded';
        //createTestCampaignWithNMembers(final Id campaignRtId, Id contactRT, final String campaignType, final Integer numOfMembers, final String memberStatus)
        final Map<String, SObject> dataMap = createTestCampaignWithNMembers(DEFAULT_MEMBERS_B2C_CAMPAIGN_RT, 
                                                            DEFAULT_MEMBERS_B2C_CONTACT_RT, 
                                                            DEFAULT_MEMBERS_CAMPAIGN_TYPE, 
                                                            3, STATUS_RESPONDED);
        Campaign camp = (Campaign)dataMap.get('Campaign');
        List<CampaignMember> members = new List<CampaignMember>();
        List<Contact> contacts = new List<Contact>();
        final Set<Id> contactIds = new Set<Id>();
        for (Integer i=0; i < 3; i++) {

            members.add((CampaignMember)dataMap.get('CampaignMember' + i));
            Contact cont = (Contact)dataMap.get('Contact' + i); 
            contactIds.add(cont.Id);
            contacts.add(cont);
        }
        

        Test.startTest();
        Database.insert(members);
        
        //check that for each contact 
        // Current_Segment__c = null, Last_Redemption_Date__c = null, Current_Segment_Campaign__c = null
        System.assertEquals(contacts.size(), [select count() from Contact where Id in: contactIds 
                                   and Current_Segment__c = null and Last_Redemption_Date__c = null and Current_Segment_Campaign__c = null]);
        
        //set status to responded for 2 Contacts and leave unresponded for 3rd
        members[0].Status = STATUS_RESPONDED;
        members[1].Status = STATUS_RESPONDED;
        Database.update(members);
        //check that first 2 contacts now updated
        System.assertEquals(2, [select count() from Contact where 
                                (Id =: contacts[0].Id or Id =: contacts[1].Id )  
                                   and Current_Segment__c = 1 
                                   and Last_Redemption_Date__c =: System.today() 
                                   and Current_Segment_Campaign__c =: camp.Id]);
                                   
        //and 3rd contact is NOT updated                          
        System.assertEquals(1, [select count() from Contact where 
                                (Id =: contacts[2].Id )  
                                   and Current_Segment__c = null 
                                   and Last_Redemption_Date__c =: null 
                                   and Current_Segment_Campaign__c =: null]);
        
    }
    
    /**
        IF
            Campaign Member.Redemption Count > 0
            AND Campaign Member.Mono Contact = "True"
        THEN CREATE
            Mono_Contact_Redemption__c with the following fields mapped:
                Mono_Contact_Redemption.Campaign = Campaign
                Mono_Contact_Redemption.Contact = Campaign Member.Contact
                Mono_Contact_Redemption.Redemption Village = Campaign Member.Redemption Village Source
                Mono_Contact_Redemption.Redemption Date = Today
        THEN
            Reset Campaign Member.Redemption_Count = 0        
    
    */
    static testMethod void testCampaignMemberBefore_RedemptionCount() {
        final Map<String, RecordType> rtMap = UnitTestUtils.loadRecordTypes(new Set<String> {'Contact', 'Campaign'}, 
                                                                            new Set<String> {'Mono_Contact', 'B2C'});
        
        final Map<String, SObject> dataMap = createTestCampaignWithNMembers(DEFAULT_MEMBERS_B2C_CAMPAIGN_RT, 
                                                            rtMap.get('Mono_Contact').Id, 
                                                            DEFAULT_MEMBERS_CAMPAIGN_TYPE, 
                                                            1, 'Sent');
        
        /*
            final Map<String, SObject> dataMap = createTestCampaignWithNMembers(rtMap.get('B2C').Id, 
                                                            rtMap.get('Mono_Contact').Id, 
                                                            DEFAULT_MEMBERS_CAMPAIGN_TYPE, 
                                                            1, 'Sent');
        */
        Campaign camp = (Campaign)dataMap.get('Campaign');
        CampaignMember cm = (CampaignMember)dataMap.get('CampaignMember0');
        
        Test.startTest();
        //original CM insert
        Database.insert(cm);
        //do not expect any Mono_Contact_Redemption to be created
        System.assertEquals(0, [select count() from Mono_Contact_Redemption__c where Campaign__c =: camp.Id]);
        
        //update 4 times with count >0, where count may be repeated due to concurrent transactions 
        Database.update(new CampaignMember(Id = cm.Id, Redemption_Count__c = 1));
        Database.update(new CampaignMember(Id = cm.Id, Redemption_Count__c = 2));
        Database.update(new CampaignMember(Id = cm.Id, Redemption_Count__c = 2));//repeat count
        Database.update(new CampaignMember(Id = cm.Id, Redemption_Count__c = 3));
        
        // System.assertEquals(4, [select count() from Mono_Contact_Redemption__c where Campaign__c =: camp.Id]);
        System.assertEquals(8, [select count() from Mono_Contact_Redemption__c where Campaign__c =: camp.Id]);
        
        //update once more and check count and date
        Database.update(new CampaignMember(Id = cm.Id, Redemption_Count__c = 1));
        // System.assertEquals(5, [select count() from Mono_Contact_Redemption__c where Campaign__c =: camp.Id and Redemption_Date__c =: System.today() ]);
        System.assertEquals(9, [select count() from Mono_Contact_Redemption__c where Campaign__c =: camp.Id and Redemption_Date__c =: System.today() ]);
        
        //update with 0 count, i.e. status changed or somethign, but not barcode scan 
        Database.update(new CampaignMember(Id = cm.Id, Redemption_Count__c = 0));
        // System.assertEquals(5, [select count() from Mono_Contact_Redemption__c where Campaign__c =: camp.Id and Redemption_Date__c =: System.today() ]);
        System.assertEquals(9, [select count() from Mono_Contact_Redemption__c where Campaign__c =: camp.Id and Redemption_Date__c =: System.today() ]);
        
    }
}