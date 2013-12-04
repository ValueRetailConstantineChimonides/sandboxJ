public with sharing class PointsProviderSelectionControllerTest {
    static testMethod void testPointsProvider(){
        PageReference pageRef = new PageReference('/apex/Points_Provider_Selection');
        
        ApexPages.StandardController ssPointsProvider = new ApexPages.StandardController(new Points_Provider__c());
        PointsProviderSelectionController ppSelectionController = new PointsProviderSelectionController(ssPointsProvider);
        
        system.assertequals('Airline',ppSelectionController.getSelectedProviderType());
        ppSelectionController.setSelectedProviderType('Hotel');
        
        system.assertequals('Hotel',ppSelectionController.getSelectedProviderType());
        
        ppSelectionController.setSelectedProviderType('Airline');
        ppSelectionController.doSelectProviderType();
        ppSelectionController.getPointsProviderOptions();
        PointsProvider__c  custPointsProvider = PointsProvider__c.getInstance();
        ppSelectionController.setSelectedProvider(custPointsProvider.Alitalia_Provider_ID__c);
        
        PageReference  pageTo = ppSelectionController.navigateToPtoviderPage();
        //System.assertEquals(pageTo, Page.Alitalia_Earn_Miles_Data_Capture);
        System.assertEquals(PointsProviderSelectionController.VILAGE_CODE_MAP.get('*Bicester Village'), 'BV');
        
        
        
        
        
        
        
        
    }
}