@isTest(SeeAllData=true)
private class CustomerActivityValidatorTest {
    /**
     * Test the CustomerActivityValidator.isCustomerActivityValid(Customer_Activity__c ca, Boolean addErrorsToFields) method
     */
    static testMethod void testValidationCheck() {
    	Contact bicester1 = TestDataGenerator.setupContact(1, Properties.BICESTER_VILLAGE_ACCOUNT_ID, true);
    	Contact bicester2 = TestDataGenerator.setupContact(1, Properties.BICESTER_VILLAGE_ACCOUNT_ID, true);
    	DateTime tooEarly = DateTime.newInstance(1950, 1, 1);
    	DateTime tooLate = DateTime.now();
    	tooLate = tooLate.addYears(10);
    	Customer_Activity__c ca1 = new Customer_Activity__c(Activity_Date__c = system.today(), Activity_Quantity__c = 1, 
    														Activity_Text__c = 'TestXYZ', Activity_Type__c = 'Member', 
    														Activity_Value__c = 1, Touchpoint_Reference__c = 'TestXYZ', 
    														Touchpoint_Source__c = 'TEST1', Touchpoint_Type__c = 'Public Wifi',
    														Contact_Name__c = bicester1.Id);
    	Customer_Activity__c ca2 = new Customer_Activity__c(Activity_Date__c = system.today(), Activity_Quantity__c = 1, 
    														Activity_Text__c = 'TestXYZ', Activity_Type__c = 'Wibble', 
    														Activity_Value__c = 1, Touchpoint_Reference__c = 'TestXYZ', 
    														Touchpoint_Source__c = 'TEST1', Touchpoint_Type__c = 'Wibble',
    														Contact_Name__c = bicester2.Id);
    	Customer_Activity__c ca3 = new Customer_Activity__c(Activity_Date__c = tooEarly, Activity_Quantity__c = 1, 
    														Activity_Text__c = 'TestXYZ', Activity_Type__c = 'Member', 
    														Activity_Value__c = 1, Touchpoint_Reference__c = 'TestXYZ', 
    														Touchpoint_Source__c = 'TEST1', Touchpoint_Type__c = 'Public Wifi',
    														Contact_Name__c = bicester1.Id);
    	Customer_Activity__c ca4 = new Customer_Activity__c(Activity_Date__c = tooLate, Activity_Quantity__c = 1, 
    														Activity_Text__c = 'TestXYZ', Activity_Type__c = 'Member', 
    														Activity_Value__c = 1, Touchpoint_Reference__c = 'TestXYZ', 
    														Touchpoint_Source__c = 'TEST1', Touchpoint_Type__c = 'Public Wifi',
    														Contact_Name__c = bicester1.Id);
    	
    	test.startTest();
    	CustomerActivityValidator.ValidationResult vr1 = CustomerActivityValidator.isCustomerActivityValid(ca1, false);
    	CustomerActivityValidator.ValidationResult vr2 = CustomerActivityValidator.isCustomerActivityValid(ca2, true);
    	CustomerActivityValidator.ValidationResult vr3 = CustomerActivityValidator.isCustomerActivityValid(ca3, false);
    	CustomerActivityValidator.ValidationResult vr4 = CustomerActivityValidator.isCustomerActivityValid(ca4, true);
    	test.stopTest();
    	
    	system.debug('VALIDATION RESULT 1: ' + vr1);
    	system.debug('VALIDATION RESULT 2: ' + vr2);
    	system.debug('VALIDATION RESULT 3: ' + vr3);
    	system.debug('VALIDATION RESULT 4: ' + vr4);
    	system.assertEquals(true, vr1.getPassedCheck());
    	system.assertEquals(null, vr1.getValidationErrorMessage());
    	system.assertEquals(false, vr2.getPassedCheck());
    	system.assertNotEquals(null, vr2.getValidationErrorMessage());
    	system.assertEquals(false, vr3.getPassedCheck());
    	system.assertNotEquals(null, vr3.getValidationErrorMessage());
    	system.assertEquals(false, vr4.getPassedCheck());
    	system.assertNotEquals(null, vr4.getValidationErrorMessage());
    }
}