trigger CustomerActivityBeforeInsert on Customer_Activity__c (before insert) {
	for (Customer_Activity__c ca : Trigger.new) {
		CustomerActivityValidator.ValidationResult vr = CustomerActivityValidator.isCustomerActivityValid(ca, true);
	}
}