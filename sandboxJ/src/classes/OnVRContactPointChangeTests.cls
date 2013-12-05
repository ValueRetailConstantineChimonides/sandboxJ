public class OnVRContactPointChangeTests {
		static testMethod void testMainChristmasCardSigner() {
		Contact contact = new Contact (LastName = 'Test');
		insert contact;
		
		VR_Employee__c employee = new VR_Employee__c(Last_Name__c = 'Test-Employee');
		insert employee;
		
		VR_Point_of_Contact__c cp = new VR_Point_of_Contact__c(VR_Employee__c = employee.id, VR_Contact_Point__c = contact.id, Christmas_Card_Signer__c = 'No');
		insert cp;
		
		contact = [select id, Main_Christmas_Card_Signer_Lookup__c from Contact where id =: contact.id];
		System.assert(contact.Main_Christmas_Card_Signer_Lookup__c  == null, 'Expected Empty Main_Christmas_Card_Signer_Lookup__c');
		
		cp.Christmas_Card_Signer__c = 'Main';
		update cp;
		contact = [select id, Main_Christmas_Card_Signer_Lookup__c from Contact where id =: contact.id];
		System.assert(contact.Main_Christmas_Card_Signer_Lookup__c  == employee.id, 'Expected not empty Main_Christmas_Card_Signer_Lookup__c');
		
		cp.Christmas_Card_Signer__c = 'No';
		update cp;
		contact = [select id, Main_Christmas_Card_Signer_Lookup__c from Contact where id =: contact.id];
		System.assert(contact.Main_Christmas_Card_Signer_Lookup__c  == null, 'Expected Empty Main_Christmas_Card_Signer_Lookup__c');
		
		//trying to save 2 Contact points with 'Main'
		VR_Point_of_Contact__c cp2 = new VR_Point_of_Contact__c(VR_Employee__c = employee.id, VR_Contact_Point__c = contact.id, Christmas_Card_Signer__c = 'Main');
		insert cp2;
		
		cp.Christmas_Card_Signer__c = 'Main';
		try {
			update cp;
		} catch (Exception e) {
			//FIELD_CUSTOM_VALIDATION_EXCEPTION, Only one "Main" Christmas Card Signer is allowed: [Christmas_Card_Signer__c]
			System.debug(e);
		}
		
		//test delete
		delete cp2;
		contact = [select id, Main_Christmas_Card_Signer_Lookup__c from Contact where id =: contact.id];
		System.assert(contact.Main_Christmas_Card_Signer_Lookup__c  == null, 'Expected Empty Main_Christmas_Card_Signer_Lookup__c');
		
		//test undelete
		undelete cp2;
		contact = [select id, Main_Christmas_Card_Signer_Lookup__c from Contact where id =: contact.id];
		System.assert(contact.Main_Christmas_Card_Signer_Lookup__c  == employee.id, 'Expected not empty Main_Christmas_Card_Signer_Lookup__c');
		
	}
}