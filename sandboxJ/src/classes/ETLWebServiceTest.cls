@isTest (seeAllData=true)
private class ETLWebServiceTest {
    /**
     * Test for simple test method in WebService.  Temporary and can be removed after implementation.
     */
    static testMethod void testWSTestMethod() {
    	Properties.IS_TEST_METHOD = true;
    	system.debug('TEST START: testWSTestMethod');
    	String testString = ETLWebService.wsTest();
    	system.assertEquals('Yes it works', testString);
    	system.debug('TEST END: testWSTestMethod');
    }
    
    /**
     * Test new contact registrations.
     * INPUT: Two ETLContactDTO records.
     * OUTCOME: Two new contacts created, two customer activity records created.
     * RESULT: Both inserts successful.
     */
    static testMethod void testContactRegistration() {
    	Properties.IS_TEST_METHOD = true;
    	system.debug('TEST START: testContactRegistration');
    	String testVillageName = 'TESTVILLAGE';
    	String testVillageCode = 'ZZ';
    	Village__c testVillage = new Village__c(Village_Code__c = testVillageCode, Name = testVillageName, Village_Local_Language__c = 'English');
    	insert testVillage;
    	system.debug('VILLAGE INSERTED: ' + testVillage.Id);
    	
    	User admUser = TestDataGenerator.setupAdminUser(false);
    	admUser.Campaign_Village__c = 'Chic Outlet Shopping;TESTVILLAGE';
    	insert admUser;
    	system.debug('ADMIN USER INSERTED: ' + admUser.Id);
    	
    	Account villageAccount = TestDataGenerator.setupB2CAccount(1, false);
    	villageAccount.Name = testVillageName;
    	villageAccount.Site = testVillageCode;
    	insert villageAccount;
    	system.debug('ACCOUNT INSERTED: ' + villageAccount.Id);
    	
    	ETLWebService_Settings__c testSettings = getTestETLSettings();
    	upsert testSettings;
    	
   		ETLContactDTO etlc1 = setupBasicETLContactDTO(1);
   		ETLContactDTO etlc2 = setupBasicETLContactDTO(2);
   		etlc1.Village = testVillageCode;
   		etlc2.Village = testVillageCode;
   		etlc2.Activity_Qty = null;
   		etlc2.Activity_Value = null;
    	List<ETLContactDTO> inList = new List<ETLContactDTO> {etlc1, etlc2};
    	
    	test.startTest();
    	List<ETLContactResultDTO> outList = ETLWebService.contactRegistration(inList);
    	test.stopTest();
    	
    	system.assertEquals(2, outList.size());
    	system.debug('OUTLIST: ' + outList);
    	
    	List<Id> contactIdList = new List<Id> ();
    	for (ETLContactResultDTO res : outList) {
    		contactIdList.add(res.ContactId);
    		system.assertEquals('Completed', res.Result);
    		system.assertEquals('Success', res.Status);
    		system.assertEquals('New', res.ContactAction);
    	}
    	
    	List<Contact> contactsUploaded = [SELECT Id, FirstName, LastName, AccountId, Email, Gender__c, Birthdate,
    									  I_am_18_years_old_or_more__c, HasOptedOutOfEmail, Mobile_Opt_Out__c,
    									  Postal_Opt_Out__c, Other_Village_Partner_Opt_Out__c, Profiling_Opt_Out__c,
    									  Mailing_Country_In_English__c, Preferred_language_of_communication__c,
    									  Nationality_Picklist__c, MailingStreet, MailingCity, MailingState, MailingCountry,
    									  MailingPostalCode, MobilePhone, RecordTypeId, LeadSource, Lead_Source_Text__c,
    									  Original_Creation_Date__c, B2C_Password__c
    									  FROM Contact
    									  WHERE Id IN :contactIdList];
    	system.debug('CONTACT LIST: ' + contactsUploaded);
    	system.assertEquals(2, contactsUploaded.size());
    	
    	for (Contact c : contactsUploaded) {
    		if (c.Email == etlc1.EmailAddress) {
	    		system.assertEquals(etlc1.LastName, c.LastName);
	    		system.assertEquals(etlc1.FirstName, c.FirstName);
	    		system.assertEquals(etlc1.DateOfBirth, c.Birthdate);
	    		system.assertEquals(etlc1.Gender, c.Gender__c);
	    		system.assertEquals(etlc1.Over18YearsOld, c.I_am_18_years_old_or_more__c);
	    		system.assertEquals(etlc1.EmailOptOut, c.HasOptedOutOfEmail);
	    		system.assertEquals(etlc1.MobileOptOut, c.Mobile_Opt_Out__c);
	    		system.assertEquals(etlc1.PostalOptOut, c.Postal_Opt_Out__c);
	    		system.assertEquals(etlc1.ThirdPartyOptOut, c.Other_Village_Partner_Opt_Out__c);
	    		system.assertEquals(etlc1.ProfilingOptOut, c.Profiling_Opt_Out__c);
	    		system.assertEquals(etlc1.Address_Street, c.MailingStreet);
	    		system.assertEquals(etlc1.Address_City, c.MailingCity);
	    		system.assertEquals(etlc1.Address_State, c.MailingState);
	    		system.assertEquals(etlc1.Address_Country, c.MailingCountry);
	    		system.assertEquals(etlc1.Address_PostCode, c.MailingPostalCode);
	    		system.assertEquals(etlc1.Mobile, c.MobilePhone);
	    		system.assertEquals(etlc1.CountryOfResidence, c.Mailing_Country_In_English__c);
	    		system.assertEquals(etlc1.Nationality, c.Nationality_Picklist__c);
	    		system.assertEquals(etlc1.PreferredLanguage, c.Preferred_language_of_communication__c);
	    		system.assertEquals(etlc1.LeadSourceText, c.Lead_Source_Text__c);
	    		system.assertEquals(testSettings.Lead_Source__c, c.LeadSource);
	    		system.assertEquals(etlc1.RegistrationDate, c.Original_Creation_Date__c);
	    		system.assertEquals(etlc1.Password, c.B2C_Password__c);
    		} else if (c.Email == etlc2.EmailAddress) {
	    		system.assertEquals(etlc2.LastName, c.LastName);
	    		system.assertEquals(etlc2.FirstName, c.FirstName);
	    		system.assertEquals(etlc2.DateOfBirth, c.Birthdate);
	    		system.assertEquals(etlc2.Gender, c.Gender__c);
	    		system.assertEquals(etlc2.Over18YearsOld, c.I_am_18_years_old_or_more__c);
	    		system.assertEquals(etlc2.EmailOptOut, c.HasOptedOutOfEmail);
	    		system.assertEquals(etlc2.MobileOptOut, c.Mobile_Opt_Out__c);
	    		system.assertEquals(etlc2.PostalOptOut, c.Postal_Opt_Out__c);
	    		system.assertEquals(etlc2.ThirdPartyOptOut, c.Other_Village_Partner_Opt_Out__c);
	    		system.assertEquals(etlc2.ProfilingOptOut, c.Profiling_Opt_Out__c);
	    		system.assertEquals(etlc2.Address_Street, c.MailingStreet);
	    		system.assertEquals(etlc2.Address_City, c.MailingCity);
	    		system.assertEquals(etlc2.Address_State, c.MailingState);
	    		system.assertEquals(etlc2.Address_Country, c.MailingCountry);
	    		system.assertEquals(etlc2.Address_PostCode, c.MailingPostalCode);
	    		system.assertEquals(etlc2.Mobile, c.MobilePhone);
	    		system.assertEquals(etlc2.CountryOfResidence, c.Mailing_Country_In_English__c);
	    		system.assertEquals(etlc2.Nationality, c.Nationality_Picklist__c);
	    		system.assertEquals(etlc2.PreferredLanguage, c.Preferred_language_of_communication__c);
	    		system.assertEquals(etlc2.LeadSourceText, c.Lead_Source_Text__c);
	    		system.assertEquals(testSettings.Lead_Source__c, c.LeadSource);
	    		system.assertEquals(etlc2.RegistrationDate, c.Original_Creation_Date__c);
	    		system.assertEquals(etlc2.Password, c.B2C_Password__c);
    		}
    	}
    	
    	List<Customer_Activity__c> activityList = [SELECT Id, Contact_Name__c, Touchpoint_Type__c, Activity_Date__c,
    											   Activity_Quantity__c, Activity_Text__c, Activity_Type__c,
    											   Activity_Value__c, Touchpoint_Reference__c, Touchpoint_Source__c,
    											   Campaign__c, Village__c
    											   FROM Customer_Activity__c
    											   WHERE Contact_Name__c IN :contactIdList];	
    	system.debug('ACTIVITY LIST: ' + activityList);
    	system.assertEquals(2, activityList.size());

    	for (Customer_Activity__c ca : activityList) {
    		system.assertEquals(testSettings.Activity_Type__c, ca.Activity_Type__c);
    		if (ca.Touchpoint_Reference__c == etlc1.TouchpointReference) {
	    		system.assertEquals(etlc1.TouchpointType, ca.Touchpoint_Type__c);
	    		system.assertEquals(etlc1.TouchpointSource, ca.Touchpoint_Source__c);
	    		system.assertEquals(etlc1.Activity_Date, ca.Activity_Date__c);
	    		system.assertEquals(etlc1.Activity_Qty, ca.Activity_Quantity__c);
	    		system.assertEquals(etlc1.Activity_Text, ca.Activity_Text__c);
	    		system.assertEquals(etlc1.Activity_Value, ca.Activity_Value__c);
	    		system.assertEquals(testVillage.Id, ca.Village__c);
    		} else if (ca.Touchpoint_Reference__c == etlc2.TouchpointReference) {
	    		system.assertEquals(etlc2.TouchpointType, ca.Touchpoint_Type__c);
	    		system.assertEquals(etlc2.TouchpointSource, ca.Touchpoint_Source__c);
	    		system.assertEquals(etlc2.Activity_Date, ca.Activity_Date__c);
	    		system.assertEquals(0, ca.Activity_Quantity__c);
	    		system.assertEquals(etlc2.Activity_Text, ca.Activity_Text__c);
	    		system.assertEquals(0, ca.Activity_Value__c);
	    		system.assertEquals(testVillage.Id, ca.Village__c);
    		}
    	}
    	system.debug('TEST END: testContactRegistration');
    }

