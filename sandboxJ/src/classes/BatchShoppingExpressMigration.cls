/* BatchShoppingExpressMigration

	Batch job for creating Customer_Activity__c records
	from existing Shopping Express data

*/
global class BatchShoppingExpressMigration implements Database.Batchable<SObject> {
	global Logger logger;
	public map<String, Id> villageMap = new Map<String, Id>();
	
	global BatchShoppingExpressMigration(){
		logger = LoggerFactory.getLogger('BatchShoppingExpressMigration');
		villageMap.put('Bicester', 'a0c20000001oaIPAAY');
		villageMap.put('Las Rozas', 'a0c20000001oaIJAAY');
		villageMap.put('La Roca', 'a0c20000001oaIQAAY');
		villageMap.put('Wertheim', 'a0c20000001oaIGAAY');
		villageMap.put('Maasmechelen', 'a0c20000001oaILAAY');
		villageMap.put('Fidenza', 'a0c20000001oaINAAY');
		villageMap.put('La Vallée', 'a0c20000001oaIHAAY');
		villageMap.put('Ingolstadt', 'a0c20000001oaIMAAY');
		villageMap.put('Kildare', 'a0c20000001oaIKAAY');
		logger.log('Village Map: ' + villageMap); 
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC){
        logger = LoggerFactory.getLogger('BatchShoppingExpressMigration');
        logger.log('BatchShoppingExpressMigration START... ');

        return Database.getQueryLocator([SELECT Id, XferDate1__c, PartySize__c, XferDeppt1__c, XferArrpt1__c,
        									    InvoiceValue__c, Contact__c, Name, h_Village_Name__c, CreatedDate,
        									    Contact__r.Account.Site
                                         FROM Resort_Hoppa_Transaction__c
                                         WHERE Migrated__c != true]);
	}	
	
	global void execute(Database.BatchableContext BC, List<Resort_Hoppa_Transaction__c> seList){  
		logger.log('BatchShoppingExpressMigration EXECUTE... '); 	
		system.debug('BatchShoppingExpressMigration EXECUTE... '); 	
		logger.log('Records To Process: ' + seList.size()); 
		system.debug('Records To Process: ' + seList.size()); 
		system.debug('SE LIST: ' + seList);
		List<Customer_Activity__c> caInsertList = new List<Customer_Activity__c>();
		List<String> errorList = new List<String>();
		
		try {
			for (Resort_Hoppa_Transaction__c seRec : seList) {
				Customer_Activity__c caRec = new Customer_Activity__c();
				if (seRec.XferDate1__c != null) {
					caRec.Activity_Date__c = seRec.XferDate1__c;
				} else {
					caRec.Activity_Date__c = seRec.CreatedDate;
				}
				caRec.Activity_Quantity__c = seRec.PartySize__c;
				caRec.Activity_Text__c = seRec.XferDeppt1__c + ' - ' + seRec.XferArrpt1__c;
				caRec.Activity_Type__c = 'Visitor';
				if (seRec.InvoiceValue__c != null && seRec.InvoiceValue__c >= 0) {
					caRec.Activity_Value__c = seRec.InvoiceValue__c;
				}
				caRec.Contact_Name__c = seRec.Contact__c;
				caRec.Touchpoint_Reference__c = seRec.Name;
				caRec.Touchpoint_Source__c = 'Shopping Express Data Migration';
				caRec.Touchpoint_Type__c = 'Shopping Express';
				if (villageMap.containsKey(seRec.h_Village_Name__c)) {
					Id vid = villageMap.get(seRec.h_Village_Name__c);
					caRec.Village__c = vid;
				} else {
					system.debug('VILLAGE CODE IS: ' + seRec.Contact__r.Account.Site);
					Id vid = VillageCrossReferencer.getVillageIdByCode(seRec.Contact__r.Account.Site);
					system.debug('VILLAGE ID IS: ' + vid);
					if (vid != null) {
						caRec.Village__c = vid;
					}
				}
				caInsertList.add(caRec);
			}
			
			system.debug('CA INSERT LIST: ' + caInsertList);
			
			if (caInsertList.size() > 0) {
	       	    List<Database.SaveResult> caInsertResults = Database.insert(caInsertList, false);
				Integer pos = 0;
				Integer successCnt = 0;
				Integer failCnt = 0;
				for (Database.SaveResult sr : caInsertResults) {
					Resort_Hoppa_Transaction__c origRec = seList.get(pos);
					if (sr.isSuccess()) {
						origRec.Migrated__c = true;
						successCnt++;
					} else {
						String errorMsg = 'Error on ' + origRec.Id + ': ' + sr.getErrors();
						errorList.add(errorMsg);
						failCnt++;
					}
					pos++;
				}
				logger.log('SUCCESS COUNT: ' + successCnt);
				system.debug('SUCCESS COUNT: ' + successCnt);
				logger.log('FAILURE COUNT: ' + failCnt);
				system.debug('FAILURE COUNT: ' + failCnt);
				if (errorList.size() > 0) {
					logger.log('ERRORS: ' + errorList);
					system.debug('ERRORS: ' + errorList);
				} else {
					logger.log('NO ERRORS');
				}
			}
			
			update seList;
			
		} catch (Exception ex){
   	 		logger.log('SYSTEM EXCEPTION: ' + ex.getMessage());
     	} finally {
   			logger.commitLog();
   		}
	}
	
    global void finish(Database.BatchableContext bc){
		logger.log('BatchShoppingExpressMigration COMPLETE... ');
		logger.commitLog();
	}
}