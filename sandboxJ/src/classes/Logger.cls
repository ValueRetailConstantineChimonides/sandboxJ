public without sharing class Logger {

   private String logType;
   private String toAppend;

	public Logger(String logType) {
    	this.toAppend = '';
   		this.logType = logType;
   	}

   	public void log(String message) {
   		
   		System.Debug(message);
      	toAppend = toAppend + '\n' + System.now().format() + ': ' + message;
   	}


   public void commitLog() {
   		try {
   			System.debug('Committing Log: ' + toAppend);
         	LogFile__c log = createLog();
         	if(!Properties.IS_TEST_METHOD){
      			insert log;
         	}
      		toAppend='';
   		} catch (Exception e) {
   			System.debug('Failed to commit logs: ' + e);
   		}
   }

   private LogFile__c createLog() {
   		LogFile__c log = new LogFile__c();
      	log.Type__c = logType;
      	log.Date__c = System.today();
        log.Date_Time_Created__c = System.now();
      	
      	if (toAppend.length() > 32000) {
      		toAppend = toAppend.substring(0, 31999);
      	}
      	log.Body__c = toAppend;
      	return log;
   }
}