trigger CampaignMemberStatusSetup on Campaign (after insert) {
    SetupDefaultCampaignMemberStatus.steupCampaignMemberStatus(Trigger.newMap);
}