public with sharing class BarcodeAppAddContactController {
	public Contact contact {get; set;}
	public Boolean duplicateFound {get; private set;}
	private Boolean multipleDuplicates;
	private String duplicateContactId;
	
	public BarcodeAppAddContactController() {
		contact = new Contact();
		contact.AccountId = VillageCrossReferencer.getUserVillageAccountId();
		contact.LeadSource = 'Barcode Application';
		contact.Lead_Source_Text__c = 'Barcode Application';
		contact.Validate_Record__c = true;
		duplicateFound = false;
		multipleDuplicates = false;
		duplicateContactId = null;
	}
	
	/**
	 * Logic for whether the Submit button should be enabled
	 */
	public Boolean getEnableSubmitButton() {
		if (contact.LastName == null || contact.LastName.length() < 1) {
			return false;
		}
		if (contact.FirstName == null || contact.FirstName.length() < 1) {
			return false;
		}
		if (contact.Email == null || contact.Email.length() < 1) {
			return false;
		}
		return true;
	}
	
	/**
	 * Return to Barcode Scanner screen
	 */
	public PageReference backToScan() {
		return Page.BarcodeAppScan;
	}

	/**
	 * Return to Customer Search screen
	 */
	public PageReference backToSearch() {
		return Page.BarcodeAppCustomerSearch;
	}
	
	/**
	 * Show duplicates in Customer Search screen
	 */
	public PageReference selectFromDuplicates() {
		PageReference pr = null;
		if (duplicateFound) {
			if (!multipleDuplicates && duplicateContactId != null) {
				pr = new PageReference('/apex/BarcodeAppCustomerSearch?contactid=' + duplicateContactId);
			} else {
				pr = new PageReference('/apex/BarcodeAppCustomerSearch?email=' + contact.Email + '&account=' + contact.AccountId);
			}
		}
		return pr;
	}

	/**
	 * Save new contact to Salesforce
	 */
	public PageReference submit() {
		contact.Current_Segment__c = 1;
		contact.RecordTypeId = Properties.B2C_CONTACT_RECORD_TYPE;
		ContactDataValidator.ValidationResult dupeCheckResult = ContactDataValidator.isContactDuplicate(contact);
		system.debug('Dupe check: ' + dupeCheckResult.getPassedCheck() + ', ' + dupeCheckResult.getValidationErrorMessage());
		if (!dupeCheckResult.getPassedCheck()) {
			contact.addError(dupeCheckResult.getValidationErrorMessage());
			List<Contact> dupeList = dupeCheckResult.getDuplicateList();
			if (dupeList != null && dupeList.size() > 0) {
				duplicateFound = true;
				if (dupeList.size() == 1) {
					duplicateContactId = dupeList.get(0).Id;
					multipleDuplicates = false;
				} else {
					duplicateContactId = null;
					multipleDuplicates = true;
				}
			}
			return null;
		}
		try {
			Database.SaveResult sr = Database.Insert(contact, true);
			if(!sr.isSuccess()) {
				Database.Error err = sr.getErrors()[0];
				ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Error adding contact: ' + err.getMessage()));
				return null;
			}
		} catch (DMLException dmlX) {
			system.debug('DMLException: ' + dmlX.getMessage());
			return null;
		} catch (Exception e) {
			system.debug('Other Exception: ' + e.getMessage());
			return null;
		}
		ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.CONFIRM, 'Contact Added: ' + contact.Id));
		PageReference pr = new PageReference('/apex/BarcodeAppCustomerSearch?contactid=' + contact.Id + '&showall=true');
		return pr;
	}
}