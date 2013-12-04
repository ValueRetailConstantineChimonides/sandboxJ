trigger ContactBeforeUpdate on Contact (before update) {
	Id b2cRecordTypeId = Properties.B2C_CONTACT_RECORD_TYPE;
	for (Contact c : Trigger.new) {
		if (c.RecordTypeId == b2cRecordTypeId && c.Validate_Record__c) {
			ContactDataValidator.ValidationResult vr = ContactDataValidator.isContactValid(c, true);
		}
		c.LastNameLocal = c.LastName;
		c.FirstNameLocal = c.FirstName;
	}
}