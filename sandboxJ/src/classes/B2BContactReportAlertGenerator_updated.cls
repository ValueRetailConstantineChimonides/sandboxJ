/*
generates 
*/
public class B2BContactReportAlertGenerator_updated {
    public static Boolean TEST_MODE = false;//used for Unit tests to change workflow slightly
    private static final Integer MAX_RECIPIENTS_IN_BATCH = 8; //max number of email permitted to be sent from 1 apex trigger
    /*
     generates Number of B2B_Contact_Report_Alert_Recipient__c
     number = number of actial recipients / 10
     divided by 10 because each B2B_Contact_Report_Alert_Recipient__c will contain no more than 10 email addresses
    */
    public void generateRecipients(List<Event> events) {
        List<B2B_Alert_Recipient__c> recipientHolders = new List<B2B_Alert_Recipient__c>();
        List<VR_Employee__c> allB2BAlertRecipients = getAllB2BAlertVREmployees();
        Map<Id, Set<String>> recipientsByEventId = getAllRelevantB2BAlertRecipients(events,allB2BAlertRecipients);
        
        Map<Id, Set<String>> recipientsEmailOrUserIdsByEventId = findAndConvertAllEmailsToUserIds(recipientsByEventId);
        
        Integer  externalEmailCount = 0;
        
        for (Event event : events) {
            //System.debug('=== inside generateRecipients');
            //List<ID> recipientIds = getAlertRecipientIds(event);
            Set<String> recipientEmails = recipientsEmailOrUserIdsByEventId.get(event.Id);
            if(null == recipientEmails)continue;
            
            Integer counter = 0;
            String recipientsStr = '';
            
            for (String recipientEmail : recipientEmails) {
                // Added for Usage Limit Count of Email address
                if (recipientEmail.contains('@')) {
                    externalEmailCount++;
                }
                if (recipientsStr.length() >0)
                    recipientsStr += ',';
                recipientsStr += recipientEmail;
                counter++;
                //System.debug('=== counter=' + counter);
                if (counter >= MAX_RECIPIENTS_IN_BATCH) {
                    recipientHolders.add(createRecipientsHolder(event.id, recipientsStr));
                    //clean recipient ids before next cycle
                    recipientsStr = '';
                    counter = 0;    
                }
            }
            if (recipientsStr.length() >0)
                recipientHolders.add(createRecipientsHolder(event.id, recipientsStr));
            
            //now process additional users
            String additionalEmailAddresses = event.h_Additional_Email_Recipients__c;
            if (additionalEmailAddresses != null && additionalEmailAddresses.length() >0) { 
                String[] emails = additionalEmailAddresses.split(',');
                recipientsStr = '';
                counter = 0;
                for (String email : emails) {
                    if (email.contains('@')) {
                        externalEmailCount++;
                    }
                    email = email.trim();
                    if (recipientsStr.length() >0)
                        recipientsStr += ',';
                    recipientsStr += email;
                    counter++;
                    //System.debug('=== counter=' + counter);
                    if (counter >= MAX_RECIPIENTS_IN_BATCH) {
                        recipientHolders.add(createRecipientsHolder(event.id, recipientsStr));
                        //clean recipient ids before next cycle
                        recipientsStr = '';
                        counter = 0;    
                    }
                }
                if (recipientsStr.length() >0)
                    recipientHolders.add(createRecipientsHolder(event.id, recipientsStr));
                
            }
        }
        Database.insert(recipientHolders);

        if(externalEmailCount > 0){
            B2BAlertViewGenerator.updateMailingLimitTracker(System.now().date(),externalEmailCount);
        }
    } 
    
