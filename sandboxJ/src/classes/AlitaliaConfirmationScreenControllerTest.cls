public with sharing class AlitaliaConfirmationScreenControllerTest {
    static testMethod void testAlitaliaConfirmationScreenController(){
        PageReference confirmPage = Page.AlitaliaConfirmationScreen;
        confirmPage.getParameters().put('customerSurnameParam','SunShine');
        confirmPage.getParameters().put('activityDateParam','2011-11-21 00:00:00 ');
        confirmPage.getParameters().put('totalPointsBaseParam','111');
        confirmPage.getParameters().put('totalPointsBonusParam','222');
        
        Test.setCurrentPage(confirmPage);
        
        AlitaliaConfirmationScreenController confirmController = new AlitaliaConfirmationScreenController();
        confirmController.getRenderPointsBonus();
        
        
    }
}