    /**
     * Test single duplicate contact registrations.  Sets up a new contact on the system then 
     * performs two tests:
     * TEST 1 - Ignore Duplicates
     * INPUT: One ETLContactDTO record.
     * OUTCOME: Contact details not updated.  One customer activity record created.
     * RESULT: Successful.
     *
     * TEST 2 - Update Duplicates
     * INPUT: One ETLContactDTO record.
     * OUTCOME: Contact details updated.  Mobile not overwritten.  Another customer activity record created.
     * RESULT: Successful.
     */
    static testMethod void testDuplicateContactRegistration() {
    	Properties.IS_TEST_METHOD = true;
    	system.debug('TEST START: testDuplicateContactRegistration');
    	String testVillageName = 'TESTVILLAGE';
    	String testVillageCode = 'ZZ';
    	Village__c testVillage = new Village__c(Village_Code__c = testVillageCode, Name = testVillageName, Village_Local_Language__c = 'English');
    	insert testVillage;
    	system.debug('VILLAGE INSERTED: ' + testVillage.Id);
    	
    	User admUser = TestDataGenerator.setupAdminUser(false);
    	admUser.Campaign_Village__c = 'Chic Outlet Shopping;TESTVILLAGE';
    	insert admUser;
    	system.debug('ADMIN USER INSERTED: ' + admUser.Id);
    	
    	Account villageAccount = TestDataGenerator.setupB2CAccount(1, false);
    	villageAccount.Name = testVillageName;
    	villageAccount.Site = testVillageCode;
    	insert villageAccount;
    	system.debug('ACCOUNT INSERTED: ' + villageAccount.Id);
    	
    	ETLWebService_Settings__c testSettings = getTestETLSettings();
    	upsert testSettings;
    	
   		// Test Ignore Duplicate
   		ETLContactDTO etlc1 = setupBasicETLContactDTO(1);
   		etlc1.Village = testVillageCode;
   		etlc1.Mobile = null;
   		etlc1.MobileOptOut = true;
		
		// Set up existing contact
		Contact tempContact = TestDataGenerator.setupContact(2, villageAccount.Id, false);
		tempContact.Email = etlc1.EmailAddress;
		tempContact.MobilePhone = '07123 689689';
		tempContact.Mobile_Opt_Out__c = false;
		tempContact.Postal_Opt_Out__c = true;
		insert tempContact;   		
   		
    	List<ETLContactDTO> inList = new List<ETLContactDTO> {etlc1};
    	
    	test.startTest();
    	List<ETLContactResultDTO> outList = ETLWebService.contactRegistration(inList);
    	test.stopTest();
    	
    	system.debug('DUPE OUTLIST 1: ' + outList);
    	system.assertEquals(1, outList.size());
    	ETLContactResultDTO dupeRes1 = outList.get(0);
   		system.assertEquals('Completed', dupeRes1.Result);
   		system.assertEquals('Success', dupeRes1.Status);
   		system.assertEquals('Ignore', dupeRes1.ContactAction);
    	Id dupeContactId = dupeRes1.ContactId;
    	system.assertEquals(tempContact.Id, dupeContactId);
    	
    	List<Contact> contactsUploaded = [SELECT Id, FirstName, LastName, Email, AccountId,
    									  MobilePhone, Mobile_Opt_Out__c, Postal_Opt_Out__c
    									  FROM Contact
    									  WHERE Id = :dupeContactId];

    	system.debug('DUPE CONTACT LIST 1: ' + contactsUploaded);
    	system.assertEquals(1, contactsUploaded.size());
    	Contact test1 = contactsUploaded.get(0);
    	system.assertEquals(tempContact.Email, test1.Email);
    	system.assertEquals(tempContact.LastName, test1.LastName);
    	system.assertEquals(tempContact.FirstName, test1.FirstName);
    	system.assertEquals(tempContact.MobilePhone, test1.MobilePhone);
    	system.assertEquals(tempContact.Mobile_Opt_Out__c, test1.Mobile_Opt_Out__c);
    	system.assertEquals(tempContact.Postal_Opt_Out__c, test1.Postal_Opt_Out__c);
    	system.assertEquals(etlc1.EmailAddress, test1.Email);
    	system.assertNotEquals(etlc1.LastName, test1.LastName);
    	system.assertNotEquals(etlc1.FirstName, test1.FirstName);
    	system.assertNotEquals(etlc1.Mobile, test1.MobilePhone);
    	system.assertNotEquals(etlc1.MobileOptOut, test1.Mobile_Opt_Out__c);
    	system.assertNotEquals(etlc1.PostalOptOut, test1.Postal_Opt_Out__c);
    	
    	List<Customer_Activity__c> activityList = [SELECT Id, Contact_Name__c, Touchpoint_Type__c, Activity_Date__c,
    											   Activity_Quantity__c, Activity_Text__c, Activity_Type__c,
    											   Activity_Value__c, Touchpoint_Reference__c, Touchpoint_Source__c,
    											   Campaign__c, Village__c
    											   FROM Customer_Activity__c
    											   WHERE Contact_Name__c = :dupeContactId];	
    	system.debug('DUPE ACTIVITY LIST 1: ' + activityList);
    	system.assertEquals(1, activityList.size());
    	
    	Customer_Activity__c ca = activityList.get(0);
   		system.assertEquals(etlc1.TouchpointReference, ca.Touchpoint_Reference__c);
   		system.assertEquals(etlc1.TouchpointType, ca.Touchpoint_Type__c);
   		system.assertEquals(etlc1.TouchpointSource, ca.Touchpoint_Source__c);
   		system.assertEquals(etlc1.Activity_Date, ca.Activity_Date__c);
   		system.assertEquals(etlc1.Activity_Qty, ca.Activity_Quantity__c);
   		system.assertEquals(etlc1.Activity_Text, ca.Activity_Text__c);
   		system.assertEquals(etlc1.Activity_Value, ca.Activity_Value__c);
   		system.assertEquals(etlc1.TouchpointType, ca.Touchpoint_Type__c);
   		system.assertEquals(testSettings.Activity_Type__c, ca.Activity_Type__c);
   		system.assertEquals(testVillage.Id, ca.Village__c);

    	testSettings.Ignore_Duplicates__c = false;
    	update testSettings;
    	
   		// Test Update Duplicate
    	etlc1.Activity_Qty = 2;
    	etlc1.Activity_Date = etlc1.Activity_Date.addDays(-1); 
    	List<ETLContactResultDTO> outList2 = ETLWebService.contactRegistration(inList);
    	
    	system.debug('DUPE OUTLIST 2: ' + outList2);
    	system.assertEquals(1, outList2.size());
    	ETLContactResultDTO dupeRes2 = outList2.get(0);
   		system.assertEquals('Completed', dupeRes2.Result);
   		system.assertEquals('Success', dupeRes2.Status);
   		system.assertEquals('Update', dupeRes2.ContactAction);
    	Id dupeContactId2 = dupeRes2.ContactId;
    	system.assertEquals(tempContact.Id, dupeContactId2);
    	
    	List<Contact> contactsUploaded2 = [SELECT Id, FirstName, LastName, AccountId, Email, Gender__c, Birthdate,
    									   I_am_18_years_old_or_more__c, HasOptedOutOfEmail, Mobile_Opt_Out__c,
    									   Postal_Opt_Out__c, Other_Village_Partner_Opt_Out__c, Profiling_Opt_Out__c,
    									   Mailing_Country_In_English__c, Preferred_language_of_communication__c,
    									   Nationality_Picklist__c, MailingStreet, MailingCity, MailingState, MailingCountry,
    									   MailingPostalCode, MobilePhone, RecordTypeId, LeadSource, Lead_Source_Text__c,
    									   Original_Creation_Date__c, B2C_Password__c
    									   FROM Contact
    									   WHERE Id = :dupeContactId2];

    	system.debug('DUPE CONTACT LIST 2: ' + contactsUploaded2);
    	system.assertEquals(1, contactsUploaded2.size());
    	Contact test2 = contactsUploaded2.get(0);
    	system.assertEquals(tempContact.Email, test2.Email);
    	system.assertNotEquals(tempContact.LastName, test2.LastName);
    	system.assertNotEquals(tempContact.FirstName, test2.FirstName);
    	system.assertEquals(etlc1.EmailAddress, test2.Email);
    	system.assertEquals(etlc1.LastName, test2.LastName);
    	system.assertEquals(etlc1.FirstName, test2.FirstName);
   		system.assertEquals(etlc1.DateOfBirth, test2.Birthdate);
	    system.assertEquals(etlc1.Gender, test2.Gender__c);
	    system.assertEquals(etlc1.Over18YearsOld, test2.I_am_18_years_old_or_more__c);
	    system.assertEquals(etlc1.EmailOptOut, test2.HasOptedOutOfEmail);
	    system.assertEquals(etlc1.MobileOptOut, test2.Mobile_Opt_Out__c);
	    system.assertEquals(etlc1.PostalOptOut, test2.Postal_Opt_Out__c);
   		system.assertEquals(etlc1.ThirdPartyOptOut, test2.Other_Village_Partner_Opt_Out__c);
   		system.assertEquals(etlc1.ProfilingOptOut, test2.Profiling_Opt_Out__c);
   		system.assertEquals(etlc1.Address_Street, test2.MailingStreet);
   		system.assertEquals(etlc1.Address_City, test2.MailingCity);
   		system.assertEquals(etlc1.Address_State, test2.MailingState);
   		system.assertEquals(etlc1.Address_Country, test2.MailingCountry);
   		system.assertEquals(etlc1.Address_PostCode, test2.MailingPostalCode);
   		system.assertEquals(tempContact.MobilePhone, test2.MobilePhone);
   		system.assertNotEquals(etlc1.Mobile, test2.MobilePhone);
   		system.assertEquals(etlc1.CountryOfResidence, test2.Mailing_Country_In_English__c);
   		system.assertEquals(etlc1.Nationality, test2.Nationality_Picklist__c);
   		system.assertEquals(etlc1.PreferredLanguage, test2.Preferred_language_of_communication__c);
    	
    	List<Customer_Activity__c> activityList2 = [SELECT Id, Contact_Name__c, Touchpoint_Type__c, Activity_Date__c,
    											    Activity_Quantity__c, Activity_Text__c, Activity_Type__c,
    											    Activity_Value__c, Touchpoint_Reference__c, Touchpoint_Source__c,
    											    Campaign__c, Village__c
    											    FROM Customer_Activity__c
    											    WHERE Contact_Name__c = :dupeContactId2];	
    	system.debug('DUPE ACTIVITY LIST 2: ' + activityList2);
    	system.assertEquals(2, activityList2.size());

    	for (Customer_Activity__c ca2 : activityList2) {
    		system.assertEquals(testSettings.Activity_Type__c, ca2.Activity_Type__c);
    		if (ca2.Id != ca.Id) {
   				system.assertEquals(etlc1.TouchpointReference, ca2.Touchpoint_Reference__c);
   				system.assertEquals(etlc1.TouchpointType, ca2.Touchpoint_Type__c);
		   		system.assertEquals(etlc1.TouchpointSource, ca2.Touchpoint_Source__c);
   				system.assertEquals(etlc1.Activity_Date, ca2.Activity_Date__c);
		   		system.assertEquals(etlc1.Activity_Qty, ca2.Activity_Quantity__c);
   				system.assertEquals(etlc1.Activity_Text, ca2.Activity_Text__c);
		   		system.assertEquals(etlc1.Activity_Value, ca2.Activity_Value__c);
   				// system.assertEquals(etlc1.CampaignId, ca2.Campaign__c);
   				system.assertEquals(etlc1.TouchpointType, ca2.Touchpoint_Type__c);
		   		system.assertEquals(testVillage.Id, ca2.Village__c);
    		}
    	}
    	system.debug('TEST END: testDuplicateContactRegistration');
    }

