public with sharing class EtihardEarnPointsConfirmationController {
    public EtihardEarnPointsConfirmationController(){
        grpNumber =  ApexPages.currentPage().getParameters().get('grpNumberParam');
        grpFirstName =  ApexPages.currentPage().getParameters().get('grpFirstNameParam');
        grpLastName =  ApexPages.currentPage().getParameters().get('grpLastNameParam');
        
        grpName = grpFirstName + ' ' + grpLastName;
        
        String activityDateStr=  ApexPages.currentPage().getParameters().get('activityDateParam');
        activityDate = activityDateStr.substring(0,10);
        totalPointsBase =  ApexPages.currentPage().getParameters().get('totalPointsBaseParam');
        totalPointsBonus =  ApexPages.currentPage().getParameters().get('totalPointsBonusParam');
        transactionReference =  ApexPages.currentPage().getParameters().get('transactionReferenceParam');
    }
    
    public String totalPointsBase {get;set;}
    public String  totalPointsBonus {get;set;}
    public Boolean getRenderPointsBonus(){
    Integer totalPointsBonusINT =  Integer.valueOf(totalPointsBonus);
        if(totalPointsBonusINT <= 0){
            return false;
        }else{
            return true;
        }
    }
    public String grpNumber {get;set;}
    public String grpFirstName {get;set;}
    public String grpLastName {get;set;}
    public String grpName {get;set;}
    public String activityDate {get;set;}
    public String transactionReference {get;set;}
    
    public PageReference gotoPointsHome(){
        return Page.Points_Provider_Selection;
    }
    
    ///////////////////////////// Test  //////////////////////////////
    static testMethod void testEtihardEarnPointsConfirmation(){
        PageReference confirmPage = Page.Etihard_Earn_Points_Confirmation;
        
        confirmPage.getParameters().put('grpNumberParam','123456789012');
        confirmPage.getParameters().put('grpFirstNameParam','FirstName');
        confirmPage.getParameters().put('grpLastNameParam','LastName');
        
        
        confirmPage.getParameters().put('activityDateParam','2011-11-21 00:00:00 ');
        confirmPage.getParameters().put('totalPointsBaseParam','111');
        confirmPage.getParameters().put('totalPointsBonusParam','222');
        
        Test.setCurrentPage(confirmPage);
        
        EtihardEarnPointsConfirmationController confirmController = new EtihardEarnPointsConfirmationController();
        confirmController.getRenderPointsBonus();
        
        confirmController.gotoPointsHome();
        
    }

}