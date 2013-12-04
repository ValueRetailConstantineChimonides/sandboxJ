public class SetupDefaultCampaignMemberStatus {
    public static void steupCampaignMemberStatus(Map<ID,Campaign> newCampaigns){
        deleteCurrentStatus(newCampaigns.keySet());
        Map<ID,Map<String,CampaignMemberStatus>> currentCampaignMemberstatusByCampaignID = retrieveCampaignMemberStatus(newCampaigns.keySet());
        System.debug('==== currentCampaignMemberstatusByCampaignID '+currentCampaignMemberstatusByCampaignID.size());
        
        List<CampaignMemberStatus> statusInsert = new List<CampaignMemberStatus>();
        List<CampaignMemberStatus> statusUpdate = new List<CampaignMemberStatus>();
        
        // Iterate through all the current Campaigns and the member status 
        // validate it against the REQUIRED List
        for(ID aCampaignID : currentCampaignMemberstatusByCampaignID.keySet()){
            Map<String,CampaignMemberStatus> currentStatusAvailable = currentCampaignMemberstatusByCampaignID.get(aCampaignID);
            for(String statusLabel : getRequiredCampaignMemberStatus().keySet()){
                if(currentStatusAvailable.get(statusLabel)== null ){
                    CampaignMemberStatus newMemberStatus = new CampaignMemberStatus();
                    System.debug('======= aCampaignID'+aCampaignID);
                    newMemberStatus.CampaignId = aCampaignID;
                    newMemberStatus.Label = statusLabel;
                    setCampaignMemberStatusFields(newMemberStatus,getRequiredCampaignMemberStatus().get(statusLabel));
                    System.debug('====About to Add =====To Insert'+newMemberStatus.Label+' '+newMemberStatus.campaignId+' '+newMemberStatus.sortOrder);
                    statusInsert.add(newMemberStatus);
                }else{
                    CampaignMemberStatus availableStati = currentStatusAvailable.get(statusLabel);
                    setCampaignMemberStatusFields(availableStati,getRequiredCampaignMemberStatus().get(statusLabel));
                    System.debug('====About to Add =====To Update'+availableStati.Label+' '+availableStati.campaignId+' '+availableStati.sortOrder+' '+availableStati.Id);
                    statusUpdate.add(availableStati);
                }
                
            }
                
        }
        
        // Do the Inser and Update
        doUpdate(statusUpdate);
        doInsert(statusInsert);
        
        
    }
    
    private static void doInsert(List<CampaignMemberStatus> statusInsert){
        Database.Saveresult[] results = Database.insert(statusInsert);
        List<CampaignMemberStatus> failedInserts = new List<CampaignMemberStatus>();
        Integer resultPointer = 0;
        for(Database.SaveResult result : results) {
            if(!result.isSuccess()) {
                CampaignMemberStatus failedItem = statusInsert.get(resultPointer);
            }
            resultPointer++;
        }
    }
    
    private static void doUpdate(List<CampaignMemberStatus> statusUpdate){
        Database.Saveresult[] results = Database.update(statusUpdate);
        List<CampaignMemberStatus> failedUpdates = new List<CampaignMemberStatus>();
        Integer resultPointer = 0;
        for(Database.SaveResult result : results) {
            if(!result.isSuccess()) {
                CampaignMemberStatus failedItem = statusUpdate.get(resultPointer);
            }
            resultPointer++;
        }
    }

    
    private static void setCampaignMemberStatusFields(CampaignMemberStatus memberStatusTarget, CampaignMemberStatus memberStatusSource){
        memberStatusTarget.SortOrder = memberStatusSource.SortOrder;
        memberStatusTarget.IsDefault = memberStatusSource.IsDefault;
        memberStatusTarget.HasResponded = memberStatusSource.HasResponded;
    }
    
    private static Map<ID,Map<String,CampaignMemberStatus>> retrieveCampaignMemberStatus(Set<ID> campaignIDS){
        Map<ID,Map<String,CampaignMemberStatus>> currentCampaignMemberstatus = new Map<ID,Map<String,CampaignMemberStatus>>();
        
        for(CampaignMemberStatus acurrentStatus : [SELECT Id,CampaignId, Label, SortOrder, IsDefault, HasResponded 
                    FROM CampaignMemberStatus WHERE CampaignId IN :campaignIDS]){
                        
                    if(currentCampaignMemberstatus.get(acurrentStatus.CampaignId)== null){
                        Map<String,CampaignMemberStatus> statusList  = new Map<String,CampaignMemberStatus>();
                        statusList.put(acurrentStatus.Label,acurrentStatus);
                        currentCampaignMemberstatus.put(acurrentStatus.CampaignId,statusList);
                    }else{
                        currentCampaignMemberstatus.get(acurrentStatus.CampaignId).put(acurrentStatus.Label,acurrentStatus);
                    }
            
        }
        return currentCampaignMemberstatus;
    }
    
    private static Map<String, CampaignMemberStatus> getRequiredCampaignMemberStatus(){
        Map<String, CampaignMemberStatus> requiredCampaignMemberStatus = new Map<String,CampaignMemberStatus>();
        
        if(requiredCampaignMemberStatus.size() == 0){
            CampaignMemberStatus SkippedOrFailedStatus = new CampaignMemberStatus();
            SkippedOrFailedStatus.Label = 'Skipped/Failed';
            SkippedOrFailedStatus.SortOrder =2;
            SkippedOrFailedStatus.IsDefault = false;
            SkippedOrFailedStatus.HasResponded = false;
            requiredCampaignMemberStatus.put('Skipped/Failed',SkippedOrFailedStatus);   
        
            CampaignMemberStatus SentStatus = new CampaignMemberStatus();
            SentStatus.Label = 'Sent';
            SentStatus.SortOrder =1;
            SentStatus.IsDefault =true;
            SentStatus.HasResponded = false;
            requiredCampaignMemberStatus.put('Sent',SentStatus);
        
            CampaignMemberStatus HardBouncedStatus = new CampaignMemberStatus();
            HardBouncedStatus.Label = 'Hard Bounced';
            HardBouncedStatus.SortOrder =3;
            HardBouncedStatus.IsDefault = false;
            HardBouncedStatus.HasResponded = false;
            requiredCampaignMemberStatus.put('Hard Bounced',HardBouncedStatus);
        
            CampaignMemberStatus SoftBouncedStatus = new CampaignMemberStatus();
            SoftBouncedStatus.Label = 'Soft Bounced';
            SoftBouncedStatus.SortOrder =4;
            SoftBouncedStatus.IsDefault = false;
            SoftBouncedStatus.HasResponded = false;
            requiredCampaignMemberStatus.put('Soft Bounced',SoftBouncedStatus);
        
            CampaignMemberStatus ViewedMessageStatus = new CampaignMemberStatus();
            ViewedMessageStatus.Label = 'Viewed Message';
            ViewedMessageStatus.SortOrder =5;
            ViewedMessageStatus.IsDefault = false;
            ViewedMessageStatus.HasResponded = false;
            requiredCampaignMemberStatus.put('Viewed Message',ViewedMessageStatus);
        
            CampaignMemberStatus ClickedCampaignLinkStatus = new CampaignMemberStatus();
            ClickedCampaignLinkStatus.Label = 'Clicked Campaign Link';
            ClickedCampaignLinkStatus.SortOrder =6;
            ClickedCampaignLinkStatus.IsDefault = false;
            ClickedCampaignLinkStatus.HasResponded = false;
            requiredCampaignMemberStatus.put('Clicked Campaign Link',ClickedCampaignLinkStatus);
        
            CampaignMemberStatus CompletedFormStatus = new CampaignMemberStatus();
            CompletedFormStatus.Label = 'Completed Form';
            CompletedFormStatus.SortOrder =7;
            CompletedFormStatus.IsDefault = false;
            CompletedFormStatus.HasResponded = false;
            requiredCampaignMemberStatus.put('Completed Form',CompletedFormStatus);
        
            CampaignMemberStatus ConvertedStatus = new CampaignMemberStatus();
            ConvertedStatus.Label = 'Converted';
            ConvertedStatus.SortOrder =8;
            ConvertedStatus.IsDefault = false;
            ConvertedStatus.HasResponded = false;
            requiredCampaignMemberStatus.put('Converted',ConvertedStatus);
        
            CampaignMemberStatus OptedOutStatus = new CampaignMemberStatus();
            OptedOutStatus.Label = 'Opted Out';
            OptedOutStatus.SortOrder = 9;
            OptedOutStatus.IsDefault = false;
            OptedOutStatus.HasResponded = false;
            requiredCampaignMemberStatus.put('Opted Out',OptedOutStatus);
        
            CampaignMemberStatus ComplainedOfSpamStatus = new CampaignMemberStatus();
            ComplainedOfSpamStatus.Label = 'Complained of spam';
            ComplainedOfSpamStatus.SortOrder = 10;
            ComplainedOfSpamStatus.IsDefault = false;
            ComplainedOfSpamStatus.HasResponded = false;
            requiredCampaignMemberStatus.put('Complained of spam',ComplainedOfSpamStatus);
        
            CampaignMemberStatus RespondedStatus = new CampaignMemberStatus();
            RespondedStatus.Label = 'Responded';
            RespondedStatus.SortOrder = 11;
            RespondedStatus.HasResponded = true;
            RespondedStatus.IsDefault = false;
            requiredCampaignMemberStatus.put('Responded',RespondedStatus);
            
        }
        return requiredCampaignMemberStatus;
    }
    private static void deleteCurrentStatus(Set<ID> campaignIDS){
        List<CampaignMemberStatus> statusList = [SELECT Id,CampaignId, Label, SortOrder, IsDefault, HasResponded 
                    FROM CampaignMemberStatus WHERE CampaignId IN :campaignIDS AND Label = 'Responded'];
                    
        Database.delete(statusList);
    }

}