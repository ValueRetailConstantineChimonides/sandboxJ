@isTest (seeAllData=true)
private class BatchShoppingExpressMigrationTest {

    static testMethod void testMigration() {
    	system.debug('TEST START: testMigration');
    	Id bicesterId = Properties.BICESTER_VILLAGE_ACCOUNT_ID;
    	Date testDate = system.today();
    	Date testDate1 = testDate.addDays(-10);
    	Date testDate2 = testDate.addDays(-20);
		Contact c1 = TestDataGenerator.setupContact(1, bicesterId, false);
		Contact c2 = TestDataGenerator.setupContact(2, bicesterId, false);
		Contact c3 = TestDataGenerator.setupContact(3, bicesterId, false);
		Contact c4 = TestDataGenerator.setupContact(4, bicesterId, false);
		List<Contact> contactList = new List<Contact>{c1, c2, c3, c4}; 
		insert contactList;
    	system.debug('CONTACT LIST: ' + contactList);
    	
		Resort_Hoppa_Transaction__c se1 = new Resort_Hoppa_Transaction__c(XferDate1__c = testDate1,
																		  PartySize__c = 2,
																		  XferDeppt1__c = 'From London to Bicester Village',
																		  XferArrpt1__c = 'From Bicester Village to London',
																		  InvoiceValue__c = 20.00,
																		  Name = 'TEST_SE1',
																		  Contact__c = c1.Id);
		Resort_Hoppa_Transaction__c se2 = new Resort_Hoppa_Transaction__c(XferDate1__c = testDate2,
																		  PartySize__c = 3,
																		  XferDeppt1__c = 'From London to Bicester Village',
																		  XferArrpt1__c = 'From Bicester Village to London',
																		  InvoiceValue__c = 30.00,
																		  Name = 'TEST_SE2',
																		  Contact__c = c2.Id);
		Resort_Hoppa_Transaction__c se3 = new Resort_Hoppa_Transaction__c(PartySize__c = 4,
																		  XferDeppt1__c = 'From London to Bicester Village',
																		  XferArrpt1__c = 'From Bicester Village to London',
																		  InvoiceValue__c = -10.00,
																		  Name = 'TEST_SE3',
																		  Contact__c = c3.Id);
		Resort_Hoppa_Transaction__c se4 = new Resort_Hoppa_Transaction__c(XferDate1__c = testDate1,
																		  PartySize__c = 2,
																		  XferDeppt1__c = 'From Here to Eternity',
																		  XferArrpt1__c = 'Are we there yet?',
																		  InvoiceValue__c = 105.00,
																		  Name = 'TEST_SE4',
																		  Contact__c = c4.Id);
		List<Resort_Hoppa_Transaction__c> seList = new List<Resort_Hoppa_Transaction__c> {se1, se2, se3, se4};
		insert seList;
		
		List<Resort_Hoppa_Transaction__c> seList2 = [SELECT Id, XferDate1__c, PartySize__c, XferDeppt1__c, XferArrpt1__c,
        									    	 InvoiceValue__c, Contact__c, Name, h_Village_Name__c, CreatedDate,
        									    	 Contact__r.Account.Site
        									    	 FROM Resort_Hoppa_Transaction__c
        									    	 WHERE Id IN :seList];

		Database.BatchableContext bc = null;
		BatchShoppingExpressMigration seMigrator = new BatchShoppingExpressMigration();
		Test.startTest();
		seMigrator.execute(bc, seList2);
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
    		system.assertEquals('Visitor', ca.Activity_Type__c);
    		system.assertEquals('Shopping Express', ca.Touchpoint_Type__c);
    		system.assertEquals('Shopping Express Data Migration', ca.Touchpoint_Source__c);
    		system.assertEquals('a0c20000001oaIPAAY', ca.Village__c);

    		if (ca.Contact_Name__c == c1.Id) {
	    		system.assertEquals(testDate1, ca.Activity_Date__c);
	    		system.assertEquals(2, ca.Activity_Quantity__c);
	    		system.assertEquals(se1.XferDeppt1__c + ' - ' + se1.XferArrpt1__c, ca.Activity_Text__c);
	    		system.assertEquals(20.00, ca.Activity_Value__c);
    		} else if (ca.Contact_Name__c == c2.Id) {
	    		system.assertEquals(testDate2, ca.Activity_Date__c);
	    		system.assertEquals(3, ca.Activity_Quantity__c);
	    		system.assertEquals(se2.XferDeppt1__c + ' - ' + se2.XferArrpt1__c, ca.Activity_Text__c);
	    		system.assertEquals(30.00, ca.Activity_Value__c);
    		} else if (ca.Contact_Name__c == c3.Id) {
	    		system.assertEquals(system.today(), ca.Activity_Date__c.date());
	    		system.assertEquals(4, ca.Activity_Quantity__c);
	    		system.assertEquals(se3.XferDeppt1__c + ' - ' + se3.XferArrpt1__c, ca.Activity_Text__c);
	    		system.assertEquals(0.00, ca.Activity_Value__c);
    		} else if (ca.Contact_Name__c == c4.Id) {
	    		system.assertEquals(testDate1, ca.Activity_Date__c);
	    		system.assertEquals(2, ca.Activity_Quantity__c);
	    		system.assertEquals(se4.XferDeppt1__c + ' - ' + se4.XferArrpt1__c, ca.Activity_Text__c);
	    		system.assertEquals(105.00, ca.Activity_Value__c);
    		}
    	}

		List<Resort_Hoppa_Transaction__c> seList3 = [SELECT Id, Name, Migrated__c
        									    	 FROM Resort_Hoppa_Transaction__c
        									    	 WHERE Id IN :seList];
        									    	 

    	system.debug('MIGRATED SE LIST: ' + seList3);
    	system.assertEquals(4, seList3.size());

    	for (Resort_Hoppa_Transaction__c rht : seList3) {
    		system.assertEquals(true, rht.Migrated__c);
    	}
    	system.debug('TEST END: testMigration');
    }
}