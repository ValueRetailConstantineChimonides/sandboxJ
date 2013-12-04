/*
     Use this script to execute the Schedule Job, If the Job is NOT currently scheduled :
     System.Schedule('ResponSys Campaign Member Synch','0 30 0,2,4,6,8,10,12,14,16,18,20,22 * * ?', new AsyncCampaignMemberResponSysStatusEvents() );

*/

global without sharing class AsyncCampaignMemberResponSysStatusEvents 
                implements Database.Batchable<SObject>, Schedulable {
                    
    private final String TriggerName = 'CampaignMemberResponSysStatusEvents';
    
    global void execute(SchedulableContext SC) {
        Database.executeBatch(new AsyncCampaignMemberResponSysStatusEvents());
    }
                    
    global Database.QueryLocator start(Database.BatchableContext BC){
        // Get all Trigger Process Manager rows that are NOT yet processed.
        
        String soqlStr = 'SELECT Process_Rule__c,Target_ID__c,Target_Object__c,Transact_Batch_ID__c,Trigger_Name__c,Processed__c'+
                                ' FROM Trigger_Process_Manager__c'+
                                    ' WHERE '+ 
                                    'Trigger_Name__c ='+'\''+TriggerName+'\''+
                                    ' AND '+
                                    ' Processed__c = false'+
                                    ' ORDER BY CreatedDate '+
                                    ' LIMIT 200000';
                        
        
        return Database.getQueryLocator(soqlStr);
    }
    private void process_CM_Status_TransactionBatch(List<Sobject> scope){
        // setup Maps to process transaction
        Map<Id,Trigger_Process_Manager__c> campaignMemberMap = new Map<Id,Trigger_Process_Manager__c>();
        Map<Id,Trigger_Process_Manager__c> contactMap = new Map<Id,Trigger_Process_Manager__c>();
        
        
        if(scope != null){
            if(scope.size() > 0){
                for(SObject so : scope){
                    Trigger_Process_Manager__c triggerProcessRule = (Trigger_Process_Manager__c)so;
                    if(triggerProcessRule.Target_Object__c == 'Contact'){
                        contactMap.put(triggerProcessRule.ID,triggerProcessRule);
                    }else if(triggerProcessRule.Target_Object__c == 'CampaignMember'){
                        campaignMemberMap.put(triggerProcessRule.ID,triggerProcessRule);
                    }
                }
                
            }
        }
        
        // Send In the transaction 
        if(contactMap.size()>0){
            CampaignMemberResponSysStatusEvents.runTriggerProcessOnContact(contactMap);
            stampAsCompleted(contactMap);
        }
         if(campaignMemberMap.size()>0){
            Set<Id> affectedCampaigns = CampaignMemberResponSysStatusEvents.runTriggerProcess(campaignMemberMap);
            //computeAggregation(affectedCampaigns);
            stampAsCompleted(campaignMemberMap);
        }
    }
    // Compute Aggregation
    public void computeAggregation(Set<id> theCampaignIds){
        List<Campaign_Results__c> allCampainMemberResults = [SELECT id,Campaign__c,Number_of_Hard_bounces__c,Number_of_soft_bounces__c,
        Number_of_Viewed_Message__c,Number_of_Clicked_Campaign_Link__c,Number_of_Opted_Out__c
            FROM 
                Campaign_Results__c
            WHERE
                Campaign__c IN :theCampaignIds];
      
      if(null == allCampainMemberResults || allCampainMemberResults.size() ==0 )return ;
    
    Map<ID,Campaign_Results__c> campaignResultsByCampaignID = new Map<ID,Campaign_Results__c>();
    
    for(Campaign_Results__c  acResult : allCampainMemberResults){
            campaignResultsByCampaignID.put(acResult.Campaign__c,acResult);
    }
    
    List<AggregateResult>  memberCounts = [SELECT CampaignID , COUNT(Id) FROM CampaignMember 
                        where  CampaignID IN :theCampaignIds
                        Group By CampaignID ];
      for (AggregateResult theCount : memberCounts)  {
            Id theCampaignIDAg = (ID)theCount.get('CampaignID');
            Integer countRec = Integer.valueOf(theCount.get('expr0'));
            
            Campaign_Results__c theCampaignResult = campaignResultsByCampaignID.get(theCampaignIDAg);
            if(null != theCampaignResult){
                theCampaignResult.Number_Sent__c = countRec;
                campaignResultsByCampaignID.put(theCampaignIDAg,theCampaignResult);
            }   
        }
        
    List<AggregateResult> campaignResultAggregate = [SELECT CampaignId, count(Hard_Bounced_Date__c),count(Soft_Bounced_Date__c),
        count(Viewed_Message_Date__c),count(Clicked_Campain_Link_Date__c),count(Opted_Out_Date__c) 
            FROM CampaignMember 
            WHERE
                CampaignId IN :theCampaignIds 
            GROUP By CampaignId];
                
        for(AggregateResult aResult :campaignResultAggregate){
            Id grpCampaignId = (Id)aResult.get('CampaignId');
            Integer hardBounceCount = Integer.valueOf(aResult.get('expr0'));
            Integer softBounceCount = Integer.valueOf(aResult.get('expr1'));
            Integer viewdMessageCount = Integer.valueOf(aResult.get('expr2'));
            Integer clickedCampaignLinkCount = Integer.valueOf(aResult.get('expr3'));
            Integer optedOutCount = Integer.valueOf(aResult.get('expr4'));
            
            //Set the Values
            Campaign_Results__c theCampaignResult = campaignResultsByCampaignID.get(grpCampaignId);
            if(null != theCampaignResult){
                theCampaignResult.Number_of_Hard_bounces__c = hardBounceCount;
                theCampaignResult.Number_of_soft_bounces__c = softBounceCount;
                theCampaignResult.Number_of_Viewed_Message__c = viewdMessageCount;
                theCampaignResult.Number_of_Clicked_Campaign_Link__c = clickedCampaignLinkCount;
                theCampaignResult.Number_of_Opted_Out__c = optedOutCount;
                
                campaignResultsByCampaignID.put(grpCampaignId,theCampaignResult);
            }
        }
        
        // Do database Update 
        if(campaignResultsByCampaignID.size() > 0){
            Database.update(campaignResultsByCampaignID.values());
        }
        
    }
    
    private void stampAsCompleted(Map<Id,Trigger_Process_Manager__c> processedMap){
        for(Id processId : processedMap.keySet()){
            processedMap.get(processId).Processed__c = true;
        }
        
            Database.update(processedMap.values());
        
    }

    
    global void execute(Database.BatchableContext BC, List<Sobject> scope){
        System.debug('### execute AsyncCampaignMemberResponSysStatusEvents ## ');
        process_CM_Status_TransactionBatch(scope);
    }
    
    global void finish(Database.BatchableContext BC){
        // Delete all Complted Processes
        System.debug('### finishing AsyncCampaignMemberResponSysStatusEvents ## ');
        Database.delete(new  List<Trigger_Process_Manager__c>([SELECT Id, Processed__c FROM Trigger_Process_Manager__c WHERE Processed__c = true AND Trigger_Name__c = :TriggerName  LIMIT 9500]));
        
    }
    
      
    
    public static Boolean inTesting = false; 
    static testMethod void testAggregation(){
        final List<CampaignMember> testCampaignMembersList = new List<CampaignMember>();
        final CampaignMember testCampaignMember = new CampaignMember();
        final CampaignMember testCampaignMember_2 = new CampaignMember();
        
        Date nowDate = DateTime.newInstance(System.currentTimeMillis()).Date();
        
        Test.startTest();
        
        // Campaign Member !
        testCampaignMember.Sent__c = true;
         testCampaignMember.Sent_Date__c  = nowDate;
         testCampaignMember.Clicked_Campain_Link__c = true;
         testCampaignMember.Clicked_Campain_Link_Date__c =  nowDate;
         testCampaignMember.Viewed_Message__c = true;
         testCampaignMember.Viewed_Message_Date__c = nowDate;
         
         // Campaign Member 2
         testCampaignMember_2.Sent__c = true;
         testCampaignMember_2.Sent_Date__c  = nowDate;
         testCampaignMember_2.Soft_Bounced__c = true;
         testCampaignMember_2.Soft_Bounced_Date__c = nowDate;
         testCampaignMember_2.Hard_Bounced_Date__c = nowDate;
         
         // Create Contacts
         List<Contact> testContacts = new List<Contact>();
         Contact testContact = new Contact();
         testContact.FirstName = 'Testing_ One';
         testContact.LastName = 'Testing1';
         
         Contact testContact_2 = new Contact();
         testContact_2.FirstName = 'Testing_ Two';
         testContact_2.LastName = 'Testing2';
         
         testContacts.add(testContact);
         testContacts.add(testContact_2);
         
         Database.SaveResult[] results = Database.insert(testContacts); 
         
         testCampaignMember.ContactId = results[0].getId();
         testCampaignMember_2.ContactId = results[1].getId();
         
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
        
        Set<Id> campaignIds = new Set<Id>{insertCampaignResult.getId()};
        
        testCampaignMember.CampaignId = insertCampaignResult.getId();
         testCampaignMember_2.CampaignId = insertCampaignResult.getId();
         testCampaignMembersList.add(testCampaignMember);
         testCampaignMembersList.add(testCampaignMember_2);
         
         //create Campaign Result
         Campaign_Results__c testCMResult = new Campaign_Results__c();
         testCMResult.Campaign__c = insertCampaignResult.getId();
          Database.Saveresult cmr = Database.insert(testCMResult);
          
         AsyncCampaignMemberResponSysStatusEvents.inTesting = true;
         
         Database.Saveresult[] campaignMembersInsertResult =  Database.insert(testCampaignMembersList);
         AsyncCampaignMemberResponSysStatusEvents testObj = new AsyncCampaignMemberResponSysStatusEvents();
         testObj.computeAggregation(campaignIds);
         
         AsyncCampaignMemberResponSysStatusEvents.inTesting = false;
         
         Database.delete(testCampaignMembersList.get(0));
         
         Test.stopTest();
         
         
         
    }
    
}