    /**
     * Test contact registration with multiple duplicates.
     * Sets up 2 matching contacts on the system then tries to upsert a matching ETL record
     * INPUT: One ETLContactDTO record.
     * OUTCOME: Upsert fails.  No contact or customer activity records created.
     * RESULT: Failed with Multiple Matches status.
     */
    static testMethod void testMultiDuplicateContactRegistration() {
    	Properties.IS_TEST_METHOD = true;
    	system.debug('TEST START: testMultiDuplicateContactRegistration');
    	String testVillageName = 'TESTVILLAGE';
    	String testVillageCode = 'ZZ';
    	Village__c testVillage = new Village__c(Village_Code__c = testVillageCode, Name = testVillageName, Village_Local_Language__c = 'English');
    	insert testVillage;
    	system.debug('VILLAGE INSERTED: ' + testVillage.Id);
    	
    	User admUser = TestDataGenerator.setupAdminUser(false);
    	admUser.Campaign_Village__c = 'Chic Outlet Shopping;TESTVILLAGE';
    	insert admUser;
    	system.debug('ADMIN USER INSERTED: ' + admUser.Id);
    	
    	Account villageAccount = TestDataGenerator.setupB2CAccount(1, false);
    	villageAccount.Name = testVillageName;
    	villageAccount.Site = testVillageCode;
    	insert villageAccount;
    	system.debug('ACCOUNT INSERTED: ' + villageAccount.Id);
    	
    	ETLWebService_Settings__c testSettings = getTestETLSettings();
    	upsert testSettings;
    	
   		ETLContactDTO etlc1 = setupBasicETLContactDTO(1);
   		etlc1.Village = testVillageCode;
		Contact tempContact = TestDataGenerator.setupContact(1, villageAccount.Id, false);
		tempContact.Email = etlc1.EmailAddress;
		Contact tempContact2 = TestDataGenerator.setupContact(1, villageAccount.Id, false);
		tempContact2.Email = etlc1.EmailAddress;
		List<Contact> tempContactList = new List<Contact> {tempContact, tempContact2};
		insert tempContactList;
   		
    	List<ETLContactDTO> inList = new List<ETLContactDTO> {etlc1};
    	
    	test.startTest();
    	List<ETLContactResultDTO> outList = ETLWebService.contactRegistration(inList);
    	test.stopTest();

    	system.debug('MULTI DUPE OUTLIST: ' + outList);
    	system.assertEquals(1, outList.size());
    	ETLContactResultDTO dupeRes1 = outList.get(0);
   		system.assertEquals('Failed', dupeRes1.Result);
   		system.assertEquals('Multiple Matches', dupeRes1.Status);
   		system.assertEquals('Update', dupeRes1.ContactAction);
    	Id dupeContactId = dupeRes1.ContactId;
    	system.assertEquals(null, dupeContactId);
    	system.debug('TEST END: testMultiDuplicateContactRegistration');
    }
    
    /**
     * Test contact registration with invalid data.
     * INPUT: Five ETLContactDTO records - one valid, one with Last Name missing,
     *        one with disabled Touchpoint Type, one with invalid Touchpoint Type and one with no email.
     * OUTCOME: One success, four fails.
     * No contact or customer activity records created for any dodgy incoming ETL.
     * RESULT: One success, two Validation Errors, one Disabled Touchpoint error 
     *         and one Invalid Touchpoint Type error.
     */
    static testMethod void testInvalidContactRegistration() {
    	Properties.IS_TEST_METHOD = true;
    	system.debug('TEST START: testInvalidContactRegistration');
    	String testVillageName = 'TESTVILLAGE';
    	String testVillageCode = 'ZZ';
    	Village__c testVillage = new Village__c(Village_Code__c = testVillageCode, Name = testVillageName, Village_Local_Language__c = 'English');
    	insert testVillage;
    	system.debug('VILLAGE INSERTED: ' + testVillage.Id);
    	
    	User admUser = TestDataGenerator.setupAdminUser(false);
    	admUser.Campaign_Village__c = 'Chic Outlet Shopping;TESTVILLAGE';
    	insert admUser;
    	system.debug('ADMIN USER INSERTED: ' + admUser.Id);
    	
    	Account villageAccount = TestDataGenerator.setupB2CAccount(1, false);
    	villageAccount.Name = testVillageName;
    	villageAccount.Site = testVillageCode;
    	insert villageAccount;
    	system.debug('ACCOUNT INSERTED: ' + villageAccount.Id);
    	
    	ETLWebService_Settings__c testSettings = getTestETLSettings();
    	upsert testSettings;
    	ETLWebService_Settings__c testSettings2 = ETLWebService_Settings__c.getValues('Public Wifi');
    	if (testSettings2 == null) {
    		testSettings2 = new ETLWebService_Settings__c();
    		testSettings2.Name = 'Public Wifi';
    	}
    	testSettings2.Enabled__c = false;
    	testSettings2.Ignore_Duplicates__c = true;
    	testSettings2.Lead_Source__c = 'Other';
    	testSettings2.Activity_Type__c = 'Visitor';
    	testSettings2.Allow_Duplicate_Activity_Records__c = true;
    	testSettings2.Allow_Multiple_Activities_Per_Day__c = true;
    	upsert testSettings2;
    	
   		ETLContactDTO etlc1 = setupBasicETLContactDTO(1);
   		ETLContactDTO etlc2 = setupBasicETLContactDTO(2);
   		ETLContactDTO etlc3 = setupBasicETLContactDTO(3);
   		ETLContactDTO etlc4 = setupBasicETLContactDTO(4);
   		ETLContactDTO etlc5 = setupBasicETLContactDTO(5);
   		etlc1.LastName = null;
   		etlc1.Village = testVillageCode;
   		etlc2.Village = testVillageCode;
   		etlc3.TouchpointType = 'Public Wifi';
   		etlc3.Village = testVillageCode;
   		etlc4.TouchpointType = 'Wobble';
   		etlc4.Village = testVillageCode;
   		etlc5.EmailAddress = null;
   		etlc5.Village = testVillageCode;
    	List<ETLContactDTO> inList = new List<ETLContactDTO> {etlc1, etlc2, etlc3, etlc4, etlc5};
    	
    	test.startTest();
    	List<ETLContactResultDTO> outList = ETLWebService.contactRegistration(inList);
    	test.stopTest();
    	
    	system.debug('OUTLIST: ' + outList);
    	/*
    	system.assertEquals(1, outList.size());
    	ETLContactResultDTO res = outList.get(0);
   		system.assertEquals('Failed', res.Result);
   		system.assertEquals('System Error', res.Status);
   		system.assertEquals(null, res.ContactAction);
   		*/
    	system.assertEquals(5, outList.size());
    	for (ETLContactResultDTO res : outList) {
    		if (res.TouchpointReference == etlc1.TouchpointReference) {
		   		system.assertEquals('Failed', res.Result);
   				system.assertEquals('Validation Error', res.Status);
   				system.assert(res.Message.contains('Required fields are missing: [LastName]'));
    		} else if (res.TouchpointReference == etlc2.TouchpointReference) {
	    		system.assertEquals(etlc2.TouchpointReference, res.TouchpointReference);
	    		system.assertEquals('Completed', res.Result);
    			system.assertEquals('Success', res.Status);
    		} else if (res.TouchpointReference == etlc3.TouchpointReference) {
	    		system.assertEquals(etlc3.TouchpointReference, res.TouchpointReference);
	    		system.assertEquals('Failed', res.Result);
    			system.assertEquals('Touchpoint Type Disabled', res.Status);
    		} else if (res.TouchpointReference == etlc4.TouchpointReference) {
	    		system.assertEquals(etlc4.TouchpointReference, res.TouchpointReference);
	    		system.assertEquals('Failed', res.Result);
    			system.assertEquals('Invalid Touchpoint Type', res.Status);
    		} else if (res.TouchpointReference == etlc5.TouchpointReference) {
		   		system.assertEquals('Failed', res.Result);
   				system.assertEquals('Validation Error', res.Status);
   				system.assert(res.Message.contains('Email address is mandatory'));
    		} else {
    			system.assert(false);
    		}
   			system.assertEquals('New', res.ContactAction);
    	}
    	system.debug('TEST END: testInvalidContactRegistration');
    }
    