    public static void cleanOldRecipients(Set<Id> eventIds, Integer nDaysOld) {
        Set<String> normalisedEventIds = normaliseIds(eventIds);
        
        B2B_Alert_Recipient__c[] recipients = getRecipientHolders(normalisedEventIds, nDaysOld);
        
        //System.debug('=== recipients.size()=' + recipients.size());
        while (recipients != null && !recipients.isEmpty()) {
            System.debug('==About to delete Brand recipients for "' + normalisedEventIds + '" and nDaysOld=' + nDaysOld);
            System.debug('recipients.size()=' + recipients.size());
            delete recipients;
            //System.debug('Deleted ' + size + ' Brand recipients');
            recipients = getRecipientHolders(normalisedEventIds, nDaysOld);
        }
    }
    public static Set<String> normaliseIds(Set<Id> eventIds) {
        Set<String> normalisedEventIds = null;
        if (null != eventIds) {
            normalisedEventIds = new Set<String>();
            for (Id eventId : eventIds) {
                String normalisedId = eventId;
                if (normalisedId != null) {
                    if (normalisedId.length() >15) {
                        normalisedId = normalisedId.substring(0, 15);
                    }
                }
                normalisedEventIds.add(normalisedId);
            }
        }
        return normalisedEventIds;      
    }
    private static B2B_Alert_Recipient__c[] getRecipientHolders (Set<String> eventIds, Integer nDaysOld) {
        Datetime endDate = null;
        if (nDaysOld != null) {
            endDate = System.now() - nDaysOld;  
        }
        System.debug('getRecipientHolders.endDate=' + endDate);
        
        if (eventIds == null && endDate == null) {
            return [select id from B2B_Alert_Recipient__c limit 1000 for update];
        }
        else if (eventIds == null && endDate != null) {
            return [select id from B2B_Alert_Recipient__c where CreatedDate <: endDate  limit 1000 for update];
        }   
        else if (eventIds != null && endDate == null) {
            return [select id from B2B_Alert_Recipient__c where Event_Id__c in: eventIds limit 1000 for update];
        }

        return [select id from B2B_Alert_Recipient__c where CreatedDate <: endDate and Event_Id__c in: eventIds limit 1000 for update];
    } 

    private static B2B_Alert_Recipient__c createRecipientsHolder(ID eventId, String recipientsStr) {
        B2B_Alert_Recipient__c recipient = new B2B_Alert_Recipient__c();
        recipient.Event_Id__c = (eventId+'').substring(0,15);
        recipient.Recipients__c = recipientsStr;
        //recipient.Event_Id_18__c = eventId;
        /*
        Date todayDate = System.today();
        if (!TEST_MODE) {
            //recipient.To_be_Sent_On__c = Datetime.newInstance(todayDate.year(), todayDate.month(), todayDate.day());
        }   
        else {
            Datetime nowDate = System.now();
            nowDate = nowDate.addMinutes(1);//to be sent in 1 minute
            recipient.To_be_Sent_On__c = nowDate;
        }
        */
        //Datetime.newInstance(todayDate.getYear(), 1,1);
        //System.debug('=== recipientsStr=' + recipientsStr);
        return recipient;
    }
    
    private List<VR_Employee__c> getAllB2BAlertVREmployees(){
        //String qStr = new AsyncB2BDailyAlertSender().start(null).getQuery();
        //List<VR_Employee__c> allB2BEmployees = Database.query(qStr);
        //return allB2BEmployees;
        String eXX = 'mojo@valueretail.com';
        Set<Id> vrEmpIds = new Set<Id>();
        for(VR_Employee__c anEmp : [SELECT Id
                    FROM VR_Employee__c 
                        WHERE 
                        Communications_Distribution_List__c INCLUDES  ('B2B Europe','B2B China')
                        And
                        Active__c = true
                        ]){
                    vrEmpIds.add(anEmp.Id);
        }
        
        return [SELECT Id,Email__c, Communications_Villages_of_Interest__c,Communications_Subjects_Of_Interest__c
                    FROM VR_Employee__c 
                        WHERE 
                        Id IN :vrEmpIds
                        ];
        
    }
    
