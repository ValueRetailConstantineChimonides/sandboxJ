public class ContactAddressChangeTests {
	static testMethod void testPostalAddressQuality() {
		UnitTestUtils.setApexOffFlag(false);
		Contact contact = new Contact(FirstName = 'testPostalAddressQuality', 
		LastName = 'test', MailingStreet = 'my street', MailingPostalCode = 'GU12 1AB', MailingCity = 'My City');
		insert contact;
		contact = [select MailingStreet, MailingPostalCode, MailingCity, Postal_address_quality__c from Contact where id =: contact.id];
		//System.assert (contact.Postal_address_quality__c <> null && contact.Postal_address_quality__c <> '0' && contact.Postal_address_quality__c.length() >0, 'Postal_address_quality__c has not been set to 0 after insert');
		
		contact.MailingStreet = 'new' + contact.MailingStreet;
		contact.Postal_address_quality__c = '1';
		update contact;
		contact = [select MailingStreet, MailingPostalCode, MailingCity, Postal_address_quality__c from Contact where id =: contact.id];
		System.assert (contact.Postal_address_quality__c == '0', 'Postal_address_quality__c has not been set to 0 after MailingStreet update. Value=\'' + contact.Postal_address_quality__c + '\'');
	}
}