    /**
     * Test new contact registration with invalid picklist values.
     * INPUT: One ETLContactDTO record with invalid gender, country, nationality and language values.
     * OUTCOME: New contact created, with default values in those fields.
     * RESULT: Successful with Cleansed status.
     */
    static testMethod void testCleansedContactRegistration() {
    	Properties.IS_TEST_METHOD = true;
    	system.debug('TEST START: testCleansedContactRegistration');
    	String testVillageName = 'TESTVILLAGE';
    	String testVillageCode = 'ZZ';
    	Village__c testVillage = new Village__c(Village_Code__c = testVillageCode, Name = testVillageName, Village_Local_Language__c = 'English');
    	insert testVillage;
    	system.debug('VILLAGE INSERTED: ' + testVillage.Id);
    	
    	User admUser = TestDataGenerator.setupAdminUser(false);
    	admUser.Campaign_Village__c = 'Chic Outlet Shopping;TESTVILLAGE';
    	insert admUser;
    	system.debug('ADMIN USER INSERTED: ' + admUser.Id);
    	
    	Account villageAccount = TestDataGenerator.setupB2CAccount(1, false);
    	villageAccount.Name = testVillageName;
    	villageAccount.Site = testVillageCode;
    	insert villageAccount;
    	system.debug('ACCOUNT INSERTED: ' + villageAccount.Id);
    	
    	ETLWebService_Settings__c testSettings = getTestETLSettings();
    	upsert testSettings;
    	
   		ETLContactDTO etlc1 = setupBasicETLContactDTO(1);
   		etlc1.Gender = 'horse';
   		etlc1.PreferredLanguage = 'hairdo';
   		etlc1.CountryOfResidence = 'wonderland';
   		etlc1.Nationality = 'Martian';
   		etlc1.Village = testVillageCode;
   		etlc1.RegistrationDate = null;
    	List<ETLContactDTO> inList = new List<ETLContactDTO> {etlc1};
    	
    	test.startTest();
    	List<ETLContactResultDTO> outList = ETLWebService.contactRegistration(inList);
    	test.stopTest();
    	
    	system.debug('OUTLIST: ' + outList);
    	system.assertEquals(1, outList.size());
    	ETLContactResultDTO res = outList.get(0);
   		system.assertEquals('Completed', res.Result);
   		system.assertEquals('Cleansed', res.Status);
   		system.assertEquals('New', res.ContactAction);
   		Id contactId = res.ContactId;

    	List<Contact> contactsUploaded = [SELECT Id, FirstName, LastName, Email, AccountId, Gender__c,
    									  Preferred_language_of_communication__c, Mailing_Country_In_English__c,
    									  Original_Creation_Date__c
    									  FROM Contact
    									  WHERE Id = :contactId];

    	system.debug('CONTACT LIST: ' + contactsUploaded);
    	system.assertEquals(1, contactsUploaded.size());
    	Contact test1 = contactsUploaded.get(0);
    	system.assertEquals(etlc1.EmailAddress, test1.Email);
    	system.assertEquals(etlc1.LastName, test1.LastName);
    	system.assertEquals(etlc1.FirstName, test1.FirstName);
    	system.assertEquals(etlc1.EmailAddress, test1.Email);
    	system.assertEquals(system.today(), test1.Original_Creation_Date__c);
    	system.assertNotEquals(etlc1.Gender, test1.Gender__c);
    	system.assertNotEquals(etlc1.PreferredLanguage, test1.Preferred_language_of_communication__c);
    	system.assertNotEquals(etlc1.CountryOfResidence, test1.Mailing_Country_In_English__c);

    	system.debug('TEST END: testCleansedContactRegistration');
    }
	
    /**
     * Test three registrations - one new, one existing, one new with bogus campaign id.
     * All have campaigns on the incoming data.
     * INPUT: Two ETLContactDTO records.
     * OUTCOME: Two new contacts created, three customer activity records created, two CM records created.
     * RESULT: All updates successful but the third reports Campaign Member error.
     */
    static testMethod void testCampaignMemberRegistration() {
    	Properties.IS_TEST_METHOD = true;
    	system.debug('TEST START: testCampaignMemberRegistration');
    	String testVillageName = 'TESTVILLAGE';
    	String testVillageCode = 'ZZ';
    	Village__c testVillage = new Village__c(Village_Code__c = testVillageCode, Name = testVillageName, Village_Local_Language__c = 'English');
    	insert testVillage;
    	system.debug('VILLAGE INSERTED: ' + testVillage.Id);
    	
    	User admUser = TestDataGenerator.setupAdminUser(false);
    	admUser.Campaign_Village__c = 'Chic Outlet Shopping;TESTVILLAGE';
    	insert admUser;
    	system.debug('ADMIN USER INSERTED: ' + admUser.Id);
    	
    	Account villageAccount = TestDataGenerator.setupB2CAccount(1, false);
    	villageAccount.Name = testVillageName;
    	villageAccount.Site = testVillageCode;
    	insert villageAccount;
    	system.debug('ACCOUNT INSERTED: ' + villageAccount.Id);
    	
    	ETLWebService_Settings__c testSettings = getTestETLSettings();
    	upsert testSettings;

    	// Set up existing campaign
    	Campaign testCampaign = TestDataGenerator.setupCampaign(1, false);
    	testCampaign.Campaign_Member_Redemption_Count__c = 2;
    	insert testCampaign;
    	Campaign tc2 = [SELECT Id, B2C_Campaign_ID__c FROM Campaign WHERE Id = :testCampaign.Id LIMIT 1];

   		ETLContactDTO etlc1 = setupBasicETLContactDTO(1);
   		ETLContactDTO etlc2 = setupBasicETLContactDTO(2);
   		ETLContactDTO etlc3 = setupBasicETLContactDTO(3);
   		etlc1.Village = testVillageCode;
   		etlc1.CampaignId = tc2.B2C_Campaign_ID__c;
   		etlc2.Village = testVillageCode;
   		etlc2.CampaignId = tc2.B2C_Campaign_ID__c;
   		etlc3.Village = testVillageCode;
   		etlc3.CampaignId = 'RandomTestRubbish';
    	List<ETLContactDTO> inList = new List<ETLContactDTO> {etlc1, etlc2, etlc3};

		// Set up existing contact
		Contact tempContact = TestDataGenerator.setupContact(2, villageAccount.Id, false);
		tempContact.Email = etlc2.EmailAddress;
		insert tempContact;   		
    	
    	test.startTest();
    	List<ETLContactResultDTO> outList = ETLWebService.contactRegistration(inList);
    	test.stopTest();
    	
    	system.debug('OUTLIST: ' + outList);
    	system.assertEquals(3, outList.size());
    	
    	List<Id> contactIdList = new List<Id> ();
    	for (ETLContactResultDTO res : outList) {
    		contactIdList.add(res.ContactId);
    		system.assertEquals('Completed', res.Result);
    		if (res.TouchpointReference == etlc3.TouchpointReference) {
    			system.assertEquals('Campaign Member Error', res.Status);
    		} else {
    			system.assertEquals('Success', res.Status);
    		}
    		if (res.ContactId == tempContact.Id) {
    			system.assertEquals('Ignore', res.ContactAction);
    		} else {
    			system.assertEquals('New', res.ContactAction);
    		}
    	}
    	
    	List<Contact> contactsUploaded = [SELECT Id, FirstName, LastName, AccountId, Email, Gender__c, Birthdate,
    									  I_am_18_years_old_or_more__c, HasOptedOutOfEmail, Mobile_Opt_Out__c,
    									  Postal_Opt_Out__c, Other_Village_Partner_Opt_Out__c, Profiling_Opt_Out__c,
    									  Mailing_Country_In_English__c, Preferred_language_of_communication__c,
    									  Nationality_Picklist__c, MailingStreet, MailingCity, MailingState, MailingCountry,
    									  MailingPostalCode, MobilePhone, RecordTypeId, LeadSource, Lead_Source_Text__c,
    									  Original_Creation_Date__c, B2C_Password__c
    									  FROM Contact
    									  WHERE Id IN :contactIdList];
    	system.debug('CONTACT LIST: ' + contactsUploaded);
    	system.assertEquals(3, contactsUploaded.size());
    	
    	for (Contact c : contactsUploaded) {
    		if (c.Email == etlc1.EmailAddress) {
	    		system.assertEquals(etlc1.LastName, c.LastName);
	    		system.assertEquals(etlc1.FirstName, c.FirstName);
	    		system.assertEquals(etlc1.DateOfBirth, c.Birthdate);
	    		system.assertEquals(etlc1.Gender, c.Gender__c);
	    		system.assertEquals(etlc1.Over18YearsOld, c.I_am_18_years_old_or_more__c);
	    		system.assertEquals(etlc1.EmailOptOut, c.HasOptedOutOfEmail);
	    		system.assertEquals(etlc1.MobileOptOut, c.Mobile_Opt_Out__c);
	    		system.assertEquals(etlc1.PostalOptOut, c.Postal_Opt_Out__c);
	    		system.assertEquals(etlc1.ThirdPartyOptOut, c.Other_Village_Partner_Opt_Out__c);
	    		system.assertEquals(etlc1.ProfilingOptOut, c.Profiling_Opt_Out__c);
	    		system.assertEquals(etlc1.Address_Street, c.MailingStreet);
	    		system.assertEquals(etlc1.Address_City, c.MailingCity);
	    		system.assertEquals(etlc1.Address_State, c.MailingState);
	    		system.assertEquals(etlc1.Address_Country, c.MailingCountry);
	    		system.assertEquals(etlc1.Address_PostCode, c.MailingPostalCode);
	    		system.assertEquals(etlc1.Mobile, c.MobilePhone);
	    		system.assertEquals(etlc1.CountryOfResidence, c.Mailing_Country_In_English__c);
	    		system.assertEquals(etlc1.Nationality, c.Nationality_Picklist__c);
	    		system.assertEquals(etlc1.PreferredLanguage, c.Preferred_language_of_communication__c);
	    		system.assertEquals(etlc1.LeadSourceText, c.Lead_Source_Text__c);
	    		system.assertEquals(testSettings.Lead_Source__c, c.LeadSource);
	    		system.assertEquals(etlc1.RegistrationDate, c.Original_Creation_Date__c);
	    		system.assertEquals(etlc1.Password, c.B2C_Password__c);
    		} else if (c.Email == etlc2.EmailAddress) {
	    		system.assertEquals(null, c.MailingStreet);
	    		system.assertEquals(null, c.MailingCity);
	    		system.assertEquals(null, c.MailingState);
	    		system.assertEquals(null, c.MailingCountry);
	    		system.assertEquals(null, c.MailingPostalCode);
	    		system.assertEquals(null, c.MobilePhone);
	    		system.assertEquals('UNITED KINGDOM', c.Mailing_Country_In_English__c);
	    		system.assertEquals(null, c.Lead_Source_Text__c);
	    		system.assertNotEquals(testSettings.Lead_Source__c, c.LeadSource);
	    		system.assertNotEquals(etlc2.RegistrationDate, c.Original_Creation_Date__c);
	    		system.assertNotEquals(etlc2.Password, c.B2C_Password__c);
    		} else if (c.Email == etlc3.EmailAddress) {
	    		system.assertEquals(etlc3.LastName, c.LastName);
	    		system.assertEquals(etlc3.FirstName, c.FirstName);
	    		system.assertEquals(etlc3.DateOfBirth, c.Birthdate);
	    		system.assertEquals(etlc3.Gender, c.Gender__c);
	    		system.assertEquals(etlc3.Over18YearsOld, c.I_am_18_years_old_or_more__c);
	    		system.assertEquals(etlc3.EmailOptOut, c.HasOptedOutOfEmail);
	    		system.assertEquals(etlc3.MobileOptOut, c.Mobile_Opt_Out__c);
	    		system.assertEquals(etlc3.PostalOptOut, c.Postal_Opt_Out__c);
	    		system.assertEquals(etlc3.ThirdPartyOptOut, c.Other_Village_Partner_Opt_Out__c);
	    		system.assertEquals(etlc3.ProfilingOptOut, c.Profiling_Opt_Out__c);
	    		system.assertEquals(etlc3.Address_Street, c.MailingStreet);
	    		system.assertEquals(etlc3.Address_City, c.MailingCity);
	    		system.assertEquals(etlc3.Address_State, c.MailingState);
	    		system.assertEquals(etlc3.Address_Country, c.MailingCountry);
	    		system.assertEquals(etlc3.Address_PostCode, c.MailingPostalCode);
	    		system.assertEquals(etlc3.Mobile, c.MobilePhone);
	    		system.assertEquals(etlc3.CountryOfResidence, c.Mailing_Country_In_English__c);
	    		system.assertEquals(etlc3.Nationality, c.Nationality_Picklist__c);
	    		system.assertEquals(etlc3.PreferredLanguage, c.Preferred_language_of_communication__c);
	    		system.assertEquals(etlc3.LeadSourceText, c.Lead_Source_Text__c);
	    		system.assertEquals(testSettings.Lead_Source__c, c.LeadSource);
	    		system.assertEquals(etlc3.RegistrationDate, c.Original_Creation_Date__c);
	    		system.assertEquals(etlc3.Password, c.B2C_Password__c);
    		} else {
    			system.assert(false); // Shouldn't ever go here.
    		}
    	}
    	
    	List<Customer_Activity__c> activityList = [SELECT Id, Contact_Name__c, Touchpoint_Type__c, Activity_Date__c,
    											   Activity_Quantity__c, Activity_Text__c, Activity_Type__c,
    											   Activity_Value__c, Touchpoint_Reference__c, Touchpoint_Source__c,
    											   Campaign__c, Village__c
    											   FROM Customer_Activity__c
    											   WHERE Contact_Name__c IN :contactIdList];	
    	system.debug('ACTIVITY LIST: ' + activityList);
    	system.assertEquals(3, activityList.size());

    	for (Customer_Activity__c ca : activityList) {
    		system.assertEquals(testSettings.Activity_Type__c, ca.Activity_Type__c);
    		if (ca.Touchpoint_Reference__c == etlc1.TouchpointReference) {
	    		system.assertEquals(etlc1.TouchpointType, ca.Touchpoint_Type__c);
	    		system.assertEquals(etlc1.TouchpointSource, ca.Touchpoint_Source__c);
	    		system.assertEquals(etlc1.Activity_Date, ca.Activity_Date__c);
	    		system.assertEquals(etlc1.Activity_Qty, ca.Activity_Quantity__c);
	    		system.assertEquals(etlc1.Activity_Text, ca.Activity_Text__c);
	    		system.assertEquals(etlc1.Activity_Value, ca.Activity_Value__c);
	    		system.assertEquals(etlc1.TouchpointType, ca.Touchpoint_Type__c);
	    		system.assertEquals(testVillage.Id, ca.Village__c);
    		} else if (ca.Touchpoint_Reference__c == etlc2.TouchpointReference) {
	    		system.assertEquals(etlc2.TouchpointType, ca.Touchpoint_Type__c);
	    		system.assertEquals(etlc2.TouchpointSource, ca.Touchpoint_Source__c);
	    		system.assertEquals(etlc2.Activity_Date, ca.Activity_Date__c);
	    		system.assertEquals(etlc2.Activity_Qty, ca.Activity_Quantity__c);
	    		system.assertEquals(etlc2.Activity_Text, ca.Activity_Text__c);
	    		system.assertEquals(etlc2.Activity_Value, ca.Activity_Value__c);
	    		system.assertEquals(etlc2.TouchpointType, ca.Touchpoint_Type__c);
	    		system.assertEquals(testVillage.Id, ca.Village__c);
    		} else if (ca.Touchpoint_Reference__c == etlc3.TouchpointReference) {
	    		system.assertEquals(etlc3.TouchpointType, ca.Touchpoint_Type__c);
	    		system.assertEquals(etlc3.TouchpointSource, ca.Touchpoint_Source__c);
	    		system.assertEquals(etlc3.Activity_Date, ca.Activity_Date__c);
	    		system.assertEquals(etlc3.Activity_Qty, ca.Activity_Quantity__c);
	    		system.assertEquals(etlc3.Activity_Text, ca.Activity_Text__c);
	    		system.assertEquals(etlc3.Activity_Value, ca.Activity_Value__c);
	    		system.assertEquals(etlc3.TouchpointType, ca.Touchpoint_Type__c);
	    		system.assertEquals(testVillage.Id, ca.Village__c);
    		}
    	}
    	
    	List<CampaignMember> cmList = [SELECT Id, CampaignId, ContactId FROM CampaignMember WHERE CampaignId = :tc2.Id];
    	system.debug('CM LIST: ' + cmList);
    	system.assertEquals(2, cmList.size());

    	for (CampaignMember cm : cmList) {
    		system.assert(cm.ContactId == contactsUploaded.get(0).Id || cm.ContactId == contactsUploaded.get(1).Id);
    	}
    	
    	system.debug('TEST END: testCampaignMemberRegistration');
    }

