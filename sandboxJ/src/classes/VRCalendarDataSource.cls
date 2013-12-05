/*
 provides data for VRNet Calendar SControl based on the specified list of village names and date range
*/
global class VRCalendarDataSource {
	/*
		
	*/
	webService static EventAttendee[] loadEventAttendees(String eventId) {
		EventAttendee[] attendees = [Select Attendee.Name, Attendee.Type From EventAttendee where EventId =:eventId order by Attendee.Type, Attendee.Name];
		return attendees;
	}
	
	/*
		we have to return array with 1 element, otherwise returned result is not valid javascript SObject
	*/
	webService static Event[] loadEventDetails(String eventId) {
		Event event = null;
		try{
			event = [Select What.Name, Who.Name, Subject, Owner.Name From Event where id =:eventId];
		} catch (Exception e) {}
		return new Event[] {event};
	}
    
	/*
		Load long text fields of Event
		we have to return array with 1 element, otherwise returned result is not valid javascript SObject
	*/
	webService static Event[] loadAdditionalEventDetails(String eventId) {
		Event event = null;
		try{
			event = [Select Description, Non_VR_Outlet_Full_Price_Performance__c From Event where id =:eventId];
		} catch (Exception e) {}
		return new Event[] {event};
	}
    
	/*
	 	get all events based on provided owner ids and date range
	*/
	webService static Event[] loadEvents(String[] userIds, Date startDate, Date endDate, String[] meetingTypesInclude, String[] meetingTypesExclude) {
		System.debug('meetingTypesInclude=' + meetingTypesInclude);
		Event[] events;
		if (isNullArray(meetingTypesExclude)) {
				events = [select id, What.Name, ActivityDate, OwnerId from Event where IsChild = false and ActivityDate >=: startDate and 
					ActivityDate<=: endDate and OwnerId in :userIds and (Subject in :meetingTypesInclude) limit 1000];
		}
		else {
				events = [select id, What.Name, ActivityDate, OwnerId from Event where IsChild = false and ActivityDate >=: startDate and 
					ActivityDate<=: endDate and OwnerId in :userIds and (Subject in :meetingTypesInclude or Subject not in :meetingTypesExclude) limit 1000];
		}


		return events;
	}
	private static Boolean isNullArray(String[] arrayFromJavascript) {
		//due to conversions from Ajax if passed value of eventTypeIncludeFilter==null it ends up here as String[1]{''}
		//and this is why we have to use such a weird condition
		return arrayFromJavascript == null || arrayFromJavascript.size() ==1 && arrayFromJavascript[0] == ''; 
	}
	/*
	 	get all events based on provided owner ids and date range
	 	parameters meetingTypesInclude & meetingTypesExclude are not used but necessary for unification
	*/
	webService static Event[] loadEventsALL(String[] userIds, Date startDate, Date endDate,
											String[] meetingTypesInclude, String[] meetingTypesExclude) {
		System.debug('ALL events');
		//due to conversions from Ajax if passed value of eventTypeFilter==null it ends up here as String[1]{''}
		//ad this is why we have to use such a weird condition
		Event[] events = [select id, What.Name, ActivityDate, OwnerId from Event where IsChild = false and ActivityDate >=: startDate and 
						ActivityDate<=: endDate and OwnerId in :userIds limit 1000];
		return events;
	}
		
	/*
	 	get IDs of all users from specified villages
	 	@return array of strings "ID;VillageName" 
	*/
	webService static String[] getUserIds(String[] villageNames) {
		System.debug('Loading users');
		final User[] allUsers = [select id, CompanyName from User ALL ROWS];
		final List<String> userIdsList = new List<String>();
		for (User user : allUsers) {
			String companyName = user.CompanyName;
			if (companyName == null)
				continue;
			for (String villageName : villageNames) {
				if (companyName.startsWith(villageName)) {
					String userid = user.id;
					String value = userid + ';' + villageName;
					userIdsList.add(value);
				}		
			} 
		}
		final String[] userIds = new String[userIdsList.size()];
		Integer i = 0;
		for (String userIdAndVillage : userIdsList) {
			userIds[i] = userIdAndVillage;
			i++;
		}
		System.debug(String.valueOf(i) + ' loaded.');
		return userIds;
	}
	
	static testMethod void testLoadEvents1() {
    	final String[] VILLAGES = new  String[]{'Bicester', 'Fidenza', 'Ingolstadt', 'Kildare', 'La Roca', 'Las Rozas',
                                              /*'La Vall?e',*/ 'Maasmechelen', 'Wertheim'};
		
		String[] userIdAndVillages = getUserIds(VILLAGES);
		List<String> userIds = new List<String>();
		Integer i = 0;
		for (String userIdAndVillage: userIdAndVillages) {
			userIds.add(userIdAndVillage.substring(0, userIdAndVillage.indexOf(';')));	
		}
		Date today = System.today();
		Date startDate = today.addDays(-3);
		//events = loadEventsALL(userIds, startDate, today, new String[] {'Leasing/Commercialisation'}, new String[]{});
		
		System.debug('startDate=' + startDate);
		System.debug('today=' + today);
		Event[] events = loadEvents(userIds, startDate, today, new String[]{}, new String[]{});
		System.debug('1::events.size()=' + events.size());
		if (events.size()>0) {
			loadEventDetails(events[0].id);
			loadEventAttendees(events[0].id);
		}
	
	}
	static testMethod void testLoadEvents2() {
    	final String[] VILLAGES = new  String[]{'Bicester', 'Fidenza', 'Ingolstadt', 'Kildare', 'La Roca', 'Las Rozas',
                                              /*'La Vall?e',*/ 'Maasmechelen', 'Wertheim'};
		
		String[] userIdAndVillages = getUserIds(VILLAGES);
		List<String> userIds = new List<String>();
		Integer i = 0;
		for (String userIdAndVillage: userIdAndVillages) {
			userIds.add(userIdAndVillage.substring(0, userIdAndVillage.indexOf(';')));	
		}
		Date today = System.today();
		Date startDate = today.addDays(-3);
		//events = loadEventsALL(userIds, startDate, today, new String[] {'Leasing/Commercialisation'}, new String[]{});
		
		System.debug('startDate=' + startDate);
		System.debug('today=' + today);
		Event[] events = loadEvents(userIds, startDate, today, new String[] {'Leasing/Commercialisation'}, new String[]{});
		if (events.size()>0) {
			loadEventDetails(events[0].id);
			loadAdditionalEventDetails(events[0].id);
			loadEventAttendees(events[0].id);
		}
		
		System.debug('2::events.size()=' + events.size());
		
	}
	
}