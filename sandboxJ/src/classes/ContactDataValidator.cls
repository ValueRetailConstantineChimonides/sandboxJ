public without sharing class ContactDataValidator {
	private static PickListValidator pickListValidator;
	
	public static ValidationResult isContactValid(Contact c, Boolean addErrorsToFields) {
		system.debug('In ContactDataValidator.isContactValid...');

		// Build validator if required
		if (pickListValidator == null) {
			pickListValidator = new PickListValidator();
		}

		if (!pickListValidator.getValidValuesMap().containsKey('Gender')) {
			Schema.DescribeFieldResult genderDFR = Contact.Gender__c.getDescribe();
			pickListValidator.buildFieldValueMaps('Gender', genderDFR);
		}
		if (!pickListValidator.getValidValuesMap().containsKey('ContactStatus')) {
			Schema.DescribeFieldResult csDFR = Contact.Contact_Status__c.getDescribe();
			pickListValidator.buildFieldValueMaps('ContactStatus', csDFR);
		}
		if (!pickListValidator.getValidValuesMap().containsKey('Country')) {
			Schema.DescribeFieldResult emcDFR = Contact.Mailing_Country_In_English__c.getDescribe();
			pickListValidator.buildFieldValueMaps('Country', emcDFR);
		}
		if (!pickListValidator.getValidValuesMap().containsKey('Language')) {
			Schema.DescribeFieldResult languageDFR = Contact.Preferred_language_of_communication__c.getDescribe();
			pickListValidator.buildFieldValueMaps('Language', languageDFR);
		}
		if (!pickListValidator.getValidValuesMap().containsKey('Nationality')) {
			Schema.DescribeFieldResult nationalityDFR = Contact.Nationality_Picklist__c.getDescribe();
			pickListValidator.buildFieldValueMaps('Nationality', nationalityDFR);
		}
		if (!pickListValidator.getValidValuesMap().containsKey('LeadSource')) {
			Schema.DescribeFieldResult leadSourceDFR = Contact.LeadSource.getDescribe();
			pickListValidator.buildFieldValueMaps('LeadSource', leadSourceDFR);
		}
		if (!pickListValidator.getValidValuesMap().containsKey('HighSpender')) {
			Schema.DescribeFieldResult highSpenderDFR = Contact.High_Spender_Status__c.getDescribe();
			pickListValidator.buildFieldValueMaps('HighSpender', highSpenderDFR);
		}
		if (!pickListValidator.getValidValuesMap().containsKey('EmailReader')) {
			Schema.DescribeFieldResult emailReaderDFR = Contact.EmailReaderStatus__c.getDescribe();
			pickListValidator.buildFieldValueMaps('EmailReader', emailReaderDFR);
		}
		
		system.debug('Validation Map: ' + pickListValidator.getValidValuesMap());
		
		Boolean passedValidation = true;
		String validationMessage;
		
		if (!isPhoneNumberValid(c.MobilePhone)) {
			passedValidation = false;
			String thisMsg = 'Invalid Mobile Number specified: ' + c.MobilePhone;
			if (validationMessage == null || validationMessage.length() < 1) {
				validationMessage = thisMsg;
			} else {
				validationMessage += '; ' + thisMsg;
			}
			if (addErrorsToFields) {
				c.MobilePhone.addError(thisMsg);
			}
		}
		
		if (!pickListValidator.isValidPickListValue('Gender', c.Gender__c)) {
			passedValidation = false;
			String thisMsg = 'Invalid Gender specified: ' + c.Gender__c;
			if (validationMessage == null || validationMessage.length() < 1) {
				validationMessage = thisMsg;
			} else {
				validationMessage += '; ' + thisMsg;
			}
			if (addErrorsToFields) {
				c.Gender__c.addError(thisMsg);
			}
		}

		if (!pickListValidator.isValidPickListValue('ContactStatus', c.Contact_Status__c)) {
			passedValidation = false;
			String thisMsg = 'Invalid Contact Status specified: ' + c.Contact_Status__c;
			if (validationMessage == null || validationMessage.length() < 1) {
				validationMessage = thisMsg;
			} else {
				validationMessage += '; ' + thisMsg;
			}
			if (addErrorsToFields) {
				c.Contact_Status__c.addError(thisMsg);
			}
		}

		if (!pickListValidator.isValidPickListValue('Country', c.Mailing_Country_In_English__c)) {
			passedValidation = false;
			String thisMsg = 'Invalid Mailing Country in English specified: ' + c.Mailing_Country_In_English__c;
			if (validationMessage == null || validationMessage.length() < 1) {
				validationMessage = thisMsg;
			} else {
				validationMessage += '; ' + thisMsg;
			}
			if (addErrorsToFields) {
				c.Mailing_Country_In_English__c.addError(thisMsg);
			}
		}

		if (!pickListValidator.isValidPickListValue('Language', c.Preferred_language_of_communication__c)) {
			passedValidation = false;
			String thisMsg = 'Invalid Communication Language specified: ' + c.Preferred_language_of_communication__c;
			if (validationMessage == null || validationMessage.length() < 1) {
				validationMessage = thisMsg;
			} else {
				validationMessage += '; ' + thisMsg;
			}
			if (addErrorsToFields) {
				c.Preferred_language_of_communication__c.addError(thisMsg);
			}
		}

		if (!pickListValidator.isValidPickListValue('Nationality', c.Nationality_Picklist__c)) {
			passedValidation = false;
			String thisMsg = 'Invalid Nationality specified: ' + c.Nationality_Picklist__c;
			if (validationMessage == null || validationMessage.length() < 1) {
				validationMessage = thisMsg;
			} else {
				validationMessage += '; ' + thisMsg;
			}
			if (addErrorsToFields) {
				c.Nationality_Picklist__c.addError(thisMsg);
			}
		}

		if (!pickListValidator.isValidPickListValue('LeadSource', c.LeadSource)) {
			passedValidation = false;
			String thisMsg = 'Invalid LeadSource specified: ' + c.LeadSource;
			if (validationMessage == null || validationMessage.length() < 1) {
				validationMessage = thisMsg;
			} else {
				validationMessage += '; ' + thisMsg;
			}
			if (addErrorsToFields) {
				c.LeadSource.addError(thisMsg);
			}
		}

		if (!pickListValidator.isValidPickListValue('HighSpender', c.High_Spender_Status__c)) {
			passedValidation = false;
			String thisMsg = 'Invalid High Spender Status specified: ' + c.High_Spender_Status__c;
			if (validationMessage == null || validationMessage.length() < 1) {
				validationMessage = thisMsg;
			} else {
				validationMessage += '; ' + thisMsg;
			}
			if (addErrorsToFields) {
				c.High_Spender_Status__c.addError(thisMsg);
			}
		}

		if (!pickListValidator.isValidPickListValue('EmailReader', c.EmailReaderStatus__c)) {
			passedValidation = false;
			String thisMsg = 'Invalid Email Reader Status specified: ' + c.EmailReaderStatus__c;
			if (validationMessage == null || validationMessage.length() < 1) {
				validationMessage = thisMsg;
			} else {
				validationMessage += '; ' + thisMsg;
			}
			if (addErrorsToFields) {
				c.EmailReaderStatus__c.addError(thisMsg);
			}
		}

		return new ValidationResult(passedValidation, validationMessage);
	}
	
	public static ValidationResult isContactDuplicate(Contact c) {
		system.debug('In ContactDataValidator.isContactDuplicate... Email = ' + c.Email + ', Account = ' + c.AccountId);
		if (String.isNotBlank(c.Email)) {
			List<Contact> checkList = [SELECT Id, LastName, FirstName, Email, Account.Name, Account.Id,
											  AccountId, Gender__c, Birthdate,
    										  I_am_18_years_old_or_more__c, HasOptedOutOfEmail, Mobile_Opt_Out__c,
    										  Postal_Opt_Out__c, Other_Village_Partner_Opt_Out__c, Profiling_Opt_Out__c,
    										  Mailing_Country_In_English__c, Preferred_language_of_communication__c,
    										  Nationality__c, MailingStreet, MailingCity, MailingState, MailingCountry,
    										  MailingPostalCode, MobilePhone, RecordTypeId, LeadSource, Lead_Source_Text__c,
    										  Original_Creation_Date__c, B2C_Password__c
									   FROM Contact
									   WHERE Email = :c.Email AND Account.Id = :c.AccountId];
			if (checkList != null && checkList.size() > 0) {
				system.debug('CheckList matches: ' + checkList);
				ValidationResult vr =  new ValidationResult(false, 'Duplicate contacts found', checkList);
				return vr;
			}
			system.debug('No duplicates found');
		} else {
			system.debug('No email address supplied');
		}
		return new ValidationResult(true, null);
	}
	
	public class ValidationResult {
		private Boolean passedCheck;
		private String validationErrorMessage;
		private List<Contact> duplicateList;
		
		public ValidationResult(Boolean passed, String errorText) {
			this(passed, errorText, null);
		}
		
		public ValidationResult(Boolean passed, String errorText, List<Contact> dupeList) {
			this.passedCheck = passed;
			this.validationErrorMessage = errorText;
			this.duplicateList = dupeList;
		}

		public Boolean getPassedCheck() {
			return this.passedCheck;
		}
		
		public String getValidationErrorMessage() {
			return this.validationErrorMessage;
		}
		
		public List<Contact> getDuplicateList() {
			return this.duplicateList;
		}
	}
	
	private static Boolean isPhoneNumberValid(String inNum) {
		String validCharacters = '1234567890()+- ';
		Boolean isValid = true;
		if (String.isNotBlank(inNum)) {
			for (Integer i = 0; i < inNum.length(); i++) {
				String compChar = inNum.substring(i, i+1);
				if (!validCharacters.contains(compChar)) {
					isValid = false;
					break;
				}
			}
		}
		return isValid;
	}
}