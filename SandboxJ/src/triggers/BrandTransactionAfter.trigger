/**
    @date 21/08/2010
    @author Andrey Gavrikov (westbrook)
    @description:
        Requirement:
        Count of unique contacts with transactions against a campaign e.g. 10 transactions against a campaign across 3 contacts therefore we need 3 to display against the campaign.
        
        Unit tests see in CampaignAfterSupport.cls
        
    @version history:
        2010-09-05 - AG
			Requirements
			Update the corresponding campaign member record (derived from the campaign and contact look up)
			
			1. Update new field on campaign member: Total transaction value (number field)
			Total value of all transactions made by that individual linked to the campaign
			
			2. Update new field on campaign member: Total transaction count (number field)
			Total count of all transactions made by that individual linked to the campaign
			
			3. Update new field on campaign member: Buyer (Boolean true or false)
			= True if the individual has made a transaction        
*/
trigger BrandTransactionAfter on Brand_Transaction__c (after delete, after insert, after undelete, after update) {
	final List<Brand_Transaction__c> transList = trigger.isDelete? trigger.old : trigger.new;
	final Set<Id> campaignIds = new Set<Id>();
	final Set<Id> contactIds = new Set<Id>(); 
    for (Brand_Transaction__c trans : transList) {
    	if (null != trans.Campaign__c) {
    	    campaignIds.add(trans.Campaign__c);
    	}
        if (null != trans.Contact__c) {
            contactIds.add(trans.Contact__c);
        }
    	
    }
    
    if (!campaignIds.isEmpty()) {
    	List<Campaign> campaignsToUpdate = new List<Campaign>(); 
        for (AggregateResult ar : [select Campaign__c, count_distinct(Contact__c) cnt 
                                    from Brand_Transaction__c where Campaign__c in: campaignIds group by Campaign__c]) {
        	
        	Id campaignId = (Id)ar.get('Campaign__c');
        	if (campaignId != null) {
        		Integer contactCount = (Integer)ar.get('cnt');
        		campaignsToUpdate.add(new Campaign(Id = campaignId, Total_Buyers__c = contactCount));
        	}
        }
        if (!campaignsToUpdate.isEmpty()) {
        	TriggerUtils.addToSkipTriggerMap('CampaignAfter', 'updating Campaign.Total_Buyers__c from BrandTransactionAfter');
        	Database.update(campaignsToUpdate);
        	TriggerUtils.removeFromSkipTriggerMap('CampaignAfter');
        }
        //update Campaign Members
        final Map<String, MemberData> campaignMemberDataMap = new Map<String, MemberData>();
        
		for ( AggregateResult ar : [select Campaign__c, Contact__c, sum(Amount__c) transAmount, count(Id) transCount
									from Brand_Transaction__c where Campaign__c in: campaignIds and Contact__c in: contactIds
									group by Campaign__c, Contact__c]) {
		
			Id campaignId = (Id)ar.get('Campaign__c');
			Id contactId = (Id)ar.get('Contact__c');
			Integer transCount = (Integer)ar.get('transCount'); 
			Decimal transAmount = (Decimal)ar.get('transAmount');
			if (contactId != null) {
				//contactIds.add(contactId);
				
				MemberData data = new MemberData();
				data.transCount = transCount;
				data.transAmount = transAmount;
				campaignMemberDataMap.put(getCampaignMemberKey(campaignId, contactId), data);
			}
			//System.debug('Campaign=' + campaignId + '; Contact=' + contactId + '; transCount=' + transCount + '; transAmount=' + transAmount);
		}
		List<CampaignMember> membersToUpdate = new List<CampaignMember>();
		//Total_transaction_value__c
		//Total_transaction_count__c
		//Buyer__c
		for (CampaignMember member : [select Id, CampaignId, ContactId from CampaignMember where CampaignId in: campaignIds and ContactId in : contactIds]){
			
			String key = getCampaignMemberKey(member.CampaignId, member.ContactId);
			
			if (null != key) {
				MemberData data = campaignMemberDataMap.get(key);
				if (null != data) {
					member.Total_transaction_count__c = data.transCount;
					member.Total_transaction_value__c = data.transAmount;
					member.Buyer__c = true;
					membersToUpdate.add(member);
				}
			}
		}
		if (!membersToUpdate.isEmpty()) {
			TriggerUtils.addToSkipTriggerMap('CampaignMemberAfter', 'updating CampaignMember.Total_transaction_count__c from BrandTransactionAfter');
			Database.update(membersToUpdate);
			TriggerUtils.removeFromSkipTriggerMap('CampaignMemberAfter');
		}
    }
    
    ////////////////////////////////////////////////////////
    class MemberData {
    	public Integer transCount;
    	public Decimal transAmount;
    	
    }
    String getCampaignMemberKey(final Id campaignId, final Id contactId) {
    	return '' + campaignId + '-' + contactId;
    }
    
}