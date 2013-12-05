@isTest (seeAllData=true)
private class BarcodeAppScanControllerTest {

	/**
	 * Test scanned barcode
	 */
    static testMethod void testBarcodeScan() {
    	Contact bvContact = TestDataGenerator.setupContact(1, Properties.BICESTER_VILLAGE_ACCOUNT_ID, true);
    	Campaign testCampaign = TestDataGenerator.setupCampaign(1, false);
    	testCampaign.Campaign_Member_Redemption_Count__c = 2;
    	insert testCampaign;
    	CampaignMember bvCM = TestDataGenerator.setupCampaignMember(bvContact.Id, testCampaign.Id, true);
    	CampaignMember bvCM2 = [SELECT Id, CM_Unique_ID__c FROM CampaignMember WHERE Id = :bvCM.Id LIMIT 1];
        String bvCMcmid = bvCM2.CM_Unique_ID__c;
        system.debug('CMID: '+ bvCMcmid);

        test.startTest();
        PageReference pageRef = new PageReference('/apex/BarcodeAppScan');
   	    Test.setCurrentPageReference(pageRef);
       	BarcodeAppScanController barcodeAppScanController = new BarcodeAppScanController();
       	
       	PageReference pageRef1 = barcodeAppScanController.save();
       	system.assertEquals(null, pageRef1);
       	barcodeAppScanController.scannedId = bvCMcmid;
       	PageReference pageRef2 = barcodeAppScanController.save();
       	test.stopTest();
    }

	/**
	 * Test clean and search buttons
	 */
    static testMethod void testClearAndSearch() {
        test.startTest();
        PageReference pageRef = new PageReference('/apex/BarcodeAppScan');
   	    Test.setCurrentPageReference(pageRef);
       	BarcodeAppScanController barcodeAppScanController = new BarcodeAppScanController();

       	barcodeAppScanController.scannedId = 'sadfuhsdfkuhsadkfuh';
       	PageReference pageRef2 = barcodeAppScanController.save();
       	barcodeAppScanController.clear();
       	PageReference pageRef3 = barcodeAppScanController.contactSearch();
       	test.stopTest();
    }
}