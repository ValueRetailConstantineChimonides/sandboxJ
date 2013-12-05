public with sharing class CampaignMemberResponSysStatusEvents {
    private static final String DELIM = '___';
    public Static Boolean inTesting = false;
    public static Boolean RUN_IN_TEST_MODE = false;
    private static ResponSys_Integration__c responSysIntegration = ResponSys_Integration__c.getInstance();
 
    public static void trackCampaignMemberStatusChange(Map<ID,CampaignMember> newCampainMember,
        Map<ID,CampaignMember> oldCampaignMember){
            // Ensure this call is coming from RESPONSYS by checking the User Group and If in test Mode use
            // System Admin User
            Id currentUserId = UserInfo.getUserId();
            if(RUN_IN_TEST_MODE == false && confirmUserInResponSysGroup(currentUserId) == false){
                return;
            }
        // List to Hold all required Campaign member changes
        List<String> campaignMembersToProcess = new List<String>();
        List<ID> campaignMemberIDs  = new List<ID>();
        // Contacts that may need updating 
        List<String> contactsUpdateIds = new List<String>();
        
        Set<Id> theCampaignIds = new Set<Id>();
        for(CampaignMember anewMeb : newCampainMember.values()){
            theCampaignIds.add(anewMeb.campaignId);
        
        }
        // Get All the Campaigns
        Map<ID,Campaign> theCampaigns = getCampaigns(theCampaignIds);
        
        // Iterate through all updated Campaign Member
        for(ID aMemberID : newCampainMember.keySet()){
        CampaignMember anOldMember = oldCampaignMember == null ? null  : oldCampaignMember.get(aMemberID) ;
            if((theCampaigns.get(newCampainMember.get(aMemberID).campaignId)).type == 'Email'){
                determineFieldUpdates(newCampainMember.get(aMemberID),anOldMember,campaignMembersToProcess,campaignMemberIDs,contactsUpdateIds);
            }

            
        }
        
        if(contactsUpdateIds.size() > 0){
            populateTriggerProcessManager(contactsUpdateIds,'Contact',(oldCampaignMember==null ? 'INSERT':'UPDATE'));
        }
        populateTriggerProcessManager(campaignMembersToProcess,'CampaignMember',(oldCampaignMember==null ? 'INSERT':'UPDATE'));
    }
    
    private static void determineFieldUpdates(CampaignMember theNewMember,CampaignMember theOldMember,List<String> campaignMembersToProcess,List<ID> campaignMemberIDs,List<String> contactsUpdateIds){
        Boolean okForProcessing = false;
        if(theNewMember != null && theOldMember == null){
            okForProcessing = true;
        }else if(theNewMember.Status != theOldMember.Status){
            okForProcessing = true;
        }
        
        if(okForProcessing){
            if(theNewMember.Status == 'Sent'){
                processSentStatus(theNewMember,campaignMembersToProcess,(theOldMember==null ? 'INSERT':'UPDATE'));
                campaignMemberIDs.add(theNewMember.ID);
            }else if(theNewMember.Status == 'Soft Bounced' && (theOldMember == null || theOldMember.Soft_Bounced__c == false )){
                processSoftBounce(theNewMember,campaignMembersToProcess,(theOldMember==null ? 'INSERT':'UPDATE'));
                campaignMemberIDs.add(theNewMember.ID);
            }else if(theNewMember.Status == 'Hard Bounced' && (theOldMember == null || theOldMember.Hard_Bounced_Date__c == null)){
                processHardBounce(theNewMember,campaignMembersToProcess,(theOldMember==null ? 'INSERT':'UPDATE'));
                campaignMemberIDs.add(theNewMember.ID);
                contactsUpdateIds.add(theNewMember.contactId+DELIM+'Hard Bounced'+DELIM);
            }else if(theNewMember.Status == 'Viewed Message' && (theOldMember == null || theOldMember.Viewed_Message__c == false)){
                processViewedMessage(theNewMember,campaignMembersToProcess,(theOldMember==null ? 'INSERT':'UPDATE'));
                campaignMemberIDs.add(theNewMember.ID);
            }else if(theNewMember.Status == 'Clicked Campaign Link' && (theOldMember  == null || theOldMember.Clicked_Campain_Link__c == false)){
                processClickedCampaignLink(theNewMember,campaignMembersToProcess,(theOldMember==null ? 'INSERT':'UPDATE'));
                campaignMemberIDs.add(theNewMember.ID);
            }else if(theNewMember.Status == 'Opted Out'  && (theOldMember == null || theOldMember.Opted_Out_Date__c == null)){
                processOptedOut(theNewMember,campaignMembersToProcess,(theOldMember==null ? 'INSERT':'UPDATE'));
                campaignMemberIDs.add(theNewMember.ID);
            }else if(theNewMember.Status == 'Responded'){
                processResponded(theNewMember,campaignMembersToProcess,(theOldMember==null ? 'INSERT':'UPDATE'));
                campaignMemberIDs.add(theNewMember.ID);
            }else if(theNewMember.Status == 'Complained of spam' && (theOldMember == null || theOldMember.Complained_Of_Spam__c == false)){
                processComplainedOfSpam(theNewMember,campaignMembersToProcess,(theOldMember==null ? 'INSERT':'UPDATE'));
                campaignMemberIDs.add(theNewMember.ID);
            }
        }
    }
    
    private static void processSentStatus(CampaignMember theNewMember ,List<String> campaignMembersToProcess, String targetEvent){
        String sentString = theNewMember.ID+DELIM;
        sentString += 'Sent'+DELIM;
        campaignMembersToProcess.add(sentString);
        
    }
    private static void processSoftBounce(CampaignMember theNewMember,List<String> campaignMembersToProcess,String targetEvent){
        String softBounceString = theNewMember.ID+DELIM;
        softBounceString += 'Soft Bounced'+DELIM;
        softBounceString += targetEvent+DELIM;
        campaignMembersToProcess.add(softBounceString);
    }
    private static void processHardBounce(CampaignMember theNewMember,List<String> campaignMembersToProcess,String targetEvent){
        String hardBounceString = theNewMember.ID+DELIM;
        hardBounceString += 'Hard Bounced'+DELIM;
        hardBounceString += targetEvent+DELIM;
        campaignMembersToProcess.add(hardBounceString);
        
    }
    private static void processViewedMessage(CampaignMember theNewMember,List<String> campaignMembersToProcess,String targetEvent){
        String viewedMessageString = theNewMember.ID+DELIM;
        viewedMessageString += 'Viewed Message'+DELIM;
        viewedMessageString += targetEvent+DELIM;
        campaignMembersToProcess.add(viewedMessageString);
        
    }
    private static void processClickedCampaignLink(CampaignMember theNewMember,List<String> campaignMembersToProcess,String targetEvent){
        String clickedCampaignString = theNewMember.ID+DELIM;
        clickedCampaignString += 'Clicked Campaign Link'+DELIM;
        clickedCampaignString += targetEvent+DELIM;
        campaignMembersToProcess.add(clickedCampaignString);
    }
    
    private static void processOptedOut(CampaignMember theNewMember,List<String> campaignMembersToProcess,String targetEvent){
        String optedOutString = theNewMember.ID+DELIM;
        optedOutString += 'Opted Out'+DELIM;
        optedOutString += targetEvent+DELIM;
        campaignMembersToProcess.add(optedOutString);
    }
    
    private static void processResponded(CampaignMember theNewMember, List<String> campaignMembersToProcess,String targetEvent){
        String respondedString = theNewMember.ID+DELIM;
        respondedString += 'Responded'+DELIM;
        respondedString += targetEvent+DELIM;
        campaignMembersToProcess.add(respondedString);
    }
    
    private static void processComplainedOfSpam(CampaignMember theNewMember, List<String> campaignMembersToProcess,String targetEvent){
        String complainedOfSpamStr = theNewMember.ID+DELIM;
        complainedOfSpamStr += 'Complained of spam'+DELIM;
        complainedOfSpamStr += targetEvent+DELIM;
        campaignMembersToProcess.add(complainedOfSpamStr);
    }
    
    public static  Set<ID> runTriggerProcess(Map<ID,Trigger_Process_Manager__c> newMap){
        List<String> rowRules = new List<String>();
        List<ID> targetIDS = new List<ID>();
        
        for(Trigger_Process_Manager__c aProcess : newMap.values()){
            String ruleStr = aProcess.Process_Rule__c;
            rowRules.add(ruleStr);
            targetIDS.add(aProcess.Target_ID__c);
        }
        
        return runRequiredUpdate(rowRules, targetIDS);
        
    }
    
    public static void runTriggerProcessOnContact(Map<ID,Trigger_Process_Manager__c> newMap){
        List<String> rowRules = new List<String>();
        List<ID> targetIDS = new List<ID>();
        
        for(Trigger_Process_Manager__c aProcess : newMap.values()){
            rowRules.add(aProcess.Process_Rule__c);
            targetIDS.add(aProcess.Target_ID__c);
        }
        
        runRequiredUpdateOnContact(rowRules, targetIDS);
        
    }
    
    //@future(callout = false)
    private static void runRequiredUpdateOnContact(List<String> recordsForProcess, List<ID> contactIDs){
        List<Contact> contactsToUpdate = new List<Contact>();
        Map<ID,Contact> allRelevantContacts = new Map<ID,Contact>([SELECT id,Hard_Bounce__c
                FROM Contact WHERE id IN :contactIDs]);
                
        for(String processString : recordsForProcess){
            String[] processFields = processString.split(DELIM);
            
            Contact theContact = allRelevantContacts.get(processFields[0]);
            if(processFields[1] == 'Hard Bounced'){
                theContact.Hard_Bounce__c = true;
            }
            contactsToUpdate.add(theContact);
        }
        
        Database.update(contactsToUpdate);
    }
    
    //@future(callout = false)
    private static Set<ID> runRequiredUpdate(List<String> recordsForProcess, List<ID> campaignMemberIDs){
        Map<Id,CampaignMember> membersToUpdate = new Map<Id,CampaignMember>();
        Map<ID,Campaign_Results__c> campaignResultsToUpdate = new Map<ID,Campaign_Results__c>();
        Map<ID,Campaign_Results__c> campaignResultsToInsert = new Map<ID,Campaign_Results__c>();
        
        Set<ID> theCampaignIds = new Set<ID>();
        Map<Id,AggregationResult> aggregationByCampaignId = new Map<Id,AggregationResult>();
        
        
        // retrieve all relevant Campaign Members
        Map<ID,CampaignMember> allRelevantCampainMembers = new Map<ID,CampaignMember>([SELECT id,contactId,CampaignID,Sent_Date__c, Sent__c,
                Soft_Bounced_Date__c,Soft_Bounced__c,Hard_Bounced_Date__c,Opted_Out_Date__c, 
                Viewed_Message_Date__c,Viewed_Message__c,Complained_Of_Spam_Date__c,Complained_Of_Spam__c,
                Clicked_Campain_Link_Date__c,Clicked_Campain_Link__c   
                FROM CampaignMember where id IN :campaignMemberIDs]);
                
                Date nowDate = DateTime.newInstance(System.currentTimeMillis()).Date();
                
          for(String processString : recordsForProcess){
            String[] processFields = processString.split(DELIM);
            
            CampaignMember theCampaignMember = allRelevantCampainMembers.get(processFields[0]);
            
            if(null != theCampaignMember){
                if(aggregationByCampaignId.get(theCampaignMember.campaignId) == null){
                    aggregationByCampaignId.put(theCampaignMember.campaignId , new AggregationResult() );
                }
                AggregationResult anAggregate = aggregationByCampaignId.get(theCampaignMember.campaignId);
            
            
                if(processFields[1] == 'Sent'){
                    if((null == theCampaignMember.Sent_Date__c) ){
                        anAggregate.sentCount++;
                    }
                    theCampaignMember.Sent_Date__c = nowDate;
                    theCampaignMember.Sent__c = true;
                
                }else if(processFields[1] == 'Soft Bounced'){
                    if(processFields[2] == 'UPDATE' && (null == theCampaignMember.Soft_Bounced_Date__c) ){
                        anAggregate.softBouncedCount++;
                    }
                    
                    // Added to handle Campaign Members Inserted with a different status than Sent
                    if(processFields[2] == 'INSERT'){
                        if(null == theCampaignMember.Sent_Date__c)anAggregate.sentCount++;
                        if((null == theCampaignMember.Soft_Bounced_Date__c))anAggregate.softBouncedCount++;
                    }
                    theCampaignMember.Soft_Bounced_Date__c = nowDate;
                    theCampaignMember.Soft_Bounced__c = true;
                    if(null == theCampaignMember.Sent_Date__c){
                        theCampaignMember.Sent_Date__c = nowDate;
                        theCampaignMember.Sent__c = true;
                    }
                
                }else if(processFields[1] == 'Hard Bounced'){
                    if(processFields[2] == 'UPDATE' && (null == theCampaignMember.Hard_Bounced_Date__c) ){
                        anAggregate.hardBouncedCount++;
                    }
                    
                    // Added to handle Campaign Members Inserted with a different status than Sent
                    if(processFields[2] == 'INSERT'){
                        if(null == theCampaignMember.Sent_Date__c)anAggregate.sentCount++;
                        if(null == theCampaignMember.Hard_Bounced_Date__c)anAggregate.hardBouncedCount++;
                    }
                    theCampaignMember.Hard_Bounced_Date__c = nowDate;
                    
                    if(null == theCampaignMember.Sent_Date__c){
                        theCampaignMember.Sent_Date__c = nowDate;
                        theCampaignMember.Sent__c = true;
                    }
                
                }else if(processFields[1] == 'Viewed Message'){
                    if(processFields[2] == 'UPDATE' && (null == theCampaignMember.Viewed_Message_Date__c) ){
                        anAggregate.viewedMsgCount++;
                    }
                
                    // Added to handle Campaign Members Inserted with a different status than Sent
                    if(processFields[2] == 'INSERT'){
                        if(null == theCampaignMember.Sent_Date__c)anAggregate.sentCount++;
                        if((null == theCampaignMember.Viewed_Message_Date__c))anAggregate.viewedMsgCount++;
                        
                    }
                    if(null == theCampaignMember.Sent_Date__c){
                        theCampaignMember.Sent_Date__c = nowDate;
                        theCampaignMember.Sent__c = true;
                    }
                    
                    theCampaignMember.Viewed_Message_Date__c = nowDate ;
                    theCampaignMember.Viewed_Message__c = true;
                
                }else if(processFields[1] == 'Clicked Campaign Link'){
                    if(processFields[2] == 'UPDATE' && (null == theCampaignMember.Clicked_Campain_Link_Date__c ) ){
                        anAggregate.ClickedCampCount++;
                        if(theCampaignMember.Viewed_Message_Date__c == null)anAggregate.viewedMsgCount++;
                    }
 
                    // Added to handle Campaign Members Inserted with a different status than Sent
                    if(processFields[2] == 'INSERT'){
                        if(null == theCampaignMember.Sent_Date__c)anAggregate.sentCount++;
                        if(null == theCampaignMember.Viewed_Message_Date__c)anAggregate.viewedMsgCount++;
                        if(null == theCampaignMember.Clicked_Campain_Link_Date__c )anAggregate.ClickedCampCount++;

                    }
                    if(null == theCampaignMember.Viewed_Message_Date__c)theCampaignMember.Viewed_Message_Date__c = nowDate;
                    theCampaignMember.Viewed_Message__c = true;
                    if(theCampaignMember.Sent_Date__c == null)theCampaignMember.Sent_Date__c = nowDate;
                    theCampaignMember.Sent__c = true;
                    theCampaignMember.Clicked_Campain_Link_Date__c = nowDate ; 
                    theCampaignMember.Clicked_Campain_Link__c = true;
                
                }else if(processFields[1] == 'Opted Out'){
                    if(processFields[2] == 'UPDATE' && (null == theCampaignMember.Opted_Out_Date__c) ){
                        anAggregate.optedOutCount++;
                        if(theCampaignMember.Viewed_Message_Date__c == null)anAggregate.viewedMsgCount++;
                    }

                        // Added to handle Campaign Members Inserted with a different status than Sent
                    if(processFields[2] == 'INSERT'){
                            if(theCampaignMember.Sent_Date__c == null)anAggregate.sentCount++;
                            if(theCampaignMember.Viewed_Message_Date__c == null)anAggregate.viewedMsgCount++;
                            if(theCampaignMember.Opted_Out_Date__c == null)anAggregate.optedOutCount++;
                            
                    }
                    
                        if(theCampaignMember.Sent_Date__c == null)theCampaignMember.Sent_Date__c = nowDate;
                         theCampaignMember.Sent__c = true;
                        if(theCampaignMember.Viewed_Message_Date__c == null)theCampaignMember.Viewed_Message_Date__c = nowDate;
                        theCampaignMember.Viewed_Message__c = true;
                            
                            
                    theCampaignMember.Opted_Out_Date__c = nowDate;
                
                }else if(processFields[1] == 'Responded'){
                    // theCampaignMember.Responded_Latest_Date__c = nowDate;
                    if(processFields[2] == 'INSERT'){
                        if(theCampaignMember.Sent_Date__c == null)anAggregate.sentCount++;
                        
                    }
                    if(theCampaignMember.Sent_Date__c == null)theCampaignMember.Sent_Date__c = nowDate;
                        theCampaignMember.Sent__c = true;
                        
                }else if(processFields[1] == 'Complained of spam'){
                    
                    if(processFields[2] == 'INSERT'){
                        if(theCampaignMember.Sent_Date__c == null)anAggregate.sentCount++;
                        
                    }
                    if(theCampaignMember.Sent_Date__c == null)theCampaignMember.Sent_Date__c = nowDate;
                     theCampaignMember.Sent__c = true;
                    theCampaignMember.Complained_Of_Spam_Date__c = nowDate;
                    theCampaignMember.Complained_Of_Spam__c = true;
                }
                aggregationByCampaignId.put(theCampaignMember.campaignId , anAggregate );
                membersToUpdate.put(theCampaignMember.Id,theCampaignMember);
                theCampaignIds.add(theCampaignMember.campaignId);
            }
          }
          
          
          Map<ID,Campaign_Results__c> CampainResultsByCampaignID = getExisitingCampaignResultsByCampaigID(theCampaignIds);
          
          // Iterate though all the results and set up Update and Inserts
          for(Id aCampaignID : theCampaignIds){
            Campaign_Results__c theCampaignResult = CampainResultsByCampaignID.get(aCampaignID);
            
            if(theCampaignResult == null){
                // Check If already added to INSERT Map
                if(campaignResultsToInsert.get(aCampaignID) == null){
                    // create a Campaign Results instance and setitup
                    Campaign_Results__c newCampaignResults = new Campaign_Results__c();
                    newCampaignResults.Campaign__c = aCampaignID;
                    newCampaignResults.Name = 'Campaign Member Status Aggregation';
                    
                    newCampaignResults.Date_Sent__c = nowDate;
                
                    // Get the Aggregation Object
                    AggregationResult anewAggregationResult  = aggregationByCampaignId.get(aCampaignID);
                    if(null != anewAggregationResult){
                        if(null == newCampaignResults.Number_Sent__c)newCampaignResults.Number_Sent__c = 0;
                        newCampaignResults.Number_Sent__c += anewAggregationResult.sentCount;
                    
                        if(null == newCampaignResults.Number_of_Hard_bounces__c)newCampaignResults.Number_of_Hard_bounces__c = 0;
                        newCampaignResults.Number_of_Hard_bounces__c += anewAggregationResult.hardBouncedCount;
                    
                        if(null == newCampaignResults.Number_of_soft_bounces__c)newCampaignResults.Number_of_soft_bounces__c = 0;
                        newCampaignResults.Number_of_soft_bounces__c += anewAggregationResult.softBouncedCount;
                    
                        if(null == newCampaignResults.Number_of_Viewed_Message__c)newCampaignResults.Number_of_Viewed_Message__c = 0;
                        newCampaignResults.Number_of_Viewed_Message__c += anewAggregationResult.viewedMsgCount;
                    
                        if(null == newCampaignResults.Number_of_Clicked_Campaign_Link__c)newCampaignResults.Number_of_Clicked_Campaign_Link__c = 0;
                        newCampaignResults.Number_of_Clicked_Campaign_Link__c += anewAggregationResult.ClickedCampCount;
                    
                        if(null == newCampaignResults.Number_of_Opted_Out__c)newCampaignResults.Number_of_Opted_Out__c = 0;
                        newCampaignResults.Number_of_Opted_Out__c += anewAggregationResult.optedOutCount;
                    }

                    // add to INSERT MAP
                    campaignResultsToInsert.put(aCampaignID,newCampaignResults);
                }
            }else{
                // set the Aggregation Values
                    AggregationResult anUpdateAggregation  = aggregationByCampaignId.get(aCampaignID);

                    if(null != anUpdateAggregation){
                        if(null == theCampaignResult.Number_Sent__c)theCampaignResult.Number_Sent__c = 0;
                        theCampaignResult.Number_Sent__c += anUpdateAggregation.sentCount;
                    
                        if(null == theCampaignResult.Number_of_Hard_bounces__c)theCampaignResult.Number_of_Hard_bounces__c = 0;
                        theCampaignResult.Number_of_Hard_bounces__c += anUpdateAggregation.hardBouncedCount;
                    
                        if(null == theCampaignResult.Number_of_soft_bounces__c)theCampaignResult.Number_of_soft_bounces__c = 0;
                        theCampaignResult.Number_of_soft_bounces__c += anUpdateAggregation.softBouncedCount;
                    
                        if(null == theCampaignResult.Number_of_Viewed_Message__c)theCampaignResult.Number_of_Viewed_Message__c = 0;
                        theCampaignResult.Number_of_Viewed_Message__c += anUpdateAggregation.viewedMsgCount;
                    
                        if(null == theCampaignResult.Number_of_Clicked_Campaign_Link__c)theCampaignResult.Number_of_Clicked_Campaign_Link__c = 0;
                        theCampaignResult.Number_of_Clicked_Campaign_Link__c += anUpdateAggregation.ClickedCampCount;
                    
                        if(null == theCampaignResult.Number_of_Opted_Out__c)theCampaignResult.Number_of_Opted_Out__c = 0;
                        theCampaignResult.Number_of_Opted_Out__c += anUpdateAggregation.optedOutCount;
                        
                    }

                    
                // check if already added to UPDATE LIST 
                if(campaignResultsToUpdate.get(aCampaignID) == null){ 
                    campaignResultsToUpdate.put(aCampaignID,theCampaignResult);
                }
            }
            
          }
          
          // Do updates
          Database.update(membersToUpdate.values());
          if(campaignResultsToInsert.size() > 0){
            Database.insert(campaignResultsToInsert.values());
          }
          if(campaignResultsToUpdate.size() > 0){
            Database.update(campaignResultsToUpdate.values());
          }
          
          
          return theCampaignIds;
          
    }
    
    private static List<Database.Saveresult> triggerPopukateResult = new List<Database.Saveresult>();
    private static void populateTriggerProcessManager(List<String> recordsForProcess,String targetObject, String triggerEvent){
        List<Trigger_Process_Manager__c> processLines = new  List<Trigger_Process_Manager__c>();
         String transBatch = getTransBatchID();
         
         for(String aRuleLine : recordsForProcess){
            String[] ruleFields =  aRuleLine.split(DELIM);
            
            Trigger_Process_Manager__c aLine = new Trigger_Process_Manager__c();
            aLine.Name =  'CampaignMemberResponSysStatusEvents '+transBatch;
            aLine.Process_Rule__c = aRuleLine;
            aLine.Target_ID__c = ruleFields[0];
            aLine.Target_Object__c = targetObject;
            aLine.Trigger_Name__c = 'CampaignMemberResponSysStatusEvents';
            aLine.Transact_Batch_ID__c = transBatch;
            aLine.Trigger_Event__c = triggerEvent;
            
            processLines.add(aLine);
         }
        
        if(RUN_IN_TEST_MODE == true){
            triggerPopukateResult.addAll(Database.insert(processLines));
        }else{
            Database.insert(processLines);
        }
            
    }
    
    private static String getTransBatchID(){
        String transBatchID = null;
            
                transBatchID = getRandomIDValue()+'';
        
        return transBatchID;
    }
    
    private static Long getRandomIDValue(){
        Long returnRandom = 0;
        
        do{
            returnRandom = (1000000000 * Math.random()).round();
        }while(returnRandom >=1000000000);
        return returnRandom;
    }
    
    
    
    private static Map<ID,Campaign_Results__c> getExisitingCampaignResultsByCampaigID(Set<ID> campaignIds){
            Map<ID,Campaign_Results__c> CResultsByCampaignId = new Map<ID,Campaign_Results__c>();
            
        for(Campaign_Results__c aCResult : [Select Id, Name,  Date_Sent__c, Number_Sent__c, Number_of_Clicked_Campaign_Link__c, 
                                            Number_of_Viewed_Message__c, Number_of_Opted_Out__c, Number_of_Hard_bounces__c, 
                                            Number_of_soft_bounces__c, Campaign__c FROM Campaign_Results__c
                                            WHERE Campaign__c IN :campaignIds]){
            CResultsByCampaignId.put(aCResult.Campaign__c,aCResult);
        }
        return CResultsByCampaignId;
        
    }
    private static Map<ID,Campaign> getCampaigns(Set<ID> campaignIds){
            Map<ID,Campaign> theCampaigns = new Map<ID,Campaign>([Select Id, Name, type  FROM Campaign WHERE id IN :campaignIds ]);
         
        return theCampaigns;
        
    }
    
    private static boolean confirmUserInResponSysGroup(Id currentUserId){
            Boolean confirmedResponSysMember = false;
            String responSysGroupName =  responSysIntegration.ResponSys_Integration_Group__c;
        // Get the group Id
        List<GroupMember> groupMemb = [Select Id, GroupId, UserOrGroupId, SystemModstamp FROM GroupMember WHERE  UserOrGroupId = :currentUserId];
        if(null != responSysGroupName && null != groupMemb && groupMemb.size() >0){
            
            Set<Id> groupIds = new Set<Id>();
            for(GroupMember aGroupMemb : groupMemb){
                groupIds.add(aGroupMemb.GroupId);
                
                
            }
            List<Group> theGroup = [Select Id, Name FROM Group WHERE Id IN:groupIds And Name = :responSysGroupName];
            if(null != theGroup && theGroup.size() > 0){
                if(theGroup[0].Name == responSysGroupName){
                    confirmedResponSysMember = true;
                }
            }
        }
        
        return confirmedResponSysMember;
    }
    // Added to track no of schedules
    public static Integer scheduleCount = 0;
    public static Date lastScheduleDate = null;
    public static Integer lastScheduleOffset = 0;
    
    public static string getScheduleString(Integer offsetHours){
        String SPACE_CHAR =' ';
        
        DateTime nowDate = System.now();
        nowDate = nowDate.addHours(offsetHours);
        
        Integer currentSeconds =  nowDate.second();
        Integer currentMinutes =  nowDate.minute();
        Integer currentHours =  nowDate.hour();
        Integer currentDay = nowDate.day();
        Integer currentMonth = nowDate.month();
        
        
        String schStr = currentSeconds + SPACE_CHAR + currentMinutes + SPACE_CHAR +  currentHours 
                                + SPACE_CHAR + currentDay + SPACE_CHAR + currentMonth + SPACE_CHAR + '?';
        
        return schStr;
    }
    
    public static void sendErrorEmail(){
        String responSysNotify =  responSysIntegration.ResponSys_Notify_Group__c;
        List<String> recipientsEmails = new List<String>();
        
        if(RUN_IN_TEST_MODE == false){
            //  Get the  Group
            Group theGroup = [Select Id, Name FROM Group WHERE Name = :responSysNotify];
            // Get the Members
            List<GroupMember> notifyMembers = [Select Id, GroupId, UserOrGroupId, SystemModstamp FROM GroupMember WHERE  GroupId = :theGroup.Id];
            Set<Id> userIds = new Set<Id>();
            for(GroupMember aNotifyMember :notifyMembers){
                userIds.add(aNotifyMember.UserOrGroupId);
            }
        
            // Get the User Emails
            Map<Id,User> mailRecipients = new Map<Id,User>([ SELECT id,userName,Email FROM User WHERE Id IN :userIds]);
            
            for(User theUser : mailRecipients.values()){
                recipientsEmails.add(theUser.Email);
            }
        }else{
            // use my test 
            recipientsEmails.add('mojo@valueretail.com');
        }
        // Set Up EMAIL 
        String subject = 'ResponSys Campaign Member Event.... Processing Pending or Error  '+System.now();
        String mailBody = 'Salesforce may have encountered error or hit processing limits. If there are records in the Trigger Process Manager object, please run this script in the Developer console :\n';
        mailBody = mailBody + ' Database.executeBatch(new AsyncCampaignMemberResponSysStatusEvents());';
        
        Messaging.SingleEmailMessage notify = new Messaging.SingleEmailMessage();
        
        notify.setSubject(subject);
        notify.setPlainTextBody(mailBody);
        notify.setToAddresses(recipientsEmails);
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { notify });
        
    }
    
    public class AggregationResult{
        public AggregationResult(){
            sentCount = 0;
            viewedMsgCount = 0;
            ClickedCampCount = 0;
            hardBouncedCount = 0;
            softBouncedCount = 0;
            optedOutCount= 0;
        }
    
            public Integer sentCount{get;set;}
            public Integer viewedMsgCount {get;set;}
            public Integer ClickedCampCount {get;set;}
            public Integer hardBouncedCount {get;set;}
            public Integer softBouncedCount {get;set;}
            public Integer optedOutCount  {get;set;}
    }
    // ///////////////////  Test Method ////////////////////////////////////////////////////
    static testMethod void testHandlingOfLimitException(){
        // Create the test campaign
        Test.startTest();
        
        Campaign theTestCampaign = createTestCampaign();
        
        // create the test testCampaignMembers. Create 13
        Integer contactCount = 10;
        Map<Id,Contact> testContacts = createContactsForTest(contactCount);
        List<CampaignMember> testCampaignMembers = setupTestMembers(testContacts.keySet());
        
        for(CampaignMember aMember : testCampaignMembers){
                aMember.CampaignId  = theTestCampaign.Id;
                aMember.Status = 'Sent';
        }
        RUN_IN_TEST_MODE = true;
        Database.SaveResult[] insertCampMembResults = Database.insert(testCampaignMembers);
        
        Map<Id,CampaignMember> insertedTestMembers = new Map<ID,CampaignMember>([SELECT Id, Status, CampaignId, ContactId  From CampaignMember WHERE CampaignId = :theTestCampaign.Id]);
        // create New Batch To Update
        List<CampaignMember> forUpdateCampaigns = new List<CampaignMember>();
        for(CampaignMember theMember : insertedTestMembers.values()){
             // change the status and fire off a a database update 
            theMember.Status = 'Viewed Message';
            forUpdateCampaigns.add(theMember);
        }
        
        Database.SaveResult[] computedResults =  Database.update(forUpdateCampaigns);
        List<Id> targetId =  new List<Id>();
        for(Database.SaveResult aRes : computedResults){
                    targetId.add(aRes.getId());
        }
        RUN_IN_TEST_MODE = false;
        // Select the Trigger Process 
        List<Trigger_Process_Manager__c> rulesToProcess = [SELECT Process_Rule__c,Target_ID__c,Target_Object__c,Transact_Batch_ID__c,Trigger_Name__c,Processed__c
                        FROM Trigger_Process_Manager__c WHERE Target_ID__c IN  :targetId ];
        // execute the Batch
        new AsyncCampaignMemberResponSysStatusEvents().execute(null,rulesToProcess);
        //Database.executeBatch(new AsyncCampaignMemberResponSysStatusEvents());
        
        Test.stopTest();
        
    }
    static testMethod  void testSendErrorEmail(){
        RUN_IN_TEST_MODE = true;
        sendErrorEmail();
        RUN_IN_TEST_MODE = false;
    }
    
    static testMethod void testGetScheduleString(){
        getScheduleString(2);
    } 
    
    static testMethod void testTrackCampaignMemberStatusChange(){
        // Create the Campaign
        Campaign theTestCampaign = createTestCampaign();
        
        // create the Campaign Members
        Integer contactCount = 8;
        Map<Id,Contact> testContacts = createContactsForTest(contactCount);
        List<CampaignMember> testCampaignMembers = setupTestMembers(testContacts.keySet());
        
        // Set Campaign Member stati
        Integer xx = 0;
            for(CampaignMember aMember : testCampaignMembers){
                aMember.CampaignId  = theTestCampaign.Id;
               
                 if(xx== 0){
                    aMember.status = 'Viewed Message';
                }else if(xx == 1){
                    aMember.status = 'Clicked Campaign Link';
                }else if(xx == 2){
                    aMember.status = 'Opted Out';
                }else if(xx == 3){
                    aMember.status = 'Soft Bounced';
                }else if(xx == 4){
                    aMember.status = 'Hard Bounced';
                 }else if(xx == 5){
                    aMember.status = 'Responded';
                }else if(xx == 6){
                    aMember.status = 'Complained of spam';
                }else{
                    aMember.status = 'Sent';
                }
                xx++;    
               
            }
            
            // Do Insert
            Test.startTest();
         Database.SaveResult[] insertCampMembResults = Database.insert(testCampaignMembers);
         Boolean membersInsertError = false; 
         List<Id> CampaignMemberIDS = new List<Id>();
        for(Database.SaveResult aResult : insertCampMembResults){
            if(aResult.isSuccess()){
                CampaignMemberIDS.add(aResult.getId());
            }else{
                membersInsertError = true;
            }
         }
         
         System.assertEquals(false,membersInsertError);
         
         Map<Id,CampaignMember> insertedTestMembers = new Map<ID,CampaignMember>([SELECT Id, Status, CampaignId, ContactId  From CampaignMember WHERE id IN :CampaignMemberIDS]);
         // Call Track Method
         RUN_IN_TEST_MODE = true;
         trackCampaignMemberStatusChange(insertedTestMembers, null);
         RUN_IN_TEST_MODE = false;
         
         if(triggerPopukateResult != null){
            Set<Id> theProcessIds = new Set<Id>();
            for(Database.Saveresult aResult : triggerPopukateResult){
                theProcessIds.add(aResult.getId());
                
            }
            Map<ID,Trigger_Process_Manager__c> testProcesses = new Map<Id,Trigger_Process_Manager__c>([SELECT Process_Rule__c,Target_ID__c,Target_Object__c,Transact_Batch_ID__c,Trigger_Name__c,Processed__c
                            FROM Trigger_Process_Manager__c 
                            WHERE Id IN :theProcessIds]);
                            
            Map<Id,Trigger_Process_Manager__c> campaignMemberMap = new Map<Id,Trigger_Process_Manager__c>();
            Map<Id,Trigger_Process_Manager__c> contactMap = new Map<Id,Trigger_Process_Manager__c>();
        
            for(Trigger_Process_Manager__c triggerProcessRule : testProcesses.values()){
                    if(triggerProcessRule.Target_Object__c == 'Contact'){
                        contactMap.put(triggerProcessRule.ID,triggerProcessRule);
                    }else if(triggerProcessRule.Target_Object__c == 'CampaignMember'){
                        campaignMemberMap.put(triggerProcessRule.ID,triggerProcessRule);
                    }
            }
         
            if(contactMap.size()>0){
                runTriggerProcessOnContact(contactMap);
            }
            if(campaignMemberMap.size()>0){
                Set<Id> affectedCampaigns = runTriggerProcess(campaignMemberMap);
            }
         }
         
         Test.stopTest();
         
    }
    
        static testMethod void testPopulateTriggerProcessManager(){
            List<String> contactToProcess = new List<String>();
            List<String> campaigns = new List<String>();
            contactToProcess.add('123456789qwertyuio___TheStatus___INSERT___');
            contactToProcess.add('123456789qwertyuio___TheStatus___INSERT___');
            
            campaigns.add('987654321qwertyuio___TheStatus___INSERT___');
            campaigns.add('987654321qwertyuio___TheStatus___INSERT___');
            

            populateTriggerProcessManager(contactToProcess,'Contact','INSERT');
            populateTriggerProcessManager(contactToProcess,'CampaignMember','INSERT');
            
        }
        static testMethod void testGetExisitingCampaignResultsByCampaigID(){
            Test.startTest();
            Campaign testCampaign = createTestCampaign();
            Campaign_Results__c testCampaignResult = new Campaign_Results__c();
            testCampaignResult.Campaign__c = testCampaign.Id;
            Database.insert(testCampaignResult);
            Set<ID> testIds = new Set<ID>();
            testIds.add(testCampaign.Id);
            getExisitingCampaignResultsByCampaigID(testIds);
            
            Test.stopTest();
        }
        
        static testMethod void testConfirmUserInResponSysGroup(){
            // Get Current User and Assert is NOT in ResponSys Group
            Id testUserId = UserInfo.getUserId();
            
            System.assertEquals(confirmUserInResponSysGroup(testUserId), false);
            
        }
        
        static testMethod void testGetCampaigns(){
            Test.startTest();
            
            Campaign testCampaign = createTestCampaign();
            Set<Id> testSet = new Set<Id>();
            testSet.add(testCampaign.Id);
            getCampaigns(testSet);
            
            Test.stopTest();
            
        }
        
        private static Campaign createTestCampaign(){
            Date nowDate = DateTime.newInstance(System.currentTimeMillis()).Date();
            Campaign retCampain = null;
            
            // create the Campaign
            Campaign  testCamp = new Campaign();
            testCamp.Campaign_Village_s__c = 'Bicester';
            testCamp.Name = 'SFDC Unit Tests';
            testCamp.StartDate = nowDate;
            testCamp.EndDate  = nowDate;
            testCamp.Campaign_Category__c = 'Mono Contact';
            testCamp.type = 'Email';
            testCamp.Incentive__c = '% Value Off (Brand)';
            testCamp.Target_Audience__c = 'Corporate';
            Database.Saveresult insertCampaignResult =  Database.insert(testCamp);
            
            if(insertCampaignResult.isSuccess()){
                // retrieve the object and return 
                retCampain = [SELECT id, Name FROM Campaign WHERE id = :insertCampaignResult.getId() ];
            }
            return retCampain;
        }
        
        private static  Map<Id,Contact> createContactsForTest(Integer numberOfXXCont){
        List<Contact> contactsInsert = new List<Contact>();
        
        // Create the Contact for testing
        for(Integer x =0;x< numberOfXXCont ;x++){
            Contact testContact = new Contact();
        
            testContact.FirstName = 'Testing_'+x;
            testContact.LastName = 'Testing'+DateTime.newInstance(System.currentTimeMillis());
            
            contactsInsert.add(testContact);
        }
        Boolean aFailure = false;
        
        // do Insert
        Database.SaveResult[] results = null;
        try{
            results = Database.insert(contactsInsert);
        }catch(Exception ex){
            //ContactUpsertManager.inTesting = false;
            System.debug('========ex'+ex);
            aFailure = true;
            
        }
        System.assertEquals(false, aFailure);
        System.debug('Attempt to create Contact');
        Set<Id> theContactIDs = new Set<Id>();
        for(Database.SaveResult aResult : results){
            if(aResult.isSuccess()){
                System.debug('====Succes Creating Contact =========');
                theContactIDs.add(aResult.getId());
            }else{
                System.debug('Failed Create====');
                aFailure = true;
                break;
            }
        }
        System.assertEquals(false, aFailure);
        
        // retrieve inserted Contacts
        Map<ID, Contact> retrieveContacts = new Map<Id,Contact>([SELECT Id, Name FROM Contact WHERE id IN  :theContactIDs]);
        
        return retrieveContacts;
    }
    
    private static List<CampaignMember> setupTestMembers(Set<Id> testContacts){
        List<CampaignMember> testMembers = new List<CampaignMember>();
        
        for(Id contId : testContacts){
            CampaignMember testMember = new CampaignMember();
            testMember.ContactId = contId;
            
            testMembers.add(testMember);
        }
        return testMembers;
    }
       
}