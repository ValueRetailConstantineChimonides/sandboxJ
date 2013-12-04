/* BatchWifiMigration

	Batch job for creating Customer_Activity__c records
	from existing Wifi data

*/
global class BatchWifiMigration implements Database.Batchable<SObject> {
	global Logger logger;
	public map<String, Id> campaignMap = new Map<String, Id>();
	public map<Id, Id> villageMap = new Map<Id, Id>();
	
	global BatchWifiMigration(){
		logger = LoggerFactory.getLogger('BatchWifiMigration');
		villageMap.put('70120000000NT90AAG', 'a0c20000001oaIPAAY');
		villageMap.put('70120000000NT9jAAG', 'a0c20000001oaINAAY');
		villageMap.put('70120000000NT9eAAG', 'a0c20000001oaIMAAY');
		villageMap.put('70120000000NT9AAAW', 'a0c20000001oaIKAAY');
		villageMap.put('70120000000NT9FAAW', 'a0c20000001oaIQAAY');
		villageMap.put('70120000000NT9KAAW', 'a0c20000001oaIHAAY');
		villageMap.put('70120000000NT9PAAW', 'a0c20000001oaIJAAY');
		villageMap.put('70120000000NT9UAAW', 'a0c20000001oaILAAY');
		villageMap.put('70120000000NT9ZAAW', 'a0c20000001oaIGAAY');
		logger.log('Village Map: ' + villageMap); 
		campaignMap.put('Bicester', '70120000000NT90AAG');
		campaignMap.put('Fidenza', '70120000000NT9jAAG');
		campaignMap.put('Ingolstadt', '70120000000NT9eAAG');
		campaignMap.put('Kildare', '70120000000NT9AAAW');
		campaignMap.put('La Roca', '70120000000NT9FAAW');
		campaignMap.put('La Vallée', '70120000000NT9KAAW');
		campaignMap.put('Las Rozas', '70120000000NT9PAAW');
		campaignMap.put('Maasmechelen', '70120000000NT9UAAW');
		campaignMap.put('Wertheim', '70120000000NT9ZAAW');
		logger.log('Campaign Map: ' + campaignMap); 
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC){
        logger = LoggerFactory.getLogger('BatchWifiMigration');
        logger.log('BatchWifiMigration START... ');
        List<Id> campList = campaignMap.values();

        return Database.getQueryLocator([SELECT Id, CreatedDate, ContactId, CampaignId, CM_Unique_ID__c,
        										FirstRespondedDate, Migrated__c
                                         FROM CampaignMember
                                         WHERE CampaignId IN :campList AND Migrated__c != true]);
	}	
	
	global void execute(Database.BatchableContext BC, List<CampaignMember> cmList){  
		logger.log('BatchWifiMigration EXECUTE... '); 	
		system.debug('BatchWifiMigration EXECUTE... '); 	
		logger.log('Records To Process: ' + cmList.size()); 
		system.debug('Records To Process: ' + cmList.size()); 
		system.debug('CM LIST: ' + cmList);
		List<Customer_Activity__c> caInsertList = new List<Customer_Activity__c>();
		List<String> errorList = new List<String>();
		
		try {
			for (CampaignMember cmRec : cmList) {
				Customer_Activity__c caRec = new Customer_Activity__c();
				caRec.Activity_Date__c = cmRec.FirstRespondedDate;
				caRec.Activity_Quantity__c = 0;
				caRec.Activity_Text__c = 'Registration';
				caRec.Activity_Type__c = 'Visitor';
				caRec.Activity_Value__c = 0;
				caRec.Contact_Name__c = cmRec.ContactId;
				caRec.Touchpoint_Reference__c = cmRec.CM_Unique_ID__c;
				caRec.Touchpoint_Source__c = 'Data Migration';
				caRec.Touchpoint_Type__c = 'Public Wifi';
				Id vid = villageMap.get(cmRec.CampaignId);
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
					CampaignMember origRec = cmList.get(pos);
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
			
			update cmList;
			
		} catch (Exception ex){
   	 		logger.log('SYSTEM EXCEPTION: ' + ex.getMessage());
     	} finally {
   			logger.commitLog();
   		}
	}
	
    global void finish(Database.BatchableContext bc){
		logger.log('BatchWifiMigration COMPLETE... ');
		logger.commitLog();
	}

}