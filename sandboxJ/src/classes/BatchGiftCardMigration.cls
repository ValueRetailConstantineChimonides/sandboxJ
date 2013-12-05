/* BatchGiftCardMigration

	Batch job for creating Customer_Activity__c records
	from existing Gift Card data

*/
global class BatchGiftCardMigration implements Database.Batchable<SObject> {
	global Logger logger;
	public map<String, Id> villageMap = new Map<String, Id>();
	
	global BatchGiftCardMigration(){
		logger = LoggerFactory.getLogger('BatchGiftCardMigration');
		villageMap.put('001200000032qrCAAQ', 'a0c20000001oaIPAAY'); // Bicester
		villageMap.put('001200000032r14AAA', 'a0c20000001oaIJAAY'); // Las Rozas
		villageMap.put('001200000032r0VAAQ', 'a0c20000001oaIQAAY'); // La Roca
		villageMap.put('001200000032r28AAA', 'a0c20000001oaIGAAY'); // Wertheim
		villageMap.put('001200000032r20AAA', 'a0c20000001oaILAAY'); // Maasmechelen
		villageMap.put('001200000032r25AAA', 'a0c20000001oaINAAY'); // Fidenza
		villageMap.put('001200000032r1aAAA', 'a0c20000001oaIHAAY'); // La Vallee
		villageMap.put('001200000032r2FAAQ', 'a0c20000001oaIMAAY'); // Ingolstadt
		villageMap.put('001200000032r2AAAQ', 'a0c20000001oaIKAAY'); // Kildare
		logger.log('Village Map: ' + villageMap);
	} 

	global Database.QueryLocator start(Database.BatchableContext BC){
        logger = LoggerFactory.getLogger('BatchGiftCardMigration');
        logger.log('BatchGiftCardMigration START... ');

        return Database.getQueryLocator([SELECT Id, Contact__c, Registration_Date__c, Amount__c,
        									    Village_ID__c, Source__c, Name
                                         FROM Gift_Card__c
                                         WHERE Migrated__c != true]);
	}	
	
	global void execute(Database.BatchableContext BC, List<Gift_Card__c> gcList){  
		logger.log('BatchGiftCardMigration EXECUTE... '); 	
		system.debug('BatchGiftCardMigration EXECUTE... '); 	
		logger.log('Records To Process: ' + gcList.size()); 
		system.debug('Records To Process: ' + gcList.size()); 
		system.debug('GC LIST: ' + gcList);
		List<Customer_Activity__c> caInsertList = new List<Customer_Activity__c>();
		List<String> errorList = new List<String>();
		
		try {
			for (Gift_Card__c gcRec : gcList) {
				Customer_Activity__c caRec = new Customer_Activity__c();
				caRec.Activity_Date__c = gcRec.Registration_Date__c;
				caRec.Activity_Quantity__c = 0;
				caRec.Activity_Text__c = 'Data Migration';
				caRec.Activity_Type__c = 'Member';
				caRec.Activity_Value__c = gcRec.Amount__c;
				caRec.Contact_Name__c = gcRec.Contact__c;
				caRec.Touchpoint_Reference__c = gcRec.Name;
				caRec.Touchpoint_Source__c = 'Online';
				caRec.Touchpoint_Type__c = 'Gift Card Purchase';
				Id vid = villageMap.get(gcRec.Village_ID__c);
				caRec.Village__c = vid;
				caInsertList.add(caRec);
			}
			
			system.debug('CA INSERT LIST: ' + caInsertList);
			
			if (caInsertList.size() > 0) {
	       	    List<Database.SaveResult> caInsertResults = Database.insert(caInsertList, false);
				Integer pos = 0;
				Integer successCnt = 0;
				Integer failCnt = 0;
				for (Database.SaveResult sr : caInsertResults) {
					Gift_Card__c origRec = gcList.get(pos);
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
			
			update gcList;
			
		} catch (Exception ex){
   	 		logger.log('SYSTEM EXCEPTION: ' + ex.getMessage());
     	} finally {
   			logger.commitLog();
   		}
	}
	
    global void finish(Database.BatchableContext bc){
		logger.log('BatchGiftCardMigration COMPLETE... ');
		logger.commitLog();
	}
}