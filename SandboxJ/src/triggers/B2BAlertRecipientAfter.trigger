/**
	once alert is sent cleanup old recipient holders 
	and uncheck Send_Email_Alert__c on releted events 
*/
trigger B2BAlertRecipientAfter on B2B_Alert_Recipient__c (after update) {
	Set<Id> processedEventIds = new Set<Id>();
	Set<Id> unProcessedEventIds = new Set<Id>();
	for (B2B_Alert_Recipient__c recipientsHolder : trigger.new) {
		if (null != recipientsHolder.Sent__c) {
			processedEventIds.add(recipientsHolder.Event_Id__c);
		} else {
			unProcessedEventIds.add(recipientsHolder.Event_Id__c);
		}
	}
	//mark processed events as Sent
	System.debug('1.processedEventIds=' + processedEventIds);
	System.debug('1.unProcessedEventIds=' + unProcessedEventIds);
	processedEventIds.removeAll(unProcessedEventIds);
	System.debug('2.processedEventIds=' + processedEventIds);
	unProcessedEventIds.clear();
	
	//check what is not yet processed and was not included in current batch
	for (B2B_Alert_Recipient__c  holder : [select Id, Event_Id__c 
											from B2B_Alert_Recipient__c 
											where Event_Id__c in: B2BContactReportAlertGenerator.normaliseIds(processedEventIds)
											and Sent__c = null]) {
		unProcessedEventIds.add(holder.Event_Id__c);
		System.debug('3.unProcessedEventIds.add=' + holder.Event_Id__c);	
	}
	processedEventIds.removeAll(unProcessedEventIds);
	System.debug('4.processedEventIds=' + processedEventIds);
	
	final List<Event> eventsToMarkAsSent = new List<Event>();
	for (Id eventId : processedEventIds) {
		eventsToMarkAsSent.add(new Event(Id = eventId, Send_Email_Alert__c = false));
	}
	if (!eventsToMarkAsSent.isEmpty()) {
		System.debug('5.eventsToMarkAsSent=' + eventsToMarkAsSent);
		Database.update(eventsToMarkAsSent);
	}
}