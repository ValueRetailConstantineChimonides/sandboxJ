@isTest (seeAllData=true)
private class BarcodeAppCustomerSearchControllerTest {
    
	/**
	 * Run search using normal data
	 */
    static testMethod void testRunNormalSearch() {
    	Contact bvContact1 = TestDataGenerator.setupContact(1, Properties.BICESTER_VILLAGE_ACCOUNT_ID, true);
    	Contact bvContact2 = TestDataGenerator.setupContact(2, Properties.BICESTER_VILLAGE_ACCOUNT_ID, true);
    	Contact bvContact3 = TestDataGenerator.setupContact(3, Properties.BICESTER_VILLAGE_ACCOUNT_ID, true);
    	Campaign testCampaign = TestDataGenerator.setupCampaign(1, false);
    	testCampaign.Campaign_Member_Redemption_Count__c = 2;
    	insert testCampaign;
    	CampaignMember bvc1CM = TestDataGenerator.setupCampaignMember(bvContact1.Id, testCampaign.Id, true);

        test.startTest();
        PageReference pageRef = new PageReference('/apex/BarcodeAppCustomerSearch');
   	    Test.setCurrentPageReference(pageRef);
       	BarcodeAppCustomerSearchController barcodeAppCustomerSearchController = new BarcodeAppCustomerSearchController();
       	
       	system.assertEquals(false, barcodeAppCustomerSearchController.getRenderCustSearch());
       	system.assertEquals(false, barcodeAppCustomerSearchController.getRenderCMSearch());
       	
       	barcodeAppCustomerSearchController.searchLastName = 'Test';
       	barcodeAppCustomerSearchController.searchEmail = bvContact1.Email;
       	barcodeAppCustomerSearchController.searchExactMatching = false;
       	barcodeAppCustomerSearchController.custSearch();
       	system.assertEquals(true, barcodeAppCustomerSearchController.getRenderCustSearch());
       	system.assertEquals(false, barcodeAppCustomerSearchController.getRenderCMSearch());
       	system.assertEquals(3, barcodeAppCustomerSearchController.custSearchResults.size());
       	system.assertEquals(3, barcodeAppCustomerSearchController.getCustSearchResults2().size());
       	
       	barcodeAppCustomerSearchController.selectedId = bvContact1.Id;
       	barcodeAppCustomerSearchController.selectRow();
       	system.assertEquals(true, barcodeAppCustomerSearchController.getRenderCustSearch());
       	system.assertEquals(true, barcodeAppCustomerSearchController.getRenderCMSearch());
       	
       	system.assertEquals(1, barcodeAppCustomerSearchController.campaignSearchResults.size());
       	system.assertEquals(1, barcodeAppCustomerSearchController.getCampaignSearchResults2().size());
       	
       	system.assertEquals(1, barcodeAppCustomerSearchController.csPageNumber);
       	system.assertEquals(1, barcodeAppCustomerSearchController.campPageNumber);
       	barcodeAppCustomerSearchController.csFirst();
       	barcodeAppCustomerSearchController.csLast();
       	barcodeAppCustomerSearchController.csNext();
       	barcodeAppCustomerSearchController.csPrevious();
       	system.assertEquals(false,barcodeAppCustomerSearchController.csHasNext);
       	system.assertEquals(false,barcodeAppCustomerSearchController.csHasPrevious);
       	barcodeAppCustomerSearchController.campNext();
       	barcodeAppCustomerSearchController.campPrevious();
       	barcodeAppCustomerSearchController.campFirst();
       	barcodeAppCustomerSearchController.campLast();
       	system.assertEquals(false,barcodeAppCustomerSearchController.campHasNext);
       	system.assertEquals(false,barcodeAppCustomerSearchController.campHasPrevious);
       	barcodeAppCustomerSearchController.campFirst();
       	barcodeAppCustomerSearchController.campLast();
       	barcodeAppCustomerSearchController.selectedCampaignId = testCampaign.Id;
       	barcodeAppCustomerSearchController.processRedemption();
       	test.stopTest();
    }

	/**
	 * Display search details for contact passed in
	 */
    static testMethod void testPassInContact() {
    	Contact bvContact1 = TestDataGenerator.setupContact(1, Properties.BICESTER_VILLAGE_ACCOUNT_ID, true);
    	Campaign testCampaign = TestDataGenerator.setupCampaign(1, false);
    	testCampaign.Campaign_Member_Redemption_Count__c = 2;
    	testCampaign.Campaign_Village_s__c = 'Bicester';
    	insert testCampaign;
    	CampaignMember bvc1CM = TestDataGenerator.setupCampaignMember(bvContact1.Id, testCampaign.Id, true);

        test.startTest();
        PageReference pageRef = new PageReference('/apex/BarcodeAppCustomerSearch?contactid=' + bvContact1.Id + '&showall=true');
   	    Test.setCurrentPageReference(pageRef);
       	BarcodeAppCustomerSearchController barcodeAppCustomerSearchController = new BarcodeAppCustomerSearchController();
       	system.assertEquals(true, barcodeAppCustomerSearchController.getRenderCustSearch());
       	system.assertEquals(true, barcodeAppCustomerSearchController.getRenderCMSearch());
       	system.assertEquals(bvContact1.Id, barcodeAppCustomerSearchController.selectedId);

       	barcodeAppCustomerSearchController.clear();
       	system.assertEquals(false, barcodeAppCustomerSearchController.getRenderCustSearch());
       	system.assertEquals(false, barcodeAppCustomerSearchController.getRenderCMSearch());
       	system.assertEquals(null, barcodeAppCustomerSearchController.custSearchResults);
       	system.assertEquals(null, barcodeAppCustomerSearchController.getCustSearchResults2());
       	system.assertEquals(null, barcodeAppCustomerSearchController.campaignSearchResults);
       	system.assertEquals(null, barcodeAppCustomerSearchController.getCampaignSearchResults2());
       	test.stopTest();
    }
    
