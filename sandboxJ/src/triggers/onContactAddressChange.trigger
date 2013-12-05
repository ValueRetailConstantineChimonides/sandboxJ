/*
ENG-0711-59
Auto-update postal address quality to 0 when address fields are updated/edited either manually or automatically.
Field to update is called ' ** Postal address quality' (Postal_address_quality__c)

*/
trigger onContactAddressChange on Contact (before update) {
	if (TriggerUtils.CURRENT_USER.Apex_Off__c)
		return;
	
	Integer i = 0;
	while (i < Trigger.new.size()) {
		Contact oldContact = Trigger.old[i];
		Contact newContact = Trigger.new[i];
		i++;
		boolean reset = false;
		reset = //oldContact.Mailing_Country_In_English__c <> newContact.Mailing_Country_In_English__c ||
			oldContact.MailingStreet <> newContact.MailingStreet ||
			//oldContact.MailingState <> newContact.MailingState ||
			oldContact.MailingPostalCode <> newContact.MailingPostalCode ||
			//oldContact.MailingCountry <> newContact.MailingCountry ||
			oldContact.MailingCity <> newContact.MailingCity;
		
		if (reset) {
			System.debug('reset Postal_address_quality__c');
			newContact.Postal_address_quality__c = '0';	
		}
	}
}