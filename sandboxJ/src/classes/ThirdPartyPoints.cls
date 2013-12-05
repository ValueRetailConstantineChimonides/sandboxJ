public virtual class ThirdPartyPoints {
    protected PointsProvider__c custPointsProvider;
    public String ticUserRetailCenterError {get;set;}
    public String transVillageCode {get;set;}
    public Points_Transaction__c   dummyPoints_Transaction {get;set;}
    protected final String BASIC_TYPE='Base';
    protected  final String TIC_USER_RETAIL_CENTER_ERROR_MSG='User Account Setup Error !!! Please contact Administrator.';
    
    public Boolean inTesting= false;
    protected String getUserRetailVillage(){
        if(!inTesting){
                    String ticVillageName = '';
        // get the currently logged In User ID
        String userID = System.Userinfo.getUserId();
        for(User TICUser : [SELECT u.name,u.retail_Centre__c  from User u
                            where u.ID= :userID]){
                ticVillageName = TICUser.retail_Centre__c;
            System.debug('=='+ TICUser.name+'==='+ ticVillageName);
        
        }
        return ticVillageName;
        
        }else{
            return '*Bicester Village';
        }

    }
    
    // Code  for Points Calculation Section
    public Boolean   verifySuccessful {get;set;}
    public Decimal   totalTransAmountValue {get;set;}
    public Integer   totalPointsAccrued {get;set;}
    public Integer   totalPointsAccruedBonus {get;set;}
    public Boolean   renderBonusField {get;set;}
    public Decimal bonusConversionValue {get;set;}
    private String transAmountValueString=null;
    public List<TransactionItem>  transactionItemsList {get;set;}
    public List<TransactionItem>  transactionItemsListBuffer {get;set;}
    protected final String BONUS_TYPE='Bonus';
    public Date activityDate {get;set;}
    public String userCurrentDateAsString {get;set;}
    
     // to determine where doConversion is called from 
    protected Boolean doneOnChange = false;
    
    public String   transactBasicBonus {get;set;}
    protected Integer BASIC_CONVERT_POINTS = 1;
    
    public List<String>   errorMessageConversion {get;set;}
    public Decimal   transAmountValue {get;set;}
    
    //private static final Integer BONUS_CONVERT_POINTS= 3;
    public static final String   CONVERT_AMOUNT_VALUE_ERROR='* Conversion amount must be greater than 0 and less than 1,000,000.';
    
    protected final String BONUS_FIELD_REQ='* Invalid Bonus Conversion Ratio ';
    protected final String BAIC_OR_BONUS_REQ='Please make sure you select a Basic or Bonus points type';
    protected final String ACTIVITY_DATE_REQ='*Please provide the Activity Date';
    
    public Boolean confirmTransactionSubmit {get;set;}
    
    protected final String  VILLAGE_CODE_SUFFIX='0';
    
    public void doRenderBonusField(){
        this.transactBasicBonus=dummyPoints_Transaction.Promo_Type__c;
        if(this.transactBasicBonus == BONUS_TYPE){
            renderBonusField = true;
        }else{
            renderBonusField = false;
            bonusConversionValue = 0;
        }
        // call doConvert if necessary
        if(totalTransAmountValue != null && totalTransAmountValue >0){
            doneOnChange=true;
            doConversion();
            doneOnChange=false;
        }
    }

    public Boolean getRenderBONUS_POINTS_RESULTS(){
        if(totalPointsAccruedBonus != null && totalPointsAccruedBonus > 0){
            return true;
        }else{
            return false;
        }
        
    }
    
    public void doConversion(){
        transactBasicBonus=dummyPoints_Transaction.Promo_Type__c;
        activityDate = dummyPoints_Transaction.Activity_Date__c;
        
        if(validateConvert()){
            Integer pointsCalculated = 0;
            Integer pointsCalculatedBonus = 0;
            // check if it is a BONUS transaction
            if(transactBasicBonus == BONUS_TYPE){
                 // do BONUS
        
                 //pointsCalculated = (Integer)(totalTransAmountValue  * BASIC_CONVERT_POINTS).round();
                 Long valLong = ((totalTransAmountValue  * BASIC_CONVERT_POINTS).round());
                 pointsCalculated = Integer.valueOf(valLong);
                 
                 if(!(bonusConversionValue ==null || bonusConversionValue ==0)){
                    Long valLongBonus = (pointsCalculated  * bonusConversionValue).round();
                    pointsCalculatedBonus = Integer.valueOf(valLongBonus);
                    
                 }else{
                    pointsCalculatedBonus= 0;
                 }
                 
                  
            }else{
                Long vvalLongCal = (totalTransAmountValue  * BASIC_CONVERT_POINTS).round();
                pointsCalculated = Integer.valueOf(vvalLongCal);
            }
            
            // set The Points for display
            totalPointsAccrued = pointsCalculated;
            totalPointsAccruedBonus = (pointsCalculatedBonus - pointsCalculated);
        }
        
    }
    
    public void doAddValue(){
        if(validateAddTransAmmountValue()){
            errorMessageConversion =new List<String>();
            if(transactionItemsList == null){
                transactionItemsList = new List<TransactionItem>();
                // (Added for pagenation) transactionItemsListList = new List<List<TransactionItem>>();
            }
        
            if(totalTransAmountValue == null){
                totalTransAmountValue = 0;
            }
        
            // create the transaction items
            TransactionItem tranItem = new TransactionItem();
            tranItem.itemValue =transAmountValue;
        
            transactionItemsList.add(tranItem);
            totalTransAmountValue+=transAmountValue;
            
            transAmountValue = null;
            
            //call convert  to dynamically update points calculation
            doConversion();
            
        }
    }
    
    public Boolean getHasRowsToRender(){
        if(transactionItemsList != null && transactionItemsList.size()>0){
            return true;
        }else{
            return false;
        }
    }
    
    
    public void doRemoveTransaction(){
        if(transactionItemsList != null && transactionItemsList.size() > 0){
            for(Integer x=0;x<transactionItemsList.size();x++){
                TransactionItem anItem = transactionItemsList.get(x);
                if(anItem.removeItem == true){
                    totalTransAmountValue=totalTransAmountValue - anItem.itemValue;
                    transactionItemsList.remove(x);
                    x--;
                }
            }
            
            // call convert to update Points.
            if(transactionItemsList.size()> 0 && totalTransAmountValue > 0){
                doConversion();
            }else if(totalTransAmountValue ==0){
                // clear points calculation 
                totalPointsAccrued = 0;
                totalPointsAccruedBonus =0;
                
            }
        }
    }
    
    private Boolean validateConvert(){
        Boolean returnValidateSuccess = true;
        List<String> errorConvMsgBuff = new List<String>();
        if(totalTransAmountValue == null){
            errorConvMsgBuff.add(CONVERT_AMOUNT_VALUE_ERROR);
            returnValidateSuccess=false;
        }
        if(totalTransAmountValue <= 0 || totalTransAmountValue > 1000000){
            errorConvMsgBuff.add(CONVERT_AMOUNT_VALUE_ERROR);
            returnValidateSuccess=false;
        }
        
        if(!doneOnChange){ // checks to see that call was NOT done from BASIC/BONUS drop down
            if(transactBasicBonus !=null && transactBasicBonus == BONUS_TYPE){
                if(bonusConversionValue == null || bonusConversionValue <= BASIC_CONVERT_POINTS){
                    errorConvMsgBuff.add(BONUS_FIELD_REQ);
                    returnValidateSuccess=false;
                }
            }
        
            if(transactBasicBonus == null || transactBasicBonus.trim().length()==0){
                errorConvMsgBuff.add(BAIC_OR_BONUS_REQ);
                returnValidateSuccess=false;
            }
        }
        
        if(activityDate == null){
            errorConvMsgBuff.add(ACTIVITY_DATE_REQ);
            returnValidateSuccess=false;
        }
            
        errorMessageConversion = errorConvMsgBuff;
        
        return returnValidateSuccess;
    }
    
    protected Boolean validateAddTransAmmountValue(){
        if((transAmountValue <= 0 || transAmountValue > 1000000)){
            errorMessageConversion = new List<String>();
            errorMessageConversion.add(CONVERT_AMOUNT_VALUE_ERROR);
             return false;
        }else{
            return true;
        }
    }
    
    public void   setTransAmountValueString(String transAmountValueString) {
        this.transAmountValueString = transAmountValueString;
        transAmountValue = Decimal.valueOf(transAmountValueString);
    }
    
    public String   getTransAmountValueString() {
        if(transAmountValue != null && transAmountValue > 0){
            return transAmountValue.setScale(2)+'';
        }else{
            return '0.00';
        }
    }
    
    public Boolean getHasConversionorAddError(){
        if(errorMessageConversion != null && errorMessageConversion.size()>0){
            return true;
        }else{
            return false;
        }
    }
    
    protected Long getRandomIDValue(){
        Long returnRandom = 0;
        
        do{
            returnRandom = (10000000 * Math.random()).round();
        }while(returnRandom >= 10000000);
        return returnRandom;
    }
    
    protected Long getRandomIDValue(Long multiplier){
        Long returnRandom = 0;
        
        do{
            returnRandom = (multiplier * Math.random()).round();
        }while(returnRandom >= multiplier);
        return returnRandom;
    }
    
    protected Boolean checkIfExists(String newTransRef){
        List<Points_Transaction__c> checkRow= [SELECT pT.ID FROM Points_Transaction__c pT 
                WHERE pT.Transaction_Reference__c =  :newTransRef];
                
        if(checkRow == null ||  checkRow.size()== 0){
            return false;
        }else{
            return true;
        }
    }
     
    
    public class TransactionItem{
        public String   itemTypeBasicBonus {get;set;}
        public String   itemTypeCreditDebit {get;set;}
        public Decimal   itemValue {get;set;}
        public Integer   itemPoints {get;set;}
        public Boolean   removeItem {get;set;}
    }

}