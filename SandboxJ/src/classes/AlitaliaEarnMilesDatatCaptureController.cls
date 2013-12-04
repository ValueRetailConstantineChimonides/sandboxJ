public with sharing class AlitaliaEarnMilesDatatCaptureController extends ThirdPartyPoints{
    public String   mileMigliaNo {get;set;}
    public String   custSurname {get;set;}
    private AlitaliaPointsServiceClient serviceClient;
    
    public Boolean   mileMigliaNoReadOnly {get;set;}
    
    public Boolean   custSurnameReadOnly {get;set;}
    public Boolean   verifyCustBtnReadOnly {get;set;}
    public Boolean   disableCancelButton {get;set;}
    
    
    private static final String VERIFY_CUSTOMER_STAGE='Verify';
    private static final String CUSTOMER_VERIFIED_STAGE='Verified';
    private static final String SUBMIT_TRANSACTION='submitTransaction';
    private static final String TRANSACTION_SUBMITTED='transactionSubmitted';
    
    private static final String VERIFY_CUSTOMER_SUCCESS_CODE = '0000';
    private static final String CREDIT_SUCCESS_CODE = '0000';
    
    public String   transactionCreditDebit {get;set;}
    
    public Boolean   validateConversionSuccess {get;set;}
    
    public List<String>   errorMessageCustomerVerify {get;set;}
    
    // error Messageconstants
    private static final String MM_NO_REQUIRED = '* MilleMiglia No  Number is required.';
    private static final String MM_NO_LENGTH_ERROR = '* MilleMiglia No  length Error ! Incorrect number of digits';
    private static final String CUST_SURNAME_REQ = '* Customer Surname is required.';
    
    public Points_Transaction__c   transactionInProcess {get;set;}
    
    public AlitaliaEarnMilesDatatCaptureController(ApexPages.StandardController stdController) {
        System.debug('AlitaliaEarnMilesDatatCaptureController');
        dummyPoints_Transaction = (Points_Transaction__c)stdController.getRecord();
        dummyPoints_Transaction.Promo_Type__c = BASIC_TYPE;
        String ticVillageName = getUserRetailVillage();
        if(ticVillageName !=null){
            transVillageCode = PointsProviderSelectionController.VILAGE_CODE_MAP.get(ticVillageName);   
        }else{
            ticUserRetailCenterError = TIC_USER_RETAIL_CENTER_ERROR_MSG;
            disableAllUI();
        }
        
        custPointsProvider = PointsProvider__c.getInstance();
        BASIC_CONVERT_POINTS = Integer.valueOf(custPointsProvider.ALITALIA_BASE_RATE__c);
    }
    
    private String verifyCustomerAuthorisationCode {get;set;}
    private String creditPointsAuthorisationCode {get;set;}
    private String finalTransactionStatus {get;set;}
    
    public void verifyCustomer(){
        Integer mileMigliaConfMin = Integer.valueOf(custPointsProvider.Alitalia_Min_Card_Digits__c);
        Integer mileMigliaConfMax = Integer.valueOf(custPointsProvider.Alitalia_Max_Card_Digits__c);
        
        verifySuccessful  = true;
        errorMessageCustomerVerify = new List<String>();
        
        List<String> errorMsg = new List<String>();
        if(mileMigliaNo == null || (mileMigliaNo.length()==0)){
            errorMsg.add(MM_NO_REQUIRED);
            verifySuccessful  = false;
        }else if(mileMigliaNo != null && ((mileMigliaNo.trim().length() < mileMigliaConfMin) || (mileMigliaNo.trim().length() > mileMigliaConfMax))){
            errorMsg.add(MM_NO_LENGTH_ERROR);
            verifySuccessful  = false;
        }
        if(custSurname == null || custSurname.length()==0){
            errorMsg.add(CUST_SURNAME_REQ);
            verifySuccessful  = false;
        }
        System.debug('VERIFY VALIDATION ====='+verifySuccessful);
        
        if(verifySuccessful){
            mileMigliaNoReadOnly=true;
            custSurnameReadOnly=true;
            verifyCustBtnReadOnly = true;
            
            // Call Alitalia Service
            serviceClient= new AlitaliaPointsServiceClient(custPointsProvider.Alitalia_Points_Service_User__c,custPointsProvider.Alitalia_Points_Service_Password__c);  
            if(inTesting){
                    serviceClient.inTesting= true;
                    serviceClient.login();
            }
            String callErrorCode = '';
            String callErrorMsg = '';
            
            try{ 
                System.debug('========= Calling Verify =========');
                List<String> callResult = null;
                callResult = serviceClient.verifyCustomer(custSurname,mileMigliaNo);
                if(inTesting){
                    callResult = new List<String>();
                    callResult.add('0000');
                    callResult.add('IN TESTING');
                }
                 
                System.debug('========= Called Verify =========');
                if(callResult !=null && callResult.size()>0){
                    callErrorCode = callResult.get(0);
                    callErrorMsg = callResult.get(1);
                    if(callErrorCode != VERIFY_CUSTOMER_SUCCESS_CODE){
                        verifySuccessful  = false; 
                        errorMessageCustomerVerify.add(callErrorCode+' : '+callErrorMsg);
                        finalTransactionStatus = PointsProviderSelectionController.VERIFIED_FAIL;
                    }else{
                        finalTransactionStatus = PointsProviderSelectionController.VERIFIED_SUCCESS;
                        System.debug('===== SUCCESSFUL VERIFY ======'+callErrorCode);
                        System.debug('===== SUCCESSFUL VERIFY ======'+callErrorMsg);
                    }
                }
            }catch(System.CalloutException cex){
                errorMessageCustomerVerify.add('System Exception'+cex);
                verifySuccessful  = false;
            }catch(Exception ex){
                errorMessageCustomerVerify.add('System Exception'+ex);
                verifySuccessful  = false;
            }finally{               
            //Save to SFDC Points Transaction object
                verifyCustomerAuthorisationCode = callErrorCode + ' : ' + callErrorMsg ;
                transactionInProcess = new Points_Transaction__c();
                transactionInProcess.Transaction_Status__c = finalTransactionStatus;
                setupTransactionInProcessObject(TRAN_OBJECT_BASE,transactionInProcess);
                system.debug('======setupTransactionInProcessObject ========');
                // Save to SFDC
                try{
                    doPointsTransactionSave(transactionInProcess);
                    System.debug('======Saved ====transactionInProcess==='+transactionInProcess.Id);
                }catch(Exception exp){
                    errorMessageCustomerVerify.add('Problem Saving toSFDC : '+exp);
                    System.debug('====Save Error ======='+exp);
                }
            }
        }else{
            // set the error message
            errorMessageCustomerVerify = errorMsg;
        }
                
    }
    
    private static final String TRAN_OBJECT_BASE='BASE';
    private static final String TRAN_OBJECT_BONUS = 'BONUS';
    
    private void setupTransactionInProcessObject(String OBJ_TYPE,Points_Transaction__c transObject){
        String transRef = null;
        // validate that the current transaction ref does NOT exist
        do{
            transRef = transVillageCode + VILLAGE_CODE_SUFFIX + getRandomIDValue();
        }while( ((transRef+'').length() < 10) && checkIfExists(transRef)== true);
            
        transObject.Name = 'Alitalia Earn Miles By ' + custSurname +' Trans Ref : '+ transRef;
        
        transObject.Customer_Card_Number__c = mileMigliaNo;
        transObject.Transaction_Reference__c = transRef ;
        transObject.Transaction_Date__c = DateTime.newInstance(System.currentTimeMillis());
        transObject.Village_Code__c = (transVillageCode != null ? transVillageCode : null);
        transObject.Activity_Date__c = activityDate;
        transObject.Transaction_Value__c = totalTransAmountValue;
        transObject.Provider_Id__c = custPointsProvider.Alitalia_Provider_ID__c;
        
        if(OBJ_TYPE == TRAN_OBJECT_BONUS){
            transObject.Promo_Type__c = PointsProviderSelectionController.POINTS_ACCR_BONUS;
            transObject.VR_Transaction_Reference__c = transactionInProcess.Transaction_Reference__c;
        }else{
            transObject.Promo_Type__c = PointsProviderSelectionController.POINTS_ACCR_BASE;
            transObject.VR_Transaction_Reference__c = transRef;
        }
        transObject.Authorise_Code__c = verifyCustomerAuthorisationCode;
        
          
    }
    
    private void disableAllUI(){
        mileMigliaNoReadOnly=true;
            custSurnameReadOnly=true;
            verifyCustBtnReadOnly = true;
            disableCancelButton=true;
    }
    
    private void enableAllUI(){
        mileMigliaNoReadOnly=false;
            custSurnameReadOnly=false;
            verifyCustBtnReadOnly = false;
            disableCancelButton=false;
    }
    
    private void doPointsTransactionSave(Points_Transaction__c transObject){
            List<Points_Transaction__c> transToInsert = new List<Points_Transaction__c>();
            transToInsert.add(transObject);
            Database.SaveResult[] results = Database.insert(transToInsert);
            
                for(Database.SaveResult result : results) {
                    if(!result.isSuccess()) {
                        System.debug('In AlitaliaEarnMilesDatatCaptureController Error Inserting Transaction' + result.getErrors());
                    }else{
                        System.debug('In AlitaliaEarnMilesDatatCaptureController Succesful Inserting Transaction' + result.getId());
                        List<Points_Transaction__c> insertedTransactionRow = [SELECT pT.ID, pT.Name,pT.Customer_Card_Number__c, 
                                pT.Transaction_Reference__c,pT.Transaction_Date__c FROM Points_Transaction__c pT 
                                WHERE pT.Transaction_Reference__c = :transObject.Transaction_Reference__c];
                                
                                for(Points_Transaction__c  transRow : insertedTransactionRow){
                                    transObject = transRow;
                                }
                    }             
            }
    }
    
private void updateTransaction(Points_Transaction__c transObject){
        List<Points_Transaction__c> transToUpdate = new List<Points_Transaction__c>();
        transToUpdate.add(transObject);
        Database.SaveResult[] results = Database.update(transToUpdate);
            
        for(Database.SaveResult result : results) {
            if(!result.isSuccess()) {
                System.debug('In AlitaliaEarnMilesDatatCaptureController Error Updating Transaction' + result.getErrors());
            }else{
                System.debug('In AlitaliaEarnMilesDatatCaptureController Sucessful Updating Transaction' + result.getId());
            }    
       }
    }
    
    public void resetVerifyFields(){
        verifySuccessful  = false;
        errorMessageCustomerVerify=null;
        
        mileMigliaNo='';
        custSurname='';
        this.transAmountValue = null;
        
        mileMigliaNoReadOnly=false;
        custSurnameReadOnly=false;
        verifyCustBtnReadOnly= false;
        
        totalPointsAccrued=null;
        totalTransAmountValue = null;
        
        transactionItemsList=null;
        
        errorMessageConversion=null;
        bonusConversionValue=0;
        
        totalPointsAccrued = 0;
        totalPointsAccruedBonus =0;
        activityDate =null;
        dummyPoints_Transaction.Activity_Date__c = null;
    }
    
        
    private Integer calculatePoints(String basicBonusType,Decimal value){
        Decimal returnVal= 0;
        if(basicBonusType== BASIC_TYPE){
            returnVal = (value * BASIC_CONVERT_POINTS);
        }else{
            returnVal =  (value * bonusConversionValue);
        }
        
        return Integer.valueOf(returnVal.round());
    }

    public Points_Transaction__c transactionInProcess_Bonus{get;set;}
    
    private void processTransaction(){
        // Call the points transfer code
            if(errorMessageConversion == null){
                 errorMessageConversion = new List<String>();
            }
            List<String> callResultBase = null;
            List<String> callResultBonus = null;
            
            transactionInProcess.Activity_Date__c = activityDate;
            transactionInProcess.Points_Value__c = totalPointsAccrued;
            transactionInProcess.Transaction_Value__c = totalTransAmountValue;
            transactionInProcess.Transact_Quantity__c = ((transactionItemsList != null && transactionItemsList.size() > 0) ? transactionItemsList.size() : 0);
            
            if(transactBasicBonus == BASIC_TYPE){
                String callErrorCode = '';
                String callErrorMsg = '';  
                
                try{
                    // CALL The Service
                    callResultBase = serviceClient.doCreditTransfer(custPointsProvider.Alitalia_Partner_Type__c, custPointsProvider.Alitalia_Partner_Code_Base__c, 
                        custSurname,transactionInProcess.Customer_Card_Number__c, totalPointsAccrued, transactionInProcess.Activity_Date__c, 
                        transactionInProcess.Transaction_Reference__c);
                        
                    if(inTesting){
                        callResultBase = new List<String>();
                        callResultBase.add('0000');
                        callResultBase.add('IN TESTING');
                    }
                        
                     callErrorCode = callResultBase.get(0);
                     callErrorMsg = callResultBase.get(1); 
                
                    if(callErrorCode != CREDIT_SUCCESS_CODE){
                        errorMessageConversion.add(callErrorCode+' : '+callErrorMsg);
                        finalTransactionStatus = PointsProviderSelectionController.CREDITING_FAIL;
                    }else{
                        finalTransactionStatus = PointsProviderSelectionController.CREDIT_COMPLETE;
                        system.debug('====== TRANS CREDIT ========'+callErrorCode);
                        system.debug('====== TRANS CREDIT MEG ========'+callErrorMsg);
                    }
                    
                }catch(Exception exp){
                    callErrorCode ='9999';
                    callErrorMsg ='Unexpected System Exception';
                    errorMessageConversion.add(callErrorCode+ ' Unexpected Exception : '+exp);
                }finally{
                    transactionInProcess.Authorise_Code__c = callErrorCode +' : ' + callErrorMsg;
                    transactionInProcess.Transaction_Type__c = PointsProviderSelectionController.POINTS_TRANS_TYPE_CREDIT ;
                    transactionInProcess.Transaction_Status__c = finalTransactionStatus;
                    // update in SFDC
                    try{
                        updateTransaction(transactionInProcess);
                        if(callErrorCode == CREDIT_SUCCESS_CODE){
                            processSuccessfulComplete = true;
                        }
                        
                        System.debug('====Sucess Update ==='+transactionInProcess);
                    }catch(Exception exp){
                        errorMessageConversion.add('Problem Updating to SFDC : '+transactionInProcess.Name+' '+exp);
                    }
                }
                
            }else{
                transactionInProcess_Bonus = new Points_Transaction__c();
                setupTransactionInProcessObject(TRAN_OBJECT_BONUS,transactionInProcess_Bonus);
                transactionInProcess_Bonus.Activity_Date__c = activityDate;
                transactionInProcess_Bonus.Points_Value__c = totalPointsAccruedBonus;
                transactionInProcess_Bonus.Transaction_Value__c = totalTransAmountValue;
                transactionInProcess_Bonus.Transact_Quantity__c = ((transactionItemsList != null && transactionItemsList.size() > 0) ? transactionItemsList.size() : 0);
                
                String callErrorCodeBase = '';
                String callErrorMsgBase = '';
                String callErrorCodeBonus = '';
                String callErrorMsgBonus = '';
                String finalTransactionStatusBase = '';
                String finalTransactionStatusBonus = '';
                
                try{
                    callResultBase = serviceClient.doCreditTransfer(custPointsProvider.Alitalia_Partner_Type__c, custPointsProvider.Alitalia_Partner_Code_Base__c, 
                        custSurname,transactionInProcess.Customer_Card_Number__c, totalPointsAccrued, transactionInProcess.Activity_Date__c, 
                        transactionInProcess.Transaction_Reference__c);

                    if(inTesting){
                        callResultBase = new List<String>();
                        callResultBase.add('0000');
                        callResultBase.add('IN TESTING');
                    
                    }

                                           
                         callErrorCodeBase = callResultBase.get(0);
                         callErrorMsgBase = callResultBase.get(1);
                        system.debug('====== TRANS CREDIT =======BONUS='+callErrorCodeBase);
                        system.debug('====== TRANS CREDIT MEG ==BONUS======'+callErrorMsgBase);
                        
                    if(callErrorCodeBase.trim() == CREDIT_SUCCESS_CODE){
                        finalTransactionStatusBase = PointsProviderSelectionController.CREDIT_COMPLETE;
                        System.debug('====== Ready to Call Bonus==BONUS======'+callErrorCodeBase);
                        callResultBonus = serviceClient.doCreditTransfer(custPointsProvider.Alitalia_Partner_Type__c, custPointsProvider.Alitalia_Partner_Code_Bonus__c, 
                            custSurname,transactionInProcess_Bonus.Customer_Card_Number__c,totalPointsAccruedBonus,transactionInProcess_Bonus.Activity_Date__c,
                            transactionInProcess_Bonus.Transaction_Reference__c);
                            
                        if(inTesting){
                            callResultBonus = new List<String>();
                            callResultBonus.add('0000');
                            callResultBonus.add('IN TESTING');
                        }
                        
                            system.debug('====== Called to  Bonus==BONUS======'+callResultBonus);
                            callErrorCodeBonus = callResultBonus.get(0);
                            callErrorMsgBonus = callResultBonus.get(1);
                            if(callErrorCodeBonus.trim() == CREDIT_SUCCESS_CODE){
                                finalTransactionStatusBonus = PointsProviderSelectionController.CREDIT_COMPLETE;
                            }else{
                                finalTransactionStatusBonus = PointsProviderSelectionController.CREDITING_FAIL;
                            }
                            system.debug('====== Called to  Bonus==BONUS======'+callResultBonus);
                    }else{
                        finalTransactionStatusBase = PointsProviderSelectionController.CREDITING_FAIL;
                        errorMessageConversion.add(callErrorCodeBase+' : '+callErrorMsgBase);
                    }
                    
                }catch(Exception exp){
                    callErrorCodeBase ='9999';
                    callErrorMsgBase ='Unexpected System Exception';
                    errorMessageConversion.add(callErrorCodeBase+ ' Unexpected Exception : '+exp);
                    errorMessageConversion.add(callErrorCodeBonus+ ' Unexpected Exception : '+exp);
                }finally{
                    transactionInProcess.Authorise_Code__c = callErrorCodeBase +' : ' + callErrorMsgBase;
                    transactionInProcess.Transaction_Status__c = finalTransactionStatusBase;
                    transactionInProcess.Transaction_Type__c = PointsProviderSelectionController.POINTS_TRANS_TYPE_CREDIT;
                    
                    transactionInProcess_Bonus.Authorise_Code__c = callErrorCodeBonus +' : ' + callErrorMsgBonus;
                    transactionInProcess_Bonus.Transaction_Status__c = finalTransactionStatusBonus;
                    transactionInProcess_Bonus.Transaction_Type__c = PointsProviderSelectionController.POINTS_TRANS_TYPE_CREDIT;
                    // Save BONUS and Update the BASE
                    try{
                        // Update the BASE
                        updateTransaction(transactionInProcess);
                        System.debug('=====Sucess Updating '+transactionInProcess.Name);
                        
                        // Save the the Bonus
                        doPointsTransactionSave(transactionInProcess_Bonus);
                        System.debug('=====Sucess Updating '+transactionInProcess_Bonus.Name);
                        if((callErrorCodeBase == CREDIT_SUCCESS_CODE) && (callErrorCodeBonus == CREDIT_SUCCESS_CODE)){
                            processSuccessfulComplete = true;
                        }
                    }catch(Exception exp){
                        errorMessageConversion.add('Problem Saving to SFDC BASE/BONUS transaction lines: '+exp);
                    }
                    
                }   
            }
    }
    private Boolean processSuccessfulComplete = false;
     
    public Boolean getHasVerifyCustomerError(){
        if(errorMessageCustomerVerify != null && errorMessageCustomerVerify.size()>0){
            return true;
        }else{
            return false;
        }
    }

    
    public PageReference doTransactionSubmit(){
        if(confirmTransactionSubmit == true){
            activityDate = dummyPoints_Transaction.Activity_Date__c;
            processTransaction();
            if(processSuccessfulComplete){
                PageReference confirmPage = Page.AlitaliaConfirmationScreen;
                confirmPage.getParameters().put('mmCodeParam',transactionInProcess.Customer_Card_Number__c);
                confirmPage.getParameters().put('customerSurnameParam',custSurname);
                confirmPage.getParameters().put('activityDateParam',transactionInProcess.Activity_Date__c+'');
               confirmPage.getParameters().put('totalPointsBaseParam',totalPointsAccrued+'');
               confirmPage.getParameters().put('totalPointsBonusParam',totalPointsAccruedBonus+'');
               confirmPage.getParameters().put('transactionReferenceParam',transactionInProcess.Transaction_Reference__c);
               
                return confirmPage;
            }else{
                return null;
            }
        }else{
            return null;
        }    
    }
    

    
}