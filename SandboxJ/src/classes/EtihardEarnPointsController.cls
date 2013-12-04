public with sharing class EtihardEarnPointsController extends ThirdPartyPoints{
    
    public EtihardEarnPointsController(ApexPages.StandardController stdController){
        dummyPoints_Transaction = (Points_Transaction__c)stdController.getRecord();
        dummyPoints_Transaction.Promo_Type__c = BASIC_TYPE;
        String ticVillageName = getUserRetailVillage();
        if(ticVillageName !=null){
            transVillageCode = PointsProviderSelectionController.VILAGE_CODE_MAP.get(ticVillageName);   
        }else{
            ticUserRetailCenterError = TIC_USER_RETAIL_CENTER_ERROR_MSG;
        }
        
        custPointsProvider = PointsProvider__c.getInstance();
        verifySuccessful = true;
        BASIC_CONVERT_POINTS = Integer.valueOf(custPointsProvider.ETIHAD_BASE_RATE__c);
        
        // Default the activity date
        activityDate = System.now().Date();
        dummyPoints_Transaction.Activity_Date__c = activityDate;
        
    }
    
    public void resetAll(){
        grpNumber = null;
        grpFirstName= null;
        grpLastName = null;
        
        transactionInProcess = null;
        transactionBonusInProcess = null;
        bonusConversionValue = null;
        transactionItemsList = null;
        
        customerVerifyErrors = null;
        errorMessageConversion = null;
        
        renderBonusField = false;
        totalPointsAccrued = null;
        totalPointsAccruedBonus = null;
        totalTransAmountValue = null;
        
        dummyPoints_Transaction.Promo_Type__c = BASIC_TYPE;
        ticUserRetailCenterError = null;
    }
    
    public String grpNumber {get;set;}
    public String grpFirstName {get;set;}
    public String grpLastName {get;set;}
    
    public List<String> customerVerifyErrors{get;set;}
    private static final String GRP_NUMBER_REQ = 'Plrase provide 12 characyer GRP Number';
    private static final String CUST_FIRSTNAME = 'Plrase provide customer first name';
    private static final String CUST_SURNAME_REQ = 'Plrase provide customer surname';
    public Boolean getHasGRPVerifyError(){
        if(null != customerVerifyErrors && customerVerifyErrors.size()>0){
            return true;
        }else{
            return false; 
        }
    }
    
    private Boolean VerifyGRPEntries(){
        Boolean verifySuccessful = true;
        customerVerifyErrors = new List<String>(); 
        
        if(grpNumber == null || grpNumber.trim().length()== 0){
            customerVerifyErrors.add(GRP_NUMBER_REQ);
            verifySuccessful = false;
        }else if(grpNumber.trim().length() < 12){
            customerVerifyErrors.add(GRP_NUMBER_REQ);
            verifySuccessful = false;
        }
        if(grpFirstName == null || grpFirstName.trim().length() == 0){
            customerVerifyErrors.add(CUST_FIRSTNAME);
            verifySuccessful = false;
        }
        if(grpLastName == null || grpLastName.trim().length() == 0){
            customerVerifyErrors.add(CUST_SURNAME_REQ);
            verifySuccessful = false;
        }
        
        return verifySuccessful;
    }
    
    public Points_Transaction__c   transactionInProcess {get;set;}
    public Points_Transaction__c   transactionBonusInProcess {get;set;}
    
    private Boolean processTransaction(){
        Boolean processingSuccessful = true;
        if(transactionInProcess == null ){
            transactionInProcess = new Points_Transaction__c();
            if(dummyPoints_Transaction.Promo_Type__c == BONUS_TYPE){
                transactionBonusInProcess = new Points_Transaction__c();
            }
        }
        
        setupTransactionData();
        
        customerVerifyErrors = new List<String>();
        Boolean baseCallSuccess = true;
        Boolean bonusCallSuccess = true;
               
        // call Service
            EtihardPointsServiceClient etihadServiceClient = new  EtihardPointsServiceClient();
        List<String> callResult  = null;
        Boolean hasException = false;
        try{
            callResult =  etihadServiceClient.insertPoints(grpFirstName, grpLastName, transactionInProcess, transactionBonusInProcess);
            
            if(null != callResult && callResult.size()>0){
                // Check if Base Call successful
                if(callResult.get(0) == EtihardPointsServiceClient.SUCCESS_RESPONSE_CODE){
                    if((null != transactionBonusInProcess && callResult.size()> 2) ){
                        // All OK
                    }else if((null != transactionBonusInProcess && callResult.size()<2)&& (callResult.get(2) == EtihardPointsServiceClient.SUCCESS_RESPONSE_CODE)){
                        bonusCallSuccess = false;
                        customerVerifyErrors.add(callResult.get(2) +' : '+callResult.get(3));
                    }else if((null != transactionBonusInProcess && callResult.size()> 2) && (callResult.get(2) != EtihardPointsServiceClient.SUCCESS_RESPONSE_CODE)){
                        bonusCallSuccess = false;
                        customerVerifyErrors.add(callResult.get(2) +' : '+callResult.get(3));
                    }
                }else{
                    baseCallSuccess = false;
                    customerVerifyErrors.add(callResult.get(0) +' : '+callResult.get(1));
                }
            }else{
                customerVerifyErrors.add(' ---Unexpected Error Please report to Administrator ');
                baseCallSuccess = false;
                bonusCallSuccess = false;
            }
            
            
        }catch(Exception ex){
            customerVerifyErrors.add(' Unexpected Exception : '+ex);
            processingSuccessful = false;
            hasException = true;
        }finally{
             List<ID> sfdcTransIDs = doTransactionSave(callResult,hasException);
        }

            
            if(baseCallSuccess == false || bonusCallSuccess == false){
                processingSuccessful = false;
            }
        return processingSuccessful;
    }
    
    /*
    private void doTransactionUpdates(List<ID> transIDs,List<String> callResult){
        List<Points_Transaction__c> updateList = new List<Points_Transaction__c>();
        
        Map<ID,Points_Transaction__c> transMap = new Map<ID,Points_Transaction__c>([SELECT ID, Authorise_Code__c, Transaction_Status__c From Points_Transaction__c WHERE ID IN :transIDs ]);
        
        Points_Transaction__c baseTransForUpdate = transMap.get(transIDs[0]);
        baseTransForUpdate.Authorise_Code__c = callResult[0];
        if(callResult[0] == EtihardPointsServiceClient.SUCCESS_RESPONSE_CODE){
            baseTransForUpdate.Transaction_Status__c = 'CREDITING COMPLETE';
        }else{
            baseTransForUpdate.Transaction_Status__c = 'CREDITING FAILED';
        }
        
        updateList.add(baseTransForUpdate);
        
        if(transMap.size() > 1){
            Points_Transaction__c bonusTransForUpdate = transMap.get(transIDs[0]);
            bonusTransForUpdate.Authorise_Code__c = callResult[0];
            if(callResult[2] == EtihardPointsServiceClient.SUCCESS_RESPONSE_CODE){
                bonusTransForUpdate.Transaction_Status__c = 'CREDITING COMPLETE';
            }else{
                bonusTransForUpdate.Transaction_Status__c = 'CREDITING FAILED';
            }
        
            updateList.add(bonusTransForUpdate);
            
        }
        Database.Saveresult[] saveResultsForUpdate = Database.update(updateList);
        
    }
    
    */
    
    private List<ID> doTransactionSave( List<String> callResult, Boolean exceptionOccured){
        List<ID> retIDs = new List<ID>();
        
        List<Points_Transaction__c> transForInsert = new List<Points_Transaction__c>();
            
        if(exceptionOccured){
            if(null != transactionInProcess )transactionInProcess.Authorise_Code__c = '99';
            if(null != transactionBonusInProcess )transactionBonusInProcess.Authorise_Code__c = '99';
            
     
            if(null != transactionInProcess )transactionInProcess.Transaction_Status__c = 'UNEXPECTE EXCEPTION';
            if(null != transactionBonusInProcess )transactionBonusInProcess.Transaction_Status__c = 'UNEXPECTE EXCEPTION';
            
        }else{
            if(null != callResult && callResult.size()> 1){
                transactionInProcess.Authorise_Code__c = callResult[0];
                if(callResult[0] == EtihardPointsServiceClient.SUCCESS_RESPONSE_CODE){
                    transactionInProcess.Transaction_Status__c = 'CREDITING COMPLETE';
                }else{
                    transactionInProcess.Transaction_Status__c = 'CREDITING FAILED';
                }
            }
            
            if(null != transactionBonusInProcess){
                if(null != callResult && callResult.size()>2){
                    transactionBonusInProcess.Authorise_Code__c = callResult[2];
                    if(callResult[2] == EtihardPointsServiceClient.SUCCESS_RESPONSE_CODE){
                        transactionBonusInProcess.Transaction_Status__c = 'CREDITING COMPLETE';
                    }else{
                        transactionBonusInProcess.Transaction_Status__c = 'CREDITING FAILED';
                    }
                }
            }
        } 
        
        transForInsert.add(transactionInProcess);
            if(dummyPoints_Transaction.Promo_Type__c == BONUS_TYPE){
                transForInsert.add(transactionBonusInProcess);
            }  
         Database.Saveresult[] insertResult = Database.insert(transForInsert);
         
         if(insertResult != null && insertResult.size()> 0){
            if(insertResult[0].isSuccess()){
                retIDs.add(insertResult[0].getId());
            }
            if(insertResult.size()> 1){
                if(insertResult[1].isSuccess()){
                    retIDs.add(insertResult[1].getId());
                
                }
            }
        }
            return retIDs;    
    }
    
    private void setupTransactionData(){
        String transRef = null;
        // validate that the current transaction ref does NOT exist
        do{
            transRef = transVillageCode + VILLAGE_CODE_SUFFIX + getRandomIDValue(1000000000) + '' + getRandomIDValue(100000000);
            
        }while(((transRef+'').length() < 20) && checkIfExists(transRef)== true);
           
        transactionInProcess.Name = 'Etihard Earn Points By ' + grpNumber +' Trans Ref : '+ transRef;
        
        transactionInProcess.Customer_Card_Number__c = grpNumber;
        transactionInProcess.Transaction_Reference__c = transRef ;
        transactionInProcess.Transaction_Date__c = (DateTime.newInstanceGmt(System.now().Date(),System.now().Time())).addHours(4);
        
        transactionInProcess.Village_Code__c = (transVillageCode != null ? transVillageCode : null);
        transactionInProcess.Activity_Date__c = activityDate;
        transactionInProcess.Transaction_Value__c = totalTransAmountValue;
        transactionInProcess.Provider_Id__c = custPointsProvider.Etihard_Provider_ID__c;
        transactionInProcess.Promo_Type__c = BASIC_TYPE;
        transactionInProcess.Transaction_Type__c = PointsProviderSelectionController.POINTS_TRANS_TYPE_CREDIT;
        
        transactionInProcess.Points_Value__c = totalPointsAccrued;
        transactionInProcess.Transaction_Value__c = totalTransAmountValue;
        transactionInProcess.Transact_Quantity__c = ((transactionItemsList != null && transactionItemsList.size() > 0) ? transactionItemsList.size() : 0);
        transactionInProcess.Transaction_Value__c = totalTransAmountValue;
        
        transactionInProcess.VR_Transaction_Reference__c = transRef;
        transactionInProcess.Transaction_Status__c = 'PENDING';
        
        if(dummyPoints_Transaction.Promo_Type__c == BONUS_TYPE){
            String transBonusRef = null;
                do{
                    transBonusRef = transVillageCode + VILLAGE_CODE_SUFFIX + getRandomIDValue(1000000000) + '' + getRandomIDValue(100000000);
                }while(((transBonusRef+'').length() < 20) && checkIfExists(transBonusRef)== true);
                
            transactionBonusInProcess.Name = 'Etihard Earn Bonus Points By ' + grpNumber +' Trans Ref : '+ transBonusRef;
        
            transactionBonusInProcess.Customer_Card_Number__c = grpNumber;
            transactionBonusInProcess.Transaction_Reference__c = transBonusRef ;
            transactionBonusInProcess.Transaction_Date__c = (DateTime.newInstanceGmt(System.now().Date(),System.now().Time())).addHours(4);
            transactionBonusInProcess.Village_Code__c = (transVillageCode != null ? transVillageCode : null);
            transactionBonusInProcess.Activity_Date__c = activityDate;
            transactionBonusInProcess.Transaction_Value__c = totalTransAmountValue;
            transactionBonusInProcess.Provider_Id__c = custPointsProvider.Etihard_Provider_ID__c;
            transactionBonusInProcess.Promo_Type__c = dummyPoints_Transaction.Promo_Type__c;
            transactionBonusInProcess.Transaction_Type__c = PointsProviderSelectionController.POINTS_TRANS_TYPE_CREDIT;
        
            transactionBonusInProcess.Points_Value__c = totalPointsAccruedBonus;
            transactionBonusInProcess.Transaction_Value__c = totalTransAmountValue;
            transactionBonusInProcess.Transact_Quantity__c = ((transactionItemsList != null && transactionItemsList.size() > 0) ? transactionItemsList.size() : 0);
            transactionBonusInProcess.Transaction_Value__c = totalTransAmountValue;
        
            transactionBonusInProcess.VR_Transaction_Reference__c = transRef;
            transactionBonusInProcess.Transaction_Status__c = 'PENDING';
        }
         
    } 
    
    public PageReference doTransactionSubmit(){
        transactionInProcess = null;
        transactionBonusInProcess = null;
        
        PageReference confirmPage = null;
        if(VerifyGRPEntries() && confirmTransactionSubmit ==  true){
            // go on and start processing submission
            if(processTransaction() == true){
                confirmPage = Page.Etihard_Earn_Points_Confirmation;
                confirmPage.getParameters().put('grpNumberParam',grpNumber);
                confirmPage.getParameters().put('grpFirstNameParam',grpFirstName);
                confirmPage.getParameters().put('grpLastNameParam',grpLastName);
                
                confirmPage.getParameters().put('activityDateParam',transactionInProcess.Activity_Date__c+'');
               confirmPage.getParameters().put('totalPointsBaseParam',totalPointsAccrued+'');
               confirmPage.getParameters().put('totalPointsBonusParam',totalPointsAccruedBonus+'');
               confirmPage.getParameters().put('transactionReferenceParam',transactionInProcess.Transaction_Reference__c);
            }
        }
        return confirmPage;
    }
    
    ///////////////////////////////////  Tests //////////////////////////////////////
    static testMethod void testEtihardEarnPointsController(){
        Test.startTest();
        PageReference pageRef = new PageReference('/apex/Etihard_Earn_Points');
        ApexPages.StandardController ssPointsTransaction = new ApexPages.StandardController(new Points_Transaction__c());
        
        EtihardEarnPointsController etihardPoints = new EtihardEarnPointsController(ssPointsTransaction);
        
        System.assertEquals(etihardPoints.doTransactionSubmit(), null);
        System.assertEquals(etihardPoints.getHasGRPVerifyError(), true);
        
        etihardPoints.grpNumber = '123456';
        System.assertEquals(etihardPoints.doTransactionSubmit(), null);
        
        etihardPoints.grpNumber = '123456789012';
        etihardPoints.grpFirstName = 'Milton';
        etihardPoints.grpLastName = 'Denton';
        System.assertEquals(etihardPoints.doTransactionSubmit(), null);
        
        etihardPoints.dummyPoints_Transaction.Promo_Type__c = 'Bonus';
        etihardPoints.doConversion();
        System.assertEquals(etihardPoints.doTransactionSubmit(), null);
        
        etihardPoints.bonusConversionValue = 4;
        etihardPoints.doConversion();
        System.assertEquals(etihardPoints.doTransactionSubmit(), null);
        
         etihardPoints.setTransAmountValueString('100'); etihardPoints.doAddValue();
        etihardPoints.setTransAmountValueString('100'); etihardPoints.doAddValue();
        etihardPoints.setTransAmountValueString('100'); etihardPoints.doAddValue();
        
        etihardPoints.confirmTransactionSubmit =true;
        PageReference forwardTo = null;
        try{
            EtihardPointsServiceClient.inTesting = true;
            forwardTo = etihardPoints.doTransactionSubmit();
            EtihardPointsServiceClient.inTesting = false;
        }catch(Exception exp){
            EtihardPointsServiceClient.inTesting = false;
        }finally{
            EtihardPointsServiceClient.inTesting = false;
        }
        
        System.assertEquals((forwardTo == null ? false : true ), true);
        etihardPoints.resetAll();
       
       Test.stopTest();
       
        //System.assertEquals(etihardPoints.doTransactionSubmit(), Page.Etihard_Earn_Points_Confirmation);
    }

}