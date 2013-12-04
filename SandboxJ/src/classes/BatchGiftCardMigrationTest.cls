@isTest (seeAllData=true)
private class BatchGiftCardMigrationTest {

    static testMethod void testMigration() {
    	system.debug('TEST START: testMigration');
    	Id bicesterId = Properties.BICESTER_VILLAGE_ACCOUNT_ID;
    	Date testDate = system.today();
    	Date testDate1 = testDate.addDays(-10);
    	Date testDate2 = testDate.addDays(-20);
    	Date testDate3 = testDate.addDays(-30);
    	Date testDate4 = testDate.addDays(-40);
		Contact c1 = TestDataGenerator.setupContact(1, bicesterId, false);
		Contact c2 = TestDataGenerator.setupContact(2, bicesterId, false);
		Contact c3 = TestDataGenerator.setupContact(3, bicesterId, false);
		List<Contact> contactList = new List<Contact>{c1, c2, c3}; 
		insert contactList;
    	system.debug('CONTACT LIST: ' + contactList);
    	
		Gift_Card__c gc1 = new Gift_Card__c(Contact__c = c1.Id, Registration_Date__c = testDate1, Amount__c = 10.00,
											Customer_ID__c = 'GIFT CARD TEST 1', Source__c = 'Gift Card Testing',
											Village_ID__c = '001200000032qrCAAQ'); // Contact 1 - Bicester

		Gift_Card__c gc2 = new Gift_Card__c(Contact__c = c2.Id, Registration_Date__c = testDate2, Amount__c = 20.00,
											Customer_ID__c = 'GIFT CARD TEST 2', Source__c = 'Gift Card Testing',
											Village_ID__c = '001200000032qrCAAQ'); // Contact 2 - Bicester

		Gift_Card__c gc3 = new Gift_Card__c(Contact__c = c2.Id, Registration_Date__c = testDate3, Amount__c = 30.00,
											Customer_ID__c = 'GIFT CARD TEST 3', Source__c = 'Gift Card Testing',
											Village_ID__c = '001200000032qrCAAQ'); // Contact 2 - Bicester

		Gift_Card__c gc4 = new Gift_Card__c(Contact__c = c3.Id, Registration_Date__c = testDate4, Amount__c = 40.00,
											Customer_ID__c = 'GIFT CARD TEST 4', Source__c = 'Gift Card Testing',
											Village_ID__c = '001200000032r2AAAQ'); // Contact 3 - Kildare

		List<Gift_Card__c> gcList = new List<Gift_Card__c> {gc1, gc2, gc3, gc4};
		insert gcList;
		
		List<Gift_Card__c> gcList2 = [SELECT Id, Contact__c, Registration_Date__c, Amount__c,
        									 Village_ID__c, Source__c, Name
        							  FROM Gift_Card__c
        							  WHERE Id IN :gcList];

		Database.BatchableContext bc = null;
		BatchGiftCardMigration gcMigrator = new BatchGiftCardMigration();
		Test.startTest();
		gcMigrator.execute(bc, gcList2);
		Test.stopTest();

    	List<Customer_Activity__c> activityList = [SELECT Id, Contact_Name__c, Touchpoint_Type__c, Activity_Date__c,
    											   Activity_Quantity__c, Activity_Text__c, Activity_Type__c,
    											   Activity_Value__c, Touchpoint_Reference__c, Touchpoint_Source__c,
    											   Campaign__c, Village__c
    											   FROM Customer_Activity__c
    											   WHERE Contact_Name__c IN :contactList];	

    	system.debug('ACTIVITY LIST: ' + activityList);
    	system.assertEquals(4, activityList.size());

    	for (Customer_Activity__c ca : activityList) {
    		system.assertEquals('Member', ca.Activity_Type__c);
    		system.assertEquals('Gift Card Purchase', ca.Touchpoint_Type__c);
    		system.assertEquals('Online', ca.Touchpoint_Source__c);
    		system.assertEquals(0, ca.Activity_Quantity__c);
    		system.assertEquals('Data Migration', ca.Activity_Text__c);
    		system.assert(ca.Touchpoint_Reference__c.startsWith('GC'));

    		if (ca.Contact_Name__c == c1.Id) {
	    		system.assertEquals(testDate1, ca.Activity_Date__c);
	    		system.assertEquals(10.00, ca.Activity_Value__c);
	    		system.assertEquals('a0c20000001oaIPAAY', ca.Village__c);
    		} else if (ca.Contact_Name__c == c2.Id) {
	    		system.assertEquals('a0c20000001oaIPAAY', ca.Village__c);
	    		system.assert(ca.Activity_Date__c == testDate2 || ca.Activity_Date__c == testDate3);
		    	system.assert(ca.Activity_Value__c == 20.00 || ca.Activity_Value__c == 30.00);
    		} else if (ca.Contact_Name__c == c3.Id) {
	    		system.assertEquals(testDate4, ca.Activity_Date__c);
	    		system.assertEquals(40.00, ca.Activity_Value__c);
	    		system.assertEquals('a0c20000001oaIKAAY', ca.Village__c);
    		}
    	}

		List<Gift_Card__c> gcList3 = [SELECT Id, Name, Migrated__c
        							  FROM Gift_Card__c
        							  WHERE Id IN :gcList];

    	system.debug('MIGRATED GC LIST: ' + gcList3);
    	system.assertEquals(4, gcList3.size());

    	for (Gift_Card__c gcm : gcList3) {
    		system.assertEquals(true, gcm.Migrated__c);
    	}
    	system.debug('TEST END: testMigration');
    }
}