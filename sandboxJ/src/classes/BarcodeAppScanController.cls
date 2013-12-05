public with sharing class BarcodeAppScanController {
	public String scannedId {get; set;}
	
	/**
	 * Navigate to Customer Search screen
	 */
	public PageReference contactSearch() {
		return Page.BarcodeAppCustomerSearch;
	}
	
	/**
	 * Submit scanned barcode
	 */
	public PageReference save() {
        if (scannedId == null || scannedId.length() == 0) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'You must scan or enter a barcode'));
			return null;
        } else {
	        List<CampaignMember> cmList = [SELECT Id
    	    							   FROM CampaignMember
        								   WHERE CM_Unique_ID__c = :scannedId];
	       	if (cmList == null || cmList.size() == 0) {
				ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'No matching records found for ID: ' + scannedId + '. It may be invalid or belong to another village. Please retry or perform a manual search.'));
				clear();
				return null;
       		} else if (cmList.size() > 1) {
				ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Multiple records found for ID: ' + scannedId + '. Please perform a manual search to locate the correct customer.'));
				clear();
				return null;
    	   	} else {
				PageReference pr = new PageReference('/apex/BarcodeAppRedemption?cmid=' + scannedId);
				return pr;
       		}
        }
	}
	
	/**
	 * Clear barcode field
	 */
	public void clear() {
		scannedId = null;
	}
}