	/**
	 * Test adding customer to a campaign
	 */
    static testMethod void testAddNewCampaignMember() {
    	Contact bvContact1 = TestDataGenerator.setupContact(1, Properties.BICESTER_VILLAGE_ACCOUNT_ID, true);
    	Campaign testCampaign = TestDataGenerator.setupCampaign(1, false);
    	testCampaign.Campaign_Member_Redemption_Count__c = 2;
    	testCampaign.Campaign_Village_s__c = 'Bicester';
    	insert testCampaign;

        test.startTest();
        PageReference pageRef = new PageReference('/apex/BarcodeAppCustomerSearch?contactid=' + bvContact1.Id + '&showall=true');
   	    Test.setCurrentPageReference(pageRef);
       	BarcodeAppCustomerSearchController barcodeAppCustomerSearchController = new BarcodeAppCustomerSearchController();
       	system.assertEquals(true, barcodeAppCustomerSearchController.getRenderCustSearch());
       	system.assertEquals(true, barcodeAppCustomerSearchController.getRenderCMSearch());
       	system.assertEquals(bvContact1.Id, barcodeAppCustomerSearchController.selectedId);

       	barcodeAppCustomerSearchController.selectedCampaignId = testCampaign.Id;
       	barcodeAppCustomerSearchController.processRedemption();

    	List<CampaignMember> bvc1CMList = [SELECT Id, ContactId, CampaignId, Status FROM CampaignMember WHERE ContactId = :bvContact1.Id]; 

       	system.assertEquals(1, bvc1CMList.size());
       	
       	CampaignMember bvc1CM = bvc1CMList.get(0);
       	
       	system.assertEquals(testCampaign.Id, bvc1CM.CampaignId);
       	system.assertEquals('Sent', bvc1CM.Status);
       	test.stopTest();
    }

	/**
	 * Simple button test
	 */
    static testMethod void testButtons() {
        test.startTest();
        PageReference pageRef = new PageReference('/apex/BarcodeAppCustomerSearch');
   	    Test.setCurrentPageReference(pageRef);
       	BarcodeAppCustomerSearchController barcodeAppCustomerSearchController = new BarcodeAppCustomerSearchController();
       	PageReference pr1 = barcodeAppCustomerSearchController.back();
       	PageReference pr2 = barcodeAppCustomerSearchController.addNew();
       	test.stopTest();
    }

	/**
	 * Test error checking
	 */
    static testMethod void testSearchForRubbish() {
        test.startTest();

        PageReference pageRef = new PageReference('/apex/BarcodeAppCustomerSearch');
   	    Test.setCurrentPageReference(pageRef);
       	BarcodeAppCustomerSearchController barcodeAppCustomerSearchController = new BarcodeAppCustomerSearchController();

       	barcodeAppCustomerSearchController.custSearch();
       	system.assertEquals(false, barcodeAppCustomerSearchController.getRenderCustSearch());
       	system.assertEquals(false, barcodeAppCustomerSearchController.getRenderCMSearch());
       	system.assertEquals(null, barcodeAppCustomerSearchController.custSearchResults);
       	system.assertEquals(null, barcodeAppCustomerSearchController.getCustSearchResults2());
       	system.assertEquals(null, barcodeAppCustomerSearchController.campaignSearchResults);
       	system.assertEquals(null, barcodeAppCustomerSearchController.getCampaignSearchResults2());

       	barcodeAppCustomerSearchController.searchLastName = 'Test2347632487634534xyz';
       	barcodeAppCustomerSearchController.searchFirstName = 'eswteraserTEst';
       	barcodeAppCustomerSearchController.searchEmail = 'asdfsadfg1234';
       	barcodeAppCustomerSearchController.searchPostcode = 'XXX123XXX';
       	barcodeAppCustomerSearchController.searchMailStreet = 'TEST1231243';
       	barcodeAppCustomerSearchController.custSearch();
       	system.assertEquals(false, barcodeAppCustomerSearchController.getRenderCustSearch());
       	system.assertEquals(false, barcodeAppCustomerSearchController.getRenderCMSearch());
       	system.assertEquals(0, barcodeAppCustomerSearchController.custSearchResults.size());
       	system.assertEquals(0, barcodeAppCustomerSearchController.getCustSearchResults2().size());
       	system.assertEquals(null, barcodeAppCustomerSearchController.campaignSearchResults);
       	system.assertEquals(null, barcodeAppCustomerSearchController.getCampaignSearchResults2());
       	
       	barcodeAppCustomerSearchController.clear();
       	barcodeAppCustomerSearchController.searchVRNumber = 'XXX123TEST';
       	barcodeAppCustomerSearchController.custSearch();
       	system.assertEquals(false, barcodeAppCustomerSearchController.getRenderCustSearch());
       	system.assertEquals(false, barcodeAppCustomerSearchController.getRenderCMSearch());
       	system.assertEquals(0, barcodeAppCustomerSearchController.custSearchResults.size());
       	system.assertEquals(0, barcodeAppCustomerSearchController.getCustSearchResults2().size());
       	system.assertEquals(null, barcodeAppCustomerSearchController.campaignSearchResults);
       	system.assertEquals(null, barcodeAppCustomerSearchController.getCampaignSearchResults2());

       	test.stopTest();
    }
}