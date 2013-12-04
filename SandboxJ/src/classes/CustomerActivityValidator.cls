public without sharing class CustomerActivityValidator {
	private static PickListValidator pickListValidator;
	private static String b2cContactRecType = Properties.B2C_CONTACT_RECORD_TYPE;

	public static ValidationResult isCustomerActivityValid(Customer_Activity__c ca, Boolean addErrorsToFields) {
		system.debug('In CustomerActivityValidator.isCustomerActivityValid...');

		// Build validator if required
		if (pickListValidator == null) {
			pickListValidator = new PickListValidator();
		}
		
		if (!pickListValidator.getValidValuesMap().containsKey('TouchpointType')) {
			Schema.DescribeFieldResult touchpointTypeDFR = Customer_Activity__c.Touchpoint_Type__c.getDescribe();
			pickListValidator.buildFieldValueMaps('TouchpointType', touchpointTypeDFR);
		}
			
		if (!pickListValidator.getValidValuesMap().containsKey('ActivityType')) {
			Schema.DescribeFieldResult activityTypeDFR = Customer_Activity__c.Activity_Type__c.getDescribe();
			pickListValidator.buildFieldValueMaps('ActivityType', activityTypeDFR);
		}
		
		system.debug('Validation Map: ' + pickListValidator.getValidValuesMap());
		
		Boolean passedValidation = true;
		String validationMessage;

		if (!pickListValidator.isValidPickListValue('TouchpointType', ca.Touchpoint_Type__c)) {
			passedValidation = false;
			String thisMsg = 'Invalid Touchpoint Type specified: ' + ca.Touchpoint_Type__c;
			if (validationMessage == null || validationMessage.length() < 1) {
				validationMessage = thisMsg;
			} else {
				validationMessage += '; ' + thisMsg;
			}
			if (addErrorsToFields) {
				ca.Touchpoint_Type__c.addError(thisMsg);
			}
		}

		if (!pickListValidator.isValidPickListValue('ActivityType', ca.Activity_Type__c)) {
			passedValidation = false;
			String thisMsg = 'Invalid Activity Type specified: ' + ca.Activity_Type__c;
			if (validationMessage == null || validationMessage.length() < 1) {
				validationMessage = thisMsg;
			} else {
				validationMessage += '; ' + thisMsg;
			}
			if (addErrorsToFields) {
				ca.Activity_Type__c.addError(thisMsg);
			}
		}
		
		DateTime earliestDate = DateTime.newInstance(1995, 1, 1);
		DateTime tempDT = DateTime.now();
		tempDT = tempDT.addYears(2);
		DateTime latestDate = DateTime.newInstance(tempDT.year(), tempDT.month(), tempDT.day());
		
		if (ca.Activity_Date__c < earliestDate || ca.Activity_Date__c > latestDate) {
			passedValidation = false;
			String thisMsg;
			if (ca.Activity_Date__c < earliestDate) {
				thisMsg = 'Activity Date cannot be before ' + earliestDate.format();
			} else {
				thisMsg = 'Activity Date cannot be after ' + latestDate.format();
			}
			if (validationMessage == null || validationMessage.length() < 1) {
				validationMessage = thisMsg;
			} else {
				validationMessage += '; ' + thisMsg;
			}
			if (addErrorsToFields) {
				ca.Activity_Date__c.addError(thisMsg);
			}
		}

		return new ValidationResult(passedValidation, validationMessage);
	}

	/**
	 * ValidationResult class
	 */
	public class ValidationResult {
		private Boolean passedCheck;
		private String validationErrorMessage;
		
		public ValidationResult(Boolean passed, String errorText) {
			this.passedCheck = passed;
			this.validationErrorMessage = errorText;
		}

		public Boolean getPassedCheck() {
			return this.passedCheck;
		}
		
		public String getValidationErrorMessage() {
			return this.validationErrorMessage;
		}
	}

}