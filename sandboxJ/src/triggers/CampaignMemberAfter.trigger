/**
    @date 21/08/2010
    @author Andrey Gavrikov (westbrook)
    @description:
        Requirement:
			a. IF
			     There is an update to the Campaign Member status to Responded
			     AND 
			     Campaign.Active Redemption Segments is True 
			   THEN proceed (otherwise do nothing)
			b. Update Contact.Current Segment with a value of 1
			c. Update Contact.Last Redemption Date with the date the redemption was captured
			     i.e. CampaignMember.FirstRespondedDate 
			d. Update Contact.Current Segment Campaign with the name of the campaign that caused redemption
    @version history:
*/
trigger CampaignMemberAfter on CampaignMember (after delete, after insert, after undelete, after update) {
    if (TriggerUtils.skipTrigger('CampaignMemberAfter')) {
        return;
    }
	
	final String STATUS_RESPONDED = 'Responded';
	if (trigger.isInsert || trigger.isUpdate || trigger.isUnDelete) {
		List<CampaignMember> respondedMembers = new List<CampaignMember>();
		Set<Id> campaignIdsToLoad = new Set<Id>();  
		for (CampaignMember cm : trigger.new) {
	   	    if (STATUS_RESPONDED == cm.Status && null != cm.ContactId) {
                campaignIdsToLoad.add(cm.CampaignId);
                respondedMembers.add(cm);               
	   	    }
		}

		if (!campaignIdsToLoad.isEmpty()) {
			final Map<Id, Campaign> activeRedemptionCampaignMap = new Map<Id, Campaign>([select Id, Name from Campaign where Active_Redemption_Segments__c = true and Id in: campaignIdsToLoad]);
			Map<Id, Contact> contactsToUpdateMap = new Map<Id, Contact>(); 
			for (CampaignMember cm : respondedMembers) {
				Campaign camp = activeRedemptionCampaignMap.get(cm.CampaignId);
				if (camp != null ) {
					//i.e. camp.Active_Redemption_Segments__c = true
					Contact cont = new Contact(Id = cm.ContactId);
					cont.Current_Segment__c = 1;
					cont.Last_Redemption_Date__c = cm.FirstRespondedDate;
					cont.Current_Segment_Campaign__c = camp.Id;
					contactsToUpdateMap.put(cont.Id, cont);
				}
			}
			if (!contactsToUpdateMap.isEmpty()) {
				Database.update(contactsToUpdateMap.values());
			}
		}
	}

}