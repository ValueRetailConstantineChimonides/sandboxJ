@isTest (seeAllData=true)
private class BatchDataCardMigrationTest {

    static testMethod void testMigration() {
    	system.debug('TEST START: testMigration');
    	Properties.IS_TEST_METHOD = true;
    	Id bicesterId = Properties.BICESTER_VILLAGE_ACCOUNT_ID;
    	Date testDate = system.today();
    	Date testDate1 = testDate.addDays(-10);
    	Date testDate2 = testDate.addDays(-20);
    	Date testDate3 = testDate.addDays(-30);
    	Date testDate4 = testDate.addDays(-40);
		Contact c1 = TestDataGenerator.setupContact(1, bicesterId, false);
		Contact c2 = TestDataGenerator.setupContact(2, bicesterId, false);
		Contact c3 = TestDataGenerator.setupContact(3, bicesterId, false);
		Contact c4 = TestDataGenerator.setupContact(4, bicesterId, false);
		c1.Original_Creation_Date__c = testDate1;
		c1.LeadSource = 'Village Registration Card';
		c2.Original_Creation_Date__c = testDate2;
		c2.LeadSource = 'Village Registration Card';
		c3.LeadSource = 'Village Registration Card';
		c4.Original_Creation_Date__c = testDate4;
		c4.LeadSource = 'Web registration';
		List<Contact> contactList = new List<Contact>{c1, c2, c3, c4}; 
		insert contactList;
    	system.debug('CONTACT LIST: ' + contactList);
    	
		List<Contact> contactList2 = [SELECT Id, AccountId, CreatedDate, User_Login_ID__c,
        									 LeadSource, Migrated__c, Original_Creation_Date__c
                                      FROM Contact
                                      WHERE Id IN :contactList AND LeadSource = 'Village Registration Card'];

		Database.BatchableContext bc = null;
		BatchDataCardMigration dcMigrator = new BatchDataCardMigration();
		Test.startTest();
		dcMigrator.execute(bc, contactList2);
		Test.stopTest();

    	List<Customer_Activity__c> activityList = [SELECT Id, Contact_Name__c, Touchpoint_Type__c, Activity_Date__c,
    											   Activity_Quantity__c, Activity_Text__c, Activity_Type__c,
    											   Activity_Value__c, Touchpoint_Reference__c, Touchpoint_Source__c,
    											   Campaign__c, Village__c
    											   FROM Customer_Activity__c
    											   WHERE Contact_Name__c IN :contactList];	

    	system.debug('ACTIVITY LIST: ' + activityList);
    	system.assertEquals(3, activityList.size());

    	for (Customer_Activity__c ca : activityList) {
    		system.assertEquals('Visitor', ca.Activity_Type__c);
    		system.assertEquals('Village Registration Card', ca.Touchpoint_Type__c);
    		system.assertEquals('Data Migration', ca.Touchpoint_Source__c);
    		system.assertEquals(0, ca.Activity_Quantity__c);
    		system.assertEquals('Data Migration', ca.Activity_Text__c);
    		system.assert(ca.Touchpoint_Reference__c.startsWith('VR'));
    		system.assertEquals(0, ca.Activity_Value__c);
    		system.assertEquals('a0c20000001oaIPAAY', ca.Village__c);

    		if (ca.Contact_Name__c == c1.Id) {
	    		system.assertEquals(testDate1, ca.Activity_Date__c);
    		} else if (ca.Contact_Name__c == c2.Id) {
	    		system.assertEquals(testDate2, ca.Activity_Date__c);
    		} else if (ca.Contact_Name__c == c3.Id) {
	    		system.assertEquals(system.today(), ca.Activity_Date__c.date());
    		} else {
    			system.assert(false);
    		}
    	}

		List<Contact> contactList3 = [SELECT Id, LastName, Migrated__c
        							  FROM Contact
        							  WHERE Id IN :contactList];

    	system.debug('MIGRATED CONTACT LIST: ' + contactList3);
    	system.assertEquals(4, contactList3.size());

    	for (Contact c : contactList3) {
    		if (c.Id == c4.Id) {
    			system.assertEquals(false, c.Migrated__c);
    		} else {
    			system.assertEquals(true, c.Migrated__c);
    		}
    	}
    	system.debug('TEST END: testMigration');
    }

    static testMethod void testFinishMethod() {
    	Properties.IS_TEST_METHOD = true;
		Database.BatchableContext bc = null;
		BatchDataCardMigration dcUpdater = new BatchDataCardMigration();
		Test.startTest();
		dcUpdater.finish(bc);
		Test.stopTest();
    }
}