public with sharing class SetupDefaultCampaignMemberStatusTest {
    static testMethod void testCampaignCreation(){
    
        Campaign campaignForTest = new Campaign();
        
        campaignForTest.Name ='Testing Default Member Status';
        campaignForTest.StartDate = DateTime.newInstance(System.currentTimeMillis()).date();
        campaignForTest.EndDate = DateTime.newInstance(System.currentTimeMillis()).date();
        campaignForTest.Campaign_Village_s__c = 'Bicester';
        campaignForTest.Campaign_Category__c = 'Mono Contact';
        campaignForTest.Type ='Email';
        campaignForTest.Incentive__c = '% Value Off (Brand)';
        campaignForTest.Target_Audience__c = 'Trade Partnerships';
        
        Database.insert(campaignForTest);
        
    }

}