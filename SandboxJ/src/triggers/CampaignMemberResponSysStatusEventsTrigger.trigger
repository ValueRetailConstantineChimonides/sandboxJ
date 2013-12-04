trigger CampaignMemberResponSysStatusEventsTrigger on CampaignMember (after insert, after update, after delete) {
        if(AsyncCampaignMemberResponSysStatusEvents.inTesting == true){
            return;
        }
        if(Trigger.isInsert){
            CampaignMemberResponSysStatusEvents.trackCampaignMemberStatusChange(Trigger.newMap,null);
        }
        if(Trigger.isUpdate){
           CampaignMemberResponSysStatusEvents.trackCampaignMemberStatusChange(Trigger.newMap, Trigger.oldMap);
        }
        if(Trigger.isDelete){
            //Set<Id> campaignIdSet = new Set<Id>();
            //for(CampaignMember oldCM : Trigger.oldMap.values()){
                    //campaignIdSet.add(oldCM.CampaignId);
            //}
           // AsyncCampaignMemberResponSysStatusEvents forDelteProcessing = new AsyncCampaignMemberResponSysStatusEvents();
           // forDelteProcessing.computeAggregation(campaignIdSet);
        }
}