    private Map<Id, Set<String>> getAllRelevantB2BAlertRecipients(List<Event> eventsList,List<VR_Employee__c> allB2BAlertRecipients) {
            String ALL_GROUP_OPTION = 'Group';
            Map<Id, Set<String>> recipientEmailsByEventIf = new Map<Id,Set<String>>();
        
        for(Event anEvent : eventsList){
            Set<String> eventRecipientMails = new Set<String>();
            
            String [] villagesDiscussed = (null != anEvent.Village_Category__c && anEvent.Village_Category__c.trim().length() > 0) ?anEvent.Village_Category__c.split(';') : null ;
            if(villagesDiscussed == null){
                continue;
            }
            
            String  eventDepartment = (null != anEvent.Event_Department__c && anEvent.Event_Department__c.trim().length() > 0) ?anEvent.Event_Department__c : 'UnSpec' ;

            
            // If the Event is a group event, then all employee will get the Report
            if((villagesDiscussed+'').indexOf(ALL_GROUP_OPTION) >= 0){
                // Add all employee as recipients
                    for(VR_Employee__c anEmployee : allB2BAlertRecipients){
                        if(null != anEmployee.Communications_Villages_of_Interest__c && 
                                (null != anEmployee.Communications_Subjects_Of_Interest__c && 
                                    ( eventDepartment == 'UnSpec' || verifyAddToRecipientByDepartmentCheck(anEmployee.Communications_Subjects_Of_Interest__c ,eventDepartment) ) ) ){
                                
                                    String toEmailAddress = anEmployee.Email__c;
                                    if(null != toEmailAddress && toEmailAddress.trim().length() > 0) eventRecipientMails.add(toEmailAddress.trim());   
                        }
                    }
            }else{
                for(VR_Employee__c anEmployee : allB2BAlertRecipients){
                Boolean addedEmployee = false;

                    for(String aVillage : villagesDiscussed){
                        if(addedEmployee ==true)continue;
                    
                        if(null != anEmployee.Communications_Villages_of_Interest__c  && 
                                ( anEmployee.Communications_Villages_of_Interest__c.indexOf(ALL_GROUP_OPTION) >= 0 || 
                                    anEmployee.Communications_Villages_of_Interest__c.indexOf(aVillage) >= 0) ){
                                
                                if( (null != anEmployee.Communications_Subjects_Of_Interest__c && 
                                        ( eventDepartment == 'UnSpec' || verifyAddToRecipientByDepartmentCheck(anEmployee.Communications_Subjects_Of_Interest__c ,eventDepartment) ) ) ){
                                            String toEmailAddress = anEmployee.Email__c;
                                            if(null != toEmailAddress && toEmailAddress.trim().length() > 0) eventRecipientMails.add(toEmailAddress.trim());
                        
                                            addedEmployee = true;
                                            continue;
                                    }   
                        }
                    }
                }
            }

            if(!eventRecipientMails.isEmpty()){
                recipientEmailsByEventIf.put(anEvent.Id,eventRecipientMails);
            } 
        }
        return recipientEmailsByEventIf;
    }
    
    private boolean verifyAddToRecipientByDepartmentCheck(String recipientDepartments,String eventDepartment){
        Boolean addByDepartment  = false;
        
        for(String aDepartment : recipientDepartments.split(';') ){
            if(aDepartment.trim() == eventDepartment){
                addByDepartment = true;
                break;
            }
        }
        return addByDepartment;
    }
    
    // Convert VR Emails to SFDC User Ids
    private Map<Id, Set<String>> findAndConvertAllEmailsToUserIds(Map<Id, Set<String>> recipientEmailsByEventIf){
        Map<Id, Set<String>> recipientsEmailOrUserIdsByEventId = new Map<Id, Set<String>>();
        
        Set<String> emailAddrForFilter = new Set<String>();
        for(Set<String> emailsForAnEvent : recipientEmailsByEventIf.values()){
            for(String anEmail : emailsForAnEvent){
                emailAddrForFilter.add(anEmail);
            }
        }
        
        Map<String,Id>  UserIdsByEmail = new Map<String,Id>();
        for(User aUser : [SELECT Id, Email FROM  User WHERE Email IN :emailAddrForFilter]){
            UserIdsByEmail.put(aUser.Email,aUser.Id);
        }

        // Match Email/User Ids to Events
        for(Id anEventId : recipientEmailsByEventIf.keySet()){
            Set<String> newMatchedList = new Set<String>();
            
            for(String currentlyHeldEmail : recipientEmailsByEventIf.get(anEventId)){
                Id foundUserId = UserIdsByEmail.get(currentlyHeldEmail);
                if(null != foundUserId){newMatchedList.add(foundUserId+''); } else { newMatchedList.add(currentlyHeldEmail);}
            }
            recipientsEmailOrUserIdsByEventId.put(anEventId,newMatchedList);
        }
        return recipientsEmailOrUserIdsByEventId;
    }

}