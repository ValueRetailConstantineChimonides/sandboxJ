public class B2BEventVisibilityController {
    public Event dummyEvent {get;set;}
    public Boolean filterAllSubjectTypes {get;set;}
    public String timeOffSetHolder {get;set;}
    
    public String selectedEventId {get;set;}
    
    
    private B2BAlertViewGenerator viewGenerator;
    private static final String GROUP_V = 'Group';
    private static final String GRS_V = 'GRS';
    
    public B2BEventVisibilityController(DateTime filterStartDate){
        dummyEvent = new Event();
        viewGenerator = new B2BAlertViewGenerator();
        initViewData(filterStartDate);
        
        refreshView();
    }
    public B2BEventVisibilityController(ApexPages.StandardController stdController){
        dummyEvent = (Event)stdController.getRecord();
        viewGenerator = new B2BAlertViewGenerator();
        initViewData(null);
        
        refreshView();
    }
    private static final String columBackground_A = 'background-color: #E8E8E8  ;padding : 2px ; border:3px solid #FFFFFF;';
    private static final String columBackground_B='background-color: #F8F8F8 ;padding : 2px; border:3px solid #FFFFFF;';
    
    public String columBackground{get{
        if(columBackground == columBackground_A){
            columBackground =columBackground_B;
        }else{
            columBackground =columBackground_A;
        }
        return columBackground;
            
    }
        set;}
    
    private void initViewData(DateTime filterStartDate){
        filterAllSubjectTypes = true;
        renderVillageCategorization = null;
        renderDateList = null;
        
        // added to allow viewing a week ahead or as needed on page first access
        if(null != filterStartDate){
            dummyEvent.StartDateTime = filterStartDate;
        }else{
            dummyEvent.StartDateTime = System.now();
        }
        
        renderVillageEventsByDate = null;
        backgroundCollorMap = null;
        renderDetailWindow = false;
    }
    
    private List<FiltersubjectItem> filterSubjectTypes;
    public List<FiltersubjectItem> getFilterSubjectTypes(){
        if(null != filterSubjectTypes && filterSubjectTypes.size()> 0){
            return filterSubjectTypes;
        }else{
            filterSubjectTypes = loadFilterSubjectTypes();
            return filterSubjectTypes;
        }
        
    }

        
    private Set<String> describeSubjectPickList(){
        return viewGenerator.describeSubjectPickList();
        
    }
    
    private List<String> describeEventVillageCategory(){
        return viewGenerator.describeEventVillageCategory();
        
    }
    
    private List<FiltersubjectItem> loadFilterSubjectTypes(){
        List<FiltersubjectItem> retunFilterList = new List<FiltersubjectItem>();
        
        Set<String> filterOptions = describeSubjectPickList();
        
        // Create the List of PiCK Objects
        for(String optionsLabel : filterOptions){
            FiltersubjectItem afilterItem = new  FiltersubjectItem();
            afilterItem.subjectText = optionsLabel;
            
            retunFilterList.add(afilterItem);
        }
        return retunFilterList;
    }
    
    public void loadAnEventDetail(){
        String selectedEventIdForDetail = ApexPages.currentPage().getParameters().get('detailEventId');
        selectedEventId = selectedEventIdForDetail;
        
        detailPageSrc = 'apex/B2BEventDetail?theEventId='+selectedEventId;
        renderDetailWindow = true;
        
    }

    public Boolean renderDetailWindow {get;set;}
    public String detailPageSrc {get;set;}
    
    public void closeDetailWindow(){
        renderDetailWindow = false;
    }
    
    
    public void refreshView(){
        renderDateList = null;
        renderVillageEventsByDate = null;
        
        
        doCallForEventsData();
        
    }
    
    public void refreshViewPreviousWeek(){
        renderDateList = null;
        renderVillageEventsByDate = null;
        
        dummyEvent.StartDateTime = (DateTime.valueOf(dummyEvent.StartDateTime)).addDays(-7);
        
        doCallForEventsData();
        
    }
    
    public void refreshViewNextWeek(){
        renderDateList = null;
        renderVillageEventsByDate = null;
        
        dummyEvent.StartDateTime = (DateTime.valueOf(dummyEvent.StartDateTime)).addDays(7);
        
        doCallForEventsData();
        
    }
    
    private Map<String,String> backgroundCollorMap;
    public Map<String,String> getBackgroundCollorMap(){
        if(backgroundCollorMap == null){
            backgroundCollorMap = new Map<String,String>();
            for(String aVillageOpt : getRenderVillageCategorization()){
                backgroundCollorMap.put(aVillageOpt,columBackground);
            }
        }
        return backgroundCollorMap;
    }
    
    private Map<Date,Map<String,List<Event>>> initializeViewMap(){
            Map<Date,Map<String,List<Event>>> eventViewDataByVillageAndDate = new Map<Date,Map<String,List<Event>>>();
            
            for(Date aDate : getRenderDateList()){
                Map<String,List<Event>> villageEventsMap = new Map<String,List<Event>>();
                for(String aVillageOption  : describeEventVillageCategory()){
                    // Create the Event List
                    villageEventsMap.put(aVillageOption,new List<Event>());
                }
                eventViewDataByVillageAndDate.put(aDate,villageEventsMap);
                
            }
            
            return eventViewDataByVillageAndDate;
    }
    
    private List<String> renderVillageCategorization;
    private List<Date> renderDateList;
    
    public Map<String,List<Event>> mondayEvents { get{
            return  getRenderVillageEventsByDate().get( (getRenderDateList().get(0))  );
        }
    }
    public Map<String,List<Event>> tuesdayEvents { get{
            return getRenderVillageEventsByDate().get( (getRenderDateList().get(1))  );
        }
    }
    public Map<String,List<Event>> wednesdayEvents { get{
            return getRenderVillageEventsByDate().get( (getRenderDateList().get(2))  );
        }
    }
    public Map<String,List<Event>> thursdayEvents { get{
            return getRenderVillageEventsByDate().get( (getRenderDateList().get(3))  );
        }
    }
    public Map<String,List<Event>> fridayEvents { get{
            return getRenderVillageEventsByDate().get( (getRenderDateList().get(4))  );
        }
    }
    public Map<String,List<Event>> saturdayEvents{ get{
            return getRenderVillageEventsByDate().get( (getRenderDateList().get(5))  );
        }
    }
    
    public Map<String,List<Event>> sundayEvents{ get{
            return getRenderVillageEventsByDate().get( (getRenderDateList().get(6))  );
        }
    }
    
    public Date mondayDate { get{
            return getRenderDateList().get(0);
        }
    }
    public Date tuesdayDate { get{
            return getRenderDateList().get(1);
        }
    }
    public Date wednesdayDate { get{
            return getRenderDateList().get(2);
        }
    }
    public Date thursdayDate { get{
            return getRenderDateList().get(3);
        }
    }
    public Date fridayDate { get{
            return getRenderDateList().get(4);
        }
    }
    public Date saturdayDate { get{
            return getRenderDateList().get(5);
        }
    }
    
    public Date sundayDate { get{
            return getRenderDateList().get(6);
        }
    }
    
    public List<Date> getRenderDateList(){
            if(renderDateList == null ){
                renderDateList = new List<Date>();
                
                DateTime viewDate = DateTime.newInstanceGmt(dummyEvent.StartDateTime.date(), dummyEvent.StartDateTime.time());
                Date renderStartDate = viewDate.date().toStartOfWeek();
            
                for(Integer dayCounter = 0;dayCounter < 7 ; dayCounter++){
                    Date renderDate = renderStartDate.addDays(dayCounter);
                    renderDateList.add(renderDate);
                }
            }
            
        return renderDateList;
    }
    
    public List<String> getRenderVillageCategorization(){
        if(renderVillageCategorization == null){
            renderVillageCategorization = describeEventVillageCategory();
        }
        return renderVillageCategorization;
    }
    
    public void doCallForEventsData(){
        Set<String> filterSubject = new Set<String>();
        if(filterAllSubjectTypes){
            // Get All
            filterSubject = describeSubjectPickList();
        }else{
            // Get selection
                for(FiltersubjectItem aFilterOption: getFilterSubjectTypes()){
                    if(aFilterOption.selectedForFiltering == true){
                        filterSubject.add(aFilterOption.subjectText);
                    }
                }
            
        }
        
        // Call the retrieve method
        callCalendarViewDataGenerator(filterSubject);
    }
    private Map<Date,Map<String,List<Event>>> renderVillageEventsByDate;
    public Map<Date,Map<String,List<Event>>> getRenderVillageEventsByDate(){
        if(renderVillageEventsByDate == null){
            renderVillageEventsByDate = initializeViewMap();
        }
        return renderVillageEventsByDate;
    }

    private Date resolveEventRenderDate(Date theEventDate, String theeventDateAsString){
        Date resolvedDate = null;
        if(null != theeventDateAsString && theeventDateAsString.trim().length() > 0 ){ 
            // get the Day, month and Year
            String[] dateParts = theeventDateAsString.split('/');
            
            try{
                if(dateParts.size() > 2){
                    Integer dayPart = Integer.valueOf(dateParts[0]);
                    Integer monthPart = Integer.valueOf(dateParts[1]);
                
                    if(dateParts[2].trim().length() >=  4){
                        Integer yearPart = Integer.valueOf((dateParts[2].subString(0,4) ));
                        
                        resolvedDate = Date.newInstance(yearPart, monthPart, dayPart);
                    }
                
                }
            }catch(Exception ex){
                System.debug('XXXXX Failed to Resolve Event String Date XXXXX '+ex);
            }
        }
        
        if(null != resolvedDate){
            return resolvedDate;
        }else{
            return theEventDate;
        }

    }
    
    private  Map<Id,Event> eventsMap;
    public static String theIds ;
    private void callCalendarViewDataGenerator(Set<String> filterSubjectTypes){
        Map<Id,Event> eventsData = viewGenerator.getCalendarViewOfEvents(dummyEvent.StartDateTime,filterSubjectTypes);
        eventsMap = eventsData;
        theIds= eventsMap.keySet()+'';
        
        for(Event anEvent : eventsData.values()){
            Date theEventDateStartDate = resolveEventRenderDate(anEvent.StartDateTime.date() , anEvent.StartDateTimeString__c );
            Date theEventDateEndDate = resolveEventRenderDate(anEvent.EndDateTime.date() , anEvent.EndDateTimeString__c );

            String villageCategory = 'NA';
            
            String[] villageCategoryValues = null;
            if(null != anEvent.Village_Category__c){
                if(anEvent.Village_Category__c.indexOf(';') >= 0){
                    villageCategoryValues = anEvent.Village_Category__c.split(';');
                     if(null != villageCategoryValues){
                        // check for GRS or Group
                        if(villageCategoryValues.size()> 1){
                            if(anEvent.Village_Category__c.indexOf(GRS_V) >= 0){
                                villageCategory = GRS_V;
                            }else{
                                villageCategory = GROUP_V;
                            }
                            
                        }
                    }   
                }else{
                    villageCategory = anEvent.Village_Category__c;
                }
            }
            
          if( (null != getRenderVillageEventsByDate().get(theEventDateStartDate) ||
                null != getRenderVillageEventsByDate().get(theEventDateEndDate)) ){
                Boolean villageMappingNotNull = false;
                
                if(Null != getRenderVillageEventsByDate().get(theEventDateStartDate) &&
                    null != getRenderVillageEventsByDate().get(theEventDateStartDate).get(villageCategory) ){
                    villageMappingNotNull = true;
                }else if(Null != getRenderVillageEventsByDate().get(theEventDateEndDate) &&
                    null !=  getRenderVillageEventsByDate().get(theEventDateEndDate).get(villageCategory) ){
                        villageMappingNotNull = true;
                    
                }
                if(villageMappingNotNull == true){
                    Integer eventDayCounter = 0;
                    while((theEventDateStartDate.addDays(eventDayCounter)) <= theEventDateEndDate){
                        if( null != getRenderVillageEventsByDate().get((theEventDateStartDate.addDays(eventDayCounter))) ){
                            getRenderVillageEventsByDate().get( (theEventDateStartDate.addDays(eventDayCounter)) ).get(villageCategory).add(anEvent);
                        }
                        eventDayCounter++;
                    }
                }
          }
        }
    }
    
    public void clearAllOtherCheckAndFilterByAll(){
        if(filterAllSubjectTypes == true){
            filterSubjectTypes = null;
        }
    }
    
    public void uncheckFilterAll(){
        for(FiltersubjectItem aFilterOption: getFilterSubjectTypes()){
            if(aFilterOption.selectedForFiltering == true){
                filterAllSubjectTypes = false;
                break;
            }
        }
    }
    
    // Inner Class to Model Filter Selection Options
    public class FiltersubjectItem{
        public FiltersubjectItem(){
            selectedForFiltering = false;
        }
        public String subjectText {get;set;}
        public Boolean selectedForFiltering {get;set;} 
    }

    
        ////// UNIT TEST //////////////////////////////////////////////////
    static testmethod void testGenerateCurrentWeekCalendar(){
        B2B_Config_Settings__c b2bSettings = B2B_Config_Settings__c.getInstance();
        Test.startTest();
        
        PageReference calendarPage = new PageReference('/apex/B2BEventVisibility');
        Test.setCurrentPage(calendarPage);
        
        // create test events
        List<Event> testEventsList = new List<Event>();
         for(Integer x =0; x<4; x++){
            Event testEvent = new Event();
            
            testEvent.RecordTypeId =b2bSettings.B2B_Event_Record_Type_Id__c;
            
                testEvent.Subject = 'Leasing/Commercialisation';
                testEvent.Event_Department__c = 'Leasing/Commercialisation';
            testEvent.description = 'Testing In Unit Test for  Calendar';
            
            
            testEvent.StartDateTime = System.now();
            testEvent.EndDateTime = System.now();
            testEvent.Village_Category__c = 'Bicester';
            testEvent.Location = 'Bicester';
            testEvent.Location_Time_Zone__c = 'British Summer Time (Europe/London)';
            
            if(x == 1){
                testEvent.Village_Category__c = 'Bicester;Fidenza';
            }
            
            testEventsList.add(testEvent);
         }
         
          Database.Saveresult[] insertResults= Database.insert(testEventsList);
        
        // create the calendar view 
        ApexPages.StandardController stdEventController = new ApexPages.StandardController(new Event());
        B2BEventVisibilityController b2bEventVisibilityctller = new B2BEventVisibilityController(stdEventController);
        
        // Test the previous and next buttons
        b2bEventVisibilityctller.refreshViewNextWeek();
        b2bEventVisibilityctller.refreshViewPreviousWeek();
        
        // call the methods that the VF page Calls
        b2bEventVisibilityctller.getRenderVillageCategorization();
        b2bEventVisibilityctller.getBackgroundCollorMap();
        
        Date testMondayDate =  b2bEventVisibilityctller.mondayDate;
        Date testTuedayDate  = b2bEventVisibilityctller.tuesdayDate;
        Date testWednesdayDate  = b2bEventVisibilityctller.wednesdayDate;
        Date testThursdayDate  = b2bEventVisibilityctller.thursdayDate;
        Date testFridayDate  = b2bEventVisibilityctller.fridayDate;
        Date testSaturdayDate  = b2bEventVisibilityctller.saturdayDate;
        Date testsundayDate  = b2bEventVisibilityctller.sundayDate;
        
        // Get the Events 
        MAP<String,LIST<Event>>  testEventsForMonday =  b2bEventVisibilityctller.mondayEvents;
        MAP<String,LIST<Event>>  testEventsForTuesday =  b2bEventVisibilityctller.tuesdayEvents;
        MAP<String,LIST<Event>>  testEventsForWednesday =  b2bEventVisibilityctller.wednesdayEvents;
        MAP<String,LIST<Event>> testEventsForThursday =  b2bEventVisibilityctller.thursdayEvents;
        MAP<String,LIST<Event>>  testEventsForFriday =  b2bEventVisibilityctller.fridayEvents;
        MAP<String,LIST<Event>>  testEventsForSaturday =  b2bEventVisibilityctller.saturdayEvents;
        MAP<String,LIST<Event>>  testEventsForSunday =  b2bEventVisibilityctller.sundayEvents;
        
        // Do filtering by subject
        List<FiltersubjectItem> allFilterOptions = b2bEventVisibilityctller.getFilterSubjectTypes();
        if(null != b2bEventVisibilityctller.getFilterSubjectTypes() &&
            b2bEventVisibilityctller.getFilterSubjectTypes().size() > 0 ){
            b2bEventVisibilityctller.getFilterSubjectTypes().get(0).selectedForFiltering = true;
            b2bEventVisibilityctller.uncheckFilterAll();
            
            //set filter all back
            b2bEventVisibilityctller.filterAllSubjectTypes = true;
            b2bEventVisibilityctller.clearAllOtherCheckAndFilterByAll();
            
            ApexPages.currentPage().getParameters().put('detailEventId', insertResults[0].getId());
            
            b2bEventVisibilityctller.loadAnEventDetail();
            b2bEventVisibilityctller.closeDetailWindow();
            
        }
        
        // access the detail 
        PageReference detailPage = new PageReference('/apex/B2BEventDetail');
            
            Test.setCurrentPage(detailPage);
            ApexPages.currentPage().getParameters().put('theEventId', insertResults[0].getId());
            B2BEventDetailController detailController = new  B2BEventDetailController();
            detailController.getRenderTimeZone();
            
            
            
            
        Test.stopTest();
        
    }   
    
}