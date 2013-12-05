/**
    @date 16/04/2011
    @author Andrey Gavrikov (westbrook)
    @description:
        Requirement:
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
			Reset Campaign Member.Redemption Count = 0        
    @version history:
*/
trigger CampaignMemberBefore on CampaignMember (before update) {
    //if ('WESTBROOK' != UserInfo.getName() && !Test.isRunningTest()) {
    //    return; //TODO remove when testing is complete
    //}
	if (Trigger.isBefore && Trigger.isUpdate) {
		Boolean ignoreRedemptionInsertErrors = Boolean.valueOf(System.Label.Ignore_Redemption_Insert_Errors);
		final List<Mono_Contact_Redemption__c> redemptionsToInsert = new List<Mono_Contact_Redemption__c>();
		final Set<Id> cmToResetCountIds = new Set<Id>();
		for (CampaignMember cm : Trigger.new) {
			CampaignMember cmOld = Trigger.oldMap.get(cm.Id);
			
			if ('True' == cm.Mono_Contact__c && null != cm.Redemption_Count__c && cm.Redemption_Count__c > 0) {
				//create new Mono_Contact_Redemption
				// Updated to create multiple records if redemption count > 1
				// Used in Barcode Application to allow multiple mono contact redemptions in one go.
				for (Integer i = 1; i <= cm.Redemption_Count__c; i++) {
					Mono_Contact_Redemption__c redemption =	new Mono_Contact_Redemption__c();
					redemption.Campaign__c = cm.CampaignId;
					redemption.Contact__c = cm.ContactId;
					redemption.Redemption_Village__c = cm.Redemption_Village_Source__c;
					redemption.Redemption_Date__c = System.today();	
					redemptionsToInsert.add(redemption);
				}
				//Reset Campaign Member.Redemption Count = 0
				cm.Redemption_Count__c = 0;
			}
		}
		if (!redemptionsToInsert.isEmpty()) {
			Database.insert(redemptionsToInsert, !ignoreRedemptionInsertErrors);
		}
	}

}