/*
generates 
*/
public class B2BContactReportAlertGenerator {
    public static Boolean TEST_MODE = false;//used for Unit tests to change workflow slightly
    private static final Integer MAX_RECIPIENTS_IN_BATCH = 9; //max number of email permitted to be sent from 1 apex trigger
    /*
     generates Number of B2B_Contact_Report_Alert_Recipient__c
     number = number of actial recipients / 10
     divided by 10 because each B2B_Contact_Report_Alert_Recipient__c will contain no more than 10 email addresses
    */
    public void generateRecipients(List<Event> events) {
        List<B2B_Alert_Recipient__c> recipientHolders = new List<B2B_Alert_Recipient__c>();
        for (Event event : events) {
            //System.debug('=== inside generateRecipients');
            List<ID> recipientIds = getAlertRecipientIds(event);
            Integer counter = 0;
            String recipientsStr = '';
            
            for (ID recipientId : recipientIds) {
                if (recipientsStr.length() >0)
                    recipientsStr += ',';
                recipientsStr += recipientId;
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
            
    private Map<ID, List<ID>> USERS_BY_GROUP_ID = new Map<ID, List<ID>>();//group Id -> List of user ids
    
    private static List<ID> getRecipientGroupIds (Event activity) {
        final List<ID> groupIds = new List<ID>();
        if (activity == null)
            return groupIds;
        if (activity.Group__c)
            groupIds.add('00G20000000oiOU');
        else {
            if (activity.Bicester__c)
                groupIds.add('00G20000000oiOH');
            if (activity.Bispingen__c)
                groupIds.add('00G20000000qQgA');
            if (activity.Fidenza__c)
                groupIds.add('00G20000000oiOM');
            if (activity.Ingolstadt__c)
                groupIds.add('00G20000000oiOQ');
            if (activity.Kildare__c)
                groupIds.add('00G20000000oiOT');
            if (activity.La_Roca__c)
                groupIds.add('00G20000000oiON');
            if (activity.La_Vall_e__c)
                groupIds.add('00G20000000oiOR');
            if (activity.Las_Rozas__c)
                groupIds.add('00G20000000oiOO');
            if (activity.Maasmechelen__c)
                groupIds.add('00G20000000oiOS');
            if (activity.Wertheim__c)
                groupIds.add('00G20000000oiOP');
        }
        //System.debug('groupIds.length=' + groupIds.size());
        return groupIds;
    }

    /*
     * returns list of alert recipients based on "Who is involved?" tickboxes
     */
    private List<Id> getAlertRecipientIds(Event activity) {
        //System.debug('inside getAlertRecipientIds');
        //scan through all checkboxes from "Who is involved?" and retrieve groups and their member users accordingly
        final Map<ID, ID> uniqueUserIds = new Map<ID, ID>();
        final List<ID> groupIds = getRecipientGroupIds(activity);
        for (ID groupId : groupIds) {
            if (!USERS_BY_GROUP_ID.containsKey(groupId)) {
                //load members of the group
                loadGroupMembers(groupId);
            }
            final List<ID> userIds = USERS_BY_GROUP_ID.get(groupId);
            if (userIds != null) {
                for (ID userId : userIds) {
                    if (uniqueUserIds.containsKey(userId))
                        continue;
                    uniqueUserIds.put(userId, userId);
                }
            }
        }
        return uniqueUserIds.values();
    }
    private List<ID> loadGroupMembers (ID groupId) {
        GroupMember[] members = [Select UserOrGroupId From GroupMember where GroupId =: groupId];
        if (members != null && members.size() >0) {
            List<ID> userIds = new List<ID>();
            for (GroupMember member : members) {
                String idStr = member.UserOrGroupId;
                if (idStr.startsWith('00G')) {
                    List<ID> recipientIds = loadGroupMembers(idStr);
                    if (recipientIds != null)
                        userIds.addAll(recipientIds);
                    //continue;//do not include groups
                } else
                    userIds.add(member.UserOrGroupId);  
            }
            USERS_BY_GROUP_ID.put(groupId, userIds);
            return userIds;
        }
        return null;
    }
    
    private static B2B_Alert_Recipient__c createRecipientsHolder(ID eventId, String recipientsStr) {
        B2B_Alert_Recipient__c recipient = new B2B_Alert_Recipient__c();
        recipient.Event_Id__c = eventId;
        recipient.Recipients__c = recipientsStr;
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
    /*
    public static testMethod void testGroupNesting() {
        B2BContactReportAlertGenerator gen = new B2BContactReportAlertGenerator();
        ID groupId = '00G20000000oiOU';
        gen.loadGroupMembers(groupId);
        System.debug('=== user ids ====');
        List<ID> userIds = gen.USERS_BY_GROUP_ID.get(groupId);
        for (ID userId : userIds) {
            System.debug('=== user id:' + userId);
        }   
    }
    */  
}