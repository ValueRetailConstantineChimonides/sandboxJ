/**
    @date 03/08/2009
    @author Andrey Gavrikov (westbrook)
    @description:
        support class for CampaignAfter.trigger
    
    @see requirement details in CampaignAfter.trigger
                     
    @version history: 
        2009-12-23 - AG - added @future method insertMembers in order to work around too many DML records limit 100
                        because there are 115 contacts to become Campaign Member
                        as of now no other @future invocations seem to be used in other parts of Apex Code
    
*/
public without sharing class CampaignAfterSupport {
    //campaign
    public static final Id DEFAULT_MEMBERS_B2C_CAMPAIGN_RT = '01220000000CkxJAAS';//(B2C Campaigns Only)
    //contact
    public static final Id DEFAULT_MEMBERS_B2C_CONTACT_RT = '012200000001KhTAAU';//B2C (All Emails) = 012200000001KhTAAU
    
    
    public static final String DEFAULT_MEMBERS_CAMPAIGN_TYPE = 'Email';
    
    private static List<CampaignMember> generateDefaultCampaignMembers(final Set<Id> campIdToAddDefaultMembers) {
        //load default contacts
        final Map<Id, Contact> contIdsMap = new Map<Id, Contact>([select Id from Contact where RecordTypeId =: DEFAULT_MEMBERS_B2C_CONTACT_RT]);
        final List<CampaignMember> campMembers = new List<CampaignMember>(); 
        for (Id campId : campIdToAddDefaultMembers) {
            for (Id contId : contIdsMap.keySet()) {
              campMembers.add(new CampaignMember(CampaignId = campId, ContactId = contId)); 
            }
        }
        return campMembers;
    } 
    @future
    public static void insertMembers(final Set<Id> campIdToAddDefaultMembers) {
        Database.insert(CampaignAfterSupport.generateDefaultCampaignMembers(campIdToAddDefaultMembers), false);  
    }
    
    //////////////// tests /////////////
    static testMethod void test() {
        //check if we have necessary contacts
        Integer count = [select count() from Contact where RecordTypeId =: DEFAULT_MEMBERS_B2C_CONTACT_RT];
        if (count <1) {
            final Account acc = new Account (Name='acc');
            insert acc;
            Contact contact = new Contact (LastName = 'Test', AccountId = acc.Id, RecordTypeId = DEFAULT_MEMBERS_B2C_CONTACT_RT);
            insert contact;
            count = 1;
        }
        //wrong type
        Campaign camp = new Campaign(Name='test', RecordTypeId = DEFAULT_MEMBERS_B2C_CAMPAIGN_RT, Type = DEFAULT_MEMBERS_CAMPAIGN_TYPE + '-test');
        insert camp;
        
        //check if default members have NOT been created because campaign Type is wrong
        System.assertEquals(0, [select count() from CampaignMember where CampaignId =: camp.Id]);
        
        //ok
        camp = new Campaign(Name='test', RecordTypeId = DEFAULT_MEMBERS_B2C_CAMPAIGN_RT, Type = DEFAULT_MEMBERS_CAMPAIGN_TYPE);
        insert camp;
        
        //check if default members have been created because campaign Type is wrong
        //20091223 - we can no longer test this result because of @future method
        //System.assertEquals(count, [select count() from CampaignMember where CampaignId =: camp.Id]);
        
    }
    
    
}