    /**
     * Input one campaign registration and then process it again.  Ensure that duplicate CM error is reported.
     * INPUT: One ETLContactDTO record processed twice.
     * OUTCOME: One new contact created, two customer activity records created, one CM record created.
     * RESULT: Both updates successful.
     */
    static testMethod void testCampaignMemberDuplicateRegistration() {
    	Properties.IS_TEST_METHOD = true;
    	system.debug('TEST START: testCampaignMemberDuplicateRegistration');
    	String testVillageName = 'TESTVILLAGE';
    	String testVillageCode = 'ZZ';
    	Village__c testVillage = new Village__c(Village_Code__c = testVillageCode, Name = testVillageName, Village_Local_Language__c = 'English');
    	insert testVillage;
    	system.debug('VILLAGE INSERTED: ' + testVillage.Id);
    	
    	User admUser = TestDataGenerator.setupAdminUser(false);
    	admUser.Campaign_Village__c = 'Chic Outlet Shopping;TESTVILLAGE';
    	insert admUser;
    	system.debug('ADMIN USER INSERTED: ' + admUser.Id);
    	
    	Account villageAccount = TestDataGenerator.setupB2CAccount(1, false);
    	villageAccount.Name = testVillageName;
    	villageAccount.Site = testVillageCode;
    	insert villageAccount;
    	system.debug('ACCOUNT INSERTED: ' + villageAccount.Id);
    	
    	ETLWebService_Settings__c testSettings = getTestETLSettings();
    	upsert testSettings;

    	// Set up existing campaign
    	Campaign testCampaign = TestDataGenerator.setupCampaign(1, false);
    	testCampaign.Campaign_Member_Redemption_Count__c = 2;
    	insert testCampaign;
    	Campaign tc2 = [SELECT Id, B2C_Campaign_ID__c FROM Campaign WHERE Id = :testCampaign.Id LIMIT 1];

   		ETLContactDTO etlc1 = setupBasicETLContactDTO(1);
   		etlc1.Village = testVillageCode;
   		etlc1.CampaignId = tc2.B2C_Campaign_ID__c;
    	List<ETLContactDTO> inList = new List<ETLContactDTO> {etlc1};

    	test.startTest();
    	List<ETLContactResultDTO> outList1 = ETLWebService.contactRegistration(inList);
    	List<ETLContactResultDTO> outList2 = ETLWebService.contactRegistration(inList);
    	test.stopTest();
    	
    	system.debug('OUTLIST1: ' + outList1);
    	system.debug('OUTLIST2: ' + outList2);
    	system.assertEquals(1, outList1.size());
    	system.assertEquals(1, outList2.size());
    	ETLContactResultDTO res1 = outList1.get(0);
    	ETLContactResultDTO res2 = outList2.get(0);

   		system.assertEquals('Completed', res1.Result);
   		system.assertEquals('Success', res1.Status);
   		system.assertEquals('Completed', res2.Result);
   		system.assertEquals('Campaign Member Error', res2.Status);
   		system.assertEquals(res1.ContactId, res2.ContactId);
   		
    	List<Contact> contactsUploaded = [SELECT Id, FirstName, LastName, AccountId, Email, Gender__c, Birthdate,
    									  I_am_18_years_old_or_more__c, HasOptedOutOfEmail, Mobile_Opt_Out__c,
    									  Postal_Opt_Out__c, Other_Village_Partner_Opt_Out__c, Profiling_Opt_Out__c,
    									  Mailing_Country_In_English__c, Preferred_language_of_communication__c,
    									  Nationality_Picklist__c, MailingStreet, MailingCity, MailingState, MailingCountry,
    									  MailingPostalCode, MobilePhone, RecordTypeId, LeadSource, Lead_Source_Text__c,
    									  Original_Creation_Date__c, B2C_Password__c
    									  FROM Contact
    									  WHERE Id = :res1.ContactId];
    	system.debug('CONTACT LIST: ' + contactsUploaded);
    	system.assertEquals(1, contactsUploaded.size());
    	
    	Contact c = contactsUploaded.get(0);
   		system.assertEquals(etlc1.LastName, c.LastName);
   		system.assertEquals(etlc1.FirstName, c.FirstName);
   		system.assertEquals(etlc1.DateOfBirth, c.Birthdate);
   		system.assertEquals(etlc1.Gender, c.Gender__c);
   		system.assertEquals(etlc1.Over18YearsOld, c.I_am_18_years_old_or_more__c);
   		system.assertEquals(etlc1.EmailOptOut, c.HasOptedOutOfEmail);
   		system.assertEquals(etlc1.MobileOptOut, c.Mobile_Opt_Out__c);
   		system.assertEquals(etlc1.PostalOptOut, c.Postal_Opt_Out__c);
   		system.assertEquals(etlc1.ThirdPartyOptOut, c.Other_Village_Partner_Opt_Out__c);
   		system.assertEquals(etlc1.ProfilingOptOut, c.Profiling_Opt_Out__c);
   		system.assertEquals(etlc1.Address_Street, c.MailingStreet);
   		system.assertEquals(etlc1.Address_City, c.MailingCity);
   		system.assertEquals(etlc1.Address_State, c.MailingState);
   		system.assertEquals(etlc1.Address_Country, c.MailingCountry);
   		system.assertEquals(etlc1.Address_PostCode, c.MailingPostalCode);
   		system.assertEquals(etlc1.Mobile, c.MobilePhone);
   		system.assertEquals(etlc1.CountryOfResidence, c.Mailing_Country_In_English__c);
   		system.assertEquals(etlc1.Nationality, c.Nationality_Picklist__c);
   		system.assertEquals(etlc1.PreferredLanguage, c.Preferred_language_of_communication__c);
   		system.assertEquals(etlc1.LeadSourceText, c.Lead_Source_Text__c);
   		system.assertEquals(testSettings.Lead_Source__c, c.LeadSource);
   		system.assertEquals(etlc1.RegistrationDate, c.Original_Creation_Date__c);
   		system.assertEquals(etlc1.Password, c.B2C_Password__c);
    	
    	List<Customer_Activity__c> activityList = [SELECT Id, Contact_Name__c, Touchpoint_Type__c, Activity_Date__c,
    											   Activity_Quantity__c, Activity_Text__c, Activity_Type__c,
    											   Activity_Value__c, Touchpoint_Reference__c, Touchpoint_Source__c,
    											   Campaign__c, Village__c
    											   FROM Customer_Activity__c
    											   WHERE Contact_Name__c = :res1.ContactId];	
    	system.debug('ACTIVITY LIST: ' + activityList);
    	system.assertEquals(2, activityList.size());

    	for (Customer_Activity__c ca : activityList) {
    		system.assertEquals(testSettings.Activity_Type__c, ca.Activity_Type__c);
    		system.assertEquals(etlc1.TouchpointType, ca.Touchpoint_Type__c);
    		system.assertEquals(etlc1.TouchpointSource, ca.Touchpoint_Source__c);
    		system.assertEquals(etlc1.Activity_Date, ca.Activity_Date__c);
    		system.assertEquals(etlc1.Activity_Qty, ca.Activity_Quantity__c);
    		system.assertEquals(etlc1.Activity_Text, ca.Activity_Text__c);
    		system.assertEquals(etlc1.Activity_Value, ca.Activity_Value__c);
    		system.assertEquals(etlc1.TouchpointType, ca.Touchpoint_Type__c);
    		system.assertEquals(tc2.Id, ca.Campaign__c);
    		system.assertEquals(testVillage.Id, ca.Village__c);
    	}
    	
    	List<CampaignMember> cmList = [SELECT Id, CampaignId, ContactId FROM CampaignMember WHERE CampaignId = :tc2.Id];
    	system.debug('CM LIST: ' + cmList);
    	system.assertEquals(1, cmList.size());
   		system.assertEquals(c.Id, cmList.get(0).ContactId);
    	
    	system.debug('TEST END: testCampaignMemberDuplicateRegistration');
    }

