public class AlitaliaConfirmationScreenController {
    public AlitaliaConfirmationScreenController(){
        mmCode =  ApexPages.currentPage().getParameters().get('mmCodeParam');
        customerSurname =  ApexPages.currentPage().getParameters().get('customerSurnameParam');
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
    public String mmCode {get;set;}
    public String customerSurname {get;set;}
    public String activityDate {get;set;}
    public String transactionReference {get;set;}
    
    public PageReference gotoPointsHome(){
        return Page.Points_Provider_Selection;
    }
    

}