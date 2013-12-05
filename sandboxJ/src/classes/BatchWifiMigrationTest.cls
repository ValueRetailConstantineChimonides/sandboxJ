@isTest (seeAllData=true)
private class BatchWifiMigrationTest {

    static testMethod void testMigration() {
    	system.debug('TEST START: testMigration');
    	Id bicesterId = Properties.BICESTER_VILLAGE_ACCOUNT_ID;
    	Date testDate = system.today();
		Contact c1 = TestDataGenerator.setupContact(1, bicesterId, false);
		Contact c2 = TestDataGenerator.setupContact(2, bicesterId, false);
		Contact c3 = TestDataGenerator.setupContact(3, bicesterId, false);
		Contact c4 = TestDataGenerator.setupContact(4, bicesterId, false);
		List<Contact> contactList = new List<Contact>{c1, c2, c3, c4}; 
		insert contactList;
    	system.debug('CONTACT LIST: ' + contactList);

    	Campaign testCampaign = TestDataGenerator.setupCampaign(1, true);
    	system.debug('TEST CAMPAIGN: ' + testCampaign);
    	
    	CampaignMember bvCM1 = TestDataGenerator.setupCampaignMember(c1.Id, '70120000000NT90AAG', false);
    	bvCM1.Status = 'Responded';
    	CampaignMember bvCM2 = TestDataGenerator.setupCampaignMember(c2.Id, '70120000000NT90AAG', false);
    	bvCM2.Status = 'Responded';
    	CampaignMember bvCM3 = TestDataGenerator.setupCampaignMember(c3.Id, '70120000000NT90AAG', false);
    	bvCM3.Status = 'Responded';
    	CampaignMember bvCM4 = TestDataGenerator.setupCampaignMember(c4.Id, '70120000000NT90AAG', false);
    	bvCM4.Status = 'Responded';
    	List<CampaignMember> cmInsertList = new List<CampaignMember>{bvCM1, bvCM2, bvCM3, bvCM4};
    	insert cmInsertList;
    	system.debug('CM INSERT LIST: ' + cmInsertList);
    	
		List<CampaignMember> cmList = [SELECT Id, CreatedDate, ContactId, CampaignId, CM_Unique_ID__c,
        									  FirstRespondedDate, Migrated__c, Status
                                       FROM CampaignMember
                                       WHERE ContactId IN :contactList AND CampaignId = '70120000000NT90AAG' AND Migrated__c != true];
        system.debug('CMLIST: '+ cmList);

		Database.BatchableContext bc = null;
		BatchWifiMigration wifiMigrator = new BatchWifiMigration();
		Test.startTest();
		wifiMigrator.execute(bc, cmList);
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
    		system.assertEquals('Public Wifi', ca.Touchpoint_Type__c);
    		system.assertEquals('Data Migration', ca.Touchpoint_Source__c);
    		system.assertEquals('a0c20000001oaIPAAY', ca.Village__c);
    		system.assertEquals('Registration', ca.Activity_Text__c);
	    	system.assertEquals(0, ca.Activity_Quantity__c);
	    	system.assertEquals(0, ca.Activity_Value__c);
    		system.assertEquals(testDate, ca.Activity_Date__c);
    	}

		List<CampaignMember> cmListLast = [SELECT Id, Migrated__c
        								   FROM CampaignMember
        								   WHERE Id IN :cmList];
        									    	 

    	system.debug('MIGRATED CM LIST: ' + cmListLast);
    	system.assertEquals(4, cmListLast.size());

    	for (CampaignMember cmLast : cmListLast) {
    		system.assertEquals(true, cmLast.Migrated__c);
    	}
    	system.debug('TEST END: testMigration');
    }
}