    /**
     * Test large batch of contact registrations.
     * INPUT: nn ETLContactDTO records.
     * OUTCOME: nn new contacts created, nn customer activity records created.
     * RESULT: All inserts successful.
     */
    static testMethod void testBatchContactRegistration() {
    	Integer BATCH_SIZE = 200;
    	Properties.IS_TEST_METHOD = true;
    	system.debug('TEST START: testBatchContactRegistration');
    	String testVillageName = 'TESTVILLAGE';
    	String testVillageCode = 'ZZ';
    	Village__c testVillage = new Village__c(Village_Code__c = testVillageCode, Name = testVillageName, Village_Local_Language__c = 'English');
    	insert testVillage;
    	system.debug('VILLAGE INSERTED: ' + testVillage.Id);
    	
    	User admUser = TestDataGenerator.setupAdminUser(false);
    	admUser.Campaign_Village__c = 'Chic Outlet Shopping;TESTVILLAGE';
    	insert admUser;
    	system.debug('ADMIN USER INSERTED: ' + admUser.Id);
    	
    	Account villageAccount = TestDataGenerator.setupB2CAccount(1, false);
    	villageAccount.Name = testVillageName;
    	villageAccount.Site = testVillageCode;
    	insert villageAccount;
    	system.debug('ACCOUNT INSERTED: ' + villageAccount.Id);
    	
    	ETLWebService_Settings__c testSettings = getTestETLSettings();
    	upsert testSettings;
    	
    	List<ETLContactDTO> inList = new List<ETLContactDTO> ();
    	
    	for (Integer i = 1; i <= BATCH_SIZE; i++) {
    		ETLContactDTO tempETL = setupBasicETLContactDTO(i);
   			tempETL.Village = testVillageCode;
    		inList.add(tempETL);
    	}
    	
    	system.assertEquals(BATCH_SIZE, inList.size());
   		
    	test.startTest();
    	List<ETLContactResultDTO> outList = ETLWebService.contactRegistration(inList);
    	test.stopTest();
    	
    	system.assertEquals(BATCH_SIZE, outList.size());
    	
    	List<Id> contactIdList = new List<Id> ();
    	for (ETLContactResultDTO res : outList) {
    		contactIdList.add(res.ContactId);
    		system.assertEquals('Completed', res.Result);
    		system.assertEquals('Success', res.Status);
    		system.assertEquals('New', res.ContactAction);
    	}
    	
    	List<Contact> contactsUploaded = [SELECT Id, FirstName, LastName, AccountId, Email, Gender__c, Birthdate,
    									  I_am_18_years_old_or_more__c, HasOptedOutOfEmail, Mobile_Opt_Out__c,
    									  Postal_Opt_Out__c, Other_Village_Partner_Opt_Out__c, Profiling_Opt_Out__c,
    									  Mailing_Country_In_English__c, Preferred_language_of_communication__c,
    									  Nationality_Picklist__c, MailingStreet, MailingCity, MailingState, MailingCountry,
    									  MailingPostalCode, MobilePhone, RecordTypeId, LeadSource, Lead_Source_Text__c,
    									  Original_Creation_Date__c, B2C_Password__c
    									  FROM Contact
    									  WHERE Id IN :contactIdList];

    	system.assertEquals(BATCH_SIZE, contactsUploaded.size());
    	
    	List<Customer_Activity__c> activityList = [SELECT Id, Contact_Name__c, Touchpoint_Type__c, Activity_Date__c,
    											   Activity_Quantity__c, Activity_Text__c, Activity_Type__c,
    											   Activity_Value__c, Touchpoint_Reference__c, Touchpoint_Source__c,
    											   Campaign__c, Village__c
    											   FROM Customer_Activity__c
    											   WHERE Contact_Name__c IN :contactIdList];	

    	system.assertEquals(BATCH_SIZE, activityList.size());

    	system.debug('TEST END: testBatchContactRegistration');
    }

    /**
     * Test large batch of contact registrations, many of which are duplicates.
     * INPUT: nn ETLContactDTO records, xx of which are duplicates.
     * OUTCOME: nn - xx new contacts created, nn customer activity records created.
     * RESULT: All results successful.
     */
    static testMethod void testBatchDuplicateContactRegistration() {
    	Properties.IS_TEST_METHOD = true;
    	Integer BATCH_SIZE = 200;
    	Integer DUPLICATE_NUMBER = 100;

    	system.debug('TEST START: testBatchDuplicateContactRegistration');
    	String testVillageName = 'TESTVILLAGE';
    	String testVillageCode = 'ZZ';
    	Village__c testVillage = new Village__c(Village_Code__c = testVillageCode, Name = testVillageName, Village_Local_Language__c = 'English');
    	insert testVillage;
    	system.debug('VILLAGE INSERTED: ' + testVillage.Id);
    	
    	User admUser = TestDataGenerator.setupAdminUser(false);
    	admUser.Campaign_Village__c = 'Chic Outlet Shopping;TESTVILLAGE';
    	insert admUser;
    	system.debug('ADMIN USER INSERTED: ' + admUser.Id);
    	
    	Account villageAccount = TestDataGenerator.setupB2CAccount(1, false);
    	villageAccount.Name = testVillageName;
    	villageAccount.Site = testVillageCode;
    	insert villageAccount;
    	system.debug('ACCOUNT INSERTED: ' + villageAccount.Id);
    	
    	ETLWebService_Settings__c testSettings = getTestETLSettings();
    	upsert testSettings;
    	
    	List<ETLContactDTO> inList = new List<ETLContactDTO> ();
    	
    	for (Integer i = 1; i <= BATCH_SIZE; i++) {
    		ETLContactDTO tempETL = setupBasicETLContactDTO(i);
   			tempETL.Village = testVillageCode;
    		inList.add(tempETL);
    	}
    	
    	system.assertEquals(BATCH_SIZE, inList.size());
   		
    	List<Contact> dupeList = new List<Contact> ();

    	for (Integer i = 1; i <= DUPLICATE_NUMBER; i++) {
    		Integer pos = i - 1;
    		Contact c = TestDataGenerator.setupContact(i, villageAccount.Id, false);
    		ETLContactDTO twin = inList.get(pos);
    		c.Email = twin.EmailAddress;
    		dupeList.add(c);
    	}

    	system.assertEquals(DUPLICATE_NUMBER, dupeList.size());
    	
    	insert dupeList;
		
    	test.startTest();
    	List<ETLContactResultDTO> outList = ETLWebService.contactRegistration(inList);
    	test.stopTest();
    	
    	system.assertEquals(BATCH_SIZE, outList.size());
    	
    	List<Id> contactIdList = new List<Id> ();
    	Integer pos2 = 1;
    	for (ETLContactResultDTO res : outList) {
    		system.debug('PROCESSING POS: ' + pos2);
    		contactIdList.add(res.ContactId);
    		if (pos2 <= DUPLICATE_NUMBER) {
    			system.assertEquals('Completed', res.Result);
    			system.assertEquals('Success', res.Status);
    			system.assertEquals('Ignore', res.ContactAction);
    		} else {
    			system.assertEquals('Completed', res.Result);
    			system.assertEquals('Success', res.Status);
    			system.assertEquals('New', res.ContactAction);
    		}
    		pos2++;
    	}
    	
    	List<Contact> contactsUploaded = [SELECT Id, FirstName, LastName, AccountId, Email, Gender__c, Birthdate,
    									  I_am_18_years_old_or_more__c, HasOptedOutOfEmail, Mobile_Opt_Out__c,
    									  Postal_Opt_Out__c, Other_Village_Partner_Opt_Out__c, Profiling_Opt_Out__c,
    									  Mailing_Country_In_English__c, Preferred_language_of_communication__c,
    									  Nationality_Picklist__c, MailingStreet, MailingCity, MailingState, MailingCountry,
    									  MailingPostalCode, MobilePhone, RecordTypeId, LeadSource, Lead_Source_Text__c,
    									  Original_Creation_Date__c, B2C_Password__c
    									  FROM Contact
    									  WHERE Id IN :contactIdList];

    	system.assertEquals(BATCH_SIZE, contactsUploaded.size());
    	
    	List<Customer_Activity__c> activityList = [SELECT Id, Contact_Name__c, Touchpoint_Type__c, Activity_Date__c,
    											   Activity_Quantity__c, Activity_Text__c, Activity_Type__c,
    											   Activity_Value__c, Touchpoint_Reference__c, Touchpoint_Source__c,
    											   Campaign__c, Village__c
    											   FROM Customer_Activity__c
    											   WHERE Contact_Name__c IN :contactIdList];	

    	system.assertEquals(BATCH_SIZE, activityList.size());

    	system.debug('TEST END: testBatchDuplicateContactRegistration');
    }

