@isTest (seeAllData=true)
private class BarcodeAppAddContactControllerTest {

    /**
     * Test adding contact
     */
    static testMethod void addContactTest() {
    	String testVillageName = 'TESTVILLAGE';
    	Village__c testVillage = new Village__c(Village_Code__c = 'ZZ', Name = testVillageName);
    	insert testVillage;
    	system.debug('VILLAGE INSERTED: ' + testVillage.Id);
    	
    	User admUser = TestDataGenerator.setupAdminUser(false);
    	admUser.Campaign_Village__c = 'Chic Outlet Shopping;TESTVILLAGE';
    	insert admUser;
    	system.debug('ADMIN USER INSERTED: ' + admUser.Id);
    	
    	Account villageAccount = TestDataGenerator.setupB2CAccount(1, false);
    	villageAccount.Name = testVillageName;
    	insert villageAccount;
    	system.debug('ACCOUNT INSERTED: ' + villageAccount.Id);

        system.runAs(admUser) {
	        PageReference pageRef = new PageReference('/apex/BarcodeAppAddContact');
   		    Test.setCurrentPageReference(pageRef);
       		BarcodeAppAddContactController barcodeAppAddContactController = new BarcodeAppAddContactController();
	       	Contact tempContact = TestDataGenerator.setupContact(1, Properties.BICESTER_VILLAGE_ACCOUNT_ID, false);
    	   	system.assertEquals(false, barcodeAppAddContactController.getEnableSubmitButton());
       		barcodeAppAddContactController.contact.LastName = tempContact.LastName;
	       	system.assertEquals(false, barcodeAppAddContactController.getEnableSubmitButton());
    	   	barcodeAppAddContactController.contact.FirstName = tempContact.FirstName;
       		system.assertEquals(false, barcodeAppAddContactController.getEnableSubmitButton());
	       	barcodeAppAddContactController.contact.Email = tempContact.Email;
    	   	system.assertEquals(true, barcodeAppAddContactController.getEnableSubmitButton());
    	   	
    	   	PageReference pageRef2 = barcodeAppAddContactController.submit();
        }
    }

    /**
     * Test adding duplicate contact
     */
    static testMethod void addDuplicateContactTest() {
    	String testVillageName = 'TESTVILLAGE';
    	Village__c testVillage = new Village__c(Village_Code__c = 'ZZ', Name = testVillageName);
    	insert testVillage;
    	system.debug('VILLAGE INSERTED: ' + testVillage.Id);
    	
    	User admUser = TestDataGenerator.setupAdminUser(false);
    	admUser.Campaign_Village__c = 'Chic Outlet Shopping;TESTVILLAGE';
    	insert admUser;
    	system.debug('ADMIN USER INSERTED: ' + admUser.Id);
    	
    	Account villageAccount = TestDataGenerator.setupB2CAccount(1, false);
    	villageAccount.Name = testVillageName;
    	insert villageAccount;
    	system.debug('ACCOUNT INSERTED: ' + villageAccount.Id);

       	Contact tempContact = TestDataGenerator.setupContact(1, villageAccount.Id, true);

        system.runAs(admUser) {
	        PageReference pageRef = new PageReference('/apex/BarcodeAppAddContact');
   		    Test.setCurrentPageReference(pageRef);
       		BarcodeAppAddContactController barcodeAppAddContactController = new BarcodeAppAddContactController();
    	   	system.assertEquals(false, barcodeAppAddContactController.getEnableSubmitButton());
       		barcodeAppAddContactController.contact.LastName = tempContact.LastName;
	       	system.assertEquals(false, barcodeAppAddContactController.getEnableSubmitButton());
    	   	barcodeAppAddContactController.contact.FirstName = tempContact.FirstName;
       		system.assertEquals(false, barcodeAppAddContactController.getEnableSubmitButton());
	       	barcodeAppAddContactController.contact.Email = tempContact.Email;
    	   	system.assertEquals(true, barcodeAppAddContactController.getEnableSubmitButton());
    	   	
    	   	PageReference pageRef2 = barcodeAppAddContactController.submit();
    	   	PageReference pageRef3 = barcodeAppAddContactController.selectFromDuplicates();
        }
    }

    /**
     * Test navigation
     */
    static testMethod void addContactNavigationTest() {
        PageReference pageRef = new PageReference('/apex/BarcodeAppAddContact');
   	    Test.setCurrentPageReference(pageRef);
       	BarcodeAppAddContactController barcodeAppAddContactController = new BarcodeAppAddContactController();

       	PageReference pageRef2 = barcodeAppAddContactController.backToScan();
       	PageReference pageRef3 = barcodeAppAddContactController.backToSearch();
    }
}