@isTest(SeeAllData=true)
private class ContactDataValidatorTest {
    /**
     * Test the ContactDataValidator.isContactDuplicate(Contact c) method
     */
    static testMethod void testDuplicationCheck() {
    	test.startTest();
    	Contact bicester1 = TestDataGenerator.setupContact(1, Properties.BICESTER_VILLAGE_ACCOUNT_ID, false);
    	ContactDataValidator.ValidationResult vr = ContactDataValidator.isContactDuplicate(bicester1);
    	system.assertEquals(true, vr.getPassedCheck());
    	system.assertEquals(null, vr.getValidationErrorMessage());
    	system.assertEquals(null, vr.getDuplicateList());
    	insert bicester1;
    	Contact bicester2 = TestDataGenerator.setupContact(1, Properties.BICESTER_VILLAGE_ACCOUNT_ID, false);
    	ContactDataValidator.ValidationResult vr2 = ContactDataValidator.isContactDuplicate(bicester2);
    	system.assertEquals(false, vr2.getPassedCheck());
    	system.assertEquals('Duplicate contacts found', vr2.getValidationErrorMessage());
    	system.assertEquals(1, vr2.getDuplicateList().size());
    	insert bicester2;
    	ContactDataValidator.ValidationResult vr3 = ContactDataValidator.isContactDuplicate(bicester2);
    	system.assertEquals(false, vr3.getPassedCheck());
    	system.assertEquals('Duplicate contacts found', vr3.getValidationErrorMessage());
    	system.assertEquals(2, vr3.getDuplicateList().size());
    	test.stopTest();
    }
    
    /**
     * Test the ContactDataValidator.isContactValid(Contact c) method
     */
    static testMethod void testValidationCheck() {
    	test.startTest();
    	Contact bicester1 = TestDataGenerator.setupContact(1, Properties.BICESTER_VILLAGE_ACCOUNT_ID, false);
    	bicester1.MobilePhone = 'Mobile Number';
    	bicester1.Gender__c = 'Cannot Decide';
    	bicester1.Preferred_language_of_communication__c = 'Gobbledigook';
    	bicester1.Mailing_Country_In_English__c = 'Middle Earth';
    	bicester1.High_Spender_Status__c = 'Scrooge';
    	bicester1.EmailReaderStatus__c = 'Luddite';
    	ContactDataValidator.ValidationResult vr = ContactDataValidator.isContactValid(bicester1, true);
    	system.debug('VALIDATION RESULT: ' + vr);
    	system.assertEquals(false, vr.getPassedCheck());
    	system.assertNotEquals(null, vr.getValidationErrorMessage());
    	system.assertEquals(null, vr.getDuplicateList());
    	bicester1.MobilePhone = '07123 456789';
    	bicester1.Contact_Status__c = 'Active';
    	bicester1.Gender__c = 'Unknown';
    	bicester1.Preferred_language_of_communication__c = 'English';
    	bicester1.Mailing_Country_In_English__c = 'UNITED KINGDOM';
    	bicester1.LeadSource = 'Other';
    	bicester1.Nationality_Picklist__c = 'British';
    	bicester1.High_Spender_Status__c = 'High';
    	bicester1.EmailReaderStatus__c = 'Unknown';
    	ContactDataValidator.ValidationResult vr2 = ContactDataValidator.isContactValid(bicester1, false);
    	system.debug('VALIDATION RESULT 2: ' + vr2);
    	system.assertEquals(true, vr2.getPassedCheck());
    	system.assertEquals(null, vr2.getValidationErrorMessage());
    	system.assertEquals(null, vr2.getDuplicateList());
    	test.stopTest();
    }
}