    /**
     * Test duplicate Customer Activity logic
     * INPUT: Two ETLContactDTO records, submitted with various settings
     * OUTCOME: Various
     * RESULT: 
     */
    static testMethod void testDuplicateCustomerActivity() {
    	Properties.IS_TEST_METHOD = true;
    	system.debug('TEST START: testDuplicateCustomerActivity');
    	String testVillageName = 'TESTVILLAGE';
    	String testVillageCode = 'ZZ';
    	Village__c testVillage = new Village__c(Village_Code__c = testVillageCode, Name = testVillageName, Village_Local_Language__c = 'English');
    	insert testVillage;
    	system.debug('VILLAGE INSERTED: ' + testVillage.Id);
    	
    	User admUser = TestDataGenerator.setupAdminUser(false);
    	admUser.Campaign_Village__c = 'Chic Outlet Shopping;TESTVILLAGE';
    	insert admUser;
    	system.debug('ADMIN USER INSERTED: ' + admUser.Id);
    	
    	Account villageAccount = TestDataGenerator.setupB2CAccount(1, false);
    	villageAccount.Name = testVillageName;
    	villageAccount.Site = testVillageCode;
    	insert villageAccount;
    	system.debug('ACCOUNT INSERTED: ' + villageAccount.Id);
    	
    	ETLWebService_Settings__c testSettings = getTestETLSettings();
    	testSettings.Allow_Duplicate_Activity_Records__c = false;
    	testSettings.Allow_Multiple_Activities_Per_Day__c = false;
    	upsert testSettings;
    	
   		ETLContactDTO etlc1 = setupBasicETLContactDTO(1);
   		ETLContactDTO etlc2 = setupBasicETLContactDTO(2);
   		etlc1.Village = testVillageCode;
   		etlc2.Village = testVillageCode;
    	List<ETLContactDTO> inList = new List<ETLContactDTO> {etlc1};
    	DateTime originalActDate = etlc1.Activity_Date;
    	system.debug('ETLC1 ACTIVITY DATE 1: ' + etlc1.Activity_Date);
    	
    	List<ETLContactResultDTO> outList1 = ETLWebService.contactRegistration(inList);
    	
    	system.assertEquals(1, outList1.size());
    	system.debug('OUTLIST 1: ' + outList1);
    	
    	List<Id> contactIdList = new List<Id> ();
    	for (ETLContactResultDTO res : outList1) {
    		contactIdList.add(res.ContactId);
    		system.assertEquals('Completed', res.Result);
    		system.assertEquals('Success', res.Status);
    		system.assertEquals('New', res.ContactAction);
    	}
    	
    	List<Contact> contactsUploaded1 = [SELECT Id, FirstName, LastName, AccountId, Email, Gender__c, Birthdate,
    									   I_am_18_years_old_or_more__c, HasOptedOutOfEmail, Mobile_Opt_Out__c,
    									   Postal_Opt_Out__c, Other_Village_Partner_Opt_Out__c, Profiling_Opt_Out__c,
    									   Mailing_Country_In_English__c, Preferred_language_of_communication__c,
    									   Nationality_Picklist__c, MailingStreet, MailingCity, MailingState, MailingCountry,
    									   MailingPostalCode, MobilePhone, RecordTypeId, LeadSource, Lead_Source_Text__c,
    									   Original_Creation_Date__c, B2C_Password__c
    									   FROM Contact
    									   WHERE Id IN :contactIdList];
    	system.debug('CONTACT LIST 1: ' + contactsUploaded1);
    	system.assertEquals(1, contactsUploaded1.size());
    	
    	Contact c = contactsUploaded1.get(0);
   		system.assertEquals(etlc1.LastName, c.LastName);
   		system.assertEquals(etlc1.FirstName, c.FirstName);
   		system.assertEquals(etlc1.DateOfBirth, c.Birthdate);
   		system.assertEquals(etlc1.Gender, c.Gender__c);
   		system.assertEquals(etlc1.Over18YearsOld, c.I_am_18_years_old_or_more__c);
   		system.assertEquals(etlc1.EmailOptOut, c.HasOptedOutOfEmail);
   		system.assertEquals(etlc1.MobileOptOut, c.Mobile_Opt_Out__c);
   		system.assertEquals(etlc1.PostalOptOut, c.Postal_Opt_Out__c);
   		system.assertEquals(etlc1.ThirdPartyOptOut, c.Other_Village_Partner_Opt_Out__c);
   		system.assertEquals(etlc1.ProfilingOptOut, c.Profiling_Opt_Out__c);
   		system.assertEquals(etlc1.Address_Street, c.MailingStreet);
   		system.assertEquals(etlc1.Address_City, c.MailingCity);
   		system.assertEquals(etlc1.Address_State, c.MailingState);
   		system.assertEquals(etlc1.Address_Country, c.MailingCountry);
   		system.assertEquals(etlc1.Address_PostCode, c.MailingPostalCode);
   		system.assertEquals(etlc1.Mobile, c.MobilePhone);
   		system.assertEquals(etlc1.CountryOfResidence, c.Mailing_Country_In_English__c);
   		system.assertEquals(etlc1.Nationality, c.Nationality_Picklist__c);
   		system.assertEquals(etlc1.PreferredLanguage, c.Preferred_language_of_communication__c);
   		system.assertEquals(etlc1.LeadSourceText, c.Lead_Source_Text__c);
   		system.assertEquals(testSettings.Lead_Source__c, c.LeadSource);
   		system.assertEquals(etlc1.RegistrationDate, c.Original_Creation_Date__c);
   		system.assertEquals(etlc1.Password, c.B2C_Password__c);
    	
    	List<Customer_Activity__c> activityList1 = [SELECT Id, Contact_Name__c, Touchpoint_Type__c, Activity_Date__c,
    											    Activity_Quantity__c, Activity_Text__c, Activity_Type__c,
    											    Activity_Value__c, Touchpoint_Reference__c, Touchpoint_Source__c,
    											    Campaign__c, Village__c
    											    FROM Customer_Activity__c
    											    WHERE Contact_Name__c IN :contactIdList];	
    	system.debug('ACTIVITY LIST 1: ' + activityList1);
    	system.assertEquals(1, activityList1.size());

    	Customer_Activity__c ca = activityList1.get(0);
   		system.assertEquals(testSettings.Activity_Type__c, ca.Activity_Type__c);
   		system.assertEquals(etlc1.TouchpointReference, ca.Touchpoint_Reference__c);
   		system.assertEquals(etlc1.TouchpointType, ca.Touchpoint_Type__c);
   		system.assertEquals(etlc1.TouchpointSource, ca.Touchpoint_Source__c);
   		system.assertEquals(originalActDate, ca.Activity_Date__c);
   		system.assertEquals(etlc1.Activity_Qty, ca.Activity_Quantity__c);
   		system.assertEquals(etlc1.Activity_Text, ca.Activity_Text__c);
   		system.assertEquals(etlc1.Activity_Value, ca.Activity_Value__c);
   		system.assertEquals(testVillage.Id, ca.Village__c);
   		
   		etlc1.Activity_Date = etlc1.Activity_Date.addMinutes(10);
    	system.debug('ETLC1 ACTIVITY DATE 2: ' + etlc1.Activity_Date);
   		inList.add(etlc2);
    	system.debug('INLIST 2: ' + inList);

    	test.startTest();
    	List<ETLContactResultDTO> outList2 = ETLWebService.contactRegistration(inList);
    	test.stopTest();

    	system.assertEquals(2, outList2.size());
    	system.debug('OUTLIST 2: ' + outList2);
    	
    	for (ETLContactResultDTO res : outList2) {
    		if (res.ContactId == c.Id) {
	    		system.assertEquals('Completed', res.Result);
    			system.assertEquals('Duplicate Customer Activity Ignored', res.Status);
    			system.assertEquals('Ignore', res.ContactAction);
    		} else {
	    		contactIdList.add(res.ContactId);
	    		system.assertEquals('Completed', res.Result);
    			system.assertEquals('Success', res.Status);
    			system.assertEquals('New', res.ContactAction);
    		}
    	}
    	
    	List<Contact> contactsUploaded2 = [SELECT Id, FirstName, LastName, AccountId, Email, Gender__c, Birthdate,
    									   I_am_18_years_old_or_more__c, HasOptedOutOfEmail, Mobile_Opt_Out__c,
    									   Postal_Opt_Out__c, Other_Village_Partner_Opt_Out__c, Profiling_Opt_Out__c,
    									   Mailing_Country_In_English__c, Preferred_language_of_communication__c,
    									   Nationality_Picklist__c, MailingStreet, MailingCity, MailingState, MailingCountry,
    									   MailingPostalCode, MobilePhone, RecordTypeId, LeadSource, Lead_Source_Text__c,
    									   Original_Creation_Date__c, B2C_Password__c
    									   FROM Contact
    									   WHERE Id IN :contactIdList];
    	system.debug('CONTACT LIST 2: ' + contactsUploaded2);
    	system.assertEquals(2, contactsUploaded2.size());
    	
    	for (Contact c2 : contactsUploaded2) {
    		if (c2.Email == etlc1.EmailAddress) {
	    		system.assertEquals(etlc1.LastName, c2.LastName);
	    		system.assertEquals(etlc1.FirstName, c2.FirstName);
	    		system.assertEquals(etlc1.DateOfBirth, c2.Birthdate);
	    		system.assertEquals(etlc1.Gender, c2.Gender__c);
	    		system.assertEquals(etlc1.Over18YearsOld, c2.I_am_18_years_old_or_more__c);
	    		system.assertEquals(etlc1.EmailOptOut, c2.HasOptedOutOfEmail);
	    		system.assertEquals(etlc1.MobileOptOut, c2.Mobile_Opt_Out__c);
	    		system.assertEquals(etlc1.PostalOptOut, c2.Postal_Opt_Out__c);
	    		system.assertEquals(etlc1.ThirdPartyOptOut, c2.Other_Village_Partner_Opt_Out__c);
	    		system.assertEquals(etlc1.ProfilingOptOut, c2.Profiling_Opt_Out__c);
	    		system.assertEquals(etlc1.Address_Street, c2.MailingStreet);
	    		system.assertEquals(etlc1.Address_City, c2.MailingCity);
	    		system.assertEquals(etlc1.Address_State, c2.MailingState);
	    		system.assertEquals(etlc1.Address_Country, c2.MailingCountry);
	    		system.assertEquals(etlc1.Address_PostCode, c2.MailingPostalCode);
	    		system.assertEquals(etlc1.Mobile, c2.MobilePhone);
	    		system.assertEquals(etlc1.CountryOfResidence, c2.Mailing_Country_In_English__c);
	    		system.assertEquals(etlc1.Nationality, c2.Nationality_Picklist__c);
	    		system.assertEquals(etlc1.PreferredLanguage, c2.Preferred_language_of_communication__c);
	    		system.assertEquals(etlc1.LeadSourceText, c2.Lead_Source_Text__c);
	    		system.assertEquals(testSettings.Lead_Source__c, c2.LeadSource);
	    		system.assertEquals(etlc1.RegistrationDate, c2.Original_Creation_Date__c);
	    		system.assertEquals(etlc1.Password, c2.B2C_Password__c);
    		} else if (c2.Email == etlc2.EmailAddress) {
	    		system.assertEquals(etlc2.LastName, c2.LastName);
	    		system.assertEquals(etlc2.FirstName, c2.FirstName);
	    		system.assertEquals(etlc2.DateOfBirth, c2.Birthdate);
	    		system.assertEquals(etlc2.Gender, c2.Gender__c);
	    		system.assertEquals(etlc2.Over18YearsOld, c2.I_am_18_years_old_or_more__c);
	    		system.assertEquals(etlc2.EmailOptOut, c2.HasOptedOutOfEmail);
	    		system.assertEquals(etlc2.MobileOptOut, c2.Mobile_Opt_Out__c);
	    		system.assertEquals(etlc2.PostalOptOut, c2.Postal_Opt_Out__c);
	    		system.assertEquals(etlc2.ThirdPartyOptOut, c2.Other_Village_Partner_Opt_Out__c);
	    		system.assertEquals(etlc2.ProfilingOptOut, c2.Profiling_Opt_Out__c);
	    		system.assertEquals(etlc2.Address_Street, c2.MailingStreet);
	    		system.assertEquals(etlc2.Address_City, c2.MailingCity);
	    		system.assertEquals(etlc2.Address_State, c2.MailingState);
	    		system.assertEquals(etlc2.Address_Country, c2.MailingCountry);
	    		system.assertEquals(etlc2.Address_PostCode, c2.MailingPostalCode);
	    		system.assertEquals(etlc2.Mobile, c2.MobilePhone);
	    		system.assertEquals(etlc2.CountryOfResidence, c2.Mailing_Country_In_English__c);
	    		system.assertEquals(etlc2.Nationality, c2.Nationality_Picklist__c);
	    		system.assertEquals(etlc2.PreferredLanguage, c2.Preferred_language_of_communication__c);
	    		system.assertEquals(etlc2.LeadSourceText, c2.Lead_Source_Text__c);
	    		system.assertEquals(testSettings.Lead_Source__c, c2.LeadSource);
	    		system.assertEquals(etlc2.RegistrationDate, c2.Original_Creation_Date__c);
	    		system.assertEquals(etlc2.Password, c2.B2C_Password__c);
    		}
    	}
    	
    	List<Customer_Activity__c> activityList2 = [SELECT Id, Contact_Name__c, Touchpoint_Type__c, Activity_Date__c,
    											    Activity_Quantity__c, Activity_Text__c, Activity_Type__c,
    											    Activity_Value__c, Touchpoint_Reference__c, Touchpoint_Source__c,
    											    Campaign__c, Village__c
    											    FROM Customer_Activity__c
    											    WHERE Contact_Name__c IN :contactIdList];	
    	system.debug('ACTIVITY LIST 2: ' + activityList2);
    	system.assertEquals(2, activityList2.size());

    	for (Customer_Activity__c ca2 : activityList2) {
    		system.assertEquals(testSettings.Activity_Type__c, ca2.Activity_Type__c);
    		if (ca2.Touchpoint_Reference__c == etlc1.TouchpointReference) {
	    		system.assertEquals(etlc1.TouchpointType, ca2.Touchpoint_Type__c);
	    		system.assertEquals(etlc1.TouchpointSource, ca2.Touchpoint_Source__c);
	    		system.assertEquals(originalActDate, ca2.Activity_Date__c);
	    		system.assertEquals(etlc1.Activity_Qty, ca2.Activity_Quantity__c);
	    		system.assertEquals(etlc1.Activity_Text, ca2.Activity_Text__c);
	    		system.assertEquals(etlc1.Activity_Value, ca2.Activity_Value__c);
	    		system.assertEquals(testVillage.Id, ca2.Village__c);
    		} else if (ca2.Touchpoint_Reference__c == etlc2.TouchpointReference) {
	    		system.assertEquals(etlc2.TouchpointType, ca2.Touchpoint_Type__c);
	    		system.assertEquals(etlc2.TouchpointSource, ca2.Touchpoint_Source__c);
	    		system.assertEquals(etlc2.Activity_Date, ca2.Activity_Date__c);
	    		system.assertEquals(etlc2.Activity_Qty, ca2.Activity_Quantity__c);
	    		system.assertEquals(etlc2.Activity_Text, ca2.Activity_Text__c);
	    		system.assertEquals(etlc2.Activity_Value, ca2.Activity_Value__c);
	    		system.assertEquals(testVillage.Id, ca2.Village__c);
    		}
    	}

    	testSettings.Allow_Duplicate_Activity_Records__c = false;
    	testSettings.Allow_Multiple_Activities_Per_Day__c = true;
    	upsert testSettings;

    	List<ETLContactResultDTO> outList3 = ETLWebService.contactRegistration(inList);

    	system.assertEquals(2, outList3.size());
    	system.debug('OUTLIST 3: ' + outList3);

    	for (ETLContactResultDTO res : outList3) {
    		if (res.ContactId == c.Id) {
	    		system.assertEquals('Completed', res.Result);
    			system.assertEquals('Success', res.Status);
    			system.assertEquals('Ignore', res.ContactAction);
    		} else {
	    		contactIdList.add(res.ContactId);
	    		system.assertEquals('Completed', res.Result);
    			system.assertEquals('Duplicate Customer Activity Ignored', res.Status);
    			system.assertEquals('Ignore', res.ContactAction);
    		}
    	}

    	List<Customer_Activity__c> activityList3 = [SELECT Id, Contact_Name__c, Touchpoint_Type__c, Activity_Date__c,
    											    Activity_Quantity__c, Activity_Text__c, Activity_Type__c,
    											    Activity_Value__c, Touchpoint_Reference__c, Touchpoint_Source__c,
    											    Campaign__c, Village__c
    											    FROM Customer_Activity__c
    											    WHERE Contact_Name__c IN :contactIdList];	
    	system.debug('ACTIVITY LIST 3: ' + activityList3);
    	system.assertEquals(3, activityList3.size());

    	testSettings.Allow_Duplicate_Activity_Records__c = true;
    	testSettings.Allow_Multiple_Activities_Per_Day__c = true;
    	upsert testSettings;

    	List<ETLContactResultDTO> outList4 = ETLWebService.contactRegistration(inList);

    	system.assertEquals(2, outList4.size());
    	system.debug('OUTLIST 4: ' + outList4);

    	List<Customer_Activity__c> activityList4 = [SELECT Id, Contact_Name__c, Touchpoint_Type__c, Activity_Date__c,
    											    Activity_Quantity__c, Activity_Text__c, Activity_Type__c,
    											    Activity_Value__c, Touchpoint_Reference__c, Touchpoint_Source__c,
    											    Campaign__c, Village__c
    											    FROM Customer_Activity__c
    											    WHERE Contact_Name__c IN :contactIdList];	
    	system.debug('ACTIVITY LIST 4: ' + activityList4);
    	system.assertEquals(5, activityList4.size());

    	system.debug('TEST END: testDuplicateCustomerActivity');
    }
    
