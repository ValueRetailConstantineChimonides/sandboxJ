/* BatchDataCardMigration

	Batch job for creating Customer_Activity__c records
	from existing Village Data Card contacts

*/
global class BatchDataCardMigration implements Database.Batchable<SObject> {
	global Logger logger;
	public map<String, Id> villageMap = new Map<String, Id>();
	
	global BatchDataCardMigration(){
		logger = LoggerFactory.getLogger('BatchDataCardMigration');
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
        logger = LoggerFactory.getLogger('BatchDataCardMigration');
        logger.log('BatchDataCardMigration START... ');

        return Database.getQueryLocator([SELECT Id, AccountId, CreatedDate, User_Login_ID__c,
        									    LeadSource, Migrated__c, Original_Creation_Date__c
                                         FROM Contact
                                         WHERE RecordTypeId = '01220000000CkczAAC' AND LeadSource = 'Village Registration Card'
                                         AND Migrated__c != true AND CreatedById = '00520000000vqQaAAI']);
	}	

	global void execute(Database.BatchableContext BC, List<Contact> cList){  
		logger.log('BatchDataCardMigration EXECUTE... '); 	
		system.debug('BatchDataCardMigration EXECUTE... '); 	
		logger.log('Records To Process: ' + cList.size()); 
		system.debug('Records To Process: ' + cList.size()); 
		system.debug('CONTACT LIST: ' + cList);
		List<Customer_Activity__c> caInsertList = new List<Customer_Activity__c>();
		List<String> errorList = new List<String>();
		
		try {
			for (Contact c : cList) {
				Customer_Activity__c caRec = new Customer_Activity__c();
				if (c.Original_Creation_Date__c != null) {
					caRec.Activity_Date__c = c.Original_Creation_Date__c;
				} else {
					caRec.Activity_Date__c = c.CreatedDate;
				}
				caRec.Activity_Quantity__c = 0;
				caRec.Activity_Text__c = 'Data Migration';
				caRec.Activity_Type__c = 'Visitor';
				caRec.Activity_Value__c = 0;
				caRec.Contact_Name__c = c.Id;
				caRec.Touchpoint_Reference__c = c.User_Login_ID__c;
				caRec.Touchpoint_Source__c = 'Data Migration';
				caRec.Touchpoint_Type__c = 'Village Registration Card';
				Id vid = villageMap.get(c.AccountId);
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
					Contact origRec = cList.get(pos);
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
			
			update cList;
			
		} catch (Exception ex){
   	 		logger.log('SYSTEM EXCEPTION: ' + ex.getMessage());
     	} finally {
   			logger.commitLog();
   		}
	}
	
    global void finish(Database.BatchableContext bc){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {'mpovey@valueretail.com'});
        mail.setReplyTo('mpovey@valueretail.com');
        mail.setSenderDisplayName('Batch Processing');
        mail.setSubject('Batch Data Card Migration Completed');
        String mailBody= 'Batch Process BatchDataCardMigration has completed';
        mail.setPlainTextBody(mailBody);
        mail.setSenderDisplayName('Batch Job');

		if (!Properties.IS_TEST_METHOD) {
	        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		}                         

		logger.log('BatchDataCardMigration COMPLETE... ');
		logger.commitLog();
	}
}