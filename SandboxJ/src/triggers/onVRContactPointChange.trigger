/*  ENG-0711-58
	Auto-update Contact field based on VR Contact Point
	On Insert or update of VR Contact Point 'Christmas Card Signer' equals 'Main' update 
	the associated named Contact field 'Main Christmas Card Signer (Lookup)' with the name of the VR Contact Point. 
*/
trigger onVRContactPointChange on VR_Point_of_Contact__c (after insert, after update, after delete, after undelete) {
	final String MAIN_CODE = 'Main';

	if (Trigger.isDelete) {
		//clear Main_Christmas_Card_Signer_Lookup__c of associated contacts
		final List<VR_Point_of_Contact__c> oldPoints = Trigger.old;
		final Map<ID, Contact> contactsToClearMap = new Map<ID, Contact>();
		
		for (VR_Point_of_Contact__c point : oldPoints) {
			if (MAIN_CODE != point.Christmas_Card_Signer__c)
				continue;
			if (point.VR_Contact_Point__c <> null) {
				final Contact contactToClear = new Contact(id = point.VR_Contact_Point__c, Main_Christmas_Card_Signer_Lookup__c = null);
				contactsToClearMap.put(contactToClear.id, contactToClear);	
			}	
		}
		if (contactsToClearMap.size() >0) {
			update contactsToClearMap.values();
		}

		return;
	}
	final List<VR_Point_of_Contact__c> points = Trigger.new;
	final Map<ID, Boolean> involvedContactsMap = new Map<ID, Boolean>();
	
	if (Trigger.isUpdate) {
		final Map<ID, Contact> contactsToClearMap = new Map<ID, Contact>();
		//clear links to VR_Employee__c from all contacts where VR_Point_of_Contact__c is not 'Main' anymore
		final Map<ID, VR_Point_of_Contact__c> oldPointsMap = Trigger.oldMap;
		for (VR_Point_of_Contact__c point : points) {
			if (MAIN_CODE != point.Christmas_Card_Signer__c && MAIN_CODE == oldPointsMap.get(point.id).Christmas_Card_Signer__c) {
				if (point.VR_Contact_Point__c <> null) {
					involvedContactsMap.put(point.VR_Contact_Point__c, false);
					final Contact contactToClear = new Contact(id = point.VR_Contact_Point__c, Main_Christmas_Card_Signer_Lookup__c = null);
					contactsToClearMap.put(contactToClear.id, contactToClear);
				}	
			}	
		}
		//clear Main_Christmas_Card_Signer_Lookup__c from all contacts where associated Contact Point is no longer 'Main'
		if (contactsToClearMap.size() >0) {
			update contactsToClearMap.values();
		}
		
	}
	
	final Map<ID, VR_Point_of_Contact__c> newMainPointsMap = new Map<ID, VR_Point_of_Contact__c>();
	involvedContactsMap.clear();
	//collect all points with MAIN_CODE flag
	for (VR_Point_of_Contact__c point : points) {
		if (point.VR_Employee__c == null)
			continue;
		if (MAIN_CODE == point.Christmas_Card_Signer__c) {
			newMainPointsMap.put(point.Id, point);
			if (point.VR_Contact_Point__c <> null)
				involvedContactsMap.put(point.VR_Contact_Point__c, true);	
		}	
	}
	
	//check if there are other 'Main' Contact Points attached to contacts involved in newMainPointsMap
	final VR_Point_of_Contact__c[] currentMainPoints = [select id, VR_Contact_Point__c from VR_Point_of_Contact__c where
														(id not in: newMainPointsMap.keySet()) and 
														(Christmas_Card_Signer__c =: MAIN_CODE) and 
														(VR_Contact_Point__c in: involvedContactsMap.keySet()) ];
	Boolean hasErrors = false; 													 
	for (VR_Point_of_Contact__c cp : currentMainPoints)	 {
		points[0].Christmas_Card_Signer__c.addError('Only one "Main" Christmas Card Signer per Contact is allowed');
		hasErrors = true;	
	}
	if (hasErrors)
		return;//no reason to continue processing, because there are errors in the batch
	
	//load all involved contacts
	final Map<ID, Contact> contactsMap = new Map<ID, Contact> ([select id, Main_Christmas_Card_Signer_Lookup__c from Contact where id in: involvedContactsMap.keySet()]);
	final Map<ID, Contact> contactsToUpdateMap = new Map<ID, Contact>(); 
	if (contactsMap.size() >0) {
		//for each contact check if we need to change Main_Christmas_Card_Signer_Lookup__c and if necessary - change
		for (VR_Point_of_Contact__c cp: newMainPointsMap.values()) {
			ID contactId = cp.VR_Contact_Point__c;
			Contact contactToUpdate = contactsMap.get(contactId);
			if (contactToUpdate == null)
				continue;
			contactToUpdate.Main_Christmas_Card_Signer_Lookup__c = cp.VR_Employee__c;
			contactsToUpdateMap.put(contactToUpdate.id, contactToUpdate);	
		}
		//update contacts
		if (contactsToUpdateMap.size() >0) {
			update contactsToUpdateMap.values();
		}		
	}
}