    private static ETLContactDTO setupBasicETLContactDTO(Integer identifier) {
    	ETLContactDTO etlc = new ETLContactDTO();
    	Date testDate = system.today();
    	DateTime testActDate = system.now();
    	Integer dateOffset = 0 - identifier;
    	testDate = testDate.addDays(dateOffset);
    	testActDate = testActDate.addDays(dateOffset);

		Date contactDOB = Date.newinstance(1975, 12, 31);
		contactDOB = contactDOB.addDays(identifier);
		   		
   		// Touchpoint Fields
   		etlc.TouchpointReference = 'setupETLContact' + identifier;
   		etlc.TouchpointType = 'Barcode Application';
   		etlc.TouchpointSource = 'UNIT TEST';

   		// Contact Fields
   		etlc.LastName = 'Test111' + identifier;
   		etlc.FirstName = 'Johnny';
   		etlc.EmailAddress = 'testt2387' + identifier + '@sdfh.com';
   		etlc.DateOfBirth = contactDOB;
   		etlc.Gender = 'Male';
   		etlc.Over18YearsOld = true;
   		etlc.EmailOptOut = false;
   		etlc.MobileOptOut = false;
   		etlc.PostalOptOut = false;
   		etlc.ThirdPartyOptOut = false;
   		etlc.ProfilingOptOut = false;
   		etlc.Address_Street = '50 Pingle Drive';
   		etlc.Address_City = 'Bicester';
   		etlc.Address_State = 'Oxon';
   		etlc.Address_Country = 'UNITED KINGDOM';
   		etlc.Address_PostCode = 'OX26 6WD';
   		etlc.Mobile = '07890 12312' + identifier;
   		etlc.Password = 'passw0rd1';
   		etlc.LeadSourceText = 'setupBasicETLContactDTO';
   		etlc.CountryOfResidence = 'UNITED KINGDOM';
   		etlc.Nationality = 'British';
   		etlc.PreferredLanguage = 'English';
   		etlc.RegistrationDate = testDate;
   		
   		// Activity Fields
   		etlc.Activity_Value = 10;
   		etlc.Activity_Qty = 1;
   		etlc.Activity_Text = 'setupBasicETLContactDTO';
   		etlc.Activity_Date = testActDate;
   		
   		return etlc;
    }
    
    private static ETLWebService_Settings__c getTestETLSettings() {
    	ETLWebService_Settings__c testSettings = ETLWebService_Settings__c.getValues('Barcode Application');
    	if (testSettings == null) {
    		testSettings = new ETLWebService_Settings__c();
    		testSettings.Name = 'Barcode Application';
    	}
    	testSettings.Enabled__c = true;
    	testSettings.Ignore_Duplicates__c = true;
    	testSettings.Lead_Source__c = 'Other';
    	testSettings.Activity_Type__c = 'Visitor';
    	testSettings.Allow_Duplicate_Activity_Records__c = true;
    	testSettings.Allow_Multiple_Activities_Per_Day__c = true;
    	return testSettings;
    }
}