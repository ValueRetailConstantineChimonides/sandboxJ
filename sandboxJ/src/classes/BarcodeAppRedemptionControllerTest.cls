@isTest(seeAllData=true)
private class BarcodeAppRedemptionControllerTest {

    /**
     * Test Redemption Screen for a non-Mono Contact
     */
    static testMethod void testRedemptionScreenNormalContact() {
    	Redemption_Config_Settings__c settings = Redemption_Config_Settings__c.getValues(Properties.BICESTER_VILLAGE_ACCOUNT_ID);
    	settings.Over_18_Required__c = true;
    	settings.Opt_In_Required__c = true;
    	update settings;
    	Contact bvContact = TestDataGenerator.setupContact(1, Properties.BICESTER_VILLAGE_ACCOUNT_ID, true);
    	Campaign testCampaign = TestDataGenerator.setupCampaign(1, false);
    	testCampaign.Campaign_Member_Redemption_Count__c = 2;
    	insert testCampaign;
    	CampaignMember bvCM = TestDataGenerator.setupCampaignMember(bvContact.Id, testCampaign.Id, true);
    	CampaignMember bvCM2 = [SELECT Id, CM_Unique_ID__c FROM CampaignMember WHERE Id = :bvCM.Id LIMIT 1];
        String bvCMcmid = bvCM2.CM_Unique_ID__c;
        system.debug('CMID: '+ bvCMcmid);

        test.startTest();
        PageReference pageRef = new PageReference('/apex/BarcodeAppRedemption?cmid=' + bvCMcmid);
   	    Test.setCurrentPageReference(pageRef);
       	BarcodeAppRedemptionController barcodeAppRedemptionController = new BarcodeAppRedemptionController();
       	system.assertEquals(false, barcodeAppRedemptionController.getRenderMonoContact());
       	system.assertEquals(false, barcodeAppRedemptionController.getEnableRedeemButton());
       	system.assertEquals(false, barcodeAppRedemptionController.getEnablePrintLabels());
       	bvContact.I_am_18_years_old_or_more__c = true;
       	bvContact.Profiling_Opt_Out__c = false;
       	update bvContact;

       	barcodeAppRedemptionController.refresh();

       	system.assertEquals(false, barcodeAppRedemptionController.getRenderMonoContact());
       	system.assertEquals(true, barcodeAppRedemptionController.getEnableRedeemButton());
       	system.assertEquals(false, barcodeAppRedemptionController.getEnablePrintLabels());

       	barcodeAppRedemptionController.processRedemption();

       	system.assertEquals(false, barcodeAppRedemptionController.getEnableRedeemButton());
       	system.assertEquals(true, barcodeAppRedemptionController.getEnablePrintLabels());

       	CampaignMember updatedBVCM = [SELECT Id, Redemption_Count__c FROM CampaignMember WHERE CM_Unique_ID__c = :bvCMcmid LIMIT 1];
       	system.assertEquals(1, updatedBVCM.Redemption_Count__c);
       	Contact updatedBVContact = [SELECT Id, Current_Segment__c FROM Contact WHERE Id = :bvContact.Id];
       	system.assertEquals(1, updatedBVContact.Current_Segment__c);

       	PageReference pageRef2 = barcodeAppRedemptionController.back();
        test.stopTest();
    }
    
