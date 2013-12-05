/**
    @date 03/08/2009
    @author Andrey Gavrikov (westbrook)
    @description:
        Requirement:
        There are 9 contacts created in SFDC with a record type of B2C (All Emails) = 012200000001KhTAAU
        These contacts must be automatically associated to every email campaign (meeting the below criteria) created in salesforce:
        1.       Campaign Record Type = 01220000000CkxJAAS (B2C Campaigns Only)
        2.       Campaign Type = Email
        3.       Test Campaign = False
        
        N.B. If the Test Campaign = True then I would like to persist ensure that none of these contacts with 
              record type 012200000001KhTAAU are included in the campaign.
                
    @version history:
        2009-12-23 - AG - added @future method insertMembers in order to work around too many DML records limit 100
                        because there are 115 contacts to become Campaign Member
                        as of now no other @future invocations seem to be used in other parts of Apex Code
        2010-09-17 - AG
            Guy asked to add:
            Include additional campaign record type 01220000000CneKAAS (COS Campaigns).
*/
trigger CampaignAfter on Campaign (after delete, after insert, after update) {
    if (TriggerUtils.skipTrigger('CampaignAfter')) {
        return;
    }
    if (Trigger.isAfter && (Trigger.isInsert)) {
        final Set<Id> campIdToAddDefaultMembers = new Set<Id>();
        for (Campaign camp : trigger.new) {
            if ( (camp.RecordTypeId == CampaignAfterSupport.DEFAULT_MEMBERS_B2C_CAMPAIGN_RT
                ||
                 camp.RecordTypeId == '01220000000CneKAAS' /*COS Campaigns*/   
                 ) 
                  && camp.Test_Campaign__c == false 
                  && camp.Type == CampaignAfterSupport.DEFAULT_MEMBERS_CAMPAIGN_TYPE) {
              campIdToAddDefaultMembers.add(camp.Id);       
            }
        }
        if (!campIdToAddDefaultMembers.isEmpty()) {
            // Removed To Stop Addition Of Seed List
            // CampaignAfterSupport.insertMembers(campIdToAddDefaultMembers);
            //Database.insert(CampaignAfterSupport.generateDefaultCampaignMembers(campIdToAddDefaultMembers), false);  
        }
    }
}