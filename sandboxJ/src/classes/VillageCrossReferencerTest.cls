@isTest(SeeAllData=true)
private class VillageCrossReferencerTest {

    static testMethod void crossReferencerTest() {
    	String testVillageName = 'TESTVILLAGE';
    	String testVillageCode = 'ZZ';
    	Village__c testVillage = new Village__c(Village_Code__c = testVillageCode, Name = testVillageName);
    	insert testVillage;
    	system.debug('VILLAGE INSERTED: ' + testVillage.Id);
    	
    	User admUser = TestDataGenerator.setupAdminUser(false);
    	admUser.Campaign_Village__c = 'Chic Outlet Shopping;TESTVILLAGE';
    	insert admUser;
    	system.debug('ADMIN USER INSERTED: ' + admUser.Id);
    	
    	Account villageAccount = TestDataGenerator.setupB2CAccount(1, false);
    	villageAccount.Name = testVillageName;
    	villageAccount.Site = testVillage.Village_Code__c;
    	insert villageAccount;
    	system.debug('ACCOUNT INSERTED: ' + villageAccount.Id);
    	
    	Account otherAccount = TestDataGenerator.setupB2CAccount(2, false);
    	otherAccount.Name = 'OTHERACCOUNT';
    	insert otherAccount;
    	system.debug('ACCOUNT INSERTED: ' + otherAccount.Id);

    	test.startTest();
    	Id test0 = VillageCrossReferencer.getVillageAccountIdByCode(testVillage.Village_Code__c);
    	system.assertEquals(villageAccount.Id, test0);
    	
    	Id test01 = VillageCrossReferencer.getVillageAccountIdByCode('WIBBLEBLAHRUBBISH');
    	system.assertEquals(null, test01);

    	List<String> villageNameList = new List<String> {testVillageName};
    	Id test1 = VillageCrossReferencer.getVillageId(villageNameList);
    	system.assertEquals(testVillage.Id, test1);

    	Id test1b = VillageCrossReferencer.getVillageIdByCode(testVillageCode);
    	system.assertEquals(testVillage.Id, test1b);

   		Id vAccId = VillageCrossReferencer.getVillageAccountId(testVillageName);
   		system.assertEquals(villageAccount.Id, vAccId);
   		
   		List<String> testNamesList = new List<String> {otherAccount.Name, testVillageName};
   		Id vAccId2 = VillageCrossReferencer.getVillageAccountId(testNamesList);
   		system.assertEquals(villageAccount.Id, vAccId2);
   		
   		Id nullId = VillageCrossReferencer.getVillageId(new List<String> {'WIBBLEBLAHRUBBISH'});
   		system.assertEquals(null, nullId);

   		Id nullId2 = VillageCrossReferencer.getVillageAccountId(new List<String> {'WIBBLEBLAHRUBBISH'});
   		system.assertEquals(null, nullId2);
    	
    	system.runAs(admUser) {
    		String vName = VillageCrossReferencer.getUserVillageName();
    		system.assertEquals(testVillageName, vName);
	    	Id vId = VillageCrossReferencer.getUserVillageId();
    		system.assertEquals(testVillage.Id, vId);
    		Id uvAccId = VillageCrossReferencer.getUserVillageAccountId();
    		system.assertEquals(villageAccount.Id, uvAccId);
    		List<Id> accIdList = VillageCrossReferencer.getUserVillageAccountIdList(false);
    		system.assertEquals(2, accIdList.size());
    	}
    	test.stopTest();
    }
}