    /**
     * Test Redemption Screen for a Mono Contact
     */
    static testMethod void testRedemptionScreenMonoContact() {
    	Campaign testCampaign = TestDataGenerator.setupCampaign(1, true);
    	Contact monoContact = TestDataGenerator.setupContact(1, Properties.BICESTER_VILLAGE_ACCOUNT_ID, false);
    	monoContact.RecordTypeId = Properties.MONO_CONTACT_RECORD_TYPE;
    	insert monoContact;
    	CampaignMember monoCM = TestDataGenerator.setupCampaignMember(monoContact.Id, testCampaign.Id, true);
    	CampaignMember monoCM2 = [SELECT Id, CM_Unique_ID__c FROM CampaignMember WHERE Id = :monoCM.Id LIMIT 1];
        String monoCMcmid = monoCM2.CM_Unique_ID__c;
    	
        test.startTest();
        PageReference pageRef = new PageReference('/apex/BarcodeAppRedemption?cmid=' + monoCMcmid);
   	    Test.setCurrentPageReference(pageRef);
       	BarcodeAppRedemptionController barcodeAppRedemptionController = new BarcodeAppRedemptionController();
       	system.assertEquals(true, barcodeAppRedemptionController.getRenderMonoContact());
       	system.assertEquals(true, barcodeAppRedemptionController.getEnableRedeemButton());
       	system.assertEquals(false, barcodeAppRedemptionController.getEnablePrintLabels());
       	
       	barcodeAppRedemptionController.monoRedemptionCount = 2;
       	barcodeAppRedemptionController.processRedemption();
       	system.assertEquals(true, barcodeAppRedemptionController.getEnablePrintLabels());
        test.stopTest();
       	
       	CampaignMember updatedMonoCM = [SELECT Id, Redemption_Count__c FROM CampaignMember WHERE CM_Unique_ID__c = :monoCMcmid LIMIT 1];
       	system.assertEquals(0, updatedMonoCM.Redemption_Count__c);
       	Contact updatedMonoContact = [SELECT Id, Current_Segment__c FROM Contact WHERE Id = :monoContact.Id LIMIT 1];
       	system.assertEquals(1, updatedMonoContact.Current_Segment__c);
       	List<Mono_Contact_Redemption__c> mrList = [SELECT Id, Contact__c FROM Mono_Contact_Redemption__c WHERE Contact__c = :monoContact.Id];
       	system.assertEquals(2, mrList.size());

        // QRCodePrintController code coverage
        PageReference qrPageRef = new PageReference('/apex/QRCodePrint?cmid=' + monoCMcmid);
   	    Test.setCurrentPageReference(qrPageRef);
       	QRCodePrintController qrCodePrintController = new QRCodePrintController();
    }

    /**
     * Test campaign validation method
     */
    static testMethod void testValidateCampaign() {
    	Redemption_Config_Settings__c settings = Redemption_Config_Settings__c.getValues(Properties.BICESTER_VILLAGE_ACCOUNT_ID);
    	settings.Over_18_Required__c = true;
    	settings.Opt_In_Required__c = true;
    	update settings;
    	Contact bvContact = TestDataGenerator.setupContact(1, Properties.BICESTER_VILLAGE_ACCOUNT_ID, true);
    	Campaign testCampaign = TestDataGenerator.setupCampaign(1, false);
    	testCampaign.Campaign_Member_Redemption_Count__c = 2;
    	testCampaign.IsActive = false;
    	Date goodStartDate = testCampaign.StartDate;
    	Date goodEndDate = testCampaign.EndDate;
    	Date badStartDate = system.today();
    	badStartDate = badStartDate.addDays(+3);
    	Date badEndDate = system.today();
    	badEndDate = badEndDate.addDays(-3);
    	testCampaign.StartDate = badStartDate;
    	testCampaign.Active_Redemption_Segments__c = false;
    	insert testCampaign;
    	
    	CampaignMember bvCM = TestDataGenerator.setupCampaignMember(bvContact.Id, testCampaign.Id, true);
    	CampaignMember bvCM2 = [SELECT Id, CM_Unique_ID__c FROM CampaignMember WHERE Id = :bvCM.Id LIMIT 1];
        String bvCMcmid = bvCM2.CM_Unique_ID__c;
        system.debug('CMID: '+ bvCMcmid);

        test.startTest();
        PageReference pageRef = new PageReference('/apex/BarcodeAppRedemption?cmid=' + bvCMcmid);
   	    Test.setCurrentPageReference(pageRef);
       	BarcodeAppRedemptionController barcodeAppRedemptionController = new BarcodeAppRedemptionController();
       	system.assertEquals(false, barcodeAppRedemptionController.isValidCampaign);
    	testCampaign.IsActive = true;
    	update testCampaign;
    	barcodeAppRedemptionController.refresh();
       	system.assertEquals(false, barcodeAppRedemptionController.isValidCampaign);
       	testCampaign.StartDate = goodStartDate;
       	testCampaign.EndDate = badEndDate;
       	update testCampaign;
    	barcodeAppRedemptionController.refresh();
       	system.assertEquals(false, barcodeAppRedemptionController.isValidCampaign);
       	testCampaign.EndDate = goodEndDate;
       	update testCampaign;
    	barcodeAppRedemptionController.refresh();
       	system.assertEquals(false, barcodeAppRedemptionController.isValidCampaign);
    	testCampaign.Active_Redemption_Segments__c = true;
       	update testCampaign;
    	barcodeAppRedemptionController.refresh();
       	system.assertEquals(true, barcodeAppRedemptionController.isValidCampaign);
        test.stopTest();
    }
}